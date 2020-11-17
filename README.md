# Automatic snapshots for Openstack
This scripts is made and tested within the [CloudVPS Openstack environment](https://cloudvps.com/openstack).

## How to install the script
Download the script using the command below:
```
curl -o /var/local/autoSnapshot.sh https://raw.githubusercontent.com/houtknots/Openstack-Automatic-Snapshot/main/script.sh
```

Make the script executable:
```
chmod +x /var/local/autoSnapshot.sh
```

Add a cronjob:
Add a cronjob to run the script at a given interval begin bij opening crontab (More info at [crontab.guru](https://crontab.guru/)):
```
crontab -e
```

Add the following line at the bottom of the crontab to enable daily snapshots at 3AM.
```
0 3 * * * bash /var/local/autoSnapshot.sh
```

## How to include an instance via the CLI (Openstack API)
Use the command below to enable the auto snapshot for the instance.
```
openstack server set --property autoSnapshot=true <instance uuid>
```

## How to include an instance via the Openstack Dashboard (Horizon)
1. Navigate to **Project** > **Compute** > **Instances**.
2. Press on the small button with arrow on it to open the action menu.
3. Within the action menu press the **Update Metadata** option.
4. Add the metadata property **autoSnapshot** with the custom option.
5. Enter the text **true** in the metadata property.
6. Press the **Save** button.
