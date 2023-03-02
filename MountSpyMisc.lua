local _, MountSpy = ...;

function MountSpy.TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function MountSpy.TableIndexOf(table, element)
    local index = 1;

    for _, value in pairs(table) do
        if value == element then
            return index;
        end

        index = index + 1;
    end

    return -1;
end

function MountSpy.StringSearch(msg)
    local searchString = string.gsub(msg, "?", "");
    searchString = strtrim(searchString);
    MountSpy.Debug("." .. searchString .. ".");

    local resultsWereFound = false;

    for i, v in ipairs(MountSpy.LegionMountIds) do
        local thisMountId = tonumber(MountSpy.LegionMountIds[i]);
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

        if string.find(string.lower(thisTest.creatureName), string.lower(searchString)) ~= nil then
            resultsWereFound = true;
            local chatLink = MountSpy.MakeMountChatLink(thisTest);
            MountSpy.Print("result:", chatLink);
        end
    end

    if resultsWereFound == false then
        MountSpy.Print("No results found.");
    end
end

-- function MountSpy.ScrubSpecialCharsForFind(stringIn)
--     local stringOut = string.gsub(stringIn, "%(", "%%(");
--     stringOut = string.gsub(stringOut, "%)", "%%)");

--     return stringOut;
-- end

function MountSpy.GetTargetBuffCount()
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

function MountSpy.MakeAchievementLink(sourceText)
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

function MountSpy.CheckForASelectedTarget()
    local targetName = UnitName("target");

    if not targetName then
        return false;
    else
        return true;
    end
end

function MountSpy.CheckForValidTarget()
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

function MountSpy.ChatFrameLooper()
    for i = 1, NUM_CHAT_WINDOWS do
        local winName = Chat_GetChannelShortcutName(i)
        if winName == nil then
            winName = "(none)"
        end
        getglobal("ChatFrame" .. i):AddMessage(
            "This is ChatFrame" .. i .. " aka " .. winName, 0, 0, 0, 0);
    end
end
