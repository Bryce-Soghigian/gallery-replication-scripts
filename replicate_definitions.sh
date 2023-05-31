#!/bin/bash

# TODO: Move to an init variables script
sourceSubscription=""
sourceResourceGroup=""
sourceGalleryName=""
targetResourceGroup="zzz"
targetGalleryName="preview.aks.gallery"
osType="Linux"  # adjust according to your images
publisher="microsoft"
offer="aks.test"

imagesToSkip=("import" "CVM" "TL", "1604", "tl")

imageDefinitions=$(az sig image-definition list --resource-group $sourceResourceGroup --gallery-name $sourceGalleryName --query "[].name" -o tsv)
for imageDefinition in $imageDefinitions
do
    shouldSkip=0
    for skip in "${imagesToSkip[@]}"; do
        if [[ $imageDefinition == *"$skip"* ]]; then
            echo "Skipping image definition: $imageDefinition"
            shouldSkip=1
            break
        fi
    done
    if (( shouldSkip == 1 )); then
        continue
    fi   
    az sig image-definition show --resource-group $targetResourceGroup --gallery-name $targetGalleryName --gallery-image-definition $imageDefinition &>/dev/null
    if [ $? -ne 0 ]; then
        sku=$imageDefinition

        if [[ -z "$sku" ]]; then
            echo "Skipping image definition $imageDefinition due to empty sku"
            continue
        fi

        hyperVGeneration="V1"  # default to Generation 1
        architecture="x64"  # default to x64 architecture
        if [[ $imageDefinition == *"gen2"* ]] || [[ $imageDefinition == *"Gen2"* ]] || [[ $imageDefinition == *"GEN2"* ]]; then
            hyperVGeneration="V2"
        fi

        # if arm or Arm or ARM is in the image definition name, set architecture to Arm64  
        if [[ $imageDefinition == *"Arm"* ]] || [[ $imageDefinition == *"arm"* ]] || [[ $imageDefinition == *"ARM"* ]]; then
            architecture="Arm64"
        fi 

        az sig image-definition create --resource-group $targetResourceGroup --gallery-name $targetGalleryName --gallery-image-definition $imageDefinition --os-type $osType --publisher $publisher --offer $offer --sku $sku --hyper-v-generation $hyperVGeneration --architecture $architecture
    fi
done 

