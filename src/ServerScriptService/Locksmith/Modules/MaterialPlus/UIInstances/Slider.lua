local Slider = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local GlobalUI = script.Parent.Parent.GlobalUI

local function RoundToDecimalPlace(num)
    return num - num % 0.1
end

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

local function CreateUI(Properties)
	
	local UIInstance
	
	if Properties["Style"] ~= nil then
		UIInstance = script[Properties["Style"]]:Clone()
	else
		UIInstance = script.Light:Clone()
	end
	
	if not Properties["Parent"] then
		UIInstance:Destroy()
		error("Frame instance requires a parent. Parent property was not defined.", 2)
		return
	end
	
	if type(Properties["Parent"]) == "table" then
		if Properties["Parent"]["Frame"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["Frame"]
		elseif Properties["Parent"]["UIInstance"] ~= nil then
			Properties["Parent"] = Properties["Parent"]["UIInstance"]
		end
	end
	
	-- // Values
	
	local Config = UIInstance.Configuration
	
	Config.MinValue.Value = Properties["MinValue"] or Config.MinValue.Value
	Config.MaxValue.Value = Properties["MaxValue"] or Config.MaxValue.Value
	Config.CurrentValue.Value =  Properties["MaxValue"] or Config.CurrentValue.Value
	
	-- // UI
	
	local InstanceProperties = {
		["Frame"] = {
			Parent = "Parent";
			Position = "Position";
			AnchorPoint = "AnchorPoint";
			Size = "Size";
			
			Visible = "Visible";
			
			BackgroundTransparency = "BackgroundTransparency";
			BackgroundColor3 = "BackgroundColor3";
			
			LayoutOrder = "LayoutOrder";
			
			Rotation = "Rotation";
			
			Name = "Name";
		};
		
		["Toggle"] = {
			SliderColor3 = "ImageColor3"
		}
	}
	
	for i, v in pairs(InstanceProperties) do
		if i == "Frame" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "Toggle" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		end
	end
	
	ZIndexInstance(UIInstance, Properties["ZIndex"])
	
	if Properties["Shadow"] ~= nil then
		local newShadow = GlobalUI.Shadow:Clone()
		newShadow.Parent = UIInstance
	end
	
	return {UIInstance, InstanceProperties}
	
end

function Slider:MoveSlider(Value)
	
	local Config = self.UIInstance.Configuration
	
	Value = math.clamp(Value, 0, 1)
		
	local Percentage = (Value - Config.MinValue.Value) / (1 - 0)
	
	TweenService:Create(self.UIInstance.Toggle, TweenInfo.new(0.1), {Position = UDim2.new(Percentage, 0, 0.5, 0)}):Play()
			
	local newValue = Config.MinValue.Value + ((Config.MaxValue.Value - Config.MinValue.Value) * Percentage)
	
	if self.Round then
		Config.CurrentValue.Value = math.floor(newValue + 0.5)
	else
		Config.CurrentValue.Value = RoundToDecimalPlace(newValue)
	end
end

function Slider.new(Properties)
	
	local self = {}
	
	local CreatedUI = CreateUI(Properties)
	self.UIInstance = CreatedUI[1]
	self.Properties = CreatedUI[2]
	
	self.Interacting = false
	
	if Properties["Round"] ~= nil then
		self.Round = Properties["Round"]
	else
		self.Round = false
	end
	
	self.ConnectionBegan = nil
	self.ConnectionEnded = nil
	self.ConnectionChanged = nil
	
	Slider.ValueChanged = self.UIInstance.Configuration.CurrentValue.Changed
	
	for i, v in pairs(self.Properties) do
		if i == "Frame" then
			for PropertyName, PropertyToEffect in pairs(v) do
				Slider[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		elseif i == "Toggle" then
			for PropertyName, PropertyToEffect in pairs(v) do
				Slider[PropertyName] = self.UIInstance.Toggle[PropertyToEffect]
			end
		end
	end
	
	return setmetatable(self, {
		__index = Slider;
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
				if i == "Frame" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance[PropertyToEffect] = Value
							break
						end
					end
				elseif i == "Toggle" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance.Toggle[PropertyToEffect] = Value
							break
						end
					end
				end
			end
		end
	})
	
end

function Slider:Enable()
	
	local Config = self.UIInstance.Configuration
	self.ConnectionBegan = self.UIInstance.Toggle.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self.Interacting = true
		end
	end)
	
	self.ConnectionEnded = self.UIInstance.Toggle.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self.Interacting = false
		end
	end)
	
	self.ConnectionChanged = UserInputService.InputChanged:Connect(function(Input)
		if self.Interacting then
			local Percentage
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				
				local BarStart, BarEnd = self.UIInstance.AbsolutePosition, self.UIInstance.AbsolutePosition + self.UIInstance.AbsoluteSize
				local MousePosition = Input.Position
				local MousePosDiff = MousePosition.X - BarStart.X
				
				Percentage = MousePosDiff / (self.UIInstance.AbsoluteSize.X)
			end
			
			if Percentage then
				Percentage = math.clamp(Percentage, 0, 1)
				
				self:MoveSlider(Percentage)
			end
		end
	end)
	
end

function Slider:Disable()
	
	if self.ConnectionBegan then
		self.ConnectionBegan:Disconnect()
	end
	
	if self.ConnectionEnded then
		self.ConnectionEnded:Disconnect()
	end
	
	if self.ConnectionChanged then
		self.ConnectionChanged:Disconnect()
	end
end

function Slider:Tween(tweenInfo, Goal, Yield)
	
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

function Slider:Edit(Properties)
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
		if i == "Frame" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "Toggle" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance.Toggle[PropertyToEffect] = Property
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

return Slider