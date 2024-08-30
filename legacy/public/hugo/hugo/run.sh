#!/bin/sh

# Inspired by https://github.com/jojomi/docker-hugo

SLEEP="${HUGO_REFRESH_TIME:=60}"
echo "HUGO_REFRESH_TIME:" $SLEEP

while [ true ]
do
    echo "Building one time..."
        hugo --minify --source="/source" --destination="/output" || exit 1
    echo "Sleeping for $SLEEP seconds..."
    sleep $SLEEP
done
