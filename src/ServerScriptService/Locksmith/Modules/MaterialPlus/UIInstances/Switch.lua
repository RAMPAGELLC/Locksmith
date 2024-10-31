local Switch = {}

local GlobalUI = script.Parent.Parent.GlobalUI

local TweenService = game:GetService("TweenService")

function ZIndexInstance(UIInstance, ZIndex)
	
	if ZIndex == nil then
		return
	end
	
	UIInstance.Border.ZIndex = ZIndex
	UIInstance.ZIndex = ZIndex + 1
	
	UIInstance.Container.Toggle.ZIndex = ZIndex + 1
	UIInstance.Button.ZIndex = ZIndex + 3
	
end

local function CreateUI(Properties)
	
	local UIInstance
	
	if Properties["Style"] ~= nil then
		UIInstance = script[Properties["Style"]]:Clone()
	else
		UIInstance = script.Light:Clone()
	end
	
	if not Properties["Parent"] then
		UIInstance:Destroy()
		error("Switch instance requires a parent. Parent property was not defined.", 2)
		return
	end
	
	if type(Properties["Parent"]) == "table" then
		if Properties["Parent"]["Frame"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["Frame"]
		elseif Properties["Parent"]["UIInstance"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["UIInstance"]
		end
	end
	
	-- // Config
	
	local Config = UIInstance.Configuration
	
	Config.On.Value = Properties["OnColor3"] or Config.On.Value
	Config.Off.Value = Properties["OffColor3"] or Config.Off.Value
	
	-- // Image Label
	
	if Properties["BorderSizePixel"] ~= nil then
		UIInstance.Border.Size = UDim2.new(1, 4 * Properties["BorderSizePixel"], 1, 4 * Properties["BorderSizePixel"])
	end
	
	local InstanceProperties = {
		["ImageLabel"] = {
			Parent = "Parent";
			Position = "Position";
			AnchorPoint = "AnchorPoint";
			Size = "Size";
			
			BackgroundTransparency = "ImageTransparency";
			
			Visible = "Visible";
			
			Rotation = "Rotation";
			
			Name = "Name";
		};
		
		["Border"] = {
			BorderColor3 = "ImageColor3"
		};
		
		["Toggle"] = {
			SwitchColor3 = "ImageColor3"
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
		elseif i == "Border" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance.Border[PropertyToEffect] = Property
				end
			end
		elseif i == "Toggle" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance.Container.Toggle[PropertyToEffect] = Property
				end
			end
		end
	end
	
	UIInstance.ImageColor3 = Config.Off.Value
	
	ZIndexInstance(UIInstance, Properties["ZIndex"])
	
	if Properties["Shadow"] then
		local Shadow = GlobalUI.Shadow:Clone()
		Shadow.Parent = UIInstance
	end
	
	return {UIInstance, InstanceProperties}
	
end

function Switch.new(Properties)
	
	local self = {}
	
	local CreatedUI = CreateUI(Properties)
	
	self.UIInstance = CreatedUI[1]
	self.Properties = CreatedUI[2]
	
	self.SwitchTweenInfo = Properties["SwitchTweenInfo"] or TweenInfo.new(0.15)
	
	self.ValueChanged = self.UIInstance.Configuration.CurrentToggle.Changed
	
	self.ClickConnection = nil
	
	Switch.BorderSizePixel = self.UIInstance.Border.Size.X.Offset / 4
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				Switch[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		elseif i == "Border" then
			for PropertyName, PropertyToEffect in pairs(v) do
				Switch[PropertyName] = self.UIInstance.Border[PropertyToEffect]
			end
		elseif i == "Toggle" then
			for PropertyName, PropertyToEffect in pairs(v) do
				Switch[PropertyName] = self.UIInstance.Container.Toggle[PropertyToEffect]
			end
		end
	end
	
	return setmetatable(self, {
		__index = Switch;
		__newindex = function(Table, Index, Value)
			if Index == "ZIndex" then
				ZIndexInstance(self.UIInstance, Value)
				return
			end
			
			if Index == "BorderSizePixel" then
				self.UIInstance.Border.Size = UDim2.new(1, 4 * Value, 1, 4 * Value)
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
				elseif i == "Border" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance.Border[PropertyToEffect] = Value
							break
						end
					end
				elseif i == "Toggle" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance.Container.Toggle[PropertyToEffect] = Value
							break
						end
					end
				end
			end
		end
	})
	
end

function Switch:Toggle(toggle)
	
	self.UIInstance.Configuration.CurrentToggle.Value = toggle
	
	if toggle then
		
		TweenService:Create(self.UIInstance.Container.Toggle, self.SwitchTweenInfo, {Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0)}):Play()
		TweenService:Create(self.UIInstance, self.SwitchTweenInfo, {ImageColor3 = self.UIInstance.Configuration.On.Value}):Play()
		
	else
		
		TweenService:Create(self.UIInstance.Container.Toggle, self.SwitchTweenInfo, {Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0, 0)}):Play()
		TweenService:Create(self.UIInstance, self.SwitchTweenInfo, {ImageColor3 = self.UIInstance.Configuration.Off.Value}):Play()
		
	end
	
end

function Switch:Edit(Properties)
	
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
		
	-- // Config
	
	local Config = UIInstance.Configuration
	
	Config.On.Value = Properties["OnColor3"] or Config.On.Value
	Config.Off.Value = Properties["OffColor3"] or Config.Off.Value
	
	-- // Image Label
	
	if Properties["BorderSizePixel"] ~= nil then
		UIInstance.Border.Size = UDim2.new(1, 4 * Properties["BorderSizePixel"], 1, 4 * Properties["BorderSizePixel"])
	end
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "Border" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance.Border[PropertyToEffect] = Property
				end
			end
		elseif i == "Toggle" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance.Container.Toggle[PropertyToEffect] = Property
				end
			end
		end
	end
	
	ZIndexInstance(UIInstance, Properties["ZIndex"])
	
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

function Switch:Tween(tweenInfo, Goal, Yield)
	
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


function Switch:Enable()
	
	self.ClickConnection = self.UIInstance.Button.MouseButton1Click:Connect(function()
		self:Toggle(not self.UIInstance.Configuration.CurrentToggle.Value)
	end)
	
end

function Switch:Disable()
	
	if self.ClickConnection then
		self.ClickConnection:Disconnect()
	end
	
end

return Switch