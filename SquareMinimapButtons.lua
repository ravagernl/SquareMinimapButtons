if not (IsAddOnLoaded("Tukui") or IsAddOnLoaded("AsphyxiaUI") or IsAddOnLoaded("DuffedUI") or IsAddOnLoaded("ElvUI")) then return end
local IgnoreButtons = {
	"AsphyxiaUIMinimapHelpButton",
	"AsphyxiaUIMinimapVersionButton",
	"DBMMinimapButton",
	"ElvConfigToggle",
	"ZygorGuidesViewerMapIcon",
	"GameTimeFrame",
	"HelpOpenTicketButton",
	"MiniMapMailFrame",
	"MiniMapTrackingButton",
	"MiniMapVoiceChatFrame",
	"QueueStatusMinimapButton",
	"TimeManagerClockButton",
}

local MoveButtons = {}

local LastFrame, FrameName, FrameNumber, Anchor1, Anchor2, AnchorX1, AnchorY1, AnchorX2, AnchorY2
FrameNumber = 0

local function SkinButton(Frame)
	if(Frame:GetObjectType() ~= "Button") then return end

	for i, buttons in pairs(IgnoreButtons) do
		if(Frame:GetName() ~= nil) then
			if(Frame:GetName():match(buttons)) then return end
		end
	end

	for i = 1,999 do
		if _G["GatherMatePin"..i] == Frame then return end
	end

	Frame:SetPushedTexture(nil)
	Frame:SetHighlightTexture(nil)
	Frame:SetDisabledTexture(nil)
	Frame:Size(24)

	for i = 1, Frame:GetNumRegions() do
		local Region = select(i, Frame:GetRegions())
		if(Region:GetObjectType() == "Texture") then
			local Texture = Region:GetTexture()

			if(Texture and (Texture:find("Border") or Texture:find("Background") or Texture:find("AlphaMask"))) then
				Region:SetTexture(nil)
			else
				Region:ClearAllPoints()
				Region:Point("TOPLEFT", Frame, "TOPLEFT", 2, -2)
				Region:Point("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -2, 2)
				Region:SetTexCoord( 0.1, 0.9, 0.1, 0.9 )
				Region:SetDrawLayer( "ARTWORK" )
				if(Frame:GetName() == "PS_MinimapButton") then
					Region.SetPoint = function() end
				end
			end
		end
	end
	if IsAddOnLoaded("Tukui_Skins") and not IsAddOnLoaded("ElvUI") then
		local U = unpack(UISkins)
		U.SkinFrame(Frame, true)
	else
		Frame:SetTemplate("Default")
	end
	
	if not Frame:IsShown() then return end
	if SquareMinimapButtonBarLayout == "Disabled" then return end
	if SquareMinimapButtonBarLayout == "Vertical" then
		Anchor1 = "TOP"
		Anchor2 = "BOTTOM"
		AnchorX1 = 0
		AnchorY1 = -3
		AnchorX2 = 0
		AnchorY2 = -2
	elseif SquareMinimapButtonBarLayout == "Horizontal" then
		Anchor1 = "RIGHT"
		Anchor2 = "LEFT"
		AnchorX1 = -3
		AnchorY1 = 0
		AnchorX2 = -2
		AnchorY2 = 0
	end
	
	Frame:ClearAllPoints()
	Frame:SetFrameStrata("LOW")
	if not LastFrame then
		Frame:SetPoint(Anchor1, SquareMinimapButtonBar, Anchor1, AnchorX1, AnchorY1)
	else
		Frame:SetPoint(Anchor1, LastFrame, Anchor2, AnchorX2, AnchorY2)
	end
	tinsert(MoveButtons, Frame:GetName())
	LastFrame = Frame
	FrameNumber = FrameNumber + 1
end

local SquareMinimapButtonBarAnchor = CreateFrame("Frame", "SquareMinimapButtonBarAnchor", UIParent)
SquareMinimapButtonBarAnchor:SetFrameStrata("HIGH")
SquareMinimapButtonBarAnchor:SetTemplate("Transparent")
SquareMinimapButtonBarAnchor:SetBackdropBorderColor(1,0,0)
SquareMinimapButtonBarAnchor:SetPoint("RIGHT", UIParent,"RIGHT", -45, 0)
SquareMinimapButtonBarAnchor:SetMovable(true)
SquareMinimapButtonBarAnchor:EnableMouse(true)
SquareMinimapButtonBarAnchor:SetClampedToScreen(true)
SquareMinimapButtonBarAnchor:RegisterForDrag("LeftButton")
SquareMinimapButtonBarAnchor:SetScript("OnDragStart", function(self) self:StartMoving() end)
SquareMinimapButtonBarAnchor:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
SquareMinimapButtonBarAnchor:Hide()
SquareMinimapButtonBarAnchor.text = SquareMinimapButtonBarAnchor:CreateFontString(nil, "OVERLAY")
SquareMinimapButtonBarAnchor.text:SetPoint("CENTER", SquareMinimapButtonBarAnchor, 0, 0)

local SquareMinimapButtonBar = CreateFrame("Frame", "SquareMinimapButtonBar", UIParent)
SquareMinimapButtonBar:SetFrameStrata("BACKGROUND")
SquareMinimapButtonBar:SetTemplate("Transparent")
SquareMinimapButtonBar:SetPoint("CENTER", SquareMinimapButtonBarAnchor,"CENTER", 0, 0)
SquareMinimapButtonBar:SetScript("OnUpdate", function(self)
	if InCombatLockdown() then return end
	for _, buttons in pairs(MoveButtons) do
		if _G[buttons]:GetParent() ~= self then _G[buttons]:SetParent(self) end
	end
end)

local SquareMinimapButtons = CreateFrame("Frame")
SquareMinimapButtons:RegisterEvent("PLAYER_ENTERING_WORLD")
SquareMinimapButtons:SetScript("OnEvent", function(self, event)
	if SquareMinimapButtonBarLayout == nil then SquareMinimapButtonBarLayout = "Disabled" end
	if MMHolder or TukuiMinimap or AsphyxiaUIMinimap or DuffedUIMinimap then
		Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
	end
	for i = 1, Minimap:GetNumChildren() do
		SkinButton(select(i, Minimap:GetChildren()))
	end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if SquareMinimapButtonBarLayout == "Vertical" then
		SquareMinimapButtonBar:Width(30)
		SquareMinimapButtonBarAnchor:Width(30)
		SquareMinimapButtonBar:Height((26*FrameNumber)+(FrameNumber-1))
		SquareMinimapButtonBarAnchor:Height((26*FrameNumber)+(FrameNumber-1))
	elseif SquareMinimapButtonBarLayout == "Horizontal" then
		SquareMinimapButtonBar:Height(30)
		SquareMinimapButtonBarAnchor:Height(30)
		SquareMinimapButtonBar:Width((26*FrameNumber)+(FrameNumber-1))
		SquareMinimapButtonBarAnchor:Width((26*FrameNumber)+(FrameNumber-1))
	end
	local A, C = unpack(ElvUI or Tukui or DuffedUI or AsphyxiaUI)
	SquareMinimapButtonBarAnchor.text:SetFont(ElvUI and A["media"].normFont or C["media"].font, 12, "OUTLINE")
	SquareMinimapButtonBarAnchor.text:SetText("Square Minimap Button Anchor")
end)

SLASH_SQUAREMINIMAP1 = "/mbb"
SlashCmdList["SQUAREMINIMAP"] = function(arg)
	if arg == "unlock" or arg == "lock" then
		if SquareMinimapButtonBarAnchor:IsShown() then
			SquareMinimapButtonBarAnchor:Hide()
		else
			SquareMinimapButtonBarAnchor:Show()
		end
	elseif arg == "Horizontal" or arg == "horizontal" or arg == "h" then
		SquareMinimapButtonBarLayout = "Horizontal"
		print("Square Minimap Button Bar Layout: "..SquareMinimapButtonBarLayout.." Set!")
		print("Please Reload for changes to take effect. /rl")
	elseif arg == "Vertical" or arg == "vertical" or arg == "v" then
		SquareMinimapButtonBarLayout = "Vertical"
		print("Square Minimap Button Bar Layout: "..SquareMinimapButtonBarLayout.." Set!")
		print("Please Reload for changes to take effect. /rl")
	elseif arg == "Disable" or arg == "disable" then
		SquareMinimapButtonBarLayout = "Disabled"
		print("Square Minimap Button Bar : "..SquareMinimapButtonBarLayout)
		print("Please Reload for changes to take effect. /rl")
	elseif arg == "" then
		print("Square Minimap Button Bar Options")
		print("/mbb Horizontal")
		print("/mbb Vertical")
		print("/mbb Disabled")
	end
end