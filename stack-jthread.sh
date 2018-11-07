#
# stack for a jvm pid and thread pid
# ./stack-jthread.sh $pid1 $tid1
#

pid=$1
tid=$2

xtid=`echo "obase=16;${tid}"|bc`

allstack=`jstack $pid | grep -A 20 $xtid`

echo -e "$allstack"

