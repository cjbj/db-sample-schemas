#!/bin/bash
#
# Create the "HR" schema under a username of your choice, on a possibly-remote database
#
# Warning: Drops and recreates a database schema

if [ $# -eq 0 ]; then
    echo "Assuming default schema values"
    NEW_SCHEMA_NAME=$USER
    NEW_PASSWORD=$USER
    CONNECT_STRING="localhost/orcl"
    SYSTEM_PASSWD="oracle"
    SYS_PASSWORD="oracle"
    USER_TABLESPACE="users"
    TEMP_TABLESPACE="temp"
    LOG_DIR="/tmp/"
elif [ $# -eq 8 ]; then
    NEW_SCHEMA_NAME=$1
    NEW_PASSWORD=$2
    CONNECT_STRING=$3
    SYSTEM_PASSWD=$4
    SYS_PASSWORD=$5
    USER_TABLESPACE=$6
    TEMP_TABLESPACE=$7
    LOG_DIR=$8  # use an absolute path with a trailing slash
else
    echo "Usage: $0 new_user_name new_password connect_string system_password sys_password user_tablespace temp_tablespace log_dir" >&2
    exit
fi

perl -p -i -e 's#__SUB__CWD__#'$(pwd)'#g' human_resources/hr_main.sql
    
sqlplus -l system/$SYSTEM_PASSWD@$CONNECT_STRING <<EOF
set echo on
@human_resources/hr_main.sql $NEW_PASSWORD $USER_TABLESPACE $TEMP_TABLESPACE $SYS_PASSWORD $LOG_DIR $NEW_SCHEMA_NAME $CONNECT_STRING
-- drop annoying, artificial, time based update limitation (see hr_code.sql)
drop trigger secure_employees;
EOF

# Reset files so there is no git diff
perl -p -i -e 's#'$(pwd)'#__SUB__CWD__#g' human_resources/hr_main.sql

echo ""
echo "DB user $NEW_SCHEMA_NAME/$NEW_PASSWORD@$CONNECT_STRING has been created"

