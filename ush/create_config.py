#!/usr/bin/env python
import json
from glob import glob
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

DEFAULT = ['jh0=1.75',
           'jh_tanh=0.5',
           'jh_semiann=0.5',
           'jh_ann=0.0',
           'jh_st0=25000.0',
           'jh_st1=5000.0',
           'skeddy0=140.0',
           'skeddy_semiann=60.0',
           'skeddy_ann=0.0',
           'tkeddy0=280.0',
           'tkeddy_semiann=0.0',
           'tkeddy_ann=0.0',
           'on2_ref_val=2e+21',
           'dynamo_efield=T',
           'potential_model=2',
           'offset1=5.0',
           'offset2=20.0',
           'transport_highlat_lp=30',
           'perp_transport_max=151',
           'hpeq=0.0',
           'colfac=1.3',
           'ipe_coldstart=F']

def print_default():
    for line in DEFAULT:
        print(line)

def main():
    parser = ArgumentParser(description='Create namelist values for WAM-IPE operational runs from JSON.')
    parser.add_argument('-p', '--path',    help='path to JSON files', type=str, default='/gpfs/dell1/nco/ops/dcom/prod')
    parser.add_argument('-d', '--default', help='default JSON file',  type=str, required=True)

    args = parser.parse_args()

    files = glob('{}/????????/swpc/wam/*json'.format(args.path))

    if len(files) == 0:
        file = args.default
    else:
        files.sort()
        file = files[-1]

    j = json.load(open(file))

    for k,v in j.items():
        if k == 'time-tag': continue
        if type(v) == bool:
            if v:
                print('{}=T'.format(k))
            else:
                print('{}=F'.format(k))
        else:
            print('{}={}'.format(k,v))

if __name__ == '__main__':
    try:
        main()
    except:
        print_default()
