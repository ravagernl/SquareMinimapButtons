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

local LastFrame, FrameName, FrameNumber
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
	-- Button Bar Code
		Frame:ClearAllPoints()
		Frame:SetFrameStrata("LOW")
		if not LastFrame then
			Frame:SetPoint("TOP", SquareMinimapButtonBar, "TOP", 0, -2)
		else
			Frame:SetPoint("TOP", LastFrame, "BOTTOM", 0, -4)
		end
		tinsert(MoveButtons, Frame:GetName())
		LastFrame = Frame
		FrameNumber = FrameNumber + 1
end

local SquareMinimapButtonBar = CreateFrame("Frame", "SquareMinimapButtonBar", UIParent)
SquareMinimapButtonBar:SetFrameStrata("BACKGROUND")
SquareMinimapButtonBar:CreateBackdrop("Transparent")
SquareMinimapButtonBar:Width(28)
SquareMinimapButtonBar:SetPoint("RIGHT", UIParent,"RIGHT", -45, 0)
SquareMinimapButtonBar:SetMovable(true)
SquareMinimapButtonBar:EnableMouse(true)
SquareMinimapButtonBar:SetClampedToScreen(true)
SquareMinimapButtonBar:RegisterForDrag("LeftButton")
SquareMinimapButtonBar:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
SquareMinimapButtonBar:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
SquareMinimapButtonBar:SetScript("OnUpdate", function(self)
	if InCombatLockdown() then return end
	for _, buttons in pairs(MoveButtons) do
		_G[buttons]:SetParent(SquareMinimapButtonBar)
	end
end)

local SquareMinimapButtons = CreateFrame("Frame")
SquareMinimapButtons:RegisterEvent("PLAYER_ENTERING_WORLD")
SquareMinimapButtons:SetScript("OnEvent", function(self, event)
	if MMHolder or TukuiMinimap or AsphyxiaUIMinimap or DuffedUIMinimap then
		Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
	end
	for i = 1, Minimap:GetNumChildren() do
		SkinButton(select(i, Minimap:GetChildren()))
	end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SquareMinimapButtonBar:Height(28*FrameNumber)
end)