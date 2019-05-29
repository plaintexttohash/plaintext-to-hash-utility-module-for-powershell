@ECHO OFF
SET current_directory=%~dp0
PowerShell.exe -Command "%current_directory%example\PipelineExample.ps1"
PAUSE