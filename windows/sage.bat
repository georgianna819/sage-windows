set sagepath=%~dp0
cd /d %sagepath%
@powershell -ExecutionPolicy Unrestricted -Command ./Start-Sagemath.ps1
