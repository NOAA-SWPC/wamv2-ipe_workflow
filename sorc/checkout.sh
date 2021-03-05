#!/bin/sh
set -xu

topdir=$(pwd)
echo $topdir

echo comio checkout ...
if [[ ! -d comio.fd ]] ; then
    rm -f ${topdir}/checkout-comio.log
    git clone --recursive https://github.com/NOAA-SWPC/COMIO.git comio.fd >> ${topdir}/checkout-comio.log 2>&1
else
    echo 'Skip.  Directory comio.fd already exists.'
fi

echo gsmwam_ipe checkout ...
if [[ ! -d gsmwam_ipe.fd ]] ; then
    rm -f ${topdir}/checkout-gsmwam_ipe.log
    git clone --recursive https://github.com/NOAA-SWPC/GSMWAM-IPE.git --branch develop gsmwam_ipe.fd >> ${topdir}/checkout-gsmwam_ipe.log 2>&1
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

echo wamipe_utils checkout ...
if [[ ! -d wamipe_utils.fd ]] ; then
    rm -f ${topdir}/checkout-wamipe_utils.log
    git clone --recursive https://github.com/NOAA-SWPC/wam-ipe_utils --branch main wamipe_utils.fd >> ${topdir}/checkout-wamipe_utils.log 2>&1
else
    echo 'Skip.  Directory wamipe_utils.fd already exists.'
fi

echo obsproc_wamipe checkout ...
if [[ ! -d obsproc_wamipe.fd ]] ; then
    rm -f ${topdir}/checkout-obsproc_wamipe.log
    git clone --recursive https://github.com/NOAA-SWPC/obsproc_wamipe --branch obsproc_wamipe_RB-3.4.0 obsproc_wamipe.fd >> ${topdir}/checkout-obsproc_wamipe.log 2>&1
else
    echo 'Skip.  Directory obsproc_wamipe.fd already exists.'
fi

echo obsproc_prep checkout ...
if [[ ! -d obsproc_prep.fd ]] ; then
    rm -f ${topdir}/checkout-obsproc_prep.log
    git clone --recursive https://github.com/NOAA-SWPC/obsproc_prep --branch obsproc_prep_RB-5.4.0 obsproc_prep.fd >> ${topdir}/checkout-obsproc_prep.log 2>&1
else
    echo 'Skip.  Directory obsproc_prep.fd already exists.'
fi

exit 0
