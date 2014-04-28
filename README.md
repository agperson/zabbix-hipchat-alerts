zabbix-hipchat-alerts
=====================

Send Zabbix alerts to a HipChat room using the v2 API.

![Zabbix notifications in HipChat](https://raw.githubusercontent.com/agperson/zabbix-hipchat-alerts/master/screenshot.png)

**Note:** The `notify.rb` script can be used on its own without Zabbix as a simple command-line notification script for the HipChat v2 API. The `hipchat.rb` script is the one that is Zabbix-specific.

1. Clone repository to your Zabbix alertscripts location (check `zabbix_server.conf` for the proper location, on RHEL/CentOS it is `/usr/lib/zabbix/alertscripts`), and make sure the Gemfile dependency is installed.
2. In Zabbix navigate to Administration > Media Types and create a new media type called "HipChat".  For type select "Script" and for script name type in "hipchat.rb".
3. Create a new user account or use an existing account with adequate (read-only) permissions. In the "Media" tab, create a new media of type "HipChat". The "Send To" field is not used but cannot be blank, so just put some text into it.
4. Navigate to Configuration > Actions and create a new Trigger action. Setup the appropriate conditions and choose any Name and Subject you'd like.  For both the Default Message and the Recovery Message enter the following:

```yaml
name: {TRIGGER.NAME}
id: {TRIGGER.ID}
status: {TRIGGER.STATUS}
hostname: {HOSTNAME}
ip: {IPADDRESS}
value: {TRIGGER.VALUE}
event_id: {EVENT.ID}
severity: {TRIGGER.SEVERITY}
```

(This format is the same as what PagerDuty uses, except that in this case there are spaces between the keys and values, to make it valid YAML.)
5. Finally, in the "Operations" tab, setup an operation that sends a message to the user you have setup with the HipChat media, and choose "HipChat" from the "Send only to" dropdown.

Be sure to configure an appropriate config.yaml file (an example is provided) with your generated token and other information, then you will get nice color-coded messages in your chat room when Zabbix actions are fired.
