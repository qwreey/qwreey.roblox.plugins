local module = {}

--// 총 합 shared[AppInfo.ToolbarId] 의 내용
--// Table = {
--//    ProviderPlugin = plugin;   => instance : 그룹 제공자 플러그인
--//    Toolbar        = toolbar;  => instance : 그룹 제공자로 만들어진 툴바 홀더
--//    CreateButton   = function; => function : 툴바에 버튼을 추가하는 함수
--//    Saved          = {items};  => table    : 툴바에 추가된 버튼들
--//    + (이 코드로 추가되는것)
--//    SharedUI = {
--//       Interface      = DockWidget   ; => instance : 위젯
--//       Button         = ToolbarButton; => instance : 툴바 버튼
--//       MainPage_Store = table        ; => table    : 설정 UI
--//       MaterialUI     = table        ; => table    : 공유된 UI 라이브러리
--//    };
--// }

local AppInfo = {
	--BUTTON
	["ButtonText"] = "Plugin Settings";
	
	--APP INFO
	["AppName"] = "Qwreey's plugin settings";
	["AppId"] = "qwreey.plugins.settingsprovider";
	["AppIcon"] = "http://www.roblox.com/asset/?id=6012012906";
}

local Theme = tostring(settings().Studio.Theme)
local MainPageZIndex = -40
local PluginPageZIndex = -20

function module:MainPageRefreshTheme(MaterialUI,Store)
	MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
	
	--// 맨 최상위 프레임
	Store.MainPage.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background)
	--// 맨 위의 바
	Store.TopBar.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar)
end

function module:setup(SharedUI,Data,plugin)
	local SettingsHandle = {}
	
	local thisplugin = Data.plugin
	local thisAppInfo = Data.AppInfo
	
	local MainPageStore = SharedUI.MainPage_Store
	local AdvancedTween = Data.AdvancedTween
	local Language = Data.Language
	
	local MouseIsLoadedByThisPlugin = false
	
	--// MaterialUI 불러오기
	local MaterialUI = Data.MaterialUI--SharedUI.Interface:FindFirstChild("MaterialUI")-- or Data.MaterialUI.script:Clone()
	--MaterialUI.Parent = SharedUI.Interface
	--MaterialUI = require(MaterialUI)
	
	MaterialUI.CurrentTheme = Theme
	local Mouse = MaterialUI:UseDockWidget(SharedUI.Interface,plugin:GetMouse())
	--if not SharedUI.Interface:FindFirstChild("DockWidgetMouseTracker") then
		
	--	MouseIsLoadedByThisPlugin = true
	--end
	
	--// 리스트 길이 리프레시
	local function RefreshList()
		MainPageStore.Scroll.CanvasSize = UDim2.new(0,0,0,MainPageStore.List.AbsoluteContentSize.Y)
	end
	MainPageStore.List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshList)
	RefreshList()
	
	--// 버튼 클릭(설정 버튼) 연결
	SharedUI.Button.Click:Connect(function()
		SharedUI.Interface.Enabled = true
		SharedUI.Interface.Title = AppInfo.AppName
		for _,Item in pairs(SharedUI.Interface:GetChildren()) do
			if Item:IsA("GuiBase") and Item.Name ~= "ClickIgnore" then
				Item.Visible = Item:IsA("TextButton") or Item.Name == "MainPage"
			end
		end
	end)
	
	--// 메인 페이지 테마링
	settings().Studio.ThemeChanged:Connect(function()
		module:MainPageRefreshTheme(MaterialUI,MainPageStore)
	end)
	
	--// 버튼 활성화 여부 리프레싱
	SharedUI.Interface:GetPropertyChangedSignal("Enabled"):Connect(function()
		wait()
		SharedUI.Button:SetActive(SharedUI.Interface.Enabled)
	end)
	
	--// 설정 프레임
	local SettingFrameStore = {}
	local SettingFrame
	SettingFrame = MaterialUI.Create("ImageButton",{
		Image = "";
		Parent = SharedUI.Interface;
		Name = thisAppInfo.AppId .. ".settings";
		Visible = false;
		BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
		NotTagging = true;
		Size = UDim2.new(1,0,1,0);
		AutoButtonColor = false;
		ZIndex = PluginPageZIndex;
		WhenCreated = function(this)
			settings().Studio.ThemeChanged:Connect(function()
				MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
				this.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background)
			end)
		end;
	},{
		MaterialUI.Create("Shadow",{
			ZIndex = PluginPageZIndex;
			NotTagging = true;
		});
		Holder = MaterialUI.Create("ScrollingFrame",{
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,1,-42);
			Position = UDim2.new(0,0,0,42);
			ScrollBarThickness = 4;
			BorderSizePixel = 0;
			NotTagging = true;
			CanvasSize = UDim2.new(0,0,0,0);
			ZIndex = PluginPageZIndex;
			WhenCreated = function(this)
				SettingFrameStore.Scroll = this
			end;
		},{
			List = MaterialUI.Create("UIListLayout",{
				NotTagging = true;
				WhenCreated = function(this)
					this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						SettingFrameStore.Scroll.CanvasSize = UDim2.new(0,0,0,this.AbsoluteContentSize.Y)
					end)
				end;
			});
		});
		TopbarHolder = MaterialUI.Create("Frame",{
			ClipsDescendants = true;
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,1,0);
			ZIndex = PluginPageZIndex;
			NotTagging = true;
		},{
			TopBar = MaterialUI.Create("Frame",{
				BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar);
				Size = UDim2.new(1,0,0,42);
				NotTagging = true;
				ZIndex = PluginPageZIndex;
				WhenCreated = function(this)
					settings().Studio.ThemeChanged:Connect(function()
						MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
						this.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar)
					end)
				end;
			},{
				Icon = MaterialUI.Create("IconButton",{
					ToolTipText = Language and Language:GetText("Back") or "Back";
					ToolTipVisible = true;
					ToolTipBackgroundColor3 = MaterialUI.CurrentTheme == "Dark" 
						and Color3.fromRGB(255,255,255)
						or  Color3.fromRGB(45,45,45);
					ToolTipTextColor3 = MaterialUI.CurrentTheme == "Dark" 
						and Color3.fromRGB(0,0,0)
						or  Color3.fromRGB(255,255,255);
					Icon = "rbxassetid://2777859585";
					IconColor3 = Color3.fromRGB(255,255,255);
					IconVisible = true;
					IconSizeScale = 0.85;
					Style = "WithOutBackground";
					Size = UDim2.fromOffset(36,36);
					Position = UDim2.new(0,3,0.5,0);
					AnchorPoint = Vector2.new(0,0.5);
					NotTagging = true;
					ZIndex = PluginPageZIndex+3;
					MouseButton1Click = function()
						SharedUI.Interface.Title = AppInfo.AppName
						--MainPageStore.ClickIgnore.Visible = true
						AdvancedTween:RunTween(SettingFrame,{
							Time = 0.4;
							Easing = AdvancedTween.EasingFunctions.Exp2;
							Direction = AdvancedTween.EasingDirection.Out;
						},{
							Position = UDim2.new(0,0,1,0);
						})
						wait(0.4)
						--MainPageStore.ClickIgnore.Visible = false
						SettingFrame.Visible = false
						SettingFrame.Size = UDim2.new(1,0,1,0)
					end;
					WhenCreated = function(this)
						settings().Studio.ThemeChanged:Connect(function()
							MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
							this.RippleColor3 = MaterialUI.Themes[MaterialUI.CurrentTheme].Rippler.RippleColor3
							this.ToolTipBackgroundColor3 = MaterialUI.CurrentTheme == "Dark" 
								and Color3.fromRGB(255,255,255)
								or  Color3.fromRGB(45,45,45)
							this.ToolTipTextColor3 = MaterialUI.CurrentTheme == "Dark" 
								and Color3.fromRGB(0,0,0)
								or  Color3.fromRGB(255,255,255)
						end)
					end;
				});
				Text = MaterialUI.Create("TextLabel",{
					Text = thisAppInfo.AppName .. " " .. (Language and Language:GetText("settings") or "settings");
					Size = UDim2.new(1,0,1,0);
					Position = UDim2.new(0,42,0,0);
					Font = Enum.Font.Gotham;
					TextSize = 16;
					TextColor3 = Color3.fromRGB(255,255,255);
					TextXAlignment = Enum.TextXAlignment.Left;
					BackgroundTransparency = 1;
					ZIndex = PluginPageZIndex;
					NotTagging = true;
				});
				Shadow = MaterialUI.Create("Shadow",{
					ZIndex = PluginPageZIndex+2;
					NotTagging = true;
				});
			});
		});
	})
	
	--// 설정 리스트 버튼 추가
	local ListButton
	ListButton = MaterialUI.Create("TextButton",{
		Name = thisAppInfo.AppId .. ".settings";
		BackgroundTransparency = 1;
		Size = UDim2.new(1,0,0,38);
		Text = "";
		Parent = MainPageStore.Scroll;
		ZIndex = MainPageZIndex+1;
		NotTagging = true;
		MouseButton1Click = function()
			SharedUI.Interface.Title = thisAppInfo.AppName .. " settings"
			--MainPageStore.ClickIgnore.Visible = true
			AdvancedTween:StopTween(SettingFrame)
			SettingFrame.Size = UDim2.new(1,0,0,38)
			SettingFrame.Position = UDim2.new(0,0,0,ListButton.AbsolutePosition.Y)
			SettingFrame.Visible = true
			AdvancedTween:RunTween(SettingFrame,{
				Time = 0.5;
				Easing = AdvancedTween.EasingFunctions.Exp2;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				Size = UDim2.new(1,0,1,0);
				Position = UDim2.new(0,0,0,0);
			})
			wait(0.5)
			--MainPageStore.ClickIgnore.Visible = false
		end;
	},{
		Div = MaterialUI.Create("Frame",{
			ZIndex = MainPageZIndex+1;
			BackgroundColor3 = Color3.fromRGB(127,127,127);
			BackgroundTransparency = 0.5;
			Size = UDim2.new(1,-40,0,1);
			Position = UDim2.new(0.5,0,0,-1);
			AnchorPoint = Vector2.new(0.5,0);
			NotTagging = true;
		});
		Rippler = MaterialUI.Create("Rippler",{
			ZIndex = MainPageZIndex+2;
			NotTagging = true;
			WhenCreated = function(this)
				settings().Studio.ThemeChanged:Connect(function()
					MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
					this.RippleColor3 = MaterialUI.Themes[MaterialUI.CurrentTheme].Rippler.RippleColor3
				end)
			end;
		});
		Icon = MaterialUI.Create("ImageLabel",{
			Size = UDim2.new(0,26,0,26);
			AnchorPoint = Vector2.new(0,0.5);
			Position = UDim2.new(0,6,0.5,0);
			Image = thisAppInfo.AppIcon;
			BackgroundTransparency = 1;
			ZIndex = MainPageZIndex+1;
			ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
			NotTagging = true;
			WhenCreated = function(this)
				settings().Studio.ThemeChanged:Connect(function()
					MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
					this.ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
				end)
			end;
		});
		Text = MaterialUI.Create("TextLabel",{
			Size = UDim2.new(1,0,1,0);
			Position = UDim2.new(0,38,0,0);
			Text = thisAppInfo.AppName .. " " .. (Language and Language:GetText("settings") or "settings");
			TextSize = 10;
			TextXAlignment = Enum.TextXAlignment.Left;
			BackgroundTransparency = 1;
			ZIndex = MainPageZIndex+1;
			TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
			NotTagging = true;
			WhenCreated = function(this)
				settings().Studio.ThemeChanged:Connect(function()
					MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
					this.TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
				end)
			end;
		});
	})
	
	--// 마우스 리프레시 연결
	--local MouseRefreshBind = SharedUI.MouseRefresh.Event:Connect(function()
	--	--// 가장 먼저 받는 플러그인이 마우스 호스터
	--	if SharedUI.MouseRefreshing or SharedUI.Interface:FindFirstChild("DockWidgetMouseTracker") then
	--		return
	--	end
	--	SharedUI.MouseRefreshing = true
	--	MouseIsLoadedByThisPlugin = true
		
	--	SharedUI.MouseRefreshing = false
	--end)
	
	--// 언로드
	thisplugin.Unloading:Connect(function()
		if ListButton then
			ListButton:Destroy()
		end
		if SettingFrame then
			SettingFrame:Destroy()
		end
		Mouse.Obj:Destroy()
		--if MouseIsLoadedByThisPlugin then
		--	MouseRefreshBind:Disconnect()
		--	if SharedUI.Interface:FindFirstChild("DockWidgetMouseTracker") then
		--		SharedUI.Interface:FindFirstChild("DockWidgetMouseTracker"):Destroy()
		--	end
		--	SharedUI.MouseRefresh:Fire()
		--end
	end)
	
	--// 리턴 패키징
	SettingsHandle.Frame = SettingFrame
	SettingsHandle.ListButton = ListButton
	SettingsHandle.Scroll = SettingFrameStore.Scroll
	
	--// 버튼 동작을 프레임 열기와 연결하기
	--//    Button : 클릭을 감지할 버튼
	--//    Frame  : 열릴 프레임
	function SettingsHandle:BindButton(Button,Frame)
		Button.MouseButton1Click:Connect(function()
			--MainPageStore.ClickIgnore.Visible = true
			AdvancedTween:StopTween(Frame)
			Frame.Size = UDim2.new(0,Button.AbsoluteSize.X,0,Button.AbsoluteSize.Y)
			Frame.Position = UDim2.new(0,Button.AbsolutePosition.X,0,Button.AbsolutePosition.Y)
			Frame.Visible = true
			AdvancedTween:RunTween(Frame,{
				Time = 0.5;
				Easing = AdvancedTween.EasingFunctions.Exp2;
				Direction = AdvancedTween.EasingDirection.Out;
			},{
				Size = UDim2.new(1,0,1,0);
				Position = UDim2.new(0,0,0,0);
			})
			wait(0.5)
			--MainPageStore.ClickIgnore.Visible = false
		end)
	end
	
	--// 뒤로가기 액션
	--//    Frame : 닫힐 프레임
	function SettingsHandle:Back(Frame)
		--MainPageStore.ClickIgnore.Visible = true
		AdvancedTween:RunTween(Frame,{
			Time = 0.4;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Position = UDim2.new(0,0,1,0);
		})
		wait(0.4)
		--MainPageStore.ClickIgnore.Visible = false
		Frame.Visible = false
		Frame.Size = UDim2.new(1,0,1,0)
	end
	
	--// 버튼 새로 만들기
	--//    ZIndex      : ZIndex 값
	--//    Icon        : 버튼 아이콘
	--//    Text        : 버튼에 쓰일 글자
	--//    LayoutOrder : 리스트 줄
	--//    Parent      : 버튼의 상위 트리 (ZIndex 가 없으면 이 개체의 ZIndex + 1 됨)
	function SettingsHandle:AddNewButton(Data)
		local Data = Data or {}
		
		local Icon = Data.Icon or ""
		local Text = Data.Text or "setting"
		local LayoutOrder = Data.LayoutOrder or 0
		local Parent = Data.Parent or SettingFrameStore.Scroll
		local ZIndex = Data.ZIndex or (Parent and Parent.ZIndex + 1 or PluginPageZIndex)
		
		return MaterialUI.Create("TextButton",{
			LayoutOrder = LayoutOrder;
			Name = Text;
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,0,38);
			Text = "";
			Parent = Parent;
			ZIndex = ZIndex+1;
			NotTagging = true;
		},{
			Div = MaterialUI.Create("Frame",{
				BackgroundColor3 = Color3.fromRGB(127,127,127);
				BackgroundTransparency = 0.5;
				Size = UDim2.new(1,-40,0,1);
				Position = UDim2.new(0.5,0,0,-1);
				AnchorPoint = Vector2.new(0.5,0);
				ZIndex = ZIndex+1;
				NotTagging = true;
			});
			Rippler = MaterialUI.Create("Rippler",{
				ZIndex = ZIndex+2;
				NotTagging = true;
				WhenCreated = function(this)
					settings().Studio.ThemeChanged:Connect(function()
						MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
						this.RippleColor3 = MaterialUI.Themes[MaterialUI.CurrentTheme].Rippler.RippleColor3
					end)
				end;
			});
			Icon = MaterialUI.Create("ImageLabel",{
				Visible = Icon ~= nil;
				Size = UDim2.new(0,26,0,26);
				AnchorPoint = Vector2.new(0,0.5);
				Position = UDim2.new(0,6,0.5,0);
				Image = Icon;
				BackgroundTransparency = 1;
				ZIndex = ZIndex+1;
				ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				NotTagging = true;
				WhenCreated = function(this)
					settings().Studio.ThemeChanged:Connect(function()
						MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
						this.ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
					end)
				end;
			});
			Text = MaterialUI.Create("TextLabel",{
				Size = UDim2.new(1,0,1,0);
				Position = UDim2.new(0,Icon ~= "" and 38 or 12,0,0);
				Text = Text;
				TextSize = 10;
				TextXAlignment = Enum.TextXAlignment.Left;
				BackgroundTransparency = 1;
				ZIndex = ZIndex+1;
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				NotTagging = true;
				WhenCreated = function(this)
					settings().Studio.ThemeChanged:Connect(function()
						MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
						this.TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
					end)
				end;
			});
		})
	end
	
	--// 페이지 새로 만들기
	--//    ZIndex     : ZIndex 값
	--//    OpenButton : 버튼
	--//    Text       : 위에 적힐 글자
	--//    Parent     : 페이지의 상위 트리
	function SettingsHandle:AddNewPage(Data)
		local Data = Data or {}
		
		local Parent = Data.Parent or SettingFrame
		local Text = Data.Text or "setting"
		local ZIndex = Data.ZIndex or 0
		local OpenButton = Data.OpenButton
		local XScroll = Data.XScroll
		local UseFrame = Data.UseFrame
		
		local Store = {}
		local Page
		Page = MaterialUI.Create("ImageButton",{
			Image = "";
			Parent = Parent;
			Name = Text;
			Visible = false;
			BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
			NotTagging = true;
			Size = UDim2.new(1,0,1,0);
			AutoButtonColor = false;
			ZIndex = ZIndex;
			WhenCreated = function(this)
				if OpenButton then
					SettingsHandle:BindButton(OpenButton,this)
				end
				settings().Studio.ThemeChanged:Connect(function()
					MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
					this.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background)
				end)
			end;
		},{
			MaterialUI.Create("Shadow",{
				ZIndex = ZIndex;
			});
			Holder = MaterialUI.Create(UseFrame and "Frame" or "ScrollingFrame",{
				BackgroundTransparency = 1;
				Size = UDim2.new(1,0,1,-42);
				Position = UDim2.new(0,0,0,42);
				NotTagging = true;
				ZIndex = ZIndex;
				BorderSizePixel = 0;
				WhenCreated = function(this)
					if not UseFrame then
						this.ScrollBarThickness = 4;
					end
					Store.Scroll = this
				end;
			},{
				List = MaterialUI.Create("UIListLayout",{
					NotTagging = true;
					WhenCreated = function(this)
						if not UseFrame then
							this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
								Store.Scroll.CanvasSize = UDim2.new(0,XScroll and this.AbsoluteContentSize.X or 0,0,this.AbsoluteContentSize.Y)
							end)
						end
					end;
				});
			});
			TopbarHolder = MaterialUI.Create("Frame",{
				ClipsDescendants = true;
				BackgroundTransparency = 1;
				Size = UDim2.new(1,0,1,0);
				ZIndex = ZIndex;
				NotTagging = true;
			},{
				TopBar = MaterialUI.Create("Frame",{
					BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar);
					Size = UDim2.new(1,0,0,42);
					NotTagging = true;
					ZIndex = ZIndex;
					WhenCreated = function(this)
						settings().Studio.ThemeChanged:Connect(function()
							MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
							this.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar)
						end)
					end;
				},{
					Icon = MaterialUI.Create("IconButton",{
						ToolTipText = Language and Language:GetText("Back") or "Back";
						ToolTipVisible = true;
						ToolTipBackgroundColor3 = MaterialUI.CurrentTheme == "Dark" 
							and Color3.fromRGB(255,255,255)
							or  Color3.fromRGB(45,45,45);
						ToolTipTextColor3 = MaterialUI.CurrentTheme == "Dark" 
							and Color3.fromRGB(0,0,0)
							or  Color3.fromRGB(255,255,255);
						Icon = "rbxassetid://2777859585";
						IconColor3 = Color3.fromRGB(255,255,255);
						IconVisible = true;
						IconSizeScale = 0.85;
						Style = "WithOutBackground";
						Size = UDim2.fromOffset(36,36);
						Position = UDim2.new(0,3,0.5,0);
						AnchorPoint = Vector2.new(0,0.5);
						NotTagging = true;
						ZIndex = ZIndex+3;
						WhenCreated = function(this)
							settings().Studio.ThemeChanged:Connect(function()
								MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
								this.RippleColor3 = MaterialUI.Themes[MaterialUI.CurrentTheme].Rippler.RippleColor3
								this.ToolTipBackgroundColor3 = MaterialUI.CurrentTheme == "Dark" 
									and Color3.fromRGB(255,255,255)
									or  Color3.fromRGB(45,45,45)
								this.ToolTipTextColor3 = MaterialUI.CurrentTheme == "Dark" 
									and Color3.fromRGB(0,0,0)
									or  Color3.fromRGB(255,255,255)
							end)
						end;
						MouseButton1Click = function()
							SettingsHandle:Back(Page)
						end
					});
					Text = MaterialUI.Create("TextLabel",{
						Text = Text;
						Size = UDim2.new(1,0,1,0);
						Position = UDim2.new(0,42,0,0);
						Font = Enum.Font.Gotham;
						TextSize = 16;
						TextColor3 = Color3.fromRGB(255,255,255);
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = ZIndex;
						NotTagging = true;
					});
					Shadow = MaterialUI.Create("Shadow",{
						ZIndex = ZIndex+2;
						NotTagging = true;
					});
				});
			});
		})
		
		return Page
	end
	
	--// 페이지 열기
	--//    Frame : 열 페이지
	function SettingsHandle:Open(Frame)
		--MainPageStore.ClickIgnore.Visible = true
		Frame.Visible = true
		AdvancedTween:StopTween(Frame)
		Frame.Position = UDim2.new(0,0,0,0)
		AdvancedTween:RunTween(Frame,{
			Time = 0.4;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Position = UDim2.new(0,0,0,0);
		})
		wait(0.4)
		--MainPageStore.ClickIgnore.Visible = false
	end
	
	return SettingsHandle
end

function module:init(Data)
	local MaterialUI = Data.MaterialUI
	local Toolbar = Data.Toolbar
	local thisAppInfo = Data.AppInfo
	
	--// 불러오기
	local GroupProvider = shared[thisAppInfo.ToolbarId]
	local plugin = GroupProvider.ProviderPlugin
	
	--// 만약 이미 있다면 바로 리턴
	if GroupProvider.SharedUI then
		return GroupProvider.SharedUI,module:setup(GroupProvider.SharedUI,Data,plugin)
	end
	if GroupProvider.LoadingSharedUI then
		repeat wait() until GroupProvider.SharedUI
		return GroupProvider.SharedUI,module:setup(GroupProvider.SharedUI,Data,plugin)
	end
	GroupProvider.LoadingSharedUI = true
	
	--// 모든 데이터를 담는 테이블
	local SharedUI = {}
	
	--// 마우스 리프레싱
	SharedUI.MouseRefresh = Instance.new("BindableEvent",SharedUI.Interface)
	SharedUI.MouseRefresh.Name = "MouseRefresh"
	
	--// 버튼
	SharedUI.Button = Toolbar:CreateButton(
		AppInfo.AppId, --// 버튼 ID
		"Open qwreey's plugins settings",
		AppInfo.AppIcon, --// 버튼 아이콘
		AppInfo.ButtonText or AppInfo.AppName
	)
	SharedUI.Button.ClickableWhenViewportHidden = true
	
	--// 위젯
	SharedUI.Interface = plugin:CreateDockWidgetPluginGui(AppInfo.AppId,
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			false,
			true,
			230,
			200,
			230,
			200
		)
	)
	SharedUI.Interface.Name = AppInfo.AppId
	SharedUI.Interface.Title = AppInfo.AppName
	SharedUI.Interface.Enabled = false
	
	--// UI
	local Store = {}
	SharedUI.MainPage_Store = Store
	Store.MainPage = MaterialUI.Create("Frame",{
		Name = "MainPage";
		Parent = SharedUI.Interface;
		Size = UDim2.fromScale(1,1);
		BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
		ZIndex = MainPageZIndex;
		NotTagging = true;
	},{
		Holder = MaterialUI.Create("ScrollingFrame",{
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,1,-42);
			Position = UDim2.new(0,0,0,42);
			ScrollBarThickness = 4;
			BorderSizePixel = 0;
			ZIndex = MainPageZIndex;
			NotTagging = true;
			WhenCreated = function(this)
				Store.Scroll = this
			end;
		},{
			List = MaterialUI.Create("UIListLayout",{
				NotTagging = true;
				WhenCreated = function(this)
					Store.List = this
				end;
			});
		});
		TopBar = MaterialUI.Create("Frame",{
			BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar);
			Size = UDim2.new(1,0,0,42);
			ZIndex = MainPageZIndex;
			NotTagging = true;
			WhenCreated = function(this)
				Store.TopBar = this
			end;
		},{
			Icon = MaterialUI.Create("ImageLabel",{
				BackgroundTransparency = 1;
				Image = "http://www.roblox.com/asset/?id=6008752152";
				Size = UDim2.fromOffset(30,30);
				Position = UDim2.new(0,6,0.5,0);
				AnchorPoint = Vector2.new(0,0.5);
				ImageColor3 = Color3.fromRGB(255,255,255);
				ZIndex = MainPageZIndex;
				NotTagging = true;
			});
			Text = MaterialUI.Create("TextLabel",{
				Text = "Settings";
				Size = UDim2.new(1,0,1,0);
				Position = UDim2.new(0,41,0,0);
				Font = Enum.Font.Gotham;
				TextSize = 16;
				TextColor3 = Color3.fromRGB(255,255,255);
				TextXAlignment = Enum.TextXAlignment.Left;
				BackgroundTransparency = 1;
				ZIndex = MainPageZIndex;
				NotTagging = true;
			});
			Shadow = MaterialUI.Create("Shadow",{
				ZIndex = MainPageZIndex+3;
				NotTagging = true;
			});
		});
	})
	--Store.ClickIgnore = MaterialUI.Create("TextButton",{
	--	Name = "ClickIgnore";
	--	BackgroundTransparency = 1;
	--	Text = "";
	--	ZIndex = 2147483647;
	--	Visible = false;
	--	Parent = SharedUI.Interface;
	--	Size = UDim2.new(1,0,1,0);
	--	NotTagging = true;
	--})
	
	--// 저장
	shared[thisAppInfo.ToolbarId].SharedUI = SharedUI
	return SharedUI,module:setup(SharedUI,Data,plugin)
end

return module
