local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path );  

local backToMain, play, resume, createResume, spinnerDefault, progress;

local function goToNext()
	storyboard.gotoScene("qplineupscene", "fade", 400);
end

local function createNewGame()
	progress = 0;
	--print("Delete old game if exists");
	if(createResume == true) then
		local dbDelete = [[DELETE FROM game]];
		db:exec(dbDelete);
		dbDelete = [[DELETE FROM lineupdetail]];
		db:exec(dbDelete);
		dbDelete = [[DELETE FROM lineup]];
		db:exec(dbDelete);
		dbDelete = [[DELETE FROM team]];
		db:exec(dbDelete);
		print("Old game deleted");
	else
		--print("Old game did not exist");
	end
	--print("Creating new game");
	
	--Create two teams, Red v. Blue
	local dbTeamAdd = [[INSERT INTO team VALUES (NULL, 'Red');]];
	db:exec(dbTeamAdd);
	dbTeamAdd = [[INSERT INTO team VALUES (NULL, 'Blue');]];
	db:exec(dbTeamAdd);
	progress = progress + 0.02;
	spinnerDefault:setProgress(progress);
	--0.02
	--Create two lineups for each time
	local teamRedId, teamBlueId;
	for row in db:nrows("SELECT teamid FROM team WHERE name = 'Red'") do
		teamRedId = row.teamid;
		--print("Red lineup 1");
		local dbLineupAdd = [[INSERT INTO lineup VALUES (NULL, ]]..row.teamid..[[);]];
		db:exec(dbLineupAdd);
		--print("Red lineup 2");
		dbLineupAdd = [[INSERT INTO lineup VALUES (NULL, ]]..row.teamid..[[);]];
		db:exec(dbLineupAdd);
	end
	progress = progress + 0.02;
	spinnerDefault:setProgress(progress);
	for row in db:nrows("SELECT teamid FROM team WHERE name = 'Blue'") do
		teamBlueId = row.teamid;
		--print("Blue lineup 1");
		local dbLineupAdd = [[INSERT INTO lineup VALUES (NULL, ]]..row.teamid..[[);]];
		db:exec(dbLineupAdd);
		--print("Blue lineup 2");
		dbLineupAdd = [[INSERT INTO lineup VALUES (NULL, ]]..row.teamid..[[);]];
		db:exec(dbLineupAdd);
	end
	progress = progress + 0.02;
	spinnerDefault:setProgress(progress);
	--progress = 0.06
	
	--Retrieve 4 random males, 4 random females, and 3 random from player to add to lineupdetail
	--for each lineup
	for row in db:nrows("SELECT lineupid FROM lineup") do
		local lineupid = row.lineupid;
		local positions = {'P', 'C', '1B', '2B', 'SS', '3B', 'LF', 'LCF', 'CF', 'RCF', 'RF'};
		--print("Getting 4 males");
		for prow in db:nrows("SELECT playerid FROM player WHERE sex = 'M' AND playerid NOT IN (select playerid from lineupdetail) ORDER BY RANDOM() LIMIT 4") do
			local playerid = prow.playerid;
			--Get position randomly
			local randomIndex = math.random(1, table.getn(positions));
			local thisPosition = table.remove(positions,randomIndex);
			local dbLineupDetailAdd = [[INSERT INTO lineupdetail VALUES (NULL,]]..lineupid..[[,]]..playerid..[[,']]..thisPosition..[[');]];
			db:exec(dbLineupDetailAdd);
			progress = progress + 0.02;
			spinnerDefault:setProgress(progress);
		end
		
		--print("Getting 4 females");
		for prow in db:nrows("SELECT playerid FROM player WHERE sex = 'F' AND playerid NOT IN (select playerid from lineupdetail) ORDER BY RANDOM() LIMIT 4") do
			local playerid = prow.playerid;
			--Get position randomly
			local randomIndex = math.random(1, table.getn(positions));
			local thisPosition = table.remove(positions,randomIndex);
			local dbLineupDetailAdd = [[INSERT INTO lineupdetail VALUES (NULL,]]..lineupid..[[,]]..playerid..[[,']]..thisPosition..[[');]];
			db:exec(dbLineupDetailAdd);
			progress = progress + 0.02;
			spinnerDefault:setProgress(progress);
		end
		
		--print("Getting 3 randoms");
		for prow in db:nrows("SELECT playerid FROM player WHERE playerid NOT IN (select playerid from lineupdetail) ORDER BY RANDOM() LIMIT 3") do
			local playerid = prow.playerid;
			--Get position randomly
			local randomIndex = math.random(1, table.getn(positions));
			local thisPosition = table.remove(positions,randomIndex);
			local dbLineupDetailAdd = [[INSERT INTO lineupdetail VALUES (NULL,]]..lineupid..[[,]]..playerid..[[,']]..thisPosition..[[');]];
			db:exec(dbLineupDetailAdd);
			progress = progress + 0.02;
			spinnerDefault:setProgress(progress);
		end
	end
	--progress = 0.9
	
	--Create game record
	local dbGameAdd = [[INSERT INTO game VALUES(NULL, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0);]];
	db:exec(dbGameAdd);
	--print("Game created");
	progress = 1.0;
	spinnerDefault:setProgress(progress);
	timer.performWithDelay(2000, goToNext);
end

function scene:createScene(event)
	local group = self.view;
	
	--local titleLogo = display.newImageRect("images/qpLineUpBG.jpg", 480, 320);
	--titleLogo.x = display.contentWidth / 2;
	--titleLogo.y = display.contentHeight / 2;
	local titleLogo = display.newRect(0,0,display.contentWidth, display.contentHeight);
	titleLogo:setFillColor(0,0,0);
	group:insert(titleLogo);
	
	local myFont = "BORG9";
	
	local quickPlay = display.newText("CREATING NEW GAME ...", 0, 0, myFont, 24);
	quickPlay.x = display.contentWidth / 2;
	quickPlay.y = display.contentHeight / 2;
	group:insert(quickPlay);
	
	spinnerDefault = widget.newProgressView
	{
		width = 250,
		isAnimated = true
	};
	spinnerDefault.x = display.contentWidth / 2;
	spinnerDefault.y = display.contentHeight / 2 + 35;
	group:insert(spinnerDefault);
	
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("qpresumescene");
	createNewGame();
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