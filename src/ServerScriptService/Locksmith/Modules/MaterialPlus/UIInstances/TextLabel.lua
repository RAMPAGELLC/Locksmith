local TweenService = game:GetService("TweenService")

local warn = require(script.Parent.Parent.Warn)

local GlobalUI = script.Parent.Parent.GlobalUI

local TextLabel = {}

function ZIndexInstance(UIInstance, ZIndex)
	
	if ZIndex == nil then
		return
	end
	
	UIInstance.ZIndex = ZIndex
	
	for i, v in pairs(UIInstance:GetChildren()) do
		wait()
		if v:IsA("GuiObject") then
			ZIndexInstance(v, (ZIndex + 1))
		end
	end
	
end

local function CreateLabel(Properties)
	
	local UIInstance
	
	if Properties["Style"] ~= nil then
		UIInstance = script[Properties["Style"]]:Clone()
	else
		UIInstance = script.Light:Clone()
	end
	
	if Properties["Parent"] == nil then
		UIInstance:Destroy()
		error("TextLabel instance requires a parent. Parent property was not defined.", 2)
		return
	end
	
	if type(Properties["Parent"]) == "table" then
		if Properties["Parent"]["Frame"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["Frame"]
		elseif Properties["Parent"]["UIInstance"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["UIInstance"]
		end
	end
	
	local InstanceProperties = {
		["ImageLabel"] = {
			Parent = "Parent";
			Position = "Position";
			AnchorPoint = "AnchorPoint";
			Size = "Size";
			
			BackgroundTransparency = "ImageTransparency";
			BackgroundColor3 = "ImageColor3";
			
			Visible = "Visible";
			
			Rotation = "Rotation";
			
			Name = "Name";
		};
		
		["TextLabel"] = {
			Text = "Text";
			TextColor3 = "TextColor3";
			TextTransparency = "TextTransparency";
			
			TextStrokeTransparency = "TextStrokeTransparency";
			TextStrokeColor3 = "TextStrokeColor3";
			
			Font = "Font";
			TextSize = "TextSize";
			
			TextWrapped = "TextWrapped";
			TextScaled = "TextScaled";
			
			TextYAlignment = "TextYAlignment";
			TextXAlignment = "TextXAlignment";
			
			LineHeight = "LineHeight";
			TextTruncate = "TextTruncate"
		}
	}
	
	for i, v in pairs(InstanceProperties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "TextLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance.TextLabel[PropertyToEffect] = Property
				end
			end
		end
	end

	-- // ZIndex
	
	ZIndexInstance(UIInstance, Properties["ZIndex"])
	
	-- // Global UI
	
	if Properties["Shadow"] ~= nil then
		local newShadow = GlobalUI.Shadow:Clone()
		newShadow.Parent = UIInstance
	end
	
	return {UIInstance, InstanceProperties}
	
end

function TextLabel.new(Properties)
	
	local self = {}
	
	local CreatedUI = CreateLabel(Properties)
	
	self.UIInstance = CreatedUI[1]
	self.Properties = CreatedUI[2]

	TextLabel.MouseEnter = self.UIInstance.MouseEnter
	TextLabel.MouseLeave = self.UIInstance.MouseLeave
	TextLabel.MouseMoved = self.UIInstance.MouseMoved
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				TextLabel[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		elseif i == "TextLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				TextLabel[PropertyName] = self.UIInstance.TextLabel[PropertyToEffect]
			end
		end
	end
	
	return setmetatable(self, {
		__index = TextLabel;
		__newindex = function(Table, Index, Value)
			
			if Index == "ZIndex" then
				ZIndexInstance(self.UIInstance, Value)
				return
			end
			
			if Index == "Parent" then
				if type(Value) == "table" then
					if Value["Frame"] ~= nil then
						Value = Value["Frame"]
					elseif Value["UIInstance"] ~= nil then
						Value = Value["UIInstance"]
					end
				end
			end
			
			for i, v in pairs(self.Properties) do
				if i == "ImageLabel" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance[PropertyToEffect] = Value
							break
						end
					end
				elseif i == "TextLabel" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance.TextLabel[PropertyToEffect] = Value
							break
						end
					end
				end
			end
		end
	})
	
end

function TextLabel:Tween(tweenInfo, Goal, Yield)
	
	local Tween = TweenService:Create(self.UIInstance, tweenInfo, Goal)
	
	if Yield then
		Tween:Play()
		Tween.Completed:Wait()
		return true
	else
		Tween:Play()
		return true
	end
end

function TextLabel:Edit(Properties)
	local UIInstance = self.UIInstance
	
	if not UIInstance then
		error("Attempted to edit a UI instance that doesn't exist.", 2)
	end
	
	if type(Properties["Parent"]) == "table" then
		if Properties["Parent"]["Frame"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["Frame"]
		elseif Properties["Parent"]["UIInstance"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["UIInstance"]
		end
	end
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "TextLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance.TextLabel[PropertyToEffect] = Property
				end
			end
		end
	end

	-- // ZIndex
	
	ZIndexInstance(UIInstance, Properties["ZIndex"])
	
	-- // Global UI
	
	if Properties["Shadow"] then
		if UIInstance:FindFirstChild("Shadow") then
			warn("UI Instance already has a shadow.")
		else
			local newShadow = GlobalUI.Shadow:Clone()
			newShadow.Parent = UIInstance
		end
	elseif not Properties["Shadow"] and UIInstance:FindFirstChild("Shadow") then
		UIInstance:FindFirstChild("Shadow"):Destroy()
	end
	
end

return TextLabel