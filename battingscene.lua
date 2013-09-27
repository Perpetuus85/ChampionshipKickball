local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();

local bx, by=0, 0 -- Create our variables for drawing the line
local lines={};
local colors, myHomePlate;
local pitchBall;
local buntButton, contactButton, powerButton, buttonGroup;
local countGroup;
local strikeOne, strikeTwo, ballOne, ballTwo, ballThree, foulOne, foulTwo, foulThree, outOne, outTwo;

local function hideKickButtons()
	buttonGroup.alpha = 0;
end

local function showKickButtons()
	buttonGroup.alpha = 1;
end

local function hideCountGroup()
	countGroup.alpha = 0;
end

local function showCountGroup()
	countGroup.alpha = 1;
end

local function fruitNinja(event)
        if "began"==event.phase then
                bx, by=event.x, event.y
        elseif "moved"==event.phase then
                for i=#lines+1, #lines+1 do
                        lines[i]=display.newLine(bx, by, event.x, event.y)
                        lines[i]:setColor(0, 0, 255)
                        lines[i].width=18
                        local me=lines[i]
                lines[i].transition=transition.to(me, {alpha=0, width=1,  time=300}) -- The key transition
                bx, by=event.x, event.y
                timer.performWithDelay(300, function() me:removeSelf() me=nil end) -- Don't forget to destroy and nil the lines!
          end
  elseif "ended"==event.phase then
        
        end
end

local xRand;

local function spawnBall(event)
	local x = pitchBall.x;
	local y = pitchBall.y;
	local rad = pitchBall.width / 2 - 1;
	--print("Before " .. rad); 
	pitchBall:removeSelf();
	pitchBall = display.newCircle(x + (xRand / 93), y + ((display.contentHeight - 100) / 93), rad + (28/93));
	--print("After " .. pitchBall.width / 2);
	pitchBall:setFillColor(255,0,0);
	pitchBall.strokeWidth = 1;
	pitchBall:setStrokeColor(0,0,0);
end

local function resetPitch(event)
	pitchBall:removeSelf();
	pitchBall = display.newCircle(display.contentWidth / 2 - 2, 110, 2);
	pitchBall:setFillColor(255,0,0);
	pitchBall.strokeWidth = 1;
	pitchBall:setStrokeColor(0,0,0);
	showKickButtons();
	showCountGroup();
end


local function pitch(event)
	xRand = math.random(-200, 200);
	timer.performWithDelay(16, spawnBall, 93);
	timer.performWithDelay(5000, resetPitch);
end

local function buntButtonTouch(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
			
		local minX = buntButton.x - (buntButton.width / 2);
		local maxX = buntButton.x + (buntButton.width / 2);
		local minY = buntButton.y - (buntButton.height / 2);
		local maxY = buntButton.y + (buntButton.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			hideKickButtons();
			hideCountGroup();
			timer.performWithDelay(1000, pitch);
		end
	end
end

local function contactButtonTouch(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
			
		local minX = contactButton.x - (contactButton.width / 2);
		local maxX = contactButton.x + (contactButton.width / 2);
		local minY = contactButton.y - (contactButton.height / 2);
		local maxY = contactButton.y + (contactButton.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			hideKickButtons();
			hideCountGroup();
			timer.performWithDelay(1000, pitch);
		end
	end
end

local function powerButtonTouch(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
			
		local minX = powerButton.x - (powerButton.width / 2);
		local maxX = powerButton.x + (powerButton.width / 2);
		local minY = powerButton.y - (powerButton.height / 2);
		local maxY = powerButton.y + (powerButton.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			hideKickButtons();
			hideCountGroup();
			timer.performWithDelay(1000, pitch);
		end
	end
end

function scene:createScene(event)
	local group = self.view;
	
	local titleLogo = display.newImageRect("images/battingBG.jpg", 480, 320);
	titleLogo.x = display.contentWidth / 2;
	titleLogo.y = display.contentHeight / 2;
	group:insert(titleLogo);
	
	local myFont = "BORG9";
	local pokeFont;
	if "Win" == system.getInfo("platformName") then
		pokeFont = "Pokemon GB"
	else
		pokeFont = "PokemonGB"
	end
	
	pitchBall = display.newCircle(display.contentWidth / 2 - 2, 110, 2);
	pitchBall:setFillColor(255,0,0);
	pitchBall.strokeWidth = 1;
	pitchBall:setStrokeColor(0,0,0);
	group:insert(pitchBall);
	
	countGroup = display.newGroup();
	
	local countBG = display.newRoundedRect(display.contentWidth - 120, 0, 120, 80, 3);
	countBG:setFillColor(0,0,0);
	countBG.alpha = 0.5;
	countGroup:insert(countBG);
	
	local ballCount = display.newText("Balls: ", display.contentWidth - 117, 0, pokeFont, 10);
	ballCount.y = 10;
	countGroup:insert(ballCount);
	
	ballOne = display.newCircle(ballCount.x + 33, ballCount.y, 5);
	ballOne:setFillColor(255,255,255);
	ballOne.alpha = 0;
	countGroup:insert(ballOne);
	
	ballTwo = display.newCircle(ballCount.x + 49, ballCount.y, 5);
	ballTwo:setFillColor(255,255,255);
	ballTwo.alpha = 0;
	countGroup:insert(ballTwo);
	
	ballThree = display.newCircle(ballCount.x + 65, ballCount.y, 5);
	ballThree:setFillColor(255,255,255);
	ballThree.alpha = 0;
	countGroup:insert(ballThree);
	
	local strikeCount = display.newText("Strikes: ", display.contentWidth - 117, 0, pokeFont, 10);
	strikeCount.y = 30;
	countGroup:insert(strikeCount);
	
	strikeOne = display.newCircle(strikeCount.x + 40, strikeCount.y, 5);
	strikeOne:setFillColor(255,255,255);
	strikeOne.alpha = 0;
	countGroup:insert(strikeOne);
	
	strikeTwo = display.newCircle(strikeCount.x + 56, strikeCount.y, 5);
	strikeTwo:setFillColor(255,255,255);
	strikeTwo.alpha = 0;
	countGroup:insert(strikeTwo);
	
	local foulCount = display.newText("Fouls: ", display.contentWidth - 117, 0, pokeFont, 10);
	foulCount.y = 50;
	countGroup:insert(foulCount);
	
	foulOne = display.newCircle(foulCount.x + 33, foulCount.y, 5);
	foulOne:setFillColor(255,255,255);
	foulOne.alpha = 0;
	countGroup:insert(foulOne);
	
	foulTwo = display.newCircle(foulCount.x + 49, foulCount.y, 5);
	foulTwo:setFillColor(255,255,255);
	foulTwo.alpha = 0;
	countGroup:insert(foulTwo);
	
	foulThree = display.newCircle(foulCount.x + 65, foulCount.y, 5);
	foulThree:setFillColor(255,255,255);
	foulThree.alpha = 0;
	countGroup:insert(foulThree);
	
	local outCount = display.newText("Outs: ", display.contentWidth - 117, 0, pokeFont, 10);
	outCount.y = 70;
	countGroup:insert(outCount);
	
	outOne = display.newCircle(outCount.x + 25, outCount.y, 5);
	outOne:setFillColor(255,255,255);
	outOne.alpha = 0;
	countGroup:insert(outOne);
	
	outTwo = display.newCircle(outCount.x + 41, outCount.y, 5);
	outTwo:setFillColor(255,255,255);
	outTwo.alpha = 0;
	countGroup:insert(outTwo);
	
	group:insert(countGroup);
	
	buttonGroup = display.newGroup();
	
	buntButton = widget.newButton
	{
		top = 0,
		left = 0,
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
		id = "buntButton",
		label = "Bunt",
		onEvent = buntButtonTouch,
	};
	buntButton.x = display.contentWidth - 100;
	buntButton.y = 140;
	buttonGroup:insert(buntButton);
	
	contactButton = widget.newButton
	{
		top = 0,
		left = 0,
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
		id = "contactButton",
		label = "Contact",
		onEvent = contactButtonTouch,
	};
	contactButton.x = display.contentWidth - 100;
	contactButton.y = 190;
	buttonGroup:insert(contactButton);
	
	powerButton = widget.newButton
	{
		top = 0,
		left = 0,
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
		id = "powerButton",
		label = "Power",
		onEvent = powerButtonTouch,
	};
	powerButton.x = display.contentWidth - 100;
	powerButton.y = 240;
	buttonGroup:insert(powerButton);
	
	group:insert(buttonGroup);
	
	--timer.performWithDelay(7000, pitch, 0);
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("qplineupscene");
	storyboard.purgeScene("qpresumescene");
	storyboard.purgeScene("scoreboardscene");
	Runtime:addEventListener("touch", fruitNinja);
end

function scene:exitScene(event)
	Runtime:removeEventListener("touch", fruitNinja)
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