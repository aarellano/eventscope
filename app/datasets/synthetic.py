#!/usr/bin/python

import sys
import json 
import random 

eventList = ['drug1','drug2','emergency room','death','discharge']

def gen(nEvents=1000, maxTime = 1000, nPatients=100, events=eventList):
    l = list()
    for i in range(nEvents):
      ts = random.randint(0, maxTime)
      te = random.randint(0, maxTime) + ts
      l.append({ 'id':random.randint(0,nPatients), \
                 'event': random.choice(events), \
                 'ts':ts,'te':te })
    return l 
d = { 'events' : gen() }
with open('example.json', 'wb') as fh:
   json.dump(d, fh)


