# TODO: Don't hard-code "default", port #s, etc.
[CmdletBinding()]
Param(
    [switch]$OpenBrowser = $false,
    [switch]$Notebook = $false
)

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
$machine = Join-Path -Path $env:DOCKER_TOOLBOX_INSTALL_PATH -ChildPath 'docker-machine.exe'

# Source Start-DockerMachine to ensure Docker VM is running and environment
# variables needed by the docker command to communicate with its host are set
. lib\Start-DockerMachine.ps1
. lib\Test-PortConnection.ps1

# Annoyingly, boot2docker currently tends to mount the /C/Users under
# "/c/Users", and when we set up volume mounting it is case-sensitive
# so just to make sure both cases exist we create a symlink if necessary
& $machine ssh $vmname '[ ! -d /C ] && sudo ln -sf /c /C'

# Set up the VM port forwarding
# Silence errors that occur if the port map is already configured
if($Notebook) {
    & $vbm controlvm "$vmname" natpf1 "sagemath,tcp,,$port,,$port" > $null 2>&1
}

$mount = "/" + ($env:USERPROFILE -Replace '\\','/' -Replace ':','') + ":/home/sage"

if($Notebook) {
    # The default entry-point for the sagemath-jupyter container
    # is to start the notebook; only need to override it for console
    # mode
    $entrypoint = ""
    $interactivity = "-d"
} else {
    $entrypoint = "--entrypoint=sage"
    $interactivity = "-t -i"
}

& $docker run $interactivity.Split() -p "${port}:${port}" -v "$mount" --name $container $entrypoint $image

if($Notebook) {
# Wait to make sure the server connection is up
    $dmip = (& $dm ip $vmname | Out-String).Trim()

    Write-Host -NoNewline "Testing web server connection..."
    do {
        $res = Test-PortConnection -TargetHost $dmip -TargetPort $port -Timeout $timeout
        if($res.ConnectionStatus -eq "Success") {
            break
        }
        Write-Host ""
        $retries -= 1
        if($retries -gt 0) {
            Write-Host -NoNewLine "Retrying..."
        }
    } while($retries -gt 0)

    if($retries -eq 0) {
        Write-Host ""
        Write-Host "Starting SageMath server failed."
        Read-Host -Prompt "Press Enter to exit..."
    } else {
        Write-Host "[READY]"
    }

# This should launch the default web browser
    if($OpenBrowser) {
        & explorer.exe http://localhost:$port
    }
}
