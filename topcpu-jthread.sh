#
# Find jvm thread who's CPU utilization >1
#

jpid=`ps -ef | grep java | grep -Ev grep | grep openjdk | awk '{print $2}'`

ps mp ${jpid} -o THREAD,tid | awk '$2 >1 {print $2,$8}'
