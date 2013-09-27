local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path );  

local backToMain, play, selectTeam, teamRed, teamBlue;
local playerTeamId, lineupone, lineuptwo;

local function playButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = play.x - (play.width / 2);
		local maxX = play.x + (play.width / 2);
		local minY = play.y - (play.height / 2);
		local maxY = play.y + (play.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			storyboard.gotoScene("roshamboscene", "fade", 400);
		end
	end
end

local function backButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = backToMain.x - (backToMain.width / 2);
		local maxX = backToMain.x + (backToMain.width / 2);
		local minY = backToMain.y - (backToMain.height / 2);
		local maxY = backToMain.y + (backToMain.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			storyboard.gotoScene("titlescene", "fade", 400);
		end
	end
end

local function fadeOutFirstPart()
	teamRed.touch = nil;
	teamBlue.touch = nil;
	transition.to(selectTeam, {time = 400, alpha = 0});
	transition.to(teamRed, {time = 400, alpha = 0});
	transition.to(teamBlue, {time = 400, alpha = 0});
end

local function fadeInSecondPart()
	local group = scene.view;
	transition.to(play, {time = 400, alpha = 1});
	transition.to(lineupone, {time = 400, alpha = 1});
	transition.to(lineuptwo, {time = 400, alpha = 1});
	play.touch = itemTouch;
	--Two lineups
	local getNames = "SELECT p.name, ld.position, l.lineupid FROM player AS p " ..
					 "JOIN lineupdetail AS ld ON p.playerid = ld.playerid " ..
					 "JOIN lineup AS l on ld.lineupid = l.lineupid " ..
					 "WHERE l.teamid = " .. playerTeamId .. " " ..
					 "ORDER BY l.lineupid";
	local lineupTexts = {};
	for row in db:nrows(getNames) do
		local tempArray = {row.name, row.position};
		table.insert(lineupTexts, tempArray);
	end
	local pokeFont;
	if "Win" == system.getInfo("platformName") then
		pokeFont = "Pokemon GB"
	else
		pokeFont = "PokemonGB"
	end
	local lineup1Text = display.newText("Temp", 0, 0, (display.contentWidth / 2), 0, pokeFont, 12);
	lineup1Text.x = display.contentWidth / 4 + 50;
	lineup1Text.y = 150;
	local updateText = "";
	for i=1,11 do
		updateText = updateText .. "\n" .. lineupTexts[i][1] .. "  " .. lineupTexts[i][2];
	end
	lineup1Text.text = updateText;
	lineup1Text.alpha = 0;
	group:insert(lineup1Text);
	local lineup2Text = display.newText("Temp", 0, 0, (display.contentWidth / 2), 0, pokeFont, 12);
	lineup2Text.x = display.contentWidth / 2 + 170;
	lineup2Text.y = 150;
	updateText = "";
	for i=12,22 do
		updateText = updateText .. "\n" .. lineupTexts[i][1] .. "  " .. lineupTexts[i][2];
	end
	lineup2Text.text = updateText;
	lineup2Text.alpha = 0;
	group:insert(lineup2Text);
	
	transition.to(lineup1Text, {time = 400, alpha = 1});
	transition.to(lineup2Text, {time = 400, alpha = 1});
end

local function updateCPUTeam(team)
	for row in db:nrows("SELECT teamid FROM team WHERE name = '" .. team .. "'") do
		local updateGame = [[UPDATE game SET cpucontrolledteamid = ]] .. row.teamid..[[;]];
		db:exec(updateGame);
	end
end

local function updatePlayerTeam(team)
	for row in db:nrows("SELECT teamid FROM team WHERE name = '" .. team .. "'") do
		playerTeamId = row.teamid;
		local updateGame = [[UPDATE game SET playercontrolledteamid = ]]..playerTeamId..[[;]];
		db:exec(updateGame);
	end
	storyboard.gotoScene("roshamboscene", "fade", 400);
end

local function redButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = teamRed.x - (teamRed.width / 2);
		local maxX = teamRed.x + (teamRed.width / 2);
		local minY = teamRed.y - (teamRed.height / 2);
		local maxY = teamRed.y + (teamRed.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			updateCPUTeam("Blue");
			updatePlayerTeam("Red");
		end
	end
end

local function blueButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = teamBlue.x - (teamBlue.width / 2);
		local maxX = teamBlue.x + (teamBlue.width / 2);
		local minY = teamBlue.y - (teamBlue.height / 2);
		local maxY = teamBlue.y + (teamBlue.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			updateCPUTeam("Red");
			updatePlayerTeam("Blue");
		end
	end
end

function scene:createScene(event)
	local group = self.view;
	
	local titleLogo = display.newImageRect("images/qpLineUpBG.jpg", 480, 320);
	titleLogo.x = display.contentWidth / 2;
	titleLogo.y = display.contentHeight / 2;
	group:insert(titleLogo);
	
	local myFont = "BORG9";
	
	backToMain = widget.newButton
	{
		left = 0,
		top = 0;
		width = 20,
		height = 20,
		defaultFile = "images/backButton.png",
		overFile = "images/backButton.png",
		id = "backButton",
		onEvent = backButtonEvent,
	};
	backToMain.x = 15;
	backToMain.y = 15;
	group:insert(backToMain);
	
	play = widget.newButton
	{
		left = 0,
		top = 0;
		width = 150,
		height = 55,
		font = "BORG9",
		fontSize = 36,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "playButton",
		label = "Next",
		onEvent = playButtonEvent,
	};
	play.x = (display.contentWidth / 2);
	play.y = display.contentHeight - 30;
	play.name = "play";
	play.alpha = 0;
	group:insert(play);
	
	selectTeam = display.newText("Select your team", 0, 0, myFont, 36);
	selectTeam.x = display.contentWidth / 2;
	selectTeam.y = 50;
	group:insert(selectTeam);
	
	teamRed = widget.newButton
	{
		left = 0,
		top = 0;
		width = 150,
		height = 55,
		font = "BORG9",
		fontSize = 36,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "redButton",
		label = "Red",
		onEvent = redButtonEvent,
	};
	teamRed.x = 130;
	teamRed.y = display.contentHeight / 2;
	group:insert(teamRed);
	
	teamBlue = widget.newButton
	{
		left = 0,
		top = 0;
		width = 150,
		height = 55,
		font = "BORG9",
		fontSize = 36,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = "images/mainMenuItemBlue.png",
		overFile = "images/mainMenuItemOverBlue.png",
		id = "blueButton",
		label = "Blue",
		onEvent = blueButtonEvent,
	};
	teamBlue.x = display.contentWidth - 130;
	teamBlue.y = display.contentHeight / 2;
	group:insert(teamBlue);
	
	lineupone = display.newText("Lineup 1", 0, 0, myFont, 18);
	lineupone.x = 130;
	lineupone.y = 50;
	lineupone.alpha = 0;
	group:insert(lineupone);
	
	lineuptwo = display.newText("Lineup 2", 0, 0, myFont, 18);
	lineuptwo.x = display.contentWidth - 130;
	lineuptwo.y = 50;
	lineuptwo.alpha = 0;
	group:insert(lineuptwo);
	
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("qpresumescene");
end

function scene:exitScene(event)
end

function scene:didExitScene(event)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene);
scene:addEventListener("willEnterScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);
scene:addEventListener("didExitScene", scene);
scene:addEventListener("destroyScene", scene);

return scene;