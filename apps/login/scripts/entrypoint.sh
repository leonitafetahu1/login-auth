#!/bin/sh
set -o allexport
. /.env-file/.env
set +o allexport

if [ -n "${ZITADEL_SERVICE_USER_TOKEN_FILE}" ] && [ -f "${ZITADEL_SERVICE_USER_TOKEN_FILE}" ]; then
  echo "ZITADEL_SERVICE_USER_TOKEN_FILE=${ZITADEL_SERVICE_USER_TOKEN_FILE} is set and file exists, setting ZITADEL_SERVICE_USER_TOKEN to the files content"
  export ZITADEL_SERVICE_USER_TOKEN=$(cat "${ZITADEL_SERVICE_USER_TOKEN_FILE}")
fi

if [ -f "/runtime/apps/login/server.js" ]; then
  exec node /runtime/apps/login/server.js
elif [ -f "/runtime/server.js" ]; then
  exec node /runtime/server.js
else
  echo "Could not find server.js in /runtime or /runtime/apps/login"
  ls -R /runtime
  exit 1
fi
