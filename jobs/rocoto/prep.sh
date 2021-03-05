#!/bin/ksh -x

###############################################################
# Source WFS workflow modules
. $HOMEwfs/ush/load_wamipe_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base prep prepbufr"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

###############################################################
# Source machine runtime environment
. $BASE_ENV/${machine}.env prep
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Set script and dependency variables
export OPREFIX="${CDUMP}.t${cyc}z."
export COMOUT="$ROTDIR/$CDUMP.$PDY/$cyc"
[[ ! -d $COMOUT ]] && mkdir -p $COMOUT

###############################################################
# If ROTDIR_DUMP=YES, copy dump files to rotdir 
if [ $ROTDIR_DUMP = "YES" ]; then
    $HOMEwfs/ush/getdump.sh $CDATE $PDUMP $DMPDIR/${PDUMP}${DUMP_SUFFIX}.${PDY}/${cyc} $COMOUT
    status=$?
    [[ $status -ne 0 ]] && exit $status

#   Ensure previous cycle gdas dumps are available (used by cycle & downstream)
    GDATE=$($NDATE -$assim_freq $CDATE)
    gPDY=$(echo $GDATE | cut -c1-8)
    gcyc=$(echo $GDATE | cut -c9-10)
    GDUMP=wdas
    PDUMP=gdas
    gCOMOUT="$ROTDIR/$GDUMP.$gPDY/$gcyc"
    if [ ! -s $gCOMOUT/$GDUMP.t${gcyc}z.updated.status.tm00.bufr_d ]; then
     $HOMEwfs/ush/getdump.sh $GDATE gdas $DMPDIR/${PDUMP}${DUMP_SUFFIX}.${gPDY}/${gcyc} $gCOMOUT
     status=$?
     [[ $status -ne 0 ]] && exit $status
    fi
    
fi

###############################################################

###############################################################
# For running real-time parallels on WCOSS_C, execute tropcy_qc and 
# copy files from operational syndata directory to a local directory.
# Otherwise, copy existing tcvital data from globaldump.
[[ $ROTDIR_DUMP = "NO" ]] && cp $DMPDIR/${CDUMP}${DUMP_SUFFIX}.${PDY}/${cyc}/${CDUMP}.t${cyc}z.syndata.tcvitals.tm00 $COMOUT/

###############################################################
# Generate prepbufr files from dumps or copy from OPS
[ $NODA = "YES" ] && exit
if [ $DO_MAKEPREPBUFR = "YES" ]; then
    if [ $ROTDIR_DUMP = "YES" ]; then
	rm $COMOUT/${OPREFIX}prepbufr
	rm $COMOUT/${OPREFIX}prepbufr.acft_profiles
	rm $COMOUT/${OPREFIX}nsstbufr
    fi

    export job="j${CDUMP}_prep_${cyc}"
    export DATAROOT="$RUNDIR/$CDATE/$CDUMP/prepbufr"
    if [ $ROTDIR_DUMP = "NO" ]; then
      COMIN_OBS=${COMIN_OBS:-$DMPDIR/${CDUMP}${DUMP_SUFFIX}.${PDY}/${cyc}}
      export COMSP=${COMSP:-$COMIN_OBS/$CDUMP.t${cyc}z.}
    fi
    export COMIN=${COMIN:-$ROTDIR/$CDUMP.$PDY/$cyc}
    export COMINwdas=${COMINwdas:-$ROTDIR/wdas.$PDY/$cyc}
    export COMINwfs=${COMINwfs:-$ROTDIR/wfs.$PDY/$cyc}

    $HOMEobsproc_network/jobs/JWAMIPE_PREP
    status=$?
    [[ $status -ne 0 ]] && exit $status

else
    if [ $ROTDIR_DUMP = "NO" ]; then
	$NCP $DMPDIR/${CDUMP}${DUMP_SUFFIX}.${PDY}/${cyc}/${OPREFIX}prepbufr               $COMOUT/${OPREFIX}prepbufr
	$NCP $DMPDIR/${CDUMP}${DUMP_SUFFIX}.${PDY}/${cyc}/${OPREFIX}prepbufr.acft_profiles $COMOUT/${OPREFIX}prepbufr.acft_profiles
	[[ $DONST = "YES" ]] && $NCP $DMPDIR/${CDUMP}${DUMP_SUFFIX}.${PDY}/${cyc}/${OPREFIX}nsstbufr $COMOUT/${OPREFIX}nsstbufr
    fi
fi

################################################################################
# Exit out cleanly
exit 0
