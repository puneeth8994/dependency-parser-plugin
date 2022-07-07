#!/bin/sh
set -e
# declare init message
INIT_MESSAGE="Dependency tester"
echo $INIT_MESSAGE
if [[ -z $SECRET_PREFIX ]] || [ ! $SECRET_PREFIX ]; then
    echo "Please provide secret prefix in args."
    exit 0
fi
if [[ -z $PACKAGE_TYPE ]] || [ $PACKAGE_TYPE == "" ]; then
    echo "Please provide package type in args."
    exit 0
fi
if [[ -z $NAMESPACE  ]] || [ $NAMESPACE == "" ]; then
    echo "Please provide namespace in args."
    exit 0
fi
if [[ -z $LABEL_SELECTOR ]] || [ $LABEL_SELECTOR == "" ]; then
    echo "Please provide label selector in args."
    exit 0
fi
# convert secret prefix argument to uppercase
SECRET_PREFIX=$(echo $SECRET_PREFIX | tr '[:lower:]' '[:upper:]')
# convert package type argument to lowercase
PACKAGE_TYPE=$(echo $PACKAGE_TYPE | tr '[:upper:]' '[:lower:]')
POD_NAME=$(kubectl get pod -n ${NAMESPACE} -l ${LABEL_SELECTOR} -o=name)
if [[ -z $POD_NAME ]] || [ $POD_NAME == "" ]; then
    echo "No running pod found for the label selector"
    exit 2
fi
if [ $PACKAGE_TYPE == "postgres" ]; then
    PASSWORD="${SECRET_PREFIX}_PASSWORD"
    NAME="${SECRET_PREFIX}_NAME"
    URL="${SECRET_PREFIX}_URL"
    PORT="${SECRET_PREFIX}_PORT"
    USERNAME="${SECRET_PREFIX}_USERNAME"
    SUBCOMMAND="PGPASSWORD=\"\$${PASSWORD}\" psql -d \"\$${NAME}\" -h \"\$${URL}\" -p \"\$${PORT}\" -U \"\$${USERNAME}\" -c ''"
    COMMAND="apk update && apk add postgresql-client && \
        eval \"$SUBCOMMAND\" && \
        echo \"postgres is up and running and reachable with provided config\" || \
        (
            echo \"cannnot connect to postgres with provided config\" && \
            echo \"postgres url key - ${URL} , username key - ${USERNAME} , password key - ${PASSWORD}, db name key - ${NAME}, port key - ${PORT}\"
        )
    "
    # Install postgres client
    kubectl exec --stdin --tty ${POD_NAME} -n ${NAMESPACE} -- sh -c "$COMMAND"
else
    echo "Package not supported"
    exit 3
fi