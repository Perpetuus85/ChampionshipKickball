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
local firstBase, secondBase, thirdBase, homePlate;
local kicker;
local transitionClosestToKickball, reachedKickball, getClosestFielderToMove;
local getClosest;
local landX, landY, minDistance;
local previousClosestPlayer, previousClosestColor;
local runnerToFirst, runnerToSecond, runnerToThird, runnerToHome;
local runnerReached, checkWhatToDo, addOut;
local runnerSecondReached, runnerThirdReached, runnerHomeReached;
local runnerBackThirdReached, runnerBackSecondReached, runnerBackFirstReached;
local checkOutAtFirst, checkOutAtSecond, checkOutAtThird, nextAtBat;
local firstBaseRunner, secondBaseRunner, thirdBaseRunner;
local aFBRunner, aSBRunner, aTBRunner;
local currentouts, keepRunning;
local holdButton, runForwardButton, runBackButton;
local homeRunThirdReachedHome, homeRunSecondReachedThird, homeRunSecondReachedHome, homeRunFirstReachedSecond;
local homeRunFirstReachedThird, homeRunFirstReachedHome;
local homeRunKickerReachedFirst, homeRunKickerReachedSecond, homeRunKickerReachedThird, homeRunKickerReachedHome;
local addRun;

nextAtBat = function(obj)
	--check if any runners advanced
	if(aTBRunner == false) then
		local gameUpdate = [[UDPATE game SET thirdbaserunner = 0; ]];
		db:exec(gameUpdate);
	end
	if(aSBRunner == true) then
		if(secondBaseRunner.x == thirdBase.x and secondBaseRunner.y == thirdBase.y) then
			--second base runner is now at third
			--update game set thirdbaserunner = secondbaserunner
			local gameUpdate = [[UPDATE game SET thirdbaserunner = secondbaserunner;]];
			db:exec(gameUpdate);
			--update game set secondbaserunner = 0
			gameUpdate = [[UPDATE game SET secondbaserunner = 0;]];
			db:exec(gameUpdate);
		end
	else
		local gameUpdate = [[UPDATE game SET secondbaserunner = 0;]];
		db:exec(gameUpdate);
	end
	if(aFBRunner == true) then
		if(firstBaseRunner.x == secondBase.x and firstBaseRunner.y == secondBase.y) then
			--first base runner is now at second
			--update game set secondbaserunner = firstbaserunner
			local gameUpdate = [[UPDATE game SET secondbaserunner = firstbaserunner;]];
			db:exec(gameUpdate);
			--update game set firstbaserunner = 0
			gameUpdate = [[UPDATE game SET firstbaserunner = 0;]];
			db:exec(gameUpdate);
		elseif(firstBaseRunner.x == thirdBase.x and firstBaseRunner.y == thirdBase.y) then
			--first base runner is now at third
			--update game set thirdbaserunner = firstbaserunner
			local gameUpdate = [[UPDATE game SET thirdbaserunner = firstbaserunner;]];
			db:exec(gameUpdate);
			--update game set firstbaserunner = 0
			gameUpdate = [[UPDATE game SET firstbaserunner = 0;]];
			db:exec(gameUpdate);
		end
	else
		local gameUpdate = [[UPDATE game SET firstbaserunner = 0;]];
		db:exec(gameUpdate);
	end
	if(kicker ~= nil) then
		if(kicker.x == firstBase.x and kicker.y == firstBase.y) then
			--kicker is at first
			--update game set firstbaserunner = currentkicker
			local gameUpdate = [[UPDATE game SET firstbaserunner = currentkicker;]];
			db:exec(gameUpdate);
		elseif(kicker.x == secondBase.x and kicker.y == secondBase.y) then
			--kicker is at second
			--update game set secondbaserunner = currentkicker
			local gameUpdate = [[UPDATE game SET secondbaserunner = currentkicker;]];
			db:exec(gameUpdate);
		elseif(kicker.x == thirdBase.x and kicker.y == thirdBase.y) then
			--kicker is at third
			--update game set thirdbaserunner = currentkicker
			local gameUpdate = [[UPDATE game SET thirdbaserunner = currentkicker;]];
			db:exec(gameUpdate);
		end
	end
	--set current kicker to next in lineup
	local nextKickerID;
	
	local currentdetailid, currentteamid;
	for row in db:nrows("SELECT d.detailid, l.teamid FROM lineupdetail as d JOIN lineup as l on l.lineupid = d.lineupid WHERE playerid = (SELECT currentkicker FROM game)") do
		currentdetailid = row.detailid;
		currentteamid = row.teamid;
	end
	local possibleNextId = currentdetailid + 1;
	local gotPlayerID = false;
	for row in db:nrows("SELECT d.playerid, d.lineupid FROM lineupdetail as d JOIN lineup as l on l.lineupid = d.lineupid WHERE l.teamid = ".. currentteamid .. " AND d.detailid = " .. possibleNextId) do
		gotPlayerID = true;
		nextKickerID = row.playerid;
	end
	if(gotPlayerID == false) then
		local currentlineupid;
		for row in db:nrows("SELECT MIN(lineupid) as lineupid FROM lineup WHERE teamid = " .. currentteamid) do
			currentlineupid = row.lineupid;
		end
		local nextLineupdetailid;
		for row in db:nrows("SELECT MIN(detailid) as detailid FROM lineupdetail WHERE lineupid = " .. currentlineupid) do
			nextLineupdetailid = row.detailid;
		end
		for row in db:nrows("SELECT playerid FROM lineupdetail WHERE detailid = " .. nextLineupdetailid) do
			nextKickerID = row.playerid;
		end
	end
	local gameUpdate = [[UPDATE game SET currentkicker = ]]..nextKickerID..[[;]];
	db:exec(gameUpdate);
	timer.performWithDelay(1000, goToPreviousScene);
end

checkOutAtFirst = function()
	if(runnerToFirst == true) then
		--OUT
		print('OUT AT FIRST');
		runnerToFirst = false;
		--remove either kicker or firstbaserunner
		if(kicker.goingTo == '1B') then
			transition.cancel(kicker.myTrans);
			kicker:removeSelf();
			kicker = nil;
		else
			if(aFBRunner == true) then
				transition.cancel(firstBaseRunner.myTrans);
				firstBaseRunner:removeSelf();
				firstBaseRunner = nil;
			end
		end
		addOut();		
	else
		--SAFE
		print('SAFE AT FIRST');
		timer.performWithDelay(500,checkWhatToDo);
	end	
end

checkOutAtSecond = function()
	if(runnerToSecond == true) then
		--OUT
		print('OUT AT SECOND');
		runnerToSecond = false;
		--remove either kicker, firstbaserunner, or secondbaserunner	
		if(kicker.goingTo == '2B') then
			transition.cancel(kicker.myTrans);
			kicker:removeSelf();
			kicker = nil;
		else
			if(aFBRunner == true) then
				if(firstBaseRunner.goingTo == '2B') then
					transition.cancel(firstBaseRunner.myTrans);
					firstBaseRunner:removeSelf();
					firstBaseRunner = nil;
				end
			elseif(aSBRunner == true) then
				transition.cancel(secondBaseRunner.myTrans);
				secondBaseRunner:removeSelf();
				secondBaseRunner = nil;
			end
		end
		addOut();			
	else
		--SAFE
		print('SAFE AT SECOND');
		timer.performWithDelay(500,checkWhatToDo);
	end	
end

checkOutAtThird = function()
	if(runnerToThird == true) then
		--OUT
		print('OUT AT THIRD');
		--remove either kicker, firstbaserunner, secondbaserunner, or thirdbaserunner
		addOut();		
	else
		--SAFE
		print('SAFE AT THIRD');
		timer.performWithDelay(500,checkWhatToDo);
	end	
end

checkWhatToDo = function()
	--if fieldIsCPU is true decide where to throw
	--else show player where they can throw
	if(runnerToThird == true or (aTBRunner == true and thirdBaseRunner.isTaggedUp == false)) then
		--if not b3
		if(closestPlayer.pos ~= '3B') then
			--throw to third
			--get distance from closestPlayer to b3
			local dist = math.sqrt((closestPlayer.x - b3.x)^2 + (closestPlayer.y - b3.y)^2);
			--calc time going 30 pps
			local myTime = dist / 65 * 1000;
			transition.to(kickBall, {time = myTime, x = b3.x, y = b3.y, onComplete=checkOutAtThird});
		else
			--else run to third
		end
	elseif(runnerToSecond == true or (aSBRunner == true and secondBaseRunner.isTaggedUp == false)) then
		--always throw to second no matter who closest player is
		local secondBaseMan;
		if(kickBall.x > display.contentWidth / 2) then
			secondBaseMan = ss;
		else
			secondBaseMan = b2;
		end
		local dist = math.sqrt((closestPlayer.x - secondBaseMan.x)^2 + (closestPlayer.y - secondBaseMan.y)^2);
		--calc time going 30 pps
		local myTime = dist / 65 * 1000;
		transition.to(kickBall, {time = myTime, x = secondBaseMan.x, y = secondBaseMan.y, onComplete=checkOutAtSecond});
	elseif(runnerToFirst == true or (aFBRunner == true and firstBaseRunner.isTaggedUp == false)) then
		--if not b1
		if(closestPlayer.pos ~= '1B') then
			--throw to first
			local dist = math.sqrt((closestPlayer.x - b1.x)^2 + (closestPlayer.y - b1.y)^2);
			local myTime = dist / 65 * 1000;
			transition.to(kickBall, {time = myTime, x = b1.x, y = b1.y, onComplete=checkOutAtFirst});
		else
			--else run to first
		end
	else
		--if not pitcher
		if(closestPlayer.pos ~= 'P') then
			--throw to pitcher
			local dist = math.sqrt((closestPlayer.x - p.x)^2 + (closestPlayer.y - p.y)^2);
			local myTime = dist / 65 * 1000;
			transition.to(kickBall, {time = myTime, x = p.x, y = p.y, onComplete=nextAtBat});
		else
			--else go to previousScene
		end
	end
end

local function goToScoreboard()
	storyboard.gotoScene("scoreboardscene", "fade", 400);
end

reachedKickball = function(obj)
	if(kickBall.x + 5 >= closestPlayer.x - 5 and kickBall.x - 5 <= closestPlayer.x + 5
		and kickBall.y + 5 >= closestPlayer.y - 5 and kickBall.y - 5 <= closestPlayer.y + 5) then
		kickBall.pickedUp = true;
		kickBall:setLinearVelocity(0,0);
		kickBall.x = closestPlayer.x;
		kickBall.y = closestPlayer.y;
		timer.performWithDelay(500, checkWhatToDo);
	else
		getClosest(kickBall.x, kickBall.y);
		transitionClosestToKickball();
	end
end

transitionClosestToKickball = function()
	--create transition for closestPlayer towards kickball
	local kX = kickBall.x;
	local kY = kickBall.y;
	local pX = closestPlayer.x;
	local pY = closestPlayer.y;
	local h = math.sqrt((kX - pX)^2 + (kY - pY)^2);
	local y = math.abs(kY-pY);
	--print('y ' .. y);
	local angle = math.asin(y / h);
	--print('angle ' .. angle);
	local myDistY = 2.5 * math.sin(angle);
	local myDistX = 2.5 * math.cos(angle);
	if(kX < pX) then
		myDistX = -1 * myDistX;
	end
	if(kY < pY) then
		myDistY = -1 * myDistY;
	end
	--print('DistY ' .. myDistY);
	--print('DistX ' .. myDistX);
	closestPlayer.myTrans = transition.to(closestPlayer, {time = 100, delta = true, x = myDistX, y = myDistY, onComplete = reachedKickball});
end

addOut = function()
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
		--print(setHalf);
		--print(setInning);
		if(kickBall ~= nil) then
			kickBall:removeSelf();
			kickBall = nil;
		end
		local updateCounts = [[UPDATE game SET currentouts = 0, currentballs = 0, currentstrikes = 0, currentfouls = 0, firstbaserunner = 0, secondbaserunner = 0, thirdbaserunner = 0, currenthalf = ]]..setHalf..[[, currentinning = ]]..setInning..[[;]];
		db:exec(updateCounts);
		timer.performWithDelay(1000, goToScoreboard);
	else
		--increment outs and change kicker
		currentOutCount = currentOutCount + 1;
		local updateOuts = [[UPDATE game set currentouts = ]]..currentOutCount..[[, currentballs = 0, currentstrikes = 0, currentfouls = 0;]];
		db:exec(updateOuts);
		timer.performWithDelay(500, checkWhatToDo);
	end
end

local function listener3(obj)
	--print('Player arrived at ball landing spot');
end

getClosest = function(kickX, kickY)	
	landX = kickX;
	--print('landX ' .. landX);
	landY = kickY;
	--print('landY ' .. landY);
	--True distance = square root of ((abs value of diff(landX,playerX))^2 + (abs value of diff(landY, playerY))^2)
	local tempClosestPlayer = nil;
	local tempMinDistance = nil;
	for i=1,playerTable.numChildren do
		if(tempClosestPlayer == nil) then
			tempClosestPlayer = playerTable[i];
		end
		if(tempMinDistance == nil) then
			tempMinDistance = math.sqrt(math.abs(landX - playerTable[i].x)^2 + math.abs(landY - playerTable[i].y)^2);
		end
		
		if(tempClosestPlayer ~= playerTable[i]) then
			local compDist = math.sqrt(math.abs(landX - playerTable[i].x)^2 + math.abs(landY - playerTable[i].y)^2);
			--print('Player at ' .. playerTable[i].pos .. ' is ' .. compDist .. ' away');
			--print('PlayerX ' .. playerTable[i].x);
			--print('PlayerY ' .. playerTable[i].y);
			if(compDist < tempMinDistance) then
				tempMinDistance = compDist;
				tempClosestPlayer = playerTable[i];
			end
			compDist = nil;
		end
	end
	--print('Closest Player ' .. closestPlayer.pos);
	if(closestPlayer == nil) then
		closestPlayer = tempClosestPlayer;
		closestPlayer:setFillColor(0,255,0);
	end
	if(minDistance == nil) then
		minDistance = tempMinDistance;
	end
	if(previousClosestPlayer == nil) then
		previousClosestPlayer = closestPlayer;
		previousClosestColor = (closestPlayer.sex == 'M' and {0,0,255}  or {255,0,0});
	end
	if(tempClosestPlayer ~= closestPlayer) then
		previousClosestPlayer = closestPlayer;
		previousClosestColor = (closestPlayer.sex == 'M' and {0,0,255}  or {255,0,0});
		previousClosestPlayer:setFillColor(previousClosestColor[1], previousClosestColor[2], previousClosestColor[3]);
		closestPlayer = tempClosestPlayer;
		closestPlayer:setFillColor(0,255,0);
	end
end

getClosestFielderToMove = function()
	getClosest((display.contentWidth / 2) + distAirX, (display.contentHeight - 20) + distAirY);
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
		transition.cancel(kicker.myTrans);
		runnerToFirst = false;
		kicker:removeSelf();
		kicker = nil;
		--kickball.x,y = closestplayer.x,y
		kickBall.x = closestPlayer.x;
		kickBall.y = closestPlayer.y;
		kickBall.isInAir = false;
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

addRun = function()
end

homeRunThirdReachedHome = function()
	--add run
	addRun();
	--remove thirdBaseRunner
	thirdBaseRunner:removeSelf();
	thirdBaseRunner = nil;
	aTBRunner = false;
	local gameUpdate = [[UPDATE game SET thirdbaserunner = 0]];
	db:exec(gameUpdate);
end

homeRunSecondReachedThird = function()
	--transition secondBaseRunner to home
	secondBaseRunner.myTrans = transition.to(secondBaseRunner, {time = 4000, x = homePlate.x, y = homePlate.y, onComplete=homeRunSecondReachedHome});
end

homeRunSecondReachedHome = function()
	--add run
	addRun();
	--remove secondBaseRunner
	secondBaseRunner:removeSelf();
	secondBaseRunner = nil;
	local gameUpdate = [[UPDATE game SET secondbaserunner = 0]];
	db:exec(gameUpdate);
end

homeRunFirstReachedSecond = function()
	--transition firstBaseRunner to third
	firstBaseRunner.myTrans = transition.to(firstBaseRunner, {time = 4000, x = thirdBase.x, y = thirdBase.y, onComplete=homeRunFirstReachedThird});
end

homeRunFirstReachedThird = function()
	--transition firstBaseRunner to home
	firstBaseRunner.myTrans = transition.to(firstBaseRunner, {time = 4000, x = homePlate.x, y = homePlate.y, onComplete=homeRunFirstReachedHome});
end

homeRunFirstReachedHome = function()
	--add run
	addRun();
	--remove firstBaseRunner
	firstBaseRunner:removeSelf();
	firstBaseRunner = nil;
	aFBRunner = false;
	local gameUpdate = [[UPDATE game SET firstbaserunner = 0]];
	db:exec(gameUpdate);
end

homeRunKickerReachedFirst = function()
	--transition kicker to second
	kicker.myTrans = transition.to(kicker, {time = 4000, x = secondBase.x, y = secondBase.y, onComplete=homeRunKickerReachedSecond});
end

homeRunKickerReachedSecond = function()
	--transition kicker to third
	kicker.myTrans = transition.to(kicker, {time = 4000, x = thirdBase.x, y = thirdBase.y, onComplete=homeRunKickerReachedThird});
end

homeRunKickerReachedThird = function()
	--transition kicker to home
	kicker.myTrans = transition.to(kicker, {time = 4000, x = homePlate.x, y = homePlate.y, onComplete=homeRunKickerReachedHome});
end

homeRunKickerReachedHome = function()
	--add run
	addRun();
	--remove kicker
	kicker:removeSelf();
	kicker = nil;
	--go to next at bat
	nextAtBat(nil);
end

local function ballWallCollision(self, event)
	if(event.phase == "began" and event.other.myName == "wall") then
		print('HOME RUN');
		transition.cancel(closestPlayer.myTrans);
		if(aTBRunner == true) then
			if(thirdBaseRunner.myTrans ~= nil) then
				transition.cancel(thirdBaseRunner.myTrans);
			end
			local remainingDistance = math.sqrt((thirdBaseRunner.x - homePlate.x)^2 + (thirdBaseRunner.y - homePlate.y)^2);
			local fullDistance = math.sqrt((thirdBase.x - homePlate.x)^2 + (thirdBase.y - homePlate.y)^2);
			local remainingPercentage = remainingDistance / fullDistance;
			local tTime = remainingPercentage * 4000;
			thirdBaseRunner.myTrans = transition.to(thirdBaseRunner, {time = tTime, x = homePlate.x, y = homePlate.y, onComplete=homeRunThirdReachedHome});
		end
		if(aSBRunner == true) then
			if(secondBaseRunner.myTrans ~= nil) then
				transition.cancel(secondBaseRunner.myTrans);
			end
			local remainingDistance = math.sqrt((secondBaseRunner.x - thirdBase.x)^2 + (secondBaseRunner.y - thirdBase.y)^2);
			local fullDistance = math.sqrt((secondBase.x - thirdBase.x)^2 + (secondBase.y - thirdBase.y)^2);
			local remainingPercentage = remainingDistance / fullDistance;
			local tTime = remainingPercentage * 4000;
			secondBaseRunner.myTrans = transition.to(secondBaseRunner, {time = tTime, x = thirdBase.x, y = thirdBase.y, onComplete=homeRunSecondReachedThird});
		end
		if(aFBRunner == true) then
			if(firstBaseRunner.myTrans ~= nil) then
				transition.cancel(firstBaseRunner.myTrans);
			end
			local remainingDistance = math.sqrt((firstBaseRunner.x - secondBase.x)^2 + (firstBaseRunner.y - secondBase.y)^2);
			local fullDistance = math.sqrt((firstBase.x - secondBase.x)^2 + (firstBase.y - secondBase.y)^2);
			local remainingPercentage = remainingDistance / fullDistance;
			local tTime = remainingPercentage * 4000;
			firstBaseRunner.myTrans = transition.to(firstBaseRunner, {time = tTime, x = secondBase.x, y = secondBase.y, onComplete=homeRunFirstReachedSecond});
		end
		if(kicker.myTrans ~= nil) then
			transition.cancel(kicker.myTrans);
		end
		local remainingDistance = math.sqrt((kicker.x - firstBase.x)^2 + (kicker.y - firstBase.y)^2);
		local fullDistance = math.sqrt((homePlate.x - firstBase.x)^2 + (homePlate.y - firstBase.y)^2);
		local remainingPercentage = remainingDistance / fullDistance;
		local tTime = remainingPercentage * 4000;
		kicker.myTrans = transition.to(kicker, {time = tTime, x = firstBase.x, y = firstBase.y, onComplete=homeRunKickerReachedFirst});
	end
end

runnerReached = function()
	if(kicker.isRunning == true) then
		kicker.isRunning = false;
	end;
	if(runnerToFirst == true) then
		runnerToFirst = false;
	end;
	
end

runnerSecondReached = function()
	if(firstBaseRunner.isRunning == true) then
		firstBaseRunner.isRunning = false;
	end
	if(runnerToSecond == true) then
		runnerToSecond = false;
	end
end

runnerThirdReached = function()
	if(secondBaseRunner.isRunning == true) then
		secondBaseRunner.isRunning = false;
	end
	if(runnerToThird == true) then
		runnerToThird = false;
	end
end

runnerHomeReached = function()
	if(thirdBaseRunner.isRunning == true) then
		thirdBaseRunner.isRunning = false;
	end
	if(runnerToHome == true) then
		runnerToHome = false;
	end
end

runnerBackThirdReached = function()
	thirdBaseRunner.isRunning = false;
	runnerToThird = false;
	thirdBaseRunner.isTaggedUp = true;
end

runnerBackSecondReached = function()
	secondBaseRunner.isRunning = false;
	runnerToSecond = false;
	secondBaseRunner.isTaggedUp = true;
end

runnerBackFirstReached = function()
	firstBaseRunner.isRunning = false;
	runnerToFirst = false;
	firstBaseRunner.isTaggedUp = true;
end

moveBallUp = function()
	kickBall.isInAir = true;
	myScaleXY = randomAngle / 30 + 1.0;
	kickBall.myTrans = transition.to(kickBall, {time = ballUpTime, delay=50, x = kickBall.x + distAirX / 2, y = kickBall.y + distAirY / 2, xScale = myScaleXY, yScale = myScaleXY, onComplete = listener1});
	kicker.myTrans = transition.to(kicker, {time = 4000, x = firstBase.x, y = firstBase.y, onComplete=runnerReached});
	kicker.isRunning = true;
	kicker.goingTo = '1B';
	runnerToFirst = true;
	if(currentouts == 2) then
		--everyone should start running if there is two outs no matter what
		if(aFBRunner == true) then
			runnerToSecond = true;
			firstBaseRunner.isRunning = true;
			firstBaseRunner.myTrans = transition.to(firstBaseRunner, {time = 4000, x = secondBase.x, y = secondBase.y, onComplete=runnerSecondReached});
			firstBaseRunner.goingTo = '2B';
		end
		
		if(aSBRunner == true) then
			runnerToThird = true;
			secondBaseRunner.isRunning = true;
			secondBaseRunner.myTrans = transition.to(secondBaseRunner, {time = 4000, x = thirdBase.x, y = thirdBase.y, onComplete=runnerThirdReached});
			secondBaseRunner.goingTo = '3B';
		end
		
		if(aTBRunner == true) then
			runnerToHome = true;
			thirdBaseRunner.isRunning = true;
			thirdBaseRunner.myTrans = transition.to(thirdBaseRunner, {time = 4000, x = homePlate.x, y = homePlate.y, onComplete=runnerHomeReached});
			thirdBaseRunner.goingTo = 'H';
		end
	else
	end
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
	transitionClosestToKickball();
	--if runners are not running, get them to start running
	if(aFBRunner == true) then
		firstBaseRunner.isTaggedUp = true;
		--print("FB Runner");
		if(firstBaseRunner.isRunning == false) then
			--print("FB Runner GO");
			runnerToSecond = true;
			firstBaseRunner.isRunning = true;
			firstBaseRunner.goingTo = '2B';
			firstBaseRunner.myTrans = transition.to(firstBaseRunner, {time = 4000, x = secondBase.x, y = secondBase.y, onComplete=runnerSecondReached});
		end
	end
	
	if(aSBRunner == true) then
		secondBaseRunner.isTaggedUp = true;
		if(secondBaseRunner.isRunning == false) then
			runnerToThird = true;
			secondBaseRunner.isRunning = true;
			secondBaseRunner.goingTo = '3B';
			secondBaseRunner.myTrans = transition.to(secondBaseRunner, {time = 4000, x = thirdBase.x, y = thirdBase.y, onComplete=runnerThirdReached});
		end
	end
	
	if(aTBRunner == true) then
		thirdBaseRunner.isTaggedUp = true;
		if(thirdBaseRunner.isRunning == false) then
			runnerToHome = true;
			thirdBaseRunner.isRunning = true;
			thirdBaseRunner.goingTo = 'H';
			thirdBaseRunner.myTrans = transition.to(thirdBaseRunner, {time = 4000, x = homePlate.x, y = homePlate.y, onComplete=runnerHomeReached});
		end
	end
end

createPlayer = function(x,y,color)
	local player = display.newRect(0,0,10,10);
	player.x = x;
	player.y = y;
	player:setFillColor(color[1],color[2],color[3]);
	return player;
end

local function holdButtonTouch(event)
	if(thirdBaseRunner.myTrans ~= nil) then
		transition.cancel(thirdBaseRunner.myTrans);
	end
	
	if(secondBaseRunner.myTrans ~= nil) then
		transition.cancel(secondBaseRunner.myTrans);
	end
	
	if(firstBaseRunner.myTrans ~= nil) then
		transition.cancel(firstBaseRunner.myTrans);
	end
end

local function runForwardButtonTouch(event)
	if(aTBRunner == true) then		
		if(runnerToHome == false) then
			if(thirdBaseRunner.myTrans ~= nil) then
				transition.cancel(thirdBaseRunner.myTrans);
			end
			if(kickBall.isInAir == true) then
				thirdBaseRunner.isTaggedUp = false;
			else
				thirdBaseRunner.isTaggedUp = true;
			end
			runnerToHome = true;
			thirdBaseRunner.isRunning = true;
			local tTime;
			local remainingDistance = math.sqrt((thirdBaseRunner.x - homePlate.x)^2 + (thirdBaseRunner.y - homePlate.y)^2);
			local fullDistance = math.sqrt((thirdBase.x - homePlate.x)^2 + (thirdBase.y - homePlate.y)^2);
			local remainPercentage = remainingDistance / fullDistance;
			tTime = remainPercentage * 4000;
			thirdBaseRunner.myTrans = transition.to(thirdBaseRunner, {time = tTime, x = homePlate.x, y = homePlate.y, onComplete=runnerHomeReached});
		end
	end
	
	if(aSBRunner == true) then
		if(runnerToThird == false) then
			if(secondBaseRunner.myTrans ~= nil) then
				transition.cancel(secondBaseRunner.myTrans);
			end
			if(kickBall.isInAir == true) then
				secondBaseRunner.isTaggedUp = false;
			else
				secondBaseRunner.isTaggedUp = true;
			end
			runnerToThird = true;
			secondBaseRunner.isRunning = true;
			local tTime;
			local remainingDistance = math.sqrt((secondBaseRunner.x - thirdBase.x)^2 + (secondBaseRunner.y - thirdBase.y)^2);
			local fullDistance = math.sqrt((secondBase.x - thirdBase.x)^2 + (secondBase.y - thirdBase.y)^2);
			local remainPercentage = remainingDistance / fullDistance;
			tTime = remainPercentage * 4000;
			secondBaseRunner.myTrans = transition.to(secondBaseRunner, {time = tTime, x = thirdBase.x, y = thirdBase.y, onComplete=runnerThirdReached});
		end
	end
	
	if(aFBRunner == true) then
		if(runnerToSecond == false) then
			if(firstBaseRunner.myTrans ~= nil) then
				transition.cancel(firstBaseRunner.myTrans);
			end
			if(kickBall.isInAir == true) then
				firstBaseRunner.isTaggedUp = false;
			else
				firstBaseRunner.isTaggedUp = true;
			end
			runnerToSecond = true;
			firstBaseRunner.isRunning = true;
			local tTime;
			local remainingDistance = math.sqrt((firstBaseRunner.x - secondBase.x)^2 + (firstBaseRunner.y - secondBase.y)^2);
			local fullDistance = math.sqrt((firstBase.x - secondBase.x)^2 + (firstBase.y - secondBase.y)^2);
			local remainPercentage = remainingDistance / fullDistance;
			tTime = remainPercentage * 4000;
			firstBaseRunner.myTrans = transition.to(firstBaseRunner, {time = tTime, x = secondBase.x, y = secondBase.y, onComplete=runnerSecondReached});
		end
	end
end

local function runBackButtonTouch(event)
	if(aTBRunner == true) then
		if(thirdBaseRunner.myTrans ~= nil) then
			transition.cancel(thirdBaseRunner.myTrans);
		end
		runnerToThird = true;
		runnerToHome = false;
		thirdBaseRunner.isRunning = true;
		local tTime;
		local remainingDistance = math.sqrt((thirdBaseRunner.x - thirdBase.x)^2 + (thirdBaseRunner.y - thirdBase.y)^2);
		local fullDistance = math.sqrt((homePlate.x - thirdBase.x)^2 + (homePlate.y - thirdBase.y)^2);
		local remainPercentage = remainingDistance / fullDistance;
		tTime = remainPercentage * 4000;
		thirdBaseRunner.myTrans = transition.to(thirdBaseRunner, {time = tTime, x = thirdBase.x, y = thirdBase.y, onComplete=runnerBackThirdReached});
	end
	
	if(aSBRunner == true) then
		if(secondBaseRunner.myTrans ~= nil) then
			transition.cancel(secondBaseRunner.myTrans);
		end
		runnerToSecond = true;
		secondBaseRunner.isRunning = true;
		local tTime;
		local remainingDistance = math.sqrt((secondBaseRunner.x - secondBase.x)^2 + (secondBaseRunner.y - secondBase.y)^2);
		local fullDistance = math.sqrt((thirdBase.x - secondBase.x)^2 + (thirdBase.y - secondBase.y)^2);
		local remainPercentage = remainingDistance / fullDistance;
		tTime = remainPercentage * 4000;
		secondBaseRunner.myTrans = transition.to(secondBaseRunner, {time = tTime, x = secondBase.x, y = secondBase.y, onComplete=runnerBackSecondReached});
	end
	
	if(aFBRunner == true) then
		if(firstBaseRunner.myTrans ~= nil) then
			transition.cancel(firstBaseRunner.myTrans);
		end
		runnerToFirst = true;
		firstBaseRunner.isRunning = true;
		local tTime;
		local remainingDistance = math.sqrt((firstBaseRunner.x - firstBase.x)^2 + (firstBaseRunner.y - firstBase.y)^2);
		local fullDistance = math.sqrt((secondBase.x - firstBase.x)^2 + (secondBase.y - firstBase.y)^2);
		local remainPercentage = remainingDistance / fullDistance;
		tTime = remainPercentage * 4000;
		firstBaseRunner.myTrans = transition.to(firstBaseRunner, {time = tTime, x = firstBase.x, y = secondBase.y, onComplete=runnerBackFirstReached});
	end
end

function scene:createScene(event)
	closestPlayer = nil;
	minDistance = nil;
	runnerToFirst = false;
	runnerToSecond = false;
	runnerToThird = false;
	runnerToHome = false;
	local group = self.view;
	physics.start();
	physics.setGravity(0,0);
	--For now white background
	local background = display.newRect(0,0, display.contentWidth, display.contentHeight);
	background:setFillColor(255,255,255);
	group:insert(background);
	
	local wall = display.newRect(-display.contentWidth,-100, display.contentWidth * 3, 50);
	wall.alpha = 0;
	wall.myName = "wall";
	group:insert(wall);
	
	playerTable = display.newGroup();
	
	physics.addBody(wall, {density = 1.0, friction = 0.3, bounce = 0.2, isSensor = true});	
	
	--NEED LINEUP FOR TEAM TO ADD PLAYERS ON FIELD
	local teamID, lineupPos;
	for row in db:nrows("SELECT currentinning, currenthalf, hometeamid, awayteamid, playercontrolledteamid, cpucontrolledteamid, currentouts FROM game") do
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
		currentouts = row.currentouts;
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
			p.sex = row.sex;
			playerTable:insert(p);
		elseif(row.position == 'C') then
			c = createPlayer(display.contentWidth / 2, display.contentHeight + 4, colorOfBox);
			c.pos = 'C';
			c.sex = row.sex;
			playerTable:insert(c);
		elseif(row.position == '3B') then
			b3 = createPlayer(display.contentWidth / 2 - 70,display.contentHeight / 2 + 40, colorOfBox);
			b3.pos = '3B';
			b3.sex = row.sex;
			playerTable:insert(b3);
		elseif(row.position == 'SS') then
			ss = createPlayer(display.contentWidth / 2 - 40,display.contentHeight / 2 - 10,colorOfBox);
			ss.pos = 'SS';
			ss.sex = row.sex;
			playerTable:insert(ss);
		elseif(row.position == '2B') then
			b2 = createPlayer(display.contentWidth / 2 + 40, display.contentHeight / 2 - 10, colorOfBox)
			b2.pos = '2B';
			b2.sex = row.sex;
			playerTable:insert(b2);
		elseif(row.position == '1B') then
			b1 = createPlayer(display.contentWidth / 2 + 70, display.contentHeight / 2 + 40, colorOfBox);
			b1.pos = '1B';
			b1.sex = row.sex;
			playerTable:insert(b1);
		elseif(row.position == 'LF') then
			lf = createPlayer(display.contentWidth / 2 - 150, display.contentHeight / 2 - 40, colorOfBox);
			lf.pos = 'LF';
			lf.sex = row.sex;
			playerTable:insert(lf);
		elseif(row.position == 'LCF') then
			lcf = createPlayer(display.contentWidth / 2 - 75, display.contentHeight / 4 - 15, colorOfBox);
			lcf.pos = 'LCF';
			lcf.sex = row.sex;
			playerTable:insert(lcf);
		elseif(row.position == 'CF') then
			cf = createPlayer(display.contentWidth / 2, 20, colorOfBox);
			cf.pos = 'CF';
			cf.sex = row.sex;
			playerTable:insert(cf);
		elseif(row.position == 'RCF') then
			rcf = createPlayer(display.contentWidth / 2 + 75, display.contentHeight / 4 - 15, colorOfBox);
			rcf.pos = 'RCF';
			rcf.sex = row.sex;
			playerTable:insert(rcf);
		elseif(row.position == 'RF') then
			rf = createPlayer(display.contentWidth / 2 + 150, display.contentHeight / 2 - 40, colorOfBox);
			rf.pos = 'RF';
			rf.sex = row.sex;
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
	
	homePlate = display.newRect(0,0,7,7);
	homePlate:rotate(45);
	homePlate.x = display.contentWidth / 2;
	homePlate.y = display.contentHeight - 18;
	homePlate:setFillColor(0,0,0);
	group:insert(homePlate);
	
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
	keepRunning = false;
	
	holdButton = widget.newButton
	{
		top = 0,
		left = 0,
		width = 150,
		height = 45,
		font = "BORG9",
		fontSize = 24,
		labelColor =
		{ 
			default = { 255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = 'images/mainMenuItem.png',
		overFile = 'images/mainMenuItemOver.png',
		id = 'holdButton',
		label = 'Hold',
		onEvent = holdButtonTouch
	};
	holdButton.x = display.contentWidth / 2 - 180;
	holdButton.y = display.contentHeight / 2 + 100;
	if(fieldIsCPU == true) then
		group:insert(holdButton);
	end
	
	runForwardButton = widget.newButton
	{
		top = 0,
		left = 0,
		width = 90,
		height = 45,
		font = "BORG9",
		fontSize = 24,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255}
		},
		defaultFile = 'images/mainMenuItem.png',
		overFile = 'images/mainMenuItemOver.png',
		id = 'runForwardButton',
		label = 'RUN',
		onEvent = runForwardButtonTouch
	};
	runForwardButton.x = display.contentWidth / 2 + 125;
	runForwardButton.y = display.contentHeight / 2 + 100;
	if(fieldIsCPU == true) then
		group:insert(runForwardButton);
	end
	
	runBackButton = widget.newButton
	{
		top = 0,
		left = 0,
		width = 90,
		height = 45,
		font = "BORG9",
		fontSize = 24,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255}
		},
		defaultFile = 'images/mainMenuItem.png',
		overFile = 'images/mainMenuItemOver.png',
		id = 'runBackButton',
		label = 'BACK',
		onEvent = runBackButtonTouch
	};
	runBackButton.x = display.contentWidth / 2 + 220;
	runBackButton.y = display.contentHeight / 2 + 100;
	if(fieldIsCPU == true) then
		group:insert(runBackButton);
	end
	
	row = nil;
	for row in db:nrows("SELECT firstbaserunner, secondbaserunner, thirdbaserunner from GAME") do	
		if(row.firstbaserunner ~= 0) then
			firstBaseRunner = display.newRect(0,0,10,10);
			firstBaseRunner:rotate(45);
			firstBaseRunner.x = firstBase.x;
			firstBaseRunner.y = firstBase.y;
			firstBaseRunner:setFillColor(175,175,175);
			aFBRunner = true;
			firstBaseRunner.isRunning = false;
			firstBaseRunner.isTaggedUp = true;
			group:insert(firstBaseRunner);
		else
			aFBRunner = false;
		end
		
		if(row.secondbaserunner ~= 0) then
			secondBaseRunner = display.newRect(0,0,10,10);
			secondBaseRunner:rotate(45);
			secondBaseRunner.x = secondBase.x;
			secondBaseRunner.y = secondBase.y;
			secondBaseRunner:setFillColor(175,175,175);
			aSBRunner = true;
			secondBaseRunner.isRunning = false;
			secondBaseRunner.isTaggedUp = true;
			group:insert(secondBaseRunner);
		else
			aSBRunner = false;
		end
		
		if(row.thirdbaserunner ~= 0) then
			thirdBaseRunner = display.newRect(0,0,10,10);
			thirdBaseRunner:roate(45);
			thirdBaseRunner.x = thirdBase.x;
			thirdBaseRunner.y = thirdBase.y;
			thirdBaseRunner:setFillColor(175,175,175);
			aTBRunner = true;
			thirdBaseRunner.isRunning = false;
			thirdBaseRunner.isTaggedUp = true;
			group:insert(thirdBaseRunner);
		else
			aTBRunner = false;
		end
	end
	
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
		local buntDist = math.random(0, 100);
		setDistance = buntDist * distanceMultiplier;
	elseif(power == 2) then
		local contactDist = math.random(50,125);
		setDistance = contactDist * distanceMultiplier;
	else
		local powerDist = math.random(100,150);
		setDistance = powerDist * distanceMultiplier;
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
		maxDistance = 100;
	elseif(power == 2) then
		maxDistance = 375;
	else
		maxDistance = 450;
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