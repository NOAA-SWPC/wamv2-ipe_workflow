#!/bin/ksh
set -x

###################################################
# Fanglin Yang, 20180318
# --create bunches of files to be archived to HPSS
###################################################


type=${1:-wfs}                ##wfs, wdas

CDATE=${CDATE:-2018010100}
PDY=$(echo $CDATE | cut -c 1-8)
cyc=$(echo $CDATE | cut -c 9-10)

#-----------------------------------------------------
if [ $type = "wfs" ]; then
#-----------------------------------------------------
  FHMIN_WFS=${FHMIN_WFS:-0}
  FHMAX_WFS=${FHMAX_WFS:-48}
  FHOUT_WFS=${FHOUT_WFS:-3}
  FHMAX_HF_WFS=${FHMAX_HF_WFS:-0}
  FHOUT_HF_WFS=${FHOUT_HF_WFS:-1}


  rm -f wfs.txt
  touch wfs.txt

  dirpath="wfs.${PDY}/${cyc}/"
  dirname="./${dirpath}"

  head="wfs.t${cyc}z."

  #..................
  echo  "./logs/${CDATE}/wfs*.log                          " >>wfs.txt

  fh=0
  while [ $fh -le $FHMAX_wfs ]; do
    fhr=$(printf %03i $fh)
    echo  "${dirname}${head}logf${fhr}                     " >>wfs.txt

    inc=$FHOUT_WFS
    if [ $FHMAX_HF_WFS -gt 0 -a $FHOUT_HF_WFS -gt 0 -a $fh -lt $FHMAX_HF_WFS ]; then
     inc=$FHOUT_HF_WFS
    fi

    fh=$((fh+inc))
  done


  #..................
  echo  "${dirname}${head}???anl              " >>wfs.txt
  echo  "${dirname}${head}IPE*                " >>wfs.txt
  echo  "${dirname}${head}sfca03              " >>wfs.txt
  echo  "${dirname}${head}atmf00              " >>wfs.txt
  echo  "${dirname}${head}sfcf00              " >>wfs.txt
  echo  "${dirname}${head}?????.*.nc          " >>wfs.txt
  echo  "${dirname}${head}input_parameters    " >>wfs.txt
#-----------------------------------------------------
fi   ##end of wfs
#-----------------------------------------------------

if [ $type = "wfr" ]; then

  FHMIN_WFR=${FHMIN_WFR:-0}
  FHMAX_WFR=${FHMAX_WFR:-9}
  FHOUT_WFR=${FHOUT_WFR:-3}
  FHMAX_HF_WFR=${FHMAX_HF_WFR:-0}
  FHOUT_HF_WFR=${FHOUT_HF_WFR:-1}


  rm -f wfr.txt
  touch wfr.txt

  dirpath="wfr.${PDY}/${cyc}/"
  dirname="./${dirpath}"

  head="wfr.t${cyc}z."

  #..................
  echo  "./logs/${CDATE}/wfr*.log                          " >>wfr.txt

  fh=0

  #..................
  echo  "${dirname}${head}?????.*.nc          " >>wfr.txt
  echo  "${dirname}${head}input_parameters    " >>wfr.txt
#-----------------------------------------------------
fi   ##end of wfr
#-----------------------------------------------------


#-----------------------------------------------------
if [ $type = "wdas" ]; then
#-----------------------------------------------------

  rm -f wdas.txt
  touch wdas.txt

  dirpath="wdas.${PDY}/${cyc}/"
  dirname="./${dirpath}"
  head="wdas.t${cyc}z."

  #..................
  echo  "${dirname}${head}atmanl              " >>wdas.txt
  echo  "${dirname}${head}sfca03              " >>wdas.txt
  echo  "${dirname}${head}IPE*                " >>wdas.txt
  for fstep in prep anal fcst ; do
   if [ -s $ROTDIR/logs/${CDATE}/wdas${fstep}.log ]; then
     echo  "./logs/${CDATE}/wdas${fstep}.log         " >>wdas.txt
   fi
  done

  fh=0
  while [ $fh -le 6 ]; do
    fhr=$(printf %02i $fh)
    echo  "${dirname}${head}atmf${fhr}          " >>wdas.txt
    echo  "${dirname}${head}sfcf${fhr}          " >>wdas.txt
    fh=$((fh+3))
  done
  echo  "${dirname}${head}input_parameters    " >>wdas.txt

#-----------------------------------------------------
fi   ##end of wdas
#-----------------------------------------------------


exit 0

