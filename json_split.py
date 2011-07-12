#!/usr/bin/python

import os
import sys
import json

obj = json.load(sys.stdin)

for q in obj['questions']:
	fname = 'questions/' + str(q['question_id'])
	if not os.path.exists(fname) :
		f = open(fname, "w")
		f.write("question = ")
		json.dump(q, f)
		f.close()
