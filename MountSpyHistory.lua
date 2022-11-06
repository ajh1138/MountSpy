local MOUNTSPY_HISTORY_MAX_ROWS = 5;

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function MountSpy_ShowHistory()
	mountspydebug("show history");

	if not MountSpyHistoryTable == nil then
		for _, value in pairs(MountSpyHistoryTable) do
			MountSpyPrint(value);
		end
	end
end

function MountSpy_ClearHistory()
	mountspydebug("clear history...");
	MountSpyHistoryTable = {};
end

function MountSpy_AddToHistory(mountInfoString)
	mountspydebug("AddToHistory called...", mountInfoString);

	if MountSpyHistoryTable == nil then
		mountspydebug("initializing MountSpyHistoryTable");
		MountSpyHistoryTable = {}
	end
	
	if mountInfoString == "" then
		return;
	end

	-- is this already in the history?
	local alreadyInTable = table.contains(MountSpyHistoryTable, mountInfoString);
	
	if not alreadyInTable then
		mountspydebug("adding to history table: ", mountInfoString);

		table.insert(MountSpyHistoryTable, mountInfoString);

		if #MountSpyHistoryTable > MOUNTSPY_HISTORY_MAX_ROWS then
			mountspydebug("removing oldest history row.");
			table.remove(MountSpyHistoryTable);
		end
	else
		mountspydebug("entry already exists in table.");
	end	
end