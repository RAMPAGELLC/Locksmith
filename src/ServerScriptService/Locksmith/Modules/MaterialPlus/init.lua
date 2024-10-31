--[[
	Tom_atoes / Fivefactor
	Material+
	
	Documentation: https://devforum.roblox.com/t/materialplus-ui-framework/330396
--]]

-- // Services


-- // UI Instances

local UIInstancesFolder = script.UIInstances

-- // Custom Globals

local print = require(script.Print)
local warn = require(script.Warn)

-- // Main

local MaterialPlus = {}

function MaterialPlus:Create(InstanceType, Properties)
	
	local InstanceModule = UIInstancesFolder:FindFirstChild(InstanceType)
	
	if not InstanceModule then
		error(InstanceType .. " is currently not a supported UI Instance.", 2)
		return nil
	end
	
	InstanceModule = require(InstanceModule)
	
	local Frame = Properties["Parent"]
	local Options = Properties["Options"]
	
	return InstanceModule.new(Properties, Frame, Options)
	
end

MaterialPlus.Instances = {
	TextBox = "TextBox";
	TextLabel = "TextLabel";
	TextButton = "TextButton";
	
	Frame = "Frame";
	ScrollingFrame = "ScrollingFrame";
	
	Switch = "Switch";
	DropMenu = "DropMenu";
	Slider = "Slider";
};

return MaterialPlus