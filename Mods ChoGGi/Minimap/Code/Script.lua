-- See LICENSE for terms

local IsValid = IsValid
local StringFormat = string.format

local image_mod = Mods.ChoGGi_MapImagesPack
ChoGGi_Minimap = {
	UseScreenshots = true,
	image_str = image_mod and StringFormat("%sMaps/%s.png",image_mod.env.CurrentModPath,"%s"),
}

-- tell people how to get my library mod (if needs be)
local fire_once
function OnMsg.ModsReloaded()
	if fire_once then
		return
	end
	fire_once = true

	-- version to version check with
	local min_version = 44
	local idx = table.find(ModsLoaded,"id","ChoGGi_Library")

	-- if we can't find mod or mod is less then min_version (we skip steam since it updates automatically)
	if not idx or idx and not Platform.steam and min_version > ModsLoaded[idx].version then
		CreateRealTimeThread(function()
			if WaitMarsQuestion(nil,"Error",StringFormat([[Minimap requires ChoGGi's Library (at least v%s).
Press Ok to download it or check Mod Manager to make sure it's enabled.]],min_version)) == "ok" then
				OpenUrl("https://steamcommunity.com/sharedfiles/filedetails/?id=1504386374")
			end
		end)
	end

	local xt = XTemplates
	local idx = table.find(xt.HUD[1],"Id","idBottom")
	if not idx then
		print([[ChoGGi Minimap: missing HUD control idBottom]])
		return
	end
	xt = xt.HUD[1][idx]
	idx = table.find(xt,"Id","idRight")
	if not idx then
		print([[ChoGGi Minimap: missing HUD control idRight]])
		return
	end
	xt = xt[idx][1]

	ChoGGi.ComFuncs.RemoveXTemplateSections(xt,"ChoGGi_Template_Minimap")

	table.insert(xt,#xt,PlaceObj("XTemplateTemplate", {
		"ChoGGi_Template_Minimap", true,
		"__template", "HUDButtonTemplate",
		"RolloverText", [[Click to go places (updates minimap first click).]],
		"RolloverTitle", [[Minimap]],
		"Id", "idMinimap",
		"Image", StringFormat("%sUI/minimap.png",CurrentModPath),
		"ImageShine", StringFormat("%sUI/minimap_shine.png",CurrentModPath),
		"FXPress", "MainMenuButtonClick",
		"OnPress", function()
			HUD.idMinimapOnPress()
		end,
	})
	)
end

-- map name for title/image
local current_map
local function MapName()
	if current_map then
		return current_map
	else
		current_map = GetMapName(GetMap())
		return current_map
	end
end

local screenshot_taken
function OnMsg.LoadGame()
	current_map = false
	screenshot_taken = false
end

function OnMsg.CityStart()
	current_map = false
end


local map_dlg = false
local dlg_x,dlg_y

function OnMsg.SaveGame()
	if map_dlg and IsValid(map_dlg.idMapControl.sphere) then
		map_dlg.idMapControl.sphere:delete()
	end
end

function HUD.idMinimapOnPress()
	if map_dlg then
		-- save dlg pos
		local box = map_dlg.idDialog.content_box
		dlg_x = box:minx()
		dlg_y = box:miny()
		-- bye bye
		map_dlg:Close()
		map_dlg = false
		Dialogs.HUD.idMinimapHighlight:SetVisible(false)
	else
		map_dlg = ChoGGi_MinimapDlg:new({}, terminal.desktop,{
			x = dlg_x,
			y = dlg_y,
		})
		local ChoGGi_Minimap = ChoGGi_Minimap

		-- auto-update image once per load
		if ChoGGi_Minimap.UseScreenshots and not screenshot_taken then
			map_dlg:idUpdateMapOnPress()
			screenshot_taken = true
		end

		local map = MapName()
		-- use topo image instead of screenshot
		if ChoGGi_Minimap.UseScreenshots then
			map_dlg:UpdateMapImage(map_dlg.map_file)
		else
			-- check for formatting string
			local str = ChoGGi_Minimap.image_str
			if not str then
				local image_mod = Mods.ChoGGi_MapImagesPack
				ChoGGi_Minimap.image_str = image_mod and StringFormat("%sMaps/%s.png",image_mod.env.CurrentModPath,"%s")
				str = ChoGGi_Minimap.image_str
			end
			if str then
				map_dlg:UpdateMapImage(str:format(map))
			end
		end
		map_dlg.idCaption:SetText(map)
		map_dlg.map_name = map
		Dialogs.HUD.idMinimapHighlight:SetVisible(true)

	end

end

-- kill off on map change
function OnMsg.ChangeMapDone()
	local term = terminal.desktop
	for i = #term, 1, -1 do
		if term[i]:IsKindOf("ChoGGi_MinimapDlg") then
			term[i]:Close()
		end
	end
end
