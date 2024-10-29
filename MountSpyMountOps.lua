local _, MountSpy = ...;

function MountSpy.LoadMountIdList()
    MountSpy.LegionMountIds = C_MountJournal.GetMountIDs();
end

function MountSpy.GetTargetMountData()
    local targetMountData = nil;

    local targetName, realmName = UnitName("target");

    if not targetName then
        MountSpy.Debug("no target.")
        return nil;
    end

    local buffCount = MountSpy.GetTargetBuffCount();
    if buffCount > MountSpy.MAXIMUM_BUFF_COUNT then
        MountSpy.Print("Target has too many active spells.");
        return nil;
    end

    -- iterate through target's buffs to see if any of them are mounts.
    local spellIterator = 1;

    local isIterating = true;

    while isIterating do
        local spellInfo = C_UnitAuras.GetBuffDataByIndex("target", spellIterator);

        -- MountSpy.Debug("iterator:", spellIterator, "spell name:", spellInfo.name, "spell id:", spellInfo.spellId);
        
        if not spellInfo then
            MountSpy.Debug("spellInfo is nil");
            break
        end

        local spellName = spellInfo.name;
        local spellId = spellInfo.spellId;

        spellIterator = spellIterator + 1;

        local testForMount = MountSpy.GetMountInfoBySpellId(spellInfo.spellId);

        if testForMount ~= nil then
            targetMountData = testForMount;
            break
        else
            if not MountSpyIgnoreShapeshifts then
                -- Check for Travel Form, etc.
                if MountSpy.IsThisADruidForm(spellName) then
                    targetMountData = {creatureName = spellName, spellId = MountSpy.NOT_REALLY_A_MOUNT_SPELL_ID};
                    isIterating = false;
                    break
                else
                    if spellName == "Tarecgosa's Visage" then
                        targetMountData = {creatureName = spellName, spellId = MountSpy.NOT_REALLY_A_MOUNT_SPELL_ID};
                        isIterating = false;
                        break
                    end
                end
            end
        end
    end -- end of buff iterator loop

    return targetMountData;
end

function MountSpy.GetMountInfoBySpellId(spellId)
    local mountInfo = nil;

    for i, v in ipairs(MountSpy.LegionMountIds) do
        local thisMountId = tonumber(MountSpy.LegionMountIds[i]);
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

function MountSpy.DoesPlayerHaveMatchingMount(targetMountData)
    local canHaz = targetMountData.collected;
    return canHaz;
end

function MountSpy.AttemptToMount(targetMountData)
    if not targetMountData then
        return;
    end

    local hasMatchingMount = MountSpy.DoesPlayerHaveMatchingMount(targetMountData);

    if hasMatchingMount then
        local safeToProceed = true;

        local alreadyMountedOnMatch = MountSpy.IsAlreadyMountedOnMatch(targetMountData.mountId);
        MountSpy.Debug("already mounted on match? ", alreadyMountedOnMatch);
        -- Player must not be in flight...
        local flying = IsFlying();
        if flying then
            safeToProceed = false;
            MountSpy.Print("Cannot switch mounts while flying.  That would be bad.");
            return;
        end

        if safeToProceed and alreadyMountedOnMatch ~= true then
            C_MountJournal.SummonByID(targetMountData.mountId);
        end -- end of proceed check
    else
        MountSpy.CheckAndShowTargetMountInfo();
    end

end

function MountSpy.MakeMountChatLink(targetMountData)
    local linkText = C_Spell.GetSpellLink(targetMountData.spellId);

    local skipExtraInfoCheck = MountSpy.CheckForNonMountBuffs(targetMountData);

    if skipExtraInfoCheck then

    else
        local _, descriptionText, sourceText = C_MountJournal.GetMountInfoExtraByID(targetMountData.mountId);

        if sourceText ~= nil then
            sourceText = string.gsub(sourceText, "|n", " ");
            sourceText = string.gsub(sourceText, "  ", " ");
            sourceText = strtrim(sourceText);

            if string.find(sourceText, "Achievement:") then
                sourceText = MountSpy.MakeAchievementLink(sourceText);
            end

            linkText = linkText .. ", From " .. sourceText;
        else
            linkText = linkText .. " No additional info available.";
        end
    end

    return linkText;
end

function MountSpy.CheckForNonMountBuffs(targetMountData)
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

function MountSpy.BuildMountInfoToPrint(targetName, targetMountData)
    if not targetName then
        MountSpy.Debug("Error - No target.");
        return "";
    end

    local targetLinkString = MountSpy.MakeTargetLinkString();
    local resultString = "";

    if targetMountData ~= nil and targetMountData.spellId ~= MountSpy.NOT_REALLY_A_MOUNT_SPELL_ID then
        local mountLinkString = MountSpy.MakeMountChatLink(targetMountData);
        resultString = targetLinkString .. " is riding " .. mountLinkString .. ".  ";
        local playerHasMatchingMount = MountSpy.DoesPlayerHaveMatchingMount(targetMountData);

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
        if (targetMountData ~= nil) and (targetMountData.spellId == MountSpy.NOT_REALLY_A_MOUNT_SPELL_ID) then
            local creatureName = strtrim(targetMountData.creatureName);

            if MountSpy.IsThisADruidForm(creatureName) then
                resultString = targetLinkString .. " is in " .. creatureName .. ".";
            elseif creatureName == "Tarecgosa's Visage" then
                resultString = targetLinkString .. " is transformed into " .. creatureName;
            end
        end
    end

    return resultString;
end

function MountSpy.TellTargetMountInfo(targetName, targetMountData)
    if targetMountData == nil then
        return;
    end

    local mountInfoToPrint = MountSpy.BuildMountInfoToPrint(targetName, targetMountData);

    if mountInfoToPrint ~= '' then
        MountSpy.Print(mountInfoToPrint);
        MountSpy.AddToHistory(mountInfoToPrint);
    end
end

function MountSpy.CheckAndShowTargetMountInfo()
    -- Note:    more steps than an automatic mode target change.
    --          Yes, I know I need to refactor this.
    local aTargetIsSelected = MountSpy.CheckForASelectedTarget();

    if aTargetIsSelected then
        MountSpy.ValidateAndTell(); -- ValidateAndTell only prints data if the target is a player and is mounted, so...

        local targetLinkString = MountSpy.MakeTargetLinkString();

        local targetName = UnitName("target");

        if not UnitIsPlayer("target") or targetName ~= "Abigail Cyrildotr" then
            MountSpy.Print(targetLinkString, "is not a player character.")
            return;
        end
        
        local targetMountData = MountSpy.GetTargetMountData();
        if not targetMountData then
            MountSpy.Print(targetLinkString, "is not mounted.");
        end
    else
        MountSpy.Print("No target selected.");
    end
end

function MountSpy.MatchMount()
    local isValidTarget = MountSpy.CheckForValidTarget();

    if isValidTarget then
        local targetMountData = MountSpy.GetTargetMountData();
        MountSpy.AttemptToMount(targetMountData);
    end
end

function MountSpy.IsAlreadyMountedOnMatch(targetMountId)
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
