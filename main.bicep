param location string = 'westeurope'

// param storageAccountRGName string = 'rg-weu-cse'

// param vmssName string

@description('Size of VMs in the VM Scale Set.')
param vmSize string = 'Standard_B2ms'

@description('When true this limits the scale set to a single placement group, of max size 100 virtual machines')
param singlePlacementGroup bool = true

@description('Admin username on all VMs.')
param adminUsername string

@description('Admin password on all VMs.')
@secure()
param adminPassword string

// @description('Location of the PowerShell DSC zip file relative to the URI specified in the _artifactsLocation, i.e. DSC/IISInstall.ps1.zip')
// param powershelldscZip string = 'https://stoweuscript.blob.core.windows.net/dsc/dsc.zip'

// @description('Location of the  of the WebDeploy package zip file relative to the URI specified in _artifactsLocation, i.e. WebDeploy/DefaultASPWebApp.v1.0.zip')
// param webDeployPackageFullPath string = 'https://stoweuscript.blob.core.windows.net/dsc/DefaultASPWebApp.v1.0.zip'

// @description('Version number of the DSC deployment. Changing this value on subsequent deployments will trigger the extension to run.')
// param powershelldscUpdateTagVersion string = '1.0'

// @description('Fault Domain count for each placement group.')
// param platformFaultDomainCount int = 1

var vm1Name = 'myVM1'
var vm2Name = 'myVM2'


var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'


// var ipConfigName = '${vmScaleSetName}ipconfig'

var vNetName = 'vnet-weu-cseVM'
var publicIPVM1Name = 'pubip-weu-VM1'
var publicIPVM2Name = 'pubip-weu-VM2'

var subnetName = 'subnet-weu-VM'

var storageAccountVM1Name = 'stoweucsevm1'
var storageAccountVM2Name = 'stoweucsevm2'


// ---------------------------------------------------------------------------------------------------------------------------------------------------------

// var loadBalancerName = 'lbweusset'

// var publicIPAddressID = publicIPAddress.id

// var bePoolName = 'bepool-weu-LB'
// var natPoolName = '${vmScaleSetName}natpool'
// var frontEndIPConfigID = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'loadBalancerFrontEnd')

// var lbPoolID = resourceId('Microsoft.Network/loadBalancers.backendAddressPools', loadBalancerName, bePoolName)

// var natStartPort = 50000

// var natEndPort = 


// var natBackendPort = 3389

// var lbProbeID = resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'tcpProbe')

// ------------------------------------------------------------------------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------------------------------------------------------------------------

// resource loadBalancer 'Microsoft.Network/loadBalancers@2021-05-01' = {
//   name: loadBalancerName
//   location: location
//   properties: {
//     frontendIPConfigurations: [
//       {
//         name: 'LoadBalancerFrontEnd'
//         properties: {
//           publicIPAddress: {
//             id: publicIPAddressID
//           }
//         }
//       }
//     ]
//     backendAddressPools: [
//       {
//         name: bePoolName
//       }
//     ]
//     inboundNatPools: [
//       {
//         name: natPoolName
//         properties: {
//           frontendIPConfiguration: {
//             id: frontEndIPConfigID
//           }
//           protocol: 'Tcp'
//           frontendPortRangeStart: natStartPort
//           frontendPortRangeEnd: natEndPort
//           backendPort: natBackendPort
//         }
//       }
//     ]
//     loadBalancingRules: [
//       {
//         name: 'LBRule'
//         properties: {
//           frontendIPConfiguration: {
//             id: frontEndIPConfigID
//           }
//           backendAddressPool: {
//             id: lbPoolID
//           }
//           protocol: 'Tcp'
//           frontendPort: 80
//           backendPort: 80
//           enableFloatingIP: false
//           idleTimeoutInMinutes: 5
//           probe: {
//             id: lbProbeID
//           }
//         }
//       }
//     ]
//     probes: [
//       {
//         name: 'tcpProbe'
//         properties: {
//           protocol: 'Tcp'
//           port: 80
//           intervalInSeconds: 5
//           numberOfProbes: 2
//         }
//       }
//     ]
//   }
// }

// ---------------------------------------------------------------------------------------------------------------------------------------------------------

resource publicIPAddressVM1 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIPVM1Name
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'cse1'
    }
  }
}

// ---------------------------------------------------------------------------------------------------------------------

resource windowsVM1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vm1Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'logitech'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'diskweucse1'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceVM1.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri:  storageAccountVM1.properties.primaryEndpoints.blob
      }
    }
  }
}

resource windowsVMExtensions 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
parent: windowsVM1
name: 'CSE1'
location: location
properties: {
  publisher: 'Microsoft.Compute'
  type: 'CustomScriptExtension'
  typeHandlerVersion: '1.10'
  autoUpgradeMinorVersion: true
protectedSettings: {
  commandToExecute: 'powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)'
}  
}
}

// -----------------------------------------------------------------------------------

resource publicIPAddressVM2 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIPVM2Name
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'cse2'
    }
  }
}


resource windowsVM2 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vm2Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'intern'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'diskweucse2'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceVM2.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri:  storageaccountVM2.properties.primaryEndpoints.blob
      }
    }
  }
}

// ---------------------------------------------------------------------------------------------------------


resource windowsVMExt 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: windowsVM2
  name: 'CSE2'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
  protectedSettings: {
    commandToExecute: 'powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)'
  }  
  }
  }



// resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
// name: storageAccountName
// scope: resourceGroup(storageAccountRGName)
// }

// -----------------------------------------------------------------------------------------------------------------

resource networkInterfaceVM1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'nic-weu-VM1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfigVM1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddressVM1.id
        
          }
          subnet: {
            id: vNet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------------------------------------------


resource storageAccountVM1 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountVM1Name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// -----------------------------------------------------------------------------------------------

resource networkInterfaceVM2 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'nic-weu-VM2'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfigVM2'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddressVM2.id
          }
          subnet: {
            id: vNet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource storageaccountVM2 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountVM2Name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}


// ------------------------------------------------------------------------------------------------------------------

  
  resource vNet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
    name: vNetName
    location: location
    properties: {
      addressSpace: {
        addressPrefixes: [
          addressPrefix
        ]
      }
      subnets: [
        {
          name: subnetName
          properties: {
            addressPrefix: subnetPrefix
          }
        }
        // {
        //   name: 'Subnet-2'
        //   properties: {
        //     addressPrefix: '10.0.1.0/24'
        //   }
        // }
      ]
    }
  }
