#!/bin/bash
FILE_NAME=$1
MAIL_TO=$2
LOCKFILE=/tmp/reporter.pid

send_mail()
{
(
cat - <<EOF

Subject: Log report ${DATE_START} - ${DATE_END}
From: reporter
To: $MAIL_TO

Hi!
Period:
${DATE_START} - ${DATE_END}
Top IPs:
${TOP_IP}
Top Addresses:
${TOP_ADDR}
Top response code: 
${TOP_CODE}

EOF
) | sendmail $MAIL_TO
}

if ( set -o noclobber; echo "$$" > "$LOCKFILE" ) 2> /dev/null;
then
  trap 'rm -f "$LOCKFILE"; exit $?' INT TERM EXIT KILL
  DATE_START=$(date --date="1 hour ago" +"%d/%b/%Y:%H:%M:%S")
  DATE_END=$(date +"%d/%b/%Y:%H:%M:%S")

  DATE_1_HOUR_AGO=date --date="1 hour ago" +"%d/%b/%Y:%H" 
  
  TOP_IP=$(grep "${DATE_1_HOUR_AGO}" ${FILE_NAME} | awk '{print $1}' | sort | uniq -c | sort -nr | head)
  TOP_ADDR=$(grep "${DATE_1_HOUR_AGO}" ${FILE_NAME} | awk '{print $7}' | sort | uniq -c | sort -nr | head)
  TOP_CODE=$(grep "${DATE_1_HOUR_AGO}" ${FILE_NAME} | awk '{print $9}' | sort | uniq -c | sort -nr | head)

  send_mail

  rm -f "$LOCKFILE"
  trap - INT TERM EXIT
else
  echo "Failed to acquire lockfile: $LOCKFILE}"
  echo "Held by $(cat $LOCKFILE)"
fi
