-- See LICENSE for terms

-- shows a dialog with to execute code in

local StringFormat = string.format

local S
local blacklist
local GetParentOfKind
local IsControlPressed
local IsShiftPressed

function OnMsg.ClassesGenerate()
	S = ChoGGi.Strings
	blacklist = ChoGGi.blacklist
	GetParentOfKind = ChoGGi.ComFuncs.GetParentOfKind
	IsControlPressed = ChoGGi.ComFuncs.IsControlPressed
	IsShiftPressed = ChoGGi.ComFuncs.IsShiftPressed
end

local function GetRootDialog(dlg)
	return GetParentOfKind(dlg,"ChoGGi_ExecCodeDlg")
end
DefineClass.ChoGGi_ExecCodeDlg = {
	__parents = {"ChoGGi_Window"},
	obj = false,
	obj_name = false,

	dialog_width = 750.0,
	dialog_height = 240.0,
	plugin_names = false,
	external_cmd = false,
	external_path = false,
}

local box10 = box(10,0,0,0)
function ChoGGi_ExecCodeDlg:Init(parent, context)
	local ChoGGi = ChoGGi
	local g_Classes = g_Classes
	local dlgConsole = dlgConsole

	if blacklist then
		self.plugin_names = {"ChoGGi_CodeEditorPlugin"}
	else
		self.plugin_names = {
			"ChoGGi_CodeEditorPlugin",
			"ChoGGi_ExternalTextEditorPlugin",
		}
	end

	self.obj = context.obj
	self.obj_name = self.obj and ChoGGi.ComFuncs.RetName(self.obj) or S[302535920001073--[[Console--]]]

	self.title = StringFormat("%s: %s",S[302535920000040--[[Exec Code--]]],self.obj_name)

	if not self.obj then
		self.dialog_width = 800.0
		self.dialog_height = 650.0
	end

	-- By the Power of Grayskull!
	self:AddElements(parent, context)

	self:AddScrollEdit()

	-- hinty hint
	self.idMoveControl.RolloverText = S[302535920000072--[["Paste or type code to be executed here, ChoGGi.CurObj is the examined object (ignored when opened from Console).
Press Ctrl-Enter or Shift-Enter to execute code."--]]]
	-- start off with this as code
	self.idEdit:SetText(GetFromClipboard() or self.obj and "ChoGGi.CurObj" or "")
	-- let us override enter/esc
	self.idEdit.OnKbdKeyDown = self.idEditOnKbdKeyDown
	-- update text on focus
	self.idEdit.OnSetFocus = self.idEditOnSetFocus

  self.idEdit:SetPlugins(self.plugin_names)
--~ 	self.idEdit.update_thread = self.idEdit:CreateThread("update_thread", self.idEdit.UpdateThread, self.idEdit)

	self.idButtonContainer = g_Classes.ChoGGi_DialogSection:new({
		Id = "idButtonContainer",
		Dock = "bottom",
		Margins = box(0,0,0,4),
	}, self.idDialog)

	do -- left buttons
		self.idLeftButs = g_Classes.ChoGGi_DialogSection:new({
			Id = "idLeftButs",
			Dock = "left",
			Margins = box(0,0,0,4),
		}, self.idButtonContainer)

		self.idOK = g_Classes.ChoGGi_Button:new({
			Id = "idOK",
			Dock = "left",
			Text = S[302535920000040--[[Exec Code--]]],
			RolloverText = S[302535920000073--[[Execute code in text box (Ctrl-Enter or Shift-Enter will also work).--]]],
			Margins = box10,
			OnPress = self.idOKOnPress,
		}, self.idLeftButs)

		if self.obj then
			self.idInsertObj = g_Classes.ChoGGi_Button:new({
				Id = "idInsertObj",
				Dock = "left",
				Text = S[302535920000075--[[Insert Obj--]]],
				RolloverText = S[302535920000076--[[At caret position inserts: ChoGGi.CurObj--]]],
				Margins = box10,
				OnPress = self.idInsertObjOnPress,
			}, self.idLeftButs)
		end

		if not blacklist then
			self.idEdit.external_cmd = ChoGGi.UserSettings.ExternalEditorCmd
			self.idEdit.external_path = ChoGGi.UserSettings.ExternalEditorPath

			self.idExterEdit = g_Classes.ChoGGi_Button:new({
				Id = "idExterEdit",
				Dock = "left",
				Text = S[302535920000471--[[External Editor--]]],
				RolloverText = S[302535920001434--[["Use an external editor (see settings for editor cmd).
	Updates external file when you type in editor (only updates text when you use Read File).
	Press again to toggle updating."--]]],
				Margins = box(20,0,0,0),
				OnPress = self.idExterEditOnPress,
			}, self.idLeftButs)

			self.idExterReadFile = g_Classes.ChoGGi_Button:new({
				Id = "idExterReadFile",
				Dock = "left",
				Text = S[302535920001435--[[Read File--]]],
				RolloverText = S[302535920001436--[[Update editor text with text from %stempedit.lua.--]]]:format(self.idEdit.external_path),
				Margins = box10,
				OnPress = self.idExterReadFileOnPress,
				FoldWhenHidden = true,
			}, self.idLeftButs)
			self.idExterReadFile:SetVisible(false)

			self.idExterFocusUpdate = g_Classes.ChoGGi_CheckButton:new({
				Id = "idExterFocusUpdate",
				Dock = "left",
				Text = S[302535920001438--[[Focus Update--]]],
				RolloverText = S[302535920001437--[[Reads file when you focus on the edit box (instead of pressing Read File).--]]],
				Margins = box10,
				OnChange = self.idExterFocusUpdateOnChange,
			}, self.idLeftButs)
			self.idExterFocusUpdate:SetVisible(false)
		end
	end -- left side

	do -- right side
	self.idRightButs = g_Classes.ChoGGi_DialogSection:new({
		Id = "idRightButs",
		Dock = "right",
	}, self.idButtonContainer)

	self.idWrapLines = g_Classes.ChoGGi_CheckButton:new({
		Id = "idWrapLines",
		Dock = "left",
		Text = S[302535920001288--[[Wrap Lines--]]],
		RolloverText = S[302535920001289--[[Wrap lines or show horizontal scrollbar.--]]],
		Margins = box10,
		Check = ChoGGi.UserSettings.WordWrap,
		OnChange = self.idWrapLinesOnChange,
	}, self.idRightButs)

	self.idCancel = g_Classes.ChoGGi_Button:new({
		Id = "idCancel",
		Dock = "right",
		Text = S[6879--[[Cancel--]]],
		RolloverText = S[302535920000074--[[Cancel without changing anything.--]]],
		Margins = box(0, 0, 10, 0),
		OnPress = self.idCloseX.OnPress,
	}, self.idRightButs)
	end -- right side

	self:SetInitPos(context.parent)
end

function ChoGGi_ExecCodeDlg:idEditOnSetFocus(...)
	if self.focus_update and self == g_ExternalTextEditorActiveCtrl then
		ChoGGi_ExternalTextEditorPlugin.ApplyEdit(nil, "Modified", self)
	end
	return ChoGGi_MultiLineEdit.OnSetFocus(self,...)
end

function ChoGGi_ExecCodeDlg:idExterFocusUpdateOnChange(which)
	GetRootDialog(self).idEdit.focus_update = which
end

function ChoGGi_ExecCodeDlg:idExterReadFileOnPress()
	ChoGGi_ExternalTextEditorPlugin.ApplyEdit(nil, "Modified", GetRootDialog(self).idEdit)
end

function ChoGGi_ExecCodeDlg:idExterEditOnPress()
	self = GetRootDialog(self)
	-- stop updating
	if self.idEdit == g_ExternalTextEditorActiveCtrl then
		g_ExternalTextEditorActiveCtrl = false
		self.idExterReadFile:SetVisible(false)
		self.idExterFocusUpdate:SetVisible(false)
		return
	end

	-- add updater
	local idx = table.find(self.idEdit.plugins,"class","ChoGGi_ExternalTextEditorPlugin")
	if idx then
		self.idExterReadFile:SetVisible(true)
		self.idExterFocusUpdate:SetVisible(true)
		self.idEdit.plugins[idx]:OpenEditor(self.idEdit)
	end
end

function ChoGGi_ExecCodeDlg:idOKOnPress()
	self = GetRootDialog(self)
	-- exec instead of also closing dialog
	ChoGGi.CurObj = self.obj
--~ 	ShowConsoleLog(true)
	-- use console to exec code so we can show results in it
	dlgConsole:Exec(self.idEdit:GetText())
end

function ChoGGi_ExecCodeDlg:idInsertObjOnPress()
	self = GetRootDialog(self)
	self.idEdit:EditOperation("ChoGGi.CurObj",true)
	self.idEdit:SetFocus()
end

function ChoGGi_ExecCodeDlg:idWrapLinesOnChange(which)
	ChoGGi.UserSettings.WordWrap = which
	GetRootDialog(self).idEdit:SetWordWrap(which)
end

local const = const
function ChoGGi_ExecCodeDlg:idEditOnKbdKeyDown(vk)
	self = GetRootDialog(self)
	if vk == const.vkEnter and (IsShiftPressed() or IsControlPressed()) then
		self.idOK:Press()
		return "break"
	elseif vk == const.vkEsc and self.obj then
		self.idCloseX:Press()
		return "break"
	end
	return ChoGGi_TextInput.OnKbdKeyDown(self.idEdit, vk)
end

function ChoGGi_ExecCodeDlg:Done(result,...)
	-- kill off external editor stuff?
	if self.idEdit == g_ExternalTextEditorActiveCtrl then
		g_ExternalTextEditorActiveCtrl = false
	end
	ChoGGi_Window.Done(self,result,...)
end
