local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();
local quickPlay, help, settings;

local function quickPlayEvent(event)
	if(event.phase == "began") then
	elseif (event.phase == "ended" or event.phase == "cancelled") then
		local minX = quickPlay.x - (quickPlay.width / 2);
		local maxX = quickPlay.x + (quickPlay.width / 2);
		local minY = quickPlay.y - (quickPlay.height / 2);
		local maxY = quickPlay.y + (quickPlay.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
				event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
				storyboard.gotoScene("qpresumescene", "fade", 400);
				--storyboard.gotoScene("battingscene", "fade", 400);
		end
	end
end

local function helpEvent(event)
	if(event.phase == "began") then
	elseif (event.phase == "ended" or event.phase == "cancelled") then
		local minX = help.x - (help.width / 2);
		local maxX = help.x + (help.width / 2);
		local minY = help.y - (help.height / 2);
		local maxY = help.y + (help.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
				print("Go to help screen");
		end
	end
end

local function settingsEvent(event)
	if(event.phase == "began") then
	elseif (event.phase == "ended" or event.phase == "cancelled") then
		local minX = settings.x - (settings.width / 2);
		local maxX = settings.x + (settings.width / 2);
		local minY = settings.y - (settings.height / 2);
		local maxY = settings.y + (settings.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
				event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
				print("Go to settings screen");
		end
	end
end

function scene:createScene(event)

	local group = self.view;
	
	local titleLogo = display.newImageRect("images/fieldBase.jpg", 480, 320);
	titleLogo.x = display.contentWidth / 2;
	titleLogo.y = display.contentHeight / 2;
	group:insert(titleLogo);
	
	local myFont = "BORG9";
	
	quickPlay = widget.newButton
	{
		left = 0,
		top = 0;
		width = 210,
		height = 45,
		font = myFont,
		fontSize = 24,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "quickPlayButton",
		label = "Quick Play",
		onEvent = quickPlayEvent,
	};
	quickPlay.x = display.contentWidth / 2;
	quickPlay.y = display.contentHeight - 154;
	group:insert(quickPlay);
	
	settings = widget.newButton
	{
		left = 0,
		top = 0;
		width = 210,
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
		id = "settingsButton",
		label = "Settings",
		onEvent = settingsEvent,
	};
	settings.x = display.contentWidth / 2;
	settings.y = display.contentHeight - 102;
	group:insert(settings);
	
	help = widget.newButton
	{
		left = 0,
		top = 0;
		width = 210,
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
		id = "helpButton",
		label = "Help",
		onEvent = helpEvent,
	};
	help.x = display.contentWidth / 2;
	help.y = display.contentHeight - 50;
	group:insert(help);
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("logoscene");
	storyboard.purgeScene("qplineupscene");
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