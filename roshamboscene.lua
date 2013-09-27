local widget = require("widget");
local storyboard = require("storyboard");
local scene = storyboard.newScene();

require "sqlite3";
local path = system.pathForFile("data.db", system.DocumentsDirectory);
db = sqlite3.open( path );  

local chooseOne, quickPlay;
local rock, paper, scissors;
local playerSelected, cpuSelected, countdown;
local cpuRock, cpuPaper, cpuScissors;
local homeAwayLine1, homeAwayLine2, playBall;
local chooseHomeAway, homeItem, awayItem;
local homeItemExp, awayItemExp;
local backToMain;

local function onComplete(event)
	if "clicked" == event.action then
		local i = event.index
		if 1 == i then
		elseif 2 == i then
			storyboard.gotoScene("titlescene", "fade", 400);
		end
	end
end

local function backButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = backToMain.x - (backToMain.width / 2);
		local maxX = backToMain.x + (backToMain.width / 2);
		local minY = backToMain.y - (backToMain.height / 2);
		local maxY = backToMain.y + (backToMain.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			local alert = native.showAlert("Back", "Would you like to return to the main menu?", {"No", "Yes"}, onComplete);
		end
	end
end

local function transitionClear()
	if(playerSelected == 1) then
		transition.to(rock, {time = 500, alpha = 0});
	elseif(playerSelected == 2) then
		transition.to(paper, {time = 500, alpha = 0});
	else
		transition.to(scissors, {time = 500, alpha = 0});
	end
	
	if(cpuSelected == 1) then
		transition.to(cpuRock, {time = 500, alpha = 0});
	elseif(cpuSelected == 2) then
		transition.to(cpuPaper, {time = 500, alpha = 0});
	else
		transition.to(cpuScissors, {time = 500, alpha = 0});
	end
	transition.to(chooseOne, {time = 500, alpha = 0});
	transition.to(quickPlay, {time = 500, alpha = 0});
	transition.to(countdown, {time = 500, alpha = 0});
end

local function playBallTouch(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
			
		local minX = playBall.x - (playBall.width / 2);
		local maxX = playBall.x + (playBall.width / 2);
		local minY = playBall.y - (playBall.height / 2);
		local maxY = playBall.y + (playBall.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			-- go to appropriate screen
			storyboard.gotoScene("scoreboardscene", "fade", 400);
		end
	end
end

local function cpuHomeTextShow()
	quickPlay.text = "HOME / AWAY";
	
	local group = scene.view;
	homeAwayLine1 = display.newText("CPU CHOOSES HOME", 0, 0, "BORG9", 24);
	homeAwayLine1.x = display.contentWidth / 2;
	homeAwayLine1.y = display.contentHeight / 2 - 30;
	homeAwayLine1.alpha = 0;
	group:insert(homeAwayLine1);
	
	homeAwayLine2 = display.newText("YOU ARE AWAY", 0, 0, "BORG9", 24);
	homeAwayLine2.x = display.contentWidth / 2;
	homeAwayLine2.y = display.contentHeight / 2 + 10;
	homeAwayLine2.alpha = 0;
	group:insert(homeAwayLine2);
	
	local homeAwayLine3 = display.newText("(KICKS FIRST)", 0, 0, "BORG9", 24);
	homeAwayLine3.x = display.contentWidth / 2;
	homeAwayLine3.y = display.contentHeight / 2 + 50;
	homeAwayLine3.alpha = 0;
	group:insert(homeAwayLine3);
	
	playBall = widget.newButton
	{
		left = 0,
		top = 0;
		width = 210,
		height = 45,
		font = "BORG9",
		fontSize = 24,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "playBallButton",
		label = "Play Ball",
		onEvent = playBallTouch,
	};
	playBall.x = display.contentWidth / 2;
	playBall.y = display.contentHeight - 40;
	playBall.alpha = 0;
	group:insert(playBall);
	
	transition.to(quickPlay, {time = 500, alpha = 1});
	transition.to(homeAwayLine1, {time = 500, alpha = 1});
	transition.to(homeAwayLine2, {time = 500, alpha = 1});
	transition.to(homeAwayLine3, {time = 500, alpha = 1});
	transition.to(playBall, {time = 500, alpha = 1});
end

local function clearHomeAway()
	transition.to(chooseHomeAway, {time = 500, alpha = 0});
	transition.to(homeItem, {time = 500, alpha = 0});
	transition.to(awayItem, {time = 500, alpha = 0});
	transition.to(homeItemExp, {time = 500, alpha = 0});
	transition.to(awayItemExp, {time = 500, alpha = 0});
end

local function playerFinalTransition()

	local playerChosenText = "";
	local cpuIsText = "";
	
	for row in db:nrows("SELECT hometeamid, playercontrolledteamid FROM game") do
		print(row.hometeamid);
		print(row.playercontrolledteamid);
		if(row.hometeamid == row.playercontrolledteamid) then
			playerChosenText = "YOU HAVE CHOSEN HOME";
			cpuIsText = "CPU IS AWAY";
		else
			playerChosenText = "YOU HAVE CHOSEN AWAY";
			cpuIsText = "CPU IS HOME";
		end
	end

	local group = scene.view;
	homeAwayLine1 = display.newText(playerChosenText, 0, 0, "BORG9", 24);
	homeAwayLine1.x = display.contentWidth / 2;
	homeAwayLine1.y = display.contentHeight / 2 - 30;
	homeAwayLine1.alpha = 0;
	group:insert(homeAwayLine1);
	
	homeAwayLine2 = display.newText(cpuIsText, 0, 0, "BORG9", 24);
	homeAwayLine2.x = display.contentWidth / 2;
	homeAwayLine2.y = display.contentHeight / 2 + 10;
	homeAwayLine2.alpha = 0;
	group:insert(homeAwayLine2);
	
	playBall = widget.newButton
	{
		left = 0,
		top = 0;
		width = 210,
		height = 45,
		font = "BORG9",
		fontSize = 24,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "playBallButton",
		label = "Play Ball",
		onEvent = playBallTouch,
	};
	playBall.x = display.contentWidth / 2;
	playBall.y = display.contentHeight - 40;
	playBall.alpha = 0;
	group:insert(playBall);
	
	transition.to(quickPlay, {time = 500, alpha = 1});
	transition.to(homeAwayLine1, {time = 500, alpha = 1});
	transition.to(homeAwayLine2, {time = 500, alpha = 1});
	transition.to(playBall, {time = 500, alpha = 1});
end

local function homeButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = homeItem.x - (homeItem.width / 2);
		local maxX = homeItem.x + (homeItem.width / 2);
		local minY = homeItem.y - (homeItem.height / 2);
		local maxY = homeItem.y + (homeItem.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			
			--Update game, set home team to playercontrolledteamid
			local gameUpdate = [[UPDATE game SET hometeamid = playercontrolledteamid]];
			db:exec(gameUpdate);
			--set away team to other teamid
			gameUpdate = [[UPDATE game SET awayteamid = cpucontrolledteamid]];
			db:exec(gameUpdate);
			
			clearHomeAway();
			timer.performWithDelay(500, playerFinalTransition);
		end
	end
end

local function awayButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = awayItem.x - (awayItem.width / 2);
		local maxX = awayItem.x + (awayItem.width / 2);
		local minY = awayItem.y - (awayItem.height / 2);
		local maxY = awayItem.y + (awayItem.height / 2);
		
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			
			--Update game, set away team to playercontrolledteamid
			local gameUpdate = [[UPDATE game SET awayteamid = playercontrollteamid]];
			db:exec(gameUpdate);
			--set home team to other teamid
			gameUpdate = [[UPDATE game SET hometeamid = cpucontrolledteamid]];
			db:exec(gameUpdate);
			
			clearHomeAway();
			timer.performWithDelay(500, playerFinalTransition);
		end
	end
end

local function playerChooseTextShow()
	quickPlay.text = "HOME / AWAY";
	
	local group = scene.view;
	
	chooseHomeAway = display.newText("CHOOSE ONE", 0, 0, "BORG9", 24);
	chooseHomeAway.x = display.contentWidth / 2;
	chooseHomeAway.y = display.contentHeight / 2 - 50;
	chooseHomeAway.alpha = 0;
	group:insert(chooseHomeAway);
	
	homeItem = widget.newButton
	{
		left = 0,
		top = 0;
		width = 150,
		height = 55,
		font = "BORG9",
		fontSize = 36,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		labelYOffset = -3,
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "homeTeamButton",
		label = "Home",
		onEvent = homeButtonEvent,
	};
	homeItem.x = display.contentWidth / 2 - 100;
	homeItem.y = display.contentHeight / 2 + 35;
	homeItem.alpha = 0;
	group:insert(homeItem);
	
	homeItemExp = display.newText("FIELDS FIRST", 0, 0, "BORG9", 18);
	homeItemExp.x = homeItem.x;
	homeItemExp.y = homeItem.y + 30;
	homeItemExp.alpha = 0;
	group:insert(homeItemExp);
	
	awayItem = widget.newButton
	{
		left = 0,
		top = 0;
		width = 150,
		height = 55,
		font = "BORG9",
		fontSize = 36,
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		labelYOffset = -3,
		defaultFile = "images/mainMenuItem.png",
		overFile = "images/mainMenuItemOver.png",
		id = "awayTeamButton",
		label = "Away",
		onEvent = awayButtonEvent,
	};
	awayItem.x = display.contentWidth / 2 + 100;
	awayItem.y = display.contentHeight / 2 + 35;
	awayItem.alpha = 0;
	awayItem.name = "away";
	group:insert(awayItem);	
	
	awayItem.touch = homeAwayTouch;
	
	awayItemExp = display.newText("KICKS FIRST", 0, 0, "BORG9", 18);
	awayItemExp.x = awayItem.x;
	awayItemExp.y = awayItem.y + 30;
	awayItemExp.alpha = 0;
	group:insert(awayItemExp);
	
	transition.to(quickPlay, {time = 500, alpha = 1});
	transition.to(chooseHomeAway, {time = 500, alpha = 1});
	transition.to(homeItem, {time = 500, alpha = 1});
	transition.to(homeItemExp, {time = 500, alpha = 1});
	transition.to(awayItem, {time = 500, alpha = 1});
	transition.to(awayItemExp, {time = 500, alpha = 1});
	
end

local function cpuWon()
	--Update game, set away team to playercontrolledteamid
	local gameUpdate = [[UPDATE game SET awayteamid = playercontrolledteamid]];
	db:exec(gameUpdate);
	--set home team to other teamid
	gameUpdate = [[UPDATE game SET hometeamid = cpucontrolledteamid]];
	db:exec(gameUpdate);
	transitionClear();
	timer.performWithDelay(750, cpuHomeTextShow);
end

local function playerWon()
	transitionClear();
	timer.performWithDelay(750, playerChooseTextShow);
end

local function resetOnTie()
	local group = scene.view;
	if(cpuSelected == 1) then
		group:remove(cpuRock);
	elseif(cpuSelected == 2) then
		group:remove(cpuPaper);
	else
		group:remove(cpuScissors);
	end
	
	group:remove(countdown);
	countdown = nil;
	
	cpuRock = nil;
	cpuPaper = nil;
	cpuScissors = nil;
	cpuSelected = nil;
	
	rock:setEnabled(true);
	paper:setEnabled(true);
	scissors:setEnabled(true);
	
	if(playerSelected == 1) then
		transition.to(rock, {time = 250, x = 80});
	elseif(playerSelected == 2) then
		transition.to(paper, {time = 250, x = display.contentWidth / 2});
	else
		transition.to(scissors, {time = 250, x = display.contentWidth - 80});
	end
	
	transition.to(rock, {time = 125, alpha = 1});
	transition.to(paper, {time = 125, alpha = 1});
	transition.to(scissors, {time = 125, alpha = 1});
	
end

local function changeChooseOneText()
	chooseOne.text = "YOU VS CPU";
end

local function computeResults()
	local playerWin = false;
	if(cpuSelected == playerSelected) then
		countdown.text = "TIE";
		timer.performWithDelay(1000, resetOnTie);
	else
		if(cpuSelected == 1) then
			if(playerSelected == 2) then
				playerWin = true;
			end
		elseif(cpuSelected == 2) then
			if(playerSelected == 3) then
				playerWin = true;
			end
		elseif(cpuSelected == 3) then
			if(playerSelected == 1) then
				playerWin = true;
			end
		end
	
		if(playerWin == true) then
			countdown.text = "YOU WIN";
			timer.performWithDelay(1000, playerWon);
		else
			countdown.text = "CPU WINS";
			timer.performWithDelay(1000, cpuWon);
		end
	end
end

local function displayCPUSelection()
	local group = scene.view;
	if(cpuSelected == 1) then
	
		cpuRock = widget.newButton
		{
			top = 0,
			left = 0,
			width = 100,
			height = 130,
			font = "BORG9",
			fontSize = 14,
			label = "Rock",
			labelColor =
			{
				default = {255,255,255,255},
				over = {255,255,255,255},
			},
			labelYOffset = 40,
			defaultFile = "images/RockHandButton.png",
			overFile = "images/RockHandButtonOver.png",
			isEnabled = false
		}
		cpuRock.x = display.contentWidth / 2 + 75;
		cpuRock.y = display.contentHeight / 2 + 40;
		group:insert(cpuRock);
		
	elseif(cpuSelected == 2) then
	
		cpuPaper = widget.newButton
		{
			top = 0,
			left = 0,
			width = 100,
			height = 130,
			font = "BORG9",
			fontSize = 14,
			label = "Paper",
			labelColor =
			{
				default = {255,255,255,255},
				over = {255,255,255,255},
			},
			labelYOffset = 40,
			defaultFile = "images/PaperHandButton.png",
			overFile = "images/PaperHandButtonOver.png",
			isEnabled = false
		}
		cpuPaper.x = display.contentWidth / 2 + 75;
		cpuPaper.y = display.contentHeight / 2 + 40;
		group:insert(cpuPaper);
	
	else
	
		cpuScissors = widget.newButton
		{
			top = 0,
			left = 0,
			width = 100,
			height = 130,
			font = "BORG9",
			fontSize = 14,
			label = "Scissors",
			labelColor =
			{
				default = {255,255,255,255},
				over = {255,255,255,255},
			},
			labelYOffset = 40,
			defaultFile = "images/ScissorsHandButton.png",
			overFile = "images/ScissorsHandButtonOver.png",
			isEnabled = false
		}
		cpuScissors.x = display.contentWidth / 2 + 75;
		cpuScissors.y = display.contentHeight / 2 + 40;
		group:insert(cpuScissors);
	
	end
	
	timer.performWithDelay(1000, computeResults);
end

local function goCountdown()
	countdown.alpha = 1;
	if(countdown.text == "READY")then
		countdown.text = "ROCK";		
	elseif(countdown.text == "ROCK") then
		countdown.text = "PAPER";
	elseif(countdown.text == "PAPER") then
		countdown.text = "SCISSORS";
	elseif(countdown.text == "SCISSORS") then
		countdown.alpha = 1;
		countdown.text = "SHOOT";
		displayCPUSelection();
	end
	if(countdown.text ~= "SHOOT") then
		transition.to(countdown, {time = 500, alpha = 0});
	end
end

local function addCountdownText()
	local group = scene.view;
	countdown = display.newText("READY", 0, 0, "BORG9", 36);
	countdown.x = display.contentWidth / 2;
	countdown.y = display.contentHeight - 40;
	group:insert(countdown);
	transition.to(countdown, {time = 500, alpha = 0});
	timer.performWithDelay(750, goCountdown, 4);
end

local function startCPUSelection()
	timer.performWithDelay(250, changeChooseOneText);
	cpuSelected = math.random(1, 3);
	timer.performWithDelay(250, addCountdownText);	
end

local function selectedRock()
	transition.to(rock, {time = 250, x = (display.contentWidth / 2 - 75)});
	transition.to(paper, {time = 125, alpha = 0});
	transition.to(scissors, {time = 125, alpha = 0});
	playerSelected = 1;
	startCPUSelection();
end

local function selectedPaper()
	transition.to(rock, {time = 125, alpha = 0});
	transition.to(paper, {time = 250, x = (display.contentWidth / 2 - 75)});
	transition.to(scissors, {time = 125, alpha = 0});
	playerSelected = 2;
	startCPUSelection();
end

local function selectedScissors()
	transition.to(rock, {time = 125, alpha = 0});
	transition.to(paper, {time = 125, alpha = 0});
	transition.to(scissors, {time = 250, x = (display.contentWidth / 2 - 75)});
	playerSelected = 3;
	startCPUSelection();
end

local function rockButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
	
		local minX = rock.x - (rock.width / 2);
		local maxX = rock.x + (rock.width / 2);
		local minY = rock.y - (rock.height / 2);
		local maxY = rock.y + (rock.height / 2);
		--Started and finished inside the button
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			rock:setEnabled(false);
			selectedRock();
		end
	end
end

local function paperButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = paper.x - (paper.width / 2);
		local maxX = paper.x + (paper.width / 2);
		local minY = paper.y - (paper.height / 2);
		local maxY = paper.y + (paper.height / 2);
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			paper:setEnabled(false);
			selectedPaper();
		end
	end
end

local function scissorsButtonEvent(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended" or event.phase == "cancelled") then
		local minX = scissors.x - (scissors.width / 2);
		local maxX = scissors.x + (scissors.width / 2);
		local minY = scissors.y - (scissors.height / 2);
		local maxY = scissors.y + (scissors.height / 2);
		if(event.x >= minX and event.x <= maxX and 
			event.y >= minY and event.y <= maxY and
			event.xStart >= minX and event.xStart <= maxX and
			event.yStart >= minY and event.yStart <= maxY) then
			scissors:setEnabled(false);
			selectedScissors();
		end
	end
end

function scene:createScene(event)
	local group = self.view;
	
	local titleLogo = display.newImageRect("images/qpLineUpBG.jpg", 480, 320);
	titleLogo.x = display.contentWidth / 2;
	titleLogo.y = display.contentHeight / 2;
	group:insert(titleLogo);
	
	local myFont = "BORG9";
	
	quickPlay = display.newText("ROSHAMBO", 0, 0, myFont, 48);
	quickPlay.x = display.contentWidth / 2;
	quickPlay.y = 50;
	group:insert(quickPlay);
	
	chooseOne = display.newText("Choose Rock, Paper, or Scissors", 0, 0, myFont, 16);
	chooseOne.x = display.contentWidth / 2;
	chooseOne.y = 90;
	group:insert(chooseOne);
	
	rock = widget.newButton
	{
		top = 0,
		left = 0,
		width = 100,
		height = 130,
		font = "BORG9",
		fontSize = 14,
		label = "Rock",
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		labelYOffset = 40,
		defaultFile = "images/RockHandButton.png",
		overFile = "images/RockHandButtonOver.png",
		onEvent = rockButtonEvent
	}
	rock.x = 80;
	rock.y = display.contentHeight / 2 + 40;
	group:insert(rock);
	
	paper = widget.newButton
	{
		top = 0,
		left = 0,
		width = 100,
		height = 130,
		font = "BORG9",
		fontSize = 14,
		label = "Paper",
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		labelYOffset = 40,
		defaultFile = "images/PaperHandButton.png",
		overFile = "images/PaperHandButtonOver.png",
		onEvent = paperButtonEvent
	}
	paper.x = display.contentWidth / 2;
	paper.y = display.contentHeight / 2 + 40;
	paper.name = "paper";
	group:insert(paper);
	
	scissors = widget.newButton
	{
		top = 0,
		left = 0,
		width = 100,
		height = 130,
		font = "BORG9",
		fontSize = 14,
		label = "Scissors",
		labelColor =
		{
			default = {255,255,255,255},
			over = {255,255,255,255},
		},
		labelYOffset = 40,
		labelXOffset = 1,
		defaultFile = "images/ScissorsHandButton.png",
		overFile = "images/ScissorsHandButtonOver.png",
		onEvent = scissorsButtonEvent
	}
	scissors.x = display.contentWidth - 80;
	scissors.y = display.contentHeight / 2 + 40;
	scissors.name = "scissors";
	group:insert(scissors);
	
	backToMain = widget.newButton
	{
		left = 0,
		top = 0;
		width = 20,
		height = 20,
		font = "BORG9",
		defaultFile = "images/backButton.png",
		overFile = "images/backButton.png",
		id = "backButton",
		onEvent = backButtonEvent,
	};
	backToMain.x = 15;
	backToMain.y = 15;
	backToMain.name = "backToMain";
	group:insert(backToMain);
end

function scene:willEnterScene(event)
end

function scene:enterScene(event)
	storyboard.purgeScene("qplineupscene");
	storyboard.purgeScene("qpresumescene");
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