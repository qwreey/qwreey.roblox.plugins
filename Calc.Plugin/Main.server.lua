local plugin = plugin
if not plugin then
	--// 플러그인이 아닌데 이 코드가 실행되면 바로 멈춰줌(태스팅 모드에서)
	return
end

local AppInfo = {
	-- APP INFO
	["AppIcon"] = "http://www.roblox.com/asset/?id=5958222005";
	["AppIconLight"] = "http://www.roblox.com/asset/?id=5958222203"; -- for toolbar light mode
	["AppName"] = "Calc";
	["AppId"] = "qwreey.plugins.calc";
	
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
	["Version"] = 2;
	["SplashIconSize"] = UDim2.new(0,70,0,70);
	["BypassSplash"] = false;
}

--------------
--import
--------------
--// 로블록스 서비스 불러오기(import)
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")
game = nil

--// 모듈 불러오기
local MaterialUI = require(script.lib.MaterialUI)
local Data = require(script.lib.Data):SetUp(plugin)
local AdvancedTween = require(script.lib.AdvancedTween)
local ToolbarCombiner = require(script.lib.ToolbarCombiner)

local Calc = require(script.res.Calc)
local UI = require(script.res.UI)
local InputHandle = require(script.res.InputHandle)

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

--// 예전 값 가져오기/ 저장하기 함수
do
	local LastRadMode = Data:Load("IsRadMode")
	Calc.SetRadMode(LastRadMode ~= nil and LastRadMode or true)
	Calc.SaveFn.SaveRadMode = function(Value)
		Data:Save("IsRadMode",Value)
	end
end

--------------
--Main Ui
--------------
local Ripplers = {}
local UnLoadUI
function LoadGui()
	--// 이전 UI 언로드
	if UnLoadUI then
		UnLoadUI()
	end
	
	--// UI 만들기
	UnLoadUI = UI:init(Calc,Ripplers,Interface,plugin,{
		Calc = Calc,
		MaterialUI = MaterialUI,
		AdvancedTween = AdvancedTween,
		Data = Data;
	})
	
	--// 키연동
	InputHandle:init(Calc,Ripplers,Interface)
end

--// 처음로드
LoadGui()

--// 태마 바뀜 감지
settings().Studio.ThemeChanged:Connect(LoadGui)

--------------
--Unload
--------------
function Unload()
	pcall(function()
		--// 플러그인 언로드 이벤트
	end)
end
plugin.Unloading:Connect(Unload)