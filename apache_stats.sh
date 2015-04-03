#!/bin/bash
##
## Script was discovered in http://wiki.enchtex.info/howto/zabbix/
##
if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
      exit 1
fi
##### PARAMETERS #####
RESERVED="$1"
METRIC="$2"
URL="$3"
STATSURL="${URL}?auto"
#
CACHE_TTL="55"
CACHE_FILE="/tmp/zabbix.apache2.`echo ${URL} | md5sum | cut -d" " -f1`.cache"
EXEC_TIMEOUT="2"
NOW_TIME=`date '+%s'`
##### RUN #####
if [ -s "${CACHE_FILE}" ]; then
        CACHE_TIME=`stat -c"%Y" "${CACHE_FILE}"`
    else
        CACHE_TIME=0
fi
DELTA_TIME=$((${NOW_TIME} - ${CACHE_TIME}))
#
if [ ${DELTA_TIME} -lt ${EXEC_TIMEOUT} ]; then
        sleep $((${EXEC_TIMEOUT} - ${DELTA_TIME}))
    elif [ ${DELTA_TIME} -gt ${CACHE_TTL} ]; then
        echo "" >> "${CACHE_FILE}" # !!!
        DATACACHE=`curl -sS --insecure --max-time ${EXEC_TIMEOUT} "${STATSURL}" 2>&1`
        echo "${DATACACHE}" > "${CACHE_FILE}" # !!!
        echo "URL=${URL}"  >> "${CACHE_FILE}" # !!!
        chmod 640 "${CACHE_FILE}"
fi
#
if [ "${METRIC}" = "accesses" ]; then
    cat "${CACHE_FILE}" | grep -i "accesses" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "kbytes" ]; then
    cat "${CACHE_FILE}" | grep -i "kbytes" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "cpuload" ]; then
    cat "${CACHE_FILE}" | grep -i "cpuload" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "uptime" ]; then
    cat "${CACHE_FILE}" | grep -i "uptime" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "avgreq" ]; then
    cat "${CACHE_FILE}" | grep -i "ReqPerSec" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "avgreqbytes" ]; then
    cat "${CACHE_FILE}" | grep -i "BytesPerReq" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "avgbytes" ]; then
    cat "${CACHE_FILE}" | grep -i "BytesPerSec" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "busyworkers" ]; then
    cat "${CACHE_FILE}" | grep -i "BusyWorkers" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "idleworkers" ]; then
    cat "${CACHE_FILE}" | grep -i "idleworkers" | cut -d':' -f2 | head -n1
fi
if [ "${METRIC}" = "totalslots" ]; then
    cat "${CACHE_FILE}" | grep -i "Scoreboard" | cut -d':' -f2 | sed -e 's/ //g' | wc -c | awk '{print $1-1}'
fi
#
exit 0
