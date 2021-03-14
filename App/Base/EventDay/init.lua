local module = {}

local function CheckBetween(Num,x,y)
	if Num == x or Num == y then
		return true
	end
	
	local min = math.min(x,y)
	local max = math.max(x,y)
	
	if Num >= min and Num <= max then
		return true
	end
	
	return false
end

local FireworkColors = {
	Color3.fromRGB(255,0,0);
	Color3.fromRGB(0,255,0);
	Color3.fromRGB(0,0,255);
	Color3.fromRGB(255,255,0);
	Color3.fromRGB(0,255,255);
	Color3.fromRGB(255,0,255);
	Color3.fromRGB(255,255,255);
}
local function UIFireworks(Parent,ScalePosX,AdvancedTween,ParticleHandle)
	local ExploTo = math.random(12,16)
	local Color = FireworkColors[math.random(1,#FireworkColors)]
	local OffsetPosY = math.random(100,200)
	local OffsetPosX = math.random(-75,75)
	
	local FlyStart = UDim2.new(ScalePosX,OffsetPosX,1,-1)
	local FlyEnd = UDim2.new(ScalePosX,0,1,-OffsetPosY)
	local FlyAng = math.deg(math.atan2(OffsetPosY,OffsetPosX))
	
	local FlyPoint = script.FireworkFly:Clone()
	FlyPoint.Rotation = FlyAng
	FlyPoint.Position = FlyStart
	FlyPoint.Parent = Parent
	FlyPoint.ImageColor3 = Color
	FlyPoint.Point.ImageColor3 = Color
	
	-- 날라가기
	AdvancedTween:RunTween(FlyPoint,{
		Time = 0.6;
		Easing = AdvancedTween.EasingFunctions.Exp4;
		Direction = AdvancedTween.EasingDirection.Out;
	},{
		Position = FlyEnd;
	},function()
		
		-- 여러 조각으로 부서트리기
		for i = 1,ExploTo do
			-- 발사
			local FireworkFire = script.FireworkFire:Clone()
			FireworkFire.ImageColor3 = Color
			FireworkFire.Position = FlyEnd
			FireworkFire.Parent = Parent
			
			-- 날라가는 각도 지정
			local FireAng = math.random(0,360)
			FireworkFire.Rotation = FireAng + 270
			
			-- 물리 연산
			local Physics = ParticleHandle:Craft_2DParticleEmitter({
				OnUDim = true;
				Inertia = 0.01;
				Gravity = 0.09;
				Vector = ParticleHandle:GetVecByYLine(FireAng,3.7);
				Position = Vector2.new(0,-38);
				Function = function(Pos,Vec)
					FireworkFire.Position = UDim2.new(
						ScalePosX,
						Pos.X,
						1,
						-OffsetPosY + Pos.Y
					)
					FireworkFire.Rotation = math.deg(math.atan2(Vec.Y,Vec.X)) + 180
				end;
			})
			
			-- 소멸
			delay(0.25,function()
				AdvancedTween:RunTween(FireworkFire,{
					Time = 0.25;
					Easing = AdvancedTween.EasingFunctions.Linear;
					Direction = AdvancedTween.EasingDirection.Out;
				},{
					ImageTransparency = 1;
				},function()
					Physics:Destroy()
					FireworkFire:Destroy()
				end)
			end)
		end
		
		-- 폭죽 헤드 없에기
		AdvancedTween:RunTweens({FlyPoint,FlyPoint.Point},{
			Time = 0.2;
			Easing = AdvancedTween.EasingFunctions.Linear;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			ImageTransparency = 1;
		},function()
			FlyPoint:Destroy()
		end)
	end)
end

local Events = {
	{
		Name = "Christmas";
		Check = function(Lang,Date)
			if Date.month ~= 12 then
				return false
			elseif not CheckBetween(Date.day,25,26) then
				return false
			end
			
			return true
		end;
		RunEvent = function(ui,Modules)
			local ParticleHandle = Modules.ParticleHandle
			local MaterialUI = Modules.MaterialUI
			local AdvancedTween = Modules.AdvancedTween
			
			local snows = {
				"http://www.roblox.com/asset/?id=6130714772";
				"http://www.roblox.com/asset/?id=6130714752";
				"http://www.roblox.com/asset/?id=6130714736";
				"http://www.roblox.com/asset/?id=6130714725";
			}
			
			local Focused = false
			local Running = false
			ui.WindowFocused:Connect(function()
				Focused = true
				if Running then
					return
				end
				
				while true do
					if not Focused then
						break
					end
					local PosX = math.random(0,100)/100
					local this = MaterialUI.Create("ImageLabel",{
						AnchorPoint = Vector2.new(0,.51);
						Position = UDim2.new(PosX,0,0,0);
						Size = UDim2.fromOffset(25,25);
						BackgroundTransparency = 1;
						Image = snows[math.random(1,#snows)];
						ZIndex = 2147483647;
						Parent = ui;
						ImageTransparency = 0.7;
					})
					local Physics = ParticleHandle:Craft_2DParticleEmitter({
						OnUDim = true;
						Inertia = 1;
						Gravity = 0;
						Vector = ParticleHandle:GetVecByYLine(180,3.2);
						Position = Vector2.new(0,0);
						Function = function(Pos)
							this.Position = UDim2.new(PosX,0,0,Pos.Y)
						end;
					})
					delay(3,function()
						if this then
							Physics:Destroy()
							this:Destroy()
						end
					end)
					wait(0.2)
				end
				Running = false
			end)
			ui.WindowFocusReleased:Connect(function()
				Focused = false
			end)
		end;
	};
	{
		Name = "Korea-NewYear";
		Check = function(Lang,Date)
			if Lang ~= "ko-kr" then
				return false
			elseif Date.month ~= 2 then
				return false
			elseif not CheckBetween(Date.day,10,15) then
				return false
			end
			return true
		end;
		RunEvent = function(ui,Modules)
			local ParticleHandle = Modules.ParticleHandle
			local MaterialUI = Modules.MaterialUI
			local AdvancedTween = Modules.AdvancedTween
			
			local Focused = false
			local Running = false
			ui.WindowFocused:Connect(function()
				Focused = true
				if Running then
					return
				end
				
				for i = 1,10 do
					if not Focused then
						break
					end
					UIFireworks(ui,math.random(10,90)/100,AdvancedTween,ParticleHandle)
					wait(0.5)
				end
				Running = false
			end)
			ui.WindowFocusReleased:Connect(function()
				Focused = false
			end)
		end;
	};
}

function module:Setup(ui,MaterialUI,AdvancedTween)
	local LangName = game:GetService("LocalizationService").SystemLocaleId
	local Date = os.date("*t",os.time())
	
	for _,Event in pairs(Events) do
		if Event.Check(LangName,Date) then
			local ParticleHandle = require(script.UIParticleEmitter)
			Event.RunEvent(ui,{
				MaterialUI = MaterialUI;
				ParticleHandle = ParticleHandle;
				AdvancedTween = AdvancedTween;
			})
			break
		end
	end
end

return module
