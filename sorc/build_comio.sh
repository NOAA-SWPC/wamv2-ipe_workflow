#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

if [ $target = "wcoss2" ] ; then
  module load envvar/$envvar_ver
  module load PrgEnv-intel/$PrgEnv_intel_ver
  module load craype/$craype_ver
  module load intel/$intel_ver
  module load cray-mpich/$cray_mpich_ver
  module load cray-libsci/$cray_libsci_ver
  module load cray-pals/$cray_pals_ver

  module load netcdf/$netcdf_ver
  module load hdf5/$hdf5_ver
  module load pnetcdf/$pnetcdf_ver
else
  module use ../modulefiles
  module load module_base.$target
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

cd comio.fd

if [ $target = "wcoss_dell_p3" ] ; then
LIBS=-lgfortran ./configure --prefix=`pwd`/install
else
./configure --prefix=`pwd`/install
fi

make && make install

exit
