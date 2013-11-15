function metrics(data, refA, refB, categories, interval){
	// this function returns the number of events happended before A(B) and after A(B)

	var output = new Array();
	for (var i = 0; i < categories.length; i++){
		var C = categories[i];
		if (C != refA && C != refB ){
			beforeA = 0; // number of event C happened before A
			afterA = 0; // number of event C happened after A

			beforeB = 0; // number of event C happened before B
			afterB = 0; // number of event C happened after B

			for (var j = 0; j < data.length; j++){
				var game = data[j]; // events in one game
				num_C = 0;
				num_A = 0;
				num_B = 0;
				for (var e = 0; e<game.length;e++){
					if (game[e].event == C) {
						num_C++;
						afterA += num_A;
						afterB += num_A;
					}else if (game[e].event == refA){
						num_A++;
						beforeA += num_C;						
					}else if (game[e].event == refB){
						num_B++;
						beforeB += num_C;
					}
				}
			}
		}
		output.push_back(new Array(new Array(beforeA, afterA),new Array(beforeB, afterB)));
	}	
}
				

function distribution(data, refA, refB, categories, interval){
	// this function returns the number of events happended before A(B) and after A(B)

	var output = new Array();
	for (var i = 0; i < categories.length; i++){
		var C = categories[i];
		if (C != refA && C != refB ){
			var C_array = new Array(); //records all events of C
			var A_array = new Array(); //records all events of refA
			var B_array = new Array(); //records all events of refB

			var beforeA = new Array(); //distributions of events happening before refA
			var afterA = new Array(); //distributions of events happening after refA

			var beforeB = new Array(); //distributions of events happening before refB
			var afterB = new Array(); //distributions of events happening after refB

			for (var j = 0; j < data.length; j++){
				var game = data[j]; // events in one game
				for (var e = 0; e < game.length;e++){
					if (game[e].event == C) {
						C_array.push_back(game[e]);
						for (var a = 0; a < A_array.length; a++){
							var idx = dis(game[e].ts, A_array[a].te, interval); 
							afterA[idx]++;
						}
						for (var b = 0; a < B_array.length; b++){
							var idx = dis(game[e].ts, B_array[a].te, interval); 
							afterB[idx]++;
						}
					}else if (game[e].event == refA){
						A_array.push_back(game[e]); 
						for (var c = 0; a < C_array.length; c++){
							var idx = dis(game[e].ts, C_array[c].te, interval);
							beforeA[idx]++;
						}
					}else if (game[e].event == refB){
						B_array.push_back(game[e]); 
						for (var c = 0; a < C_array.length; c++){
							var idx = dis(game[e].ts, B_array[c].te, interval);
							beforeB[idx]++;
						}
					}
				}
			}
		}
		output.push_back(new Array(new Array(afterA, beforeA),new Array(afterB, beforeB)));
	}
	return output;
}

function dis(later_event_time,early_event_time,interval){
	//var later_min = parseInt(later_event_time(later_event_time.substring(3,4)));
	//var later_sec = parseInt(later_event_time(later_event_time.substring(6,7)));
	//var early_min = parseInt(later_event_time(early_event_time.substring(3,4)));
	//var early_sec = parseInt(later_event_time(early_event_time.substring(6,7)));

	//var diff_sec = later_min*60+later_sec - (early_min*60+early_sec);
	var diff_sec = (later_event_time.milliseconds - early_event_time.milliseconds)/1000;

	return diff_sec/interval;
}