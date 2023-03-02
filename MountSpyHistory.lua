local _, MountSpy = ...;

local MOUNTSPY_HISTORY_MAX_ROWS = 10;

function MountSpy.ShowHistory()
    if MountSpyHistoryTable ~= nil and #MountSpyHistoryTable > 0 then
        MountSpy.Print("History:");
        for _, value in pairs(MountSpyHistoryTable) do
            MountSpy.Print(" - ", value);
        end
    else
        MountSpy.Print("History is empty.");
    end
end

function MountSpy.ClearHistory()
    MountSpyHistoryTable = {};
    MountSpy.Print("History cleared.");
end

function MountSpy.AddToHistory(mountInfoString)
    if MountSpyHistoryTable == nil then
        MountSpy.Debug("initializing MountSpyHistoryTable");
        MountSpyHistoryTable = {}
    end

    if mountInfoString == '' then
        return;
    end

    local mountAlreadyInTableAtPosition = MountSpy.TableIndexOf(MountSpyHistoryTable, mountInfoString);

    if mountAlreadyInTableAtPosition > -1 then
        table.remove(MountSpyHistoryTable, mountAlreadyInTableAtPosition);
    end

    table.insert(MountSpyHistoryTable, mountInfoString);

    if #MountSpyHistoryTable > MOUNTSPY_HISTORY_MAX_ROWS then
        table.remove(MountSpyHistoryTable, 1);
    end
end
