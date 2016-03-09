# Test-PortConnection: Newer versions of PowerShell include a built-in cmdlet
# for this, but it is not available on the default install in Windows 7
# Thanks http://techibee.com/powershell/powershell-test-port-connectivity/1214
function Test-PortConnection {
    [CmdletBinding()]
    Param(
        [parameter(mandatory=$true)]
        [string]$TargetHost,

        [parameter(mandatory=$true)]
        [int32]$TargetPort,

        [int32] $Timeout = 10000
    )

    $OutputObj = New-Object -TypeName PSobject

    $OutputObj | Add-Member -MemberType NoteProperty -Name TargetHostName -Value $TargetHost

    if(Test-Connection -ComputerName $TargetHost -Count 2) {
        $OutputObj | Add-Member -MemberType NoteProperty -Name TargetHostStatus -Value "ONLINE"
    } else {
        $OutputObj | Add-Member -MemberType NoteProperty -Name TargetHostStatus -Value "OFFLINE"
    }

    $OutputObj | Add-Member -MemberType NoteProperty -Name PortNumber -Value $targetport

    $Socket = New-Object System.Net.Sockets.TCPClient
    $Connection = $Socket.BeginConnect($Targethost,$TargetPort,$null,$null)
    $Connection.AsyncWaitHandle.WaitOne($timeout,$false)  | Out-Null

    if($Socket.Connected -eq $true) {
        $OutputObj | Add-Member -MemberType NoteProperty -Name ConnectionStatus -Value "Success"
    } else {
        $OutputObj | Add-Member -MemberType NoteProperty -Name ConnectionStatus -Value "Failed"
    }

    $Socket.Close | Out-Null
    Return $OutputObj
}
