local _, MountSpy = ...;

function MountSpy_ToggleUI(msg, editbox)
    local isShown = MountSpy_MainFrame:IsShown();

    if isShown then
        MountSpy_HideUI();
        MountSpyHidden = true;
    else
        MountSpy_ShowUI();
        MountSpyHidden = false;
    end
end

function MountSpy_ShowUI(msg, editbox)
    MountSpy_MainFrame:Show();
    MountSpyHidden = false;
end

function MountSpy_HideUI(msg, editbox)
    MountSpy_MainFrame:Hide();
    MountSpyHidden = true;
end

function MountSpy_SetAutoModeDisplay()
    getglobal(MountSpy_ActiveModeCheckButton:GetName() .. "Text"):SetText("Automatic Mode");
end

function MountSpy_GetInfoButtonClick()
    MountSpy_CheckAndShowTargetMountInfo();
end

function MountSpy_ActiveModeCheckButtonClick()
    MountSpyAutomaticMode = MountSpy_ActiveModeCheckButton:GetChecked();

    if MountSpyAutomaticMode then
        MountSpy_ValidateAndTell();
    end
end

function MountSpy_OnLoad(frame)
    MountSpy.Debug("OnLoad has fired.");
end

function MountSpy_OnHide()
    MountSpyHidden = true;
    --	MountSpy.Debug("frame closed.  MountSpyHidden var = " .. tostring(MountSpyHidden))
end
