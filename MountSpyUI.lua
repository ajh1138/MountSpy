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

