@echo off
cd /d "%~dp0"

REM clone ysm models repo
git clone https://github.com/Elaina69/Yes-Steve-Model-Repo.git
if errorlevel 1 exit /b 1

REM move ysm models repo to custom/ (files and directories)
robocopy Yes-Steve-Model-Repo . /E /MOVE /NFL /NDL /NJH /NJS /nc /ns /np >nul
if exist Yes-Steve-Model-Repo rmdir /s /q Yes-Steve-Model-Repo
