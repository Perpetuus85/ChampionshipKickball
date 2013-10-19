local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path );  


local dirX, dirY, power, kickBall;
local physics = require("physics");
local distX, distY, prevScene;
local moveBallUp, moveBallDown, moveBallRoll;
local randomAngle;
local myScaleXY;
local ballUpTime, ballDownTime, ballRollTime;
local distAirX, distAirY;
local distRollX, distRollY;
local kickAngle;
local fieldIsCPU;
local p, c, b1, b2, b3, ss, lf, lcf, cf, rcf, rf;
local playerTable;
local createPlayer;
local closestPlayer, goToPreviousScene;
local firstBase, secondBase, thirdBase;
local kicker;
local transitionClosestToKickball;

local function goToScoreboard()
	storyboard.gotoScene("scoreboardscene", "fade", 400);
end

transitionClosestToKickball = function()
	if(kickBall.pickedUp == false)
		--create transition for closestPlayer towards kickball, on complete call this function
		local kX = kickBall.x;
		local kY = kickBall.y;
		local pX = closestPlayer.x;
		local pY = closestPlayer.y;
		local h = 2;
		local y = math.abs(kY-pY);
		local angle = math.deg(math.asin(y / h));
		local myDistY = 2 * math.sin(math.rad(angle));
		local myDistX = 2 - myDistY;
		--moving at 10 pps calculate distance moved over 200 ms towards kX,kY in X,Y direction
		closestPlayer.myTrans = transition.to(closestPlayer, {time = 200,
	end
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
		--increment outs and change kicker
		currentOutCount = currentOutCount + 1;
		local updateOuts = [[UPDATE game set currentouts = ]]..currentOutCount..[[, currentballs = 0, currentstrikes = 0, currentfouls = 0;]];
		db:exec(updateOuts);
		timer.performWithDelay(1000, goToPreviousScene);
	end
end

local function listener3(obj)
	--print('Player arrived at ball landing spot');
end

local function getClosestFielderToMove()
	local landX, landY;
	landX = (display.contentWidth / 2) + distAirX;
	--print('landX ' .. landX);
	landY = (display.contentHeight - 20) + distAirY;
	--print('landY ' .. landY);
	--True distance = square root of ((abs value of diff(landX,playerX))^2 + (abs value of diff(landY, playerY))^2)
	closestPlayer = nil;
	local minDistance = nil;
	for i=1,playerTable.numChildren do
		if(closestPlayer == nil) then
			closestPlayer = playerTable[i];
		end
		if(minDistance == nil) then
			minDistance = math.sqrt(math.abs(landX - playerTable[i].x)^2 + math.abs(landY - playerTable[i].y)^2);
		end
		
		if(closestPlayer ~= playerTable[i]) then
			local compDist = math.sqrt(math.abs(landX - playerTable[i].x)^2 + math.abs(landY - playerTable[i].y)^2);
			--print('Player at ' .. playerTable[i].pos .. ' is ' .. compDist .. ' away');
			--print('PlayerX ' .. playerTable[i].x);
			--print('PlayerY ' .. playerTable[i].y);
			if(compDist < minDistance) then
				minDistance = compDist;
				closestPlayer = playerTable[i];
			end
			compDist = nil;
		end
	end
	print('Closest Player ' .. closestPlayer.pos);
	--move closest player to landx,landy at 10 pixels / second
	local totalMS = minDistance / 10 * 1000;
	closestPlayer.myTrans = transition.to(closestPlayer, {time = totalMS, x = landX, y = landY, onComplete = listener3});
	
	--move b3 to 3B if not closest player
	if(closestPlayer.pos ~= '3B') then
		--get distance of b3 to thirdbase
		local b3Dist = math.sqrt(math.abs(b3.x - (thirdBase.x + 4))^2 + math.abs(b3.y - (thirdBase.y))^2);
		--calculate time at 10 pps
		local b3Time = b3Dist / 10 * 1000;
		--transition
		b3.myTrans = transition.to(b3, {time = b3Time, x = thirdBase.x + 4, y = thirdBase.y});
	end;
	
	if(landX > display.contentWidth / 2) then
		--move ss to 2B if not closest player and land.x > display.contentWidth / 2
		if(closestPlayer.pos ~= 'SS') then
			local ssDist = math.sqrt(math.abs(ss.x - (secondBase.x))^2 + math.abs(ss.y - (secondBase.y + 4))^2);
			local ssTime = ssDist / 15 * 1000;
			ss.myTrans = transition.to(ss, {time = ssTime, x = secondBase.x, y = secondBase.y + 4});
		end
	else
		--move b2 to 2B if not closest player and land.y <= display.contentWidth / 2
		if(closestPlayer.pos ~= '2B') then
			local b2Dist = math.sqrt(math.abs(b2.x - (secondBase.x))^2 + math.abs(b2.y - (secondBase.y + 4))^2);
			local b2Time = b2Dist / 15 * 1000;
			b2.myTrans = transition.to(b2, {time = b2Time, x = secondBase.x, y = secondBase.y + 4});
		end
	end
	
	--move b1 to 1B if not closest player
	if(closestPlayer.pos ~= '1B') then
		--get distance of b1 to firstbase
		local b1Dist = math.sqrt(math.abs(b1.x - (firstBase.x - 4))^2 + math.abs(b1.y - (firstBase.y))^2);
		--calculate time at 10 pps
		local b1Time = b1Dist / 10 * 1000;
		--transition
		b1.myTrans = transition.to(b1, {time = b1Time, x = firstBase.x - 4, y = firstBase.y});
	end
end

goToPreviousScene = function()
	storyboard.gotoScene(prevScene, "fade", 250);
end

local function listener1(obj)
	moveBallDown();	
end

local function listener2(obj)
	--print('Ball arrived at landing spot');
	--check for any part of player at kickBall.x,kickBall.y (area of kickBall)
	if(kickBall.x + 5 >= closestPlayer.x - 5 and kickBall.x - 5 <= closestPlayer.x + 5
		and kickBall.y + 5 >= closestPlayer.y - 5 and kickBall.y - 5 <= closestPlayer.y + 5) then
		--if yes, ball was caught and kicker is out
		--stop the transition for kickball and closestplayer
		transition.cancel(kickBall.myTrans);
		transition.cancel(closestPlayer.myTrans);
		--kickball.x,y = closestplayer.x,y
		kickBall.x = closestPlayer.x;
		kickBall.y = closestPlayer.y;
		print('OUT');
		--Update database
		addOut();		
	else
		print('HIT');
		--if no, roll ball
		transition.cancel(closestPlayer.myTrans);
		moveBallRoll();
	end
end

local function ballWallCollision(self, event)
	if(event.phase == "began" and event.other.myName == "wall") then
		--Home Run!!!
	end
end

--ONLY FOR DEBUGGING
local function didBallStop()
	local vx, vy = kickBall:getLinearVelocity();
	if(vx == 0 and vy == 0) then
		Runtime:removeEventListener("enterFrame", didBallStop);
		timer.performWithDelay(1000, goToPreviousScene);
	end
end

moveBallUp = function()
	kickBall.isInAir = true;
	myScaleXY = randomAngle / 30 + 1.0;
	kickBall.myTrans = transition.to(kickBall, {time = ballUpTime, delay=50, x = kickBall.x + distAirX / 2, y = kickBall.y + distAirY / 2, xScale = myScaleXY, yScale = myScaleXY, onComplete = listener1});
	transition.to(kicker, {time = 2500, x = firstBase.x, y = firstBase.y});
end

moveBallDown = function()
	kickBall.myTrans = transition.to(kickBall, {time = ballDownTime, x = kickBall.x + distAirX / 2, y = kickBall.y + distAirY / 2, xScale = 1, yScale = 1, onComplete = listener2});
end

moveBallRoll = function()
	kickBall.isInAir = false;
	kickBall:setFillColor(0,0,255);
	--Kickball becomes physics object when rolling to apply linear damping to slow down
	local xVel = distRollX / ballRollTime * 1000;
	local yVel = distRollY / ballRollTime * 1000;
	physics.addBody(kickBall, {radius = 5, density = 1.0, friction = 0.3, bounce = 0.2});
	kickBall.linearDamping = 0.5;
	kickBall.myName = "kickBall";
	kickBall.collision = ballWallCollision;
	kickBall:addEventListener("collision", kickBall);
	kickBall:setLinearVelocity(xVel, yVel);
	
	--ONLY FOR DEBUGGING
	Runtime:addEventListener("enterFrame", didBallStop);
end

createPlayer = function(x,y,color)
	local player = display.newRect(0,0,10,10);
	player.x = x;
	player.y = y;
	player:setFillColor(color[1],color[2],color[3]);
	return player;
end

function scene:createScene(event)
	local group = self.view;
	physics.start();
	physics.setGravity(0,0);
	--For now white background
	local background = display.newRect(0,0, display.contentWidth, display.contentHeight);
	background:setFillColor(255,255,255);
	group:insert(background);
	
	local wall = display.newRect(-display.contentWidth,-10, display.contentWidth * 3, 5);
	wall.alpha = 0;
	wall.myName = "wall";
	group:insert(wall);
	
	playerTable = display.newGroup();
	
	physics.addBody(wall, {density = 1.0, friction = 0.3, bounce = 0.2, isSensor = true});	
	
	--NEED LINEUP FOR TEAM TO ADD PLAYERS ON FIELD
	local teamID, lineupPos;
	for row in db:nrows("SELECT currentinning, currenthalf, hometeamid, awayteamid, playercontrolledteamid, cpucontrolledteamid FROM game") do
		--if half == 1 then home else away
		if(row.currenthalf == 1) then
			teamID = row.hometeamid
		else
			teamID = row.awayteamid
		end
		--if inning is odd then 1 else 2
		if(row.currentinning % 2 == 0) then
			lineupPos = 2;
		else
			lineupPos = 1;
		end
		if(teamID == playercontrolledteamid) then
			fieldIsCPU = false;
		else
			fieldIsCPU = true;
		end
	end
	row = nil;
	local fieldLineupID, getLineupID;
	if(lineupPos == 1) then
		getLineupID = "SELECT MIN(lineupid) as lineupid FROM lineup WHERE teamid = teamID";
	else
		getLineupID = "SELECT MAX(lineupid) as lineupid FROM lineup WHERE teamid = teamID";		
	end
	for row in db:nrows(getLineupID) do
		fieldLineupID = row.lineupid;
	end
	row = nil;
	for row in db:nrows("SELECT p.sex, l.position FROM player AS p JOIN lineupdetail AS l on p.playerid = l.playerid WHERE l.lineupid = " .. fieldLineupID) do
		local colorOfBox = (row.sex == 'M' and {0,0,255}  or {255,0,0});
		if(row.position == 'P') then
			p = createPlayer(display.contentWidth / 2, display.contentHeight / 2 + 55, colorOfBox);
			p.pos = 'P';
			playerTable:insert(p);
		elseif(row.position == 'C') then
			c = createPlayer(display.contentWidth / 2, display.contentHeight + 3, colorOfBox);
			c.pos = 'C';
			playerTable:insert(c);
		elseif(row.position == '3B') then
			b3 = createPlayer(display.contentWidth / 2 - 70,display.contentHeight / 2 + 40, colorOfBox);
			b3.pos = '3B';
			playerTable:insert(b3);
		elseif(row.position == 'SS') then
			ss = createPlayer(display.contentWidth / 2 - 40,display.contentHeight / 2 - 10,colorOfBox);
			ss.pos = 'SS';
			playerTable:insert(ss);
		elseif(row.position == '2B') then
			b2 = createPlayer(display.contentWidth / 2 + 40, display.contentHeight / 2 - 10, colorOfBox)
			b2.pos = '2B';
			playerTable:insert(b2);
		elseif(row.position == '1B') then
			b1 = createPlayer(display.contentWidth / 2 + 70, display.contentHeight / 2 + 40, colorOfBox);
			b1.pos = '1B';
			playerTable:insert(b1);
		elseif(row.position == 'LF') then
			lf = createPlayer(display.contentWidth / 2 - 150, display.contentHeight / 2 - 40, colorOfBox);
			lf.pos = 'LF';
			playerTable:insert(lf);
		elseif(row.position == 'LCF') then
			lcf = createPlayer(display.contentWidth / 2 - 75, display.contentHeight / 4 - 15, colorOfBox);
			lcf.pos = 'LCF';
			playerTable:insert(lcf);
		elseif(row.position == 'CF') then
			cf = createPlayer(display.contentWidth / 2, 20, colorOfBox);
			cf.pos = 'CF';
			playerTable:insert(cf);
		elseif(row.position == 'RCF') then
			rcf = createPlayer(display.contentWidth / 2 + 75, display.contentHeight / 4 - 15, colorOfBox);
			rcf.pos = 'RCF';
			playerTable:insert(rcf);
		elseif(row.position == 'RF') then
			rf = createPlayer(display.contentWidth / 2 + 150, display.contentHeight / 2 - 40, colorOfBox);
			rf.pos = 'RF';
			playerTable:insert(rf);
		end
	end
	group:insert(playerTable);
	
	firstBase = display.newRect(0,0,7,7);
	firstBase:rotate(45);
	firstBase.x = display.contentWidth / 2 + 85;
	firstBase.y = display.contentHeight / 2 + 55;
	firstBase:setFillColor(0,0,0);
	group:insert(firstBase);
	
	secondBase = display.newRect(0,0,7,7);
	secondBase:rotate(45);
	secondBase.x = display.contentWidth / 2;
	secondBase.y = display.contentHeight / 2 - 20;
	secondBase:setFillColor(0,0,0);
	group:insert(secondBase);
	
	thirdBase = display.newRect(0,0,7,7);
	thirdBase:rotate(45);
	thirdBase.x = display.contentWidth / 2 - 85;
	thirdBase.y = display.contentHeight / 2 + 55
	thirdBase:setFillColor(0,0,0);
	group:insert(thirdBase);
	
	dirX = event.params.dirX;
	--print('DirX: ' .. dirX);
	dirY = event.params.dirY;
	--print('DirY: ' .. dirY);
	power = event.params.power;
	prevScene = event.params.prev;
	
	kicker = display.newRect(0,0,10,10);
	kicker:rotate(45);
	kicker.x = display.contentWidth / 2;
	kicker.y = display.contentHeight - 18;
	kicker:setFillColor(0,0,255);
	group:insert(kicker);
	
	--Create ball at middle bottom of screen
	kickBall = display.newCircle(display.contentWidth / 2, display.contentHeight - 20,5);
	kickBall:setFillColor(255,0,0);
	--kickBall.strokeWidth = 1;
	--kickBall:setStrokeColor(0,0,0);
	group:insert(kickBall);
	
	kickBall.pickedUp = false;
	
	--Random angle depending on kickpower
	if(power == 1) then
		randomAngle = 0;
	elseif(power == 2) then
		randomAngle = math.random(0,30);
	else
		randomAngle = math.random(0,60);
	end
	local distanceMultiplier;
	if(randomAngle <= 30) then
		distanceMultiplier = (randomAngle / 15.0) + 1.0;
	else
		distanceMultiplier = 4.0 - (randomAngle / 30.0);
	end
	local setDistance;
	if(power == 1) then
		setDistance = 35 * distanceMultiplier;
	elseif(power == 2) then
		setDistance = 75 * distanceMultiplier;
	else
		setDistance = 100 * distanceMultiplier;
	end
	kickAngle = math.deg(math.asin(dirY / (math.sqrt(math.pow(dirX, 2) + math.pow(dirY, 2)))));
	distY = setDistance * math.sin(math.rad(kickAngle));
	distX = math.sqrt(math.pow(setDistance, 2) - math.pow(distY, 2));	
	if(dirX < 0) then
		distX = distX * -1;
	end
	local airTimeMultiplier = 1.00 - math.pow(2.10, (-.1 * randomAngle));
	local timeInAir = airTimeMultiplier * 4000;
	local maxDistance;
	if(power == 1) then
		maxDistance = 35;
	elseif(power == 2) then
		maxDistance = 225;
	else
		maxDistance = 300;
	end
	local anotherMultiplier = setDistance / maxDistance;
	ballUpTime = (timeInAir / 2) * anotherMultiplier;
	ballDownTime = (timeInAir / 2) * anotherMultiplier;
	ballRollTime = (4000 - timeInAir) * anotherMultiplier;
	distAirX = distX * airTimeMultiplier;
	distAirY = distY * airTimeMultiplier;
	distRollX = distX - distAirX;
	distRollY = distY - distAirY;
	getClosestFielderToMove();
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("battingscene");
	storyboard.purgeScene("pitchingscene");
	--Transition for now, will need a better transition that show ball growing and shrinking depending on angle of kick
	--Ball is biggest half way between start and finish
	--timer.performWithDelay(20, moveBall, 100)
	--height of ball with depend on angle of kick and power
	--example 60 degree / power = 3 ball will be in air from start to finish
	--example 2 1 degree / power = 2 ball will be in air for minimal time
	moveBallUp();
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