# zabbix3-slack
Slack Notification from Zabbix 3.x

![Imgur](http://i.imgur.com/jxrdq35.png)

## Env
- Zabbix 3.0
- CentOS Linux release 7.2.1511 (Core)

## Install Steps

```
[Zabbix-Server]$ cd /usr/lib/zabbix/alertscripts    # AlertScriptsPath
[Zabbix-Server]$ git clone https://github.com/kenzo0107/zabbix3-slack
[Zabbix-Server]$ mv zabbix3-slack/slack.sh .
[Zabbix-Server]$ rm -r zabbix3-slack
[Zabbix-Server]$ chmod 755 slack.sh
[Zabbix-Server]$ vim slack.sh  # change incoming_webhook yourself.
```

### Media Types Setting
![Imgur](http://i.imgur.com/mO04RzX.png)

### Users > Media
![Imgur](http://i.imgur.com/qiVzYUp.png)