Param (
# Name of the environment
[Parameter(Mandatory=$true)][string] $environmentName,
[Parameter(Mandatory=$true)][string] $subscriptionId,
[Parameter(Mandatory=$true)][string] $aadAdminUpn,
[string] $region = "westus2"
)


#https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site

$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=${environmentName}-${region}-P2S-Root" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

$thumbprint = $cert.Thumbprint

$rootCertBase64 = [convert]::tobase64string((get-item cert:\currentuser\my\$thumbprint).RawData)

New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
-Subject "CN=${environmentName}-${region}-P2S-Client" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

$vars = @{
    "subscription_id" = $subscriptionId
    "environment_name" = $environmentName
    "aad_admin_upn" = $aadAdminUpn
    "p2s_root_cert_data_base64" = $rootCertBase64
}

Set-Content -Path ./terraform/variables.auto.tfvars.json -Value ($vars | ConvertTo-Json)