#!/bin/sh
set +x
#------------------------------------
# Exception handling is now included.
#
# USER DEFINED STUFF:
#
# USE_PREINST_LIBS: set to "true" to use preinstalled libraries.
#                   Anything other than "true"  will use libraries locally.
#------------------------------------

export USE_PREINST_LIBS="true"

#------------------------------------
# END USER DEFINED STUFF
#------------------------------------

build_dir=`pwd`
logs_dir=$build_dir/logs
if [ ! -d $logs_dir  ]; then
  echo "Creating logs folder"
  mkdir $logs_dir
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  echo "Creating ../exec folder"
  mkdir ../exec
fi

#------------------------------------
# GET MACHINE
#------------------------------------
target=""
source ./machine-setup.sh > /dev/null 2>&1

source ../versions/build.ver
#------------------------------------
# INCLUDE PARTIAL BUILD 
#------------------------------------

. ./partial_build.sh

#------------------------------------
# Exception Handling Init
#------------------------------------
ERRSCRIPT=${ERRSCRIPT:-'eval [[ $err = 0 ]]'}
err=0

#------------------------------------
# build libraries first
#------------------------------------
$Build_libs && {
echo " .... Library build not currently supported .... "
#echo " .... Building libraries .... "
#./build_libs.sh > $logs_dir/build_libs.log 2>&1
}

#------------------------------------
# build COMIO
#------------------------------------
$Build_comio && {
echo " .... Building comio .... "
./build_comio.sh > $logs_dir/build_comio.log 2>&1
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building COMIO."
    echo "The log file is in $logs_dir/build_comio.log"
fi
((err+=$rc))
}

#------------------------------------
# build GSMWAM-IPE
#------------------------------------
$Build_gsmwam_ipe && {
echo " .... Building gsmwam_ipe .... "
./build_gsmwam_ipe.sh > $logs_dir/build_gsmwam_ipe.log 2>&1
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building GSMWAM-IPE."
    echo "The log file is in $logs_dir/build_gsmwam_ipe.log"
fi
((err+=$rc))
}

#------------------------------------
# build gsi
#------------------------------------
$Build_gsi && {
echo " .... Building gsi .... "
./build_gsi.sh > $logs_dir/build_gsi.log 2>&1
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building gsi."
    echo "The log file is in $logs_dir/build_gsi.log"
fi
((err+=$rc))
}

#------------------------------------
# build wam-ipe_utils
#------------------------------------
$Build_wamipe_utils && {
echo " .... Building wamipe_utils .... "
./build_wamipe_utils.sh > $logs_dir/build_wamipe_utils.log 2>&1
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building wamipe_utils."
    echo "The log file is in $logs_dir/build_wamipe_utils.log"
fi
((err+=$rc))
}

#------------------------------------
# build obsproc
#------------------------------------
$Build_obsproc && {
echo " .... Building obsproc .... "
./build_obsproc.sh > $logs_dir/build_obsproc.log 2>&1
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building obsproc."
    echo "The log file is in $logs_dir/build_obsproc.log"
fi
((err+=$rc))
}

#------------------------------------
# Exception Handling
#------------------------------------
[[ $err -ne 0 ]] && echo "FATAL BUILD ERROR: Please check the log file for detail, ABORT!"
$ERRSCRIPT || exit $err

echo;echo " .... Build system finished .... "

exit 0
