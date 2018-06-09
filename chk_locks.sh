#!/bin/bash
################################################################################
# CheckLocks : display locks of a Progress Base
# Serge Golovanow
# Usage : ./chk_locks [base] (user)
# If user is specified, display user's locks and locks with commons RecID
################################################################################

#Verif s'il y a au moins un argument, sinon sortie
if  [ $# -eq 0 ]
then
  echo 1>&2 "Usage : $0 [base] (user)"
  exit 1;
fi

IFS=$'\n'

if [ $# -eq 1 ]
then   #Un seul argument, on affiche tous les locks de la base
  for LIGNE in `mpro -db $1 -b -p locks.p | tee | tail +33` # | grep -vE '^----'`
  do
    echo -e "$1\t$LIGNE"
  done
  
else #Un autre argument, on affiche tous les locks de l'user, plus ceux partageant ses recid

  #R�cup�ration des RECID
  for LIGNE in `mpro -db $1 -b -p locks.p | tee | tail +33 | grep -E "^ +$2"`
  do
    #IFS=$BACKIFS
    RECID="$RECID|`echo $LIGNE | awk '{print $3}' | sed 's/\ //g'`"
  done
  
  RECID=`echo $RECID | sed 's/ //g' | sed 's/\|$//g'` 
  #echo $RECID
  
   #echo " Usr Name         iREcid Table File-Name    Flags"
#  echo "---- ---------- -------- ----- ------------ -----"

  for LIGNE in `mpro -db $1 -b -p locks.p | tee | tail +31 | grep -E "(^ *$2 $RECID)"`
  do
    echo -e "$1\t$LIGNE"
  done
  
fi