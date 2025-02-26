@echo off

SET ORICUTRON="..\..\..\oricutron-iss\"

SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

SET ROM=shell

%CC65%\ca65.exe -DWITH_SDCARD_FOR_ROOT=1 -ttelestrat --include-dir %CC65%\asminc\ src/%ROM%.asm -o %ROM%.ld65  --debug-info --verbose
%CC65%\ld65.exe -tnone -DWITH_SDCARD_FOR_ROOT=1 %ROM%.ld65 -o %ROM%.rom  -Ln shell.sym



IF "%1"=="NORUN" GOTO End

copy %ROM%.rom %ORICUTRON%\roms\ > NUL

xcopy data\*.* %ORICUTRON%\sdcard\ > NUL

cd %ORICUTRON%
oricutron -mt  --symbols "%ORIGIN_PATH%\xa_labels_orix.txt"

:End
cd %ORIGIN_PATH%
%OSDK%\bin\MemMap "%ORIGIN_PATH%\xa_labels_orix.txt" memmap.html O docs/telemon.css

