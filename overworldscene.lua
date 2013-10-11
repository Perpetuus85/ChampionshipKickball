local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();
local dirX, dirY, power, kickBall;
local physics = require("physics");
local distX, distY, prevScene;
local moveBallUp, moveBallDown, moveBallRoll;
local randomAngle;
local myScaleXY;
local ballUpTime, ballDownTime, ballRollTime;
local distAirX, distAirY;
local distRollX, distRollY;

local function goToPreviousScene()
	storyboard.gotoScene(prevScene, "fade", 250);
end

local function listener1(obj)
	moveBallDown();	
end

local function listener2(obj)
	moveBallRoll();
end

local function listener3(obj)
	timer.performWithDelay(1000, goToPreviousScene);
end

local function ballWallCollision(self, event)
	if(event.phase == "began" and event.other.myName == "wall") then
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
	--initial velocity depends on power
	--kickBall.x / ballRollTime -> x velocity
	--kickBall.y / ballRollTime -> y velocity
	print('X: ' .. kickBall.x);
	print('Y: ' .. kickBall.y);
	print('BallRollTime: ' .. ballRollTime);
	local xVel = distRollX / ballRollTime * 1000;
	local yVel = distRollY / ballRollTime * 1000;
	print('xVel: ' .. xVel);
	print('yVel: ' .. yVel);
	physics.addBody(kickBall, {radius = 5, density = 1.0, friction = 0.3, bounce = 0.2});
	--transition.to(kickBall, {time = ballRollTime, x = kickBall.x + distRollX, y = kickBall.y + distRollY, onComplete = listener3});
	kickBall.linearDamping = 0.5;
	kickBall.myName = "kickBall";
	kickBall.collision = ballWallCollision;
	kickBall:addEventListener("collision", kickBall);
	kickBall:setLinearVelocity(xVel, yVel);
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