// that's the default, but put it here for completeness
targetScope = 'resourceGroup'

// PARAMS General
param suffix string = 'DataBricksExplore'
param resourceTags object

// PARAMS Vnet
param vnetAddressSpace string = '192.168.0.0/24'
param snetDBricksPublic object = {
  name: 'snet-DBricksPublic'
  subnetPrefix: '192.168.0.0/26'
}  
param snetDBricksPrivate object = {
   name: 'snet-DBricksPrivate'
  subnetPrefix: '192.168.0.64/26'
}
param snetPE object = {
  name: 'snet-PE'
  subnetPrefix: '192.168.0.128/26'
}
param snetAdmin object = {
  name: 'snet-Admin'
  subnetPrefix: '192.168.0.192/27'
}
param snetBastion object = {
  name: 'AzureBastionSubnet'  //fixed name of subnet de-jure
  subnetPrefix: '192.168.0.224/27'
}
param nsgID string

//params Databircks
param dBricksSKU string = 'premium'


//VARS
// vars  Resource Names
var env = resourceTags.Environment
var vnetName = 'vnet-${env}-${suffix}'
var dataFactoryName = 'adf-${env}-${suffix}'
var dBricksWSName = 'dbw-${env}-${suffix}'
var managedResourceGroupName = 'rg-databricks-${dBricksWSName}-${uniqueString(dBricksWSName, resourceGroup().id)}'
var managedResourceGroupId = '${subscription().id}/resourceGroups/${managedResourceGroupName}'
var dataLakeName ='st${env}${uniqueString(resourceGroup().id)}${suffix}'

//Create Resources

//create the Virtual Network to host all resources and its subnets
module vnet 'modules/VNet.module.bicep' = {
  name: 'vnetDeployment-${vnetName}'
  params: {
    name: vnetName
    region: resourceGroup().location    
    snetDBricksPublic: snetDBricksPublic
    snetDBricksPrivate: snetDBricksPrivate
    snetPE: snetPE
    snetAdmin: snetAdmin
    snetBastion: snetBastion    
    vnetAddressSpace: vnetAddressSpace
    tags: resourceTags
    nsgID: nsgID
  }
}
module dBricksWS 'modules/DataBricks.module.bicep' = {
  name: 'DataBricksWorkspaceDeplyment'
  params: {
    name: dBricksWSName
    region: resourceGroup().location
    tags: resourceTags
    dBricksSKU: dBricksSKU
    managedResourceGroupId: managedResourceGroupId
    privateSubnetName: snetDBricksPrivate.name
    publicSubnetName: snetDBricksPublic.name
    vnetID: vnet.outputs.vnetID
  }
}

module dataLake 'modules/DataLake.module.bicep' = {
  name: 'DataLakeDeployment'
  params: {
    name: dataLakeName
    region: resourceGroup().location
    tags: resourceTags
  }
}

module dataFactory 'modules/DataFactory.module.bicep' = {
  name: 'DataFactoryDeployment'
  params:{
    name: dataFactoryName
    region: resourceGroup().location
    tags: resourceTags
  }
}

output nsgID string = nsgID
