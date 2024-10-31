-- Copyright (©) 2024 Metatable Games
-- Written by vq9o
-- License: The Unlicense
-- GitHub: https://github.com/RAMPAGELLC/Locksmith

local PLUGIN_LATEST = "3.0.7"
local PLUGIN_NAME = "Locksmith"
local PLUGIN_BUTTON_ID = "LOCKSMITHBYMETA"
local PLUGIN_ICON = "rbxassetid://5051086561"
local PLUGIN_SUMMARY = "Locksmith; Roblox virus threat removal & protection by Meta Games."

local IS_LOCAL = (plugin.Name:find(".rbxm") ~= nil)

-- Init
local function getId(str)
	if IS_LOCAL then
		str ..= " (LOCAL)"
	end

	return str
end

local button = nil
local pluginName = getId(PLUGIN_NAME)
local widgetName = getId(script.Name)

if not _G.MetaToolbar then
	_G.MetaToolbar = plugin:CreateToolbar("Plugins by Meta")
end

local buttonId = getId(PLUGIN_BUTTON_ID)
button = _G[buttonId]

if not button then
	button = _G.MetaToolbar:CreateButton(pluginName, PLUGIN_SUMMARY, PLUGIN_ICON)
	_G[buttonId] = button
end

-- Services
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CollectionService = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local TweenService = game:GetService("TweenService")

-- Script
local StartScan = nil
local Temp = script:WaitForChild("LocksmithCore")
local Modules = script:WaitForChild("Modules")
local UI = script:WaitForChild("UI")
local Gui = Temp:Clone()

Temp.Enabled = false

if game.CoreGui:FindFirstChild("LocksmithCore") then
	game.CoreGui:FindFirstChild("LocksmithCore"):Destroy()
end

Gui.Parent = game.CoreGui

button.Click:Connect(function()
	Gui.Enabled = not Gui.Enabled
end)

Gui.Enabled = false

-- Modules
local Maid = require(Modules.Maid)
local MaterialPlus = require(Modules.MaterialPlus)
local Dragify = require(Modules.Dragify)
local Loadify = require(Modules.Loadify)
local ScanList = require(Modules.ScanList)
local LocksmithRecentVersion = require(16182662066) -- Legacy 8631703711

local quickFixes = require(Modules.QuickFixes)

-- Variables
local UIInstances = MaterialPlus.Instances 

-- Settings
local Settings = {
	{
		Name = "Use Change History",
		Enabled = false,
	};
	{
		Name = "Ignore CoreGui",
		Enabled = false,
	};
	{
		Name = "Print Raw Report",
		Enabled = false,
	};
	{
		Name = "Flag 'require'",
		Enabled = false,
	};
	{
		Name = "Flag 'getfenv'",
		Enabled = false,
	};
	{
		Name = "Ignore Roblox Classes/Services",
		Enabled = false,
	};
	{
		Name = "Ignore PluginGuiService",
		Enabled = false,
	};{
		Name = "Print Progress",
		Enabled = false,
	};
}

local ChangeLog = {
	{
		Title = "3.0.7 Update",
		Author = "Meta Games",
		Date = "10/30/2024",
		Description = [[
! Plugin re-orgnization under Meta Games
! Plugin now appears as 'Plugins by Meta'
! Plugin memory leaks fixed
! Updated for latest known 2024 backdoors/viruses
+ Quick-fix/Quick-removal options to quickly automatically remove detected viruses sections of a script such as the RoSync virus.
		]]
	},
	{
		Title = "3.0.6 Update",
		Author = "vq9o",
		Date = "1/30/2024",
		Description = [[
! Back during active scan now cancels the previous
! Tooltips should maybe work now.
		]]
	},
	{
		Title = "3.0.5 Update",
		Author = "vq9o",
		Date = "1/30/2024",
		Description = [[
! UX Improvement
! Experience Log Clear Button
! UI Tooltips
! UI Button re-names
! Optimization fixes
		]]
	},
	{
		Title = "3.0.4 Update",
		Author = "vq9o",
		Date = "5/25/2022",
		Description = [[
+ You can now whitelist an instance to be ignored in scans by using CollectionService and tagging it with **LOCKSMITH_IGNORE_INSTANCE**
! View flag is now hidden when the scan is re-started.
! Drop shadow for view flag fixed.
! Scan progress text scaled up.
! MouseButton1Click connections fixed
+ Log feed of progress added.
+ Locksmith will not scan itself (LOCKSMITH_IGNORE_INSTANCE)
+ You can now drag guis with right-click to prevent selecting instances.
		]]
	},
	{
		Title = "3.0.3 Update",
		Author = "vq9o",
		Date = "5/24/2022",
		Description = [[
		! Fixed scroll size to be automatic to handle more larger scans.
		]]
	},
	{
		Title = "3.0.2 Update",
		Author = "vq9o",
		Date = "4/15/2022",
		Description = [[
		! Flagged Code fixed for other flags
		! UI Size Issues resolved
		! Display Name fixed for Scans
		! Name detection for invalid characters fixed
		]]
	},
	{
		Title = "Locksmith Revamp",
		Author = "vq9o",
		Date = "1/24/2022",
		Description = [[
		Locksmith team is proud to announce brand new Locksmith!
		
		- UI Refreshment
		- Better Backdoor Hunting
		- Brand new Backdoor Panel
		- Alot of brand new features :)
		]]
	},
}

-- Setup
Dragify(Gui.Framework);

Gui.Framework.Scan.Log.Frame.Clear.Activated:Connect(function()
	for i,v in pairs(Gui.Framework.Scan.Log.Frame.LogFrame:GetChildren()) do
		if v:IsA("TextLabel") then v:Destroy() end
	end
end)

for i,v in pairs(Gui.Framework:GetChildren()) do if v:IsA("Frame") then v.Visible = false end end
for i,v in pairs(Gui.Framework.Settings.Buttons:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
for i,v in pairs(Gui.Framework.Changes.Buttons:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
for i,v in pairs(Settings) do
	local Frame = UI.Setting:Clone()
	Frame.Setting.Text = v.Name
	Frame.Parent = Gui.Framework.Settings.Buttons

	local Switch = MaterialPlus:Create(UIInstances.Switch, {
		Parent = Frame;

		AnchorPoint = Frame.Switch.AnchorPoint;

		Position = Frame.Switch.Position;

		Shadow = true;

		ZIndex = 9;

		Style = "Dark";
	})

	Switch:Enable()
	Switch.ValueChanged:Connect(function(NewValue)
		Settings[i].Enabled = NewValue
	end)
end

for i,v in pairs(ChangeLog) do
	local Frame = UI.ViewArticle:Clone()
	Frame.Setting.Text = v.Title
	Frame.Parent = Gui.Framework.Changes.Buttons
	Frame.View.Activated:Connect(function()
		Gui.Framework.Changes.Framework.Visible = true
		Gui.Framework.Changes.Framework.Changes.Title.Text = v.Title
		Gui.Framework.Changes.Framework.Changes.Author.Text = "Written by "..v.Author..", "..v.Date
		Gui.Framework.Changes.Framework.Changes.Buttons.Author.Text = v.Description
	end)
end

function Tooltip(Child)
	local Open = Child.Tooltip.Size
	Child.Tooltip.Size = UDim2.new(0,0,0,0)
	Child.Tooltip.UIStroke.Enabled = false
	Child.MouseEnter:Connect(function()
		Child.Tooltip.UIStroke.Enabled = true
		TweenService:Create(Child.Tooltip, TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = Open
		}):Play()
	end)
	Child.MouseLeave:Connect(function()
		Child.Tooltip.UIStroke.Enabled = false
		TweenService:Create(Child.Tooltip, TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = UDim2.new(0,0,0,0)
		}):Play()
	end)
end

Tooltip(Gui.Framework.Scan.Framework.Changes.Select)
Tooltip(Gui.Framework.Scan.Framework.Changes.Save)
Tooltip(Gui.Framework.Scan.Framework.Changes.Delete)
Tooltip(Gui.Framework.Scan.Framework.Changes.View)
Tooltip(Gui.Framework.Scan.Framework.Changes.QuickFix)

for i,v in pairs(quickFixes) do
	local GuiContainer = Gui.Framework.Home.Buttons.QuickRemove
	local QuickFix = GuiContainer.Option:Clone()
	QuickFix.Text = i
	QuickFix.Visible = true
	QuickFix.Parent = GuiContainer.Options
	
	QuickFix.MouseButton1Click:Connect(function()
		quickFixes[i][2](quickFixes[i][1], nil)
	end)
end

Gui.Framework.Home.Buttons.QuickRemove.MouseButton1Click:Connect(function()
	Gui.Framework.Home.Buttons.QuickRemove.Options.Visible = not Gui.Framework.Home.Buttons.QuickRemove.Options.Visible
end)

Gui.Framework.Changes.Framework.Changes.Back.MouseButton1Click:Connect(function()
	Gui.Framework.Changes.Framework.Visible = false
end)

Gui.Framework.Home.Buttons.Settings.MouseButton1Click:Connect(function()
	Gui.Framework.Home.Visible = false
	Gui.Framework.Settings.Visible = true
end)

Gui.Framework.Settings.Back.MouseButton1Click:Connect(function()
	Gui.Framework.Home.Visible = true
	Gui.Framework.Settings.Visible = false
end)

Gui.Framework.Home.Buttons.Changes.MouseButton1Click:Connect(function()
	Gui.Framework.Home.Visible = false
	Gui.Framework.Changes.Visible = true
end)

Gui.Framework.Changes.Back.MouseButton1Click:Connect(function()
	Gui.Framework.Home.Visible = true
	Gui.Framework.Changes.Visible = false
end)

Gui.Framework.Home.Buttons.Scan.MouseButton1Click:Connect(function()
	Gui.Framework.Home.Visible = false
	Gui.Framework.Scan.Visible = true
	StartScan()
end)

Gui.Framework.Scan.Back.MouseButton1Click:Connect(function()
	Gui.Framework.Home.Visible = true
	Gui.Framework.Scan.Visible = false
end)

if LocksmithRecentVersion ~= PLUGIN_LATEST then
	Gui.Enabled = true
	Gui.Framework.Outdated.Visible = true
else
	Gui.Framework.Home.Visible = true
end

local function stringContainsOf2(str, tab)
	local found = {}

	for _,v in ipairs(tab) do
		if string.find(str, v) then
			table.insert(found, tostring(v))
		end
	end

	return #found > 0, found
end


local function stringContainsOf(str, tab)
	for _,v in ipairs(tab) do
		if string.find(str, v) then
			return true, tostring(v)
		end
	end

	return false, ""
end

local function getTime()
	local date = os.date("*t") 
	return ("%02d:%02d:%02d"):format(date.hour, date.min, date.sec)
end

local function Log(text, textcolor)
	local Log = UI.Log:Clone()
	Log.Parent = Gui.Framework.Scan.Log.Frame.LogFrame
	Log.Text = "["..getTime().."] "..text
	Log.TextColor3 = textcolor
	Gui.Framework.Scan.Log.Frame.LogFrame.CanvasPosition = Vector2.new(0,99999)
end

local function scanScript(scrpt)
	local Flags = {}
	local FlaggedCode = {}
	local Lines = string.split(scrpt.Source, "\n")
	local Flagged = false

	local IsCodeFlagged, CodeFlagged = stringContainsOf(scrpt.Source, ScanList)

	if IsCodeFlagged then
		Flagged = true;
		table.insert(Flags, "Code Contains Flagged Code marked as 'Unsafe'")
		table.insert(FlaggedCode, scrpt.Source)
	end

	local IsNameFlagged, NameFlagged = stringContainsOf(scrpt.Name, ScanList)

	if IsNameFlagged then
		Flagged = true;
		table.insert(Flags, "Name Flagged for malicious name '"..NameFlagged.."'")
		table.insert(FlaggedCode, scrpt.Source)
	end

	local IsRequireFlagged, RequireResult = stringContainsOf(scrpt.Source, {"require"})
	if Settings[4].Enabled and IsRequireFlagged then
		Flagged = true;
		table.insert(Flags, "Flagged for requiring a module, Flagged: '"..RequireResult.."'")
		table.insert(FlaggedCode, scrpt.Source)
	end

	local IsGetFlagged, GetResult = stringContainsOf(scrpt.Source, {"getfenv"})
	if Settings[5].Enabled and IsGetFlagged then
		Flagged = true;
		table.insert(Flags, "Flagged for getfenv, Flagged: '"..GetResult.."'")
		table.insert(FlaggedCode, scrpt.Source)
	end

	local AvaliableFixes = {}
	local IsQuickFixFlagged = false

	for i,v in pairs(quickFixes) do
		local localFlagged = scrpt.Source:match(v[1]) ~= nil;

		if localFlagged then
			IsQuickFixFlagged = true
			Flagged = true;

			table.insert(Flags, "Flagged for avaliable quick-fix removal, Flagged: '"..i.."'")
			table.insert(FlaggedCode, scrpt.Source)
			table.insert(AvaliableFixes, i)
		end
	end

	task.wait()

	return Flagged, {
		["IsQuickFixFlagged"] = IsQuickFixFlagged,
		["AvaliableFixes"] = AvaliableFixes,
		["Flags"] = Flags,
		["FlaggedCode"] = FlaggedCode,
		["Lines"] = Lines,
	}
end

StartScan = function()
	Gui.Framework.Scan.Amount.Text = "<b>Clearing cache</b>"
	for i,v in pairs(Gui.Framework.Scan.Buttons:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
	Gui.Framework.Scan.Buttons.Visible = false
	Gui.Framework.Scan.Loading.Visible = true
	Gui.Framework.Scan.Framework.Visible = false
	Loadify(Gui.Framework.Scan.Loading)

	local Report = {}
	local Scanned = 0;

	Gui.Framework.Scan.Amount.Text = "<b>Clearing log(s)</b>"
	for i,v in pairs(Gui.Framework.Scan.Log.Frame.LogFrame:GetChildren()) do
		if v:IsA("TextLabel") then v:Destroy() end
	end

	task.wait(.3)
	Log("Log has been cleared by server", Color3.fromRGB(236, 42, 42))
	Gui.Framework.Scan.Amount.Text = "<b>Preparing scan</b>"

	if Settings[8].Enabled then
		warn("LOCKSMITH: SCANNING")
	end

	Gui.Framework.Scan.Amount.Text = "<b>Scanning experience</b>"

	for i,v in ipairs(game:GetDescendants()) do
		local s,e = pcall(function()
			if v:IsA("BaseScript") or v:IsA("ModuleScript") or v:IsA("Script") then

				if Settings[2].Enabled then
					if v:IsDescendantOf(game:GetService("CoreGui")) then 
						if Settings[8].Enabled then
							Log("Locksmith Aborted "..v.Name.." for: IgnoreCoreGui", Color3.fromRGB(255, 255, 255))
							print("Locksmith Aborted "..v.Name.." for: IgnoreCoreGui")
						end
						return 
					end
				end

				if Settings[6].Enabled then
					if v:IsDescendantOf(game:GetService("RobloxPluginGuiService")) then 
						if Settings[8].Enabled then
							Log("Locksmith Aborted "..v.Name.." for: IgnoreRobloxPluginGuiService", Color3.fromRGB(255, 255, 255))
							print("Locksmith Aborted "..v.Name.." for: IgnoreRobloxPluginGuiService")
						end
						return 
					end
				end

				if Settings[7].Enabled then
					if v:IsDescendantOf(game:GetService("PluginGuiService")) then 
						if Settings[8].Enabled then
							Log("Locksmith Aborted "..v.Name.." for: IgnorePluginGuiService", Color3.fromRGB(255, 255, 255))
							print("Locksmith Aborted "..v.Name.." for: IgnorePluginGuiService")
						end
						return 
					end
				end

				if CollectionService:HasTag(v, "LOCKSMITH_IGNORE_INSTANCE") then
					if Settings[8].Enabled then
						Log("Locksmith Aborted "..v.Name.." for: LOCKSMITH_IGNORE_INSTANCE Tag", Color3.fromRGB(255, 255, 255))
						print("Locksmith Aborted "..v.Name.." for: LOCKSMITH_IGNORE_INSTANCE Tag")
					end

					return
				end


				if Settings[8].Enabled then
					Log("Locksmith Scanning "..v.Name, Color3.fromRGB(255, 255, 255))
					print("Locksmith Scanning "..v.Name)
				end

				Scanned += 1

				local IsBackDoor, Info = scanScript(v)

				if IsBackDoor then
					local Data = Info;
					local Name = v:GetFullName()

					if string.len(v.Name) < 1 then
						Name = Name .. "<locksmith_unkown>"
					end

					local DisplayName = v.Name

					if string.len(v.Name) < 1 then
						DisplayName = DisplayName .. "<locksmith_unkown>"
					end

					Data.Name = Name
					Data.DisplayName = DisplayName -- used for scan list.
					Data.Object = v
					table.insert(Report, Data)
				end
			end
		end)

		if not s then 
			Log("Locksmith failed to scan "..v.Name, Color3.fromRGB(255, 30, 30)) 
			warn("Locksmith failed to scan "..v.Name, e) 
		end
	end

	task.wait(1)

	if Settings[8].Enabled then
		Log("Scanning completed. Generating report", Color3.fromRGB(0, 170, 127))
		warn("LOCKSMITH: GENERATING REPORT")
	end

	Gui.Framework.Scan.Amount.Text = "<b>Generating Report</b>"

	local ReportMaid;

	for i,v in pairs(Report) do
		Report[i].Active = false
		local View = UI.ViewArticle:Clone()
		View.Parent = Gui.Framework.Scan.Buttons
		View.Setting.Text = v.DisplayName .. " #".. tostring(i)

		View.View.MouseButton1Click:Connect(function()
			if ReportMaid then
				ReportMaid:DoCleaning()
			end

			ReportMaid = Maid.new();

			local ReportFrame = Gui.Framework.Scan.Framework.Changes;
			local Summary = ""

			ReportFrame.Load.Visible = true
			Gui.Framework.Scan.Framework.Visible = true

			for i,v in pairs(ReportFrame.Code:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
			for i,v in pairs(ReportFrame.Flags:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end

			for i,v in pairs(v.Flags) do
				local Flag = UI.Flag:Clone()
				Flag.Parent = ReportFrame.Flags
				Flag.Text = v

				if Summary == "" then
					Summary = v
				else
					Summary = Summary..", "..v
				end
			end

			local CodeFlags = table.getn(v.FlaggedCode) or 0

			if Report[i].IsQuickFixFlagged then
				Summary = Summary..", <b>"..CodeFlags.."</b> code flags found. " .. tostring(#Report[i].AvaliableFixes) .. " avaliable quick-fixes. End of Generated Report!"
			else
				Summary = Summary..", <b>"..CodeFlags.."</b> code flags found. End of Generated Report!"
			end

			ReportFrame.QuickFix.Visible = Report[i].IsQuickFixFlagged
			ReportFrame.QuickFix.Options.Visible = false

			if Report[i].IsQuickFixFlagged then
				ReportMaid:GiveTask(ReportFrame.QuickFix.MouseButton1Click:Connect(function()
					ReportFrame.QuickFix.Options.Visible = not ReportFrame.QuickFix.Options.Visible
				end))
				
				for i,v in pairs(v.AvaliableFixes) do
					local QuickFix = ReportFrame.QuickFix.Option:Clone()
					QuickFix.Text = i
					QuickFix.Visible = true
					QuickFix.Parent = ReportFrame.QuickFix.Options
					
					ReportMaid:GiveTask(QuickFix)
					ReportMaid:GiveTask(QuickFix.MouseButton1Click:Connect(function()
						quickFixes[i][2](quickFixes[i][1], v.Object)
					end))
				end
			end

			for i,v in pairs(v.FlaggedCode) do
				local Flag = UI.FlaggedCode:Clone()
				Flag.Parent = ReportFrame.Code
				Flag.Text = v
			end

			ReportMaid:GiveTask(ReportFrame.Delete.MouseButton1Click:Connect(function()
				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_User_Delete")
				end

				Selection:Set({v.Object})
				v.Object:Destroy()
				Gui.Framework.Scan.Framework.Visible = false
				View:Destroy()
				Report[i].Active = false

				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_Complete_Action_Delete")
				end
			end))

			ReportMaid:GiveTask(ReportFrame.Select.MouseButton1Click:Connect(function()
				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_User_Select")
				end

				Selection:Set({v.Object})

				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_Complete_Action_Select")
				end
			end))

			ReportMaid:GiveTask(ReportFrame.Save.MouseButton1Click:Connect(function()
				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_User_Save")
				end

				Selection:Set({v.Object})
				plugin:PromptSaveSelection()

				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_Complete_Action_Save")
				end
			end))

			ReportMaid:GiveTask(ReportFrame.View.MouseButton1Click:Connect(function()
				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_User_View")
				end

				Selection:Set({v.Object})
				plugin:OpenScript(v.Object)

				if Settings[1].Enabled then
					ChangeHistoryService:SetWaypoint("Locksmith_Complete_Action_View")
				end
			end))

			ReportMaid:GiveTask(ReportFrame.Back.MouseButton1Click:Connect(function()
				Gui.Framework.Scan.Framework.Visible = false
				Report[i].Active = false
			end))

			ReportFrame.Title.Text = string.upper(v.Name).." FLAGS"
			ReportFrame.Summary.Text = Summary

			task.wait(.6)
			ReportFrame.Load.Visible = false

			ReportMaid:GiveTask(v.Object.Destroying:Connect(function()
				Gui.Framework.Scan.Framework.Visible = false
				Report[i].Active = false
				if View then View:Destroy() end
			end))

			--[[
			from 3.0.2 -- very bad usage of loops, and should use rbx signals.
			coroutine.wrap(function()
				while true do
					if v.Object == nil then
						Gui.Framework.Scan.Framework.Visible = false
						Report[i].Active = false
						if View then View:Destroy() end
					end

					task.wait(1)
				end
			end)()
			]]
		end)
	end

	task.wait(1)

	if Settings[3].Enabled then
		Log("Raw report printed in console.", Color3.fromRGB(0, 170, 127))
		warn("BEGIN LOCKSMITH RAW REPORT")
		print(Report)
		warn("END LOCKSMITH RAW REPORT")
	end

	local FlaggedTotal = table.getn(Report) or 0
	Gui.Framework.Scan.Amount.Text = "<b>"..Scanned.."</b> Scanned, <b>"..FlaggedTotal.."</b> Flagged"


	if Settings[8].Enabled then 
		Log("Report finished processing, locksmith is done.", Color3.fromRGB(0, 170, 127)) warn("Locksmith is done!") end

	local connection1 = nil
	local connection2 = nil

	connection1 = Gui.Framework.Scan.Rescan.MouseButton1Click:Connect(function()
		ChangeHistoryService:SetWaypoint("Locksmith_User_Action_Rescan")

		connection1:Disconnect()
		StartScan()

		if Settings[1].Enabled then
			ChangeHistoryService:SetWaypoint("Locksmith_Complete_Action_Rescan")
		end
	end)

	connection2 = Gui.Framework.Scan.Delete.MouseButton1Click:Connect(function()
		ChangeHistoryService:SetWaypoint("Locksmith_User_Delete_All")

		connection2:Disconnect()

		for i,v in pairs(Report) do
			if v.Object then
				v.Object:Destroy()
				Gui.Framework.Scan.Visible = false
				Gui.Framework.Home.Visible = true
			end
		end

		if Settings[1].Enabled then
			ChangeHistoryService:SetWaypoint("Locksmith_Complete_Action_Delete_All")
		end
	end)

	Gui.Framework.Scan.Loading.Visible = false
	Gui.Framework.Scan.Buttons.Visible = true
end