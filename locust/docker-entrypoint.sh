#!/bin/sh

set -e

LOCUST_MODE=${LOCUST_MODE:-standalone}
LOCUST_MASTER_BIND_PORT=${LOCUST_MASTER_BIND_PORT:-5557}
LOCUST_FILE=${LOCUST_FILE:-locustfile.py}

if [ "x" != "${LOCUST_S3_PATH}x" ] ; then
    aws s3 cp s3://${LOCUST_S3_PATH}/${LOCUST_FILE} . --region ${AWS_REGION}
    chmod +x ${LOCUST_FILE}
fi

if [ ${1} = "locust" ] ; then 
    echo "Starting locust......."
    if [ -z ${TEST_HOST_URL+x} ] ; then
        echo "You need to set the URL of the host to be tested (TEST_HOST_URL)."
        exit 1
    fi

    LOCUST_OPTS="-f ${LOCUST_FILE} --host=${TEST_HOST_URL} --no-reset-stats $LOCUST_OPTS"

    case `echo ${LOCUST_MODE} | tr 'a-z' 'A-Z'` in
    "MASTER")
        LOCUST_OPTS="--master --master-bind-port=${LOCUST_MASTER_BIND_PORT} $LOCUST_OPTS"
        ;;

    "SLAVE")
        LOCUST_OPTS="--slave --master-host=${LOCUST_MASTER} --master-port=${LOCUST_MASTER_BIND_PORT} $LOCUST_OPTS"
        if [ -z ${LOCUST_MASTER+x} ] ; then
            echo "You need to set LOCUST_MASTER."
            exit 1
        fi
        ;;
    esac
fi


exec "$@"