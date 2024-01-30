//Merged Doohl's and the existing ticklag as they both had good elements about them ~Carn

/client/proc/ticklag()
	set category = "Debug"
	set name = "Set Ticklag"
	set desc = "Sets a new tick lag. Recommend you don't mess with this too much! Stable, time-tested ticklag value is 0.9"

	if(!check_rights(R_DEBUG))	return

	var/newtick = input("Sets a new tick lag. Please don't mess with this too much! The stable, time-tested ticklag value is 0.9","Lag of Tick", world.tick_lag) as num|null
	//I've used ticks of 2 before to help with serious singulo lags
	if(newtick && newtick <= 2 && newtick > 0)
		log_and_message_admins("has modified world.tick_lag to [newtick]")
		world.tick_lag = newtick
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Ticklag") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

	else
		to_chat(src, "<span class='warning'>Error: ticklag(): Invalid world.ticklag value. No changes made.</span>")


