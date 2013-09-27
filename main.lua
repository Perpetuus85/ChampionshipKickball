-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

display.setStatusBar(display.HiddenStatusBar);

local storyboard = require "storyboard";

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path );  

local tablesetup = [[CREATE TABLE IF NOT EXISTS player (playerid INTEGER PRIMARY KEY, name, sex, imageGroup);]];
db:exec( tablesetup );
tablesetup = [[CREATE TABLE IF NOT EXISTS team (teamid INTEGER PRIMARY KEY, name);]];
db:exec( tablesetup );
tablesetup = [[CREATE TABLE IF NOT EXISTS lineup (lineupid INTEGER PRIMARY KEY, teamid);]];
db:exec( tablesetup );
tablesetup = [[CREATE TABLE IF NOT EXISTS lineupdetail (detailid INTEGER PRIMARY KEY, lineupid, playerid, position);]];
db:exec( tablesetup );
tablesetup = [[CREATE TABLE IF NOT EXISTS game (gameid INTEGER PRIMARY KEY, hometeamid, awayteamid, currentinning, currenthalf, currentouts, currentstrikes, currentballs, currentfouls, homescore, awayscore, currentkicker, firstbaserunner, secondbaserunner, thirdbaserunner, playercontrolledteamid, cpucontrolledteamid);]];
db:exec( tablesetup );
local createDB = false;
for row in db:nrows("SELECT COUNT(*) as numOfRows FROM player") do
	if(row.numOfRows == 0) then
		createDB = true;
	end
end
if(createDB == true) then
	local playerData = {
		{'Eric', 'M', 1},	--1
		{'Dan', 'M', 1}, 	--2
		{'Mike', 'M', 1},	--3
		{'Joe', 'M', 1},	--4
		{'Chris', 'M', 1},	--5
		{'Todd', 'M', 1},	--6
		{'Andy', 'M', 1},	--7
		{'Jason', 'M', 2},	--8
		{'Steve', 'M', 2},	--9
		{'Keith', 'M', 2},	--10
		{'Manny', 'M', 2},	--11
		{'Larry', 'M', 2},	--12
		{'Ray', 'M', 2},	--13
		{'Damon', 'M', 2},	--14
		{'Rob', 'M', 1},	--15
		{'John', 'M', 1},	--16
		{'Levi', 'M', 1},	--17
		{'Jeremy', 'M', 1},	--18
		{'David', 'M', 1},	--19
		{'Brian', 'M', 1},	--20
		{'Peter', 'M', 1},	--21
		{'Stu', 'M', 2},	--22
		{'Liz', 'F', 3},	--23
		{'Shauna', 'F', 3},	--24
		{'Claudia', 'F', 3},--25
		{'Nikki', 'F', 3},	--26
		{'Laura', 'F', 3},	--27
		{'Chelsea', 'F', 3},--28
		{'Whitney' ,'F', 3},--29
		{'Melanie', 'F', 4},--30
		{'Christina', 'F', 4},--31
		{'Melissa', 'F', 4},--32
		{'Jennifer', 'F', 4},--33
		{'Amanda', 'F', 4},	--34
		{'Stephanie', 'F', 4},--35
		{'Kathy', 'F', 4},	--36
		{'Patricia', 'F', 3},	--37
		{'Elena', 'F', 3},	--38
		{'Morgan', 'F', 3},	--39
		{'Emily', 'F', 3},	--40
		{'Peggy', 'F', 3},	--41
		{'Renee', 'F', 3},	--42
		{'Angie', 'F', 3},	--43
		{'Mary', 'F', 4}	--44
	};
	for i = 1,44 do
		local tableFill = [[INSERT INTO player VALUES (NULL, ']]..playerData[i][1]..[[', ']]..playerData[i][2]..[[', ]]..playerData[i][3]..[[);]];
		db:exec(tableFill);
	end
end

local function onSystemEvent( event )
    if( event.type == "applicationExit" ) then             
		--DELETE ONLY ON DEBUG
		local tableDelete = [[DROP TABLE game]];
		db:exec(tableDelete);
		tableDelete = [[DROP TABLE lineupdetail]];
		db:exec(tableDelete);
		tableDelete = [[DROP TABLE lineup]];
		db:exec(tableDelete);
		tableDelete = [[DROP TABLE team]];
		db:exec(tableDelete);
		tableDelete = [[DROP TABLE player]];
		db:exec(tableDelete);
        db:close()
    end
end

Runtime:addEventListener( "system", onSystemEvent );

storyboard.gotoScene("logoscene", "fade", 400);