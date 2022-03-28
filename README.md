# Automatic snapshots for Openstack
This script uses the [Openstack CLI](https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html)  
This scripts is made and tested for and within the [CloudVPS Openstack environment](https://l.jhcs.nl/brpnFSPq) most functions will also work with other providers.

## Requirements 
 - [Openstack Command Line Client](https://l.jhcs.nl/AALyHOQu)
 - [Openstack RC File](https://l.jhcs.nl/daNZS33F)
 
## How to install the script
**Download the script:**
```
curl -o /usr/local/autoSnapshot.sh https://raw.githubusercontent.com/houtknots/Openstack-Automatic-Snapshot/main/script.sh
```

**Make the script executable:**
```
chmod +x /usr/local/autoSnapshot.sh
```

**Install the Openstack RC File:**

Place the [Openstack RC File](https://l.jhcs.nl/daNZS33F) under the directory `/usr/local/` with the name `rcfile.sh`.


If you would like the change the location of the RC file, edit line 13 within the script `rcFile='/usr/local/rcfile.sh'`. You can also run the script with the path to the RC file as argument like: `/usr/local/autoSnapshot.sh /path/to/rcfile.sh`

The CloudVPS default Openstack RC file asks you to enter your Openstack password. If you would like to run the scripts automated remove `read -sr OS_PASSWORD_INPUT` on line 30 and change `$OS_PASSWORD_INPUT` on line 31 to your password example: `"export OS_PASSWORD="P4$$w0rd"`.

**Add a cronjob to automate the script:**

Add a cronjob to run the script at a given time, start by opening crontab (More info at [crontab.guru](https://crontab.guru/)):
```
crontab -e
```

Add the following line at the bottom of the crontab to enable daily snapshots at 3 AM.
```
0 3 * * * /usr/local/autoSnapshot.sh
```

## How to include an instance via the commandline (Openstack API)
Use the command below to enable auto-snapshots for an instance.
```
openstack server set --property autoSnapshot=true <instance uuid>
# (Optional) Enable availability zone sync
openstack server set --property snapshotSync=true <instance uuid>
```

Use the command below to enable auto-snapshots for an volume.
```
openstack volume set --property autoSnapshot=true <volume uuid>
```

## How to include an instance via the Openstack Dashboard (Horizon)
1. Navigate to **Project** > **Compute** > **Instances**.
2. Press on the small button with arrow on it to open the action menu.
3. Within the action menu press the **Update Metadata** option.
4. Add the metadata property **autoSnapshot** with true as value.  
5. (Optional) Add the metadata property **snapshotSync** with true as value if you want to enable availability zone syncing.
6. Enter the text **true** in the metadata property.
7. Press the **Save** button.

## How to include an volume via the Openstack Dashboard (Horizon)
1. Navigate to **Project** > **Volumes** > **Volumes**.
2. Press on the small button with arrow on it to open the action menu.
3. Within the action menu press the **Update Metadata** option.
4. Add the metadata property **autoSnapshot** with the custom option.
5. Enter the text **true** in the metadata property.
6. Press the **Save** button.

## Test the script
Run the script by using the command below:
```
/usr/local/autoSnapshot.sh
```
