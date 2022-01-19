#List of servers you want to update with a new SSL cert
$serverList = ('server1','server2','server3')
#Initial file location
$srcFile = "\\myremote\server\mynewSSL.pfx"
#Path where you want to save the file to
$destFile = "C:\temp\mynewSSL.pfx"

Invoke-Command -ComputerName $serverList -ScriptBlock { 

  Write-host "Connected to: $env:computername"
  #Copy file to the remote server
  Copy-Item -Path $srcFile -Destination $destFile
  #Import the SSL cert into the system
  Import-Certificate -FilePath $destFile -CertStoreLocation Cert:\LocalMachine\My
}
