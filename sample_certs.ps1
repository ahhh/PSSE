# PowerShell script for playing around with PKI certificates

# Write out all certs
Get-ChildItem -Recurse Cert: > certs.txt

#Search for all Microsoft certs
dir cert:\ -rec | select-String -inputobject {$_.Subject} -pattern "Microsoft"

# Print MS root cert thumbprint
$targetCert = Get-ChildItem -Recurse Cert: | Where-Object {$_.FriendlyName -eq "Microsoft Root Certificate Authority"}
$certHash = $targetCert.Thumbprint
echo "Microsoft Root Certificate Authority Hash: $certHash"
