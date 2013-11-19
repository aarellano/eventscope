#!/usr/bin/python
import sys
import json
import random
import argparse
from datetime import datetime

event_list = ['drug1','drug2','emergency room','death','discharge']

parser = argparse.ArgumentParser(description='Generate synthetic dataset.')
parser.add_argument('-ne','--num_events', type=int, default=1000,
                   help='total number of events to generate')
parser.add_argument('-nr','--num_records', type=int, default=100,
                   help='number of records')
parser.add_argument('-mt','--max_time', type=int, default=1440,
                   help='maximum event starting time in minutes')
parser.add_argument('-md','--max_duration', type=int, default=60,
                   help='maximum event duration in minutes')
parser.add_argument('-f','--file_path',default='Example.json',
                   help='file to which to write the dataset')

def gen(num_events=1000,
        num_records=100,
        max_time = 43200,
        max_duration = 60,
        file_path='Example.json',
        events=event_list):
  l = []
  for i in xrange(num_events):
    ts_sec = 946684800 + random.randint(0, max_time * 60)
    te_sec = random.randint(0, max_duration * 60) + ts_sec
    ts = datetime.fromtimestamp(ts_sec)
    te = datetime.fromtimestamp(te_sec)
    l.append({ 'id':random.randint(0,num_records),
               'event': random.choice(events),
               'ts':ts.strftime("%Y/%m/%d %H:%M:%S"),
               'te':te.strftime("%Y/%m/%d %H:%M:%S")})
  d = { 'events' : l }
  with open(file_path, 'wb') as fh:
    json.dump(d, fh)
    fh.close()

if __name__ == '__main__':
  if sys.argv[0] == 'python':
    start_from = 2
  else:
    start_from = 1
  args = parser.parse_args(sys.argv[start_from:])
  gen(**vars(args));

