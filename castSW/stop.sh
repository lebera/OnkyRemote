#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )" && pwd )"

APP_EXE='darkice'
ps -axo pid,command,args | grep $APP_EXE | grep -v grep | awk '{ print $1 }' | xargs kill -s SIGINT

APP_EXE='icecast'
ps -axo pid,command,args | grep $APP_EXE | grep -v grep | awk '{ print $1 }' | xargs kill -s SIGINT

rm -rf /tmp/icecast.log

APP_EXE='ConfigDefaultOutput'
$DIR/$APP_EXE -d "Built-in Output"
$DIR/$APP_EXE -m 0

