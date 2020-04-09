#!/bin/ksh -x

###############################################################
# Source WFS workflow modules
. $HOMEwfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Execute the JJOB
$HOMEwfs/jobs/JGLOBAL_ANALYSIS
status=$?
exit $status
