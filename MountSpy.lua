-- Props to SDPhantom for good info originally posted at http://www.wowinterface.com/forums/showthread.php?p=314065
local _, MountSpy = ...

local PrefixHexColor = "2B98FF"

MountSpy.Version = "10.01.07-01"
MountSpy.PrintPrefix = "|cFF" .. PrefixHexColor .. "Mount Spy:|r"
MountSpy.LegionMountIds = {}
MountSpy.NOT_REALLY_A_MOUNT_SPELL_ID = 999999
MountSpy.MAXIMUM_BUFF_COUNT = 20

function MountSpy.Debug(...)
    if MountSpyDebugMode == false then
        return
    end

    local msg = "|cFFFF0000MountSpy debug:|r "

    print(msg, ...) -- do NOT use MountSpy.Print here! Vars might not be initialized yet. --
end

function MountSpy.Print(msg, ...)
    local msgConcat = msg
    for i = 1, select("#", ...) do
        msgConcat = msgConcat .. " " .. tostring(select(i, ...))
    end

    local ChatFrameRef = _G[MountSpyChatFrameName]
    ChatFrameRef:AddMessage(MountSpy.PrintPrefix .. msgConcat)
end

function MountSpy.ValidateAndTell()
    local isValidTarget = MountSpy.CheckForValidTarget()

    if isValidTarget then
        local targetName = UnitName("target")
        local targetMountData = MountSpy.GetTargetMountData()

        MountSpy.TellTargetMountInfo(targetName, targetMountData)
    end
end

function MountSpy.MakeTargetLinkString()
    local targetLinkColor = ""
    local targetLinkString = "bleh"
    local targetName = UnitName("target")

    if UnitIsFriend("target", "player") then
        targetLinkColor = "00FF00"
        targetLinkString = "|cff" .. targetLinkColor .. "|Hplayer:" .. targetName .. "|h[" .. targetName .. "]|h|r"
    else
        targetLinkColor = "FF3333"
        targetLinkString = "|cff" .. targetLinkColor .. "" .. targetName .. "|h|r"
    end

    return targetLinkString
end

function MountSpy.IsThisADruidForm(creatureName)
    if (creatureName == "Bear Form") or (creatureName == "Travel Form") or (creatureName == "Cat Form") then
        return true
    else
        return false
    end
end

function MountSpy.Init()
    MountSpy.InitSavedVariables()

    if not MountSpySuppressLoadingMessages then
        MountSpy.Print("MountSpy", MountSpy.Version, "is loading.")
    end

    MountSpy_ActiveModeCheckButton:SetChecked(MountSpyAutomaticMode)

    if MountSpyHidden and not MountSpyAlwaysShowOnStartup then
        MountSpy.HideUI()
    end

    MountSpy.DoSettingsRegistration()

    C_Timer.After(6, MountSpy.SetAutoModeDisplay)

    C_Timer.After(10, MountSpy.LoadMountIdList)

    C_Timer.After(15, MountSpy.PrintCurrentStatus)
end

function MountSpy.OnPlayerTargetChanged()
    if MountSpyAutomaticMode == false then
        return
    end

    local isValidTarget = MountSpy.CheckForValidTarget()
    local targetId = UnitGUID("target")
    local playerId = UnitGUID("player")

    if not isValidTarget then
        return
    end

    if targetId == nil then
        return
    end

    local bgNum = UnitInBattleground("player")
    MountSpy.Debug("battleground number:" .. tostring(bgNum))
    local playerIsInBattleground = (bgNum ~= nil)
    MountSpy.Debug("playerIsInBattleground:" .. tostring(playerIsInBattleground))

    if MountSpyIgnoreSelf then
        if targetId == playerId then
            MountSpy.Debug("seriously, stop clicking yourself.", playerId)
            return
        end
    end

    if MountSpyDisableInCombat then
        if InCombatLockdown() then
            MountSpy.Debug("...disabled in combat, and you're in combat. so there.")
            return
        end
    end

    MountSpy.Debug("MountSpyDisableInBattlegrounds: " .. tostring(MountSpyDisableInBattlegrounds))
    if MountSpyDisableInBattlegrounds then
        if playerIsInBattleground == true then
            MountSpy.Debug("...currently disabled in battlegrounds.")
            return
        end
    end

    if MountSpyDisableInArenas then
        local isArena, _ = IsActiveBattlefieldArena()
        if isArena then
            MountSpy.Debug("...disabled in arenas, and you're in an arena. congrats.", isArena)
            return
        end
    end

    -- A battleground is an instance, but not the kind of instance we want to skip if DisableInBattlegrounds is false.
    if MountSpyDisableInInstances then
        if MountSpyDisableInBattlegrounds ~= true and playerIsInBattleground then
            MountSpy.Debug("...not disabled in bg, and you're in a bg, so you should see the dataz.")
        else
            local instanceName, instanceType = GetInstanceInfo()
            MountSpy.Debug("instance:" .. instanceName .. " type:" .. instanceType)
            if instanceType ~= "none" then
                MountSpy.Debug("we're in an instance. aborting check.")
                return
            end
        end
    end

    -- if it makes it through that gauntlet of checks, do the thing.
    MountSpy.ValidateAndTell()
end

function MountSpy.ShowHelp()
    MountSpy.Print(
        "commands:\n",
        "show - Shows the UI\n",
        "hide - Hides the UI\n",
        "getinfo - Gets info about the targeted player's mount\n",
        "match - Attempts to put you on a mount that matches the target's mount\n",
        "quiet - Toggles the messages displayed at login\n",
        "history - Lists mounts that were spotted recently\n",
        "clearhistory - Clears the mount history list\n",
        "version - Displays the version number of this addon"
    )
end

function MountSpy.ReceiveCommand(msg, ...)
    -- MountSpy.Debug(msg, MountSpyDebugMode);

    msg = strtrim(msg)

    if msg == nil or msg == "" or msg == "show" then
        MountSpy.ShowUI()
    elseif msg == "history" or msg == "hist" then
        MountSpy.ShowHistory()
    elseif msg == "clearhistory" or msg == "clrhist" then
        MountSpy.ClearHistory()
    elseif msg == "hide" then
        MountSpy.HideUI()
    elseif msg == "help" then
        MountSpy.ShowHelp()
    elseif msg == "getinfo" then
        MountSpy.CheckAndShowTargetMountInfo()
    elseif msg == "match" then
        MountSpy.MatchMount()
    elseif msg == "version" then
        MountSpy.Print("version", MountSpy.Version)
    elseif msg == "vars" then
        MountSpy.SayVariables()
    elseif msg == "debug" then
        MountSpy.ToggleDebugMode()
    elseif msg == "quiet" then
        MountSpy.ToggleQuietMode()
    elseif msg == "self" then
        MountSpy.ToggleIgnoreSelf()
    elseif msg == "instance" then
        MountSpy.ToggleDisableInInstances()
    elseif msg == "bg" then
        MountSpy.ToggleDisableInBattlegrounds()
    elseif msg == "arena" then
        MountSpy.ToggleDisableInArenas()
    elseif msg == "combat" then
        MountSpy.ToggleDisableInCombat()
    elseif msg == "shapeshift" then
        MountSpy.ToggleIgnoreShapeshifts()
    elseif msg == "showonstartup" then
        MountSpy.ToggleAlwaysShowOnStartup()
    elseif string.find(msg, "setwindow ") and string.find(msg, "setwindow ") > 0 then
        -- MountSpy.SetChatFrameName(msg);
        MountSpy.ChatFrameLooper()
    else
        MountSpy.Print("Unknown command.")
    end
end

-- startup events --
function MountSpy_OnEvent(self, eventName, ...)
    local arg1 = ...
    -- MountSpy.Debug("event happened: ", arg1, eventName );

    if eventName == "PLAYER_TARGET_CHANGED" then
        MountSpy.OnPlayerTargetChanged()
    end

    if eventName == "ADDON_LOADED" and arg1 == "MountSpy" then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        self:RegisterEvent("VARIABLES_LOADED")
        MountSpy.Init()
    end

    if eventName == "PLAYER_LOGIN" then
    -- nothing for now --
    end
end

SlashCmdList["MOUNTSPY_SLASHCMD"] = function(msg)
    MountSpy.ReceiveCommand(msg)
end
SLASH_MOUNTSPY_SLASHCMD1 = "/mountspy"
