#!/bin/ksh -x

###############################################################
# Source WFS workflow modules
. $HOMEwfs/ush/load_wamipe_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Execute the JJOB
$HOMEwfs/jobs/JWAMIPE_FORECAST
status=$?
exit $status
