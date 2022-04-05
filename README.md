# Hub and Spok network on the cheap

Hub and spoke network on a budget for labs and experimenting with VPN, DNS, private link, etc.

# Setting up an environment
Unfortunately this assumes a windows machine at this time. Certificate management and VPN setup are wildly different on each system. I use windows primarily and so this is what was reasonable to accomplish. The process up to the VPN should be similar on Linux or Mac with openssl instead of windows cert store calls.

There are 3 powershell scripts in the root of this repo, start by cloning or downloading.

> terraform is required and admin access will be required for VPN setup

> Environment name can be whatever you want, but it should be unique for some resources and between 5-16 characters with no special characters and begin with a letter. Azure can be rough because resource name is often a global DNS name.

Fill in the placeholders and then run

```powershell
./setup-basics.ps1 `
-subscriptionId {GUID} `
-environmentName {string} `
-aadAdminUpn {email} `
-region {string}
```

```powershell
cd terraform
terraform init
terraform apply
cd ..
```

```powershell
cd ..
./setup-vpn.ps1 -environmentName {string} -region {string}
```