state("BioshockHD")
{
	bool	inGame			:	0x12D270C, 0x214, 0x6E8, 0x38;
	byte	fontainePhase	:	0x12D22C4, 0x0, 0x14, 0x1C, 0x1148;
	int		lvl				:	0x130287C;
	int		loading			:	0x12D2730;
}
state("Bioshock2HD")
{
	bool 	isSaving		:	0x1A9A680;
	bool 	isLoading		:	0x1885120, 0x298;
	byte	lvl				:	0x1885120, 0x278;
	byte	area			:	0x189D7BC;
	bool	endMain			:	0x189F260, 0x1F0, 0x34, 0x1C0, 0x788;
	bool	endDLC			:	0x1AAEE1C, 0x24, 0xEC, 0x938;
}

startup 
{
	vars.md=false;
	
	settings.Add("setup",false,"Enable game time pausing on setup splits for multi-game runs");
	settings.SetToolTip("setup", "Setup splits must have the word \"setup\" in them (without the quotes). Make sure no other splits have that word");
	
	settings.Add("BS1",true,"BioShock 1");
	vars.lvls=new string[]
	{
	"The Crash Site", "Welcome to Rapture", "Medical Pavillion",
	"Neptunes Bounty", "Smugglers Hideout", "Arcadia (Not skipped)",
	"Farmers Market", "Arcadia", "Fort Frolic", "Hephaestus",
	"Rapture Central Control", "Olympus Heights", "Apollo Square",
	"Point Prometheus", "Proving Grounds", "Fontaine",
	};
	
	foreach(var item in vars.lvls)
	{
		if(item == "Arcadia (Not skipped)"||item == "Farmers Market") settings.Add(item, false, null, "BS1");
		else settings.Add(item, true, null, "BS1");
	}
	
	settings.Add("BS2",true,"BioShock 2");
	vars.lvls2=new string[]{
	"Adonis Luxury Resort", "The Atlantic Express", "Ryan Amusements",
	"Pauper's Drop", "Siren Alley", "Dionysus Park",
	"Fontaine Futuristics", "Fontaine Futuristics 1",
	"Outer Persephone", "Inner Persephone",};
	
	foreach(var item in vars.lvls2)
	{
		if(item == "Fontaine Futuristics 1"){
			settings.Add(item, false, null,"Fontaine Futuristics");
			settings.SetToolTip(item, "Split when leaving the first half of Fontaine Futuristics");
		}
		else settings.Add(item, true, null, "BS2");
	}
	
	settings.Add("BS2MD",true,"BioShock 2: Minerva's Den");
	vars.lvls3=new string[]{"Minerva's Den", "Operations", "The Thinker",};
	
	foreach(var item in vars.lvls3){settings.Add(item, true, null, "BS2MD");}
}

init
{
	timer.IsGameTimePaused=false;
	vars.prevLvl=0;
	vars.prevArea=0;
	if(!game.ProcessName.Contains("2"))
		vars.md=false;
}

exit{timer.IsGameTimePaused=true;}

start
{
	vars.prevLvl=0;
	vars.prevArea=0;
	
	if(game.ProcessName.Contains("2")){
		if(current.lvl == 2){ // Minerva's Den
			vars.md=true;
			return current.area == 47 && old.area == 56;
		}
		else{ // Main game
			vars.md=false;
			return current.lvl == 7 && current.area == 35 && old.area == 40;
		}
	}
	else return current.lvl == 1555 && current.inGame && !old.inGame;
}

isLoading
{
	if(settings["setup"] && timer.CurrentSplit.Name.ToLower().Contains("setup"))
		return true;
	if(game.ProcessName.Contains("2"))
		return current.isSaving || current.isLoading;
	else
		return current.loading != 0;
}

split
{
	if(current.lvl != old.lvl){
		if(current.lvl == 0 && old.lvl != 0) vars.prevLvl=old.lvl;
		//print("[ASL] vars.prevLvl: "+vars.prevLvl+" | current.lvl: "+current.lvl);
		
		if(game.ProcessName.Contains("2")){
			if(vars.md){
				if(current.area == 0 && old.area != 0) vars.prevArea=old.area;
				//print("[ASL] vars.prevArea: "+vars.prevArea+" | current.area: "+current.area);
				 if(vars.prevLvl == 2 	&& current.lvl == 19)	{vars.prevLvl=current.lvl;	return settings["Minerva's Den"];}
			}
			else
			{
				 if(current.lvl == 0) return;
			else if(vars.prevLvl == 7 	&& current.lvl == 2)		{vars.prevLvl=current.lvl;	return settings["Adonis Luxury Resort"];}
			else if(vars.prevLvl == 2 	&& current.lvl == 16)		{vars.prevLvl=current.lvl;	return settings["The Atlantic Express"];}
			else if(vars.prevLvl == 16 	&& current.lvl == 39)		{vars.prevLvl=current.lvl;	return settings["Ryan Amusements"];}
			else if(vars.prevLvl == 39	&& current.lvl == 36)		{vars.prevLvl=current.lvl;	return settings["Pauper's Drop"];}
			else if(vars.prevLvl == 36	&& current.lvl == 25)		{vars.prevLvl=current.lvl;	return settings["Siren Alley"];}
			else if(vars.prevLvl == 25 	&& current.lvl == 27)		{vars.prevLvl=current.lvl;	return settings["Dionysus Park"];}
			else if(vars.prevLvl == 27 	&& current.lvl == 3)		{vars.prevLvl=current.lvl;	return settings["Fontaine Futuristics"];}
			else if(vars.prevLvl == 3 	&& current.lvl == 39)		{vars.prevLvl=current.lvl;	return settings["Outer Persephone"];}
			}
		}
		
		else
		{
				 if(current.lvl == 0) return;
			else if(vars.prevLvl == 1555 	&& current.lvl == 5538)	{vars.prevLvl=current.lvl; return settings["The Crash Site"];}
			else if(vars.prevLvl == 7648 	&& current.lvl == 7039)	{vars.prevLvl=current.lvl; return settings["Welcome to Rapture"];}
			else if(vars.prevLvl == 9712 	&& current.lvl == 8543)	{vars.prevLvl=current.lvl; return settings["Medical Pavillion"];}
			else if(vars.prevLvl == 11780 	&& current.lvl == 3205)	{vars.prevLvl=current.lvl; return settings["Neptunes Bounty"];}
			else if(vars.prevLvl == 4440 	&& current.lvl == 8187)	{vars.prevLvl=current.lvl; return settings["Smugglers Hideout"];}
			else if(vars.prevLvl == 11290	&& current.lvl == 5448)	{vars.prevLvl=current.lvl; return settings["Arcadia (Not skipped)"];}
			else if(vars.prevLvl == 7524	&& current.lvl == 8187)	{vars.prevLvl=current.lvl; return settings["Farmers Market"];}
			else if(vars.prevLvl == 11290 	&& current.lvl == 9317)	{vars.prevLvl=current.lvl; return settings["Arcadia"];}
			else if(vars.prevLvl == 12844 	&& current.lvl == 6932)	{vars.prevLvl=current.lvl; return settings["Fort Frolic"];}
			else if(vars.prevLvl == 9564 	&& current.lvl == 2116)	{vars.prevLvl=current.lvl; return settings["Hephaestus"];}
			else if(vars.prevLvl == 2942 	&& current.lvl == 8291)	{vars.prevLvl=current.lvl; return settings["Rapture Central Control"];}
			else if(vars.prevLvl == 11433 	&& current.lvl == 5804)	{vars.prevLvl=current.lvl; return settings["Olympus Heights"];}
			else if(vars.prevLvl == 8013 	&& current.lvl == 8672)	{vars.prevLvl=current.lvl; return settings["Apollo Square"];}
			else if(vars.prevLvl == 11957 	&& current.lvl == 4101)	{vars.prevLvl=current.lvl; return settings["Point Prometheus"];}
			else if(vars.prevLvl == 5672 	&& current.lvl == 928)	{vars.prevLvl=current.lvl; return settings["Proving Grounds"];}
		}
	}
	else if(game.ProcessName.Contains("2"))
	{
			// Split on leaving airlock from main FF and entering water section
				 if(!vars.md && current.lvl==27 && current.area == 49 && old.area == 50)													return settings["Fontaine Futuristics 1"];
			// Split on entering final elevator
			else if(!vars.md && current.lvl==39 && current.area == 63 && current.endMain && !old.endMain)									return settings["Inner Persephone"];
			// Minerva's Den splits
			else if(vars.md  && current.lvl== 0 && vars.prevLvl == 19 && vars.prevArea== 4 && current.area== 2){vars.prevLvl=current.lvl;	return settings["Operations"];}
			else if(vars.md  && current.lvl== 0 && old.lvl== 0 && current.area== 22 && current.endDLC && !old.endDLC)						return settings["The Thinker"];
	}
	else if(current.lvl==1309 && old.fontainePhase==3 && current.fontainePhase==4)		   return settings["Fontaine"];
}