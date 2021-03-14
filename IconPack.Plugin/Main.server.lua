local plugin = plugin
if not plugin then
	--// 플러그인이 아닌데 이 코드가 실행되면 바로 멈춰줌(태스팅 모드에서)
	return
end

--TODO : 아이콘 별표 기능

local AppInfo = {
	-- APP INFO
	["AppIcon"] = "http://www.roblox.com/asset/?id=6035086033";
	["AppIconLight"] = "http://www.roblox.com/asset/?id=6035086035"; -- for toolbar light mode
	["AppName"] = "IconPack";
	["AppId"] = "qwreey.plugins.iconpack";
	
	-- PLUGIN GROUP
	["ToolbarId"] = "qwreey.plugins.toolbarprovider";
	["ToolbarName"] = "Qwreey's plugins";
	
	--BUTTON
	["ButtonText"] = "Icon Pack";
	["ButtonHoverText"] = "Open IconPack Window\nPowered by google";
	
	-- INTERFACE
	["InterfaceMiniSize"] = {X=250,Y=210};
	["InterfaceInitSize"] = {X=250,Y=300};
	["InterfaceDefaultFace"] = Enum.InitialDockState.Right;
	
	-- OTHER
	["Version"] = 1;
	["SplashIconSize"] = UDim2.new(0,70,0,70);
	["BypassSplash"] = false;
}

--------------
--import
--------------
--// 로블록스 서비스 불러오기(import)
local PluginGuiService = game:GetService("PluginGuiService")
local TextService = game:GetService("TextService")
local ContentProvider = game:GetService("ContentProvider")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")

--// 모듈 불러오기
local MaterialUI = require(script.lib.MaterialUI)
local Data = require(script.lib.Data):SetUp(plugin)
local AdvancedTween = require(script.lib.AdvancedTween)
local ToolbarCombiner = require(script.lib.ToolbarCombiner)
local Util = require(script.lib.Util)

local License = require(script.License)
local LicenseViewer = require(script.res.LicenseViewer)

local Language = require(script.res.Language)

local IconDump = require(script.res.IconDump)
--[[ IconDump 설명
IconDump = {
	[IconStyle] = {
		[IconGroup] = {
			[IconName] = IconURL(Content URL);
		};
	};
}
]]

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

local TopBarSizeY = 40
local TopBarIconPadding = 10
local TopBarText = Language:GetText("TopBarText")

local IconFrameSize = {X = 76,Y = 75}
local IconSize = 48
local IconTopPadding = 4

local SearchBarSizeY = 30
local SearchBarOpenSize = UDim2.new(
	1,
	- TextService:GetTextSize(TopBarText,14,AppFont,Vector2.new(math.huge,math.huge)).X
	- TopBarSizeY - 5 - 4,
	0,
	SearchBarSizeY
)
local SearchBarIconScale = 0.8
local SearchBarBackgroundColor = {
	["Dark"] = Color3.fromRGB(85,85,85);
	["Light"] = Color3.fromRGB(245,245,245);
}
local SearchBarPlaceHolderColor = {
	["Dark"] = Color3.fromRGB(200,200,200);
	["Light"] = Color3.fromRGB(135,135,135);
}

local IconInfoFrameZIndex = 50
local IconInfoFrameSizeY = 120
local IconInfoFrameColor = {
	["Dark"] = Color3.fromRGB(35,35,35);
	["Light"] = Color3.fromRGB(245,245,245);
}

local FavoriteIcon = {
	Off = "http://www.roblox.com/asset/?id=6023565882";
	On  = "http://www.roblox.com/asset/?id=6023426974";
}

local GroupListSizeX = 150

local ToolTipZIndex = 80000
local MenuZIndex = 90000

--[[ 아이콘 테이블(각각)
Icon = {
	["GroupName"] = Str = > 그룹 이름
	["Style"] = Str = > 스타일(아직 baseline 만)
	["IconName"] = Str = > 아이콘 이름
	["IconURL"] = Str = > 아이콘 URL
}
]]

--[[ 플러그인에 저장되는 값들
Data = {
	["LastSelected"] = {} = > 선택된 아이콘 정보 저장
	["SavedScrollPos"] = int = > 스크롤 위치 저장
	["LastSearchStat"] = str = > 검색 정보 저장
}
]]

local SelectIcon = void

--// 저장 값 불러오기
local SavedScrollPos = Data:Load("SavedScrollPos") or 0
local LastSearchStat = Data:Load("LastSearchStat") or ""
local Selected = Data:Load("Selected")

local Favorites = Data:Load("Favorites") or {}
local AddFavoriteListItem
local UpdateFavoriteList

--// 업데이트 키 (여러개의 창이 열려있을때 상호 교환용)
local Favorites_UpdateKey = Data:ForceLoad("Favorites_UpdateKey") or Util:MakeID()
Data:Save("Favorites_UpdateKey",Favorites_UpdateKey)

function LoadGui()
	--// UI 개채를 담을곳
	local Store = {
		Snackbars = nil;
		IconHolder = nil;
		SearchTextBox = nil;
		SearchBar = nil;
		SearchCancel = nil;
		IconInfoFrame = nil;
		IconInfoFrameHolder = nil;
		OverScrollFrameForIconInfoFrame = nil;
		FavoritesHolder = nil;
		FavoritesFrame = nil;
		FavoriteIcon_ToolTip = nil;
		NoFavoriteText = nil;
		FavoriteIconButton = nil;
		MenuIcon_ToolTip = nil;
		Frame = nil;
		CloseIcon_ToolTip = nil;
		SearchIcon_ToolTip = nil;
		GroupListHolder = nil;
		GroupListFrame = nil;
		GroupListItemHolder = nil;
		ResizingFrame = nil;
	}
	local UndoFunction = void
	
	--// 이전의 UI 제거(태마 변경시, 클리어)
	Interface:ClearAllChildren()
	MaterialUI:CleanUp()
	
	--// 현재 태마 불러오기
	MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
	--// 위잿 등록
	local Mouse = MaterialUI:UseDockWidget(Interface,plugin:GetMouse())
	
	--// 즐겨찾기 추가 함수
	function AddFavoriteListItem(Select)
		Store.NoFavoriteText.Visible = false
		
		local TextLabelSizeY = IconFrameSize.Y - IconSize - IconTopPadding
		MaterialUI.Create("ImageButton",{
			MouseButton1Click = function()
				SelectIcon(Select)
			end;
			BackgroundTransparency = 1;
			Parent = Store.FavoritesHolder;
			ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
			ImageTransparency = 0.88;
			Name = Select.IconName;
			WhenCreated = function(this)
				MaterialUI:SetRound(this,8)
			end;
		},{
			Icon = MaterialUI.Create("ImageLabel",{
				SizeConstraint = Enum.SizeConstraint.RelativeXX;
				BackgroundTransparency = 1;
				Position = UDim2.new(0.5,0,0,IconTopPadding);
				AnchorPoint = Vector2.new(0.5,0);
				Image = Select.IconURL;
				ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Size = UDim2.new(0,IconSize,0,IconSize);
			});
			Text = MaterialUI.Create("TextLabel",{
				Font = AppFont;
				BackgroundTransparency = 1;
				Position = UDim2.new(0.5,0,1,0);
				AnchorPoint = Vector2.new(0.5,1);
				Text = Select.IconName;
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Size = UDim2.new(1,0,0,TextLabelSizeY);
				TextTruncate = Enum.TextTruncate.AtEnd;
				ClipsDescendants = true;
				TextSize = 11;
			});
		})
	end
	
	function UpdateFavoriteList()
		--// 다른 창에서 즐겨찾기 리스트를 변경했는지 확인하고 변경 된 경우
		--// 불러오기를 시작함
		
		local GlobalUpdateKey = Data:ForceLoad("Favorites_UpdateKey")
		if Favorites_UpdateKey ~= GlobalUpdateKey then
			for _,Item in pairs(Store.FavoritesHolder:GetChildren()) do
				if Item:IsA("ImageButton") then
					Item.Visible = false
					Item:Destroy()
				end
			end
			
			Favorites = Data:ForceLoad("Favorites")
			
			local SelectedIsFavorite = false
			for _,Item in pairs(Favorites) do
				AddFavoriteListItem(Item)
				if Item.IconURL == Selected.IconURL then
					SelectedIsFavorite = true
				end
			end
			
			Store.FavoriteIconButton.Icon = FavoriteIcon[SelectedIsFavorite and "On" or "Off"]
		end
	end
	
	local function AddImage(Selected)
		--// 추가 함수
		
		--// 다시 수행 용
		History:SetWaypoint("Adding new imagelabel")
		
		local SelectedInstance = Selection:Get()
		if (not SelectedInstance[1]) or (not Selected) then
			return
		end
		
		local New = MaterialUI.Create("ImageLabel",{
			Size = UDim2.new(0,80,0,80,0);
			Parent = SelectedInstance[1];
			BackgroundTransparency = 1;
			Image = Selected.IconURL;
		})
		
		--// 되돌리기 용
		History:SetWaypoint("Added new imagelabel")
		
		--// 스낵바
		Store.Snackbars.Text = Language:GetText("ImageAdded")
		Store.Snackbars:Open()
		
		UndoFunction = function()
			History:SetWaypoint("removing imagelabel")
			if New then
				New:Destroy()
			end
			History:SetWaypoint("removed imagelabel")
			Store.Snackbars:Close()
		end
	end
	
	local function SetImage(Selected)
		--// 교체 함수
		
		--// 다시 수행 용
		History:SetWaypoint("Editing image")
		
		local SelectedInstance = Selection:Get()
		if (not SelectedInstance[1]) or (not Selected) then
			return
		end
		
		local UndoList = {}
		for _,SelectedIns in pairs(SelectedInstance) do
			if SelectedIns:IsA("ImageButton") or SelectedIns:IsA("ImageLabel") then
				UndoList[SelectedIns] = SelectedIns.Image
				SelectedIns.Image = Selected.IconURL
			end
		end
		
		--// 되돌리기 용
		History:SetWaypoint("Edited image")
		
		--// 스낵바
		Store.Snackbars.Text = Language:GetText("ImageSetted")
		Store.Snackbars:Open()
		
		UndoFunction = function()
			History:SetWaypoint("start undo edit imagelabel")
			for Item,Image in pairs(UndoList) do
				Item.Image = Image
			end
			History:SetWaypoint("undo edit imagelabel ended")
			Store.Snackbars:Close()
		end
	end
	
	--// UI 만들기
	MaterialUI.Create("Frame",{
		ClipsDescendants = true;
		WhenCreated = function(this)
			Store.Frame = this
		end;
		BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
		--Size = UDim2.fromOffset(
		--	Mouse.Obj.AbsoluteSize.X,
		--	Mouse.Obj.AbsoluteSize.Y
		--);
		Size = UDim2.fromScale(1,1);
		Name = "Main";
		Parent = Interface;
	},{
		--// 그룹 항목 보기
		GroupListFrame = MaterialUI.Create("TextButton",{
			AutoButtonColor = false;
			Text = "";
			BackgroundTransparency = 1;
			BackgroundColor3 = Color3.fromRGB(0,0,0);
			Size = UDim2.new(1,0,1,0);
			Visible = false;
			ZIndex = MenuZIndex;
			WhenCreated = function(this)
				Store.GroupListFrame = this
			end;
			MouseButton1Click = function()
				AdvancedTween:RunTween(Store.GroupListHolder,{
					Time = 0.4;
					Easing = AdvancedTween.EasingFunctions.Exp2;
					Direction = AdvancedTween.EasingDirection.Out;
				},{
					AnchorPoint = Vector2.new(1,0);
				})
			end;
		},{
			GroupListHolder = MaterialUI.Create("TextButton",{
				ZIndex = MenuZIndex;
				AutoButtonColor = false;
				Text = "";
				BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
				Size = UDim2.new(0,GroupListSizeX,1,0);
				Position = UDim2.new(0,0,0,0);
				AnchorPoint = Vector2.new(1,0);
				WhenCreated = function(this)
					Store.GroupListHolder = this
					this:GetPropertyChangedSignal("AnchorPoint"):Connect(function()
						Store.GroupListFrame.Visible = this.AnchorPoint.X ~= 1
						local OpenPer = 1 - this.AnchorPoint.X
						local Tr = 1 - (0.4 * OpenPer)
						Store.GroupListFrame.BackgroundTransparency = Tr
						--0.6 ~ 1
					end)
				end;
			},{
				BackIcon = MaterialUI.Create("IconButton",{
					ZIndex = MenuZIndex;
					Style = MaterialUI.CEnum.IconButtonStyle.WithOutBackground;
					Size = UDim2.fromOffset(TopBarSizeY-TopBarIconPadding,TopBarSizeY-TopBarIconPadding);
					Position = UDim2.new(0,TopBarIconPadding/2,0,TopBarSizeY/2);
					AnchorPoint = Vector2.new(0,0.5);
					Icon = "http://www.roblox.com/asset/?id=6031091000";
					IconSizeScale = 0.85;
					MouseButton1Click = function()
						AdvancedTween:RunTween(Store.GroupListHolder,{
							Time = 0.4;
							Easing = AdvancedTween.EasingFunctions.Exp2;
							Direction = AdvancedTween.EasingDirection.Out;
						},{
							AnchorPoint = Vector2.new(1,0);
						})
					end;
				});
				TopText = MaterialUI.Create("TextLabel",{
					ZIndex = MenuZIndex;
					Font = AppFont;
					TextSize = 16;
					Text = Language:GetText("Groups");
					BackgroundTransparency = 1;
					TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					Size = UDim2.new(1,0,0,TopBarSizeY);
					Position = UDim2.new(0,TopBarSizeY,0,0);
					TextXAlignment = Enum.TextXAlignment.Left;
				});
				TopDiv = MaterialUI.Create("Frame",{
					ZIndex = MenuZIndex;
					Size = UDim2.new(1,-16,0,1);
					Position = UDim2.new(0.5,0,0,TopBarSizeY);
					AnchorPoint = Vector2.new(0.5,1);
					BackgroundColor3 = Color3.fromRGB(127,127,127);
				});
				Shadow = MaterialUI.Create("Shadow",{
					ZIndex = MenuZIndex;
				});
				GroupListItemHolder = MaterialUI.Create("ScrollingFrame",{
					ZIndex = MenuZIndex;
					BackgroundTransparency = 1;
					ScrollBarImageColor3 = MaterialUI:GetColor("TextColor");
					ScrollBarImageTransparency = 0.2;
					ScrollBarThickness = 4;
					Size = UDim2.new(1,0,1,-TopBarSizeY);
					Position = UDim2.new(0,0,0,TopBarSizeY);
					WhenCreated = function(this)
						Store.GroupListItemHolder = this
					end;
				},{
					ListLayout = MaterialUI.Create("UIListLayout",{
						SortOrder = Enum.SortOrder.Name;
						WhenCreated = function(this)
							this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
								Store.GroupListItemHolder.CanvasSize = UDim2.fromOffset(0,this.AbsoluteContentSize.Y)
							end)
						end;
					});
				});
			});
		});
		
		--// 맨위 바
		TopBar = MaterialUI.Create("Frame",{
			BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar);
			Size = UDim2.new(1,0,0,TopBarSizeY);
		},{
			Shadow = MaterialUI.Create("Shadow");
			MenuIcon = MaterialUI.Create("IconButton",{
				Style = MaterialUI.CEnum.IconButtonStyle.WithOutBackground;
				Size = UDim2.fromOffset(TopBarSizeY-TopBarIconPadding,TopBarSizeY-TopBarIconPadding);
				Position = UDim2.new(0,TopBarIconPadding/2,0.5,0);
				AnchorPoint = Vector2.new(0,0.5);
				Icon = "http://www.roblox.com/asset/?id=6031097225";
				IconSizeScale = 0.85;
				MouseButton1Click = function()
					AdvancedTween:RunTween(Store.GroupListHolder,{
						Time = 0.4;
						Easing = AdvancedTween.EasingFunctions.Exp2;
						Direction = AdvancedTween.EasingDirection.Out;
					},{
						AnchorPoint = Vector2.new(0,0);
					})
				end;
				WhenCreated = function(this)
					MaterialUI.Create("ToolTip",{
						Name = "Menu_ToolTip";
						ZIndex = ToolTipZIndex;
						BackgroundColor3 = MaterialUI.CurrentTheme == "Dark" and
							Color3.fromRGB(255,255,255) or
							Color3.fromRGB(45,45,45);
						TextColor3 = MaterialUI.CurrentTheme == "Dark" and
							Color3.fromRGB(0,0,0) or
							Color3.fromRGB(255,255,255);
						Position = UDim2.new(0,3,0,TopBarSizeY + 4);
						AnchorPoint = Vector2.new(0,0);
						Adornee = this;
						WhenCreated = function(this)
							Store.MenuIcon_ToolTip = this
						end;
						TextFunction = function()
							return Language:GetText("Menu_ToolTip")
						end;
					});
					Store.FavoriteIconButton = this
				end;
			});
			--MenuIcon = MaterialUI.Create("ImageLabel",{
				--Size = UDim2.fromOffset(TopBarSizeY-TopBarIconPadding,TopBarSizeY-TopBarIconPadding);
				--Position = UDim2.new(0,TopBarIconPadding/2,0.5,0);
				--AnchorPoint = Vector2.new(0,0.5);
			--	BackgroundTransparency = 1;
			--	Image = "http://www.roblox.com/asset/?id=6031097225";
			--});
			Text = MaterialUI.Create("TextLabel",{
				Text = TopBarText;
				Size = UDim2.new(1,0,1,0);
				Position = UDim2.new(0,TopBarSizeY,0,0);
				BackgroundTransparency = 1;
				TextColor3 = Color3.fromRGB(255,255,255);
				Font = AppFont;
				TextSize = 14;
				TextXAlignment = Enum.TextXAlignment.Left;
			});
			--// 검색 구현
			SearchBar = MaterialUI.Create("ImageLabel",{
				Size = LastSearchStat == "" and
					UDim2.new(0,SearchBarSizeY,0,SearchBarSizeY) or
					SearchBarOpenSize;
				Position = UDim2.new(1,-4,0.5,0);
				AnchorPoint = Vector2.new(1,0.5);
				BackgroundTransparency = 1;
				ImageColor3 = SearchBarBackgroundColor[MaterialUI.CurrentTheme];
				ClipsDescendants = true;
				WhenCreated = function(this)
					Store.SearchBar = this
					MaterialUI:SetRound(this,1000);
				end;
			},{
				TextBox = MaterialUI.Create("TextBox",{
					Size = UDim2.new(1,-SearchBarSizeY*2,1,0);
					Position = UDim2.new(0,SearchBarSizeY,0,0);
					BackgroundTransparency = 1;
					ClearTextOnFocus = false;
					TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					TextTruncate = Enum.TextTruncate.AtEnd;
					TextXAlignment = Enum.TextXAlignment.Left;
					Text = LastSearchStat;
					PlaceholderText = Language:GetText("SearchHere");
					PlaceholderColor3 = SearchBarPlaceHolderColor[MaterialUI.CurrentTheme];
					Visible = LastSearchStat ~= "";
					WhenCreated = function(this)
						Store.SearchTextBox = this
						this:GetPropertyChangedSignal("Text"):Connect(function()
							LastSearchStat = this.Text
						end)
						this.FocusLost:Connect(function(ent)
							if this.Text == "" then
								AdvancedTween:RunTween(Store.SearchBar,{
									Time = 0.4;
									Easing = AdvancedTween.EasingFunctions.Exp2;
									Direction = AdvancedTween.EasingDirection.Out;
								},{
									Size = UDim2.new(0,SearchBarSizeY,0,SearchBarSizeY);
								})
								AdvancedTween:RunTween(Store.SearchCancel,{
									Time = 0.3;
									Easing = AdvancedTween.EasingFunctions.Exp2;
									Direction = AdvancedTween.EasingDirection.Out;
								},{
									AnchorPoint = Vector2.new(1,0);
								})
								Store.SearchTextBox.Visible = false
							end
						end)
					end;
				},{
					Padding = MaterialUI.Create("UIPadding",{
						PaddingLeft = UDim.new(0,5);
					});
				});
				SearchIcon = MaterialUI.Create("IconButton",{
					Icon = "http://www.roblox.com/asset/?id=6031154871";
					IconSizeScale = SearchBarIconScale;
					Size = UDim2.new(0,SearchBarSizeY,0,SearchBarSizeY);
					Position = UDim2.new(1,0,0,0);
					AnchorPoint = Vector2.new(1,0);
					Style = MaterialUI.CEnum.IconButtonStyle.WithOutBackground;
					IconColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					MouseButton1Click = function()
						AdvancedTween:RunTween(Store.SearchBar,{
							Time = 0.4;
							Easing = AdvancedTween.EasingFunctions.Exp2;
							Direction = AdvancedTween.EasingDirection.Out;
						},{
							Size = SearchBarOpenSize;
						})
						Store.SearchTextBox:CaptureFocus()
						AdvancedTween:RunTween(Store.SearchCancel,{
							Time = 0.3;
							Easing = AdvancedTween.EasingFunctions.Exp2;
							Direction = AdvancedTween.EasingDirection.Out;
						},{
							AnchorPoint = Vector2.new(0,0);
						})
						Store.SearchTextBox.Visible = true
					end;
					WhenCreated = function(this)
						MaterialUI.Create("ToolTip",{
							Name = "SearchIcon_ToolTip";
							ZIndex = ToolTipZIndex;
							BackgroundColor3 = MaterialUI.CurrentTheme == "Dark" and
								Color3.fromRGB(255,255,255) or
								Color3.fromRGB(45,45,45);
							TextColor3 = MaterialUI.CurrentTheme == "Dark" and
								Color3.fromRGB(0,0,0) or
								Color3.fromRGB(255,255,255);
							Position = UDim2.new(1,-3,0,TopBarSizeY + 4);
							AnchorPoint = Vector2.new(1,0);
							Adornee = this;
							WhenCreated = function(this)
								Store.SearchIcon_ToolTip = this
							end;
							TextFunction = function()
								return Language:GetText("Search")
							end;
						});
					end;
				});
				Cancel = MaterialUI.Create("IconButton",{
					Icon = "http://www.roblox.com/asset/?id=6035047409";
					IconSizeScale = SearchBarIconScale;
					Size = UDim2.new(0,SearchBarSizeY,0,SearchBarSizeY);
					Style = MaterialUI.CEnum.IconButtonStyle.WithOutBackground;
					IconColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					AnchorPoint = LastSearchStat == "" and Vector2.new(1,0) or Vector2.new(0,0);
					WhenCreated = function(this)
						Store.SearchCancel = this
					end;
					MouseButton1Click = function()
						Store.SearchTextBox.Text = ""
						Store.SearchTextBox:ReleaseFocus(false)
						AdvancedTween:RunTween(Store.SearchBar,{
							Time = 0.4;
							Easing = AdvancedTween.EasingFunctions.Exp2;
							Direction = AdvancedTween.EasingDirection.Out;
						},{
							Size = UDim2.new(0,SearchBarSizeY,0,SearchBarSizeY);
						})
						AdvancedTween:RunTween(Store.SearchCancel,{
							Time = 0.3;
							Easing = AdvancedTween.EasingFunctions.Exp2;
							Direction = AdvancedTween.EasingDirection.Out;
						},{
							AnchorPoint = Vector2.new(1,0);
						})
						Store.SearchTextBox.Visible = false
					end;
				});
			});
		});
		
		--// 아이콘들 담는 곳
		IconHolder = MaterialUI.Create("ScrollingFrame",{
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,1,-TopBarSizeY);
			Position = UDim2.new(0,0,0,TopBarSizeY);
			ScrollBarImageColor3 = MaterialUI:GetColor("TextColor");
			ScrollBarImageTransparency = 0.2;
			ScrollBarThickness = 6;
			WhenCreated = function(this)
				Store.IconHolder = this
				this:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
					SavedScrollPos = this.CanvasPosition.Y
				end)
			end;
		},{
			--// 리스트화(그룹)
			ListLayout = MaterialUI.Create("UIListLayout",{
				SortOrder = Enum.SortOrder.LayoutOrder;
				WhenCreated = function(this)
					-- AbsoluteContextSize : vec2
					this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						Store.IconHolder.CanvasSize = UDim2.fromOffset(0,this.AbsoluteContentSize.Y)
					end)
				end;
			});
			OverScrollFrameForIconInfoFrame = MaterialUI.Create("Frame",{
				LayoutOrder = 2147483647;
				Size = UDim2.new(1,0,0,IconInfoFrameSizeY);
				BackgroundTransparency = 1;
				Visible = false;
				WhenCreated = function(this)
					Store.OverScrollFrameForIconInfoFrame = this
				end;
			});
			Favorites = MaterialUI.Create("Frame",{
				Size = UDim2.new(1,0,0,70);
				Parent = Store.IconHolder;
				BackgroundTransparency = 1;
				Name = "Favorites";
				LayoutOrder = -2147483647;
				ClipsDescendants = true;
				WhenCreated = function(this)
					Store.FavoritesFrame = this
				end;
			},{
				Text = MaterialUI.Create("TextLabel",{
					TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					TextXAlignment = Enum.TextXAlignment.Left;
					Font = AppFont;
					TextSize = 16;
					Text = "Favorites";
					Size = UDim2.new(1,-30,0,30);
					Position = UDim2.new(0.5,0,0,0);
					AnchorPoint = Vector2.new(0.5,0);
					BackgroundTransparency = 1;
				});
				NoFavoriteText = MaterialUI.Create("TextLabel",{
					Text = Language:GetText("NoFavoritesList");
					Font = AppFont;
					TextSize = 16;
					Size = UDim2.new(1,0,1,-30);
					Position = UDim2.new(0,0,0,30);
					BackgroundTransparency = 1;
					TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					WhenCreated = function(this)
						Store.NoFavoriteText = this
					end;
				});
				Holder = MaterialUI.Create("Frame",{
					Position = UDim2.new(0,0,0,30);
					BackgroundTransparency = 1;
					Size = UDim2.new(1,0,1,0);
					WhenCreated = function(this)
						Store.FavoritesHolder = this
					end;
				},{
					Grid = MaterialUI.Create("UIGridLayout",{
						SortOrder = Enum.SortOrder.Name;
						CellSize = UDim2.new(0,IconFrameSize.X,0,IconFrameSize.Y);
						CellPadding = UDim2.new(0,5,0,5);
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						WhenCreated = function(this)
							this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
								AdvancedTween:RunTween(Store.FavoritesFrame,{
									Time = 0.2;
									Easing = AdvancedTween.EasingFunctions.Exp2;
									Direction = AdvancedTween.EasingDirection.Out;
								},{
									Size = UDim2.new(
										1,
										0,
										0,
										math.max(this.AbsoluteContentSize.Y + 30 + 8,70)
									);
								})
							end)
						end;
					});
				});
			})
		});
		
		--// 아이콘 선택했을때 프레임
		IconInfoFrame = MaterialUI.Create("Frame",{
			Visible = true;
			ZIndex = IconInfoFrameZIndex;
			Size = UDim2.new(1,0,0,IconInfoFrameSizeY);
			Position = UDim2.new(0,0,1,0);
			AnchorPoint = Vector2.new(0,0);
			BackgroundColor3 = IconInfoFrameColor[MaterialUI.CurrentTheme];
			WhenCreated = function(this)
				Store.IconInfoFrame = this
				this:GetPropertyChangedSignal("AnchorPoint"):Connect(function()
					local thisVisible = this.AnchorPoint.Y ~= 0
					Store.OverScrollFrameForIconInfoFrame.Visible = thisVisible
					this.Shadow.Visible = thisVisible
					--this.Visible = thisVisible
				end)
			end;
		},{
			Shadow = MaterialUI.Create("Shadow",{
				ZIndex = IconInfoFrameZIndex+1;
				Visible = false;
			});
			SnackbarsHolder = MaterialUI.Create("Frame",{
				Size = UDim2.new(1,0,0,60);
				AnchorPoint = Vector2.new(0,1);
				BackgroundTransparency = 1;
				ClipsDescendants = true;
			},{
				Snackbars = MaterialUI.Create("Snackbars",{
					OpenTime = 2.3;
					WhenCreated = function(this)
						Store.Snackbars = this
					end;
					ZIndex = IconInfoFrameZIndex+1;
					Font = AppFont;
					Size = UDim2.new(1,-16,0,50);
					Position = UDim2.new(0,8,1,-6);
				},{
					MaterialUI.Create("Button",{
						Font = AppFont;
						Text = Language:GetText("Undo");
						Style = MaterialUI.CEnum.ButtonStyle.Text;
						TextColor3 = Color3.fromRGB(62,255,181);
						Size = UDim2.new(0,60,1,0);
						TextSize = 12;
						MouseButton1Click = function()
							UndoFunction()
						end;
						ZIndex = IconInfoFrameZIndex+2;
					});
				});
			});
		});
		
		--// 아이콘 선택했을때 프레임(아이템 보관용)
		--// 합쳐도 상관은 없는데 에니메이션 효과(시차효과)를 위해서 분활
		IconInfoFrameHolder = MaterialUI.Create("TextButton",{
			--// 뒷 배경 클릭 방지를 위해 버튼으로 지정
			AutoButtonColor = false;
			Text = "";
			ZIndex = IconInfoFrameZIndex+1;
			Size = UDim2.new(1,0,0,IconInfoFrameSizeY);
			Position = UDim2.new(0,0,1,0);
			AnchorPoint = Vector2.new(0,0);
			BackgroundTransparency = 1;
			WhenCreated = function(this)
				Store.IconInfoFrameHolder = this
			end;
		},{
			SelectedText = MaterialUI.Create("TextLabel",{
				ZIndex = IconInfoFrameZIndex+1;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextSize = 14;
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Text = "Selected : Test";
				Font = AppFont;
				Position = UDim2.new(0,8,0,0);
				BackgroundTransparency = 1;
				Size = UDim2.new(1,-8 - (30*2),0,30);
			});
			CloseIcon = MaterialUI.Create("IconButton",{
				ZIndex = IconInfoFrameZIndex+1;
				Style = MaterialUI.CEnum.IconButtonStyle.WithOutBackground;
				Size = UDim2.new(0,30,0,30);
				Position = UDim2.new(1,0,0,0);
				AnchorPoint = Vector2.new(1,0);
				Icon = "http://www.roblox.com/asset/?id=6035047409";
				IconSizeScale = 0.8;
				MouseButton1Click = function()
					AdvancedTween:RunTween(Store.IconInfoFrame,{
						Time = 0.3;
						Easing = AdvancedTween.EasingFunctions.Exp2;
						Direction = AdvancedTween.EasingDirection.Out;
					},{
						AnchorPoint = Vector2.new(0,0)
					})
					AdvancedTween:RunTween(Store.IconInfoFrameHolder,{
						Time = 0.1;
						Easing = AdvancedTween.EasingFunctions.Exp2;
						Direction = AdvancedTween.EasingDirection.Out;
					},{
						AnchorPoint = Vector2.new(0,0)
					})
					Selected = nil
				end;
				WhenCreated = function(this)
					MaterialUI.Create("ToolTip",{
						Name = "CloseIcon_ToolTip";
						ZIndex = IconInfoFrameZIndex+4;
						BackgroundColor3 = MaterialUI.CurrentTheme == "Dark" and
							Color3.fromRGB(255,255,255) or
							Color3.fromRGB(45,45,45);
						TextColor3 = MaterialUI.CurrentTheme == "Dark" and
							Color3.fromRGB(0,0,0) or
							Color3.fromRGB(255,255,255);
						Position = UDim2.new(1,-3,0,34);
						AnchorPoint = Vector2.new(1,0);
						Adornee = this;
						WhenCreated = function(this)
							Store.CloseIcon_ToolTip = this
						end;
						TextFunction = function()
							return Language:GetText("Close")
						end;
					});
				end;
			});
			FavoriteIcon = MaterialUI.Create("IconButton",{
				ZIndex = IconInfoFrameZIndex+1;
				Style = MaterialUI.CEnum.IconButtonStyle.WithOutBackground;
				Size = UDim2.new(0,30,0,30);
				Position = UDim2.new(1,-30,0,0);
				AnchorPoint = Vector2.new(1,0);
				Icon = FavoriteIcon.Off;
				IconSizeScale = 0.65;
				MouseButton1Click = function()
					UpdateFavoriteList()
					
					--// 이미 즐겨찾기 되어 있는지 확인
					local Already = false
					for i,v in pairs(Favorites) do
						if v.IconURL == Selected.IconURL then
							Already = i
							break
						end
					end
					
					if Already then
						--// 즐겨찾기가 이미 되어 있어 삭제 시도
						table.remove(Favorites,Already)
						local Button = Store.FavoritesHolder:FindFirstChild(Selected.IconName)
						Button.Visible = false
						Button:Destroy()
						Store.NoFavoriteText.Visible = #Favorites == 0
						Store.FavoriteIconButton.Icon = FavoriteIcon.Off
						Store.FavoriteIcon_ToolTip.Text = Language:GetText("AddToFavorites")
					else
						--// 즐겨찾기가 안되어 있어 추가 시도
						AddFavoriteListItem(Selected)
						Favorites[#Favorites+1] = Selected
						Store.FavoriteIconButton.Icon = FavoriteIcon.On
						Store.FavoriteIcon_ToolTip.Text = Language:GetText("RemoveFromFavorites")
					end
					
					--// 저장
					Data:Save("Favorites",Favorites)
					
					--// 다른 스튜디오 창을 위해 업데이트 키를 변경함
					Favorites_UpdateKey = Util:MakeID()
					Data:Save("Favorites_UpdateKey",Favorites_UpdateKey)
				end;
				WhenCreated = function(this)
					MaterialUI.Create("ToolTip",{
						Name = "FavoriteIcon_ToolTip";
						ZIndex = IconInfoFrameZIndex+4;
						BackgroundColor3 = MaterialUI.CurrentTheme == "Dark" and
							Color3.fromRGB(255,255,255) or
							Color3.fromRGB(45,45,45);
						TextColor3 = MaterialUI.CurrentTheme == "Dark" and
							Color3.fromRGB(0,0,0) or
							Color3.fromRGB(255,255,255);
						Position = UDim2.new(1,-3,0,34);
						AnchorPoint = Vector2.new(1,0);
						Adornee = this;
						WhenCreated = function(this)
							Store.FavoriteIcon_ToolTip = this
						end;
						TextFunction = function()
							if not Selected then
								return ""
							end
							
							for _,v in pairs(Favorites) do
								if v.IconURL == Selected.IconURL then
									return Language:GetText("RemoveFromFavorites")
								end
							end
							return Language:GetText("AddToFavorites")
						end;
					});
					Store.FavoriteIconButton = this
				end;
			});
			IconHolder = MaterialUI.Create("ImageLabel",{
				ZIndex = IconInfoFrameZIndex+1;
				ImageTransparency = 0.88;
				SizeConstraint = Enum.SizeConstraint.RelativeYY;
				WhenCreated = function(this)
					MaterialUI:SetRound(this,8);
				end;
				Size = UDim2.new(1,-36,1,-36);
				Position = UDim2.new(0,3,1,-3);
				AnchorPoint = Vector2.new(0,1);
				BackgroundTransparency = 1;
				ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
			},{
				Icon = MaterialUI.Create("ImageLabel",{
					ZIndex = IconInfoFrameZIndex+1;
					BackgroundTransparency = 1;
					Size = UDim2.new(0.8,0,0.8,0);
					Position = UDim2.new(0.5,0,0.5,0);
					AnchorPoint = Vector2.new(0.5,0.5);
					Image = "";
					ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				});
			});
			IDText = MaterialUI.Create("TextBox",{
				ClearTextOnFocus = false;
				TextEditable = false;
				TextTruncate = Enum.TextTruncate.AtEnd;
				ZIndex = IconInfoFrameZIndex+1;
				BackgroundTransparency = 1;
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Text = "Image ID : None";
				TextSize = 14;
				Font = AppFont;
				Position = UDim2.new(0,
					(IconInfoFrameSizeY / 2) + 30 + 6,
					0,
					32 + (18*0)
				);
				Size = UDim2.new(1,
					-(IconInfoFrameSizeY / 2) - 30 - 6,
					0,
					16
				);
				TextXAlignment = Enum.TextXAlignment.Left;
			});
			StyleText = MaterialUI.Create("TextLabel",{
				ZIndex = IconInfoFrameZIndex+1;
				BackgroundTransparency = 1;
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Text = "Style : None";
				TextSize = 14;
				Font = AppFont;
				Position = UDim2.new(0,
					(IconInfoFrameSizeY / 2) + 30 + 6,
					0,
					32 + (18*1)
				);
				Size = UDim2.new(1,
					-(IconInfoFrameSizeY / 2) - 30 - 6,
					0,
					16
				);
				TextXAlignment = Enum.TextXAlignment.Left;
			});
			GroupText = MaterialUI.Create("TextLabel",{
				ZIndex = IconInfoFrameZIndex+1;
				BackgroundTransparency = 1;
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Text = "Group : None";
				TextSize = 14;
				Font = AppFont;
				Position = UDim2.new(0,
					(IconInfoFrameSizeY / 2) + 30 + 6,
					0,
					32 + (18*2)
				);
				Size = UDim2.new(1,
					-(IconInfoFrameSizeY / 2) - 30 - 6,
					0,
					16
				);
				TextXAlignment = Enum.TextXAlignment.Left;
			});
			Insert = MaterialUI.Create("Button",{
				TextSize = 18;
				Font = AppFont;
				ZIndex = IconInfoFrameZIndex+3;
				Style = MaterialUI.CEnum.ButtonStyle.Text;
				--RoundSize = 
				Size = UDim2.new(0,60,0,IconInfoFrameSizeY - (18*3) - 30 - 4);
				Position = UDim2.new(1,-4,1,-2);
				AnchorPoint = Vector2.new(1,1);
				TextColor3 = Color3.fromRGB(0,165,255);
				Text = Language:GetText("Insert");
				MouseButton1Click = function()
					AddImage(Selected)
				end;
			});
			Set = MaterialUI.Create("Button",{
				TextSize = 18;
				Font = AppFont;
				ZIndex = IconInfoFrameZIndex+3;
				Style = MaterialUI.CEnum.ButtonStyle.Text;
				--RoundSize = 
				Size = UDim2.new(0,60,0,IconInfoFrameSizeY - (18*3) - 30 - 4);
				Position = UDim2.new(1,-68,1,-2);
				AnchorPoint = Vector2.new(1,1);
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Text = Language:GetText("Set");
				MouseButton1Click = function()
					SetImage(Selected)
				end;
			});
		});
	})
	
	--// 툴팁 Parent 지정
	Store.FavoriteIcon_ToolTip.Parent = Store.IconInfoFrameHolder
	Store.MenuIcon_ToolTip.Parent = Store.Frame
	Store.CloseIcon_ToolTip.Parent = Store.IconInfoFrameHolder
	Store.SearchIcon_ToolTip.Parent = Store.Frame
	
	--// 작은 택스트 래이블 크기(Y)
	local TextLabelSizeY = IconFrameSize.Y - IconSize - IconTopPadding
	
	--// 덤프 테이블 분해하기
	for Style,StyleItems in pairs(IconDump) do
		for Group,GroupItems in pairs(StyleItems) do
			--// 그룹 받는 그리드
			local GroupStore = {
				Frame = nil;
				Holder = nil;
			}
			GroupStore.Frame = MaterialUI.Create("Frame",{
				Size = UDim2.new(1,0,0,0);
				Parent = Store.IconHolder;
				BackgroundTransparency = 1;
				Name = Group;
			},{
				Div = MaterialUI.Create("Frame",{
					Size = UDim2.new(1,-40,0,1);
					Position = UDim2.new(0.5,0,0,-1);
					AnchorPoint = Vector2.new(0.5,0);
					BackgroundColor3 = Color3.fromRGB(127,127,127);
				});
				Text = MaterialUI.Create("TextLabel",{
					TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					TextXAlignment = Enum.TextXAlignment.Left;
					Font = AppFont;
					TextSize = 16;
					Text = string.upper(string.sub(Group,1,1)) .. string.sub(Group,2,#Group);
					Size = UDim2.new(1,-30,0,30);
					Position = UDim2.new(0.5,0,0,0);
					AnchorPoint = Vector2.new(0.5,0);
					BackgroundTransparency = 1;
				});
				Holder = MaterialUI.Create("Frame",{
					Position = UDim2.new(0,0,0,30);
					BackgroundTransparency = 1;
					Size = UDim2.new(1,0,1,0);
					WhenCreated = function(this)
						GroupStore.Holder = this
					end;
				},{
					Grid = MaterialUI.Create("UIGridLayout",{
						SortOrder = Enum.SortOrder.Name;
						CellSize = UDim2.new(0,IconFrameSize.X,0,IconFrameSize.Y);
						CellPadding = UDim2.new(0,5,0,5);
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						WhenCreated = function(this)
							this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
								GroupStore.Frame.Size = UDim2.new(1,0,0,this.AbsoluteContentSize.Y + 30 + 8)
							end)
						end;
					});
				});
			})
			
			--// 그룹들 창에 쓰일 버튼
			GroupStore.ListItem = MaterialUI.Create("TextButton",{
				Name = Group;
				Parent = Store.GroupListItemHolder;
				BackgroundTransparency = 1;
				Text = "";
				Size = UDim2.new(1,0,0,34);
				ZIndex = MenuZIndex;
				MouseButton1Click = function()
					AdvancedTween:RunTween(Store.IconHolder,{
						Time = 0.65;
						Easing = AdvancedTween.EasingFunctions.Exp2;
						Direction = AdvancedTween.EasingDirection.Out;
					},{
						CanvasPosition = Vector2.new(
							0,
							Store.IconHolder.CanvasPosition.Y + (GroupStore.Frame.AbsolutePosition.Y - Store.IconHolder.AbsolutePosition.Y)
						);
					})
					AdvancedTween:RunTween(Store.GroupListHolder,{
						Time = 0.4;
						Easing = AdvancedTween.EasingFunctions.Exp2;
						Direction = AdvancedTween.EasingDirection.Out;
					},{
						AnchorPoint = Vector2.new(1,0);
					})
				end;
			},{
				Div = MaterialUI.Create("Frame",{
					ZIndex = MenuZIndex;
					Size = UDim2.new(1,-16+2,0,1);
					Position = UDim2.new(0.5,-2,0,-1);
					AnchorPoint = Vector2.new(0.5,0);
					BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					BackgroundTransparency = 0.85;
				});
				Rippler = MaterialUI.Create("Rippler",{
					ZIndex = MenuZIndex;
				});
				TextLabel = MaterialUI.Create("TextLabel",{
					ZIndex = MenuZIndex;
					Text = Group;
					Size = UDim2.new(1,0,1,0);
					BackgroundTransparency = 1;
					Position = UDim2.new(0,8,0,0);
					Font = AppFont;
					TextSize = 15;
					TextXAlignment = Enum.TextXAlignment.Left;
					TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
				});
			})
			
			--// 그룹 아이템들 불러오기
			for IconName,Icon in pairs(GroupItems) do
				--// 아이템
				local IconNameRep = string.gsub(IconName,"_"," ")
				MaterialUI.Create("ImageButton",{
					MouseButton1Click = function()
						SelectIcon({
							Group = Group;
							Style = Style;
							IconName = IconNameRep;
							IconURL = Icon;
						})
					end;
					BackgroundTransparency = 1;
					Parent = GroupStore.Holder;
					ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
					ImageTransparency = 0.88;
					Name = IconNameRep;
					WhenCreated = function(this)
						MaterialUI:SetRound(this,8)
					end;
				},{
					Icon = MaterialUI.Create("ImageLabel",{
						SizeConstraint = Enum.SizeConstraint.RelativeXX;
						BackgroundTransparency = 1;
						Position = UDim2.new(0.5,0,0,IconTopPadding);
						AnchorPoint = Vector2.new(0.5,0);
						Image = Icon;
						ImageColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
						Size = UDim2.new(0,IconSize,0,IconSize);
					});
					Text = MaterialUI.Create("TextLabel",{
						Font = AppFont;
						BackgroundTransparency = 1;
						Position = UDim2.new(0.5,0,1,0);
						AnchorPoint = Vector2.new(0.5,1);
						Text = IconNameRep;
						TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
						Size = UDim2.new(1,0,0,TextLabelSizeY);
						TextTruncate = Enum.TextTruncate.AtEnd;
						ClipsDescendants = true;
						TextSize = 11;
					});
				})
				
				--// 미리로드
				--spawn(function()
				--	ContentProvider:PreloadAsync({Icon})
				--end)
			end
			
			--// 검색 글자 바뀔때
			local function Search_Group()
				local GroupVisible = false
				local Text = string.gsub(Store.SearchTextBox.Text,"_"," ")
				for _,Item in pairs(GroupStore.Holder:GetChildren()) do
					if Item:IsA("ImageButton") then
						Item.Visible = Text == "" or string.find(Item.Name,Text,1,true)
						GroupVisible = GroupVisible or Item.Visible
					end
				end
				GroupStore.Frame.Visible = GroupVisible
				GroupStore.ListItem.Visible = GroupVisible
			end
			Store.SearchTextBox:GetPropertyChangedSignal("Text"):Connect(Search_Group)
			Search_Group()
		end
	end
	
	--// 이전 스크롤 위치 불러오기
	Store.IconHolder.CanvasPosition = Vector2.new(0,SavedScrollPos);
	
	--// 아이콘 선택 함수 지정
	SelectIcon = function(IconInfo)
		Selected = IconInfo
		--SelectIcon({
		--	Group = Group;
		--	Style = Style;
		--	IconName = IconName;
		--	IconURL = Icon;
		--})
		Store.IconInfoFrameHolder.SelectedText.Text = Language:GetText("Selected"):format(IconInfo.IconName)
		Store.IconInfoFrameHolder.IconHolder.Icon.Image = IconInfo.IconURL
		Store.IconInfoFrameHolder.IDText.Text = Language:GetText("ImageID"):format(IconInfo.IconURL or "")
		Store.IconInfoFrameHolder.StyleText.Text = Language:GetText("Style"):format(IconInfo.Style or "")
		Store.IconInfoFrameHolder.GroupText.Text = Language:GetText("Group"):format(IconInfo.Group or "")
		
		local Favorited = false
		for _,v in pairs(Favorites) do
			if v.IconURL == Selected.IconURL then
				Favorited = true
				break
			end
		end
		Store.FavoriteIconButton.Icon = Favorited and FavoriteIcon.On or FavoriteIcon.Off
		
		AdvancedTween:RunTween(Store.IconInfoFrame,{
			Time = 0.3;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			AnchorPoint = Vector2.new(0,1);
		})
		AdvancedTween:StopTween(Store.IconInfoFrameHolder)
		Store.IconInfoFrameHolder.AnchorPoint = Vector2.new(0,0);
		AdvancedTween:RunTween(Store.IconInfoFrameHolder,{
			Time = 0.5; -- 시차
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			AnchorPoint = Vector2.new(0,1);
		})
		--IconInfo
	end
	
	--// 즐겨찾기 검색시 사라지도록
	local function RefreshFavoritesFrameVisible()
		Store.FavoritesFrame.Visible = Store.SearchTextBox.Text == ""
	end
	Store.SearchTextBox:GetPropertyChangedSignal("Text"):Connect(RefreshFavoritesFrameVisible)
	RefreshFavoritesFrameVisible()
	
	--// 즐겨찾기 리스트 불러오기
	for _,v in pairs(Favorites) do
		AddFavoriteListItem(v)
	end
	
	--// 예전 선택값 불러오기
	if Selected then
		SelectIcon(Selected)
	end
end

--// 처음로드
LoadGui()

--// 다른 창에서 데이터를 업데이트 한 경우를 위해 연속
spawn(function()
	while wait(5) do
		if UpdateFavoriteList then
			UpdateFavoriteList()
		end
	end
end)

--// 태마 바뀜 감지
settings().Studio.ThemeChanged:Connect(LoadGui)

--------------
--Unload
--------------
--// 플러그인 언로드 이벤트
function Unload()
	pcall(function()
		Data:Save("SavedScrollPos",SavedScrollPos)
		Data:Save("LastSearchStat",LastSearchStat)
		Data:Save("Selected",Selected)
		
		Data:Save("Favorites",Favorites)
		Favorites_UpdateKey = Util:MakeID()
		Data:Save("Favorites_UpdateKey",Favorites_UpdateKey)
	end)
end
plugin.Unloading:Connect(Unload)