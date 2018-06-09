#!/bin/bash

#Verif s'il y a au moins un argument, sinon sortie
if  [ $# -eq 0 ]
then
  echo 1>&2 "Usage : $0 [Shaker XML configuration file]"
  echo "Presently, these occurences of Shaker are running :"
  ps -ef | grep perl | grep shaker
  exit 1;
fi

if [ -f $1 ]
then
  FILECONF=$1
elif [ -f `dirname $0`/$1 ]
then
  FILECONF=`dirname $0`/$1
else
  echo 1>&2 "Configuration file $1 doesn't exist !" 
  echo "Presently, these occurences of Shaker are running :"
  ps -ef | grep perl | grep shaker
  exit 1
fi

PIDFILE=`grep pidfile $FILECONF | perl -e 'while ($l=<STDIN>) { $l=~/pidfile="(.+?)"/; print "$1\n";}';`
if [ -f $PIDFILE ]
then
  PID=`cat $PIDFILE`
  kill $PID
else
  echo "PID file $PIDFILE doesn't exist !"
fi