local Placement = {}

function Placement.BottomLeft(Frame, UIInstance)
	UIInstance.AnchorPoint = Vector2.new(0, 0)
	UIInstance.Position = UDim2.new(0, 0, 0, 0)
	UIInstance.Holder.AnchorPoint = Vector2.new(0, 0)
	UIInstance.Holder.Position = UDim2.new(0, 0, Frame.Size.Y.Scale, Frame.Size.Y.Offset + 3)
end

function Placement.BottomMiddle(Frame, UIInstance)
	UIInstance.AnchorPoint = Vector2.new(0.5, 0)
	UIInstance.Position = UDim2.new(0.5, 0, 0, 0)
	UIInstance.Holder.AnchorPoint = Vector2.new(0, 0)
	UIInstance.Holder.Position = UDim2.new(0, 0, Frame.Size.Y.Scale, Frame.Size.Y.Offset + 3)
end

function Placement.BottomRight(Frame, UIInstance)
	UIInstance.AnchorPoint = Vector2.new(1, 0)
	UIInstance.Position = UDim2.new(1, 0, 0, 0)
	UIInstance.Holder.AnchorPoint = Vector2.new(0, 0)
	UIInstance.Holder.Position = UDim2.new(0, 0, Frame.Size.Y.Scale, Frame.Size.Y.Offset + 3)
end

function Placement.TopLeft(Frame, UIInstance)
	UIInstance.AnchorPoint = Vector2.new(0, 1)
	UIInstance.Position = UDim2.new(0, 0, 1, 0)
	UIInstance.Holder.AnchorPoint = Vector2.new(0, 1)
	UIInstance.Holder.Position = UDim2.new(0, 0, 1, -Frame.Size.Y.Offset - 3)
end

function Placement.TopMiddle(Frame, UIInstance)
	UIInstance.AnchorPoint = Vector2.new(0.5, 1)
	UIInstance.Position = UDim2.new(0.5, 0, 1, 0)
	UIInstance.Holder.AnchorPoint = Vector2.new(0, 1)
	UIInstance.Holder.Position = UDim2.new(0, 0, 1, -Frame.Size.Y.Offset - 3)
end

function Placement.TopRight(Frame, UIInstance)
	UIInstance.AnchorPoint = Vector2.new(1, 1)
	UIInstance.Position = UDim2.new(1, 0, 1, 0)
	UIInstance.Holder.AnchorPoint = Vector2.new(0, 1)
	UIInstance.Holder.Position = UDim2.new(0, 0, 1, -Frame.Size.Y.Offset - 3)
end

return Placement