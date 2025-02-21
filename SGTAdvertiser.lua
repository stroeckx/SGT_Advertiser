SGTAdvertiser = LibStub("AceAddon-3.0"):NewAddon("SGTAdvertiser", "AceConsole-3.0", "AceEvent-3.0");
SGTAdvertiser.L = LibStub("AceLocale-3.0"):GetLocale("SGTAdvertiser");

--Variables start
SGTAdvertiser.majorVersion = 1;
SGTAdvertiser.subVersion = 0;
SGTAdvertiser.minorVersion = 10;
SGTAdvertiser.macroButton = nil;
SGTAdvertiser.searchMacroButton = nil;
local priceFrame = nil;
local buttonInitialised = false;
local isFrameMoving = false;
local isTradeChatEnabled = false;
--Variables end

function SGTAdvertiser:OnInitialize()
    if(SGTCore.DoVersionCheck == nil or SGTCore:DoVersionCheck(1,0,5, SGTCore) == false) then
        message(SGTAdvertiser.L["Error_version_core"]);
        return;
    end

    SGTAdvertiser.db = LibStub("AceDB-3.0"):New("SGTAdvertiserDB", {
        profile = 
        {
            settings = 
            {
                enabled = true,
                timeBetweenPosts = 300,
                buttonSize = 50;
            },
            lastPost = 0;
        },
    });

    local dummyFrame = CreateFrame("Frame");
    dummyFrame:SetScript('OnUpdate', OnUpdate);
    SGTCore:AddTabWithFrame("SGTAdvertiser", SGTAdvertiser.L["Advertiser"], SGTAdvertiser.L["Advertiser"], SGTAdvertiser:GetVersionString(), SGTAdvertiser.OnAdvertiserFrameCreated);

    -- set up button
    SGTAdvertiser.macroButton = CreateFrame("Button", "SGTAdvertiserMacroButton", UIParent, "SecureActionButtonTemplate");
    SGTAdvertiser:SetbuttonShown(false);
    SGTAdvertiser.macroButton:SetSize(SGTAdvertiser.db.profile.settings.buttonSize,SGTAdvertiser.db.profile.settings.buttonSize);
    SGTAdvertiser.macroButton:SetPoint("CENTER");
    SGTAdvertiser.macroButton:SetClampedToScreen(true);
    SGTAdvertiser.macroButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown") --https://github.com/Stanzilla/WoWUIBugs/issues/268
    SGTAdvertiser.macroButton:SetAttribute("type1", "macro") -- left click causes macro
    SGTAdvertiser.macroButton:SetAttribute("macrotext", "/run SGTAdvertiser:PostMacro()");
    SGTAdvertiser.macroButton:SetMovable(true);
    SGTAdvertiser.macroButton:SetMouseClickEnabled(true);
    SGTAdvertiser.macroButton:EnableMouse(true);
    SGTAdvertiser.macroButton:RegisterForDrag("RightButton")
    SGTAdvertiser.macroButton:SetScript("OnDragStart", function(self, button)
        isFrameMoving = true;
        self:StartMoving();
    end)
    SGTAdvertiser.macroButton:SetScript("OnDragStop", function(self)
        isFrameMoving = false;
        self:StopMovingOrSizing();
    end)
    C_Timer.After(0, function()
        SGTAdvertiser:UpdateMacroButton(); 
    end)
    SGTAdvertiser:CheckIfInTradeChat();
    -- button setup end
    SGTAdvertiser:RegisterEvent("CHANNEL_UI_UPDATE", "CheckIfInTradeChat");  
end

function SGTAdvertiser:CheckIfInTradeChat()
    id1, name1, disabled1, id2, name2, disabled2 = GetChannelList();
    if(name2 ~= "Trade") then
        print(SGTAdvertiser.L["Error_NoTradeChannel"]);
        isTradeChatEnabled = false;
        return;
    end
    if(disabled2 == false) then
        isTradeChatEnabled = true;
    else
        isTradeChatEnabled = false;
    end
end

function SGTAdvertiser:UpdateMacroButton()
    local name, icon, body = GetMacroInfo("SGT");
    if(name == nil or icon == nil or body == nil) then
        print(SGTAdvertiser.L["Error_NoMacro"]);
            SGTAdvertiser.macroButton:Hide();
        --if(SGTAdvertiser.searchMacroButton ~= nil) then
        --    SGTAdvertiser.searchMacroButton:Show();
        --end
        return;
    end
    --if(SGTAdvertiser.searchMacroButton ~= nil) then
    --    SGTAdvertiser.searchMacroButton:Hide();
    --end
    SGTAdvertiser.macroButton:Hide();
    SGTAdvertiser.macroButton:SetNormalTexture(icon);
    buttonInitialised = true;
end

function SGTAdvertiser:OnAdvertiserFrameCreated()
    local advertiserFrame = SGTCore:GetTabFrame("SGTAdvertiser");
    local scrollchild = advertiserFrame.scrollframe.scrollchild;
	local anchor = SGTCore:AddInitialAnchor("Anchor", scrollchild, advertiserFrame);
    local advertiserDescription = SGTCore:AddAnchoredFontString("SGTAdvertiserDescriptionText", scrollchild, anchor, 5, -5, SGTAdvertiser.L["SGTAdvertiserDescription"]);
    local enabledCheckbox = SGTCore:AddOptionCheckbox("SGTAdvertiserEnabledCheckbox", scrollchild, advertiserDescription, SGTAdvertiser.db.profile.settings.enabled, SGTAdvertiser.L["Enabled"], SGTAdvertiser.OnEnabledChecked)
    local sizeSlider = SGTCore:AddOptionSlider("SGTAdvertiserSizeSlider", scrollchild, enabledCheckbox, 10, 100, 1, SGTAdvertiser.db.profile.settings.buttonSize, SGTAdvertiser.L["ButtonSize"], SGTAdvertiser.OnSizeSliderChanged)
    local delaySlider = SGTCore:AddOptionSlider("SGTAdvertiserdelaySlider", scrollchild, sizeSlider, 120, 900, 10, SGTAdvertiser.db.profile.settings.timeBetweenPosts, SGTAdvertiser.L["delaySec"], SGTAdvertiser.OnDelaySliderChanged)
    SGTAdvertiser.searchMacroButton = SGTCore:AddButton("SGTAdvertiserScanButton", scrollchild, delaySlider, 125, 20, tostring(SGTAdvertiser.L["SearchMacro"]), SGTAdvertiser.OnSearchMacroButtonClicked)
    --if(buttonInitialised == true) then
    --    SGTAdvertiser.searchMacroButton:Hide();
    --end
end

function SGTAdvertiser:OnEnabledChecked(checked)
    if(checked == nil) then
        return;
    end
    SGTAdvertiser.db.profile.settings.enabled = checked;
end

function SGTAdvertiser:OnSearchMacroButtonClicked()
    SGTAdvertiser:UpdateMacroButton();
end

function SGTAdvertiser:OnSizeSliderChanged(value)
    if(value == nil) then
        return;
    end
    SGTAdvertiser.db.profile.settings.buttonSize = value;
    SGTAdvertiser.macroButton:SetSize(SGTAdvertiser.db.profile.settings.buttonSize,SGTAdvertiser.db.profile.settings.buttonSize);
end

function SGTAdvertiser:OnDelaySliderChanged(value)
    if(value == nil) then
        return;
    end
    SGTAdvertiser.db.profile.settings.timeBetweenPosts = value;
end

function SGTAdvertiser:GetVersionString()
    return tostring(SGTAdvertiser.majorVersion) .. "." .. tostring(SGTAdvertiser.subVersion) .. "." .. tostring(SGTAdvertiser.minorVersion);
end

function SGTAdvertiser:PostMacro()
    local body = GetMacroBody(GetMacroIndexByName("SGT"));
    if(string.sub(body,1,3) == "/2 ") then
        body = string.sub(body,4);
    end
    if (body) then
        SendChatMessage(body, 'CHANNEL', nil, '2');
        SGTAdvertiser.db.profile.lastPost = GetServerTime();
    else
        print(SGTAdvertiser.L["Error_NoMacro"]);
        SGTAdvertiser.macroButton:Hide();
        buttonInitialised = false;
    end
end

function OnUpdate(self, elapsed)
    local isShown = SGTAdvertiser.macroButton:IsShown();
    if(isFrameMoving == true) then
        return;
    end
    if(SGTAdvertiser.db.profile.settings.enabled == false or buttonInitialised == false or isTradeChatEnabled == false) then
        SGTAdvertiser:SetbuttonShown(false);
        return;
    end
    if(SGTAdvertiser.db.profile.lastPost == false) then
        SGTAdvertiser:SetbuttonShown(false);
        return;
    end
    if(SGTAdvertiser.db.profile.lastPost == nil or SGTAdvertiser.db.profile.lastPost < 0) then
        SGTAdvertiser:SetbuttonShown(false);
        return; --just for safety
    end
    if(SGTAdvertiser.db.profile.settings.timeBetweenPosts == nil or SGTAdvertiser.db.profile.settings.timeBetweenPosts < 0) then
        SGTAdvertiser:SetbuttonShown(false);
        return; --just for safety
    end
    if(GetServerTime() - SGTAdvertiser.db.profile.lastPost > SGTAdvertiser.db.profile.settings.timeBetweenPosts) then
        SGTAdvertiser:SetbuttonShown(true);
    else
        SGTAdvertiser:SetbuttonShown(false);
    end
end

function SGTAdvertiser:SetbuttonShown(shouldShow)
    if(shouldShow == true) then
        if(SGTAdvertiser.macroButton:IsShown() == false) then
            SGTAdvertiser.macroButton:Show();
        end
    else
        if(SGTAdvertiser.macroButton:IsShown() == true) then
            SGTAdvertiser.macroButton:Hide();
        end
    end
end

function SGTAdvertiser:PrintStatus()
    local timeSincePost = GetServerTime() - SGTAdvertiser.db.profile.lastPost;
    print(timeSincePost);--x time ago
    print(SGTAdvertiser.db.profile.settings.timeBetweenPosts - timeSincePost);
end