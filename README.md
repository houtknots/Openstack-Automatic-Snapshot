# Automatic snapshots for Openstack
This script uses the Openstack API
This scripts is made and tested within the [CloudVPS Openstack environment](https://cloudvps.com/openstack).

## Requirements 
 - [Openstack Command Line Cliënt](https://www.cloudvps.com/knowledgebase/entry/2856-openstack-cli-tools-installation/)
 - [Openstack RC File](https://www.cloudvps.com/knowledgebase/entry/2856-openstack-cli-tools-installation/#Openstack%20RC%20FILE )
 
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

Place the [Openstack RC File](https://www.cloudvps.com/knowledgebase/entry/2856-openstack-cli-tools-installation/#Openstack%20RC%20FILE) under the directory `/usr/local/` with the name `rcfile.sh`.


If you would like the change the location of the RC file, edit line 13 within the script `rcFile='/usr/local/rcfile.sh'`.


The default Openstack RC file asks you to enter your Openstack password. If you would like to run the scripts automated remove `read -sr OS_PASSWORD_INPUT` on line 30 and change `$OS_PASSWORD_INPUT` on line 31 to your password example: `"export OS_PASSWORD="P4$$w0rd"`.

**Add a cronjob to automate the script:**

Add a cronjob to run the script at a given time, start by opening crontab (More info at [crontab.guru](https://crontab.guru/)):
```
crontab -e
```

Add the following line at the bottom of the crontab to enable daily snapshots at 3AM.
```
0 3 * * * bash /usr/local/autoSnapshot.sh
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

## Test the script
You can run the script by using the command below:
```
bash /usr/local/autoSnapshot.sh
```
