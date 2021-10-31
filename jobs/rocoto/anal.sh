#!/bin/ksh -x
if [ ! -z ${PBS_O_WORKDIR} ]; then cd $PBS_O_WORKDIR; fi
###############################################################
# Source WAM-IPE workflow modules
. $HOMEwfs/ush/load_wamipe_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Execute the JJOB
$HOMEwfs/jobs/JWAMIPE_ANALYSIS
status=$?
exit $status
