local plugin = plugin
if not plugin then
	--// 플러그인이 아닌데 이 코드가 실행되면 바로 멈춰줌(태스팅 모드에서)
	return
end

local AppInfo = {
	-- APP INFO
	["AppIcon"] = "http://www.roblox.com/asset/?id=6022668884";
	["AppIconLight"] = "http://www.roblox.com/asset/?id=6194153380"; -- for toolbar light mode
	["AppName"] = "Profiler";
	["AppId"] = "qwreey.plugins.profiler";
	
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
local PluginGuiInput = require(script.lib.PluginGuiInput)
local CustomScroll = require(script.lib.CustomScroll)

local License = require(script.License)
local LicenseViewer = require(script.res.LicenseViewer)
local View = require(script.res.View)

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

-- 마우스 생성
MaterialUI:UseDockWidget(Interface,plugin:GetMouse())
-- 테마 등록
MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
-- 인풋 서비스 불러오기
local PluginGuiInput = PluginGuiInput:init(Interface)

-- CustomScroll init
CustomScroll.init({
	["AdvancedTween"] = AdvancedTween;
	["UserInputService"] = PluginGuiInput;
})

--// 라이선스 뷰어 Init
LicenseViewer:Init(App.SettingsHandle,MaterialUI,License,Language)
View:Init({
	Plugin = plugin;
	Interface = Interface;
	SettingsHandle = App.SettingsHandle;
	MaterialUI = MaterialUI;
	Language = Language;
	AdvancedTween = AdvancedTween;
	PluginGuiInput = PluginGuiInput;
	CustomScroll = CustomScroll;
})

--------------
--Data
--------------


--------------
--Unload
--------------
--// 플러그인 언로드 이벤트
--function Unload()
--end
--plugin.Unloading:Connect(Unload)