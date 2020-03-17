@echo off

SET DIR=%~dp0%
cd %DIR%
::install chocolatey
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install_chocolatey.ps1' %*" -Verb RunAs
call refresh_path.bat
::install git,node and python
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install_deps.ps1' %*" -Verb RunAs
call refresh_path.bat
pip install virtualenv 
virtualenv venv
call venv/scripts/activate
call git clone https://github.com/doccano/doccano.git doccano
cd %DIR%doccano
call git checkout bdba2961bf7942eb529a1591a7499b5d15af73bf
git config --global url."https://".insteadOf git://
pip install -r %DIR%doccano\requirements.txt
cd %DIR%doccano\frontend
SET PATH=%PATH%;%systemroot%\System32\WindowsPowerShell\v1.0\
::call npm install --global --production windows-build-tools
call npm install
call npm run build
cd %DIR%doccano\app
python manage.py migrate
python manage.py createsuperuser
call deactivate
cd %DIR%doccano\app\server\static
call npm install
cd %DIR%
copy %DIR%annotation.html %DIR%doccano\app\server\templates /Y
net stop doccano /Y
nssm remove doccano confirm
nssm install doccano %DIR%run_doccano.bat %DIR%
nssm start doccano
net stop start_webpack /Y
nssm remove start_webpack confirm
nssm install start_webpack %DIR%start_webpack.bat %DIR%
nssm start start_webpack




