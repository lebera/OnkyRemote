#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )" && pwd )"

APP_EXE='icecast'
pid=`ps -axo pid,command,args | grep $APP_EXE | grep -v grep | awk '{ print $1 }'`
if [[ -z $pid ]]; then
  mkdir /tmp/icecast.log/
  XML="s|<webroot>.*<\/webroot>|<webroot>"$DIR"/icecastdir/web<\/webroot>|g"
  sed -i -r $XML $DIR/$APP_EXE.xml
  XML="s|<adminroot>.*<\/adminroot>|<adminroot>"$DIR"/icecastdir/admin<\/adminroot>|g"
  sed -i -r $XML $DIR/$APP_EXE.xml
  $DIR/$APP_EXE -c $DIR/$APP_EXE.xml &
fi

APP_EXE='darkice'
pid=`ps -axo pid,command,args | grep $APP_EXE | grep -v grep | awk '{ print $1 }'`
if [[ -z $pid ]]; then
  $DIR/$APP_EXE -c $DIR/$APP_EXE.cfg &
fi

APP_EXE='ConfigDefaultOutput'
$DIR/$APP_EXE -d "AirBeamTV Audio"
$DIR/$APP_EXE -m 0
$DIR/$APP_EXE -v 1.0

sleep 1
