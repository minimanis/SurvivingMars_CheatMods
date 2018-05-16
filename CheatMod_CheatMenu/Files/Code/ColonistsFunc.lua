local cCodeFuncs = ChoGGi.CodeFuncs
local cComFuncs = ChoGGi.ComFuncs
local cConsts = ChoGGi.Consts
local cInfoFuncs = ChoGGi.InfoFuncs
local cSettingFuncs = ChoGGi.SettingFuncs
local cTables = ChoGGi.Tables
local cMenuFuncs = ChoGGi.MenuFuncs

local UsualIcon = "UI/Icons/Notifications/colonist.tga"


function cMenuFuncs.UniversityGradRemoveIdiotTrait_Toggle()
  ChoGGi.UserSettings.UniversityGradRemoveIdiotTrait = not ChoGGi.UserSettings.UniversityGradRemoveIdiotTrait

  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(
    tostring(ChoGGi.UserSettings.UniversityGradRemoveIdiotTrait) .. "Water? Like out of the toilet?",
    "Idiots"
  )
end

DeathReasons.ChoGGi_Soylent = "Evil Overlord"
function cMenuFuncs.TheSoylentOption()
  --can't drop BlackCubes
  local list = {}
  local all = AllResourcesList
  for i = 1, #all do
    if all[i] ~= "BlackCube" then
      list[#list+1] = all[i]
    end
  end

  local function MeatbagsToSoylent(MeatBag,res)
    if MeatBag.dying then
      return
    end

    if res then
      res = list[UICity:Random(1,#list)]
    else
      res = "Food"
    end
    PlaceResourcePile(MeatBag:GetVisualPos(), res, UICity:Random(1,5) * cConsts.ResourceScale)
    --PlaceResourcePile(MeatBag:GetLogicalPos(), res, UICity:Random(1,5) * cConsts.ResourceScale)
    MeatBag:SetCommand("Die","ChoGGi_Soylent")
  end

  --one at a time
  local sel = cCodeFuncs.SelObject()
  if sel and sel.class == "Colonist"then
    MeatbagsToSoylent(sel)
    return
  end

  --culling the herd
  local ItemList = {
    {text = "Homeless",value = "Homeless"},
    {text = "Unemployed",value = "Unemployed"},
    {text = "Both",value = "Both"},
  }

  local CallBackFunc = function(choice)
    local value = choice[1].value
    local check1 = choice[1].check1
    local dome
    sel = SelectedObj
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check2 then
      dome = sel.dome.handle
    end

    local function Cull(Label)
      local tab = UICity.labels[Label] or empty_table
      for i = 1, #tab do
        if dome then
          if tab[i].dome and tab[i].dome.handle == dome then
            MeatbagsToSoylent(Obj,check1)
          end
        else
          MeatbagsToSoylent(Obj,check1)
        end
      end
    end

    if value == "Both" then
      Cull("Homeless")
      Cull("Unemployed")
    elseif value == "Homeless" or value == "Unemployed" then
      Cull(value)
    end
    cComFuncs.MsgPopup("Monster... " .. choice[1].text,
      "Snacks","UI/Icons/Sections/Food_1.tga"
    )
  end

  local Check1 = "Random resource"
  local Check1Hint = "Drops random resource instead of food."
  local Check2 = "Dome Only"
  local Check2Hint = "Will only apply to colonists in the same dome as selected colonist."
  local hint = "Convert useless meatbags into productive protein.\n\nCertain colonists may take some time (traveling in shuttles)."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"The Soylent Option",hint,nil,Check1,Check1Hint,Check2,Check2Hint)
end

function cMenuFuncs.AddApplicantsToPool()
  local ItemList = {
    {text = 1,value = 1},
    {text = 10,value = 10},
    {text = 25,value = 25},
    {text = 50,value = 50},
    {text = 75,value = 75},
    {text = 100,value = 100},
    {text = 250,value = 250},
    {text = 500,value = 500},
    {text = 1000,value = 1000},
    {text = 2500,value = 2500},
    {text = 5000,value = 5000},
    {text = 10000,value = 10000},
    {text = 25000,value = 25000},
    {text = 50000,value = 50000},
    {text = 100000,value = 100000},
  }

  local CallBackFunc = function(choice)
    local value = choice[1].value
    if type(value) == "number" then
      local now = GameTime()
      local self = SA_AddApplicants
      for _ = 1, value do
        local colonist = GenerateApplicant(now)
        local to_add = self.Trait
        if self.Trait == "random_positive" then
          to_add = GetRandomTrait(colonist.traits, {}, {}, "Positive", "base")
        elseif self.Trait == "random_negative" then
          to_add = GetRandomTrait(colonist.traits, {}, {}, "Negative", "base")
        elseif self.Trait == "random_rare" then
          to_add = GetRandomTrait(colonist.traits, {}, {}, "Rare", "base")
        elseif self.Trait == "random_common" then
          to_add = GetRandomTrait(colonist.traits, {}, {}, "Common", "base")
        elseif self.Trait == "random" then
          to_add = GenerateTraits(colonist, false, 1)
        else
          to_add = self.Trait
        end
        if type(to_add) == "table" then
          for trait in pairs(to_add) do
            colonist.traits[trait] = true
          end
        else
          colonist.traits[to_add] = true
        end
        if self.Specialization ~= "any" then
          colonist.traits[self.Specialization] = true
          colonist.specialist = self.Specialization
        end
      end
      cComFuncs.MsgPopup("Added applicants: " .. choice[1].text,
        "Applicants",UsualIcon
      )
    end
  end

  local hint = "Warning: Will take some time for 25K and up."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Add Applicants To Pool",hint)
end

function cMenuFuncs.FireAllColonists()
  local FireAllColonists = function()
    local tab = UICity.labels.Colonist or empty_table
    for i = 1, #tab do
      tab[i]:GetFired()
    end
  end
  cComFuncs.QuestionBox("Are you sure you want to fire everyone?",FireAllColonists,"Yer outta here!")
end

function cMenuFuncs.SetAllWorkShifts()
  local ItemList = {
    {text = "Turn On All Shifts",value = 0},
    {text = "Turn Off All Shifts",value = 3.1415926535},
  }

  local CallBackFunc = function(choice)
    local shift
    if choice[1].value == 3.1415926535 then
      shift = {true,true,true}
    else
      shift = {false,false,false}
    end

    local tab = UICity.labels.ShiftsBuilding or empty_table
    for i = 1, #tab do
      if tab[i].closed_shifts then
        tab[i].closed_shifts = shift
      end
    end

    cComFuncs.MsgPopup("Early night? Vamos al bar un trago!",
      "Shifts",UsualIcon
    )
  end
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set Shifts","Are you sure you want to change all shifts?")
end

function cMenuFuncs.SetMinComfortBirth()

  local r = cConsts.ResourceScale
  local DefaultSetting = cConsts.MinComfortBirth / r
  local hint_low = "Lower = more babies"
  local hint_high = "Higher = less babies"
  local ItemList = {
    {text = " Default: " .. DefaultSetting,value = DefaultSetting},
    {text = 0,value = 0,hint = hint_low},
    {text = 35,value = 35,hint = hint_low},
    {text = 140,value = 140,hint = hint_high},
    {text = 280,value = 280,hint = hint_high},
  }

  --other hint type
  local hint = DefaultSetting
  if ChoGGi.UserSettings.MinComfortBirth then
    hint = ChoGGi.UserSettings.MinComfortBirth / r
  end

  --callback
  local CallBackFunc = function(choice)

    local value = choice[1].value
    if type(value) == "number" then
      value = value * r
      cComFuncs.SetConstsG("MinComfortBirth",value)
      cComFuncs.SetSavedSetting("MinComfortBirth",Consts.MinComfortBirth)

      cSettingFuncs.WriteSettings()
      cComFuncs.MsgPopup("Selected: " .. choice[1].text .. "\nLook at them, bloody Catholics, filling the bloody world up with bloody people they can't afford to bloody feed.",
        "Colonists",UsualIcon,true
      )
    end
  end

  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"MinComfortBirth","Current: " .. hint)
end

function cMenuFuncs.VisitFailPenalty_Toggle()
  cComFuncs.SetConstsG("VisitFailPenalty",cComFuncs.NumRetBool(Consts.VisitFailPenalty,0,cConsts.VisitFailPenalty))

  cComFuncs.SetSavedSetting("VisitFailPenalty",Consts.VisitFailPenalty)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.VisitFailPenalty) .. "\nThe mill's closed. There's no more work. We're destitute. I'm afraid I have no choice but to sell you all for scientific experiments.",
    "Colonists",UsualIcon,true
  )
end

function cMenuFuncs.RenegadeCreation_Toggle()
  cComFuncs.SetConstsG("RenegadeCreation",cComFuncs.ValueRetOpp(Consts.RenegadeCreation,9999900,cConsts.RenegadeCreation))

  cComFuncs.SetSavedSetting("RenegadeCreation",Consts.RenegadeCreation)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.RenegadeCreation) .. ": I just love findin' subversives.",
    "Colonists",UsualIcon
  )
end
function cMenuFuncs.SetRenegadeStatus()
  local ItemList = {
    {text = "Make All Renegades",value = "Make"},
    {text = "Remove All Renegades",value = "Remove"},
  }

  local CallBackFunc = function(choice)
    local dome
    local sel = SelectedObj
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    local Type
    local value = choice[1].value
    if value == "Make" then
      Type = "AddTrait"
    elseif value == "Remove" then
      Type = "RemoveTrait"
    end

    local tab = UICity.labels.Colonist or empty_table
    for i = 1, #tab do
      if dome then
        if tab[i].dome and tab[i].dome.handle == dome then
          tab[i][Type](tab[i],"Renegade")
        end
      else
        tab[i][Type](tab[i],"Renegade")
      end
    end
    cComFuncs.MsgPopup("OK, a limosine that can fly. Now I have seen everything.\nReally? Have you seen a man eat his own head?\nNo.\nSo then, you haven't seen everything.",
      "Colonists",UsualIcon,true
    )
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Make Renegades",nil,nil,Check1,Check1Hint)
end

function cMenuFuncs.ColonistsMoraleAlwaysMax_Toggle()
  -- was -100
  cComFuncs.SetConstsG("HighStatLevel",cComFuncs.NumRetBool(Consts.HighStatLevel,0,cConsts.HighStatLevel))
  cComFuncs.SetConstsG("LowStatLevel",cComFuncs.NumRetBool(Consts.LowStatLevel,0,cConsts.LowStatLevel))
  cComFuncs.SetConstsG("HighStatMoraleEffect",cComFuncs.ValueRetOpp(Consts.HighStatMoraleEffect,999900,cConsts.HighStatMoraleEffect))
  cComFuncs.SetSavedSetting("HighStatMoraleEffect",Consts.HighStatMoraleEffect)
  cComFuncs.SetSavedSetting("HighStatLevel",Consts.HighStatLevel)
  cComFuncs.SetSavedSetting("LowStatLevel",Consts.LowStatLevel)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.HighStatMoraleEffect) .. ": Happy as a pig in shit",
    "Colonists",UsualIcon
  )
end

function cMenuFuncs.SeeDeadSanityDamage_Toggle()
  cComFuncs.SetConstsG("SeeDeadSanity",cComFuncs.NumRetBool(Consts.SeeDeadSanity,0,cConsts.SeeDeadSanity))
  cComFuncs.SetSavedSetting("SeeDeadSanity",Consts.SeeDeadSanity)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.SeeDeadSanity) .. ": I love me some corpses.",
    "Colonists",UsualIcon
  )
end

function cMenuFuncs.NoHomeComfortDamage_Toggle()
  cComFuncs.SetConstsG("NoHomeComfort",cComFuncs.NumRetBool(Consts.NoHomeComfort,0,cConsts.NoHomeComfort))
  cComFuncs.SetSavedSetting("NoHomeComfort",Consts.NoHomeComfort)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.NoHomeComfort) .. "\nOh, give me a home where the Buffalo roam\nWhere the Deer and the Antelope play;\nWhere seldom is heard a discouraging word,",
    "Colonists",UsualIcon,true
  )
end

function cMenuFuncs.ChanceOfSanityDamage_Toggle()
  cComFuncs.SetConstsG("DustStormSanityDamage",cComFuncs.NumRetBool(Consts.DustStormSanityDamage,0,cConsts.DustStormSanityDamage))
  cComFuncs.SetConstsG("MysteryDreamSanityDamage",cComFuncs.NumRetBool(Consts.MysteryDreamSanityDamage,0,cConsts.MysteryDreamSanityDamage))
  cComFuncs.SetConstsG("ColdWaveSanityDamage",cComFuncs.NumRetBool(Consts.ColdWaveSanityDamage,0,cConsts.ColdWaveSanityDamage))
  cComFuncs.SetConstsG("MeteorSanityDamage",cComFuncs.NumRetBool(Consts.MeteorSanityDamage,0,cConsts.MeteorSanityDamage))

  cComFuncs.SetSavedSetting("DustStormSanityDamage",Consts.DustStormSanityDamage)
  cComFuncs.SetSavedSetting("MysteryDreamSanityDamage",Consts.MysteryDreamSanityDamage)
  cComFuncs.SetSavedSetting("ColdWaveSanityDamage",Consts.ColdWaveSanityDamage)
  cComFuncs.SetSavedSetting("MeteorSanityDamage",Consts.MeteorSanityDamage)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.DustStormSanityDamage) .. ": Happy as a pig in shit",
    "Colonists",UsualIcon
  )
end

function cMenuFuncs.ChanceOfNegativeTrait_Toggle()
  cComFuncs.SetConstsG("LowSanityNegativeTraitChance",cComFuncs.NumRetBool(Consts.LowSanityNegativeTraitChance,0,cCodeFuncs.GetLowSanityNegativeTraitChance()))

  cComFuncs.SetSavedSetting("LowSanityNegativeTraitChance",Consts.LowSanityNegativeTraitChance)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.LowSanityNegativeTraitChance) .. ": Stupid and happy",
    "Colonists",UsualIcon
  )
end

function cMenuFuncs.ColonistsChanceOfSuicide_Toggle()
  cComFuncs.SetConstsG("LowSanitySuicideChance",cComFuncs.ToggleBoolNum(Consts.LowSanitySuicideChance))

  cComFuncs.SetSavedSetting("LowSanitySuicideChance",Consts.LowSanitySuicideChance)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.LowSanitySuicideChance) .. ": Getting away ain't that easy",
    "Colonists",UsualIcon
  )
end

function cMenuFuncs.ColonistsSuffocate_Toggle()
  cComFuncs.SetConstsG("OxygenMaxOutsideTime",cComFuncs.ValueRetOpp(Consts.OxygenMaxOutsideTime,99999900,cConsts.OxygenMaxOutsideTime))

  cComFuncs.SetSavedSetting("OxygenMaxOutsideTime",Consts.OxygenMaxOutsideTime)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.OxygenMaxOutsideTime) .. ": Free Air",
    "Colonists",UsualIcon
  )
end

function cMenuFuncs.ColonistsStarve_Toggle()
  cComFuncs.SetConstsG("TimeBeforeStarving",cComFuncs.ValueRetOpp(Consts.TimeBeforeStarving,99999900,cConsts.TimeBeforeStarving))

  cComFuncs.SetSavedSetting("TimeBeforeStarving",Consts.TimeBeforeStarving)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.TimeBeforeStarving) .. ": Free Food",
    "Colonists","UI/Icons/Sections/Food_2.tga"
  )
end

function cMenuFuncs.AvoidWorkplace_Toggle()
  cComFuncs.SetConstsG("AvoidWorkplaceSols",cComFuncs.NumRetBool(Consts.AvoidWorkplaceSols,0,cConsts.AvoidWorkplaceSols))

  cComFuncs.SetSavedSetting("AvoidWorkplaceSols",Consts.AvoidWorkplaceSols)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.AvoidWorkplaceSols) .. ": No Shame",
    "Colonists",UsualIcon
  )
end

function cMenuFuncs.PositivePlayground_Toggle()
  cComFuncs.SetConstsG("positive_playground_chance",cComFuncs.ValueRetOpp(Consts.positive_playground_chance,101,cConsts.positive_playground_chance))

  cComFuncs.SetSavedSetting("positive_playground_chance",Consts.positive_playground_chance)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.positive_playground_chance) .. "\nWe've all seen them, on the playground, at the store, walking on the streets.",
    "Traits","UI/Icons/Upgrades/home_collective_02.tga",true
  )
end

function cMenuFuncs.ProjectMorpheusPositiveTrait_Toggle()
  cComFuncs.SetConstsG("ProjectMorphiousPositiveTraitChance",cComFuncs.ValueRetOpp(Consts.ProjectMorphiousPositiveTraitChance,100,cConsts.ProjectMorphiousPositiveTraitChance))

  cComFuncs.SetSavedSetting("ProjectMorphiousPositiveTraitChance",Consts.ProjectMorphiousPositiveTraitChance)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.ProjectMorphiousPositiveTraitChance) .. "\nSay, \"Small umbrella, small umbrella.\"",
    "Colonists","UI/Icons/Upgrades/rejuvenation_treatment_04.tga",true
  )
end

function cMenuFuncs.PerformancePenaltyNonSpecialist_Toggle()
  cComFuncs.SetConstsG("NonSpecialistPerformancePenalty",cComFuncs.NumRetBool(Consts.NonSpecialistPerformancePenalty,0,cCodeFuncs.GetNonSpecialistPerformancePenalty()))

  cComFuncs.SetSavedSetting("NonSpecialistPerformancePenalty",Consts.NonSpecialistPerformancePenalty)
  cSettingFuncs.WriteSettings()
  cComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.NonSpecialistPerformancePenalty) .. "\nYou never know what you're gonna get.",
    "Penalty",UsualIcon,true
  )
end

function cMenuFuncs.SetOutsideWorkplaceRadius()
  local DefaultSetting = cConsts.DefaultOutsideWorkplacesRadius
  local ItemList = {
    {text = " Default: " .. DefaultSetting,value = DefaultSetting},
    {text = 15,value = 15},
    {text = 20,value = 20},
    {text = 25,value = 25},
    {text = 50,value = 50},
    {text = 75,value = 75},
    {text = 100,value = 100},
    {text = 250,value = 250},
  }

  local hint = DefaultSetting
  if ChoGGi.UserSettings.DefaultOutsideWorkplacesRadius then
    hint = ChoGGi.UserSettings.DefaultOutsideWorkplacesRadius
  end

  local CallBackFunc = function(choice)
    local value = choice[1].value
    if type(value) == "number" then
      cComFuncs.SetConstsG("DefaultOutsideWorkplacesRadius",value)
      cComFuncs.SetSavedSetting("DefaultOutsideWorkplacesRadius",value)
      cSettingFuncs.WriteSettings()
        cComFuncs.MsgPopup(choice[1].text .. ": There's a voice that keeps on calling me\nDown the road is where I'll always be\nMaybe tomorrow, I'll find what I call home\nUntil tomorrow, you know I'm free to roam",
          "Colonists","UI/Icons/Sections/dome.tga",true
        )
    end
  end

  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set Outside Workplace Radius","Current distance: " .. hint .. "\n\nYou may not want to make it too far away unless you turned off suffocation.")
end

function cMenuFuncs.SetDeathAge()
  local function RetDeathAge(colonist)
    return colonist.MinAge_Senior + 5 + colonist:Random(10) + colonist:Random(5) + colonist:Random(5)
  end

  local ItemList = {
    {text = " Default",value = "Default",hint = "Uses same code as game to pick death ages."},
    {text = 60,value = 60},
    {text = 75,value = 75},
    {text = 100,value = 100},
    {text = 250,value = 250},
    {text = 500,value = 500},
    {text = 1000,value = 1000},
    {text = 10000,value = 10000},
    {text = "Logan's Run (Novel)",value = "LoganNovel"},
    {text = "Logan's Run (Movie)",value = "LoganMovie"},
    {text = "TNG: Half a Life",value = "TNG"},
    {text = "The Happy Place",value = "TheHappyPlace"},
    {text = "In Time",value = "InTime"},
  }

  local CallBackFunc = function(choice)
    local value = choice[1].value
    local amount
    if type(value) == "number" then
      amount = value
    elseif value == "LoganNovel" then
      amount = 21
    elseif value == "LoganMovie" then
      amount = 30
    elseif value == "TNG" then
      amount = 60
    elseif value == "TheHappyPlace" then
      amount = 60
    elseif value == "InTime" then
      amount = 26
    end

    if value == "Default" or type(amount) == "number" then
      if value == "Default" then
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          tab[i].death_age = RetDeathAge(tab[i])
        end
      elseif type(amount) == "number" then
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          tab[i].death_age = amount
        end
      end

      cComFuncs.MsgPopup("Death age: " .. choice[1].text,
        "Colonists","UI/Icons/Sections/attention.tga"
      )
    end
  end

  local hint = "Usual age is around " .. RetDeathAge(UICity.labels.Colonist[1]) .. ". This doesn't stop colonists from becoming seniors; just death (research ForeverYoung for enternal labour)."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set Death Age",hint)
end

function cMenuFuncs.ColonistsAddSpecializationToAll()
  local tab = UICity.labels.Colonist or empty_table
  for i = 1, #tab do
    if tab[i].specialist == "none" then
      cCodeFuncs.ColonistUpdateSpecialization(tab[i],"Random")
    end
  end

  cComFuncs.MsgPopup("No lazy good fer nuthins round here",
    "Colonists","UI/Icons/Upgrades/home_collective_04.tga"
  )
end

local function IsChild(value)
  if value == "Child" then
    return "Warning: Child will remove specialization."
  end
end
function cMenuFuncs.SetColonistsAge(iType)
  local DefaultSetting = " Default"
  local sType = ""
  local sSetting = "NewColonistAge"

  if iType == 1 then
    sType = "New C"
  elseif iType == 2 then
    sType = "C"
    DefaultSetting = " Random"
    sSetting = nil
  end

  local ItemList = {}
  ItemList[#ItemList+1] = {
    text = DefaultSetting,
    value = DefaultSetting,
  }
  for i = 1, #cTables.ColonistAges do
  ItemList[#ItemList+1] = {
      text = cTables.ColonistAges[i],
      value = cTables.ColonistAges[i],
      hint = IsChild(cTables.ColonistAges[i]),
    }
  end

  local hint = ""
  if iType == 1 then
    hint = DefaultSetting
    if ChoGGi.UserSettings[sSetting] then
      hint = ChoGGi.UserSettings[sSetting]
    end
    hint = "Current: " .. hint .. "\n\nWarning: Child will remove specialization."
  end

  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    local value = choice[1].value
    --new
    if iType == 1 then
      cComFuncs.SetSavedSetting("NewColonistAge",value)
      cSettingFuncs.WriteSettings()

    --existing
    elseif iType == 2 then
      if choice[1].check2 then
        if sel then
          cCodeFuncs.ColonistUpdateAge(sel,value)
        end
      else
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          if dome then
            if tab[i].dome and tab[i].dome.handle == dome then
              cCodeFuncs.ColonistUpdateAge(tab[i],value)
            end
          else
            cCodeFuncs.ColonistUpdateAge(tab[i],value)
          end
        end
      end

    end

    cComFuncs.MsgPopup(sType .. "olonists: " .. choice[1].text,
      "Colonists",UsualIcon
    )
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local Check2 = "Selected Only"
  local Check2Hint = "Will only apply to selected colonist."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. sType .. "olonist Age",hint,nil,Check1,Check1Hint,Check2,Check2Hint)
end

function cMenuFuncs.SetColonistsGender(iType)
  local DefaultSetting = " Default"
  local sType = ""
  local sSetting = "NewColonistGender"
  if iType == 1 then
    sType = "New C"
  elseif iType == 2 then
    sType = "C"
    DefaultSetting = " Random"
    sSetting = nil
  end

  local ItemList = {}
  ItemList[#ItemList+1] = {
    text = DefaultSetting,
    value = DefaultSetting,
    hint = "How the game normally works",
  }
  ItemList[#ItemList+1] = {
    text = " MaleOrFemale",
    value = "MaleOrFemale",
    hint = "Only set as male or female",
  }
  for i = 1, #cTables.ColonistGenders do
    ItemList[#ItemList+1] = {
      text = cTables.ColonistGenders[i],
      value = cTables.ColonistGenders[i],
    }
  end

  local hint
  if iType == 1 then
    hint = DefaultSetting
    if ChoGGi.UserSettings[sSetting] then
      hint = ChoGGi.UserSettings[sSetting]
    end
    hint = "Current: " .. hint
  end

  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    --new
    local value = choice[1].value
    if iType == 1 then
      cComFuncs.SetSavedSetting("NewColonistGender",value)
      cSettingFuncs.WriteSettings()
    --existing
    elseif iType == 2 then
      if choice[1].check2 then
        if sel then
          cCodeFuncs.ColonistUpdateGender(sel,value)
        end
      else
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          if dome then
            if tab[i].dome and tab[i].dome.handle == dome then
              cCodeFuncs.ColonistUpdateGender(tab[i],value)
            end
          else
            cCodeFuncs.ColonistUpdateGender(tab[i],value)
          end
        end
      end

    end
    cComFuncs.MsgPopup(sType .. "olonists: " .. choice[1].text,
      "Colonists",UsualIcon
    )
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local Check2 = "Selected Only"
  local Check2Hint = "Will only apply to selected colonist."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. sType .. "olonist Gender",hint,nil,Check1,Check1Hint,Check2,Check2Hint)
end

function cMenuFuncs.SetColonistsSpecialization(iType)
  local DefaultSetting = " Default"
  local sType = ""
  local sSetting = "NewColonistSpecialization"
  if iType == 1 then
    sType = "New C"
  elseif iType == 2 then
    sType = "C"
    DefaultSetting = " Random"
    sSetting = nil
  end

  local ItemList = {}
  ItemList[#ItemList+1] = {
    text = DefaultSetting,
    value = DefaultSetting,
    hint = "How the game normally works",
  }
  if iType == 1 then
    ItemList[#ItemList+1] = {
      text = "Random",
      value = "Random",
      hint = "Everyone gets a spec",
    }
  end
  ItemList[#ItemList+1] = {
    text = "none",
    value = "none",
    hint = "Removes specializations",
  }
  for i = 1, #cTables.ColonistSpecializations do
    ItemList[#ItemList+1] = {
      text = cTables.ColonistSpecializations[i],
      value = cTables.ColonistSpecializations[i],
    }
  end

  local hint
  if iType == 1 then
    hint = DefaultSetting
    if ChoGGi.UserSettings[sSetting] then
      hint = ChoGGi.UserSettings[sSetting]
    end
    hint = "Current: " .. hint
  end

  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    --new
    local value = choice[1].value
    if iType == 1 then
      cComFuncs.SetSavedSetting("NewColonistSpecialization",value)
      cSettingFuncs.WriteSettings()
    --existing
    elseif iType == 2 then
      if choice[1].check2 then
        if sel then
          cCodeFuncs.ColonistUpdateSpecialization(sel,value)
        end
      else
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          if dome then
            if tab[i].dome and tab[i].dome.handle == dome then
              cCodeFuncs.ColonistUpdateSpecialization(tab[i],value)
            end
          else
            cCodeFuncs.ColonistUpdateSpecialization(tab[i],value)
          end
        end
      end

    end
    cComFuncs.MsgPopup(sType .. "olonists: " .. choice[1].text,
      "Colonists",UsualIcon
    )
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local Check2 = "Selected Only"
  local Check2Hint = "Will only apply to selected colonist."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. sType .. "olonist Specialization",hint,nil,Check1,Check1Hint,Check2,Check2Hint)
end

function cMenuFuncs.SetColonistsRace(iType)
  local DefaultSetting = " Default"
  local sType = ""
  local sSetting = "NewColonistRace"
  if iType == 1 then
    sType = "New C"
  elseif iType == 2 then
    sType = "C"
    DefaultSetting = " Random"
    sSetting = nil
  end

  local ItemList = {}
  ItemList[#ItemList+1] = {
    text = DefaultSetting,
    value = DefaultSetting,
    race = DefaultSetting,
  }
  local race = {"Herrenvolk","Schwarzvolk","Asiatischvolk","Indischvolk","S�dost Asiatischvolk"}
  for i = 1, #cTables.ColonistRaces do
    ItemList[#ItemList+1] = {
      text = cTables.ColonistRaces[i],
      value = i,
      race = race[i],
    }
  end

  local hint
  if iType == 1 then
    hint = DefaultSetting
    if ChoGGi.UserSettings[sSetting] then
      hint = ChoGGi.UserSettings[sSetting]
    end
    hint = "Current: " .. hint
  end

  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    --new
    local value = choice[1].value
    if iType == 1 then
      cComFuncs.SetSavedSetting("NewColonistRace",value)
      cSettingFuncs.WriteSettings()
    --existing
    elseif iType == 2 then
      if choice[1].check2 then
        if sel then
          cCodeFuncs.ColonistUpdateRace(sel,value)
        end
      else
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          if dome then
            if tab[i].dome and tab[i].dome.handle == dome then
              cCodeFuncs.ColonistUpdateRace(tab[i],value)
            end
          else
            cCodeFuncs.ColonistUpdateRace(tab[i],value)
          end
        end
      end

    end
    cComFuncs.MsgPopup("Nationalsozialistische Rassenhygiene: " .. choice[1].race,
      "Colonists",UsualIcon
    )
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local Check2 = "Selected Only"
  local Check2Hint = "Will only apply to selected colonist."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. sType .. "olonist Race",hint,nil,Check1,Check1Hint,Check2,Check2Hint)
end

function cMenuFuncs.SetColonistsTraits(iType)
  local DefaultSetting = " Default"
  local sSetting = "NewColonistTraits"
  local sType = "New C"

  local hint = ""
  if iType == 1 then
    hint = DefaultSetting
    local saved = ChoGGi.UserSettings[sSetting]
    if saved then
      hint = ""
      for i = 1, #saved do
        hint = hint .. saved[i] .. ","
      end
    end
    hint = "Current: " .. hint
  elseif iType == 2 then
    sType = "C"
    DefaultSetting = " Random"
  end
  hint = hint .. "\n\nDefaults to adding traits, check Remove to remove. Use Shift or Ctrl to select multiple traits."

  local ItemList = {
      {text = " " .. DefaultSetting,value = DefaultSetting,hint = "Use game defaults"},
      {text = " All Positive Traits",value = "PositiveTraits",hint = "All the positive traits..."},
      {text = " All Negative Traits",value = "NegativeTraits",hint = "All the negative traits..."},
      {text = " All Traits",value = "AllTraits",hint = "All the traits..."},
    }

  if iType == 2 then
    ItemList[1].hint = "Random: Each colonist gets three positive and three negative traits (if it picks same traits then you won't get all six)."
  end

  for i = 1, #cTables.NegativeTraits do
    ItemList[#ItemList+1] = {
      text = cTables.NegativeTraits[i],
      value = cTables.NegativeTraits[i],
    }
  end
  for i = 1, #cTables.PositiveTraits do
    ItemList[#ItemList+1] = {
      text = cTables.PositiveTraits[i],
      value = cTables.PositiveTraits[i],
    }
  end
  --add hint descriptions
  for i = 1, #ItemList do
    local hinttemp = DataInstances.Trait[ItemList[i].text]
    if hinttemp then
      ItemList[i].hint = ": " .. _InternalTranslate(hinttemp.description)
    end
  end

  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    --create list of traits
    local TraitsListTemp = {}
    local function AddToTable(List,Table)
      for x = 1, #List do
        Table[#Table+1] = List[x]
      end
      return Table
    end
    for i = 1, #choice do
      if choice[i].value == "NegativeTraits" then
        TraitsListTemp = AddToTable(cTables.NegativeTraits,TraitsListTemp)
      elseif choice[i].value == "PositiveTraits" then
        TraitsListTemp = AddToTable(cTables.PositiveTraits,TraitsListTemp)
      elseif choice[i].value == "AllTraits" then
        TraitsListTemp = AddToTable(cTables.PositiveTraits,TraitsListTemp)
        TraitsListTemp = AddToTable(cTables.NegativeTraits,TraitsListTemp)
        ex(TraitsListTemp)
      else
        if choice[i].value then
          TraitsListTemp = AddToTable(choice[i].value,TraitsListTemp)
        end
      end
    end
    --remove dupes
    table.sort(TraitsListTemp)
    local TraitsList = {}
    for i = 1, #TraitsListTemp do
      if TraitsListTemp[i] ~= TraitsListTemp[i-1] then
        TraitsList[#TraitsList+1] = TraitsListTemp[i]
      end
    end

    --new
    if iType == 1 then
      if choice[1].value == DefaultSetting then
        ChoGGi.UserSettings.NewColonistTraits = false
      else
        ChoGGi.UserSettings.NewColonistTraits = TraitsList
      end
      cSettingFuncs.WriteSettings()

    --existing
    elseif iType == 2 then
      --random 3x3
      if choice[1].value == DefaultSetting then
        local function RandomTraits(Obj)
          --remove all traits
          cCodeFuncs.ColonistUpdateTraits(Obj,false,cTables.PositiveTraits)
          cCodeFuncs.ColonistUpdateTraits(Obj,false,cTables.NegativeTraits)
          --add random ones
          Obj:AddTrait(cTables.PositiveTraits[UICity:Random(1,#cTables.PositiveTraits)],true)
          Obj:AddTrait(cTables.PositiveTraits[UICity:Random(1,#cTables.PositiveTraits)],true)
          Obj:AddTrait(cTables.PositiveTraits[UICity:Random(1,#cTables.PositiveTraits)],true)
          Obj:AddTrait(cTables.NegativeTraits[UICity:Random(1,#cTables.NegativeTraits)],true)
          Obj:AddTrait(cTables.NegativeTraits[UICity:Random(1,#cTables.NegativeTraits)],true)
          Obj:AddTrait(cTables.NegativeTraits[UICity:Random(1,#cTables.NegativeTraits)],true)
          Notify(Obj,"UpdateMorale")
        end
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          if dome then
            if tab[i].dome and tab[i].dome.handle == dome then
              RandomTraits(tab[i])
            end
          else
            RandomTraits(tab[i])
          end
        end

      else
        local Type = "AddTrait"
        if choice[1].check2 then
          Type = "RemoveTrait"
        end
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          for j = 1, #TraitsList do
            if dome then
              if tab[i].dome and tab[i].dome.handle == dome then
                tab[i][Type](tab[i],TraitsList[j],true)
              end
            else
              tab[i][Type](tab[i],TraitsList[j],true)
            end
          end
        end

      end

    end
    cComFuncs.MsgPopup(sType .. "olonists traits set: " .. #TraitsList,
      "Colonists",UsualIcon
    )
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local Check2 = "Remove"
  local Check2Hint = "Check to remove traits"
  if iType == 1 then
    cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. sType .. "olonist Traits",hint,true)
  elseif iType == 2 then
    cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. sType .. "olonist Traits",hint,true,Check1,Check1Hint,Check2,Check2Hint)
  end
end

function cMenuFuncs.SetColonistsStats()
	local r = cConsts.ResourceScale
  local ItemList = {
    {text = "All Stats Max",value = 1},
    {text = "All Stats Fill",value = 2},
    {text = "Health Max",value = 3},
    {text = "Health Fill",value = 4},

    {text = "Morale Fill",value = 5},

    {text = "Sanity Max",value = 6},
    {text = "Sanity Fill",value = 7},

    {text = "Comfort Max",value = 8},
    {text = "Comfort Fill",value = 9},
  }

  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    local max = 100000 * r
    local fill = 100 * r
    local value = choice[1].value
    local function SetStat(Stat,v)
      if v == 1 or v == 3 or v == 6 or v == 8 then
        v = max
      else
        v = fill
      end
      local tab = UICity.labels.Colonist or empty_table
      for i = 1, #tab do
        if dome then
          if tab[i].dome and tab[i].dome.handle == dome then
            tab[i][Stat] = v
          end
        else
          tab[i][Stat] = v
        end
      end
    end

    if value == 1 or value == 2 then
      if value == 1 then
        value = max
      elseif value == 2 then
        value = fill
      end

      local tab = UICity.labels.Colonist or empty_table
      for i = 1, #tab do
        if dome then
          if tab[i].dome and tab[i].dome.handle == dome then
            tab[i].stat_morale = value
            tab[i].stat_sanity = value
            tab[i].stat_comfort = value
            tab[i].stat_health = value
          end
        else
          tab[i].stat_morale = value
          tab[i].stat_sanity = value
          tab[i].stat_comfort = value
          tab[i].stat_health = value
        end
      end

    elseif value == 3 or value == 4 then
      SetStat("stat_health",value)
    elseif value == 5 then
      SetStat("stat_morale",value)
    elseif value == 6 or value == 7 then
      SetStat("stat_sanity",value)
    elseif value == 8 or value == 9 then
      SetStat("stat_comfort",value)
    end

    cComFuncs.MsgPopup(choice[1].text,"Colonists",UsualIcon)
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local hint = "Fill: Stat bar filled to 100\nMax: 100000 (choose fill to reset)\n\nWarning: Disable births or else..."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set Stats Of All Colonists",hint,nil,Check1,Check1Hint)
end

function cMenuFuncs.SetColonistMoveSpeed()
  local r = cConsts.ResourceScale
  local DefaultSetting = cConsts.SpeedColonist
  local ItemList = {
    {text = " Default: " .. DefaultSetting / r,value = DefaultSetting},
    {text = 5,value = 5 * r},
    {text = 10,value = 10 * r},
    {text = 15,value = 15 * r},
    {text = 25,value = 25 * r},
    {text = 50,value = 50 * r},
    {text = 100,value = 100 * r},
    {text = 1000,value = 1000 * r},
    {text = 10000,value = 10000 * r},
  }

  --other hint type
  local hint = DefaultSetting
  if ChoGGi.UserSettings.SpeedColonist then
    hint = ChoGGi.UserSettings.SpeedColonist
  end

  --callback
  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    local value = choice[1].value
    if type(value) == "number" then
      if choice[1].check2 then
        if sel then
          pf.SetStepLen(sel,value)
        end
      else
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          if dome then
            if tab[i].dome and tab[i].dome.handle == dome then
              --tab[i]:SetMoveSpeed(value)
              pf.SetStepLen(tab[i],value)
            end
          else
            --tab[i]:SetMoveSpeed(value)
            pf.SetStepLen(tab[i],value)
          end
        end
      end

      cComFuncs.SetSavedSetting("SpeedColonist",value)
      cSettingFuncs.WriteSettings()
      cComFuncs.MsgPopup("Selected: " .. choice[1].text,
        "Colonists",UsualIcon
      )
    end
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local Check2 = "Selected Only"
  local Check2Hint = "Will only apply to selected colonist."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Colonist Move Speed","Current: " .. hint,nil,Check1,Check1Hint,Check2,Check2Hint)
end

function cMenuFuncs.SetColonistsGravity()
  local DefaultSetting = cConsts.GravityColonist
  local r = cConsts.ResourceScale
  local ItemList = {
    {text = " Default: " .. DefaultSetting,value = DefaultSetting},
    {text = 1,value = 1},
    {text = 2,value = 2},
    {text = 3,value = 3},
    {text = 4,value = 4},
    {text = 5,value = 5},
    {text = 10,value = 10},
    {text = 15,value = 15},
    {text = 25,value = 25},
    {text = 50,value = 50},
    {text = 75,value = 75},
    {text = 100,value = 100},
    {text = 250,value = 250},
    {text = 500,value = 500},
  }

  local hint = DefaultSetting
  if ChoGGi.UserSettings.GravityColonist then
    hint = ChoGGi.UserSettings.GravityColonist / r
  end

  local CallBackFunc = function(choice)
    local sel = SelectedObj
    local dome
    if sel and sel.class == "Colonist" and sel.dome and choice[1].check1 then
      dome = sel.dome.handle
    end
    local value = choice[1].value
    if type(value) == "number" then
      value = value * r
      if choice[1].check2 then
        if sel then
          sel:SetGravity(value)
        end
      else
        local tab = UICity.labels.Colonist or empty_table
        for i = 1, #tab do
          if dome then
            if tab[i].dome and tab[i].dome.handle == dome then
              tab[i]:SetGravity(value)
            end
          else
            tab[i]:SetGravity(value)
          end
        end
      end

      cComFuncs.SetSavedSetting("GravityColonist",value)

      cSettingFuncs.WriteSettings()
      cComFuncs.MsgPopup("Colonist gravity is now: " .. choice[1].text,
        "Colonists",UsualIcon
      )
    end
  end

  local Check1 = "Dome Only"
  local Check1Hint = "Will only apply to colonists in the same dome as selected colonist."
  local Check2 = "Selected Only"
  local Check2Hint = "Will only apply to selected colonist."
  cCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set Colonist Gravity","Current gravity: " .. hint,nil,Check1,Check1Hint,Check2,Check2Hint)
end
