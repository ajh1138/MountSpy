local _, MountSpy = ...;

function MountSpy:InitSavedVariables()
    if MountSpyChatFrameName == nil then
        MountSpyChatFrameName = "DEFAULT_CHAT_FRAME";
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

    MountSpy.Debug("acct vars done.")
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
end

function MountSpy.ToggleDisableInInstances()
    MountSpyDisableInInstances = not MountSpyDisableInInstances;

    if MountSpyDisableInInstances then
        MountSpy.Print("...now Disabled in Instances.");
    else
        MountSpy.Print("...now Enabled in Instances.");
    end
end

function MountSpy.ToggleDisableInBattlegrounds()
    MountSpyDisableInBattlegrounds = not MountSpyDisableInBattlegrounds;

    if MountSpyDisableInBattlegrounds then
        MountSpy.Print("...now Disabled in Battlegrounds.");
    else
        MountSpy.Print("...now Enabled in Battlegrounds.");
    end
end

function MountSpy.ToggleDisableInArenas()
    MountSpyDisableInArenas = not MountSpyDisableInArenas;

    if MountSpyDisableInArenas then
        MountSpy.Print("...now Disabled in Arenas.");
    else
        MountSpy.Print("...now Enabled in Arenas.");
    end
end

function MountSpy.ToggleDisableInCombat()
    MountSpyDisableInCombat = not MountSpyDisableInCombat;

    if MountSpyDisableInCombat then
        MountSpy.Print("...now Disabled in Combat.");
    else
        MountSpy.Print("...now Enabled in Combat.");
    end
end

function MountSpy.ToggleIgnoreShapeshifts()
    MountSpyIgnoreShapeshifts = not MountSpyIgnoreShapeshifts;

    if MountSpyIgnoreShapeshifts then
        MountSpy.Print("...now ignoring player travel shapeshifts.");
    else
        MountSpy.Print("...will display player travel shapeshifts.");
    end
end

function MountSpy.ToggleIgnoreSelf()
    MountSpyIgnoreSelf = not MountSpyIgnoreSelf;

    if MountSpyIgnoreSelf then
        MountSpy.Print("...ignoring clicks on yourself.");
    else
        MountSpy.Print("...automatic mode will react to clicks on yourself.");
    end
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
    MountSpy.Print("hidden:", MountSpyHidden, ",debugmode:", MountSpyDebugMode, ",automatic:", MountSpyAutomaticMode, ",disabled in bg:", MountSpyDisableInBattlegrounds, ",disabled in arenas:", MountSpyDisableInArenas, ",disabled in combat:", MountSpyDisableInCombat, ",disabled in instances:", MountSpyDisableInInstances, ",ignore self:", MountSpyIgnoreSelf, ",ignore shapeshifts:", MountSpyIgnoreShapeshifts, ",chat frame:", MountSpyChatFrameName);
end

