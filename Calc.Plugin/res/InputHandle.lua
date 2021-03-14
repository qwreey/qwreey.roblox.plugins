local module = {}

local KeyCodeAndFunctionName = {
	[Enum.KeyCode.KeypadZero] = "Zero";
	[Enum.KeyCode.KeypadOne] = "One";
	[Enum.KeyCode.KeypadTwo] = "Two";
	[Enum.KeyCode.KeypadThree] = "Three";
	[Enum.KeyCode.KeypadFour] = "Four";
	[Enum.KeyCode.KeypadFive] = "Five";
	[Enum.KeyCode.KeypadSix] = "Six";
	[Enum.KeyCode.KeypadSeven] = "Seven";
	[Enum.KeyCode.KeypadEight] = "Eight";
	[Enum.KeyCode.KeypadNine] = "Nine";
	[Enum.KeyCode.KeypadEnter] = "Eq";
	[Enum.KeyCode.KeypadPlus] = "Sum";
	[Enum.KeyCode.KeypadMinus] = "Sub";
	[Enum.KeyCode.KeypadMultiply] = "Multiple";
	[Enum.KeyCode.KeypadDivide] = "Divide";
	[Enum.KeyCode.KeypadPeriod] = "Dot";
}

local Focused = false
local Loaded = false
function module:init(Calc,Ripplers,Interface)
	
	local InputHandleFrame = Instance.new("Frame")
	InputHandleFrame.Size = UDim2.new(1,0,1,0)
	InputHandleFrame.BackgroundTransparency = 1
	InputHandleFrame.Parent = Interface
	
	InputHandleFrame.InputBegan:Connect(function(Input)
		if not Focused then
			return
		end
		
		local FnName = KeyCodeAndFunctionName[Input.KeyCode]
		if FnName then
			Calc.KeyFn["Key_"..FnName]()
			Ripplers[FnName]()
		end
	end)
	
	if not Loaded then
		Loaded = true
		--// 포커스와 연동
		Interface.WindowFocused:Connect(function()
			Focused = true
		end)
		Interface.WindowFocusReleased:Connect(function()
			Focused = false
		end)
	end
end

return module
