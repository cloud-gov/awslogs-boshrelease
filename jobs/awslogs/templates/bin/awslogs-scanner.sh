#!/bin/bash

INOTIFY_WAIT="/var/vcap/packages/inotify-tools/bin/inotifywait"

mkdir -p /var/vcap/jobs/awslogs/conf.d

export CONFIG_FILE=/var/vcap/jobs/awslogs/conf.d/all-vcap-logs.conf

if [ ! -f ${CONFIG_FILE} ]; then
  touch ${CONFIG_FILE}
fi

scan_for_logs() {
  TMPCONF=$(mktemp)

  for I in `find /var/vcap/sys/log -type f`
  do
    # deliberately excluding obviously non-ingestable files (only ASCII, text or empty files,
    # no timestamp-rotated files) to reduce log readers and thus forestall lost log lines
    echo $I | egrep -q 'log.[0-9][0-9][0-9]+$' && continue
    file $I | egrep -q 'ASCII|text|empty' || continue
    GROUP_NAME=`dirname $I | xargs basename`
    echo ""
    echo "[$I]"
    echo "file = $I"
    echo "buffer_duration = 5000"
    echo "log_stream_name = $I-{instance_id}"
    echo "initial_position = start_of_file"
    echo "log_group_name = $GROUP_NAME"
  done > ${TMPCONF}

  if cmp -s ${TMPCONF} ${CONFIG_FILE}; then
    # files are the same we don't need to do anything but clean up our tempfile
    rm ${TMPCONF}
  else
    # files differ, install and restart
    echo -e "[$(date)] Updating awslogs config:\n$(diff ${CONFIG_FILE} ${TMPCONF})"

    cp ${CONFIG_FILE} ${CONFIG_FILE}-previous
    mv ${TMPCONF} ${CONFIG_FILE}

    /var/vcap/bosh/bin/monit restart awslogs
  fi
}

# initial scan when we start
scan_for_logs

# then any time a new file is created in /var/vcap/sys/logs (excluding our own dir) then rescan for new logs
while ${INOTIFY_WAIT} -r -e create /var/vcap/sys/log @/var/vcap/sys/log/awslogs; do
  echo "inotify triggered, scanning for new logs"
  scan_for_logs
done
