local GlobalUI = script.Parent.Parent.GlobalUI

local TweenService = game:GetService("TweenService")

local PlacementModule = require(script.Placement)

local TextBase

local DropMenu = {}

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

function CreateUI(Frame, Properties, Options)
	
	local UIInstance
	
	local StyleTextColor
	
	if Properties["Style"] then
		UIInstance = script[Properties["Style"]]:Clone()
		
		if Properties["Style"] == "Dark" then
			StyleTextColor = Color3.fromRGB(255, 255, 255)
		else
			StyleTextColor = Color3.fromRGB(40, 40, 40)
		end
	else
		UIInstance = script.Light:Clone()
		StyleTextColor = Color3.fromRGB(40, 40, 40)
	end
	
	if Frame == nil then
		UIInstance:Destroy()
		error("Drop down menu requires a UI instance to be parented to.", 2)
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
			Size = "Size";
			
			Visible = "Visible";
			
			Rotation = "Rotation";
			
			Name = "Name";
		};
		
		["Holder"] = {
			Size = "Size";
			
			BackgroundTransparency = "ImageTransparency";
			BackgroundColor3 = "ImageColor3";
		};
	}
	
	for i, v in pairs(InstanceProperties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "Holder" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					UIInstance[PropertyToEffect] = Property
				end
			end
		end
	end
	
	-- // Options
	
	TextBase = Instance.new("TextButton")
	TextBase.BackgroundTransparency = Properties["TextButtonTransparency"] or 1
	TextBase.Font = Properties["Font"] or Enum.Font.GothamSemibold
	TextBase.TextColor3 = Properties["TextColor3"] or StyleTextColor
	TextBase.AutoButtonColor = Properties["AutoButtonColor"] or false
	TextBase.Size = Properties["ButtonSize"] or UDim2.new(1, 0, 0, 25)
	TextBase.TextSize = Properties["TextSize"] or 18
	TextBase.BorderColor3 = Properties["ButtonBorderColor3"] or TextBase.BorderColor3
	TextBase.BorderSizePixel = Properties["ButtonBorderSizePixel"] or 0
	TextBase.TextXAlignment = Properties["TextXAlignment"] or Enum.TextXAlignment.Left
	TextBase.TextYAlignment = Properties["TextYAlignment"] or Enum.TextYAlignment.Center
	
	if Properties["TextScaled"] ~= nil then
		TextBase.TextScaled = Properties["TextScaled"]
	else
		TextBase.TextScaled = true
	end
	
	if Properties["TextWrapped"] ~= nil then
		TextBase.TextWrapped = Properties["TextWrapped"]
	else
		TextBase.TextWrapped = true
	end
	
	for OptionName, Func in pairs(Options) do
		
		local Template = TextBase:Clone()
		Template.Text = OptionName
		Template.MouseButton1Click:Connect(Func)
		Template.Parent = UIInstance.Holder
		
	end
	
	wait()
	
	local newScale = UDim2.new(UIInstance.Size.X.Scale, UIInstance.Size.X.Offset, 0, (Frame.AbsoluteSize.Y + UIInstance.Holder.UIListLayout.AbsoluteContentSize.Y) + 10) --+ UDim2.new(0, 0, 0, 0)
	UIInstance.Size = newScale
	
	-- // ImageButton
	
	if Properties["Placement"] ~= nil then
		local placement = Properties["Placement"]
		
		PlacementModule[placement](Frame, UIInstance)
	else
		PlacementModule["BottomLeft"](Frame, UIInstance)
	end
	
	ZIndexInstance(UIInstance, Properties["ZIndex"])
	
	if Properties["Shadow"] then
		local Shadow = GlobalUI.Shadow:Clone()
		Shadow.Parent = UIInstance.Holder
	end
	
	return {UIInstance, InstanceProperties}
	
end

function DropMenu.new(Properties, Frame, Options)
	
	local self = {}
	
	if type(Frame) == "table" then
		if Frame["UIInstance"] ~= nil then
			Frame = Frame["UIInstance"]
		elseif Frame["Frame"] ~= nil then
			Frame = Frame["Frame"]
		end
	end
	
	local CreatedUI = CreateUI(Frame, Properties, Options)
	
	self.UIInstance = CreatedUI[1]
	self.Properties = CreatedUI[2]
	
	self.Frame = Frame
	
	self.DB = false
	
	self.MouseIn = false
	
	self.Enabled = false
	
	self.TweenInfo = Properties["OpenTweenInfo"] or TweenInfo.new(0.25)
	
	self.OpenConnection = nil
	self.CloseConnection = nil
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				DropMenu[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		elseif i == "Holder" then
			for PropertyName, PropertyToEffect in pairs(v) do
				DropMenu[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		end
	end
	
	return setmetatable(self, {
		__index = DropMenu;
		__newindex = function(Table, Index, Value)
			
			if Index == "ZIndex" then
				ZIndexInstance(self.UIInstance, Value)
				return
			end
			
			if Index == "Placement" then
				PlacementModule[Value](self.Frame, self.UIInstance)
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
				elseif i == "Holder" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance.Holder[PropertyToEffect] = Value
							break
						end
					end
				end
			end
		end
	})
end

function DropMenu:Enable()
	
	self.Enabled = true
	
	self.MouseIn = false
	
	self.OpenConnection = self.Frame.MouseEnter:Connect(function()
		
		if self.MouseIn or self.DB then
			return
		end
		
		self.DB = true
		
		self.MouseIn = true
		
		self.UIInstance.Holder.Size = UDim2.new(self.UIInstance.Holder.Size.X.Scale, 0, 0, 0)
		self.UIInstance.Visible = true
		
		local ListLayout = self.UIInstance.Holder.UIListLayout
		
		local newTween = TweenService:Create(self.UIInstance.Holder, self.TweenInfo, {Size = UDim2.new(self.UIInstance.Holder.Size.X.Scale, self.UIInstance.Holder.Size.X.Offset, 0, ListLayout.AbsoluteContentSize.Y + 5)})
		
		newTween:Play()
		
	end)
	
	self.CloseConnection = self.UIInstance.MouseLeave:Connect(function()
		
		if not self.MouseIn then
			return
		end
		
		self.MouseIn = false
		
		local newTween = TweenService:Create(self.UIInstance.Holder, self.TweenInfo, {Size = UDim2.new(self.UIInstance.Holder.Size.X.Scale, 0, 0, 0)})
		
		newTween:Play()
		
		newTween.Completed:Wait()
		
		self.UIInstance.Visible = false
		
		wait(0.2)
		
		self.DB = false
		
	end)
	
end

function DropMenu:Disable()
	self.Enabled = false
	do
		self.MouseIn = false
	
		local newTween = TweenService:Create(self.UIInstance.Holder, self.TweenInfo, {Size = UDim2.new(self.UIInstance.Holder.Size.X.Scale, 0, 0, 0)})
		
		newTween:Play()
		
		newTween.Completed:Wait()
		
		self.UIInstance.Visible = false
	end
	
	if self.OpenConnection then
		self.CloseConnection:Disconnect()
	end
	
	if self.CloseConnection then
		self.CloseConnection:Disconnect()
	end
end

function DropMenu:Tween(tweenInfo, Goal, Yield)
	
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

function DropMenu:Edit(Properties)
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
	
	-- // ImageLabel Properties
	
	for OptionName, Func in pairs(Properties["Options"]) do
		
		local Template = TextBase:Clone()
		Template.Text = OptionName
		Template.MouseButton1Click:Connect(Func)
		Template.Parent = UIInstance.Holder
		
	end
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					self.UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "Holder" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					self.UIInstance.Holder[PropertyToEffect] = Property
				end
			end
		end
	end

	if Properties["Placement"] ~= nil then
		local placement = Properties["Placement"]
		
		PlacementModule[placement](self.Frame, UIInstance)
	else
		PlacementModule["BottomLeft"](self.Frame, UIInstance)
	end
	
	if Properties["Shadow"] then
		local Shadow = GlobalUI.Shadow:Clone()
		Shadow.Parent = UIInstance.Holder
	end

	-- // Global UI
	
	if Properties["Shadow"] then
		if UIInstance:FindFirstChild("Shadow") then
			warn("UI Instance already has a shadow.")
		else
			local newShadow = GlobalUI.Shadow:Clone()
			newShadow.Parent = UIInstance.Holder
		end
	elseif not Properties["Shadow"] and UIInstance:FindFirstChild("Shadow") then
		UIInstance:FindFirstChild("Shadow"):Destroy()
	end
	
end

return DropMenu
