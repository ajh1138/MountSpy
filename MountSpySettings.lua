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

    if not MountSpy.DebugMode then
        MountSpy.DebugMode = true;
        debugStatusText = "on";
    else
        MountSpy.DebugMode = false;
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
    MountSpy.Print("MountSpyHidden:", MountSpyHidden, "MountSpy.DebugMode:", MountSpy.DebugMode, "MountSpyAutomaticMode:", MountSpyAutomaticMode);
end

function MountSpy.ToggleIgnoreSelf()
    MountSpyIgnoreSelf = not MountSpyIgnoreSelf;
    MountSpy.Print("IgnoreSelf set to", MountSpyIgnoreSelf);
end
