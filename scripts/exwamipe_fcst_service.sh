#!/bin/bash
set -ax

# path/variable setup
SIGI=${SIGI:-$COMIN/$CDUMP.t${cyc}z.$ATM$SUFOUT}

CDATE=$(eval $SIGHDR $SIGI idate)
FDATE=$($NDATE `eval $SIGHDR $SIGI fhour | cut -d'.' -f 1` $CDATE)

SWIO_IDATE=${FDATE}15
SWIO_EDATE=$($NDATE $FHMAX $FDATE)00

# link lock files
sdate=$SWIO_IDATE
edate=$SWIO_EDATE
while [ $sdate -le $edate ] ; do
    $NLN $COMOUT/${CDUMP}.t${cyc}z.${sdate:0:8}_${sdate:8}00.lock ${sdate:0:8}_${sdate:8}00.lock
    sdate=$($MDATE 15 $sdate)
done

# link actual target files in
${NLN} $COMOUT/$CDUMP.t${cyc}z.input_parameters input_parameters.nc

# wait if necessary
while [ ! -f input_parameters.nc ] ; do
    sleep 60
done

# and then pull and write drivers as they come in
$HOMEwfs/ush/realtime_wrapper.py -e $SWIO_EDATE -p $DCOM -d $data_poll_interval_min -c $($MDATE -$((36*60)) ${FDATE}00)

exit $?
