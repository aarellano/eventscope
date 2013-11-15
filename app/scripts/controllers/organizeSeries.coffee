list = (data, refA, refB, categories, interval)-> 
for eventName in categories
	if eventName != refA
		before = 0;
		after = 0;
		for game in data
			for event in game
				

