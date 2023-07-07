#!/bin/bash

INOTIFY_WAIT="/var/vcap/packages/inotify-tools/bin/inotifywait"

export CONFIG_FILE=/var/vcap/jobs/awlogs-jammy/config/cw-agent.json

export PATH=$PATH:/var/vcap/packages/jq-1.6/bin

scan_for_logs() {
  TMPCONF=$(mktemp)

  find /var/vcap/sys/log -type f | while read -r I
  do
    # deliberately excluding obviously non-ingestable files (only ASCII, text or empty files,
    # no timestamp-rotated files) to reduce log readers and thus forestall lost log lines
    echo "$I" | grep -Eq 'log.[0-9][0-9][0-9]+$' && continue
    file "$I" | grep -Eq 'ASCII|text|empty' || continue
    GROUP_NAME=$(dirname "$I" | xargs basename)

    cat $CONFIG_FILE \
      | jq --arg file_path "$I" --arg group_name "$GROUP_NAME" --arg retention_in_days "<%= p("awslogs-jammy.retention-in-days") %>" '.logs.logs_collected.files.collect_list += [{
        "file_path": $file_path,
        "log_group_name": $group_name,
        "log_stream_name": "{instance_id}",
        "retention_in_days": $retention_in_days,
      }]' \
      > "$TMPCONF"
  done

  if cmp -s "${TMPCONF}" "${CONFIG_FILE}"; then
    # files are the same we don't need to do anything but clean up our tempfile
    rm "${TMPCONF}"
  else
    # files differ, install and restart
    echo -e "[$(date)] Updating awslogs-jammy config:\n$(diff "${CONFIG_FILE}" "${TMPCONF}")"

    cp "${CONFIG_FILE}" "${CONFIG_FILE}-previous"
    mv "${TMPCONF}" "${CONFIG_FILE}"

    /var/vcap/bosh/bin/monit restart awslogs-jammy
  fi
}

# initial scan when we start
scan_for_logs

# then any time a new file is created in /var/vcap/sys/logs (excluding our own dir) then rescan for new logs
while ${INOTIFY_WAIT} -r -e create /var/vcap/sys/log @/var/vcap/sys/log/awslogs-jammy; do
  echo "inotify triggered, scanning for new logs"
  scan_for_logs
done
