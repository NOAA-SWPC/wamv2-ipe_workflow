#!/usr/bin/env python

###############################################################
# < next few lines under version control, D O  N O T  E D I T >
# $Date$
# $Revision$
# $Author$
# $Id$
###############################################################

from __future__ import print_function
import os
import sys
import glob
import shutil
import socket
from datetime import datetime
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import workflow_utils as wfu

global expdir, configdir, comrot, pslot, resdet, resens, nens, cdump, idate, edate, wfs_cyc


def makedirs_if_missing(d):
    if not os.path.exists(d):
        os.makedirs(d)


def create_EXPDIR():

    makedirs_if_missing(expdir)
    configs = glob.glob('%s/config.*' % configdir)
    if len(configs) == 0:
        msg = 'no config files found in %s' % configdir
        raise IOError(msg)
    for config in configs:
        shutil.copy(config, expdir)

    return


def create_COMROT():

    idatestr = idate.strftime('%Y%m%d%H')
    cymd = idate.strftime('%Y%m%d')
    chh = idate.strftime('%H')

    makedirs_if_missing(comrot)

    # Link ensemble member initial conditions
    enkfdir = 'enkf%s.%s/%s' % (cdump, cymd, chh)
    makedirs_if_missing(os.path.join(comrot, enkfdir))
    for i in range(1, nens + 1):
        makedirs_if_missing(os.path.join(comrot, enkfdir, 'mem%03d' % i))
        os.symlink(os.path.join(icsdir, idatestr, 'T%d' % resens, 'mem%03d' % i, 'INPUT'),
                   os.path.join(comrot, enkfdir, 'mem%03d' % i, 'INPUT'))

    # Link deterministic initial conditions
    detdir = '%s.%s/%s' % (cdump, cymd, chh)
    makedirs_if_missing(os.path.join(comrot, detdir))
    os.symlink(os.path.join(icsdir, idatestr, 'T%d' % resdet, 'control', 'INPUT'),
               os.path.join(comrot, detdir, 'INPUT'))

    # Link bias correction and radiance diagnostics files
    for fname in ['abias', 'abias_pc', 'abias_air', 'radstat']:
        os.symlink(os.path.join(icsdir, idatestr, '%s.t%sz.%s' % (cdump, chh, fname)),
                   os.path.join(comrot, detdir, '%s.t%sz.%s' % (cdump, chh, fname)))

    return


def edit_baseconfig():

    base_config = '%s/config.base' % expdir

    here = os.path.dirname(__file__)
    top = os.path.abspath(os.path.join(
        os.path.abspath(here), '../..'))

    if os.path.exists(base_config):
        os.unlink(base_config)

    print('\nSDATE = %s\nEDATE = %s' % (idate, edate))
    with open(base_config + '.emc.dyn', 'rt') as fi:
        with open(base_config, 'wt') as fo:
            for line in fi:
                line = line.replace('@MACHINE@', machine.upper()) \
                    .replace('@PSLOT@', pslot) \
                    .replace('@SDATE@', idate.strftime('%Y%m%d%H')) \
                    .replace('@EDATE@', edate.strftime('%Y%m%d%H')) \
                    .replace('@CASEENS@', 'T%d' % resens) \
                    .replace('@CASECTL@', 'T%d' % resdet) \
                    .replace('@NMEM_ENKF@', '%d' % nens) \
                    .replace('@HOMEwfs@', top) \
                    .replace('@wfs_cyc@', '%d' % wfs_cyc) \
                    .replace('@BASE_GIT@', base_git) \
                    .replace('@BASE_SVN@', base_svn) \
                    .replace('@DMPDIR@', dmpdir) \
                    .replace('@NWPROD@', nwprod) \
                    .replace('@COMROOT@', comroot) \
                    .replace('@HOMEDIR@', homedir) \
                    .replace('@STMP@', stmp) \
                    .replace('@PTMP@', ptmp) \
                    .replace('@NOSCRUB@', noscrub) \
                    .replace('@ACCOUNT@', account) \
                    .replace('@QUEUE@', queue) \
                    .replace('@QUEUE_ARCH@', queue_arch) \
                    .replace('@PARAMETER_PATH@', parameter_path) \
                    .replace('@IPE_IC_DIR@', ipe_ic_dir) \
                    .replace('@DCOM@', dcom) 
                if expdir is not None:
                    line = line.replace('@EXPDIR@', os.path.dirname(expdir))
                if comrot is not None:
                    line = line.replace('@ROTDIR@', os.path.dirname(comrot))
                if 'ICSDIR' in line:
                    continue
                fo.write(line)

    print('')
    print('EDITED:  %s/config.base as per user input.' % expdir)
    print('DEFAULT: %s/config.base.emc.dyn is for reference only.' % expdir)
    print('Please verify and delete the default file before proceeding.')
    print('')

    return


if __name__ == '__main__':

    description = '''Setup files and directories to start a WFS parallel.
Create EXPDIR, copy config files
Create COMROT experiment directory structure,
link initial condition files from $ICSDIR to $COMROT'''

    parser = ArgumentParser(description=description, formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument('--pslot', help='parallel experiment name', type=str, required=False, default='test')
    parser.add_argument('--resdet', help='resolution of the deterministic model forecast', type=int, required=False, default=62)
    parser.add_argument('--resens', help='resolution of the ensemble model forecast', type=int, required=False, default=192)
    parser.add_argument('--comrot', help='full path to COMROT', type=str, required=False, default='/scratch1/NCEPDEV/stmp2/{}'.format(os.environ['USER']))
    parser.add_argument('--expdir', help='full path to EXPDIR', type=str, required=False, default='/scratch1/NCEPDEV/swpc/{}/exp'.format(os.environ['USER']))
    parser.add_argument('--idate', help='starting date of experiment, initial conditions must exist!', type=str, required=True)
    parser.add_argument('--edate', help='end date experiment', type=str, required=True)
    parser.add_argument('--icsdir', help='full path to initial condition directory', type=str, required=False)
    parser.add_argument('--configdir', help='full path to directory containing the config files', type=str, required=False, default='../../parm/config')
    parser.add_argument('--nens', help='number of ensemble members', type=int, required=False, default=0)
    parser.add_argument('--cdump', help='CDUMP to start the experiment', type=str, required=False, default='wdas')
    parser.add_argument('--wfs_cyc', help='WFS cycles to run', type=int, choices=[0, 1, 2, 4], default=4, required=False)
    parser.add_argument('--partition', help='partition on machine', type=str, required=False, default=None)

    args = parser.parse_args()

    machine = wfu.detectMachine()

    configdir = args.configdir
    if not configdir:
        configdir = os.path.abspath(os.path.dirname(__file__) + '/../parm/config')

    pslot = args.pslot
    idate = datetime.strptime(args.idate, '%Y%m%d%H')
    edate = datetime.strptime(args.edate, '%Y%m%d%H')
    icsdir = args.icsdir
    resdet = args.resdet
    resens = args.resens
    comrot = args.comrot if args.comrot is None else os.path.join(args.comrot, pslot)
    expdir = args.expdir if args.expdir is None else os.path.join(args.expdir, pslot)
    nens = args.nens
    cdump = args.cdump
    wfs_cyc = args.wfs_cyc
    partition = args.partition

    # Set machine defaults
    if machine == 'WCOSS_DELL_P3':
      base_git = '/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git'
      base_svn = '/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git'
      dmpdir = '/gpfs/dell3/emc/global/dump'
      nwprod = '${NWROOT:-"/gpfs/dell1/nco/ops/nwprod"}'
      comroot = '${COMROOT:-"/gpfs/dell1/nco/ops/com"}'
      homedir = '/gpfs/dell2/emc/modeling/noscrub/$USER'
      stmp = '/gpfs/dell3/stmp/$USER'
      ptmp = '/gpfs/dell3/ptmp/$USER'
      noscrub = '/gpfs/dell2/emc/modeling/noscrub/$USER'
      account = 'SPACE-T2O'
      queue = 'dev'
      queue_arch = 'dev_transfer'
      ipe_ic_dir = '/gpfs/dell2/swpc/noscrub/Adam.Kubaryk/refactored_ipe_input_decks'
      parameter_path = '/gpfs/dell2/swpc/noscrub/Adam.Kubaryk/WAM-IPE_INPUT_PARAMETERS'
      dcom = '/gpfs/dell1/nco/ops/dcom/prod'

      if partition in ['3p5']:
        queue = 'dev2'
        queue_arch = 'dev2_transfer'

    elif machine == 'WCOSS2':
      base_git = '/lfs/h2/emc/noscrub/emc.glopara/git'
      base_svn = '/lfs/h2/emc/noscrub/emc.glopara/git'
      dmpdir = '/lfs/h2/emc/global/noscrub/dump'
      nwprod = '${NWROOT:-"/lfs/h1/ops/prod/nwprod"}'
      comroot = '${COMROOT:-"/lfs/h1/ops/prod/com"}'
      homedir = '/lfs/h1/swpc/wam/noscrub/$USER'
      stmp = '/lfs/h1/swpc/stmp/$USER'
      ptmp = '/lfs/h1/swpc/ptmp/$USER'
      noscrub = '/lfs/h1/swpc/wam/noscrub/$USER'
      account = 'WFS-DEV'
      queue = 'dev'
      queue_arch = 'dev_transfer'
      ipe_ic_dir = '/lfs/h1/swpc/wam/noscrub/Adam.Kubaryk/WAM_FIX/IPE_FIX'
      parameter_path = '/lfs/h1/gpfs/dell2/swpc/noscrub/Adam.Kubaryk/WAM-IPE_INPUT_PARAMETERS'
      dcom = '/lfs/h1/ops/canned/dcom' # prod

      if partition in ['3p5']:
        queue = 'dev2'
        queue_arch = 'dev2_transfer'
    elif machine == 'WCOSS_C':
      base_git = '/gpfs/hps3/emc/global/noscrub/emc.glopara/git'
      base_svn = '/gpfs/hps3/emc/global/noscrub/emc.glopara/svn'
      dmpdir = '/gpfs/dell3/emc/global/dump'
      nwprod = '${NWROOT:-"/gpfs/hps/nco/ops/nwprod"}'
      comroot = '${COMROOT:-"/gpfs/hps/nco/ops/com"}'
      homedir = '/gpfs/hps3/emc/global/noscrub/$USER'
      stmp = '/gpfs/hps2/stmp/$USER'
      ptmp = '/gpfs/hps2/ptmp/$USER'
      noscrub = '/gpfs/hps3/emc/global/noscrub/$USER'
      account = 'GFS-DEV'
      queue = 'dev'
      queue_arch = 'dev_transfer'
    elif machine == 'HERA':
      base_git = '/scratch1/NCEPDEV/global/glopara/git'
      base_svn = '/scratch1/NCEPDEV/global/glopara/svn'
      dmpdir = '/scratch1/NCEPDEV/global/glopara/dump'
      nwprod = '/scratch1/NCEPDEV/global/glopara/nwpara'
      comroot = '/scratch1/NCEPDEV/rstprod/com'
      homedir = '/scratch1/NCEPDEV/global/$USER'
      stmp = '/scratch1/NCEPDEV/stmp2/$USER'
      ptmp = '/scratch1/NCEPDEV/stmp4/$USER'
      noscrub = '$HOMEDIR'
      account = 'swpc'
      queue = 'batch'
      queue_arch = 'service'
      ipe_ic_dir = '/scratch1/NCEPDEV/swpc/WAM-IPE_DATA/IPE_FIX'
      parameter_path = '/scratch1/NCEPDEV/swpc/WAM-IPE_DATA/INPUT_PARAMETERS'
      dcom = '/scratch1/NCEPDEV/swpc/George.Millward/dcom'

    if args.icsdir is not None and not os.path.exists(icsdir):
        msg = 'Initial conditions do not exist in %s' % icsdir
        raise IOError(msg)

    # COMROT directory
    if args.icsdir is None:
       create_comrot = False
    else:
       create_comrot = True
       if os.path.exists(comrot):
           print()
           print('COMROT already exists in %s' % comrot)
           print()
           overwrite_comrot = input('Do you wish to over-write COMROT [y/N]: ')
           create_comrot = True if overwrite_comrot in ['y', 'yes', 'Y', 'YES'] else False
           if create_comrot:
              shutil.rmtree(comrot)

    if create_comrot:
        create_COMROT()

    # EXP directory
    create_expdir = True
    if os.path.exists(expdir):
        print()
        print('EXPDIR already exists in %s' % expdir)
        print()
        overwrite_expdir = input('Do you wish to over-write EXPDIR [y/N]: ')
        create_expdir = True if overwrite_expdir in ['y', 'yes', 'Y', 'YES'] else False
        if create_expdir:
            shutil.rmtree(expdir)

    if create_expdir:
        create_EXPDIR()
        edit_baseconfig()

    sys.exit(0)
