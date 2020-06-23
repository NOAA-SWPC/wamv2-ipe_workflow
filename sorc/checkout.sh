#!/bin/sh
set -xu

topdir=$(pwd)
echo $topdir

echo gsmwam_ipe checkout ...
if [[ ! -d gsmwam_ipe.fd ]] ; then
    rm -f ${topdir}/checkout-gsmwam_ipe.log
    git clone --recursive https://github.com/NOAA-SWPC/GSMWAM-IPE.git --branch ipe_transport gsmwam_ipe.fd >> ${topdir}/checkout-gsmwam_ipe.log 2>&1
else
    echo 'Skip.  Directory gsmwam_ipe.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive https://github.com/NOAA-SWPC/GSI --branch support_for_wam gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi

exit 0
