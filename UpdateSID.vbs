'// UpdateSID.vbs - GES JRW
'// Sophos Script to acquire the current SID values for the Sophos groups then replace the values in Machine.xml
'// Note: In order for this to work, the SAV service will be stopped and then started, losing on-access protection momentarily

Option Explicit
Dim xmlFile, fileSys, wshShell, objWMIService, profilePath, grpName, intSize, sidArr(), strSAVService
Set fileSys = CreateObject("Scripting.FileSystemObject")
Set wshShell = CreateObject("WScript.Shell")
set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly = &h20

intSize = 0
strSAVService = "SAVService"
profilePath = wshShell.ExpandEnvironmentStrings("%ALLUSERSPROFILE%")

If filesys.FileExists(profilePath&"\Application Data\Sophos\Sophos Anti-Virus\Config\machine.xml") Then'
	xmlFile = profilePath&"\Application Data\Sophos\Sophos Anti-Virus\Config\machine.xml"
Else
	Wscript.quit
End if

Function StopService()
    dim intStopAttempts, intIsRunning, intWaitForServiceStopInSeconds
    dim i, colListOfServices, objService
    intStopAttempts                = 3
    intIsRunning                   = 1
    intWaitForServiceStopInSeconds = 5
    for i = 1 to intStopAttempts
        set colListOfServices = objWMIService.ExecQuery("SELECT State FROM Win32_Service WHERE Name ='" & strSAVService & "'")
        For Each objService in colListOfServices
            if objService.state = "Stopped" then
                intIsRunning = 0
                i = intStopAttempts
            else
                objService.StopService()
                wscript.sleep intWaitForServiceStopInSeconds * 1000
                intIsRunning = 1
            end if
        Next
    next
    if intIsRunning = 0 then 
        StopService = true
    else
        StopService = false
    end if
End function

Function StartService()
	dim colListOfServices, objService
    set colListOfServices = objWMIService.ExecQuery("Select state from Win32_Service Where Name ='" & strSAVService & "'")
	for each objService in colListOfServices
        objService.StartService()
    next
End Function

Sub GetSID(grpName)
	Dim objItem, colItems
	ReDim sidArr(intSize)
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_Group WHERE Name = '" & grpName &"'", "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly)
	For Each objItem In colItems
		sidArr(UBound(sidArr)) = objItem.SID
		ReDim Preserve sidArr(UBound(sidArr) + 1)
	Next
End Sub

Sub updateSID(grpName)
	Dim xmlDoc, objNode, child, i, newSID, valSID
	Set xmlDoc = CreateObject("Microsoft.XMLDOM")
	xmlDoc.load (xmlFile)
	If xmlDoc.parseError.errorCode Then
		StartService()
		MsgBox("Cannot load Machine.xml.")
		WScript.quit 
	End If
	Set objNode = xmlDoc.selectSingleNode("/configuration/components/configurationManager/security/roles/role[@name='" & grpName & "']")
	For Each child In ObjNode.childNodes
		objNode.removeChild(child)
	Next
	For i = 0 To UBound(sidArr) -1
		Set newSID = xmlDoc.createElement("SID")
		Set valSID = xmlDoc.createTextNode(sidArr(i))
		objNode.appendChild(newSID)
		newSID.appendChild(valSID)
	Next
	xmlDoc.Save(xmlFile)
End sub

If StopService() = True Then
	GetSID("SophosAdministrator")
	updateSID("SophosAdministrator")
	GetSID("SophosPowerUser")
	updateSID("SophosPowerUser")
	GetSID("SophosUser")
	updateSID("SophosUser")
End If

StartService()
MsgBox("Script Complete.")