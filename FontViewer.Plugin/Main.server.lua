local plugin = plugin
if not plugin then
	--// 플러그인이 아닌데 이 코드가 실행되면 바로 멈춰줌(태스팅 모드에서)
	return
end

local AppInfo = {
	-- APP INFO
	["AppIcon"] = "http://www.roblox.com/asset/?id=5942546820";
	["AppIconLight"] = "http://www.roblox.com/asset/?id=5942546942"; -- for toolbar light mode
	["AppName"] = "FontViewer";
	["AppId"] = "qwreey.plugins.fontviewer";
	
	-- PLUGIN GROUP
	["ToolbarId"] = "qwreey.plugins.toolbarprovider";
	["ToolbarName"] = "Qwreey's plugins";
	
	--BUTTON
	["ButtonText"] = "Font Viewer";
	["ButtonHoverText"] = nil;
	
	-- INTERFACE
	["InterfaceMiniSize"] = {X=150,Y=150};
	["InterfaceInitSize"] = {X=220,Y=300};
	["InterfaceDefaultFace"] = Enum.InitialDockState.Right;
	
	-- OTHER
	["Version"] = 13;
	["SplashIconSize"] = UDim2.new(0,70,0,70);
	["BypassSplash"] = false;
}

--------------
--import
--------------
--// 로블록스 서비스 불러오기(import)
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")

--// 모듈 불러오기
local Util = require(script.lib.Util)
local MaterialUI = require(script.lib.MaterialUI)
local Data = require(script.lib.Data):SetUp(plugin)
local AdvancedTween = require(script.lib.AdvancedTween)
local ToolbarCombiner = require(script.lib.ToolbarCombiner)

local License = require(script.License)
local LicenseViewer = require(script.res.LicenseViewer)

local Language = require(script.res.Language)
local RobloxFonts = Util:GetRobloxFonts()

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
--Main Ui
--------------
--// 줄임말 지정(해놓고 안썼다는,,, 외워버려서)
--MaterialUI:SetPropertiesAlias({
--	Par = "Parent";
--	Pos = "Position";
--	Sz = "Size";
--	Tx = "Text";
--})

--// 뒤에 Light,Semibold,Bold,Black,Italic 붇는거 모아줌
local Footer = {"Italic","Light","Semibold","Bold","Black"}

--// 코드 시작
local Main
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
	
	--// 리소스 불러오기
	local UIList = script.res.UIList:Clone()
	local ResFontFrame = script.res.FontFrame
	local ResFontFrame_Child = script.res.FontFrame_Child
	
	--// 글자에 태마 속성 적용
	ResFontFrame.Preview.TextColor3 = MaterialUI:GetColor("TextColor")
	ResFontFrame.FontName.TextColor3 = MaterialUI:GetColor("TextColor")
	ResFontFrame.Div.BackgroundColor3 = MaterialUI:GetColor("TextColor")
	
	ResFontFrame_Child.Preview.TextColor3 = MaterialUI:GetColor("TextColor")
	ResFontFrame_Child.FontName.TextColor3 = MaterialUI:GetColor("TextColor")
	ResFontFrame_Child.Div.BackgroundColor3 = MaterialUI:GetColor("TextColor")
	ResFontFrame_Child.ChildLine.BackgroundColor3 = MaterialUI:GetColor("TextColor")
	
	--// UI 드로잉(OOP/Roact 로 구현된 ui)
	Main = MaterialUI.Create("Frame",{
		Name = "Main";
		Parent = Interface;
		Size = UDim2.new(1,0,1,0);
		Position = UDim2.new(0,0,0,0);
		BackgroundColor3 = MaterialUI:GetColor("Background");
	},{
		TopBar = MaterialUI.Create("Frame",{
			Name = "TopBar";
			Size = UDim2.new(1,0,0,42);
			Position = UDim2.new(0,0,0,0);
			BackgroundColor3 = MaterialUI:GetColor("TopBar")
		},{
			Shadow = MaterialUI.Create("Shadow");
			TextField = MaterialUI.Create("TextField",{
				Size = UDim2.new(1,-10,0,30);
				Position = UDim2.new(0.5,0,0.5,2);
				AnchorPoint = Vector2.new(0.5,0.5);
				Text = Data:Load("LastText") or "Hello World";
				Style = MaterialUI.CEnum.TextFieldStyle.Text;
				PlaceholderText = Language:GetText("PreviewText")--"Preview text"
			},nil,function(this)
				--// 콜백 함수로써, 현재 개체를 반환함(Create 의 4번째 인수)
				Store.TextBox = this
				
				this.TextChanged:Connect(function()
					Data:Save("LastText",this.Text)
				end)
				
				if MaterialUI.CurrentTheme == "Light" then
					--// 라이트테마에선 택스트박스가 잘 안보여서 색깔을 좀 바꿔줌
					this.OffColor3 = Color3.fromRGB(30,30,30)
					this.OnColor3 = Color3.fromRGB(255,255,255)
				end
			end);
		});
		Holder = MaterialUI.Create("Frame",{
			Name = "Holder";
			Size = UDim2.new(1,0,1,-42);
			Position = UDim2.new(0,0,0,42);
			BackgroundTransparency = 1;
		},{
			Holder_Font = MaterialUI.Create("ScrollingFrame",{ --// 실제 폰트 미리보기가 담기는곳
				Name = "Holder_Font";
				Size = UDim2.new(1,0,1,0);
				Position = UDim2.new(0,0,0,0);
				BackgroundTransparency = 1;
				BorderSizePixel = 0;
				ScrollBarImageTransparency = 0.2;
				ScrollBarThickness = 6;
				--// 스크롤바 색상 지정
				ScrollBarImageColor3 = MaterialUI:GetColor("TextColor");
			},{UIList},function(this)
				Store.Scroll = this
				UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					--// 캔버스 크기 조정
					this.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y)
				end)
			end)
		})
	})
	
	--// Light,Semibold,Bold,Black,Italic 가 붇은 폰트가
	--// 두번 로드됨을 막음 (한번에 묶기 위해 사용됨)
	local ByPass = {}
	
	--// 드로잉 될 인덱스
	local Index = 0
	
	--// 폰트 하나가 담길 버튼(개체화)
	local function FontFrame(Font,IsChild)
		--// IsChild : SourceSansBold 가 SourceSans 에 포함되는것과 같이
		--// 상속된 폰트인가를 말함
		
		if ByPass[Font] then
			return
		end
		ByPass[Font] = true
		
		--// Enum 은 tostring 하면 Enum.Font.Code 와 같이 변환됨,
		--// 즉 . 를 기점으로 나누고 3번째를 가져옴, (이름을 가져옴)
		local FontName = string.split(tostring(Font),".")[3]
		
		local this = IsChild and ResFontFrame_Child:Clone() or ResFontFrame:Clone()
		
		this.Parent = Store.Scroll
		this.FontName.Text = FontName
		this.Preview.Font = Font
		this.LayoutOrder = Index
		Index = Index + 1
		
		--// 리플러, 마우스에서 잉크가 퍼저 나가는 그 효과를 구현하기 위한 구현자
		local Rippler = MaterialUI.Rippler_New(this)
		--// 리플러가 UIPadding 을 무시하도록 함
		Rippler.Position = UDim2.new(0,IsChild and -25 or -10,0,0)
		Rippler.Size = UDim2.new(1,IsChild and 25 or 10,1,0)
		
		local function Refresh()
			--// 미리보기 글자가 변경되었을때 실행됨
			this.Preview.Text = Store.TextBox.Text
		end
		Store.TextBox.TextChanged:Connect(Refresh)
		Refresh()
		
		--// 버튼이 클릭되었을때, 탐색기에 선택된 아이템들의 폰트를 변경합니다
		--// 참고 : 개체가 사라지면 모든 연결이 해제되므로 Disconnect를 호출할 필요가 없습니다
		this.MouseButton1Click:Connect(function()
			local SelectTable = Selection:Get()
			if SelectTable == nil or #SelectTable == 0 then
				return
			end
			
			History:SetWaypoint("Setting font of selection")
			for _,Selected in pairs(SelectTable) do
				if Selected:IsA("TextButton") or Selected:IsA("TextLabel") or Selected:IsA("TextBox") then
					--// 택스트 개체는 가상 상속된 개채가 없습니다,
					--// GuiObject 와 같이 상속 개체 모두 확인이 불가능합니다
					
					--// 폰트 적용
					
					--// 웨이 포인트를 통해 컨트롤 Z 가 가능하도록 함 (변경 녹화 시작)
					Selected.Font = Font
					
					--// 변경 녹화 끝
				end
			end
			History:SetWaypoint("Set font of selection")
		end)
		
		if not IsChild then
			--// 만약 footer 가 붇지 않은 폰트라면
			--// 지금 폰트 이름에 footer 를 붇여서 한번 더 검색함(파생 폰트를 가져옴)
			for _,Str in pairs(Footer) do
				local ChildFont
				for _,FontTable in pairs(RobloxFonts) do
					if FontTable.Name == FontName .. Str then
						ChildFont = FontTable.Font
						break
					end
				end
				
				if ChildFont then
					FontFrame(ChildFont,true)
				end
			end
		end
	end

	for _,FontTable in pairs(RobloxFonts) do
		--// 모든 폰트 불러오기
		
		--// Footer 가 붇은 폰트는 건너뜀(나중에 로드)
		local Pass = false
		for _,Str in pairs(Footer) do
			if string.find(FontTable["Name"],".-" .. Str) then
				Pass = true
				break
			end
		end
		if Pass then
			continue
		end
		
		--// 불러오기
		FontFrame(FontTable["Font"],false)
	end
end

--// 태마 바뀜 감지
settings().Studio.ThemeChanged:Connect(LoadGui)

--// 처음로드
LoadGui()

--------------
--Unload
--------------
function Unload()
	pcall(function()
		--// 플러그인 언로드 이벤트
		
	end)
end
plugin.Unloading:Connect(Unload)