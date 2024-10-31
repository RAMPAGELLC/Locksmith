local TweenService = game:GetService("TweenService")

local GlobalUI = script.Parent.Parent.GlobalUI

local TextBox = {}

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

local function CreateTextbox(Properties)
	
	local NewBox
	
	if Properties["Style"] ~= nil then
		NewBox = script[Properties["Style"]]:Clone()
	else
		NewBox = script.Light:Clone()
	end
	
	if not Properties["Parent"] then
		NewBox:Destroy()
		error("InputBox instance requires a parent. Parent property was not defined.", 2)
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
			
			Visible = "Visible";
			
			BackgroundTransparency = "ImageTransparency";
			BackgroundColor3 = "ImageColor3";
			
			Rotation = "Rotation";
			
			Name = "Name";
		};
		
		["InputBox"] = {
			Text = "Text";
			TextColor3 = "TextColor3";
			TextTransparency = "TextTransparency";
			
			TextStrokeTransparency = "TextStrokeTransparency";
			TextStrokeColor3 = "TextStrokeColor3";
			
			MultiLine = "MultiLine";
			ClearTextOnFocus = "ClearTextOnFocus";
			
			SelectionStart = "SelectionStart";
			
			ShowNativeInput = "ShowNativeInput";
			
			TextEditable = "TextEditable";
			
			PlaceholderColor3 = "PlaceholderColor3";
			PlaceholderText = "PlaceholderText";
			
			LayoutOrder = "LayoutOrder";
			
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
					NewBox[PropertyToEffect] = Property
				end
			end
		elseif i == "InputBox" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					NewBox.InputBox[PropertyToEffect] = Property
				end
			end
		end
	end

	-- // ZIndex
	
	ZIndexInstance(NewBox, Properties["ZIndex"])
	
	-- // Global UI
	
	if Properties["Shadow"] ~= nil then
		local newShadow = GlobalUI.Shadow:Clone()
		newShadow.Parent = NewBox
	end
	
	return {NewBox, InstanceProperties}
	
end

function TextBox.new(Properties)
	
	local self = {}
	
	local CreateUI = CreateTextbox(Properties)
	self.UIInstance = CreateUI[1]
	self.Properties = CreateUI[2]
	
	TextBox.Focused = self.UIInstance.InputBox.Focused
	TextBox.FocusLost = self.UIInstance.InputBox.FocusLost
	
	TextBox.MouseEnter = self.UIInstance.MouseEnter
	TextBox.MouseLeave = self.UIInstance.MouseLeave
	TextBox.MouseMoved = self.UIInstance.MouseMoved
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				TextBox[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		elseif i == "InputBox" then
			for PropertyName, PropertyToEffect in pairs(v) do
				TextBox[PropertyName] = self.UIInstance.InputBox[PropertyToEffect]
			end
		end
	end
	
	return setmetatable(self, {
		__index = TextBox;
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
				elseif i == "InputBox" then
					for PropertyName, PropertyToEffect in pairs(v) do
						if PropertyName == Index then
							self.UIInstance.InputBox[PropertyToEffect] = Value
							break
						end
					end
				end
			end
		end
	})
	
end

function TextBox:Tween(tweenInfo, Goal, Yield)
	
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

function TextBox:Edit(Properties)
	
	local NewBox = self.UIInstance
	
	if not NewBox then
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
					self.UIInstance[PropertyToEffect] = Property
				end
			end
		elseif i == "InputBox" then
			for PropertyName, PropertyToEffect in pairs(v) do
				local Property = Properties[PropertyName]
				
				if Property ~= nil then
					self.UIInstance.InputBox[PropertyToEffect] = Property
				end
			end
		end
	end
	
	-- // Global UI
	
	if Properties["Shadow"] then
		if NewBox:FindFirstChild("Shadow") then
			warn("UI Instance already has a shadow.")
		else
			local newShadow = GlobalUI.Shadow:Clone()
			newShadow.Parent = NewBox
		end
	elseif not Properties["Shadow"] and NewBox:FindFirstChild("Shadow") then
		NewBox:FindFirstChild("Shadow"):Destroy()
	end
	
end

function TextBox:IsFocused()
	return self.NewBox.InputBox:IsFocused()
end

function TextBox:ReleaseFocus(bool)
	self.NewBox.InputBox:ReleaseFocus(bool)
end

function TextBox:CaptureFocus()
	self.NewBox.InputBox:CaptureFocus()
end

return TextBox