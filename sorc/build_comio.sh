#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

module use -a ../modulefiles
module load module_base.$target

if [ $target = "wcoss_dell_p3" ] ; then
  LIBS=-lgfortran
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

cd comio.fd

./configure --prefix=`pwd`/install
make && make install

exit
