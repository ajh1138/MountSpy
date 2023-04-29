local _, MountSpy = ...;

MountSpy_SavedVars = {};

function MountSpy.RegisterSettingsUI()
	local category, layout = Settings.RegisterVerticalLayoutCategory("MountSpy");
	
-- this didn't work --->	Settings.SetupCVarCheckBox(category,  "MountSpyAutomaticMode", "Automatic Mode", "Show mount info automatically when selecting a mounted player.");
-- this line taints stuff and is blocked.  doesn't work.  ----> local setting = Settings.RegisterProxySetting(category, "MountSpyAutomaticMode", MountSpy_SavedVars, type(true), "Automatic Mode", true);
   
	MountSpy.AddSettingControl(category, "Automatic Mode", "MountSpyAutomaticMode", true, MountSpyAutomaticMode, "Show mount info automatically when selecting a mounted player.");
	MountSpy.AddSettingControl(category, "Hide Mount Spy window", "MountSpyHidden", true, MountSpyHidden, "Hide the Mount Spy window.");
	MountSpy.AddSettingControl(category, "Ignore self-clicks", "MountSpyIgnoreSelf", true, MountSpyIgnoreSelf, "Prevents showing your mount info when you select your own character.");
	MountSpy.AddSettingControl(category, "Disable during combat", "MountSpyDisableInCombat", true, MountSpyDisableInCombat, "Keep this setting checked for better performance.");
	MountSpy.AddSettingControl(category, "Disable in battlegrounds", "MountSpyDisableInBattlegrounds", true, MountSpyDisableInBattlegrounds, "Keep this setting checked for better performance.");
	MountSpy.AddSettingControl(category, "Disable in instances", "MountSpyDisableInInstances", true, MountSpyDisableInInstances, "Keep this setting checked for better performance.");
	MountSpy.AddSettingControl(category, "Disable in arenas", "MountSpyDisableInArenas", true, MountSpyDisableInArenas, "Keep this setting checked for better performance.");
	MountSpy.AddSettingControl(category, "Do not display shapeshifts", "MountSpyIgnoreShapeshifts", true, MountSpyIgnoreShapeshifts, "Prevents showing info for druid travel forms, etc.");
	MountSpy.AddSettingControl(category, "Show window on login", "MountSpyAlwaysShowOnStartup", false, MountSpyAlwaysShowOnStartup, "Always show the Mount Spy window upon login.");
	MountSpy.AddSettingControl(category, "Do not show loading message", "MountSpySuppressLoadingMessages", false, MountSpySuppressLoadingMessages, "Prevents Mount Spy from telling you that it is loading upon login.");

	Settings.RegisterAddOnCategory(category);
end

function MountSpy.AddSettingControl(category, controlLabel, settingVariableName, defaultValue, currentValue, tooltip)
	local setting = Settings.RegisterAddOnSetting(category, controlLabel, settingVariableName, type(defaultValue), currentValue);
    Settings.SetOnValueChangedCallback(settingVariableName, function(event) _G[settingVariableName] = setting:GetValue(); end);
	Settings.CreateCheckBox(category, setting, tooltip);
end

function MountSpy.DoSettingsRegistration()
	SettingsRegistrar:AddRegistrant(MountSpy.RegisterSettingsUI);
end