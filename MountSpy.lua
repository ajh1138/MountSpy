-- Props to SDPhantom for good info originally posted at http://www.wowinterface.com/forums/showthread.php?p=314065
local MountSpyPrintHexColor = "2B98FF";
local MountSpyPrintPrefix = "|cFF" .. MountSpyPrintHexColor .. "Mount Spy:|r";
local NOT_REALLY_A_MOUNT_SPELLID = 999999;
local MOUNTSPY_VERSION = "10.00.05-01";

-- If a targeted player has more than TARGETED_PLAYER_SPELL_LIMIT spells/buffs on them,
-- abort the mount check because the loop will be really slow.
-- This happens mostly in battlegrounds. 
local TARGETED_PLAYER_SPELL_LIMIT = 20;

local legionMountIds = {};

function MountSpyPrint(msg, ...)
	for i = 1, select('#', ...) do
		msg = msg .. ' ' .. select(i, ...)
	end
	local ChatFrameName = "DEFAULT_CHAT_FRAME"
	--GrimNotepad Change - use my other chat frame "4"	
	--ChatFrameName = "ChatFrame4"
	local ChatFrameRef = _G[ChatFrameName];
	ChatFrameRef:AddMessage(MountSpyPrintPrefix .. msg);
end


function MountSpy_LoadMountIdList()
    legionMountIds = C_MountJournal.GetMountIDs();
end

function MountSpy_SetAutoModeDisplay()
    getglobal(MountSpy_ActiveModeCheckButton:GetName() .. "Text"):SetText(
        "Automatic Mode");
end

function MountSpy_MatchMountButtonClick()
    local isValidTarget = MountSpy_CheckForValidTarget();

    if isValidTarget then
        -- local targetName = UnitName("target");
        local targetMountData = MountSpy_GetTargetMountData();
        -- MountSpy_TellTargetMountInfo(targetName, targetMountData);
        MountSpy_AttemptToMount(targetMountData);
    end
end

function MountSpy_CheckAndShowTargetMountInfo()
  -- Note: more steps than an automatic mode target change.
  local aTargetIsSelected = MountSpy_CheckForASelectedTarget();

  if aTargetIsSelected then
        MountSpy_ValidateAndTell(); -- ValidateAndTell only prints data if the target is a player and is mounted, so...

    local targetLinkString = MountSpy_MakeTargetLinkString();

		if not UnitIsPlayer("target") then
			MountSpyPrint(targetLinkString,"is not a player character.")
		else
			local targetMountData = MountSpy_GetTargetMountData();
			if not targetMountData then
				MountSpyPrint(targetLinkString,"is not mounted.");
			end
		end
	else
		MountSpyPrint("No target selected.");
	end
end

function MountSpy_GetInfoButtonClick() MountSpy_CheckAndShowTargetMountInfo(); end

function MountSpy_ActiveModeCheckButtonClick()
    MountSpyAutomaticMode = MountSpy_ActiveModeCheckButton:GetChecked();

    if MountSpyAutomaticMode then MountSpy_ValidateAndTell(); end
end

function MountSpy_GetTargetBuffCount()
    local buffCount = 0;

    while true do

        local spellName = UnitBuff("target", buffCount + 1);

        if not spellName then
            break
        else
            buffCount = buffCount + 1;
        end

    end

    return buffCount;
end

function MountSpy_ValidateAndTell()
    local isValidTarget = MountSpy_CheckForValidTarget();

    if isValidTarget then
        local targetName = UnitName("target");
        local targetMountData = MountSpy_GetTargetMountData();

        MountSpy_TellTargetMountInfo(targetName, targetMountData);
    end
end

function MountSpy_MakeTargetLinkString()
    local targetLinkColor = "";
    local targetLinkString = "bleh";
    local targetName = UnitName("target");

    if UnitIsFriend("target", "player") then
        targetLinkColor = "00FF00";
        targetLinkString = "|cff" .. targetLinkColor .. "|Hplayer:" ..
                               targetName .. "|h[" .. targetName .. "]|h|r";
    else
        targetLinkColor = "FF3333";
        targetLinkString = "|cff" .. targetLinkColor .. "" .. targetName ..
                               "|h|r";
    end

    return targetLinkString;
end

function MountSpy_BuildMountInfoToPrint(targetName, targetMountData)
    if not targetName then
        mountspydebug("Error - No target.");
        return "";
    end

    local targetLinkString = MountSpy_MakeTargetLinkString();
    local resultString = "";

    if targetMountData ~= nil and targetMountData.spellId ~=
        NOT_REALLY_A_MOUNT_SPELLID then
        local mountLinkString = MountSpy_MakeMountChatLink(targetMountData);
        resultString = targetLinkString .. " is riding " .. mountLinkString ..
                           ".  ";
        local playerHasMatchingMount = MountSpy_DoesPlayerHaveMatchingMount(
                                           targetMountData);

        -- override some stuff if target is the player...
        if targetName == UnitName("player") then
            playerHasMatchingMount = true;
            resultString = "You are riding " .. mountLinkString .. ".  ";
        end

        if playerHasMatchingMount then
            if targetName == UnitName("player") then
                resultString = resultString
            else
                resultString = resultString ..
                                   "|cffCCFFCC  You have this mount.|h|r"
            end
        else
            if targetMountData.creatureName ~= "Travel Form" then
                resultString = resultString ..
                                   "|cffFFCCCC Your character does not have this mount.|h|r";
            end
        end
    else
        if (targetMountData ~= nil) and
            (targetMountData.spellId == NOT_REALLY_A_MOUNT_SPELLID) then
            local creatureName = strtrim(targetMountData.creatureName);

            if MountSpy_IsThisADruidForm(creatureName) then
                resultString = targetLinkString .. " is in " .. creatureName ..
                                   ".";
            elseif creatureName == "Tarecgosa's Visage" then
                resultString = targetLinkString .. " is transformed into " ..
                                   creatureName;
            end
        end
    end

    return resultString;
end

function MountSpy_TellTargetMountInfo(targetName, targetMountData)
    local mountInfoToPrint = MountSpy_BuildMountInfoToPrint(targetName,
                                                            targetMountData);

    if mountInfoToPrint ~= '' then
        MountSpyPrint(mountInfoToPrint);
        MountSpy_AddToHistory(mountInfoToPrint);
    end
end

function MountSpy_CheckForASelectedTarget()
    local targetName = UnitName("target");

    if not targetName then
        return false;
    else
        return true;
    end
end

function MountSpy_CheckForValidTarget()
    local isValidTarget = true;

    local targetName = UnitName("target");

    if not targetName then
        isValidTarget = false;
        return false;
    end

    -- is target a player?
    if isValidTarget then
        local isPlayerCharacter = UnitIsPlayer("target");
        if not isPlayerCharacter then isValidTarget = false; end
    end

    return isValidTarget;
end

function MountSpy_GetTargetMountData()
    local targetMountData = nil;

    local targetName, realmName = UnitName("target");

    if not targetName then
        mountspydebug("no target name")
        return nil;
    end

	local buffCount = MountSpy_GetTargetBuffCount();
	if buffCount > TARGETED_PLAYER_SPELL_LIMIT then
		MountSpyPrint("Target has too many active spells.");
		return nil;
	end


    -- iterate through target's buffs to see if any of them are mounts.
    local spellIterator = 1;

    while true do

        local spellName, _, _, _, _, _, _, _, _, spellId = UnitBuff("target",
                                                                    spellIterator);

        -- mountspydebug("iterator:", spellIterator, "spell name:", spellName, "spell id:", spellId);

        if not spellName then break end

        spellIterator = spellIterator + 1;

        local testForMount = MountSpy_GetMountInfoBySpellId(spellId);

        if testForMount ~= nil then
            targetMountData = testForMount;
            break
        else
            -- Check for Travel Form, etc.
            if MountSpy_IsThisADruidForm(spellName) then
                targetMountData = {
                    creatureName = spellName,
                    spellId = NOT_REALLY_A_MOUNT_SPELLID
                };
                break
            else
                if spellName == "Tarecgosa's Visage" then
                    targetMountData = {
                        creatureName = spellName,
                        spellId = NOT_REALLY_A_MOUNT_SPELLID
                    };
                    break
                end
            end
        end
    end -- end of buff iterator loop

    return targetMountData;
end

function MountSpy_IsThisADruidForm(creatureName)
    if (creatureName == "Bear Form") or (creatureName == "Travel Form") or
        (creatureName == "Cat Form") then
        return true;
    else
        return false;
    end
end

function MountSpy_GetMountInfoBySpellId(spellId)
    local mountInfo = nil;

    for i, v in ipairs(legionMountIds) do
        local thisMountId = tonumber(legionMountIds[i]);
        local creatureName, blehSpellId, icon, active, isUsable, sourceType,
              isFavorite, isFactionSpecific, faction, isFiltered, isCollected,
              blorp = C_MountJournal.GetMountInfoByID(thisMountId);
        local thisTest = {
            mountId = thisMountId,
            creatureName = creatureName,
            collected = isCollected,
            index = i,
            spellId = blehSpellId
        };

        if tonumber(thisTest.spellId) == tonumber(spellId) then
            mountInfo = thisTest;
            break
        end
    end

    --	mountspydebug("mountInfo:", mountInfo);
    return mountInfo;
end

function MountSpy_DoesPlayerHaveMatchingMount(targetMountData)
    local canHaz = targetMountData.collected;

    return canHaz;
end

function MountSpy_AttemptToMount(targetMountData)
	if not targetMountData then
		return;
	end
	
	local hasMatchingMount = MountSpy_DoesPlayerHaveMatchingMount(targetMountData);

	if hasMatchingMount then
		local safeToProceed = true;

		local alreadyMountedOnMatch = MountSpy_IsAlreadyMountedOnMatch(targetMountData.mountId);
		mountspydebug("already mounted on match? ", alreadyMountedOnMatch);
		-- Must not be in flight...
		local flying = IsFlying();
		if flying then
			safeToProceed = false;
			MountSpyPrint("Cannot switch mounts while flying.  That would be bad.");
			return;
		end

        if safeToProceed and alreadyMountedOnMatch ~= true then
            C_MountJournal.SummonByID(targetMountData.mountId);
        end -- end of proceed check
    end
end

function MountSpy_IsAlreadyMountedOnMatch(targetMountId)
    -- Tired of screwing with this function.  I need to get somebody to help me test it.
    -- better to just iterate through the player's active spells and see if there's a match there.

    -- local myMountId, name, _, _, summoned, mountType = GetCompanionInfo("MOUNT", 1);
    -- mountspydebug("my mount: ", myMountId);
    -- local isAlready = false;

    -- if myMountId == targetMountId then
    -- 	isAlready = true;
    -- end

    return false;
end

function MountSpy_MakeMountChatLink(targetMountData)
    local linkText = GetSpellLink(targetMountData.spellId);

    local skipExtraInfoCheck = MountSpy_CheckForNonMountBuffs(targetMountData);

    if skipExtraInfoCheck then

    else
        local _, descriptionText, sourceText =
            C_MountJournal.GetMountInfoExtraByID(targetMountData.mountId);

        if sourceText ~= nil then
            sourceText = string.gsub(sourceText, "|n", " ");
            sourceText = string.gsub(sourceText, "  ", " ");
            sourceText = strtrim(sourceText);

            if string.find(sourceText, "Achievement:") then
                sourceText = MountSpy_MakeAchievementLink(sourceText);
            end

            linkText = linkText .. ", From " .. sourceText;
        else
            linkText = linkText .. " No additional info available.";
        end
    end

    return linkText;
end

function MountSpy_MakeAchievementLink(sourceText)
    local newSourceText = "";

    for i = 1, #MountSpy_Achievements do
        local fromTbl = MountSpy_Achievements[i].name;

        local achFound = string.find(string.lower(sourceText),
                                     string.lower(fromTbl), nil, true);

        if achFound then
            local cheeveId = MountSpy_Achievements[i].id;
            local cheeveName = MountSpy_Achievements[i].name;

            local achievementLink = GetAchievementLink(cheeveId);

            newSourceText = "|cffFFD700|hAchievement:|r " .. achievementLink; -- string.gsub(sourceText, cheeveName, achievementLink .. " ");
            break
        end
    end

    -- in case the achievement isn't found.
    if newSourceText == "" then newSourceText = sourceText; end

    return newSourceText;
end

function MountSpy_ScrubSpecialCharsForFind(stringIn)
    local stringOut = string.gsub(stringIn, "%(", "%%(");
    stringOut = string.gsub(stringOut, "%)", "%%)");

    return stringOut;
end

function MountSpy_CheckForNonMountBuffs(targetMountData)
    local nonMountBuffs = {
        "Travel Form", "Cat Form", "Bear Form", "Tarecgosa's Visage"
    };

    local nonMountFound = false;

    for i, v in ipairs(nonMountBuffs) do
        if v == targetMountData.creatureName then nonMountFound = true; end
    end

    if nonMountFound then
        return true;
    else
        return false;
    end
end

function MountSpy_StringSearch(msg)
    local searchString = string.gsub(msg, "?", "");
    searchString = strtrim(searchString);
    mountspydebug("." .. searchString .. ".");

    local resultsWereFound = false;
    local searchResults = {};

    for i, v in ipairs(legionMountIds) do
        local thisMountId = tonumber(legionMountIds[i]);
        local creatureName, blehSpellId, icon, active, isUsable, sourceType,
              isFavorite, isFactionSpecific, faction, isFiltered, isCollected,
              blorp = C_MountJournal.GetMountInfoByID(thisMountId);
        local thisTest = {
            mountId = thisMountId,
            creatureName = creatureName,
            collected = isCollected,
            index = i,
            spellId = blehSpellId
        };

        if string.find(string.lower(thisTest.creatureName),
                       string.lower(searchString)) ~= nil then
            resultsWereFound = true;
            local chatLink = MountSpy_MakeMountChatLink(thisTest);
            MountSpyPrint("result:", chatLink);
        end
    end

    if resultsWereFound == false then MountSpyPrint("No results found."); end
end

function MountSpy_ToggleUI(msg, editbox)
    local isShown = MountSpy_MainFrame:IsShown();

    if isShown then
        MountSpy_HideUI();
        MountSpyHidden = true;
    else
        MountSpy_ShowUI();
        MountSpyHidden = false;
    end
end

function MountSpy_ShowUI(msg, editbox)
    MountSpy_MainFrame:Show();
    MountSpyHidden = false;
end

function MountSpy_HideUI(msg, editbox)
    MountSpy_MainFrame:Hide();
    MountSpyHidden = true;
end

function MountSpy_Init()
    if not MountSpySuppressLoadingMessages then
        MountSpyPrint("MountSpy", MOUNTSPY_VERSION, "is loading.");
    end

    mountspydebug("init. ", "auto:", MountSpyAutomaticMode, "debug:",
                  MountSpyDebugMode, "hidden:", MountSpyHidden);

    if MountSpyAutomaticMode == nil then MountSpyAutomaticMode = true; end

    if MountSpyHidden == nil then MountSpyHidden = false; end

    if MountSpyDebugMode == nil then MountSpyDebugMode = false; end

    MountSpy_ActiveModeCheckButton:SetChecked(MountSpyAutomaticMode);

    if MountSpyHidden then MountSpy_HideUI(); end

    C_Timer.After(6, MountSpy_SetAutoModeDisplay);

    C_Timer.After(10, MountSpy_LoadMountIdList);

    C_Timer.After(15, MountSpy_PrintCurrentStatus);
end

function MountSpy_OnPlayerTargetChanged()
    if MountSpyAutomaticMode then MountSpy_ValidateAndTell(); end
end

function mountspydebug(...)
    if MountSpyDebugMode == false then return; end

    local msg = "|cFFFF0000MountSpy debug:|r ";

    MountSpyPrint(msg,...);
end


function MountSpy_PrintCurrentStatus()
    local statusMsg = "";

	if MountSpyHidden == true and not MountSpySuppressLoadingMessages then
		statusMsg = "The MountSpy window is hidden. Use /mountspy to show it.";
		MountSpyPrint(statusMsg);
	end
end

function MountSpy_SayVariables()
    MountSpyPrint("MountSpyHidden:", MountSpyHidden, "MountSpyDebugMode:",
                  MountSpyDebugMode, "MountSpyAutomaticMode:",
                  MountSpyAutomaticMode);
end

function MountSpy_ShowHelp()
	MountSpyPrint("commands:\n",
		"show - Shows the UI\n",
	 	"hide - Hides the UI\n",
		"getinfo - Gets info about the targeted player's mount\n",
		"match - Attempts to put you on a mount that matches the target's mount\n",
		"quiet - Toggles the messages displayed at login\n",
		"history - Lists mounts that were spotted recently\n",
		"clearhistory - Clears the mount history list\n",
		"version - Displays the version number of this addon"
	);
end

function MountSpy_ReceiveCommand(msg) 
	mountspydebug(MountSpyPrintPrefix, msg, MountSpyDebugMode);

	if msg == nil or msg == "" or msg == "show" then
		MountSpy_ShowUI();
	elseif msg == "history" or msg == "hist" then
		MountSpy_ShowHistory();
	elseif msg == "clearhistory" or msg == "clrhist" then
		MountSpy_ClearHistory();
	elseif msg == "hide" then
		MountSpy_HideUI();
	elseif msg == "help" then
		MountSpy_ShowHelp();
	elseif msg == "getinfo" then
		MountSpy_CheckAndShowTargetMountInfo();
	elseif msg == "match" then
		MountSpy_MatchMountButtonClick();
	elseif msg == "version" then
		MountSpyPrint("version", MOUNTSPY_VERSION);
	elseif msg == "vars" then
		MountSpy_SayVariables();
	elseif msg == "debug" then

		local debugStatus = "off";

		if not MountSpyDebugMode then
			MountSpyDebugMode = true;
			debugStatus = "on";
		else
			MountSpyDebugMode = false;
		end

		MountSpyPrint("MountSpy debugging is now " .. debugStatus .. ".");
	elseif msg == "quiet" then
		if not MountSpySuppressLoadingMessages then
			MountSpySuppressLoadingMessages = true;
			MountSpyPrint("Startup messages disabled.");
		else
			MountSpySuppressLoadingMessages = false;
			MountSpyPrint("Startup messages enabled.");
		end	
	elseif string.find(msg, "?") and string.find(msg, "?") > 0 then
		MountSpy_StringSearch(msg);
	else
		MountSpyPrint("Unknown command.");
	end
end

-- startup events --
function MountSpy_OnEvent(self, eventName, ...)
    local arg1 = ...;
    -- mountspydebug("event happened: ", arg1, eventName );

    if eventName == "PLAYER_TARGET_CHANGED" then
        MountSpy_OnPlayerTargetChanged();
    end

    if eventName == "ADDON_LOADED" and arg1 == "MountSpy" then
        MountSpy_Init();
        self:RegisterEvent("PLAYER_TARGET_CHANGED");
    end
end

function MountSpy_OnLoad(frame) mountspydebug("OnLoad has fired."); end

function MountSpy_OnHide()
    MountSpyHidden = true;
    --	mountspydebug("frame closed.  MountSpyHidden var = " .. tostring(MountSpyHidden))
end

SlashCmdList["MOUNTSPY_SLASHCMD"] =
    function(msg) MountSpy_ReceiveCommand(msg); end
SLASH_MOUNTSPY_SLASHCMD1 = "/mountspy";
