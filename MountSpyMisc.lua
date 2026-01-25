local _, MountSpy = ...

function MountSpy.TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function MountSpy.TableIndexOf(table, element)
    local index = 1

    for _, value in pairs(table) do
        if value == element then
            return index
        end

        index = index + 1
    end

    return -1
end

function MountSpy.GetTargetBuffCount(unit)
    local buffCount = 0

    while true do
        local spellName = C_UnitAuras.GetBuffDataByIndex(unit, buffCount + 1)

        if not spellName then
            break
        else
            buffCount = buffCount + 1
        end
    end

    return buffCount
end

function MountSpy.MakeAchievementLink(sourceText)
    local newSourceText = ""

    for i = 1, #MountSpy_Achievements do
        local fromTbl = MountSpy_Achievements[i].name

        local achFound = string.find(string.lower(sourceText), string.lower(fromTbl), nil, true)

        if achFound then
            local cheeveId = MountSpy_Achievements[i].id
            local achievementLink = GetAchievementLink(cheeveId)

            newSourceText = "|cffFFD700|hAchievement:|r " .. achievementLink
            break
        end
    end

    -- in case the achievement isn't found.
    if newSourceText == "" then
        newSourceText = sourceText
    end

    return newSourceText
end

function MountSpy.CheckForASelectedTarget()
    local targetName = UnitName("target")

    if not targetName then
        return false
    else
        return true
    end
end

function MountSpy.CheckForValidTarget()
    local isValidTarget = true
    local targetName = UnitName("target")

    if not targetName then
        isValidTarget = false
        return false
    end

    -- ensure that the target is a player or is the MountMania host...
    if canaccessvalue(targetName) then
        MountSpy.Debug("target name:", targetName);
    else
        isValidTarget = false;
    end 
   
   
    if isValidTarget then        
        local isPlayerCharacter = UnitIsPlayer("target")
        if not isPlayerCharacter and targetName ~= "Abigail Cyrildotr" then
            isValidTarget = false
        end
    end
    
    MountSpy.Debug("valid target? " .. tostring(isValidTarget));

    return isValidTarget
end

function MountSpy.ChatFrameLooper()
    for i = 1, NUM_CHAT_WINDOWS do
        local winName = Chat_GetChannelShortcutName(i)
        if winName == nil then
            winName = "(none)"
        end
        getglobal("ChatFrame" .. i):AddMessage("This is ChatFrame" .. i .. " aka " .. winName, 0, 0, 0, 0)
    end
end

function MountSpy.DisplayPlayerMountName()
    local mountInfo = MountSpy.GetTargetMountData("player");
    
    if not mountInfo then
        return;
    end

    local myMountId = mountInfo.mountId;     

    if myMountId then
        local creatureName = C_MountJournal.GetMountInfoByID(myMountId);

        if creatureName then
            if MountSpy.PlayerMountNameDisplayFrame == nil then
                MountSpy.InitPlayerMountNameDisplayFrame();
            end

            MountSpy.PlayerMountNameDisplayFontString:SetText("Riding: " .. creatureName);
            UIFrameFadeIn(MountSpy.PlayerMountNameDisplayFrame, 0.25, 0, 1);

            C_Timer.After(3, function() UIFrameFadeOut(MountSpy.PlayerMountNameDisplayFrame, 3, 1, 0)  end);
        end
    end
end

function MountSpy.InitPlayerMountNameDisplayFrame()
    MountSpy.PlayerMountNameDisplayFrame = CreateFrame("Frame", "MountSpyPlayerMountDisplayFrame", UIParent);
    MountSpy.PlayerMountNameDisplayFrame:SetSize(200, 50);
    MountSpy.PlayerMountNameDisplayFrame:SetPoint("TOP", UIParent, "TOP", 0, -200);
    MountSpy.PlayerMountNameDisplayFontString = MountSpy.PlayerMountNameDisplayFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
    MountSpy.PlayerMountNameDisplayFontString:SetPoint("CENTER", MountSpy.PlayerMountNameDisplayFrame, "CENTER", 0, 0);
    MountSpy.PlayerMountNameDisplayFontString:SetTextColor(1, 0.84, 0); -- Gold color     
end