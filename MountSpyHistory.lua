local MOUNTSPY_HISTORY_MAX_ROWS = 10;

function MountSpy_TableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function MountSpy_TableIndexOf(table, element)
	local index = 1;

	for _, value in pairs(table) do
		if value == element then
			return index;
		end

		index = index + 1;
	end

	return -1;
end

function MountSpy_ShowHistory()
	if MountSpyHistoryTable ~= nil and #MountSpyHistoryTable > 0 then
		MountSpyPrint("History:");
		for _, value in pairs(MountSpyHistoryTable) do
			print(" - ", value);
		end
	else
		MountSpyPrint("History is empty.");
	end
end

function MountSpy_ClearHistory()
	MountSpyHistoryTable = {};
	MountSpyPrint("History cleared.");
end

function MountSpy_AddToHistory(mountInfoString)
	if MountSpyHistoryTable == nil then
		mountspydebug("initializing MountSpyHistoryTable");
		MountSpyHistoryTable = {}
	end
	
	if mountInfoString == '' then
		return;
	end

	local mountAlreadyInTableAtPosition = MountSpy_TableIndexOf(MountSpyHistoryTable, mountInfoString);
	
	if mountAlreadyInTableAtPosition > -1 then
		table.remove(MountSpyHistoryTable, mountAlreadyInTableAtPosition);
	end

	table.insert(MountSpyHistoryTable, mountInfoString);

	if #MountSpyHistoryTable > MOUNTSPY_HISTORY_MAX_ROWS then
		table.remove(MountSpyHistoryTable, 1);
	end
end