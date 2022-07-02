local _G = _G or getfenv(0)

local resizes = {
  MainMenuBar, MainMenuExpBar, MainMenuBarMaxLevelBar,
  ReputationWatchBar, ReputationWatchStatusBar,
}

local frames = {
  ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
  MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
}

local textures = {
  MainMenuBarTexture0, MainMenuBarTexture1,
  MainMenuXPBarTexture2, MainMenuXPBarTexture3,
  ReputationWatchBarTexture2, ReputationWatchBarTexture3,
  ReputationXPBarTexture2, ReputationXPBarTexture3,
  SlidingActionBarTexture0, SlidingActionBarTexture1,
}

local normtextures = {
  ShapeshiftButton1, ShapeshiftButton2,
  ShapeshiftButton3, ShapeshiftButton4,
  ShapeshiftButton5, ShapeshiftButton6,
}

-- general function to hide textures and frames
local function hide(frame, texture)
  if not frame then return end

  if texture and texture == 1 and frame.SetTexture then
    frame:SetTexture("")
  elseif texture and texture == 2 and frame.SetNormalTexture then
    frame:SetNormalTexture("")
  else
    frame:ClearAllPoints()
    frame.Show = function() return end
    frame:Hide()
  end
end

-- reduce actionbar size
for id, frame in pairs(resizes) do frame:SetWidth(488) end

  -- hide reduced frames
for id, frame in pairs(frames) do hide(frame) end

-- clear reduced textures
for id, frame in pairs(textures) do hide(frame, 1) end

-- clear some button textures
for id, frame in pairs(normtextures) do hide(frame, 2) end

local ui = CreateFrame("Frame", "ShaguControllerUI", UIParent)
ui:RegisterEvent("PLAYER_ENTERING_WORLD")
ui:SetScript("OnEvent", function()
  -- update ui when frame positions get managed
  ui.manage_positions_hook = UIParent_ManageFramePositions
  UIParent_ManageFramePositions = ui.manage_positions
end)

ui.manage_button = function(self, frame, pos, x, y, image)
  -- set button scale and set position
  frame:SetScale(1.2)
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, pos, x, y)

  -- hide keybind text
  _G[frame:GetName().."HotKey"]:Hide()

  -- add keybind icon
  if not frame.keybind_icon then
    frame.keybind_icon = CreateFrame("Frame", nil, frame)
    frame.keybind_icon:SetFrameLevel(255)
    frame.keybind_icon:SetAllPoints(frame)

    frame.keybind_icon.tex = frame.keybind_icon:CreateTexture(nil, "OVERLAY")
    frame.keybind_icon.tex:SetTexture(image)
    frame.keybind_icon.tex:SetPoint("TOPRIGHT", frame.keybind_icon, "TOPRIGHT", 0, 0)
    frame.keybind_icon.tex:SetWidth(16)
    frame.keybind_icon.tex:SetHeight(16)
  end
end

ui.manage_positions = function(a1, a2, a3)
  -- run original function first
  ui.manage_positions_hook(a1, a2, a3)

  -- right action buttons
  ui:manage_button(ActionButton1, "BOTTOMRIGHT", -220, 135, "Interface\\AddOns\\ShaguController\\img\\y")
  ui:manage_button(ActionButton2, "BOTTOMRIGHT", -265,  90, "Interface\\AddOns\\ShaguController\\img\\x")
  ui:manage_button(ActionButton3, "BOTTOMRIGHT", -220,  45, "Interface\\AddOns\\ShaguController\\img\\a")
  ui:manage_button(ActionButton4, "BOTTOMRIGHT", -175,  90, "Interface\\AddOns\\ShaguController\\img\\b")

  -- left action buttons
  ui:manage_button(ActionButton5, "BOTTOMLEFT", 220, 135, "Interface\\AddOns\\ShaguController\\img\\up")
  ui:manage_button(ActionButton6, "BOTTOMLEFT", 265,  90, "Interface\\AddOns\\ShaguController\\img\\right")
  ui:manage_button(ActionButton7, "BOTTOMLEFT", 220,  45, "Interface\\AddOns\\ShaguController\\img\\down")
  ui:manage_button(ActionButton8, "BOTTOMLEFT", 175,  90, "Interface\\AddOns\\ShaguController\\img\\left")

  -- replace button 3 with jump icon
  ActionButton3Icon:SetTexture("Interface\\Icons\\inv_gizmo_rocketboot_01")
  ActionButton3Icon.SetTexture = function() return end

  ActionButton3Name:SetPoint("BOTTOM", 0, 5)
  ActionButton3Name:SetText("Jump")
  ActionButton3Name.SetText = function() return end

  ActionButton3:Show()
  ActionButton3.Hide = function() return end

  ActionButton3Icon:Show()
  ActionButton3Icon.Hide = function() return end

  -- move and resize chat
  ChatFrameEditBox:ClearAllPoints()
  ChatFrameEditBox:SetPoint("TOP", UIParent, "TOP", 0, -10)
  ChatFrameEditBox:SetWidth(300)
  ChatFrameEditBox:SetScale(2)

  -- on-screen keyboard helper
  ChatFrame1.oskHelper = ChatFrame1.oskHelper or CreateFrame("Button", nil, UIParent)
  ChatFrame1.oskHelper:SetFrameStrata("BACKGROUND")
  ChatFrame1.oskHelper:SetAllPoints(ChatFrame1)
  ChatFrame1.oskHelper:SetScript("OnClick", function()
    if not ChatFrameEditBox:IsVisible() then
      ChatFrameEditBox:Show()
      ChatFrameEditBox:Raise()
    else
      ChatFrameEditBox:Hide()
    end
  end)

  ChatFrame1.oskHelper:SetScript("OnUpdate", function()
    if ChatFrameEditBox:IsVisible() and this.state ~= 1 then
      ChatFrame1:SetScale(2)
      ChatFrame1:ClearAllPoints()
      ChatFrame1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
      ChatFrame1:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", 0, 0)
      this.state = 1
    elseif not ChatFrameEditBox:IsVisible() and this.state ~= 0 then
      local anchor = MainMenuBarArtFrame
      anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
      anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
      anchor = ShapeshiftBarFrame:IsVisible() and ShapeshiftBarFrame or anchor
      anchor = PetActionBarFrame:IsVisible() and PetActionBarFrame or anchor

      ChatFrame1:SetScale(1)
      ChatFrame1:ClearAllPoints()
      ChatFrame1:SetPoint("LEFT", MultiBarBottomLeft, "LEFT", 17, 0)
      ChatFrame1:SetPoint("RIGHT", MultiBarBottomLeft, "RIGHT", -17, 0)
      ChatFrame1:SetPoint("BOTTOM", anchor, "TOP", 0, 4)
      ChatFrame1:SetPoint("TOP", UIParent, "CENTER", 0, -200)
      this.state = 0
    end
  end)

  -- move and hide some chat buttons
  ChatFrameMenuButton:Hide()
  ChatFrameMenuButton.Show = function() return end

  for i=1, NUM_CHAT_WINDOWS do
    _G["ChatFrame"..i.."DownButton"]:ClearAllPoints()
    _G["ChatFrame"..i.."DownButton"]:SetPoint("BOTTOMRIGHT", _G["ChatFrame"..i], "BOTTOMRIGHT", 0, -5)

    _G["ChatFrame"..i.."UpButton"]:ClearAllPoints()
    _G["ChatFrame"..i.."UpButton"]:SetPoint("RIGHT", _G["ChatFrame"..i.."DownButton"], "LEFT", 0, 0)

    _G["ChatFrame"..i.."BottomButton"]:Hide()
    _G["ChatFrame"..i.."BottomButton"].Show = function() return end
  end

  -- move pet action bar
  local anchor = MainMenuBarArtFrame
  anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
  anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
  anchor = ShapeshiftBarFrame:IsVisible() and ShapeshiftBarFrame or anchor
  PetActionBarFrame:ClearAllPoints()
  PetActionBarFrame:SetPoint("BOTTOM", anchor, "TOP", 0, 3)

  -- move shapeshift bar
  local anchor = MainMenuBarArtFrame
  anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
  anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
  ShapeshiftBarFrame:ClearAllPoints()
  ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 10)

  -- move normal action bars
  MultiBarBottomLeft:ClearAllPoints()
  MultiBarBottomLeft:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, 20)

  MultiBarBottomRight:ClearAllPoints()
  MultiBarBottomRight:SetPoint("BOTTOM", MultiBarBottomLeft, "TOP", 0, 5)

  -- experience bar
  MainMenuXPBarTexture0:SetPoint("LEFT", MainMenuExpBar, "LEFT")
  MainMenuXPBarTexture1:SetPoint("RIGHT", MainMenuExpBar, "RIGHT")

  -- reputation bar
  ReputationWatchBar:SetPoint("BOTTOM", MainMenuExpBar, "TOP", 0, 0)
  ReputationWatchBarTexture0:SetPoint("LEFT", ReputationWatchBar, "LEFT")
  ReputationWatchBarTexture1:SetPoint("RIGHT", ReputationWatchBar, "RIGHT")

  -- move elements for reduced actionbar size
  MainMenuMaxLevelBar0:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT")
  MainMenuBarTexture2:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT")
  MainMenuBarTexture3:SetPoint("RIGHT", MainMenuBarArtFrame, "RIGHT")

  ActionBarDownButton:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMLEFT", -5, -5)
  ActionBarUpButton:SetPoint("TOPLEFT", MainMenuBarArtFrame, "TOPLEFT", -5, -5)
  MainMenuBarPageNumber:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT", 25, -5)
  CharacterMicroButton:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT", 38, 0)

  MainMenuBarLeftEndCap:SetPoint("RIGHT", MainMenuBarArtFrame, "LEFT", 30, 0)
  MainMenuBarRightEndCap:SetPoint("LEFT", MainMenuBarArtFrame, "RIGHT", -30, 0)

  -- move pfQuest arrow if existing
  if pfQuest and pfQuest.route and pfQuest.route.arrow then
    pfQuest.route.arrow:SetPoint("CENTER", 0, -120)
  end
end

-- save to main frame
ShaguController.ui = ui
