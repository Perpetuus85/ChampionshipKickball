local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path ); 

local myFont, nextButton;

local function nextButtonTouch(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
			
		local minX = nextButton.x - (nextButton.width / 2);
		local maxX = nextButton.x + (nextButton.width / 2);
		local minY = nextButton.y - (nextButton.height / 2);
		local maxY = nextButton.y + (nextButton.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			-- go to appropriate screen
			-- if top and player = away or bottom and player = home -> batting
			-- if bottom and player = away or top and player = home -> field
			local getInfo = "SELECT currenthalf, awayteamid, playercontrolledteamid FROM game";
			local goToScene = "";
			for row in db:nrows(getInfo) do
				if(row.currenthalf == 1) then
					if(row.awayteamid == row.playercontrolledteamid) then
						goToScene = "battingscene";
					else
						goToScene = "pitchingscene";
					end
				else
					if(row.awayteamid == row.playercontrolledteamid) then
						goToScene = "pitchingscene";
					else
						goToScene = "battingscene";
					end
				end
			end
			storyboard.gotoScene(goToScene, "fade", 400);
		end
	end
end

function scene:createScene(event)
	local group = self.view;
	if "Win" == system.getInfo("platformName") then
		myFont = "Pokemon GB"
	else
		myFont = "PokemonGB"
	end
	local getHome = "SELECT t.name from team as t " ..
					"JOIN game as g ON g.hometeamid = t.teamid ";
	local homeTeamName = "";
	for row in db:nrows(getHome) do
		homeTeamName = row.name;
	end
	local getAway = "SELECT t.name from team as t " ..
					"JOIN game as g on g.awayteamid = t.teamid ";
	local awayTeamName = "";
	for row in db:nrows(getAway) do
		awayTeamName = row.name;
	end
	local getGameInfo = "SELECT currentinning, currenthalf, awayscore, homescore from game";
	local topOrBottom = "";
	local curInning = "";
	local awayScore = ""; 
	local homeScore = "";
	for row in db:nrows(getGameInfo) do
		curInning = row.currentinning;
		if(row.currenthalf == 1) then
			topOrBottom = "Top";
		else
			topOrBottom = "Bottom";
		end
		awayScore = row.awayscore;
		homeScore = row.homescore;
	end
	
	local inningStr = topOrBottom .. " " .. curInning;
	local inningDis = display.newText(inningStr, display.contentWidth / 2, 40, myFont, 16);
	inningDis.x = display.contentWidth / 2;
	group:insert(inningDis);
	
	local awayTeamDis = display.newText(awayTeamName, 0, 210, myFont, 18);
	awayTeamDis.x = (display.contentWidth / 2) - 90;
	awayTeamDis.y = display.contentHeight / 2 + 20;
	group:insert(awayTeamDis);
	
	local awayTeamScore = display.newText(awayScore, 0, display.contentHeight / 2, myFont, 36);
	awayTeamScore.x = (display.contentWidth / 2) - 90;
	awayTeamScore.y = display.contentHeight / 2 - 20;
	group:insert(awayTeamScore);
	
	local homeTeamDis = display.newText(homeTeamName, 0, 210, myFont, 18);
	homeTeamDis.x = (display.contentWidth / 2) + 90;
	homeTeamDis.y = display.contentHeight / 2 + 20;
	group:insert(homeTeamDis);
	
	local homeTeamScore = display.newText(homeScore, 0, display.contentHeight / 2, myFont, 36);
	homeTeamScore.x = (display.contentWidth / 2) + 90;
	homeTeamScore.y = display.contentHeight / 2 - 20;
	group:insert(homeTeamScore);
	
	nextButton = widget.newButton
	{
		left = 0,
		top = 0;
		width = 150,
		height = 45,
		font = "BORG9",
		fontSize = 24,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "nextButton",
		label = "Go",
		onEvent = nextButtonTouch,
	};
	nextButton.x = display.contentWidth / 2;
	nextButton.y = display.contentHeight - 40;
	group:insert(nextButton);
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
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