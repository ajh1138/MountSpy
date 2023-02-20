local _, MountSpy = ...;

function MountSpy.ToggleUI(msg, editbox)
    local isShown = MountSpy_MainFrame:IsShown();

    if isShown then
        MountSpy.HideUI();
        MountSpyHidden = true;
    else
        MountSpy.ShowUI();
        MountSpyHidden = false;
    end
end

function MountSpy.ShowUI(msg, editbox)
    MountSpy_MainFrame:Show();
    MountSpyHidden = false;
end

function MountSpy.HideUI(msg, editbox)
    MountSpy_MainFrame:Hide();
    MountSpyHidden = true;
end

function MountSpy.SetAutoModeDisplay()
    getglobal(MountSpy_ActiveModeCheckButton:GetName() .. "Text"):SetText("Automatic Mode");
end

function MountSpy_GetInfoButtonClick()
    MountSpy.CheckAndShowTargetMountInfo();
end

function MountSpy_ActiveModeCheckButtonClick()
    MountSpyAutomaticMode = MountSpy_ActiveModeCheckButton:GetChecked();

    if MountSpyAutomaticMode then
        MountSpy.ValidateAndTell();
    end
end

function MountSpy_OnLoad(frame)
    MountSpy.Debug("OnLoad has fired.");
end

function MountSpy_OnHide()
    MountSpyHidden = true;
    --	MountSpy.Debug("frame closed.  MountSpyHidden var = " .. tostring(MountSpyHidden))
end

function MountSpy_MatchMountButtonClick()
    MountSpy.MatchMount();
end
