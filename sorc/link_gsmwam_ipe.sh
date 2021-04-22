#!/bin/bash
set -ex

#--make symbolic links for EMC installation and hardcopies for NCO delivery

RUN_ENVIR=${1}
machine=${2}

if [ $# -lt 2 ]; then
    echo '***ERROR*** must specify two arguements: (1) RUN_ENVIR, (2) machine'
    echo ' Syntax: link_gsmwam_ipe.sh ( nco | emc ) ( cray | dell | hera )'
    exit 1
fi

if [ $RUN_ENVIR != emc -a $RUN_ENVIR != nco ]; then
    echo 'Syntax: link_gsmwam_ipe.sh ( nco | emc ) ( cray | dell | hera )'
    exit 1
fi
if [ $machine != cray -a -a $machine != dell -a $machine != hera ]; then
    echo 'Syntax: link_gsmwam_ipe.sh ( nco | emc ) ( cray | dell | hera )'
    exit 1
fi

LINK="ln -fs"
SLINK="ln -fs"
[[ $RUN_ENVIR = nco ]] && LINK="cp -rp"

pwd=$(pwd -P)

#------------------------------
#--model fix fields
#------------------------------
if [ $machine == "cray" ]; then # unsupported
    FIX_DIR="/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix"
elif [ $machine = "dell" ]; then
    FIX_DIR="/gpfs/dell2/swpc/noscrub/Adam.Kubaryk/WAM_FIX"
elif [ $machine = "hera" ]; then
    FIX_DIR="/scratch1/NCEPDEV/swpc/WAM-IPE_DATA/WAM_FIX"
fi
cd ${pwd}/../fix                ||exit 8
for dir in GSM IPE_FIX MED_SPACEWX WAM_gh_L150 ; do
    [[ -d $dir ]] && rm -rf $dir
done
$LINK $FIX_DIR/* .

#---------------------------------------
#--add files from external repositories
#---------------------------------------
cd ${pwd}/../ush                ||exit 8
    for file in global_cycle_driver.sh \
        global_chgres_driver.sh  global_cycle.sh \
        global_chgres.sh ; do
        $LINK ../sorc/wamipe_utils.fd/ush/$file                  .
    done

    for file in interpolate_input_parameters.py parse_realtime.py \
        sw_from_f107_kp.py parse.py realtime_wrapper.py ; do
        $LINK ../sorc/gsmwam_ipe.fd/scripts/interpolate_input_parameters/$file .
    done

#------------------------------
#--add GSI file
#------------------------------
cd ${pwd}/../jobs               ||exit 8
    $LINK ../sorc/gsi.fd/jobs/JWAMIPE_ANALYSIS           .
    $LINK ../sorc/obsproc_wamipe.fd/jobs/JWAMIPE_PREP    .
cd ${pwd}/../scripts            ||exit 8
    $LINK ../sorc/gsi.fd/scripts/exwamipe_analysis.sh.ecf    .
cd ${pwd}/../fix                ||exit 8
    [[ -d fix_gsi ]] && rm -rf fix_gsi
    $LINK ../sorc/gsi.fd/fix  fix_gsi


#------------------------------
#--link executables
#------------------------------

cd $pwd/../exec
executable=global_gsmwam_ipe.x
[[ -s $executable ]] && rm -f $executable
$LINK ../sorc/gsmwam_ipe.fd/NEMS/exe/NEMS.x $executable

for wamipe_utilsexe in \
     nemsio_get        chgsigfhr       chgsfcfhr     \
     global_chgres     global_sighdr   global_cycle  \
     global_sfchdr ; do
    [[ -s $wamipe_utilsexe ]] && rm -f $wamipe_utilsexe
    $LINK ../sorc/wamipe_utils.fd/exec/$wamipe_utilsexe .
done

for gsiexe in  global_gsi.x ;do
    [[ -s $gsiexe ]] && rm -f $gsiexe
    $LINK ../sorc/gsi.fd/exec/$gsiexe .
done


#------------------------------
#--link source code directories
#------------------------------

cd ${pwd}/../sorc   ||   exit 8
    $SLINK gsi.fd/src                                                                      global_gsi.fd

#------------------------------
#--choose dynamic config.base for EMC installation
#--choose static config.base for NCO installation
cd $pwd/../parm/config
[[ -s config.base ]] && rm -f config.base
if [ $RUN_ENVIR = nco ] ; then
 cp -p config.base.nco.static config.base
else
 cp -p config.base.emc.dyn config.base
fi
#------------------------------


exit 0

