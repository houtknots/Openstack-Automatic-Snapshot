#!/bin/sh

##########################################################

# Project: Openstack Automatic Snapshots
# Author : houtknots
# Website: https://houtknots.com/
# Github : https://github.com/houtknots

##########################################################

# Specify where you Openstack RC File - instructions: https://www.cloudvps.com/knowledgebase/entry/2856#Openstack%20RC%20FILE
rcFile='/var/local/rcfile.sh'

# Specify the amount of days before the snapshot should be removed 
retentionDays=14

##########################################################
#  DO NOT EDIT BELOW THIS LINE                           #
##########################################################


# Set Variables
date=(`date +"%Y-%m-%d"`)
expireTime="$retentionDays days ago"
epochExpire=$(date --date "$expireTime" +'%s')

# If RC file exists load the rcfile, otherwise announce it does not exist and exit script with exit code 1
if [ -f "$rcFile" ]; then
    source $rcFile
else
    echo "Make sure you specify the Openstack RC-FILE - instructions: https://www.cloudvps.com/knowledgebase/entry/2856#Openstack%20RC%20FILE"
    exit 1
fi

# Announce snapshot creation
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Creating new snapshots!"

# If an instance has the autoSnapshot metadata tag is true create snapshots!
for instance in $(openstack server list -c ID -f value); do
        # Retrieve the required info from the instance.
        properties=(`openstack server show $instance -c properties -f value`)
        instanceName=(`openstack server show ${instance} -c name -f value`)

        # Check if the autoSnapshot is set to true, if this is the case create a snapshot of that instance, otherwise skip the instance.
        if [[ $properties =~ "autoSnapshot='true'" ]]; then
            echo "Creating snapshot of instance: ${instanceName} - ${instance}"
            snapshotID=(`openstack server image create ${instance} -c id -f value --wait --name "autoSnapshot_${date}_${instanceName}" | xargs`)
            openstack image set $snapshotID --tag autoSnapshot
        else
            echo "Skipping instance! Metadata key not set: ${instanceName} - ${instance}"
        fi
done

# Announce snapshot deletion
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Deleting old snapshots!"

# Get all snapshot/image uuid's which include autoSnapshot in their name
for image in `openstack image list --tag autoSnapshot -f value -c ID`; do

    # Get the epochtimestamp from when the snapshot wat created
    epochCreated=(`date --date "$(openstack image show ${image} -f value -c created_at)" "+%s"`)

    # If the snapshot is older then the above specified in variable expireTime delete the snapshot
    if [ $epochCreated -lt $epochExpire ]; then
        echo "Deleting old snapshot: ${image}"
        openstack image delete $image
    else
        echo "Skipping snapshot: ${image}"
    fi
done

# Announce the script has finished and exit the script with errorcode 0
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Finished!"
exit 0
