#!/bin/bash

##########################################################

# Project: Openstack Automatic Snapshots
# Author : houtknots
# Website: https://houtknots.com/
# Github : https://github.com/houtknots

##########################################################

# Specify where you Openstack RC File - instructions: https://www.cloudvps.com/knowledgebase/entry/2856#Openstack%20RC%20FILE
# use first passed variable as openstack rc file or use default
rcFile="${1:-/usr/local/rcfile.sh}"

# Specify the amount of days before the snapshot should be removed 
retentionDays=14

###############################    
# DO NOT EDIT BELOW THIS LINE #
###############################

# Set Variables
date=$(date +"%Y-%m-%d")
expireTime="$retentionDays days ago"
epochExpire=$(date --date "$expireTime" +'%s')

# If RC file exists load the rcfile, otherwise announce it does not exist and exit script with exit code 1
if [ -f "$rcFile" ]; then
    source $rcFile
else
    echo "Make sure you specify the Openstack RC-FILE - instructions: https://www.cloudvps.com/knowledgebase/entry/2856#Openstack%20RC%20FILE"
    exit 1
fi

##########################
#   Snapshot Creation    #
##########################

# Announce snapshot creation
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Creating instance snapshots!"

# If an instance has the autoSnapshot metadata tag is true create snapshots!
for instance in $(openstack server list -c ID -f value); do
        # Retrieve the required info from the instance.
        properties=$(openstack server show $instance -c properties -f value)
        instanceName=$(openstack server show ${instance} -c name -f value)

        # Check if the autoSnapshot is set to true, if this is the case create a snapshot of that instance, otherwise skip the instance.
        if [[ $properties =~ "autoSnapshot='true'" ]]; then
            echo "Creating snapshot of instance: ${instanceName} - ${instance}"
            snapshotID=$(openstack server image create ${instance} -c id -f value --wait --name "autoSnapshot_${date}_${instanceName}" | xargs)
            openstack image set $snapshotID --tag autoSnapshot
        else
            echo "Skipping instance! Metadata key not set: ${instanceName} - ${instance}"
        fi
done

# Announce snapshot creation
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Creating volume snapshots!"

# If an instance has the autoSnapshot metadata tag is true create snapshots!
for volume in $(openstack volume list -c ID -f value); do
        # Retrieve the required info from the instance.
        properties=$(openstack volume show $volume -c properties -f value | sed 's/ //g')
        volumeName=$(openstack volume show ${volume} -c name -f value)

        # Check if the autoSnapshot is set to true, if this is the case create a snapshot of that instance, otherwise skip the instance.
        if [[ $properties == *"'autoSnapshot':'true'"* ]]; then
            echo "Creating snapshot of volume: ${volumeName} - ${volume}"
            snapshotID=$(openstack volume snapshot create ${volume} -c id -f value --description "autoSnapshot_${date}_${volumeName}" | xargs)
            openstack volume snapshot set $snapshotID --property autoSnapshot=true --name "autoSnapshot_${date}_${volumeName}"
        else
            echo "Skipping volume! Metadata key not set: ${volumeName} - ${volume}"
        fi
done

##########################
#   Snapshot Deletion    #
##########################

# Announce snapshot deletion
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Deleting old instance snapshots!"

# Get all snapshot/image uuid's which include autoSnapshot in their name
for image in $(openstack image list --tag autoSnapshot -f value -c ID); do

    # Get the epochtimestamp from when the snapshot wat created
    epochCreated=$(date --date "$(openstack image show ${image} -f value -c created_at)" "+%s")

    # If the snapshot is older then the above specified in variable expireTime delete the snapshot
    if [ $epochCreated -lt $epochExpire ]; then
        echo "Deleting old snapshot: ${image}"
        openstack image delete $image
    else
        echo "Skipping snapshot: ${image}"
    fi
done

# Announce snapshot deletion
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Deleting old volume snapshots!"

# Get all snapshot/image uuid's which include autoSnapshot in their name
for vsnapshot in $(openstack volume snapshot list -c ID -f value); do

    # Check if the snapshot name starts with autoSnapshot
    vsnapshotName=$(openstack volume snapshot show ${vsnapshot} -c name -f value)
    if [[ $vsnapshotName == "autoSnapshot"* ]]; then

        # Get the epochtimestamp from when the snapshot wat created
        epochCreated=$(date --date "$(openstack volume snapshot show ${vsnapshot} -f value -c created_at)" "+%s")

        # If the snapshot is older then the above specified in variable expireTime delete the snapshot
        if [ $epochCreated -lt $epochExpire ]; then
            echo "Deleting old volume snapshot: ${vsnapshot}"
            openstack volume snapshot delete $vsnapshot
        else
            echo "Skipping volume snapshot: ${vsnapshot}"
        fi
    else
        echo "Skipping volume snapshot: ${vsnapshot}"
    fi
done

# Announce the script has finished and exit the script with errorcode 0
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Finished!"
exit 0
