#
# Check if all Exchange services are running
#

# Set error codes
$ErrorGetService =    10
$ErrorServiceStatus = 11

# Set my script name
$MyName = $MyInvocation.MyCommand.Name
Write-Output "$MyName (PID:$PID) : Started."

# Set service name for an array (Exchange Server 2010 SP3 RU7)
$ExchangeServices = @(
"MSExchangeAB",
"MSExchangeADTopology",
"MSExchangeAntispamUpdate",
"MSExchangeEdgeSync",
"MSExchangeFBA",
"MSExchangeFDS",
<#
"MSExchangeImap4",
#>
"MSExchangeIS",
"MSExchangeMailboxAssistants",
"MSExchangeMailboxReplication",
"MSExchangeMailSubmission",
<#
"MSExchangeMonitoring",
"MSExchangePop3",
#>
"MSExchangeProtectedServiceHost",
"MSExchangeRepl",
"MSExchangeRPC",
"MSExchangeSA",
"MSExchangeSearch",
"MSExchangeServiceHost",
"MSExchangeThrottling",
"MSExchangeTransport",
"MSExchangeTransportLogSearch",
"msftesql-Exchange"
)

# Check if all Exchange services are running
Write-Output "Wait for all Exchange services to be running..."
<#
:checkService while($True)
#>
:checkService1 for ($i = 0; $i -lt $env:RetryCount; $i++)
{
        :checkService2 for ($j = 0; $j -lt $ExchangeServices.Count; $j++)
        {
                $ServiceName = $ExchangeServices[$j]
                $CurrentService = Get-Service -Name $ServiceName
                $bRet = $?
                if ($bRet -eq $False)
                {
                        clplogcmd -m "Get-Service failed." -i $ErrorGetService -l ERR
                }
                else
                {
                        $DisplayName = $CurrentService.DisplayName
                        $Status = $CurrentService.Status
                        if ($Status -eq "Running")
                        {
<# DEBUG
                                Write-Output "$DisplayName : $Status (retry:$i)"
#>
                        }
                        else
                        {
                                Write-Output "$DisplayName : $Status (retry:$i)"
                                Write-Output "Wait for $DisplayName to be running."
                                break checkService2
                        }
                }
        }
        if ($j -eq $ExchangeServices.Count)
        {
                Write-Output "All Exchange services are running."
                break checkService1
        }
        armsleep $env:RetryInterval
}
if ($i -eq $env:RetryCount)
{
        clplogcmd -m "Some Exchange services are not running." -i $ErrorServiceStatus -l ERR
        Write-Output "Some Exchange services are not running."
}
else
{
        Write-Output "$MyName (PID:$PID): Completed successfully."
        Write-Output "$MyName (PID:$PID): Retry - $i"
        exit 0
}

# Start up Exchange services
Write-Output "Try to start Exchange services."
:startService1 for ($i = 0; $i -lt $env:RetryCount; $i++)
{
        :startService2 for ($j = 0; $j -lt $ExchangeServices.Count; $j++)
        {
                $ServiceName = $ExchangeServices[$j]
                $CurrentService = Get-Service -Name $ServiceName
                $bRet = $?
                if ($bRet -eq $False)
                {
                        clplogcmd -m "Get-Service failed." -i $ErrorGetService -l ERR
                }
                else
                {
                        $DisplayName = $CurrentService.DisplayName
                        $Status = $CurrentService.Status
                        if ($Status -eq "Stopped")
                        {
                                Write-Output "$DisplayName : $Status (retry:$i)"
                                Write-Output "Start $DisplayName."
                                Start-Service -Name $ServiceName
                                break startService2
                        }
                        elseif ($Status -eq "Running")
                        {
<# DEBUG
                                Write-Output "$DisplayName : $Status (retry:$i)"
#>
                        }
                        else
                        {
                                Write-Output "$DisplayName : $Status (retry:$i)"
                                break startService2
                        }
                }
        }
        if ($j -eq $ExchangeServices.Count)
        {
                Write-Output "All Exchange services are running."
                break startService1
        }
        armsleep $env:RetryInterval
}
if ($i -eq $env:RetryCount)
{
        clplogcmd -m "Some Exchange services are not running." -i $ErrorServiceStatus -l ERR
        Write-Output "$MyName (PID:$PID): Retry count exceeded."
        for ($j = 0; $j -lt $ExchangeServices.Count; $j++)
        {
                $ServiceName = $ExchangeServices[$j]
                $CurrentService = Get-Service -Name $ServiceName
                $bRet = $?
                if ($bRet -eq $False)
                {
                        clplogcmd -m "Get-Service failed." -i $ErrorGetService -l ERR
                }
                $DisplayName = $CurrentService.DisplayName
                $Status = $CurrentService.Status
                Write-Output "$DisplayName : $Status (retry:$i)"
        }
        exit $ErrorServiceStatus
}
else
{
        Write-Output "$MyName (PID:$PID): Completed successfully."
        Write-Output "$MyName (PID:$PID): Retry - $i"
        exit 0
}
