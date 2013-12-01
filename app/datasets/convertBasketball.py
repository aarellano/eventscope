#!/usr/bin/python
import sys
import json
import csv
import os
import argparse
import re
from operator import itemgetter

parser = argparse.ArgumentParser(description='Convert basketball dataset to json.')
parser.add_argument('-i','--input',default='Chicago_Bulls_New',
                   help='where to get the input from (file or folder)')
parser.add_argument('-o','--output',default='Basketball.json',
                   help='full path of json output file.')
def convert(input, output):
	if(os.path.isfile(input)):
		file_list = [input]
	else:
		file_list = [os.path.join(input,f) for f in os.listdir(input) if os.path.isfile(os.path.join(input,f))]
	events = []
	shot_type_pattern = re.compile("(?<=Shot Type=\")\d")
	for filepath in file_list:
		fhandle = open(filepath,'rb')
		reader = csv.reader(fhandle,delimiter='\t',quoting=csv.QUOTE_NONE)
		for row in reader:
			rec_id = row[0]
			event_type = row[1].rstrip()
			ts = row[2]
			if(len(row) > 3 and ":" in row[3]):
				#contains end time
				te = row[3]
			else:
				te = None
			if(event_type == "No Points Scored" or event_type == "Points Scored"):
				#skip these two types
				continue
			if("End of Period" in event_type):
				event_type = "End of Period"

			if("End of Game" in event_type):
				event_type = "End of Game"

			if("Timeout" in event_type):
				event_type = "Timeout"

			if("Made Shot" in event_type or "Missed Shot" in event_type):
				#add what type of shot it is
				shot_type = shot_type_pattern.findall(row[4])[0]
				event_type = event_type + " " + shot_type
			events.append({ 'id':rec_id,
               				'event': event_type,
               				'ts':ts,
               				'te':te})
	#sort by getter
	events.sort(key=itemgetter('id'))
	data = { 'events' : events }
	with open(output, 'wb') as fhandle:
		json.dump(data, fhandle)
    	fhandle.close()
	

if __name__ == '__main__':
  if sys.argv[0] == 'python':
    start_from = 2
  else:
    start_from = 1
  args = parser.parse_args(sys.argv[start_from:])
  convert(**vars(args));