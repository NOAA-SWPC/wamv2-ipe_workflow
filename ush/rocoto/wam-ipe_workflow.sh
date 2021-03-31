#!/bin/sh

# Checkout, build, setup and execute the workflow

set -ex

pslot="run_test"
expdir="/gpfs/dell2/swpc/noscrub/Adam.Kubaryk/exp"
comrot="/gpfs/dell2/ptmp/Adam.Kubaryk"
idate="2021033100"
edate="2021033100"

######################################
# USER NEED NOT MODIFY BELOW THIS LINE
######################################

[[ -d $expdir/$pslot ]] && rm -rf $expdir/$pslot
[[ -d $comrot/$pslot ]] && rm -rf $comrot/$pslot

python setup_expt.py --pslot $pslot --comrot $comrot --expdir $expdir \
                     --idate $idate --edate $edate --configdir ../../parm/config
python setup_workflow.py --expdir $expdir/$pslot
