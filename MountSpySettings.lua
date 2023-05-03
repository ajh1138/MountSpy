local _, MountSpy = ...;

-- TODO: put config settings in a table with defaults already setup.
-- TODO: make this whole file more DRY. (loop through the table)

function MountSpy.InitSavedVariables()
    if MountSpyChatFrameName == nil then
        MountSpyChatFrameName = "DEFAULT_CHAT_FRAME";
    end

    if MountSpySuppressLoadingMessages == nil then
        MountSpySuppressLoadingMessages = false;
    end

    if MountSpyAutomaticMode == nil then
        MountSpyAutomaticMode = true;
    end

    if MountSpyHidden == nil then
        MountSpyHidden = false;
    end

    if MountSpyDebugMode == nil then
        MountSpyDebugMode = false;
    end

    if MountSpyAlwaysShowOnStartup == nil then
        MountSpyAlwaysShowOnStartup = false;
    end

    if MountSpyDisableInCombat == nil then
        MountSpyDisableInCombat = true;
    end

    if MountSpyDisableInBattlegrounds == nil then
        MountSpyDisableInBattlegrounds = true;
    end

    if MountSpyDisableInArenas == nil then
        MountSpyDisableInArenas = true;
    end

    if MountSpyDisableInInstances == nil then
        MountSpyDisableInInstances = true;
    end

    if MountSpyIgnoreSelf == nil then
        MountSpyIgnoreSelf = true;
    end

    if MountSpyIgnoreShapeshifts == nil then
        MountSpyIgnoreShapeshifts = true;
    end
end

function MountSpy.ToggleDebugMode()
    local debugStatusText = "off";

    if not MountSpyDebugMode then
        MountSpyDebugMode = true;
        debugStatusText = "on";
    else
        MountSpyDebugMode = false;
    end

    print("MountSpy debugging is now " .. debugStatusText .. ".");
end

function MountSpy.ToggleQuietMode()
    if not MountSpySuppressLoadingMessages then
        MountSpySuppressLoadingMessages = true;
        MountSpy.Print("Startup messages disabled.");
    else
        MountSpySuppressLoadingMessages = false;
        MountSpy.Print("Startup messages enabled.");
    end

    MountSpy.UpdateSettingControl("MountSpySuppressLoadingMessages");
end

function MountSpy.ToggleDisableInInstances()
    MountSpyDisableInInstances = not MountSpyDisableInInstances;

    if MountSpyDisableInInstances then
        MountSpy.Print("...now Disabled in Instances.");
    else
        MountSpy.Print("...now Enabled in Instances.");
    end

    MountSpy.UpdateSettingControl("MountSpyDisableInInstances");
end

function MountSpy.ToggleDisableInBattlegrounds()
    MountSpyDisableInBattlegrounds = not MountSpyDisableInBattlegrounds;

    if MountSpyDisableInBattlegrounds then
        MountSpy.Print("...now Disabled in Battlegrounds.");
    else
        MountSpy.Print("...now Enabled in Battlegrounds.");
    end

    MountSpy.UpdateSettingControl("MountSpyDisableInBattlegrounds");
end

function MountSpy.ToggleDisableInArenas()
    MountSpyDisableInArenas = not MountSpyDisableInArenas;

    if MountSpyDisableInArenas then
        MountSpy.Print("...now Disabled in Arenas.");
    else
        MountSpy.Print("...now Enabled in Arenas.");
    end

    MountSpy.UpdateSettingControl("MountSpyDisableInArenas");
end

function MountSpy.ToggleDisableInCombat()
    MountSpyDisableInCombat = not MountSpyDisableInCombat;

    if MountSpyDisableInCombat then
        MountSpy.Print("...now Disabled in Combat.");
    else
        MountSpy.Print("...now Enabled in Combat.");
    end

    MountSpy.UpdateSettingControl("MountSpyDisableInCombat");
end

function MountSpy.ToggleIgnoreShapeshifts()
    MountSpyIgnoreShapeshifts = not MountSpyIgnoreShapeshifts;

    if MountSpyIgnoreShapeshifts then
        MountSpy.Print("...now ignoring player travel shapeshifts.");
    else
        MountSpy.Print("...will display player travel shapeshifts.");
    end

    MountSpy.UpdateSettingControl("MountSpyIgnoreShapeshifts");
end

function MountSpy.ToggleIgnoreSelf()
    MountSpyIgnoreSelf = not MountSpyIgnoreSelf;

    if MountSpyIgnoreSelf then
        MountSpy.Print("...ignoring clicks on yourself.");
    else
        MountSpy.Print("...automatic mode will react to clicks on yourself.");
    end

    MountSpy.UpdateSettingControl("MountSpyIgnoreSelf");
end

function MountSpy.ToggleAlwaysShowOnStartup()
    MountSpyAlwaysShowOnStartup = not MountSpyAlwaysShowOnStartup;

    if MountSpyAlwaysShowOnStartup then
        MountSpy.Print("...'always show window on startup' is turned on.");
    else
        MountSpy.Print("...'always show window on startup' is turned off.");
    end

    MountSpy.UpdateSettingControl("MountSpyAlwaysShowOnStartup");
end

function MountSpy.SetChatFrameName(msg)
    local frameName = gsub(msg, "setwindow ", "");
    MountSpy.Debug("frame name -" .. frameName .. "-");
    local ChatFrameRef = _G[frameName];
    ChatFrameRef:AddMessage("whatever!!", 1.0, 1.0, 0);
    if ChatFrameRef == nil then
        print("Error: Chat window " .. frameName .. " not found."); -- Do not use MountSpy.Print to show this error, in case a chat window was closed, etc. --
    else
        MountSpyChatFrameName = frameName;
        MountSpy.Print("Chat window set to " .. MountSpyChatFrameName);
    end
end

function MountSpy.PrintCurrentStatus()
    local statusMsg = "";

    if MountSpyHidden == true and not MountSpySuppressLoadingMessages then
        statusMsg = "The MountSpy window is hidden. Use /mountspy to show it.";
        MountSpy.Print(statusMsg);
    end
end

function MountSpy.SayVariables()
    MountSpy.Print("hidden:", MountSpyHidden, ", debugmode:", MountSpyDebugMode, ", automatic:", MountSpyAutomaticMode, ", disabled in bg:", MountSpyDisableInBattlegrounds, ", disabled in arenas:", MountSpyDisableInArenas, ", disabled in combat:", MountSpyDisableInCombat, ", disabled in instances:", MountSpyDisableInInstances, ", ignore self:", MountSpyIgnoreSelf, ", ignore shapeshifts:", MountSpyIgnoreShapeshifts, ", chat frame:", MountSpyChatFrameName);
end

