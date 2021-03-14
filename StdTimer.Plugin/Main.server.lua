local plugin = plugin
if not plugin then
	--// 플러그인이 아닌데 이 코드가 실행되면 바로 멈춰줌(태스팅 모드에서)
	return
end

local AppInfo = {
	-- APP INFO
	["AppIcon"] = "http://www.roblox.com/asset/?id=5942547043";
	["AppIconLight"] = "http://www.roblox.com/asset/?id=5942547149"; -- for toolbar light mode
	["AppName"] = "Std Timer";
	["AppId"] = "qwreey.plugins.stdtimer";
	
	-- PLUGIN GROUP
	["ToolbarId"] = "qwreey.plugins.toolbarprovider";
	["ToolbarName"] = "Qwreey's plugins";
	
	--BUTTON
	["ButtonText"] = nil;
	["ButtonHoverText"] = nil;
	
	-- INTERFACE
	["InterfaceMiniSize"] = {X=150,Y=150};
	["InterfaceInitSize"] = {X=220,Y=300};
	["InterfaceDefaultFace"] = Enum.InitialDockState.Right;
	
	-- OTHER
	["Version"] = 10;
	["SplashIconSize"] = UDim2.new(0,70,0,70);
	["BypassSplash"] = false;
}

--------------
--import
--------------
--// 로블록스 서비스 불러오기(import)
local Run = game:GetService("RunService")

--// 모듈 불러오기
local Utils = require(script.lib.Util)
local MaterialUI = require(script.lib.MaterialUI)
local Data = require(script.lib.Data):SetUp(plugin)
local AdvancedTween = require(script.lib.AdvancedTween)
local ToolbarCombiner = require(script.lib.ToolbarCombiner)

local License = require(script.License)
local LicenseViewer = require(script.res.LicenseViewer)

local Language = require(script.res.Language)

--------------
--Make plugin
--------------
--// 플긴 버전 저장
local OldVersion = Data:Load("LastVersioni")
Data:Save("LastVersion",AppInfo.Version)

--// 불러오기
local App do
	local AppModule = require(script.App)
	App = AppModule:init(plugin,AppInfo,{
		MaterialUI = MaterialUI;
		AdvancedTween = AdvancedTween;
		ToolbarCombiner = ToolbarCombiner;
		Language = Language;
	})
end
local Interface = App.Interface

--// 라이선스 뷰어 Init
LicenseViewer:Init(App.SettingsHandle,MaterialUI,License,Language)

--------------
--Data
--------------
if Data:Load("SummationTime") == nil then
	Data:Save("SummationTime",math.floor(elapsedTime()))
end
local SessionID
if Run:IsEdit() then
	SessionID = Utils:MakeID()
	Data:Save("LastSessionID",SessionID)
end
SessionID = SessionID or Data:Load("LastSessionID")

--------------
--Main Ui
--------------
--// 플러그인 로드시간(총합 시간 계산용)
local PluginStartTime = tick()
local Main
local Refresh
function LoadGui()
	--// UI 개채를 담을곳
	local Store = {}
	
	--// 이전의 UI 제거(태마 변경시, 클리어)
	Interface:ClearAllChildren()
	MaterialUI:CleanUp()
	
	--// 현재 태마 불러오기
	MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
	--// 위잿 등록
	MaterialUI:UseDockWidget(Interface,plugin:GetMouse())
	
	--// 시간 글씨 색상
	local TimeTextColor = MaterialUI.CurrentTheme == "Dark" and Color3.fromRGB(255,170,0) or Color3.fromRGB(200, 120, 0)
	
	--// UI 만들기
	MaterialUI.Create("Frame",{
		Parent = Interface;
		Name = "Main";
		BackgroundColor3 = MaterialUI:GetColor("Background");
		Size = UDim2.new(1,0,1,0);
	},{
		--// 리스트 개체
		MaterialUI.Create("UIListLayout",{
			SortOrder = Enum.SortOrder.LayoutOrder;
			VerticalAlignment = Enum.VerticalAlignment.Center;
		});
		--// 이번 세션 시간 표시자 해더
		MaterialUI.Create("TextLabel",{
			Name = "SessionTimeLabel_Header";
			LayoutOrder = 1;
			Size = UDim2.new(1,0,0,24);
			BackgroundTransparency = 1;
			TextColor3 = MaterialUI:GetColor("TextColor");
			Text = Language:GetText("Session_time");
			TextSize = 20;
			Font = Enum.Font.GothamBold;
		});
		--// 이번 세션 시간 표시자 푸터
		MaterialUI.Create("TextLabel",{
			Name = "SessionTimeLabel_Footer";
			LayoutOrder = 2;
			Size = UDim2.new(1,0,0,22);
			BackgroundTransparency = 1;
			TextColor3 = TimeTextColor;
			Text = "";
			TextSize = 18;
			Font = Enum.Font.Gotham;
		},nil,function(this)
			Store.SessionTimeLabel = this
		end);
		--// 위 아래 나누는 디바이더
		MaterialUI.Create("Frame",{
			Name = "DivHeader";
			Size = UDim2.new(1,0,0,12);
			LayoutOrder = 3;
			BackgroundTransparency = 1;
		},{
			MaterialUI.Create("Frame",{
				Name = "Div";
				LayoutOrder = 3;
				Size = UDim2.new(1,-34,0,1);
				Position = UDim2.new(0.5,0,0.5,0);
				AnchorPoint = Vector2.new(0.5,0.5);
				BackgroundColor3 = MaterialUI:GetColor("TextColor");
				BackgroundTransparency = 0.75;
			});
		});
		--// 합계 시간 해더
		MaterialUI.Create("TextLabel",{
			Name = "SummationTimeLabel_Header";
			LayoutOrder = 4;
			Size = UDim2.new(1,0,0,24);
			BackgroundTransparency = 1;
			TextColor3 = MaterialUI:GetColor("TextColor");
			Text = Language:GetText("Summation_time");
			TextSize = 20;
			Font = Enum.Font.GothamBold;
		});
		--// 합계 시간 푸터
		MaterialUI.Create("TextLabel",{
			Name = "SummationTimeLabel_Footer";
			LayoutOrder = 5;
			Size = UDim2.new(1,0,0,22);
			BackgroundTransparency = 1;
			TextColor3 = TimeTextColor;
			Text = "";
			TextSize = 18;
			Font = Enum.Font.Gotham;
		},nil,function(this)
			Store.SummationTimeLabel = this
		end);
	})
	
	--// 실제로 시간을 표시하는데 쓰이는 함수
	Refresh = function(now)
		local now = now
		local Sum = Data:Load("SummationTime") + (now - PluginStartTime)
		local Elp = elapsedTime()
		--// 오류는 무시하세요 (os 와는 조금 다른 용도)
		--// elapsedTime 는 현재 세션이 몇초동안 켜져있었는지 반환합니다
		--// (플러그인 시작 기점이 아닌 이 장소가 열린 시점 기준)
		
		local SumTimeTable = Utils:TickToTime(Sum)
		local SumSeconds = tostring(SumTimeTable.Seconds)
		local SumMinutes = tostring(SumTimeTable.Minutes)
		Store.SummationTimeLabel.Text = ("%s:%s"):format(
			tostring(SumTimeTable.Hours),
			#SumMinutes >= 2 and SumMinutes or ("0" .. SumMinutes)
			--#SumSeconds >= 2 and SumSeconds or ("0" .. SumSeconds)
		)
		
		local ElpTimeTable = Utils:TickToTime(Elp)
		local ElpSeconds = tostring(ElpTimeTable.Seconds)
		local ElpMinutes = tostring(ElpTimeTable.Minutes)
		Store.SessionTimeLabel.Text = ("%s:%s:%s"):format(
			tostring(ElpTimeTable.Hours),
			#ElpMinutes >= 2 and ElpMinutes or ("0" .. ElpMinutes),
			#ElpSeconds >= 2 and ElpSeconds or ("0" .. ElpSeconds)
		)
	end
end

--// 처음로드
LoadGui()

--// 태마 바뀜 감지
settings().Studio.ThemeChanged:Connect(LoadGui)

--// 다른 창에서 실행되고 있을때, 중복 실행을 막음
function StopPlugin(MsgID,ClickFn)
	local ErrorText = Language:GetText(MsgID or "Unknow error")
	
	MaterialUI.Create("TextButton",{
		Parent = Interface;
		Name = "Stopped";
		BackgroundColor3 = MaterialUI:GetColor("Background");
		Size = UDim2.new(1,0,1,0);
		BackgroundTransparency = 0.35;
		ZIndex = 80;
		AutoButtonColor = false;
		Text = "";
	},{
		Box = MaterialUI.Create("ImageLabel",{
			BackgroundTransparency = 1;
			ImageTransparency = 0.2;
			ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.BackgroundHighLight);
			Size = UDim2.new(0,290,0,80);
			Position = UDim2.new(0.5,0,0.5,0);
			AnchorPoint = Vector2.new(0.5,0.5);
			ZIndex = 80;
		},{
			Icon = MaterialUI.Create("ImageLabel",{
				BackgroundTransparency = 1;
				Image = "rbxassetid://3944668821";
				ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Size = UDim2.new(0,50,0,50);
				Position = UDim2.new(0,20,0.5,0);
				AnchorPoint = Vector2.new(0,0.5);
				ZIndex = 80;
			});
			Text = MaterialUI.Create("TextLabel",{
				BackgroundTransparency = 1;
				Text = ErrorText;
				TextSize = 12;
				Size = UDim2.new(1,-50-20,1,0);
				Position = UDim2.new(1,0,0,0);
				AnchorPoint = Vector2.new(1,0);
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				ZIndex = 80;
				TextWrapped = true;
			});
		},function(this)
			MaterialUI:SetRound(this,15)
		end);
	},function(This)
		if ClickFn then
			This.MouseButton1Click:Connect(function()
				ClickFn(This)
			end)
		end
	end)
end

--StopPlugin("Test")

--// 시간 저장 함수 지정
local function SaveTime(now)
	local Time = Data:Load("SummationTime") + (now - PluginStartTime)
	Data:Save("SummationTime",math.floor(Time))
	PluginStartTime = now
end

--// 개속해서 반복해서 시간 업데이트
--// (새로운 쓰래드 생성)
spawn(function()
	local SaveCoolTime = tick() + 60
	while true do
		local now = tick()
		local Save = SaveCoolTime < now
		SaveCoolTime = Save and now + 60 or SaveCoolTime
		
		if Save then
			--// 만약 다른 세션이 켜진경우(다른 창이 열린경우) 현재 창을 멈춤
			if Data:ForceLoad("LastSessionID") ~= SessionID then
				StopPlugin("RunningInOtherWindow",function(UI)
					SessionID = Utils:MakeID()
					Data:Save("LastSessionID",SessionID)
					UI:Destroy()
				end)
				break
			end
			
			--// 60 초 마다 저장(갑자기 팅기는거 방지해서)
			SaveTime(now)
		end
		
		if Refresh then
			Refresh(now)
		end
	wait(0.5) end
end)

--------------
--Command
--------------
--// 명령줄에서(명령 실행)

-- _G.StdTimer:ResetSum()
	--이 플러그인을 초기화시킴, elapsedTime 는 로블록스 내장함수라 세션타임은 못바꿈
-- _G.StdTimer:SetSum(Seconds)
	--통계 시간을 Seconds 로 바꿈(초)
-- _G.StdTimer:GetSum()
	--통계시간을 돌려줌

local GlobalTable = {}
_G.StdTimer = GlobalTable

function GlobalTable:ResetSum()
	Data:Save("SummationTime",fl(elapsedTime()))
	PluginStartTime = tick()
	
	return true
end
function GlobalTable:SetSum(Seconds)
	Data:Save("SummationTime",Seconds)
	PluginStartTime = tick()
	
	return true
end
function GlobalTable:GetSum()
	return Data:Load("SummationTime") + (tick() - PluginStartTime)
end

--------------
--Unload
--------------
--// 플러그인 언로드 이벤트
function Unload()
	pcall(function()
		SaveTime(tick()) --// 플러그인 꺼지기 전 저장
		Refresh = nil
	end)
end
plugin.Unloading:Connect(Unload)