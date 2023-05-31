#!/bin/bash

# This script replicates all image versions from one gallery to another
# It assumes that the source gallery is in the same subscription as the target gallery as well as the same region (e.g. East US)
sourceSubscription=""
sourceResourceGroup=""
sourceGalleryName=""
targetResourceGroup="zzz"
targetGalleryName="preview.aks.gallery"
osType="Linux"  # adjust according to your images
publisher="microsoft"
offer="YourOffer"


imagesToSkip=("import"  "CVM" "TL", "1604")
imageDefinitions=$(az sig image-definition list --resource-group $sourceResourceGroup --gallery-name $sourceGalleryName --query "[].name" -o tsv)


for imageDefinition in $imageDefinitions
do
    skip=0
    for i in "${imagesToSkip[@]}"; do
        if [[ $imageDefinition == *"$i"* ]]; then
            echo "Skipping image definition: $imageDefinition"
            skip=1
            break  # this will exit the inner loop
        fi
    done
    if (( skip == 1 )); then
        continue  # this will skip to the next iteration of the outer loop
    fi
    imageVersions=$(az sig image-version list --resource-group $sourceResourceGroup --gallery-name $sourceGalleryName --gallery-image-definition $imageDefinition --query "[].name" -o tsv)
    for imageVersion in $imageVersions
    do
        diskId="/subscriptions/$sourceSubscription/resourceGroups/$sourceResourceGroup/providers/Microsoft.Compute/galleries/$sourceGalleryName/images/${imageDefinition}/versions/${imageVersion}"

        az sig image-version show --resource-group $targetResourceGroup --gallery-name $targetGalleryName --gallery-image-definition $imageDefinition --gallery-image-version $imageVersion &>/dev/null

        if [ $? -ne 0 ]; then
            az sig image-version create --resource-group $targetResourceGroup --gallery-name $targetGalleryName --gallery-image-definition $imageDefinition --gallery-image-version $imageVersion --managed-image $diskId &
        fi
    done
    wait
done

