#!/bin/bash
# GPTGENERATED
# Define your variables
location="eastus"
galleryName=""
resourceGroup=""
publisherUri=""
publisherEmail="bsoghigian@microsoft.com"
eulaLink="https://www.contoso.com/eula"
prefix="previewaks"

# Create a resource group
az group create --name $resourceGroup --location $location

# Create a shared image gallery
az sig create \
   --gallery-name $galleryName \
   --permissions community \
   --resource-group $resourceGroup \
   --publisher-uri $publisherUri \
   --publisher-email $publisherEmail \
   --eula $eulaLink \
   --public-name-prefix $prefix

