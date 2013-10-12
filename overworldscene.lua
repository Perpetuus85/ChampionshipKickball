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
local fieldIsCPU;
local p, c, b1, b2, b3, ss, lf, lcf, cf, rcf, rf;

local function goToPreviousScene()
	storyboard.gotoScene(prevScene, "fade", 250);
end

local function listener1(obj)
	moveBallDown();	
end

local function listener2(obj)
	moveBallRoll();
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
	myScaleXY = randomAngle / 30 + 1.0;
	transition.to(kickBall, {time = ballUpTime, delay=50, x = kickBall.x + distAirX / 2, y = kickBall.y + distAirY / 2, xScale = myScaleXY, yScale = myScaleXY, onComplete = listener1});
end

moveBallDown = function()
	transition.to(kickBall, {time = ballDownTime, x = kickBall.x + distAirX / 2, y = kickBall.y + distAirY / 2, xScale = 1, yScale = 1, onComplete = listener2});
end

moveBallRoll = function()
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
			p = display.newRect(0,0,10,10);
			p.x = display.contentWidth / 2;
			p.y = display.contentHeight / 2 + 60;
			p:setFillColor(colorOfBox[1], colorOfBox[2], colorOfBox[3]);
			group:insert(p);
		elseif(row.position == 'C') then
			c = display.newRect(0,0,10,10);
			c.x = display.contentWidth / 2;
			c.y = display.contentHeight - 5;
			c:setFillColor(colorOfBox[1], colorOfBox[2], colorOfBox[3]);
			group:insert(c);
		elseif(row.position == '3B') then
			b3 = display.newRect(0,0,10,10);
			b3.x = display.contentWidth / 2 - 80;
			b3.y = display.contentHeight / 2 + 50;
			b3:setFillColor(colorOfBox[1], colorOfBox[2], colorOfBox[3]);
			group:insert(b3);
		elseif(row.position == 'SS') then
			ss = display.newRect(0,0,10,10);
			ss.x = display.contentWidth / 2 - 40;
			ss.y = display.contentHeight / 2 - 10;
			ss:setFillColor(colorOfBox[1], colorOfBox[2], colorOfBox[3]);
			group:insert(ss);
		elseif(row.position == '2B') then
			b2 = display.newRect(0,0,10,10);
			b2.x = display.contentWidth / 2 + 40;
			b2.y = display.contentHeight / 2 - 10;
			b2:setFillColor(colorOfBox[1], colorOfBox[2], colorOfBox[3]);
			group:insert(b2);
		elseif(row.position == '1B') then
			b1 = display.newRect(0,0,10,10);
			b1.x = display.contentWidth / 2 + 80;
			b1.y = display.contentHeight / 2 + 50;
			b1:setFillColor(colorOfBox[1], colorOfBox[2], colorOfBox[3]);
			group:insert(b1);
		elseif(row.position == 'LF') then
		elseif(row.position == 'LCF') then
		elseif(row.position == 'CF') then
		elseif(row.position == 'RCF') then
		elseif(row.position == 'RF') then
		end
	end
	
	dirX = event.params.dirX;
	--print('DirX: ' .. dirX);
	dirY = event.params.dirY;
	--print('DirY: ' .. dirY);
	power = event.params.power;
	prevScene = event.params.prev;
	
	--Create ball at middle bottom of screen
	kickBall = display.newCircle(display.contentWidth / 2, display.contentHeight - 20,5);
	kickBall:setFillColor(255,0,0);
	--kickBall.strokeWidth = 1;
	--kickBall:setStrokeColor(0,0,0);
	group:insert(kickBall);
	
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
	local kickAngle = math.deg(math.asin(dirY / (math.sqrt(math.pow(dirX, 2) + math.pow(dirY, 2)))));
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