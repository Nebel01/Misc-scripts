#Created by Davide Basso, this script helps automate download of files from SAP Concur and decrypt using a key that has been shared with SAP Concur support.
#This script requires that gpg is already installed on a Windows machine and the public and private key are already set up.
#Later, you need to set up a Task Scheduler task to run this scipt as you need.
#Note: In order to use this automation you need to have WinSCP Automation which can be donwload for free and an alternative download to the original version which adds
#the support of .Net library.

try
{
    $remoteFolder = "out"
    $localFolder  = "C:\SAP Concur\out"
    # Load WinSCP .NET assembly
    Add-Type -Path "<Your_full_path_to_WinSCPAutomation_folder>\WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = "<hostname_provided_by_Concur>"
        UserName = "<username_provided_by_Concur>"
        #Concur SFTP password is saved as environmnet variable
        #Private key password stored in the computer env
        PrivateKeyPassphrase = $env:concur_sftp
        SshHostKeyFingerprint = "<SSH_finger_print>"
        SshPrivateKeyPath = "<full_path_to_SSL_key>\concur_ssh_private_key.ppk"      

    } 
    $session = New-Object WinSCP.Session
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
        # Get list of files in the directory
        $directoryInfo = $session.ListDirectory($remoteFolder) 
        # Select the most recent file
        $latest =
            $directoryInfo.Files |
            Where-Object { -Not $_.IsDirectory } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
 
        # Any file at all?
        if ($latest -eq $Null)
        {
            Write-Host "No file found"
            exit 1
        }
 
		    $fullFileName = $localFolder+"\"+$latest.Name
        $decrptedFullName = $localFolder+"\"+($latest.Name -replace ".pgp","")

        if(Test-Path $decrptedFullName) {
            Write-Host "latest file already present"
        } 
        else {
            #Remove the encrypted file and I leave the historical files present in the folder
            Remove-Item -Path "$localFolder\*.pgp"
            # Download the selected file
            $session.GetFileToDirectory($latest.FullName, $localFolder) | Out-Null
			      #Decript the donwloaded file with gpg and delete the file
            gpg --batch --yes --passphrase="$env:concur_sftp" --pinentry-mode loopback -o $decrptedFullName -d $fullFileName
			      Remove-item $fullFileName
        }

    }
    finally
    {
        $session.Close()
        # Disconnect, clean up
        $session.Dispose()
    } 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
