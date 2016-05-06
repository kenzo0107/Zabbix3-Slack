#!/bin/bash

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
    case "$1" in
      'RECOVERY' ) emoji=':smile:' ;;
      'PLOBLEM'  ) emoji=':frowning:' ;;
    esac
    echo "${emoji}"
}

# color設定取得
function get_color() {
    status="$1"
    severity="$2"
    if [ "${status}" == 'OK' ]; then
        case "${severity}" in
          'Information') color="#439FE0" ;;
          *) color="good" ;;
        esac
    elif [ "${status}" == 'PROBLEM' ]; then
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
host=$(echo "${message}" | grep 'HOST:' | awk -F'HOST: ' '{print $2}')
datetime=$(echo "${message}" | grep 'DATETIME:' | awk -F'DATETIME: ' '{print $2}')
trigger_name=$(echo "${message}" | grep 'TRIGGER_NAME:' | awk -F'TRIGGER_NAME: ' '{print $2}')
trigger_status=$(echo "${message}" | grep 'TRIGGER_STATUS:' | awk -F'TRIGGER_STATUS: ' '{print $2}')
trigger_severity=$(echo "${message}" | grep 'TRIGGER_SEVERITY:' | awk -F'TRIGGER_SEVERITY: ' '{print $2}')
trigger_url=$(echo "${message}" | grep 'TRIGGER_URL:' | awk -F'TRIGGER_URL: ' '{print $2}')
item_name=$(echo "${message}" | grep 'ITEM_NAME:' | awk -F'ITEM_NAME: ' '{print $2}')
item_key=$(echo "${message}" | grep 'ITEM_KEY:' | awk -F'ITEM_KEY: ' '{print $2}')
item_value=$(echo "${message}" | grep 'ITEM_VALUE:' | awk -F'ITEM_VALUE: ' '{print $2}')
event_id=$(echo "${message}" | grep 'EVENT_ID:' | awk -F'EVENT_ID: ' '{print $2}')
item_id=$(echo "${message}" | grep 'ITEM_ID:' | awk -F'ITEM_ID: ' '{print $2}')

emoji=$(get_emoji "${subject}")
color=$(get_color "${trigger_status}" "${trigger_severity}")

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL
payload="payload={
  \"channel\": \"${channel}\",
  \"username\": \"${username}\",
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
