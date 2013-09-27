local storyboard = require("storyboard");
local scene = storyboard.newScene();

local bx, by=0, 0 -- Create our variables for drawing the line
local lines={};
local colors, myHomePlate;
local pitchBall;

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
end


local function pitch(event)
	xRand = math.random(-200, 200);
	timer.performWithDelay(16, spawnBall, 93);
	timer.performWithDelay(5000, resetPitch);
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
	
	local countBG = display.newRoundedRect(display.contentWidth - 120, 0, 120, 80, 3);
	countBG:setFillColor(0,0,0);
	countBG.alpha = 0.5;
	group:insert(countBG);
	
	local ballCount = display.newText("Balls: ", display.contentWidth - 117, 0, pokeFont, 10);
	ballCount.y = 10;
	group:insert(ballCount);
	
	local ballOne = display.newCircle(ballCount.x + 33, ballCount.y, 5);
	ballOne:setFillColor(255,255,255);
	ballOne.alpha = 0;
	group:insert(ballOne);
	
	local ballTwo = display.newCircle(ballCount.x + 49, ballCount.y, 5);
	ballTwo:setFillColor(255,255,255);
	ballTwo.alpha = 0;
	group:insert(ballTwo);
	
	local ballThree = display.newCircle(ballCount.x + 65, ballCount.y, 5);
	ballThree:setFillColor(255,255,255);
	ballThree.alpha = 0;
	group:insert(ballThree);
	
	local strikeCount = display.newText("Strikes: ", display.contentWidth - 117, 0, pokeFont, 10);
	strikeCount.y = 30;
	group:insert(strikeCount);
	
	local strikeOne = display.newCircle(strikeCount.x + 40, strikeCount.y, 5);
	strikeOne:setFillColor(255,255,255);
	strikeOne.alpha = 0;
	group:insert(strikeOne);
	
	local strikeTwo = display.newCircle(strikeCount.x + 56, strikeCount.y, 5);
	strikeTwo:setFillColor(255,255,255);
	strikeTwo.alpha = 0;
	group:insert(strikeTwo);
	
	local foulCount = display.newText("Fouls: ", display.contentWidth - 117, 0, pokeFont, 10);
	foulCount.y = 50;
	group:insert(foulCount);
	
	local foulOne = display.newCircle(foulCount.x + 33, foulCount.y, 5);
	foulOne:setFillColor(255,255,255);
	foulOne.alpha = 0;
	group:insert(foulOne);
	
	local foulTwo = display.newCircle(foulCount.x + 49, foulCount.y, 5);
	foulTwo:setFillColor(255,255,255);
	foulTwo.alpha = 0;
	group:insert(foulTwo);
	
	local foulThree = display.newCircle(foulCount.x + 65, foulCount.y, 5);
	foulThree:setFillColor(255,255,255);
	foulThree.alpha = 0;
	group:insert(foulThree);
	
	local outCount = display.newText("Outs: ", display.contentWidth - 117, 0, pokeFont, 10);
	outCount.y = 70;
	group:insert(outCount);
	
	local outOne = display.newCircle(outCount.x + 25, outCount.y, 5);
	outOne:setFillColor(255,255,255);
	outOne.alpha = 0;
	group:insert(outOne);
	
	local outTwo = display.newCircle(outCount.x + 41, outCount.y, 5);
	outTwo:setFillColor(255,255,255);
	outTwo.alpha = 0;
	group:insert(outTwo);
	
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