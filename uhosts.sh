#!/bin/sh

HOST_FILE_PATH="/etc/hosts"

IP_REGEX="^[#0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"

# exit shell with err_code
# $1 : err_code
# $2 : err_msg
exit_on_err()
{
    [[ ! -z "${2}" ]] && echo "${2}" 1>&2
    exit ${1}
}

# string is blank line
# $1 source string
is_ip()
{
    counter=`echo $1 | grep -E "$IP_REGEX" | wc -l`
    return $counter
}


# the usage
usage()
{
    echo "
Usage:
    $0 [option] [args]
    [[-h][--help][-help]]     : print this usage tips
    [-s]                      : search host setting by ip or hostname
    [-a]                      : add ip hostname map into /etc/hosts
    [-d]                      : delete host setting by ip or hostname
    [-l]                      : list all host settings

Example:
    ./uhosts.sh [[-h][--help][-help]]
    ./uhosts.sh -s <ip>
    ./uhosts.sh -s <hostname>
    ./uhosts.sh -a <ip> <hostname>
    ./uhosts.sh -d <ip>
    ./uhosts.sh -d <hostname>
    ./uhosts.sh -l

"
}

# search by ip or hostname
# $1 <ip> or <hostname>
search_handler()
{
    grep -Ev '^$|^#' $HOST_FILE_PATH | grep "$1"
    return 0
}

# replace hostname，and delete signle ip row and blank line
# $1 <hostname>
replace_hostname()
{
    # hostname is exists
    exists=`grep -Ev '^$|^#' $HOST_FILE_PATH | grep "$1"`
    if [ -n "$exists" ] ; then

	if [ "$(uname)" == "Darwin" ] ; then
	    # delete hostname
	    sed -i '' "s/$1//g" $HOST_FILE_PATH
	    # delete signle ip row
	    sed -i '' 's/^[#0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\ $//g' $HOST_FILE_PATH
	    sed -i '' '/^$/d' $HOST_FILE_PATH
	else
	    # delete hostname
	    sed -i "s/$1//g" $HOST_FILE_PATH
	    # delete signle ip row
	    sed -i 's/^[#0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\ $//g' $HOST_FILE_PATH
	    sed -i '/^$/d' $HOST_FILE_PATH
	fi

    fi
}

delete_row_byid()
{
    if [ "$(uname)" == "Darwin" ] ; then
	sed -i '' "s/^${1}.*$//g" $HOST_FILE_PATH
	sed -i '' '/^$/d' $HOST_FILE_PATH
    else
	sed -i "s/^${1}.*$//g" $HOST_FILE_PATH
	sed -i '/^$/d' $HOST_FILE_PATH
    fi
    
}

# add ip hostname into /etc/hosts
# $1 <ip>
# $2 <hostname>
add_handler()
{
    replace_hostname "$2"
    # add
    echo "$1 $2" >> $HOST_FILE_PATH
    return 0
}

# delete by ip or hostname
# $1 <ip> or <hostname>
delete_handler()
{
    # is ip ? delete row : replace and then delete all blank line
    is_ip "$1"
    if [ $? -eq 0 ] ; then
	replace_hostname "$1"
    else
	# delete by ip
	delete_row_byid "$1"
    fi
    
    return 0
}

# list all hostname map settings
list_handler()
{
    grep -Ev '^$|^#' $HOST_FILE_PATH
    return 0
}

# parse the arguments and dispatch the option handler
handle_option()
{
    if ([ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-help" ]) ; then
	usage
	exit 0
    fi

    if ([ "$1" = "-s" ]) ; then
	# search
	search_handler "$2"
	exit 0
    fi

    if ([ "$1" = "-a" ]) ; then
	# add
	add_handler "$2" "$3"
	exit 0
    fi

    if ([ "$1" = "-d" ]) ; then
	# delete
	delete_handler "$2"
	exit 0
    fi

    if ([ "$1" = "-l" ]) ; then
	# list
	list_handler
	exit 0
    fi
}

# main method entry
main()
{
    echo "Uhosts script version: 0.0.1"
    echo '\n\n'
    handle_option "${@}" \
	|| exit_on_err 1 "$(usage)"
}

main "${@}"
