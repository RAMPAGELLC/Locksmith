local TweenService = game:GetService("TweenService")

local GlobalUI = script.Parent.Parent.GlobalUI

local Frame = {}

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
	
	local InstanceProperties = {
		["ImageLabel"] = {
			Parent = "Parent";
			Position = "Position";
			AnchorPoint = "AnchorPoint";
			Size = "Size";
			
			Visible = "Visible";
			
			BackgroundTransparency = "ImageTransparency";
			BackgroundColor3 = "ImageColor3";
			
			LayoutOrder = "LayoutOrder";
			
			Rotation = "Rotation";
			
			Name = "Name";
			
			ClipsDescendants = "ClipsDescendants"
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
		end
	end
	
	ZIndexInstance(UIInstance, Properties["ZIndex"])
	
	-- // Rounded
	
	if Properties["RoundedCornerPix"] then
		if Properties["RoundedCornerPix"] == 0 then
			UIInstance.SliceScale = 0.001
		else
			UIInstance.SliceScale = Properties["RoundedCornerPix"] / 100
		end
	end
	
	-- // Global UI
	
	if Properties["Shadow"] ~= nil then
		local newShadow = GlobalUI.Shadow:Clone()
		newShadow.Parent = UIInstance
	end
	
	return {UIInstance, InstanceProperties}
	
end

function Frame.new(Properties)
	
	local self = {}
	
	local CreatedUI = CreateUI(Properties)
	
	self.UIInstance = CreatedUI[1]
	self.Properties = CreatedUI[2]
	
	Frame.MouseEnter = self.UIInstance.MouseEnter
	Frame.MouseLeave = self.UIInstance.MouseLeave
	Frame.MouseMoved = self.UIInstance.MouseMoved
	
	Frame.RoundedCornerPix = math.floor(self.UIInstance.SliceScale * 100)
	
	for i, v in pairs(self.Properties) do
		if i == "ImageLabel" then
			for PropertyName, PropertyToEffect in pairs(v) do
				Frame[PropertyName] = self.UIInstance[PropertyToEffect]
			end
		end
	end
	
	return setmetatable(self, {
		__index = Frame;
		__newindex = function(Table, Index, Value)
			
			if Index == "ZIndex" then
				ZIndexInstance(self.UIInstance, Value)
				return
			end
			
			if Index == "RoundedCornerPix" then
				if Value == 0 then
					self.UIInstance.SliceScale = 0.001
				else
					self.UIInstance.SliceScale = Value / 100
				end
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
				end
			end
		end
	})
	
end

function Frame:Tween(tweenInfo, Goal, Yield)
	
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

function Frame:Edit(Properties)
	
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
		end
	end
	
	if Properties["RoundedCornerPix"] then
		if Properties["RoundedCornerPix"] == 0 then
			UIInstance.SliceScale = 0.001
		else
			UIInstance.SliceScale = Properties["RoundedCornerPix"] / 100
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

return Frame