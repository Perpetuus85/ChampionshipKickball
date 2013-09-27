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
	
	pitchBall = display.newCircle(display.contentWidth / 2 - 2, 110, 2);
	pitchBall:setFillColor(255,0,0);
	pitchBall.strokeWidth = 1;
	pitchBall:setStrokeColor(0,0,0);
	group:insert(pitchBall);
	
	timer.performWithDelay(7000, pitch, 0);
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