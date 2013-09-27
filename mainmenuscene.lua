local storyboard = require("storyboard");
local scene = storyboard.newScene();

local sp, mp, settings

local function spMenuGo(self, event)
	if(event.phase == "began") then
		storyboard.gotoScene("qplineupscene", "fade", 400)
		--storyboard.gotoScene("battingscene", "fade", 400);
		--print("go to sp menu")
	end
end

local function mpMenuGo(self, event)
	if(event.phase == "began") then
		storyboard.gotoScene("franchisemodescene", "fade", 400)
	end
end

local function settingsMenuGo(self, event)
	if(event.phase == "began") then
		storyboard.gotoScene("settingsmenuscene", "fade", 400)
	end
end

function scene:createScene(event)
	local group = self.view;
	
	local myFont = "PokemonGB";
	
	sp = display.newText("QUICK PLAY", display.contentWidth / 2, 40, myFont, 14)
	sp.x = display.contentWidth / 2;
	sp:setTextColor(255)
	group:insert(sp);
	
	sp.touch = spMenuGo;
		
	mp = display.newText("FRANCHISE MODE", display.contentWidth / 2, 90, myFont, 14)
	mp.x = display.contentWidth / 2;
	mp:setTextColor(255);
	group:insert(mp)
	
	mp.touch = mpMenuGo
		
	settings = display.newText("SETTINGS", display.contentWidth / 2, 140, myFont, 14)
	settings.x = display.contentWidth / 2;
	settings:setTextColor(255);
	group:insert(settings);
	
	settings.touch = settingsMenuGo
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("titlescene");
	sp:addEventListener("touch", sp);
	--mp:addEventListener("touch", mp);
	--settings:addEventListener("touch", settings);
end

function scene:exitScene(event)
	sp:removeEventListener("touch", sp);
	--mp:removeEventListener("touch", mp);
	--settings:removeEventListener("touch", settings);
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