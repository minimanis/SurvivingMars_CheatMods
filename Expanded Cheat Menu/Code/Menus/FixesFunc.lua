-- See LICENSE for terms

function OnMsg.ClassesGenerate()
	local MsgPopup = ChoGGi.ComFuncs.MsgPopup
	local DeleteObject = ChoGGi.ComFuncs.DeleteObject
	local S = ChoGGi.Strings

	local pairs,pcall,type = pairs,pcall,type
	local StringFormat = string.format

	function ChoGGi.MenuFuncs.FireMostFixes()
		CreateRealTimeThread(function()
			local ChoGGi = ChoGGi
			local Sleep = Sleep

			pcall(function()
				ChoGGi.MenuFuncs.RemoveUnreachableConstructionSites()
				ChoGGi.MenuFuncs.ParticlesWithNullPolylines()
				ChoGGi.MenuFuncs.StutterWithHighFPS()

				ChoGGi.MenuFuncs.ColonistsTryingToBoardRocketFreezesGame()
				ChoGGi.MenuFuncs.AttachBuildingsToNearestWorkingDome()
				ChoGGi.MenuFuncs.DronesKeepTryingBlockedAreas()
				ChoGGi.MenuFuncs.RemoveYellowGridMarks()
				ChoGGi.MenuFuncs.RemoveBlueGridMarks()
				ChoGGi.MenuFuncs.CablesAndPipesRepair()
				ChoGGi.MenuFuncs.MirrorSphereStuck()
				ChoGGi.MenuFuncs.ProjectMorpheusRadarFellDown()
			end)

			-- loop through and remove all my msgs from the onscreen popups
			CreateRealTimeThread(function()
				Sleep(1000)
				while #ChoGGi.Temp.MsgPopups < 10 do
					Sleep(500)
				end
				local popups = ChoGGi.Temp.MsgPopups or ""
				for i = #popups, 1, -1 do
					popups[i]:delete()
				end
				ChoGGi.Temp.MsgPopups = {}
			end)
		end)
	end

	function ChoGGi.MenuFuncs.RocketCrashesGameOnLanding()
		local rockets = UICity.labels.SupplyRocket or ""
		for i = 1, #rockets do
			rockets[i]:ForEachAttach("ParSystem",function(a)
				if type(a.polyline) == "string" and a.polyline:find("\0") then
					a:delete()
				end
			end)
		end
		MsgPopup(
			4493--[[All--]],
			302535920001351--[[Rocket Crashes Game On Landing--]]
		)
	end

	function ChoGGi.MenuFuncs.ToggleWorkingAll()
		MapForEach("map","BaseBuilding",function(o)
			if type(o.ToggleWorking) == "function" and not o:IsKindOfClasses("OrbitalProbe","ResourceStockpile","WasteRockStockpile","BaseRover") then
				ChoGGi.ComFuncs.ToggleWorking(o)
			end
		end)

		MsgPopup(
			4493--[[All--]],
			302535920001299--[[Toggle Working On All Buildings--]]
		)
	end

	do -- DronesNotRepairingDome
		local looping_thread

		function ChoGGi.MenuFuncs.DronesNotRepairingDomes()
			local MapGet = MapGet
			local Sleep = Sleep
			MsgPopup(
				83--[[Domes--]],
				302535920001295--[[Drones Not Repairing Domes--]]
			)
			-- just in case someone decides to click it more than once...
			if looping_thread then
				DeleteThread(looping_thread)
				looping_thread = nil
			end
			-- loop 50 times, more than long enough for a drone smart/idle enough to grab the res outside the dome and repair it.
			looping_thread = CreateRealTimeThread(function()
				local count = 0
				while true do
					if count > 49 then
						break
					end
					count = count + 1

					local domes = UICity.labels.Domes or ""
					for i = 1, #domes do
						-- get a list of all res in the center of dome
						local pos = domes[i]:GetSpotPos(-1)
						local objs = MapGet(pos, 1000, "ResourcePile")
						-- loop through the spots till we find a Workdrone outside the dome (any spot outside will do)
						local id_start, id_end = domes[i]:GetAllSpots(domes[i]:GetState())
						for j = id_start, id_end do
							if domes[i]:GetSpotName(j) == "Workdrone" then
								local spot_pos = domes[i]:GetSpotPos(j)
								-- and goodbye res
								for k = 1, #objs do
									objs[k]:SetPos(spot_pos)
								end
								break
							end
						end
					end

					Sleep(1000)
				end
				MsgPopup(
					1157--[[Complete thread--]],
					302535920001295--[[Drones Not Repairing Domes--]]
				)
			end)
		end
	end -- do

	function ChoGGi.MenuFuncs.CheckForBorkedTransportPath_Toggle()
		local ChoGGi = ChoGGi
		if ChoGGi.UserSettings.CheckForBorkedTransportPath then
			ChoGGi.UserSettings.CheckForBorkedTransportPath = nil
		else
			ChoGGi.UserSettings.CheckForBorkedTransportPath = true
			ChoGGi.MenuFuncs.StutterWithHighFPS(true)
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.CheckForBorkedTransportPath,302535920001266--[[Borked Transport Pathing--]]),
			1683--[[RC Transport--]],
			"UI/Icons/IPButtons/transport_route.tga"
		)
	end

	function ChoGGi.MenuFuncs.AllPipeSkinsToDefault()
		local ChoGGi = ChoGGi
		local Sleep = Sleep
		CreateRealTimeThread(function()
			-- so GetPipeConnections ignores the dupe connection error
			ChoGGi.Temp.FixingPipes = true
			local grids = UICity.water
			for i = 1, #grids do
				grids[i]:ChangeElementSkin("Chrome", true)
				-- needs a slight delay between changing skins
				Sleep(100)
				grids[i]:ChangeElementSkin("Default", true)
			end
			ChoGGi.Temp.FixingPipes = nil
		end)
		MsgPopup(
			4493--[[All--]],
			302535920000461--[[All Pipe Skins To Default--]]
		)
	end

	do --ResetCommanders
		local function ResetRover(rc)
			local drones
			if rc.attached_drones then
				drones = #rc.attached_drones
				for i = 1, #rc.attached_drones do
					rc.attached_drones[i]:delete()
				end
			end
			local pos = rc:GetVisualPos()
			local new = rc:Clone()
			rc:delete()
			new:SetPos(GetPassablePointNearby(pos))
			-- add any missing drones
			if drones > #new.attached_drones then
				repeat
					new:SpawnDrone()
				until drones == #new.attached_drones
			end
		end

		function ChoGGi.MenuFuncs.ResetCommanders()
			CreateRealTimeThread(function()
				local Sleep = Sleep
				local GetStateIdx = GetStateIdx
				local before_table = {}

				-- get all commanders stuck in deploy with at least one drone
				MapForEach("map","RCRover",function(rc)
					local drones = #rc.attached_drones > 0
					if drones then
						if rc:GetState() == GetStateIdx("deployIdle") then
							-- store them in a table for later
							before_table[rc.handle] = {rc = rc, amount = #rc.attached_drones}
						-- borked, no sense in waiting for later
						elseif rc:GetState() == GetStateIdx("idle") and rc.waiting_on_drones then
							ResetRover(rc)
						end
					end
				end)
				-- let user know something is happening
				MsgPopup(
					302535920000464--[[Updating Rovers--]],
					5438--[[Rovers--]]
				)
				--wait awhile just to be sure
				Sleep(5000)
				--go through and reset any rovers still doing the same thing
				for _,rc_table in pairs(before_table) do
					local state = rc_table.rc:GetState() == GetStateIdx("deployIdle")
					local drones = #rc_table.rc.attached_drones == rc_table.amount
					if state and drones then
						ResetRover(rc_table.rc)
					end
				end
			end)
		end
	end -- do

	do -- Colonist stuff
		local SpawnColonist = ChoGGi.ComFuncs.SpawnColonist
		local IsValid = IsValid
		local FindNearestObject = FindNearestObject
		local GetPassablePointNearby = GetPassablePointNearby

		function ChoGGi.MenuFuncs.ResetAllColonists()
			local UICity = UICity
			local function CallBackFunc(answer)
				if answer then
					local objs = UICity.labels.Colonist or ""
					for i = 1, #objs do
						local c = objs[i]
						local is_valid = IsValid(c)
						SpawnColonist(c,nil,is_valid and c:GetVisualPos(),UICity)
						if is_valid then
							c:delete()
						end
					end
				end
			end

			ChoGGi.ComFuncs.QuestionBox(
				StringFormat("%s!\n%s\n%s",S[6779--[[Warning--]]],S[302535920000055--[[Reset All Colonists--]]],S[302535920000939--[["Fix certain freezing issues (mouse still moves screen, keyboard doesn't), will lower comfort by about 20."--]]]),
				CallBackFunc,
				StringFormat("%s: %s",S[6779--[[Warning--]]],S[302535920000055--[[Reset All Colonists--]]])
			)
		end

		function ChoGGi.MenuFuncs.ColonistsTryingToBoardRocketFreezesGame()
			local UICity = UICity
			local objs = UICity.labels.Colonist or ""
			local rockets = UICity.labels.SupplyRocket or {}
			for i = 1, #objs do
				local c = objs[i]
				local is_valid = IsValid(c)
				if is_valid and c:GetStateText() == "movePlanet" then
					local rocket = FindNearestObject(rockets,c)
					SpawnColonist(c,rocket,c:GetVisualPos(),UICity)
					c:delete()
				end
			end

			MsgPopup(
				4493--[[All--]],
				302535920000591--[[Colonists Trying To Board Rocket Freezes Game--]]
			)
		end

		local function AttachedColonist(c,pos,rocket,city)
			-- try to remove attached colonist from rocket, and get pos so we can create a new c at the same pos
			if IsValid(c) then
				c:Detach()
				SpawnColonist(c,rocket,pos,city)
				c:delete()
			else
				SpawnColonist(nil,nil,rocket,pos,city)
			end
		end
		function ChoGGi.MenuFuncs.ColonistsStuckOutsideRocket()
			local InvalidPos = ChoGGi.Consts.InvalidPos
			local UICity = UICity
			local rockets = UICity.labels.SupplyRocket or ""
			for i = 1, #rockets do
				-- SupplyRocket also returns rockets in space
				if rockets[i]:GetPos() ~= InvalidPos then
					local pos = GetPassablePointNearby(rockets[i]:GetPos())
					rockets[i]:ForEachAttach("Colonist",AttachedColonist,pos,rockets[i],UICity)
				end
			end
			MsgPopup(
				302535920000585--[[Colonists Stuck Outside Rocket--]],
				5238--[[Rockets--]]
			)
		end

	end -- do

	function ChoGGi.MenuFuncs.ParticlesWithNullPolylines()
		SuspendPassEdits("ParticlesWithNullPolylines")
		MapDelete(true, "ParSystem",function(o)
			if type(o.polyline) == "string" and o.polyline:find("\0") then
				return true
			end
		end)
		ResumePassEdits("ParticlesWithNullPolylines")

		MsgPopup(
			302535920000593--[[Remove Particles With Null Polylines--]],
			4493--[[All--]]
		)
	end

	function ChoGGi.MenuFuncs.RemoveMissingClassObjects()
		SuspendPassEdits("RemoveMissingClassObjects")
		MapDelete(true, "UnpersistedMissingClass")
		ResumePassEdits("RemoveMissingClassObjects")
		MsgPopup(
			302535920000587--[[Remove Missing Class Objects (Warning)--]],
			4493--[[All--]]
		)
	end

	function ChoGGi.MenuFuncs.MirrorSphereStuck()
		local type = type
		local IsValid = IsValid

		local objs = UICity.labels.MirrorSpheres or ""
		for i = 1, #objs do
			if not IsValid(objs[i].target) then
				DeleteObject(objs[i])
			end
		end

		SuspendPassEdits("MirrorSphereStuck")
		MapDelete(true, "ParSystem",function(o)
--~ 			if o:GetProperty("ParticlesName") == "PowerDecoy_Captured" and
			if o:GetParticlesName() == "PowerDecoy_Captured" and
					type(o.polyline) == "string" and o.polyline:find("\0") then
				return true
			end
		end)
		ResumePassEdits("MirrorSphereStuck")

		MsgPopup(
			302535920000595--[[Mirror Sphere Stuck--]],
			4493--[[All--]]
		)
	end

	function ChoGGi.MenuFuncs.StutterWithHighFPS(skip)
		local ChoGGi = ChoGGi
		local objs = UICity.labels.Unit or ""
		--CargoShuttle
		for i = 1, #objs do
			ChoGGi.ComFuncs.CheckForBorkedTransportPath(objs[i])
		end

		if skip ~= true then
			ChoGGi.ComFuncs.ResetHumanCentipedes()
		end
		MsgPopup(
			302535920000597--[[Stutter With High FPS--]],
			4493--[[All--]]
		)
	end

	do -- DronesKeepTryingBlockedAreas
		local function ResetPriorityQueue(cls_name)
			local max = const.MaxBuildingPriority
			MapForEach("map",cls_name,function(o)
				-- clears out the queues
				o.priority_queue = {}
				for priority = -1, max do
					o.priority_queue[priority] = {}
				end
			end)
		end

		function ChoGGi.MenuFuncs.DronesKeepTryingBlockedAreas()
			local ChoGGi = ChoGGi
			ResetPriorityQueue("SupplyRocket")
			ResetPriorityQueue("RCRover")
			ResetPriorityQueue("DroneHub")
			-- toggle working state on all ConstructionSite (wakes up drones else they'll wait at hub)
			MapForEach("map","ConstructionSite",function(o)
				ChoGGi.ComFuncs.ToggleWorking(o)
			end)
			MsgPopup(
				302535920000599--[[Drones Keep Trying Blocked Areas--]],
				4493--[[All--]]
			)
		end
	end -- do

	function ChoGGi.MenuFuncs.AlignAllBuildingsToHexGrid()
		local HexGetNearestCenter = HexGetNearestCenter
		MapForEach("map","Building",function(o)
			o:SetPos(HexGetNearestCenter(o:GetVisualPos()))
		end)
		MsgPopup(
			302535920000621--[[Align All Buildings To Hex Grid--]],
			4493--[[All--]]
		)
	end

	do -- RemoveUnreachableConstructionSites
		local type,pairs = type,pairs
		local function RemoveUnreachable(cls_name)
			MapForEach("map",cls_name,function(o)
				for bld,_ in pairs(o.unreachable_buildings or {}) do
					if type(bld.IsKindOf) == "function" and bld:IsKindOf("ConstructionSite") then
						bld:Cancel()
					end
				end
				o.unreachable_buildings = {}
			end)
		end

		function ChoGGi.MenuFuncs.RemoveUnreachableConstructionSites()
			local objs = UICity.labels.Drone or ""
			for i = 1, #objs do
				objs[i]:CleanUnreachables()
			end
			RemoveUnreachable("DroneHub")
			RemoveUnreachable("RCRover")
			RemoveUnreachable("SupplyRocket")

			MsgPopup(
				302535920000601--[[Idle Drones Won't Build When Resources Available--]],
				302535920000971--[[Sites--]]
			)
		end
	end -- do

	function ChoGGi.MenuFuncs.RemoveYellowGridMarks()
		SuspendPassEdits("RemoveYellowGridMarks")
		MapDelete(true, "GridTile")
		ResumePassEdits("RemoveYellowGridMarks")
		MsgPopup(
			302535920000603--[[Remove Yellow Grid Marks--]],
			4493--[[All--]]
		)
	end

	function ChoGGi.MenuFuncs.RemoveBlueGridMarks()
		SuspendPassEdits("RemoveBlueGridMarks")
		MapDelete(true, "RangeHexRadius",function(o)
			if not o.ToggleWorkZone then
				return true
			end
		end)
		-- remove the rover outlines added from https://forum.paradoxplaza.com/forum/index.php?threads/surviving-mars-persistent-transport-route-blueprint-on-map.1121333/
		MapDelete(true, "WireFramedPrettification",function(o)
			if o.entity == "RoverTransport" then
				return true
			end
		end)
		ResumePassEdits("RemoveBlueGridMarks")

		MsgPopup(
			302535920001193--[[Remove Blue Grid Marks--]],
			4493--[[All--]]
		)
	end

	function ChoGGi.MenuFuncs.ProjectMorpheusRadarFellDown()
		local objs = UICity.labels.ProjectMorpheus or ""
		for i = 1, #objs do
			objs[i]:ChangeWorkingStateAnim(false)
			objs[i]:ChangeWorkingStateAnim(true)
		end
		MsgPopup(
			302535920000605--[[Project Morpheus Radar Fell Down--]],
			4493--[[All--]]
		)
	end

	function ChoGGi.MenuFuncs.RebuildWalkablePointsInDomes()
		MapForEach("map","Dome",function(o)
			o.walkable_points = false
			o:GenerateWalkablePoints()
		end)
		MsgPopup(
			302535920000583--[[Rebuild Walkable Points In Domes--]],
			4493--[[All--]]
		)
	end

	function ChoGGi.MenuFuncs.AttachBuildingsToNearestWorkingDome()
		local ChoGGi = ChoGGi
		local AttachToNearestDome = ChoGGi.ComFuncs.AttachToNearestDome
		local objs = UICity.labels.InsideBuildings or ""
		for i = 1, #objs do
			AttachToNearestDome(objs[i])
		end

		MsgPopup(
			302535920000609--[[Attach Buildings To Nearest Working Dome--]],
			3980--[[Buildings--]],
			"UI/Icons/Sections/basic.tga"
		)
	end

	function ChoGGi.MenuFuncs.ColonistsFixBlackCube()
		local objs = UICity.labels.Colonist or ""
		for i = 1, #objs do
			local c = objs[i]
			if c.entity:find("Child") and c.specialist ~= "none" then
				c.specialist = "none"

				c.traits.Youth = nil
				c.traits.Adult = nil
				c.traits["Middle Aged"] = nil
				c.traits.Senior = nil
				c.traits.Retiree = nil

				c.traits.Child = true
				c.age_trait = "Child"
				c.age = 0
				c:ChooseEntity()
				c:SetResidence(false)
				c:UpdateResidence()
			end
		end
		MsgPopup(
			302535920000619--[[Fix Black Cube Colonists--]],
			4493--[[All--]]
		)
	end

	do -- CablesAndPipesRepair
		local function RepairBorkedShit(borked_shit)
			local type = type
			local IsValid = IsValid
			local just_in_case = 0
			while #borked_shit > 0 do

				for i = #borked_shit, 1, -1 do
					if IsValid(borked_shit[i]) and type(borked_shit[i].Repair) == "function" then
						borked_shit[i]:Repair()
					end
				end

				if just_in_case > 25000 then
					break
				end
				just_in_case = just_in_case + 1

			end
		end

		function ChoGGi.MenuFuncs.CablesAndPipesRepair()
			local g_BrokenSupplyGridElements = g_BrokenSupplyGridElements
			RepairBorkedShit(g_BrokenSupplyGridElements.electricity)
			RepairBorkedShit(g_BrokenSupplyGridElements.water)

			MsgPopup(
				S[302535920000157--[[Cables & Pipes--]]],": ",S[302535920000607--[[Instant Repair--]]],
				4493--[[All--]]
			)
		end
	end -- do

	------------------------- toggles

	-- fucking ai mods... (fix your shit or take it down kthxbai)
	function ChoGGi.MenuFuncs.ColonistsStuckOutsideServiceBuildings_Toggle()
		local ChoGGi = ChoGGi
		if ChoGGi.UserSettings.ColonistsStuckOutsideServiceBuildings then
			ChoGGi.UserSettings.ColonistsStuckOutsideServiceBuildings = nil
		else
			ChoGGi.UserSettings.ColonistsStuckOutsideServiceBuildings = true
			ChoGGi.ComFuncs.ResetHumanCentipedes()
		end

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.ColonistsStuckOutsideServiceBuildings,302535920000248--[[Colonists Stuck Outside Service Buildings--]]),
			547--[[Colonists--]],
			"UI/Icons/IPButtons/colonist_section.tga"
		)
	end

	function ChoGGi.MenuFuncs.DroneResourceCarryAmountFix_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.DroneResourceCarryAmountFix = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.DroneResourceCarryAmountFix)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.DroneResourceCarryAmountFix,302535920000613--[[Drone Carry Amount--]]),
			517--[[Drones--]],
			"UI/Icons/IPButtons/drone.tga"
		)
	end

	function ChoGGi.MenuFuncs.SortCommandCenterDist_Toggle()
		local ChoGGi = ChoGGi
		ChoGGi.UserSettings.SortCommandCenterDist = ChoGGi.ComFuncs.ToggleValue(ChoGGi.UserSettings.SortCommandCenterDist)

		ChoGGi.SettingFuncs.WriteSettings()
		MsgPopup(
			ChoGGi.ComFuncs.SettingState(ChoGGi.UserSettings.SortCommandCenterDist,302535920000615--[[Sort Command Center Dist--]]),
			3980--[[Buildings--]]
		)
	end

	---------------------------------------------------Testers

	--~ GetDupePositions(UICity.labels.Colonist or "")
	--~ function ChoGGi.MenuFuncs.GetDupePositions(list)
	--~	 local dupes = {}
	--~	 local positions = {}
	--~	 local pos
	--~	 for i = 1, #list do
	--~		 pos = list[i]:GetPos()
	--~		 pos = tostring(point(pos:x(),pos:y()))
	--~		 if not positions[pos] then
	--~			 positions[pos] = true
	--~		 else
	--~			 dupes[pos] = true
	--~		 end
	--~	 end
	--~	 if #dupes > 0 then
	--~		 table.sort(dupes)
	--~		 ChoGGi.ComFuncs.OpenInExamineDlg(dupes)
	--~	 end
	--~ end

	--~ function ChoGGi.MenuFuncs.DeathToObjects(cls)
	--~ use MapDelete above
	--~ 	end

	--~ ChoGGi.MenuFuncs.DeathToObjects("BaseRover")
	--~ ChoGGi.MenuFuncs.DeathToObjects("Colonist")
	--~ ChoGGi.MenuFuncs.DeathToObjects("CargoShuttle")
	--~ ChoGGi.MenuFuncs.DeathToObjects("Building")
	--~ ChoGGi.MenuFuncs.DeathToObjects("Drone")
	--~ ChoGGi.MenuFuncs.DeathToObjects("SupplyRocket")
	--~ ChoGGi.MenuFuncs.DeathToObjects("Unit") --rovers/drones/colonists

	--~ --show all elec consumption
	--~ local amount = 0
	--~ MapForEach("map",nil,function(o)
	--~ 	if o.class and o.electricity and o.electricity.consumption then
	--~ 		local temp = o.electricity.consumption / 1000
	--~ 		amount = amount + temp
	--~ 		print(o.class,": ",temp)
	--~ 	end
	--~ end)
	--~ print(amount)

end
