local _, MountSpy = ...
local settingsTbl = {};

MountSpy.SettingsControls = {}

function MountSpy.RegisterSettingsUI()
	local category, layout = Settings.RegisterVerticalLayoutCategory("MountSpy")

	local automaticSetting =
		MountSpy.AddSettingCheckbox(
		category,
		"Automatic Mode",
		"MountSpyAutomaticMode",
		true,
		MountSpyAutomaticMode,
		"Show mount info automatically when selecting a mounted player."
	)
	MountSpy.OnAutomaticModeSettingChange(automaticSetting)

	local windowSetting =
		MountSpy.AddSettingCheckbox(
		category,
		"Hide Mount Spy window",
		"MountSpyHidden",
		true,
		MountSpyHidden,
		"Hide the Mount Spy window."
	)
	MountSpy.OnWindowVisibilitySettingChange(windowSetting)

	MountSpy.AddSettingCheckbox(
		category,
		"Ignore self-clicks",
		"MountSpyIgnoreSelf",
		true,
		MountSpyIgnoreSelf,
		"Prevents showing your mount info when you select your own character."
	)
	MountSpy.AddSettingCheckbox(
		category,
		"Disable during combat",
		"MountSpyDisableInCombat",
		true,
		MountSpyDisableInCombat,
		"Keep this setting checked for better performance."
	)
	MountSpy.AddSettingCheckbox(
		category,
		"Disable in battlegrounds",
		"MountSpyDisableInBattlegrounds",
		true,
		MountSpyDisableInBattlegrounds,
		"Keep this setting checked for better performance."
	)
	MountSpy.AddSettingCheckbox(
		category,
		"Disable in instances",
		"MountSpyDisableInInstances",
		true,
		MountSpyDisableInInstances,
		"Keep this setting checked for better performance."
	)
	MountSpy.AddSettingCheckbox(
		category,
		"Disable in arenas",
		"MountSpyDisableInArenas",
		true,
		MountSpyDisableInArenas,
		"Keep this setting checked for better performance."
	)
	MountSpy.AddSettingCheckbox(
		category,
		"Do not display shapeshifts",
		"MountSpyIgnoreShapeshifts",
		true,
		MountSpyIgnoreShapeshifts,
		"Prevents showing info for druid travel forms, etc."
	)
	MountSpy.AddSettingCheckbox(
		category,
		"Show window on login",
		"MountSpyAlwaysShowOnStartup",
		false,
		MountSpyAlwaysShowOnStartup,
		"Always show the Mount Spy window upon login."
	)
	MountSpy.AddSettingCheckbox(
		category,
		"Do not show loading message",
		"MountSpySuppressLoadingMessages",
		false,
		MountSpySuppressLoadingMessages,
		"Prevents Mount Spy from telling you that it is loading upon login."
	)

	Settings.RegisterAddOnCategory(category)
end

function MountSpy.AddSettingCheckbox(category, controlLabel, settingVariableName, defaultValue, currentValue, tooltip)
	local variableKey = settingVariableName .. "_Key";

	local setting =
		-- old Settings.RegisterAddOnSetting(category, controlLabel, settingVariableName, type(defaultValue), currentValue)

		-- new one...		
		Settings.RegisterAddOnSetting(category, settingVariableName, variableKey, settingsTbl, type(defaultValue), settingVariableName, defaultValue)

	Settings.SetOnValueChangedCallback(
		settingVariableName,
		function(event)
			_G[settingVariableName] = setting:GetValue()
		end
	)
	Settings.CreateCheckBox(category, setting, tooltip)

	MountSpy.SettingsControls[settingVariableName] = setting

	return setting
end

function MountSpy.DoSettingsRegistration()
	SettingsRegistrar:AddRegistrant(MountSpy.RegisterSettingsUI)
end

function MountSpy.UpdateSettingControl(settingVariableName)
	if tablelength(MountSpy.SettingsControls) > 0 then
		if MountSpy.SettingsControls[settingVariableName] ~= nil then
			MountSpy.SettingsControls[settingVariableName]:SetValue(_G[settingVariableName], false)
		end
	end
end

function MountSpy.OnWindowVisibilitySettingChange(setting)
	Settings.SetOnValueChangedCallback(
		"MountSpyHidden",
		function(event)
			_G["MountSpyHidden"] = setting:GetValue()

			if MountSpyHidden then
				MountSpy.HideUI()
			else
				MountSpy.ShowUI()
			end
		end
	)
end

function MountSpy.OnAutomaticModeSettingChange(setting)
	Settings.SetOnValueChangedCallback(
		"MountSpyAutomaticMode",
		function(event)
			_G["MountSpyAutomaticMode"] = setting:GetValue()

			MountSpy_ActiveModeCheckButton:SetChecked(MountSpyAutomaticMode)
		end
	)
end

-- because Lua sucks...(# operator isn't reliable)
function tablelength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end
