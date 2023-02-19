local _, MountSpy = ...;

function MountSpy.StringSearch(msg)
    local searchString = string.gsub(msg, "?", "");
    searchString = strtrim(searchString);
    MountSpy.Debug("." .. searchString .. ".");

    local resultsWereFound = false;

    for i, v in ipairs(MountSpy.Props.LegionMountIds) do
        local thisMountId = tonumber(MountSpy.Props.LegionMountIds[i]);
        local creatureName, blehSpellId, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, blorp = C_MountJournal.GetMountInfoByID(thisMountId);
        local thisTest = {mountId = thisMountId, creatureName = creatureName, collected = isCollected, index = i, spellId = blehSpellId};

        if string.find(string.lower(thisTest.creatureName), string.lower(searchString)) ~= nil then
            resultsWereFound = true;
            local chatLink = MountSpy_MakeMountChatLink(thisTest);
            MountSpy.Print("result:", chatLink);
        end
    end

    if resultsWereFound == false then
        MountSpy.Print("No results found.");
    end
end

-- function MountSpy_ScrubSpecialCharsForFind(stringIn)
--     local stringOut = string.gsub(stringIn, "%(", "%%(");
--     stringOut = string.gsub(stringOut, "%)", "%%)");

--     return stringOut;
-- end
