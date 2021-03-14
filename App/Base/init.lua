local module = {}

local ContentProvider = game:GetService("ContentProvider")

local EventDay = require(script.EventDay)

function module:init(plugin,AppInfo,Modules)
	local ReturnData = {}
	
	local AdvancedTween = Modules.AdvancedTween
	local MaterialUI = Modules.MaterialUI
	local ToolbarCombiner = Modules.ToolbarCombiner
	local Language = Modules.Language
	
	--// 플긴 아이콘 프리로드
	ContentProvider:PreloadAsync({AppInfo.AppIcon,AppInfo.AppIconLight})
	
	--// 플러그인 창 만들기
	local Interface = plugin:CreateDockWidgetPluginGui(
		AppInfo.AppId,
		DockWidgetPluginGuiInfo.new(
			AppInfo.InterfaceDefaultFace,
			true,
			false,
			AppInfo.InterfaceInitSize.X,
			AppInfo.InterfaceInitSize.Y,
			AppInfo.InterfaceMiniSize.X,
			AppInfo.InterfaceMiniSize.Y
		)
	)
	Interface.Title = AppInfo.AppName
	Interface.Name = AppInfo.AppName
	
	--// 플러그인 툴바(맨 위에 플러그인창) 만들기
	local Toolbar = ToolbarCombiner:CreateToolbar(AppInfo.ToolbarName,AppInfo.ToolbarId)
	local Theme = tostring(settings().Studio.Theme)
	
	--// 공유 UI 빌드하기
	local SharedUIModule = require(script.SharedUI)
	local SharedUI,SettingsHandle = SharedUIModule:init({
		AdvancedTween = AdvancedTween;
		MaterialUI = MaterialUI;
		Toolbar = Toolbar;
		plugin = plugin;
		AppInfo = AppInfo;
		Language = Language;
	})
	
	--// 툴바에 버튼 추가
	local OpenBtn = Toolbar:CreateButton(
		AppInfo.AppId, --// 버튼 ID
		AppInfo.ButtonHoverText or ("Open %s Window"):format(AppInfo.AppName), --// 마우스가 위에 있을때 뜰 글자
		Theme == "Dark" and AppInfo.AppIcon or AppInfo.AppIconLight, --// 버튼 아이콘
		AppInfo.ButtonText or AppInfo.AppName --// 버튼에 쓰일 글자
	)
	
	--// 버튼 아이콘의 색상을 태마와 일치시킴 (배경이 검정이면 흰색으로)
	local function RefreshButtonIcon()
		Theme = tostring(settings().Studio.Theme)
		OpenBtn.Icon = ""
		wait()
		OpenBtn.Icon = Theme == "Dark" and AppInfo.AppIcon or AppInfo.AppIconLight
	end
	settings().Studio.ThemeChanged:Connect(RefreshButtonIcon)
	
	--// 버튼 클릭 이벤트
	OpenBtn.Click:connect(function()
		Interface.Enabled = not Interface.Enabled
	end)
	
	--// 버튼이 코드 편집기 창과 같이, 다른 창에 있어도 작동하도록 함
	OpenBtn.ClickableWhenViewportHidden = true
	
	--// 버튼이 눌린가를 UI 의 보이기로 설정
	local function Refresh_OpenBtn_Active()
		wait()
		OpenBtn:SetActive(Interface.Enabled)
	end
	Interface:GetPropertyChangedSignal("Enabled"):Connect(Refresh_OpenBtn_Active)
	Refresh_OpenBtn_Active()
	
	--// 플러그인이 삭제되면 버튼을 클릭하지 못하도록 설정
	plugin.Unloading:Connect(function()
		OpenBtn.Enabled = false
	end)
	
	--// 스플레시 스크린
	local function SplashScreen()
		if (not Interface.Enabled) or (AppInfo.BypassSplash) then
			return
		end
		
		local Splash = MaterialUI.Create("TextButton",{
			AutoButtonColor = false;
			Text = "";
			Parent = Interface;
			Size = UDim2.fromScale(1,1);
			BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
			ZIndex = 20000;
		},{
			Icon = MaterialUI.Create("ImageLabel",{
				Size = AppInfo.SplashIconSize;
				Position = UDim2.new(0.5,0,0.5,0);
				AnchorPoint = Vector2.new(0.5,0.5);
				Image = AppInfo.AppIcon;
				ZIndex = 20000;
				BackgroundTransparency = 1;
				ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
			})
		})
		
		delay(0.3,function()
			AdvancedTween:RunTween(Splash.Icon,{
				Time = 0.18;
				Easing = AdvancedTween.EasingFunctions.Linear;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				ImageTransparency = 1;
			})
			AdvancedTween:RunTween(Splash,{
				Time = 0.18;
				Easing = AdvancedTween.EasingFunctions.Linear;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				BackgroundTransparency = 1;
			},function()
				Splash:Destroy()
			end)
		end)
	end
	Interface:GetPropertyChangedSignal("Enabled"):Connect(SplashScreen)
	
	ReturnData.Interface = Interface
	ReturnData.ToolbarButton = OpenBtn
	
	ReturnData.SharedUI = SharedUI
	ReturnData.SettingsHandle = SettingsHandle
	
	EventDay:Setup(Interface,MaterialUI,AdvancedTween)
	
	return ReturnData
end

return module