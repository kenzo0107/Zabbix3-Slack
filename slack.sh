#!/bin/bash

# Zabbix > Configuration > Action
#
# Default subject : PROBLEM alert - {TRIGGER.NAME} is {TRIGGER.STATUS}
# Default message :
# HOST: {HOST.NAME}
# TRIGGER_NAME: {TRIGGER.NAME}
# TRIGGER_STATUS: {TRIGGER.STATUS}
# TRIGGER_SEVERITY: {TRIGGER.SEVERITY}
# DATETIME: {DATE} / {TIME}
# ITEM_ID: {ITEM.ID1}
# ITEM_NAME: {ITEM.NAME1}
# ITEM_KEY: {ITEM.KEY1}
# ITEM_VALUE: {ITEM.VALUE1}
# EVENT_ID: {EVENT.ID}
# TRIGGER_URL: {TRIGGER.URL}
#
# Recovery subject : RECOVERY alert - {TRIGGER.NAME} is {TRIGGER.STATUS}
# Recovery message :
# HOST: {HOST.NAME}
# TRIGGER_NAME: {TRIGGER.NAME}
# TRIGGER_STATUS: {TRIGGER.STATUS}
# TRIGGER_SEVERITY: {TRIGGER.SEVERITY}
# DATETIME: {DATE} / {TIME}
# ITEM_ID: {ITEM.ID1}
# ITEM_NAME: {ITEM.NAME1}
# ITEM_KEY: {ITEM.KEY1}
# ITEM_VALUE: {ITEM.VALUE1}
# EVENT_ID: {EVENT.ID}
# TRIGGER_URL: {TRIGGER.URL}

# define yourself.
incoming_webhook='https://hooks.slack.com/services/xxxxxx/xxxxxx/xxxxxxxxxxxxxxxxxxxxxxxxxxx'

# Slack user name.
username='Zabbix'

# Slack Channel - Media > "Send to".
channel="$1"

# {ALERT.SUBJECT}
subject="$2"

# {ALERT.MESSAGE}
message="$3"

# {ALERT.SUBJECT}により emoji 変更.
function get_emoji() {
    emoji=":ghost:"
    if [[ `echo "$1" | grep 'RECOVERY'` ]]; then
        emoji=':smile:'
    elif [[ `echo "$1" | grep 'PROBLEM'` ]]; then
        emoji=':frowning:'
    fi
    echo "${emoji}"
}

# color設定取得
function get_color() {
    status=$(echo "$1" | tr -d " ")
    severity=$(echo "$2" | tr -d " ")
    if [[ `echo "${status}" | grep 'OK'` ]]; then
        case "${severity}" in
          'Information') color="#439FE0" ;;
          *) color="good" ;;
        esac
    elif [[ `echo "${status}" | grep 'PROBLEM'` ]]; then
        case "${severity}" in
          'Information') color="#439FE0" ;;
          'Warning') color="warning" ;;
          *) color="danger" ;;
        esac
    else
        color="#808080"
    fi
    echo "${color}"
}

# zabbix parameters.
host=$(echo "${message}" | grep 'HOST:' | awk -F'HOST: ' '{print $2}' | sed -e "s/ $//")
datetime=$(echo "${message}" | grep 'DATETIME:' | awk -F'DATETIME: ' '{print $2}' | sed -e "s/ $//")
trigger_name=$(echo "${message}" | grep 'TRIGGER_NAME:' | awk -F'TRIGGER_NAME: ' '{print $2}' | sed -e "s/ $//")
trigger_status=$(echo "${message}" | grep 'TRIGGER_STATUS:' | awk -F'TRIGGER_STATUS: ' '{print $2}' | sed -e "s/ $//")
trigger_severity=$(echo "${message}" | grep 'TRIGGER_SEVERITY:' | awk -F'TRIGGER_SEVERITY: ' '{print $2}' | sed -e "s/ $//")
trigger_url=$(echo "${message}" | grep 'TRIGGER_URL:' | awk -F'TRIGGER_URL: ' '{print $2}' | sed -e "s/ $//")
item_name=$(echo "${message}" | grep 'ITEM_NAME:' | awk -F'ITEM_NAME: ' '{print $2}' | sed -e "s/ $//")
item_key=$(echo "${message}" | grep 'ITEM_KEY:' | awk -F'ITEM_KEY: ' '{print $2}' | sed -e "s/ $//")
item_value=$(echo "${message}" | grep 'ITEM_VALUE:' | awk -F'ITEM_VALUE: ' '{print $2}' | sed -e "s/ $//")
event_id=$(echo "${message}" | grep 'EVENT_ID:' | awk -F'EVENT_ID: ' '{print $2}' | sed -e "s/ $//")
item_id=$(echo "${message}" | grep 'ITEM_ID:' | awk -F'ITEM_ID: ' '{print $2}' | sed -e "s/ $//")

emoji=$(get_emoji "${subject}")
color=$(get_color "${trigger_status}" "${trigger_severity}")

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL
payload="payload={
  \"channel\": \"${channel}\",
  \"username\": \"${username}\",
  \"icon_emoji\": \"${emoji}\",
  \"text\": \"*${subject}*\",
  \"attachments\": [
    {
      \"fallback\": \"Date / Time: ${datetime} - ${subject}\",
      \"color\": \"${color}\",
      \"fields\": [
        {
            \"title\": \"Date / Time\",
            \"value\": \"${datetime}\",
            \"short\": true
        },
        {
            \"title\": \"Status\",
            \"value\": \"${trigger_status}\",
            \"short\": true
        },
        {
            \"title\": \"Host\",
            \"value\": \"${host}\",
            \"short\": true
        },
        {
            \"title\": \"Item\",
            \"value\": \"${item_name}: ${item_value}\",
            \"short\": true
        }
      ]
    }
  ]
}"
curl -m 5 --data-urlencode "${payload}" $incoming_webhook -A 'zabbix-slack-alertscript / https://github.com/ericoc/zabbix-slack-alertscript'
