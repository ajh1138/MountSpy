-- Props to SDPhantom for good info originally posted at http://www.wowinterface.com/forums/showthread.php?p=314065
local _, MountSpy = ...;

local PrefixHexColor = "2B98FF";

MountSpy.Props = {Version = "10.00.05-03", PrintPrefix = "|cFF" .. PrefixHexColor .. "Mount Spy:|r", LegionMountIds = {}, NotReallyAMountSpellID = 999999, TargetedPlayerSpellLimit = 20}

function MountSpy.Print(msg, ...)
    local msgConcat = msg;
    for i = 1, select('#', ...) do
        msgConcat = msgConcat .. ' ' .. tostring(select(i, ...));
    end

    local ChatFrameRef = _G[MountSpyChatFrameName];
    ChatFrameRef:AddMessage(MountSpy.Props.PrintPrefix .. msgConcat);
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
        targetLinkString = "|cff" .. targetLinkColor .. "|Hplayer:" .. targetName .. "|h[" .. targetName .. "]|h|r";
    else
        targetLinkColor = "FF3333";
        targetLinkString = "|cff" .. targetLinkColor .. "" .. targetName .. "|h|r";
    end

    return targetLinkString;
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
        if not isPlayerCharacter then
            isValidTarget = false;
        end
    end

    return isValidTarget;
end

function MountSpy_IsThisADruidForm(creatureName)
    if (creatureName == "Bear Form") or (creatureName == "Travel Form") or (creatureName == "Cat Form") then
        return true;
    else
        return false;
    end
end

function MountSpy_IsAlreadyMountedOnMatch(targetMountId)
    -- Tired of screwing with this function.  I need to get somebody to help me test it.
    -- better to just iterate through the player's active spells and see if there's a match there.

    -- local myMountId, name, _, _, summoned, mountType = GetCompanionInfo("MOUNT", 1);
    -- MountSpy.Debug("my mount: ", myMountId);
    -- local isAlready = false;

    -- if myMountId == targetMountId then
    -- 	isAlready = true;
    -- end

    return false;
end

function MountSpy_MakeAchievementLink(sourceText)
    local newSourceText = "";

    for i = 1, #MountSpy_Achievements do
        local fromTbl = MountSpy_Achievements[i].name;

        local achFound = string.find(string.lower(sourceText), string.lower(fromTbl), nil, true);

        if achFound then
            local cheeveId = MountSpy_Achievements[i].id;
            local achievementLink = GetAchievementLink(cheeveId);

            newSourceText = "|cffFFD700|hAchievement:|r " .. achievementLink;
            break
        end
    end

    -- in case the achievement isn't found.
    if newSourceText == "" then
        newSourceText = sourceText;
    end

    return newSourceText;
end

function MountSpy:Init()
    MountSpy:InitSavedVariables();

    if not MountSpySuppressLoadingMessages then
        MountSpy.Print("MountSpy", MountSpy.Version, "is loading.");
    end

    MountSpy.Debug("init. ", "auto:", MountSpyAutomaticMode, "debug:", MountSpy.DebugMode, "hidden:", MountSpyHidden);

    MountSpy_ActiveModeCheckButton:SetChecked(MountSpyAutomaticMode);

    if MountSpyHidden then
        MountSpy_HideUI();
    end

    C_Timer.After(6, MountSpy_SetAutoModeDisplay);

    C_Timer.After(10, MountSpy.LoadMountIdList);

    C_Timer.After(15, MountSpy_PrintCurrentStatus);
end

function MountSpy_OnPlayerTargetChanged()
    if MountSpyAutomaticMode == false then
        return;
    end

    local targetId = UnitGUID("target");

    if targetId == nil then
        MountSpy.Print("DEBUG: no target!");
        return;
    end

    if MountSpyIgnoreSelf then
        local playerId = UnitGUID("player");
        if targetId == playerId then
            MountSpy.Print("DEBUG: stop clicking yourself.", playerId);
            return;
        end
    end

    if MountSpyDisableInCombat then
        if InCombatLockdown() then
            return;
        end
    end

    if MountSpyDisableInBattlegrounds then
        local bgNum = UnitInBattleground("player");
        MountSpy.Print("DEBUG: what's my num in this bg?", bgNum);
        if bgNum ~= nil then
            return;
        end
    end

    if MountSpyDisableInArenas then
        -- check to see if they're in an arena...
        local isArena, _ = IsActiveBattlefieldArena();
        MountSpy.Print("DEBUG: is arena?", isArena);
        if isArena then
            return
        end
    end

    if MountSpyDisableInInstances then
        local instanceName, instanceType = GetInstanceInfo();
        MountSpy.Print("DEBUG: instance?", instanceName, "type: ", instanceType);
        if instanceType ~= "none" then
            return;
        end
    end

    MountSpy_ValidateAndTell();
end

function MountSpy.Debug(...)
    if MountSpy.DebugMode == false then
        return;
    end

    local msg = "|cFFFF0000MountSpy debug:|r ";

    print(msg, ...); -- do NOT use MountSpy.Print here! vars might not be initialized yet. --
end

function MountSpy_ShowHelp()
    MountSpy.Print("commands:\n", "show - Shows the UI\n", "hide - Hides the UI\n", "getinfo - Gets info about the targeted player's mount\n", "match - Attempts to put you on a mount that matches the target's mount\n", "quiet - Toggles the messages displayed at login\n", "history - Lists mounts that were spotted recently\n", "clearhistory - Clears the mount history list\n", "version - Displays the version number of this addon");
end

function MountSpy_ReceiveCommand(msg, ...)
    -- MountSpy.Debug(msg, MountSpy.DebugMode);

    msg = strtrim(msg);

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
        MountSpy.Print("version", MountSpy.Version);
    elseif msg == "vars" then
        MountSpy_SayVariables();
    elseif msg == "debug" then
        MountSpy.ToggleDebugMode();
    elseif msg == "quiet" then
        MountSpy.ToggleQuietMode();
    elseif msg == "ignoreself" then
        MountSpy.ToggleIgnoreSelf();
    elseif string.find(msg, "setwindow ") and string.find(msg, "setwindow ") > 0 then
        MountSpy_SetChatFrameName(msg);
    elseif string.find(msg, "?") and string.find(msg, "?") > 0 then
        MountSpy.StringSearch(msg);
    else
        MountSpy.Print("Unknown command.");
    end
end

-- startup events --
function MountSpy_OnEvent(self, eventName, ...)
    local arg1 = ...;
    -- MountSpy.Debug("event happened: ", arg1, eventName );

    if eventName == "PLAYER_TARGET_CHANGED" then
        MountSpy_OnPlayerTargetChanged();
    end

    if eventName == "ADDON_LOADED" and arg1 == "MountSpy" then
        self:RegisterEvent("PLAYER_TARGET_CHANGED");
        self:RegisterEvent("VARIABLES_LOADED");

        MountSpy.Print("calling init.");
        MountSpy:Init();
    end

    if eventName == "PLAYER_LOGIN" then
    end
end

SlashCmdList["MOUNTSPY_SLASHCMD"] = function(msg)
    MountSpy_ReceiveCommand(msg);
end
SLASH_MOUNTSPY_SLASHCMD1 = "/mountspy";
