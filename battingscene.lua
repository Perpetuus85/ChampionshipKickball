local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();
local physics = require("physics");

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path );  

local bx, by=0, 0 -- Create our variables for drawing the line
local lines={};
local colors, myHomePlate;
local pitchBall;
local buntButton, contactButton, powerButton, buttonGroup;
local countGroup;
local strikeOne, strikeTwo, ballOne, ballTwo, ballThree, foulOne, foulTwo, foulThree, outOne, outTwo;
local dx, dy;

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

local xRand, spawnCount;
local isStrike, touchKick;
local kickPower;

local resetPitch, removeTouchKickListener;

local function deletePitchBallAndGo()
	pitchBall:removeSelf();
	pitchBall = nil;
	physics.stop();
	storyboard.gotoScene("overworldscene", 
		{
			effect = "fade",
			time = 250,
			params = 
			{
				dirX = dx,
				dirY = dy,
				power = kickPower,
				prev = 'battingscene'
			}
		}
	);
end

local function onKickCollision(self, event)
	if(event.phase == "began" and event.other.myName == "pitchBall") then
		--Get the vector between self.x,self.y and event.other.x,event.other.y
		dx = event.other.x - self.x;
		dy = event.other.y - self.y;
		--print(self.myName .. ": collision with " .. event.other.myName);
		removeTouchKickListener();
		touchKick:removeSelf();
		touchKick = nil;		
		pitchBall:applyLinearImpulse(dx / 10, 0, pitchBall.x, pitchBall.y);
		--timer.performWithDelay(250, resetPitch);
		timer.performWithDelay(250, deletePitchBallAndGo);		
	end
end

local function touchKickBody(event)
	if(event.phase == "began") then
		--Add physics body at event.x,event.y
		if(touchKick ~= nil) then
			touchKick:removeSelf();
			touchKick = nil;
		end
		touchKick = display.newRect(0,0,50,50);
		touchKick.x = event.x;
		touchKick.y = event.y;
		touchKick.alpha = 0;
		--Power sets the bounce
		local myBounce;
		if(kickPower == 1) then
			myBounce = 0.1;
		elseif(kickPower == 2) then
			myBounce = 1.0;
		else
			myBounce = 2.0;
		end
		physics.addBody(touchKick, {density = 6.0, friction = 0, bounce = myBounce});
		touchKick.myName = "touchKick";
		--Physics body needs collision detection with pitchball
		touchKick.collision = onKickCollision;
		touchKick:addEventListener("collision", touchKick);
	elseif(event.phase == "moved") then
		--Move physics body to event.x,event.y
		if(touchKick ~= nil) then
			touchKick.x = event.x;
			touchKick.y = event.y;
		end
	elseif(event.phase == "ended") then
		--Remove physics body
		if(touchKick ~= nil) then
			touchKick:removeSelf();
			touchKick = nil;
		end
	end
	return true;
end

local function startTouchKickListener()
	Runtime:addEventListener("touch", touchKickBody);
end

removeTouchKickListener = function()
	Runtime:removeEventListener("touch", touchKickBody);
end

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
	spawnCount = spawnCount + 1;
	--print(spawnCount);
	if(spawnCount == 35) then
		--Create physics ball from pitchball
		physics.addBody(pitchBall, { radius=rad, density = 1.0, friction = 0.3, bounce = 0.2} );
		pitchBall.myName = "pitchBall";
		pitchBall:setLinearVelocity(0, 150);
	end
end

resetPitch = function(event)
	isStrike = nil;
	pitchBall:removeSelf();
	pitchBall = display.newCircle(display.contentWidth / 2 - 2, 110, 2);
	pitchBall:setFillColor(255,0,0);
	pitchBall.strokeWidth = 1;
	pitchBall:setStrokeColor(0,0,0);
	showKickButtons();
	showCountGroup();
end

local function goToScoreboard()
	storyboard.gotoScene("scoreboardscene", "fade", 400);
end

local function addOut()
	local currentOutCount, currentHalf, currentInning;
	for row in db:nrows("SELECT currentouts, currenthalf, currentinning FROM game") do
		currentOutCount = row.currentouts;
		currentHalf = row.currenthalf;
		currentInning = row.currentinning;
	end
	if(currentOutCount == 2) then
		--end inning, if half = 1 then 2 else increment inning set half to 1
		local setHalf, setInning;
		if(currentHalf == 1) then
			setHalf = 2;
			setInning = currentInning;
		else
			setHalf = 1;
			setInning = currentInning + 1;
		end
		print(setHalf);
		print(setInning);
		local updateCounts = [[UPDATE game SET currentouts = 0, currentballs = 0, currentstrikes = 0, currentfouls = 0, firstbaserunner = 0, secondbaserunner = 0, thirdbaserunner = 0, currenthalf = ]]..setHalf..[[, currentinning = ]]..setInning..[[;]];
		db:exec(updateCounts);
		timer.performWithDelay(1000, goToScoreboard);
	else
		--increment outs
		currentOutCount = currentOutCount + 1;
		local updateOuts = [[UPDATE game set currentouts = ]]..currentOutCount..[[;]];
		db:exec(updateOuts);
		--update display
		outOne.alpha = 1;
		if(currentOutCount > 1) then
			outTwo.alpha = 1;
		end
		--Then reset pitch
		timer.performWithDelay(1000, resetPitch);
	end
end

local function addStrike()
	local currentStrikeCount;
	for row in db:nrows("SELECT currentstrikes FROM game") do
		currentStrikeCount = row.currentstrikes;
	end
	if(currentStrikeCount == 2) then
		--It is an out
		--currentstrikes go to 0, currentballs go to 0, currentfouls go to 0
		local updateStrikes = [[UPDATE game SET currentstrikes = 0, currentballs = 0, currentfouls = 0]];
		db:exec(updateStrikes);
		--update display
		strikeOne.alpha = 0;
		strikeTwo.alpha = 0;
		foulOne.alpha = 0;
		foulTwo.alpha = 0;
		foulThree.alpha = 0;
		ballOne.alpha = 0;
		ballTwo.alpha = 0;
		ballThree.alpha = 0;
		--add out
		addOut();
	else
		currentStrikeCount = currentStrikeCount + 1;
		local updateStrikes = [[UPDATE game SET currentstrikes = ]]..currentStrikeCount..[[;]];
		db:exec(updateStrikes);
		if(currentStrikeCount > 0) then
			strikeOne.alpha = 1;
		end
		if(currentStrikeCount > 1) then
			strikeTwo.alpha = 1;
		end
		--Then reset pitch
		timer.performWithDelay(1000, resetPitch);
	end
end

local function addBall()
	local currentBallCount;
	for row in db:nrows("SELECT currentballs FROM game") do	
		currentBallCount = row.currentballs;
	end
	if(currentBallCount == 3) then
		--It is a walk
		local firstBaseRunner, secondBaseRunner, thirdBaseRunner;
		local currentkicker, currentHalf, awayScore, homeScore;
		local newKicker, newFirst, newSecond, newThird, newAway, newHome;
		for row in db:nrows("SELECT * FROM game") do
			firstBaseRunner = row.firstbaserunner;
			secondBaseRunner = row.secondbaserunner;
			thirdBaseRunner = row.thirdbaserunner;
			currentKicker = row.currentkicker;
			currentHalf = row.currenthalf;
			awayScore = row.awayscore;
			homeScore = row.homescore;
			newKicker = row.currentkicker;
			newFirst = row.firstbaserunner;
			newSecond = row.secondbaserunner;
			newThird = row.thirdbaserunner;
			newAway = row.awayscore;
			newHome = row.homescore;
		end
		--if thirdbaserunner ~= 0 then increase score by 1
		if(thirdBaseRunner ~= 0) then
			if(currentHalf == 1) then
				--increase away
				newAway = awayScore + 1;
			else
				--increase home
				newHome = homeScore + 1;
			end
		end
		--if secondbaserunner ~= 0 then thirdbaserunner = secondbaserunner
		if(secondBaseRunner ~= 0) then
			newThird = secondBaseRunner;
		end
		--if firstbaserunner ~= 0 then secondbaserunner = firstbaserunner
		if(firstBaseRunner ~= 0) then
			newSecond = firstBaseRunner;
		end
		--firstbaserunner = currentkicker
		newFirst = currentKicker
		--reset counts
		local updateItems = [[UPDATE game SET currentstrikes = 0, currentfouls = 0, currentballs = 0, currentkicker = ]]..newKicker..[[, firstbaserunner = ]]..newFirst..[[, secondbaserunner = ]]..newSecond..[[, thirdbaserunner = ]]..newThird..[[, awayscore = ]]..newAway..[[, homescore = ]]..newHome..[[;]];
		db:exec(updateItems);
		--update display
		
		--reset pitch
		timer.performWithDelay(1000, resetPitch);
	else
		currentBallCount = currentBallCount + 1;
		local updateBalls = [[UPDATE game SET currentballs = ]]..currentBallCount..[[;]];
		db:exec(updateBalls);
		ballOne.alpha = 1;
		if(currentBallCount > 1) then
			ballTwo.alpha = 1;
		end
		if(currentBallCount > 2) then
			ballThree.alpha = 1;
		end
		--Then reset pitch
		timer.performWithDelay(1000, resetPitch);
	end
end

local function onLocalCollision(self, event)
	if(event.phase == "began") then
		--print(self.myName .. ": collision began with " .. event.other.myName);
		if(self.myName == "endOfPitchLine" and event.other.myName == "pitchBall") then
			--Check if strike else ball
			if(isStrike ~= nil and isStrike == true) then
				--Display strike
				print("STRIKE");
				--Update strike count and display
				addStrike();
			else
				--Display ball
				print("BALL");
				--Update ball count and display
				addBall();
			end
			if(touchKick ~= nil) then
				removeTouchKickListener();
				touchKick:removeSelf();
				touchKick = nil;				
			end
		elseif(self.myName == "pHomePlate" and event.other.myName == "pitchBall") then
			--It is a strike
			isStrike = true;
		end
	end
end



local function pitch(event)
	xRand = math.random(-300, 300);
	spawnCount = 0;
	timer.performWithDelay(16, spawnBall, 35);
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
			startTouchKickListener();
			--Set power to bunt
			kickPower = 1;
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
			startTouchKickListener();
			--Set power to contact
			kickPower = 2;
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
			startTouchKickListener();
			--Set power to power
			kickPower = 3;
			timer.performWithDelay(1000, pitch);
		end
	end
end

local function paintPoly(poly, xoffset, yoffset, rgba)
 
    local newLine = display.newLine
    local math_floor = math.floor
    local math_min = math.min
    local math_max = math.max
    local polyGroup = display.newGroup()
 
    local n = #poly
 
    local minY = poly[1].y
    local maxY = poly[1].y
 
    for i = 2, n do
        minY = math_min(minY, poly[i].y)
        maxY = math_max(maxY, poly[i].y)
    end
 
    for y = minY, maxY do
 
        local ints = {}
        local int = 0
        local last = n
 
        for i = 1, n do
            local y1 = poly[last].y
            local y2 = poly[i].y
            if y1 < y2 then
                local x1 = poly[last].x
                local x2 = poly[i].x
                if (y >= y1) and (y < y2) then
                    int = int + 1
                    ints[int] = math_floor((y - y1) * (x2 - x1) / (y2 - y1) + x1)
                end
            elseif y1 > y2 then
                local x1 = poly[last].x
                local x2 = poly[i].x
                if (y >= y2) and (y < y1) then
                    int = int + 1
                    ints[int] = math_floor((y - y2) * (x1 - x2) / (y1 - y2) + x2)
                end
            end
            last = i
        end
 
        local i = 1
        while i < int do
            local line = newLine(ints[i] + xoffset, y + yoffset, ints[i + 1] + xoffset, y + yoffset)
            polyGroup:insert(line)
            line:setColor(rgba[1], rgba[2], rgba[3], rgba[4])
            i = i + 2
        end
    end
 
    return polyGroup
end

function scene:createScene(event)
	physics.start();
	physics.setGravity(0,0);
	physics.setDrawMode("hybrid");
	
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
	
	local countBG = display.newRect(display.contentWidth - 120, 0, 120, 80);
	countBG:setFillColor(0,0,0);
	countBG.alpha = 0.65;
	countGroup:insert(countBG);
	
	local basesBG = display.newRect(0,0,120,80);
	basesBG:setFillColor(0,0,0);
	basesBG.alpha = 0.65;
	countGroup:insert(basesBG);
	
	local scoreBG = display.newRect(120,0,display.contentWidth - 240, 21);
	scoreBG:setFillColor(0,0,0);
	scoreBG.alpha = 0.65;
	countGroup:insert(scoreBG);
	
	local firstBaseRunner, secondBaseRunner, thirdBaseRunner;
	local currentOuts, currentFouls, currentStrikes, currentBalls;
	local homeScore, awayScore, homeTeamName, awayTeamName;
	local currentInning, currentHalf;
	for row in db:nrows("SELECT * FROM game") do 
		firstBaseRunner = row.firstbaserunner;
		secondBaseRunner = row.secondbaserunner;
		thirdBaseRunner = row.thirdbaserunner;
		currentOuts = row.currentouts;
		currentFouls = row.currentfouls;
		currentStrikes = row.currentstrikes;
		currentBalls = row.currentballs;
		homeScore = row.homescore;
		awayScore = row.awayscore;
		currentInning = row.currentinning;
		currentHalf = row.currenthalf;
	end
	row = nil;
	for row in db:nrows("SELECT t.name FROM game AS g JOIN team AS t ON t.teamid = g.hometeamid") do
		homeTeamName = row.name;
	end
	row = nil;
	for row in db:nrows("SELECT t.name FROM game AS g JOIN team AS t ON t.teamid = g.awayteamid") do
		awayTeamName = row.name;
	end
	row = nil;
	
	local scoreTotals = display.newText(awayTeamName .. " " .. awayScore .. " | " .. homeTeamName .. " " .. homeScore, 0,0,pokeFont, 10);
	scoreTotals.x = display.contentWidth / 2;
	scoreTotals.y = 11;
	countGroup:insert(scoreTotals);
	
	if(currentHalf == 1) then
		currentHalf = 'Top';
	else
		currentHalf = 'Bot';
	end
	
	local inningStatus = display.newText(currentHalf .. ' ' .. currentInning, 0, 0, pokeFont, 10);
	inningStatus.x = basesBG.x;
	inningStatus.y = basesBG.y + (basesBG.height / 2) - 11;
	countGroup:insert(inningStatus);
	
	local firstBase = display.newRect(0,0,20,20);
	firstBase.x = 80;
	firstBase.y = 35;
	if(firstBaseRunner == 0) then
		firstBase:setFillColor(255,255,255);
		firstBase.alpha = 0.3;
	else
		firstBase:setFillColor(255,215,0);
		firstBase.alpha = 1;
	end
	firstBase:rotate(45);
	countGroup:insert(firstBase);
	
	local secondBase = display.newRect(0,0,20,20);
	secondBase.x = 60;
	secondBase.y = 15;
	if(secondBaseRunner == 0) then
		secondBase:setFillColor(255,255,255);
		secondBase.alpha = 0.3;
	else
		secondBase:setFillColor(255,215,0);
		secondBase.alpha = 1;
	end
	secondBase:rotate(45);
	countGroup:insert(secondBase);
	
	local thirdBase = display.newRect(0,0,20,20);
	thirdBase.x = 40;
	thirdBase.y = 35;
	if(thirdBaseRunner == 0) then
		thirdBase:setFillColor(255,255,255);
		thirdBase.alpha = 0.3;
	else
		thirdBase:setFillColor(255,215,0);
		thirdBase.alpha = 1;
	end
	thirdBase:rotate(45);
	countGroup:insert(thirdBase);
	
	local homePlateShape =
	{
	{x=53, y=60},
	{x=67, y=60},
	{x=67, y=65},
	{x=60, y=72},
	{x=53, y=65}
	};
	
	local homePlatePoly = paintPoly(homePlateShape, 0, -15, {255,255,255,255});
	countGroup:insert(homePlatePoly);
	
	local ballCount = display.newText("Balls: ", display.contentWidth - 117, 0, pokeFont, 10);
	ballCount.y = 10;
	countGroup:insert(ballCount);
	
	ballOne = display.newCircle(ballCount.x + 33, ballCount.y, 5);
	ballOne:setFillColor(255,255,255);
	if(currentBalls > 0) then
		ballOne.alpha = 1;
	else
		ballOne.alpha = 0;
	end
	countGroup:insert(ballOne);
	
	ballTwo = display.newCircle(ballCount.x + 49, ballCount.y, 5);
	ballTwo:setFillColor(255,255,255);
	if(currentBalls > 1) then
		ballTwo.alpha = 1;
	else
		ballTwo.alpha = 0;
	end
	countGroup:insert(ballTwo);
	
	ballThree = display.newCircle(ballCount.x + 65, ballCount.y, 5);
	ballThree:setFillColor(255,255,255);
	if(currentBalls > 2) then
		ballThree.alpha = 1;
	else
		ballThree.alpha = 0;
	end
	countGroup:insert(ballThree);
	
	local strikeCount = display.newText("Strikes: ", display.contentWidth - 117, 0, pokeFont, 10);
	strikeCount.y = 30;
	countGroup:insert(strikeCount);
	
	strikeOne = display.newCircle(strikeCount.x + 40, strikeCount.y, 5);
	strikeOne:setFillColor(255,255,255);
	if(currentStrikes > 0) then
		strikeOne.alpha = 1;
	else
		strikeOne.alpha = 0;
	end
	countGroup:insert(strikeOne);
	
	strikeTwo = display.newCircle(strikeCount.x + 56, strikeCount.y, 5);
	strikeTwo:setFillColor(255,255,255);
	if(currentStrikes > 1) then
		strikeTwo.alpha = 1;
	else
		strikeTwo.alpha = 0;
	end
	countGroup:insert(strikeTwo);
	
	local foulCount = display.newText("Fouls: ", display.contentWidth - 117, 0, pokeFont, 10);
	foulCount.y = 50;
	countGroup:insert(foulCount);
	
	foulOne = display.newCircle(foulCount.x + 33, foulCount.y, 5);
	foulOne:setFillColor(255,255,255);
	if(currentFouls > 0) then
		foulOne.alpha = 1;
	else
		foulOne.alpha = 0;
	end
	countGroup:insert(foulOne);
	
	foulTwo = display.newCircle(foulCount.x + 49, foulCount.y, 5);
	foulTwo:setFillColor(255,255,255);
	if(currentFouls > 1) then
		foulTwo.alpha = 1;
	else
		foulTwo.alpha = 0;
	end
	countGroup:insert(foulTwo);
	
	foulThree = display.newCircle(foulCount.x + 65, foulCount.y, 5);
	foulThree:setFillColor(255,255,255);
	if(currentFouls > 2) then
		foulThree.alpha = 1;
	else
		foulThree.alpha = 0;
	end
	countGroup:insert(foulThree);
	
	local outCount = display.newText("Outs: ", display.contentWidth - 117, 0, pokeFont, 10);
	outCount.y = 70;
	countGroup:insert(outCount);
	
	outOne = display.newCircle(outCount.x + 25, outCount.y, 5);
	outOne:setFillColor(255,255,255);
	if(currentOuts > 0) then
		outOne.alpha = 1;
	else
		outOne.alpha = 0;
	end
	countGroup:insert(outOne);
	
	outTwo = display.newCircle(outCount.x + 41, outCount.y, 5);
	outTwo:setFillColor(255,255,255);
	if(currentOuts > 1) then
		outTwo.alpha = 1;
	else
		outTwo.alpha = 0;
	end
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
	
	local endOfPitchLine = display.newRect(0, display.contentHeight + 75, display.contentWidth, 5);
	group:insert(endOfPitchLine);
	
	physics.addBody(endOfPitchLine, {density = 1.0, friction = 0.3, bounce = 0.2, isSensor = true});
	endOfPitchLine.myName = "endOfPitchLine";
	endOfPitchLine.collision = onLocalCollision;
	endOfPitchLine:addEventListener("collision", endOfPitchLine);
	
	local pHomePlate = display.newRect(0,0,110,5);
	pHomePlate.x = display.contentWidth / 2;
	pHomePlate.y = display.contentHeight - 55;
	pHomePlate.alpha = 0;
	group:insert(pHomePlate);
	
	physics.addBody(pHomePlate, {density = 1.0, friction = 0.3, bounce = 0.2, isSensor = true});
	pHomePlate.myName = "pHomePlate";
	pHomePlate.collision = onLocalCollision;
	pHomePlate:addEventListener("collision", pHomePlate);
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("qplineupscene");
	storyboard.purgeScene("qpresumescene");
	storyboard.purgeScene("scoreboardscene");
	storyboard.purgeScene("overworldscene");
	
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