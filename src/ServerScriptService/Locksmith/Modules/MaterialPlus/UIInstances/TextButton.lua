local TweenService = game:GetService("TweenService")

local GlobalUI = script.Parent.Parent.GlobalUI

local TextButton = {}

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

local function CreateButton(Properties)
	
	local UIInstance
	
	if Properties["Style"] ~= nil then
		UIInstance = script[Properties["Style"]]:Clone()
	else
		UIInstance = script.Light:Clone()
	end
	
	if not Properties["Parent"] then
		UIInstance:Destroy()
		error("TextButton instance requires a parent. Parent property was not defined.", 2)
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
		["ImageButton"] = {
			Parent = "Parent";
			Position = "Position";
			AnchorPoint = "AnchorPoint";
			Size = "Size";
			
			Visible = "Visible";
			
			BackgroundTransparency = "ImageTransparency";
			BackgroundColor3 = "ImageColor3";
			
			Rotation = "Rotation";
			
			Name = "Name";
			
			Active = "Active";
			AutoButtonColor = "AutoButtonColor"
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
		if i == "ImageButton" then
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
					UIInstance[PropertyToEffect] = Property
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

function TextButton.new(Properties)
	
	local self = {}
	
	local CreatedUI = CreateButton(Properties)
	
	self.UIInstance = CreatedUI[1]
	self.Properties = CreatedUI[2]
	
	TextButton.MouseButton1Click = self.UIInstance.MouseButton1Click
	TextButton.MouseButton2Click = self.UIInstance.MouseButton2Click
	
	TextButton.MouseButton1Down = self.UIInstance.MouseButton1Down
	TextButton.MouseButton2Down = self.UIInstance.MouseButton2Down
	
	TextButton.MouseButton1Up = self.UIInstance.MouseButton1Up
	TextButton.MouseButton2Up = self.UIInstance.MouseButton2Up
	
	TextButton.Activated = self.UIInstance.Activated
	
	TextButton.MouseEnter = self.UIInstance.MouseEnter
	TextButton.MouseLeave = self.UIInstance.MouseLeave
	TextButton.MouseMoved = self.UIInstance.MouseMoved
	
	for i, v in pairs(self.Properties) do
		if i == "ImageButton" then
			for PropertyName, PropertyToEffect in pairs(v) do
				TextButton[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		elseif i == "TextLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				TextButton[PropertyName] = self.UIInstance.TextLabel[PropertyToEffect]
			end
		end
	end
	
	return setmetatable(self, {
		__index = TextButton;
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
				if i == "ImageButton" then
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

function TextButton:Tween(tweenInfo, Goal, Yield)
	
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

function TextButton:Edit(Properties)
	
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
		if i == "ImageButton" then
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

return TextButton