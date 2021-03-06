-- See LICENSE for terms

function OnMsg.ClassesGenerate()

	local S = ChoGGi.Strings
	local Actions = ChoGGi.Temp.Actions
--~	local StringFormat = string.format
	local c = #Actions

	c = c + 1
	Actions[c] = {ActionName = S[302535920000031--[[Find Nearest Resource--]]],
		ActionMenubar = "ECM.Expanded CM",
		ActionId = ".Find Nearest Resource",
		ActionIcon = "CommonAssets/UI/Menu/EV_OpenFirst.tga",
		RolloverText = S[302535920000554--[[Select an object and click this to display a list of resources.--]]],
		OnAction = function()
			ChoGGi.ComFuncs.FindNearestResource()
		end,
		ActionSortKey = "96",
	}

	c = c + 1
	Actions[c] = {ActionName = S[302535920000333--[[Building Info--]]],
		ActionMenubar = "ECM.Expanded CM",
		ActionId = ".Building Info",
		ActionIcon = "CommonAssets/UI/Menu/ExportImageSequence.tga",
		RolloverText = S[302535920000345--[[Shows info about building in text above it.--]]],
		OnAction = ChoGGi.MenuFuncs.BuildingInfo_Toggle,
		ActionSortKey = "97",
	}

	--~ c = c + 1
	--~ Actions[c] = {ActionName = S[302535920000555--[[Monitor Info--]]],
	--~ 	ActionMenubar = "ECM.Expanded CM",
	--~ 	ActionId = ".Monitor Info",
	--~ 	ActionIcon = "CommonAssets/UI/Menu/EV_OpenFirst.tga",
	--~ 	RolloverText = S[302535920000556--[[Shows a list of updated information about your city.--]]],
	--~ 	OnAction = ChoGGi.MenuFuncs.MonitorInfo,
	--~ 	ActionSortKey = "98",
	--~ }

	c = c + 1
	Actions[c] = {ActionName = S[302535920000469--[[Close Dialogs--]]],
		ActionMenubar = "ECM.Expanded CM",
		ActionId = ".Close Dialogs",
		ActionIcon = "CommonAssets/UI/Menu/remove_water.tga",
		RolloverText = S[302535920000470--[[Close any dialogs opened by ECM (Examine, ObjectManipulator, Change Colours, etc...)--]]],
		OnAction = function()
			ChoGGi.ComFuncs.CloseDialogsECM(true)
		end,
		ActionSortKey = "99",
	}

end
