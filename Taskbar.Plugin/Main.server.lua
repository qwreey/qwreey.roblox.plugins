local plugin = plugin
if not plugin then
	--// 플러그인이 아닌데 이 코드가 실행되면 바로 멈춰줌(태스팅 모드에서)
	return
end

local AppInfo = {
	-- APP INFO
	["AppIcon"] = "http://www.roblox.com/asset/?id=6007972232";
	["AppIconLight"] = "http://www.roblox.com/asset/?id=6007972463"; -- for toolbar light mode
	["AppName"] = "Taskbar";
	["AppId"] = "qwreey.plugins.taskbar";
	
	-- PLUGIN GROUP
	["ToolbarId"] = "qwreey.plugins.toolbarprovider";
	["ToolbarName"] = "Qwreey's plugins";
	
	--BUTTON
	["ButtonText"] = "Task bar";
	["ButtonHoverText"] = nil;
	
	-- INTERFACE
	["InterfaceMiniSize"] = {X=150,Y=36};
	["InterfaceInitSize"] = {X=220,Y=300};
	["InterfaceDefaultFace"] = Enum.InitialDockState.Bottom;
	
	-- OTHER
	["Version"] = 2;
	["SplashIconSize"] = UDim2.new(0,70,0,70);
	["BypassSplash"] = true;
}

--------------
--import
--------------
--// 로블록스 서비스 불러오기(import)
local PluginGuiService = game:GetService("PluginGuiService")
local TextService = game:GetService("TextService")

--// 모듈 불러오기
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

--------------
--Main Ui
--------------
local void = function()end
local AppFont = Enum.Font.Gotham

local FocusedEffectColor = Color3.fromRGB(20,170,255)
local FocusedFrameThickness = 16;

local Button_MouseFocusedScale = 1.1
local Button_MouseDownScale = 0.8
local Button_IdleScale = 1
local Button_MarginX = 14
local Button_SizeY = 26
local Button_TextSize = 14

local BLinePadding = 34

local ButtonZIndex = 10
local ShadowZIndex = 20
local BLineZIndex = 30

local LastFocusWindow = nil;
local Buttons = {}

local AddToScroll = void

--// 버튼 눌렀을때 해당 창에 포커스되는 효과
function RunFocusedEffect(PluginGui)
	local New = MaterialUI.Create("Frame",{
		Size = UDim2.new(1,0,1,0);
		BackgroundTransparency = 1;
		ZIndex = 2147483647;
	},{
		Left = MaterialUI.Create("Frame",{
			ZIndex = 2147483647;
			BackgroundColor3 = FocusedEffectColor;
			Size = UDim2.new(0,FocusedFrameThickness,1,0);
		});
		Right = MaterialUI.Create("Frame",{
			ZIndex = 2147483647;
			BackgroundColor3 = FocusedEffectColor;
			Size = UDim2.new(0,FocusedFrameThickness,1,0);
			Position = UDim2.new(1,0,0,0);
			AnchorPoint = Vector2.new(1,0);
		});
		Bottom = MaterialUI.Create("Frame",{
			ZIndex = 2147483647;
			BackgroundColor3 = FocusedEffectColor;
			Size = UDim2.new(1,0,0,FocusedFrameThickness);
		});
		Top = MaterialUI.Create("Frame",{
			ZIndex = 2147483647;
			BackgroundColor3 = FocusedEffectColor;
			Size = UDim2.new(1,0,0,FocusedFrameThickness);
			Position = UDim2.new(0,0,1,0);
			AnchorPoint = Vector2.new(0,1);
		});
	});
	
	New.Parent = PluginGui
	
	local TweenData = {
		Time = 0.4;
		Easing = AdvancedTween.EasingFunctions.Exp2;
		Direction = AdvancedTween.EasingDirection.Out;
	}
	
	--AdvancedTween:RunTweens({New.Left,New.Right,New.Bottom,New.Top},TweenData,{
	--	BackgroundTransparency = 1;
	--	--Size = UDim2.new(0,0,0,0);
	--})
	
	AdvancedTween:RunTweens({New.Left,New.Right},TweenData,{
		Size = UDim2.new(0,0,1,0)
	})
	AdvancedTween:RunTweens({New.Top,New.Bottom},TweenData,{
		Size = UDim2.new(1,0,0,0)
	})
	
	delay(0.4,function()
		New:Destroy()
	end)
end

function AddButton(Window)
	if Window == Interface then
		return
	end
	
	local this = {
		Connection = {};
		Scale = nil;
	}
	
	this.Window = Window
	this.Button = MaterialUI.Create("TextButton",{
		NotTagging = true;
		Parent = script.tmp;
		Name = "ItemFrame";
		BackgroundColor3 = Color3.fromRGB(128, 128, 128);
		BackgroundTransparency = 1;
		Size = UDim2.new(0,40,0,Button_SizeY);
		Text = "";
		AutoButtonColor = false;
		ZIndex = ButtonZIndex;
		MouseButton1Click = function()
			LastFocusWindow = this.Window
			this.Window.Enabled = false
			RunFocusedEffect(this.Window)
		end;
		MouseEnter = function()
			AdvancedTween:RunTween(this.Scale,{
				Time = 0.2;
				Easing = AdvancedTween.EasingFunctions.Exp2;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				Scale = Button_MouseFocusedScale;
			})
		end;
		MouseLeave = function()
			AdvancedTween:RunTween(this.Scale,{
				Time = 0.2;
				Easing = AdvancedTween.EasingFunctions.Exp2;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				Scale = Button_IdleScale;
			})
		end;
		MouseButton1Down = function()
			AdvancedTween:RunTween(this.Scale,{
				Time = 0.5;
				Easing = AdvancedTween.EasingFunctions.Exp2;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				Scale = Button_MouseDownScale;
			})
		end;
		MouseButton1Up = function()
			AdvancedTween:RunTween(this.Scale,{
				Time = 0.35;
				Easing = AdvancedTween.EasingFunctions.Exp2;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				Scale = Button_MouseFocusedScale;
			})
		end;
	},{
		Round = MaterialUI.Create("ImageLabel",{
			NotTagging = true;
			AnchorPoint = Vector2.new(0.5, 0.5);
			BackgroundTransparency = 1;
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(1, 0, 1, 0);
			ImageColor3 = Color3.fromRGB(128, 128, 128);
			ImageTransparency = 0.5;
			ZIndex = ButtonZIndex;
			WhenCreated = function(new)
				MaterialUI:SetRound(new,8)
			end;
		},{
			TextLabel = MaterialUI.Create("TextLabel",{
				NotTagging = true;
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				BackgroundTransparency = 1;
				Size = UDim2.new(1,0,1,0);
				ZIndex = ButtonZIndex;
				Font = AppFont;
				Text = "";
				TextColor3 = Color3.fromRGB(255, 255, 255);
				TextSize = Button_TextSize;
			});
			Scale = MaterialUI.Create("UIScale",{
				NotTagging = true;
				Scale = 1;
				WhenCreated = function(new)
					this.Scale = new
				end;
			});
		});
	},function(this)
		AddToScroll(this)
	end);
	
	--// 숨기기/보이기 리프래싱
	this.EnabledRefresh = function()
		if LastFocusWindow == this.Window then
			wait()
			LastFocusWindow = nil
			this.Window.Enabled = true
			return
		end
		
		this.Button.Visible = this.Window.Enabled
	end
	this.Connection.EnabledChanged = this.Window:GetPropertyChangedSignal("Enabled"):Connect(this.EnabledRefresh)
	this.EnabledRefresh()
	
	--// 글자 리프래싱
	this.ButtonTextRefresh = function()
		this.Button.Round.TextLabel.Text = this.Window.Title
		this.Button.Size = UDim2.new(
			0,
			TextService:GetTextSize(
				this.Window.Title,
				Button_TextSize,
				AppFont,
				Vector2.new(math.huge,math.huge)
			).X + Button_MarginX,
			0,
			Button_SizeY
		)
	end
	this.Connection.TitleChanged = this.Window:GetPropertyChangedSignal("Title"):Connect(this.ButtonTextRefresh)
	this.ButtonTextRefresh()
	
	Buttons[Window] = this
	return this
end
function RemoveButton(Window)
	if Window == Interface then
		return
	elseif not Buttons[Window] then
		return
	end
	local this = Buttons[Window]
	
	this.Button:Destroy()
	for i,Connection in pairs(this.Connection) do
		if not Connection then
			return
		end
		Connection:Disconnect()
		this.Connection[i] = nil
	end
	Buttons[Window] = nil
	this = nil
end
PluginGuiService.ChildAdded:Connect(AddButton)
PluginGuiService.ChildRemoved:Connect(RemoveButton)

for _,Window in pairs(PluginGuiService:GetChildren()) do
	AddButton(Window)
end

function LoadGui()
	for _,Button in pairs(Buttons) do
		Button.Button.Parent = script.tmp
	end
	
	--// UI 개채를 담을곳
	local Store = {
		ListLayout = nil;
		BLine = nil;
		Scroll = nil;
		Main = nil;
	}
	
	--// 이전의 UI 제거(태마 변경시, 클리어)
	Interface:ClearAllChildren()
	MaterialUI:CleanUp()
	
	--// 현재 태마 불러오기
	MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
	--// 위잿 등록
	MaterialUI.UseDockWidget(Interface,plugin:GetMouse())
	
	--// UI 만들기
	MaterialUI.Create("Frame",{
		Parent = Interface;
		Name = "Main";
		BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
		Size = UDim2.new(1,0,1,0);
		WhenCreated = function(this)
			Store.Main = this
		end;
	},{
		--// 버튼 담기는 스크롤
		Scroll = MaterialUI.Create("ScrollingFrame",{
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,1,0);
			ScrollBarThickness = 0;
			WhenCreated = function(this)
				AddToScroll = function(new)
					new.Parent = this
				end
				Store.Scroll = this
			end;
		},{
			ListLayout = MaterialUI.Create("UIListLayout",{
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Center;
				SortOrder = Enum.SortOrder.LayoutOrder;
				VerticalAlignment = Enum.VerticalAlignment.Center;
				Padding = UDim.new(0, 6);
			},nil,function(this)
				Store.ListLayout = this
				
				this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					if not Store.Scroll then
						return
					end
					
					Store.Scroll.CanvasSize = UDim2.new(
						0,
						this.AbsoluteContentSize.X,
						0,
						0
					)
				end)
			end);
		});
		Padding = MaterialUI.Create("UIPadding",{
			PaddingBottom = UDim.new(0, 4);
		});
		
		--// 옆쪽 그림자
		LShadow = MaterialUI.Create("ImageLabel",{
			BackgroundTransparency = 1;
			Size = UDim2.new(0,80,1,0);
			Position = UDim2.new(0,0,0,0);
			AnchorPoint = Vector2.new(0.5,0);
			ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
			Image = "http://www.roblox.com/asset/?id=3952381184";
			ZIndex = ShadowZIndex;
		});
		RShadow = MaterialUI.Create("ImageLabel",{
			BackgroundTransparency = 1;
			Size = UDim2.new(0,80,1,0);
			Position = UDim2.new(1,0,0,0);
			AnchorPoint = Vector2.new(0.5,0);
			ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
			Image = "http://www.roblox.com/asset/?id=3952381184";
			ZIndex = ShadowZIndex;
		});
		
		--// 아랫쪽 라인(데코)
		BLine = MaterialUI.Create("Frame",{
			AnchorPoint = Vector2.new(0.5,0.5);
			BackgroundColor3 = Color3.fromRGB(128,128,128);
			BorderSizePixel = 0;
			Position = UDim2.new(0.5,0,0.5,16);
			Size = UDim2.new(0,50,0,1);
			ZIndex = BLineZIndex;
			WhenCreated = function(this)
				Store.BLine = this
			end;
		});
	})
	
	--// 이전 버튼 가져오기
	for _,Button in pairs(Buttons) do
		Button.Button.Parent = Store.Scroll
		
		--// 태마 적용
		Button.Button.Round.TextLabel.TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
	end
	
	--// 바텀라인 크기 리프레시
	local function BLineSizeRefresh()
		Store.BLine.Size = UDim2.new(
			0,
			math.min(
				Store.Main.AbsoluteSize.X - BLinePadding,
				Store.ListLayout.AbsoluteContentSize.X
			),
			0,
			1
		)
	end
	Store.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(BLineSizeRefresh)
	Store.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(BLineSizeRefresh)
	BLineSizeRefresh()
end

--// 처음로드
LoadGui()

--// 태마 바뀜 감지
settings().Studio.ThemeChanged:Connect(LoadGui)

--------------
--Unload
--------------
--// 플러그인 언로드 이벤트
function Unload()
	pcall(function()
		
	end)
end
plugin.Unloading:Connect(Unload)