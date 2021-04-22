#!/bin/sh

# Checkout, build, setup and execute the workflow

set -ex

pslot="pseudoops"
expdir="/gpfs/dell2/swpc/noscrub/$USER/exp"
comrot="/gpfs/dell2/ptmp/$USER"
idate="2021041406"
edate="2021050100"

######################################
# USER NEED NOT MODIFY BELOW THIS LINE
######################################

[[ -d $expdir/$pslot ]] && rm -rf $expdir/$pslot
#[[ -d $comrot/$pslot ]] && rm -rf $comrot/$pslot

python setup_expt.py --pslot $pslot --comrot $comrot --expdir $expdir \
                     --idate $idate --edate $edate --configdir ../../parm/config
python setup_workflow.py --expdir $expdir/$pslot
