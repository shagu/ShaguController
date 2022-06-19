-- TODO
-- Gosip Register for Keys
-- Space (A) accept, E (B) cancel

local _G = _G or getfenv(0)
BINDING_HEADER_SHAGUCONTROL = "ShaguController Custom Buttons"

local core = {}

core.keybinds = CreateFrame("Frame")
core.keybinds:RegisterEvent("PLAYER_LOGIN")
core.keybinds:RegisterEvent("PLAYER_LOGOUT")
core.keybinds:SetScript("OnEvent", function()
  if event == "PLAYER_LOGIN" then
    -- save previous keybinds
    core.keybinds.previous_bindings = GetCurrentBindingSet()

    -- overwrite keybindings on login
    SetBinding("TAB", "TOGGLEWORLDMAP")                 -- Window (TabKey)
    SetBinding("1", "SHAGUCONTROL1")                    -- Trackpad-Up: Inventory + Character
    SetBinding("2", "SHAGUCONTROL2")                    -- Trackpad-Right: QuestLog
    SetBinding("3", "SHAGUCONTROL3")                    -- Trackpad-Down: Talents & Social
    SetBinding("4", "SHAGUCONTROL4")                    -- Trackpad-Left: Spellbook
    SetBinding("MOUSEWHEELDOWN", "TARGETPREVIOUSENEMY") -- L1
    SetBinding("MOUSEWHEELUP", "TARGETNEARESTENEMY")    -- R1
    SetBinding("F", "ACTIONBUTTON1")                    -- Y
    SetBinding("R", "ACTIONBUTTON2")                    -- X
    SetBinding("E", "ACTIONBUTTON4")                    -- B
    -- Jump                                             -- A
    SetBinding("UP", "ACTIONBUTTON5")                   -- Arrow-Up
    SetBinding("RIGHT", "ACTIONBUTTON6")                -- Arrow-Right
    SetBinding("DOWN", "ACTIONBUTTON7")                 -- Arrow-Down
    SetBinding("LEFT", "ACTIONBUTTON8")                 -- Arrow-Down
    SaveBindings(GetCurrentBindingSet())

    -- notify the player for keybind changes
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00Shagu|cffffffffController: Initialized Keybinds")  
  elseif event == "PLAYER_LOGOUT" and core.previous_bindings then
    SaveBindings(core.keybinds.previous_bindings)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00Shagu|cffffffffController: Old Keybinds Restored")
  end
end)

core.loot = CreateFrame("Frame", "ShaguControllerLoot", LootFrame)
core.loot:SetScript("OnUpdate", function()
  if GetNumLootItems() == 0 then HideUIPanel(LootFrame) return end

  local x, y = GetCursorPosition()
	local s = LootFrame:GetEffectiveScale()
	x, y  = x / s, y / s

	for i = 1, LOOTFRAME_NUMBUTTONS, 1 do
		local button = getglobal("LootButton"..i)
		if button:IsVisible() then
		
		  if core.loot.last_button ~= button then
		    local button_offset = (i-1) * button:GetHeight()
    	  LootFrame:ClearAllPoints()
	    	LootFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - 40, y + 100 + button_offset)
	    	core.loot.last_button = button
	    end
	   
		  return
		end
	end
end)

core.loot:SetScript("OnShow", function()
  core.loot.last_button = nil
end)

core.ui = CreateFrame("Frame", "ShaguControllerUI", UIParent)
core.ui:RegisterEvent("PLAYER_ENTERING_WORLD")
core.ui:SetScript("OnEvent", function()
  -- update ui when frame positions get managed
  core.ui.manage_positions_hook = UIParent_ManageFramePositions
  UIParent_ManageFramePositions = core.ui.manage_positions
end)

core.ui.resizes = {
  MainMenuBar, MainMenuExpBar, MainMenuBarMaxLevelBar,
  ReputationWatchBar, ReputationWatchStatusBar,
}
    
core.ui.frames = {
  ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
}
      
core.ui.textures = {
  MainMenuBarTexture0, MainMenuBarTexture1,
  MainMenuXPBarTexture0, MainMenuXPBarTexture3,
  ReputationWatchBarTexture2, ReputationWatchBarTexture3,
  ReputationXPBarTexture2, ReputationXPBarTexture3,
  SlidingActionBarTexture0, SlidingActionBarTexture1,
}

core.ui.normtextures = {
  ShapeshiftButton1, ShapeshiftButton2,
  ShapeshiftButton3, ShapeshiftButton4,
  ShapeshiftButton5, ShapeshiftButton6,
}

-- general function to hide textures and frames
core.ui.hide = function(self, frame, texture)
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
    
core.ui.manage_button = function(self, frame, pos, x, y, image)
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

core.ui.manage_positions = function(a1, a2, a3)
  -- run original function first
  core.ui.manage_positions_hook(a1, a2, a3)
    
  -- right action buttons
  core.ui:manage_button(ActionButton1, "BOTTOMRIGHT", -220, 135, "Interface\\AddOns\\ShaguController\\img\\y")
  core.ui:manage_button(ActionButton2, "BOTTOMRIGHT", -265,  90, "Interface\\AddOns\\ShaguController\\img\\x")
  core.ui:manage_button(ActionButton3, "BOTTOMRIGHT", -220,  45, "Interface\\AddOns\\ShaguController\\img\\a")
  core.ui:manage_button(ActionButton4, "BOTTOMRIGHT", -175,  90, "Interface\\AddOns\\ShaguController\\img\\b")
  
  -- left action buttons
  core.ui:manage_button(ActionButton5, "BOTTOMLEFT", 220, 135, "Interface\\AddOns\\ShaguController\\img\\up")
  core.ui:manage_button(ActionButton6, "BOTTOMLEFT", 265,  90, "Interface\\AddOns\\ShaguController\\img\\right")
  core.ui:manage_button(ActionButton7, "BOTTOMLEFT", 220,  45, "Interface\\AddOns\\ShaguController\\img\\down")
  core.ui:manage_button(ActionButton8, "BOTTOMLEFT", 175,  90, "Interface\\AddOns\\ShaguController\\img\\left")
  
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
  local anchor = MainMenuBarArtFrame
  anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
  anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
  anchor = ShapeshiftBarFrame:IsVisible() and ShapeshiftBarFrame or anchor
  anchor = PetActionBarFrame:IsVisible() and PetActionBarFrame or anchor
  
  ChatFrame1:ClearAllPoints()
  ChatFrame1:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 17, 13)
  ChatFrame1:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", -17, 13)
  ChatFrame1:SetPoint("TOP", UIParent, "CENTER", 0, -200)
  
  -- move and hide some chat buttons
  ChatFrame1DownButton:ClearAllPoints()
  ChatFrame1DownButton:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, -5)
  
  ChatFrame1UpButton:ClearAllPoints()
  ChatFrame1UpButton:SetPoint("RIGHT", ChatFrame1DownButton, "LEFT", 0, 0)
  
  ChatFrameMenuButton:Hide()
  ChatFrame1BottomButton:Hide()

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
  
  -- reduce actionbar size
  for id, frame in pairs(core.ui.resizes) do frame:SetWidth(488) end
  
  -- hide reduced frames
  for id, frame in pairs(core.ui.frames) do core.ui:hide(frame) end

  -- clear reduced textures
  for id, frame in pairs(core.ui.textures) do core.ui:hide(frame, 1) end
  
  -- clear some button textures
  for id, frame in pairs(core.ui.normtextures) do core.ui:hide(frame, 2) end
end
