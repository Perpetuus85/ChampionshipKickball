local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();
local dirX, dirY, power, kickBall;
local physics = require("physics");
local distX, distY, prevScene;
local moveBallEnd;
local randomAngle;
local myScaleXY;

local function goToPreviousScene()
	storyboard.gotoScene(prevScene, "fade", 250);
end

local function listener1(obj)
	moveBallEnd();	
end

local function listener2(obj)
	timer.performWithDelay(1000, goToPreviousScene);
end

local function moveBallStart()
	myScaleXY = randomAngle / 30 + 1.0;
	transition.to(kickBall, {time = 2000, delay=50, x = kickBall.x + distX / 2, y = kickBall.y + distY / 2, xScale = myScaleXY, yScale = myScaleXY, onComplete = listener1});
end

moveBallEnd = function()
	transition.to(kickBall, {time = 2000, x = kickBall.x + distX / 2, y = kickBall.y + distY / 2, xScale = 1, yScale = 1, onComplete = listener2});
end

function scene:createScene(event)
	local group = self.view;
	
	--For now white background
	local background = display.newRect(0,0, display.contentWidth, display.contentHeight);
	background:setFillColor(255,255,255);
	group:insert(background);
	
	dirX = event.params.dirX;
	print('DirX: ' .. dirX);
	dirY = event.params.dirY;
	print('DirY: ' .. dirY);
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
	print('Multi: ' .. distanceMultiplier);
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
	--distY = kickBall.y + distY;
	--distX = kickBall.x + distX;
	--print('DistX: ' .. distX);
	--print('DistY: ' .. distY);
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
	moveBallStart();
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