#!/bin/ksh -x

###############################################################
# Source WAM-IPE workflow modules
. $HOMEwamipe/ush/load_wamipe_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Execute the JJOB
$HOMEwamipe/jobs/JWAMIPE_PREP
status=$?
exit $status
