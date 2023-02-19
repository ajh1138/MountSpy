local _, MountSpy = ...;

function MountSpy.LoadMountIdList()
    MountSpy.Props.LegionMountIds = C_MountJournal.GetMountIDs();
end

function MountSpy_GetTargetMountData()
    local targetMountData = nil;

    local targetName, realmName = UnitName("target");

    if not targetName then
        MountSpy.Debug("no target name")
        return nil;
    end

    local buffCount = MountSpy_GetTargetBuffCount();
    if buffCount > MountSpy.Props.TargetedPlayerSpellLimit then
        MountSpy.Print("Target has too many active spells.");
        return nil;
    end

    -- iterate through target's buffs to see if any of them are mounts.
    local spellIterator = 1;

    while true do

        local spellName, _, _, _, _, _, _, _, _, spellId = UnitBuff("target", spellIterator);

        -- MountSpy.Debug("iterator:", spellIterator, "spell name:", spellName, "spell id:", spellId);

        if not spellName then
            break
        end

        spellIterator = spellIterator + 1;

        local testForMount = MountSpy_GetMountInfoBySpellId(spellId);

        if testForMount ~= nil then
            targetMountData = testForMount;
            break
        else
            -- Check for Travel Form, etc.
            if MountSpy_IsThisADruidForm(spellName) then
                targetMountData = {creatureName = spellName, spellId = MountSpy.Props.NotReallyAMountSpellID};
                break
            else
                if spellName == "Tarecgosa's Visage" then
                    targetMountData = {creatureName = spellName, spellId = MountSpy.Props.NotReallyAMountSpellID};
                    break
                end
            end
        end
    end -- end of buff iterator loop

    return targetMountData;
end

function MountSpy_GetMountInfoBySpellId(spellId)
    local mountInfo = nil;

    for i, v in ipairs(MountSpy.Props.LegionMountIds) do
        local thisMountId = tonumber(MountSpy.Props.LegionMountIds[i]);
        local creatureName, blehSpellId, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, blorp = C_MountJournal.GetMountInfoByID(thisMountId);
        local thisTest = {mountId = thisMountId, creatureName = creatureName, collected = isCollected, index = i, spellId = blehSpellId};

        if tonumber(thisTest.spellId) == tonumber(spellId) then
            mountInfo = thisTest;
            break
        end
    end

    --	MountSpy.Debug("mountInfo:", mountInfo);
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
        MountSpy.Debug("already mounted on match? ", alreadyMountedOnMatch);
        -- Must not be in flight...
        local flying = IsFlying();
        if flying then
            safeToProceed = false;
            MountSpy.Print("Cannot switch mounts while flying.  That would be bad.");
            return;
        end

        if safeToProceed and alreadyMountedOnMatch ~= true then
            C_MountJournal.SummonByID(targetMountData.mountId);
        end -- end of proceed check
    end
end

function MountSpy_MakeMountChatLink(targetMountData)
    local linkText = GetSpellLink(targetMountData.spellId);

    local skipExtraInfoCheck = MountSpy_CheckForNonMountBuffs(targetMountData);

    if skipExtraInfoCheck then

    else
        local _, descriptionText, sourceText = C_MountJournal.GetMountInfoExtraByID(targetMountData.mountId);

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

function MountSpy_CheckForNonMountBuffs(targetMountData)
    local nonMountBuffs = {"Travel Form", "Cat Form", "Bear Form", "Tarecgosa's Visage"};

    local nonMountFound = false;

    for i, v in ipairs(nonMountBuffs) do
        if v == targetMountData.creatureName then
            nonMountFound = true;
        end
    end

    if nonMountFound then
        return true;
    else
        return false;
    end
end

function MountSpy_BuildMountInfoToPrint(targetName, targetMountData)
    if not targetName then
        MountSpy.Debug("Error - No target.");
        return "";
    end

    local targetLinkString = MountSpy_MakeTargetLinkString();
    local resultString = "";

    if targetMountData ~= nil and targetMountData.spellId ~= MountSpy.NotReallyAMountSpellID then
        local mountLinkString = MountSpy_MakeMountChatLink(targetMountData);
        resultString = targetLinkString .. " is riding " .. mountLinkString .. ".  ";
        local playerHasMatchingMount = MountSpy_DoesPlayerHaveMatchingMount(targetMountData);

        -- override some stuff if target is the player...
        if targetName == UnitName("player") then
            playerHasMatchingMount = true;
            resultString = "You are riding " .. mountLinkString .. ".  ";
        end

        if playerHasMatchingMount then
            if targetName == UnitName("player") then
                resultString = resultString
            else
                resultString = resultString .. "|cffCCFFCC  You have this mount.|h|r"
            end
        else
            if targetMountData.creatureName ~= "Travel Form" then
                resultString = resultString .. "|cffFFCCCC Your character does not have this mount.|h|r";
            end
        end
    else
        if (targetMountData ~= nil) and (targetMountData.spellId == NOT_REALLY_A_MOUNT_SPELLID) then
            local creatureName = strtrim(targetMountData.creatureName);

            if MountSpy_IsThisADruidForm(creatureName) then
                resultString = targetLinkString .. " is in " .. creatureName .. ".";
            elseif creatureName == "Tarecgosa's Visage" then
                resultString = targetLinkString .. " is transformed into " .. creatureName;
            end
        end
    end

    return resultString;
end

function MountSpy_TellTargetMountInfo(targetName, targetMountData)
    local mountInfoToPrint = MountSpy_BuildMountInfoToPrint(targetName, targetMountData);

    if mountInfoToPrint ~= '' then
        MountSpy.Print(mountInfoToPrint);
        MountSpy_AddToHistory(mountInfoToPrint);
    end
end

function MountSpy_CheckAndShowTargetMountInfo()
    -- Note: more steps than an automatic mode target change.
    local aTargetIsSelected = MountSpy_CheckForASelectedTarget();

    if aTargetIsSelected then
        MountSpy_ValidateAndTell(); -- ValidateAndTell only prints data if the target is a player and is mounted, so...

        local targetLinkString = MountSpy_MakeTargetLinkString();

        if not UnitIsPlayer("target") then
            MountSpy.Print(targetLinkString, "is not a player character.")
        else
            local targetMountData = MountSpy_GetTargetMountData();
            if not targetMountData then
                MountSpy.Print(targetLinkString, "is not mounted.");
            end
        end
    else
        MountSpy.Print("No target selected.");
    end
end

