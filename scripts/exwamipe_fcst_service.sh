#!/bin/bash
set -ax

COMIN=${COMIN:-$ROTDIR/$CDUMP.$PDY/$cyc}
SIGI=${SIGI:-$COMIN/$CDUMP.t${cyc}z.$ATM$SUFOUT}
CDATE=$(eval $SIGHDR $SIGI idate)
FDATE=$($NDATE `eval $SIGHDR $SIGI fhour | cut -d'.' -f 1` $CDATE)
SWIO_IDATE=${FDATE}15
SWIO_EDATE=$($NDATE $FHMAX $FDATE)00

if [ $RUN_ENVIR = 'nco' ] ; then
    TJOB=$(echo $job | sed 's/fservice/forecast/')
else
    TJOB=$(echo $job | sed 's/fsvc/fcst/')
fi


while [ ! -d ../$TJOB ] ; do
    sleep 60
done


cd ../$TJOB

while [ ! -f input_parameters.nc ] ; do
    sleep 60
done

$HOMEwamipe/ush/realtime_wrapper.py -e $SWIO_EDATE -p $DCOM -d $data_poll_interval_min -c ${SWIO_IDATE:0:-2}15

exit $?
