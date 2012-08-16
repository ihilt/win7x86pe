@echo off
copy winpe.wim ISO\sources\boot.wim
oscdimg -n -betfsboot.com ISO\ win7x86pe.iso