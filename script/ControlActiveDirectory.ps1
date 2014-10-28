#
# Change AD parameters for a mailbox database 
#

Import-Module ActiveDirectory

# Set error codes
$ErrorGetADDomain    = 20
$ErrorGetADObject    = 21
$ErrorSetADObject    = 22
$ErrorRenameADObject = 23

# Set my script name
$MyName = $MyInvocation.MyCommand.Name
Write-Output "$MyName (PID:$PID) : Started."

# Get computer name
$ComputerName = $env:COMPUTERNAME

# Insert the environment variables to the local variables
$OrganizationName = $env:OrganizationName
$AdministrativeGroupName = $env:AdministrativeGroupName
$MailboxDatabaseName = $env:MailboxDatabaseName

# Get Active Directory name
$ActiveDirectoryName = (Get-ADDomain).DistinguishedName
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Get-ADDomain failed." -i $ErrorGetADDomain -l ERR
        exit $ErrorGetADDomain
}

# Show the variables
Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Output "Organization              : $OrganizationName" 
Write-Output "Administrative Group      : $AdministrativeGroupName" 
Write-Output "Computer Name             : $ComputerName"
Write-Output "Active Directory          : $ActiveDirectoryName"
Write-Output "Mailbox Database          : $MailboxDatabaseName" 

# Set mailbox database distinguished name
$MailboxDatabaseDN = "CN=" + $MailboxDatabaseName +`
                     ",CN=Databases" +`
                     ",CN=" + $AdministrativeGroupName +`
                     ",CN=Administrative Groups" +`
                     ",CN=" + $OrganizationName +`
                     ",CN=Microsoft Exchange" +`
                     ",CN=Services" +`
                     ",CN=Configuration" +`
                     "," + $ActiveDirectoryName
Write-Output "MailboxDatabaseDN         : $MailboxDatabaseDN"

# Set server distinguished name
$ServerDN = "CN=" + $ComputerName +`
            ",CN=Servers" +`
            ",CN=" + $AdministrativeGroupName +`
            ",CN=Administrative Groups" +`
            ",CN=" + $OrganizationName +`
            ",CN=Microsoft Exchange" +`
            ",CN=Services" +`
            ",CN=Configuration" +`
            "," + $ActiveDirectoryName
Write-Output "ServerDN                  : $ServerDN"

# Set legacyExchangeDN
$ExchangeDN = "/o=" + $OrganizationName +`
              "/ou=" + $AdministrativeGroupName +`
              "/cn=Configuration" +`
              "/cn=Servers" +`
              "/cn=" + $ComputerName +`
              "/cn=Microsoft Private MDB"
Write-Output "ExchangeDN                : $ExchangeDN"
Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++"

# Get mailbox database object
$MailboxDatabaseObject = Get-ADObject -Identity $MailboxDatabaseDN -Properties *
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Get-ADObject failed." -i $ErrorGetADObject -l ERR
        exit $ErrorGetADObject
}
$msExchMasterServerOrAvailabilityGroup = $MailboxDatabaseObject.msExchMasterServerOrAvailabilityGroup
$msExchOwningServer = $MailboxDatabaseObject.msExchOwningServer
$legacyExchangeDN = $MailboxDatabaseObject.legacyExchangeDN
Write-Output "msExchMasterServerOrAG (B): $msExchMasterServerOrAvailabilityGroup"
Write-Output "msExchOwningServer     (B): $msExchOwningServer"
Write-Output "legacyExchangeDN       (B): $legacyExchangeDN"

# Replace
Set-ADObject $MailboxDatabaseObject -Replace @{msExchMasterServerOrAvailabilityGroup="$ServerDN"}
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Set-ADObject failed." -i $ErrorSetADObject -l ERR
        exit $ErrorSetADObject
}
Set-ADObject $MailboxDatabaseObject -Replace @{msExchOwningServer="$ServerDN"}
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Set-ADObject failed." -i $ErrorSetADObject -l ERR
        exit $ErrorSetADObject
}
Set-ADObject $MailboxDatabaseObject -Replace @{legacyExchangeDN="$ExchangeDN"}
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Set-ADObject failed." -i $ErrorSetADObject -l ERR
        exit $ErrorSetADObject
}
$MailboxDatabaseObject = Get-ADObject -Identity $MailboxDatabaseDN -Properties *
$bRet = $?
if ($bRet -eq $False)
{
        Write-Output "$MyName : Get-ADObject failed, ignore."
}
$msExchMasterServerOrAvailabilityGroup = $MailboxDatabaseObject.msExchMasterServerOrAvailabilityGroup
$msExchOwningServer = $MailboxDatabaseObject.msExchOwningServer
$legacyExchangeDN = $MailboxDatabaseObject.legacyExchangeDN
Write-Output "msExchMasterServerOrAG (A): $msExchMasterServerOrAvailabilityGroup"
Write-Output "msExchOwningServer     (A): $msExchOwningServer"
Write-Output "legacyExchangeDN       (A): $legacyExchangeDN"

# Get msExchMDBcopy distinguished name
$msExchMDBcopyDN = Get-ADObject -Filter {(ObjectClass -Like "msExchMDBcopy")}`
                                -SearchBase $MailboxDatabaseDN
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Get-ADObject failed." -i $ErrorGetADObject -l ERR
        exit $ErrorGetADObject
}
Write-Output "msExchMDBcopyDN        (B): $msExchMDBcopyDN"

# Get mailbox database property
$msExchMDBcopyObject = Get-ADObject -Identity $msExchMDBcopyDN -Properties *
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Get-ADObject failed." -i $ErrorGetADObject -l ERR
        exit $ErrorGetADObject
}
$msExchHostServerLink = $msExchMDBcopyObject.msExchHostServerLink
Write-Output "msExchHostServerLink   (B): $msExchHostServerLink"

# Replace
Set-ADObject -Identity $msExchMDBcopyObject -Replace @{msExchHostServerLink="$ServerDN"}
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Get-ADObject failed." -i $ErrorGetADObject -l ERR
        exit $ErrorGetADObject
}
$msExchMDBcopyObject = Get-ADObject -Identity $msExchMDBcopyDN -Properties *
$bRet = $?
if ($bRet -eq $False)
{
        Write-Output "$MyName : Get-ADObject failed, ignore."
}
$msExchHostServerLink = $msExchMDBcopyObject.msExchHostServerLink
Write-Output "msExchHostServerLink   (A): $msExchHostServerLink"

# Rename mailbox database property
Rename-ADObject -Identity "$msExchMDBcopyDN" -NewName "$ComputerName"
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Rename-ADObject failed." -i $ErrorRenameADObject -l ERR
        exit $ErrorRenameADObject
}
$msExchMDBcopyDN = Get-ADObject -Filter {(ObjectClass -Like "msExchMDBcopy")}`
                                -SearchBase $MailboxDatabaseDN
$bRet = $?
if ($bRet -eq $False)
{
        Write-Output "Get-ADObject failed, ignore."
}
Write-Output "msExchMDBcopyDN        (A): $msExchMDBcopyDN"

Write-Output "$MyName (PID:$PID) : Completed successfully."
exit 0
