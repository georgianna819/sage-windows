# TODO: Don't hard-code "default", port #s, etc.
$vmname = "default"
$image = "sagemath/sagemath-jupyter"
$container = "sagemath-windows"
$port = 8888
$timeout = 5000
$retries = 3

if (Test-Path -Path 'Env:VBOX_MSI_INSTALL_PATH') {
    $vbm = (Join-Path -Path $env:VBOX_MSI_INSTALL_PATH -ChildPath 'VBoxManage.exe')
}
else {
    $vbm = (Join-Path -Path $env:VBOX_INSTALL_PATH -ChildPath 'VBoxManage.exe')
}

$docker = Join-Path -Path $env:DOCKER_TOOLBOX_INSTALL_PATH -ChildPath 'docker.exe'

# Source Start-DockerMachine to ensure Docker VM is running and environment
# variables needed by the docker command to communicate with its host are set
. lib\Start-DockerMachine.ps1
. lib\Test-PortConnection.ps1



# Set up the VM port forwarding
& $vbm controlvm "$vmname" natpf1 "sagemath,tcp,,$port,,$port"

& $docker run -d -p "${port}:${port}" --name $container $image

# Wait to make sure the server connection is up
Write-Host -NoNewline "Testing web server connection..."
do {
    $res = Test-PortConnection -TargetHost "localhost" -TargetPort $port -Timeout $timeout
    if($res.ConnectionStatus -eq "Success") {
        break
    }
    Write-Host ""
    Write-Host -NoNewLine "Retrying..."
    $retries -= 1
} while($retries -gt 0)

if($retries -eq 0) {
    Write-Host ""
    Write-Host "Starting SageMath server failed."
    Read-Host -Prompt "Press Enter to exit..."
} else {
    Write-Host "[READY]"
}

# This should launch the default web browser
& explorer.exe http://localhost:$port
