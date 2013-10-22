local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path );  

local backToMain, play, resume, createResume;

local function newGameEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "cancelled" or event.phase == "ended") then
		local minX = play.x - (play.width / 2);
		local maxX = play.x + (play.width / 2);
		local minY = play.y - (play.height / 2);
		local maxY = play.y + (play.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
				event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
				storyboard.gotoScene("createnewgamescene", "fade", 400);
		end
	end
end

local function resumeEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = resume.x - (resume.width / 2);
		local maxX = resume.x + (resume.width / 2);
		local minY = resume.y - (resume.height / 2);
		local maxY = resume.y + (resume.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
				event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
				local nextScene = "";
				for row in db:nrows("select * from game") do
					if(row.playercontrolledteamid == 0) then
						nextScene = "qplineupscene";
					elseif(row.hometeamid == 0) then
						nextScene = "roshamboscene";
					elseif(row.playercontrolledteamid == row.hometeamid and row.currenthalf == 2) then
						nextScene = "battingscene";
					else
						nextScene = "pitchingscene";
					end
				end
				storyboard.gotoScene(nextScene, "fade", 400);
		end
	end
end

local function onComplete(event)
	if "clicked" == event.action then
		local i = event.index
		if 1 == i then
		elseif 2 == i then
			storyboard.gotoScene("titlescene", "fade", 400);
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
			local alert = native.showAlert("Back", "Would you like to return to the main menu?", {"No", "Yes"}, onComplete);
		end
	end
end

function scene:createScene(event)
	local group = self.view;
	
	--local titleLogo = display.newImageRect("images/qpLineUpBG.jpg", 480, 320);
	--titleLogo.x = display.contentWidth / 2;
	--titleLogo.y = display.contentHeight / 2;
	local titleLogo = display.newRect(0,0,display.contentWidth, display.contentHeight);
	titleLogo:setFillColor(0,0,0);
	group:insert(titleLogo);
	
	local myFont = "BORG9";
	
	backToMain = widget.newButton
	{
		left = 0,
		top = 0;
		width = 20,
		height = 20,
		font = "BORG9",
		defaultFile = "images/backButton.png",
		overFile = "images/backButton.png",
		id = "backButton",
		onEvent = backButtonEvent,
	};
	backToMain.x = 15;
	backToMain.y = 15;
	backToMain.name = "backToMain";
	group:insert(backToMain);
	
	local quickPlay = display.newText("QUICK PLAY", 0, 0, myFont, 48);
	quickPlay.x = display.contentWidth / 2;
	quickPlay.y = 50;
	group:insert(quickPlay);
	
	local resumeOffset = 0;
	createResume = false;
	for row in db:nrows("SELECT COUNT(*) as numOfRows FROM game") do
		if(row.numOfRows > 0) then
			createResume = true;
		end
	end
	if(createResume == true) then
		resumeOffset = 60;
		resume = widget.newButton
		{
			left = 0,
			top = 0;
			width = 290,
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
			id = "resumeButton",
			label = "Resume",
			onEvent = resumeEvent,
		};
		resume.x = display.contentWidth / 2;
		resume.y = display.contentHeight / 2;
		group:insert(resume);
	end
	
	play = widget.newButton
	{
		left = 0,
		top = 0;
		width = 290,
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
		id = "newGameButton",
		label = "New Game",
		onEvent = newGameEvent,
	};
	play.x = (display.contentWidth / 2);
	play.y = (display.contentHeight / 2) + resumeOffset;
	group:insert(play);
	
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("titlescene");
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