-- Copyright (©) 2024 Metatable Games
-- Written by vq9o
-- License: The Unlicense
-- GitHub: https://github.com/RAMPAGELLC/Locksmith

return function(Frame)
	task.spawn(function()
		local c1 = Frame.Circle1
		local c2 = Frame.Circle2
		local c3 = Frame.Circle3

		while true do
			wait(0.15)
			c1:TweenSize(UDim2.new(0, 5, 0, 5), "InOut", "Quad", 0.5, true)
			wait(0.15)
			c2:TweenSize(UDim2.new(0, 5, 0, 5), "InOut", "Quad", 0.5, true)
			wait(0.15)
			c3:TweenSize(UDim2.new(0, 5, 0, 5), "InOut", "Quad", 0.5, true)
			wait(0.15)
			c1:TweenSize(UDim2.new(0, 20, 0, 20), "InOut", "Quad", 0.5, true)
			wait(0.15)
			c2:TweenSize(UDim2.new(0, 20, 0, 20), "InOut", "Quad", 0.5, true)
			wait(0.15)
			c3:TweenSize(UDim2.new(0, 20, 0, 20), "InOut", "Quad", 0.5, true)
		end
	end)
end