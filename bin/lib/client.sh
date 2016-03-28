check_client() {
    if [ -n "$1" ]
    then
        CLIENT="$1"
    elif [ -z "$CLIENT" ]
    then
        read CLIENT < ~/.client
    fi

    if [ -z "$CLIENT" ]
    then
        echo No client specified and CLIENT not set!
        unset
        unset LOWER_CLIENT
        exit -1
    fi

    LOWER_CLIENT=${CLIENT,,}
}

read_client_data() {
    check_client $1
    eval $(~/bin/lib/parse_client_data ~/.client_data.yml $CLIENT CLIENT_DATA | tr '\n' ';')
}
