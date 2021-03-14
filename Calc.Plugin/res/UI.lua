local module = {}

local TextService = game:GetService("TextService")
local void = function()end

--// 폰트
local AppFont = Enum.Font.Gotham
local ButtonTextSize = 18

--// 버튼 그리드(scale)
local SizeX = 1/4
local SizeY = 1/6

--// 맨 위 프레임 사이즈(offset)
local TopFrameSizeY = 85

--// 토글 프레임 사이즈(offset)
local FnToggleSizeX = 20

--// 편집 가능한 택스트 사이즈
local NumberSizeY = 40
local NumberTextSize = 20

--// 뒷 숫자 사이즈
local BackNumberSizeY = 28
local BackNumberTextSize = 16

--// Deg/Rad 선택기 크기
local DegAndRadFrameSizeX = 70

--// 간격
local TopFramePadding = {
	Top = 5;
	Bottom = 8;
	Right = 5;
	Left = 3;
}

--// --------------
--//  ZIndex
--// --------------

local TopFrameZIndex = 5000
local FnFrameZIndex = 4000
local Frame1ZIndex = 3000
local Frame2ZIndex = 2000
local FnToggleButtonZIndex = 1000

--// --------------
--//  Color
--// --------------

--// 가장 위에 결과,모드,뒷 숫자 나오는 프레임
local TopFrameColor = {
	Dark = Color3.fromRGB(35,35,35);
	Light = Color3.fromRGB(80,170,250);
}

--// 가장 위 프레임에 글자 색깔
local TopTextColor = {
	Dark = Color3.fromRGB(255,255,255);
	Light = Color3.fromRGB(255,255,255);
}

--// 숫자 입력기 있는 맨 처음 프레임
local Frame1Color = {
	Dark = Color3.fromRGB(50,50,50);
	Light = Color3.fromRGB(255,255,255);
}

--// - + 같은 계산 있는 2번째 프레임
local Frame2Color = {
	Dark = Color3.fromRGB(70,70,70);
	Light = Color3.fromRGB(235,235,235);
}

--// cos sin tan 같은 함수 있는 프레임
local FnFrameColor = {
	Dark = Color3.fromRGB(60,185,155);
	Light = Color3.fromRGB(60,185,155);
}

--// 버튼 글자 색
local TextColor = {
	Dark = Color3.fromRGB(255,255,255);
	Light = Color3.fromRGB(0,0,0);
}

--// Rad / Deg 선택기, 꺼짐 색깔
local RotModeDisabledColor = {
	Dark = Color3.fromRGB(105,105,105);
	Light = Color3.fromRGB(200,200,200);
}

--// Rad / Deg 선택기, 켜짐 색깔
local RotModeEnabledColor = {
	Dark = Color3.fromRGB(255,255,255);
	Light = Color3.fromRGB(0,0,0);
}

--// Rad / Deg 선택기, 배경 색깔
local RotModeBackgroundColor = {
	Dark = Color3.fromRGB(0,0,0);
	Light = Color3.fromRGB(255,255,255);
}

--// Rad / Deg 선택기, 구분선 색깔(디바이더)
local RotModeDivColor = {
	Dark = Color3.fromRGB(160,160,160);
	Light = Color3.fromRGB(80,80,80);
}

function module:init(Calc,Ripplers,Interface,plugin,Modules)
	--// 모듈
	local Calc = Modules.Calc
	local MaterialUI = Modules.MaterialUI
	local AdvancedTween = Modules.AdvancedTween
	
	--// 자동완성
	--local Calc = require(script.Parent.Calc)
	--local MaterialUI = require(script.Parent.Parent.lib.MaterialUI)
	--local AdvancedTween = require(script.Parent.Parent.lib.AdvancedTween)
	
	--// 이전 UI 클린업 ()
	Interface:ClearAllChildren()
	MaterialUI:CleanUp()
	
	--// 테마 지정
	MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
	
	--// 마우스 지정
	MaterialUI:UseDockWidget(Interface,plugin:GetMouse())
	
	--// 그리기
	local Store = {
		FnToggleButton = nil;
		FnFrame = nil;
		FnFrameHolder = nil;
		FnFrameCloseIcon = nil;
		ModeText = nil;
		NumberText = nil;
		NumberPointer = nil;
		BackNumberText = nil;
		DegAndRadFrame = nil;
	}
	
	local DrowButton = {
		new = function(Properties)
			return MaterialUI.Create("TextButton",{
				AutoButtonColor = false;
				Size = UDim2.new(Properties.GridSizeX,0,Properties.GridSizeY,0);
				Position = UDim2.new(
					Properties.GridSizeX*Properties.Pos.X - Properties.GridSizeX,
					0,
					Properties.GridSizeY*Properties.Pos.Y - Properties.GridSizeY,
					0
				);
				Text = Properties.Text;
				TextSize = ButtonTextSize;
				Font = AppFont;
				ZIndex = Properties.ZIndex;
				TextColor3 = TextColor[MaterialUI.CurrentTheme];
				BackgroundTransparency = 1;
				MouseButton1Click = Properties.ClickFn or void;
			},{
				MaterialUI.Create("Rippler",{
					ZIndex = Properties.ZIndex;
				},nil,function(this)
					Ripplers[Properties.Name] = function()
						this:Ripple()
					end
				end);
			});
		end
	}
	
	MaterialUI.Create("Frame",{
		Name = "Main";
		Size = UDim2.new(1,0,1,0);
		BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
		Parent = Interface;
	},{
		TopFrame = MaterialUI.Create("Frame",{
			Size = UDim2.new(1,0,0,TopFrameSizeY);
			ZIndex = TopFrameZIndex;
			BackgroundColor3 = TopFrameColor[MaterialUI.CurrentTheme]
		},{
			Shadow = MaterialUI.Create("Shadow",{
				ZIndex = TopFrameZIndex;
			});
			ModeTextHolder = MaterialUI.Create("Frame",{
				Size = UDim2.new(0,NumberSizeY,0,NumberSizeY);
				Position = UDim2.new(0,TopFramePadding.Left,1,-TopFramePadding.Bottom);
				AnchorPoint = Vector2.new(0,1);
				ZIndex = TopFrameZIndex;
				ClipsDescendants = true;
				BackgroundTransparency = 1;
			},{
				ModeText = MaterialUI.Create("TextLabel",{
					Text = Calc:GetMode();
					Font = AppFont;
					Size = UDim2.new(1,0,1,0);
					TextSize = NumberTextSize;
					TextColor3 = Color3.fromRGB(255,255,255);
					ZIndex = TopFrameZIndex;
					BackgroundTransparency = 1;
				},nil,function(this)
					Store.ModeText = this
				end)
			});
			NumberTextHolder = MaterialUI.Create("Frame",{
				Size = UDim2.new(1,-NumberSizeY-TopFramePadding.Left-TopFramePadding.Right-5,0,NumberSizeY);
				Position = UDim2.new(1,-TopFramePadding.Right,1,-TopFramePadding.Bottom);
				AnchorPoint = Vector2.new(1,1);
				ZIndex = TopFrameZIndex;
				ClipsDescendants = true;
				BackgroundTransparency = 1;
			},{
				NumberText = MaterialUI.Create("TextBox",{
					Text = Calc:GetNumber();
					Font = AppFont;
					Position = UDim2.new(1,-4,0,0);
					AnchorPoint = Vector2.new(1,0);
					TextSize = NumberTextSize;
					TextColor3 = Color3.fromRGB(255,255,255);
					BackgroundTransparency = 1;
					ZIndex = TopFrameZIndex;
					TextXAlignment = Enum.TextXAlignment.Left;
					TextEditable = false;
					ClearTextOnFocus = false;
					--Size = UDim2.new(1,0,1,0)
				},nil,function(this)
					Store.NumberText = this
					--this.TextBounds.X
					this.Size = UDim2.new(
						0,
						TextService:GetTextSize(this.Text,this.TextSize,this.Font,Vector2.new(math.huge,math.huge)).X,
						1,
						0
					)
				end);
				NumberPointer = MaterialUI.Create("Frame",{
					Size = UDim2.new(0,2,0,NumberTextSize+2);
					Position = UDim2.new(1,0,0.5,0);
					AnchorPoint = Vector2.new(1,0.5);
					BackgroundColor3 = Color3.fromRGB(255,255,255);
					BackgroundTransparency = 1;
					ZIndex = TopFrameZIndex
				},nil,function(this)
					Store.NumberPointer = this
				end)
			});
			BackNumberTextHolder = MaterialUI.Create("Frame",{
				Size = UDim2.new(1,-TopFramePadding.Left-TopFramePadding.Right,0,BackNumberSizeY);
				Position = UDim2.new(0,TopFramePadding.Left,0,TopFramePadding.Top);
				ZIndex = TopFrameZIndex;
				ClipsDescendants = true;
				BackgroundTransparency = 1;
			},{
				BackNumberText = MaterialUI.Create("TextLabel",{
					Text = Calc:GetBackNumber();
					Font = AppFont;
					TextSize = BackNumberTextSize;
					TextColor3 = Color3.fromRGB(255,255,255);
					BackgroundTransparency = 1;
					ZIndex = TopFrameZIndex;
					TextXAlignment = Enum.TextXAlignment.Right;
					Size = UDim2.new(1,0,1,0)
				},nil,function(this)
					Store.BackNumberText = this
					--this.TextBounds.X
				end)
			});
			DegAndRadFrame = MaterialUI.Create("TextButton",{
				Text = "";
				AutoButtonColor = false;
				Size = UDim2.new(0,DegAndRadFrameSizeX,0,BackNumberSizeY);
				Position = UDim2.new(0,TopFramePadding.Left,0,TopFramePadding.Top);
				BackgroundColor3 = TopFrameColor[MaterialUI.CurrentTheme];
				ClipsDescendants = true;
				ZIndex = TopFrameZIndex+1;
				Visible = false;
			},{
				Main = MaterialUI.Create("ImageLabel",{
					Size = UDim2.new(0,60,1,-2);
					Position = UDim2.new(0.5,0,0.5,0);
					AnchorPoint = Vector2.new(0.5,0.5);
					BackgroundTransparency = 1;
					ImageColor3 = RotModeBackgroundColor[MaterialUI.CurrentTheme];
					ZIndex = TopFrameZIndex+1;
				},{
					DEG = MaterialUI.Create("TextLabel",{
						Size = UDim2.new(0.5,0,1,0);
						Text = "DEG";
						TextSize = 11;
						Font = AppFont;
						BackgroundTransparency = 1;
						TextColor3 = RotModeEnabledColor[MaterialUI.CurrentTheme];
						ZIndex = TopFrameZIndex+1;
					});
					DIV = MaterialUI.Create("TextLabel",{
						Size = UDim2.new(1,0,1,0);
						Text = "/";
						TextSize = 15;
						Font = AppFont;
						BackgroundTransparency = 1;
						TextColor3 = RotModeDivColor[MaterialUI.CurrentTheme];
						ZIndex = TopFrameZIndex+1;
					});
					RAD = MaterialUI.Create("TextLabel",{
						Size = UDim2.new(0.5,0,1,0);
						Position = UDim2.new(0.5,0,0,0);
						Text = "RAD";
						TextSize = 11;
						Font = AppFont;
						BackgroundTransparency = 1;
						TextColor3 = RotModeEnabledColor[MaterialUI.CurrentTheme];
						ZIndex = TopFrameZIndex+1;
					});
				},function(this)
					MaterialUI:SetRound(this,50)
				end)
			},function(this)
				Store.DegAndRadFrame = this
			end);
		});
		
		Frame1 = MaterialUI.Create("Frame",{
			Position = UDim2.new(0,0,0,TopFrameSizeY);
			Size = UDim2.new(SizeX*3,-FnToggleSizeX/2,1,-TopFrameSizeY);
			ZIndex = Frame1ZIndex;
			BackgroundColor3 = Frame1Color[MaterialUI.CurrentTheme]
		},{
			Shadow = MaterialUI.Create("Shadow",{
				ZIndex = Frame1ZIndex;
			});
			M = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 1};
				Text = "M";
				Name = "M";
				ClickFn = Calc.KeyFn.Key_M;
				ZIndex = Frame1ZIndex;
			});
			MR = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 2,Y = 1};
				Text = "MR";
				Name = "MR";
				ClickFn = Calc.KeyFn.Key_MR;
				ZIndex = Frame1ZIndex;
			},nil,function(this)
				MaterialUI.Create("ToolTip",{
					Parent = this;
					Adornee = this;
					ZIndex = Frame1ZIndex + 50;
					BackgroundColor3 = Color3.fromRGB(30,30,30);
					TextFunction = function()
						return Calc:GetMemory()
					end;
				})
			end);
			MC = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 3,Y = 1};
				Text = "MC";
				Name = "MC";
				ClickFn = Calc.KeyFn.Key_MC;
				ZIndex = Frame1ZIndex;
			});
			C = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 2};
				Text = "C";
				Name = "C";
				ClickFn = Calc.KeyFn.Key_C;
				ZIndex = Frame1ZIndex;
			});
			CE = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 2,Y = 2};
				Text = "CE";
				Name = "CE";
				ClickFn = Calc.KeyFn.Key_CE;
				ZIndex = Frame1ZIndex;
			});
			Reverse = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 3,Y = 2};
				Text = "+/-";
				Name = "Reverse";
				ClickFn = Calc.KeyFn.Key_Reverse;
				ZIndex = Frame1ZIndex;
			});
			Seven = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 3};
				Text = "7";
				Name = "Seven";
				ClickFn = Calc.KeyFn.Key_Seven;
				ZIndex = Frame1ZIndex;
			});
			Eight = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 2,Y = 3};
				Text = "8";
				Name = "Eight";
				ClickFn = Calc.KeyFn.Key_Eight;
				ZIndex = Frame1ZIndex;
			});
			Nine = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 3,Y = 3};
				Text = "9";
				Name = "Nine";
				ClickFn = Calc.KeyFn.Key_Nine;
				ZIndex = Frame1ZIndex;
			});
			Four = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 4};
				Text = "4";
				Name = "Four";
				ClickFn = Calc.KeyFn.Key_Four;
				ZIndex = Frame1ZIndex;
			});
			Five = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 2,Y = 4};
				Text = "5";
				Name = "Five";
				ClickFn = Calc.KeyFn.Key_Five;
				ZIndex = Frame1ZIndex;
			});
			Six = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 3,Y = 4};
				Text = "6";
				Name = "Six";
				ClickFn = Calc.KeyFn.Key_Six;
				ZIndex = Frame1ZIndex;
			});
			One = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 5};
				Text = "1";
				Name = "One";
				ClickFn = Calc.KeyFn.Key_One;
				ZIndex = Frame1ZIndex;
			});
			Two = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 2,Y = 5};
				Text = "2";
				Name = "Two";
				ClickFn = Calc.KeyFn.Key_Two;
				ZIndex = Frame1ZIndex;
			});
			Three = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 3,Y = 5};
				Text = "3";
				Name = "Three";
				ClickFn = Calc.KeyFn.Key_Three;
				ZIndex = Frame1ZIndex;
			});
			Dot = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 6};
				Text = ".";
				Name = "Dot";
				ClickFn = Calc.KeyFn.Key_Dot;
				ZIndex = Frame1ZIndex;
			});
			Zero = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 2,Y = 6};
				Text = "0";
				Name = "Zero";
				ClickFn = Calc.KeyFn.Key_Zero;
				ZIndex = Frame1ZIndex;
			});
			Eq = MaterialUI.Create(DrowButton,{
				GridSizeX = 1/3;
				GridSizeY = SizeY;
				Pos = {X = 3,Y = 6};
				Text = "=";
				Name = "Eq";
				ClickFn = Calc.KeyFn.Key_Eq;
				ZIndex = Frame1ZIndex;
			});
		});
		
		Frame2 = MaterialUI.Create("Frame",{
			Position = UDim2.new(SizeX*3,-FnToggleSizeX/2,0,TopFrameSizeY);
			Size = UDim2.new(SizeX,-FnToggleSizeX/2,1,-TopFrameSizeY);
			ZIndex = Frame2ZIndex;
			BackgroundColor3 = Frame2Color[MaterialUI.CurrentTheme]
		},{
			Shadow = MaterialUI.Create("Shadow",{
				ZIndex = Frame2ZIndex;
			});
			Del = MaterialUI.Create(DrowButton,{
				GridSizeX = 1;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 1};
				Text = "Del";
				Name = "Del";
				ClickFn = Calc.KeyFn.Key_Del;
				ZIndex = Frame2ZIndex;
			});
			Power = MaterialUI.Create(DrowButton,{
				GridSizeX = 1;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 2};
				Text = "^";
				Name = "Power";
				ClickFn = Calc.KeyFn.Key_Power;
				ZIndex = Frame2ZIndex;
			});
			Divide = MaterialUI.Create(DrowButton,{
				GridSizeX = 1;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 3};
				Text = "/";
				Name = "Divide";
				ClickFn = Calc.KeyFn.Key_Divide;
				ZIndex = Frame2ZIndex;
			});
			Multiple = MaterialUI.Create(DrowButton,{
				GridSizeX = 1;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 4};
				Text = "*";
				Name = "Multiple";
				ClickFn = Calc.KeyFn.Key_Multiple;
				ZIndex = Frame2ZIndex;
			});
			Sub = MaterialUI.Create(DrowButton,{
				GridSizeX = 1;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 5};
				Text = "-";
				Name = "Sub";
				ClickFn = Calc.KeyFn.Key_Sub;
				ZIndex = Frame2ZIndex;
			});
			Sum = MaterialUI.Create(DrowButton,{
				GridSizeX = 1;
				GridSizeY = SizeY;
				Pos = {X = 1,Y = 6};
				Text = "+";
				Name = "Sum";
				ClickFn = Calc.KeyFn.Key_Sum;
				ZIndex = Frame2ZIndex;
			});
		});
		
		FnToggleButton = MaterialUI.Create("TextButton",{
			AutoButtonColor = false;
			Text = "";
			Position = UDim2.new(1,-FnToggleSizeX,0,TopFrameSizeY);
			Size = UDim2.new(0,FnToggleSizeX,1,-TopFrameSizeY);
			BackgroundColor3 = FnFrameColor[MaterialUI.CurrentTheme];
		},{
			Ripple = MaterialUI.Create("Rippler");
			Icon = MaterialUI.Create("ImageLabel",{
				AnchorPoint = Vector2.new(0.5,0.5);
				Position = UDim2.new(0.5,0,0.5,0);
				Rotation = 90;
				BackgroundTransparency = 1;
				Size = UDim2.new(0,FnToggleSizeX,0,FnToggleSizeX);
				Image = "http://www.roblox.com/asset/?id=5820145760";
				ImageColor3 = Color3.fromRGB(255,255,255);
			});
		},function(this)
			Store.FnToggleButton = this
		end);
		
		FnFrameHolder = MaterialUI.Create("TextButton",{
			Text = "";
			AutoButtonColor = false;
			BackgroundColor3 = Color3.fromRGB(0,0,0);
			BackgroundTransparency = 0.6;
			Size = UDim2.new(1,0,1,-TopFrameSizeY);
			Position = UDim2.new(0,0,0,TopFrameSizeY);
			ZIndex = FnFrameZIndex;
			Visible = false;
		},{
			FnFrame = MaterialUI.Create("Frame",{
				Size = UDim2.new(SizeX*2,FnToggleSizeX,1,0);
				Position = UDim2.new(1,0,0,0);
				AnchorPoint = Vector2.new(1,0);
				BackgroundColor3 = FnFrameColor[MaterialUI.CurrentTheme];
				ZIndex = FnFrameZIndex;
			},{
				Shadow = MaterialUI.Create("Shadow",{
					ZIndex = FnFrameZIndex;
				});
				Icon = MaterialUI.Create("ImageLabel",{
					AnchorPoint = Vector2.new(0,0.5);
					Position = UDim2.new(0,0,0.5,0);
					Rotation = -90;
					BackgroundTransparency = 1;
					Size = UDim2.new(0,FnToggleSizeX,0,FnToggleSizeX);
					Image = "http://www.roblox.com/asset/?id=5820145760";
					ImageColor3 = Color3.fromRGB(255,255,255);
					ZIndex = FnFrameZIndex;
				},nil,function(this)
					Store.FnFrameCloseIcon = this
				end);
				Holder = MaterialUI.Create("Frame",{
					Size = UDim2.new(1,-FnToggleSizeX,1,0);
					Position = UDim2.new(0,FnToggleSizeX,0,0);
					BackgroundTransparency = 1;
				},{
					Cos = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 1,Y = 1};
						Text = "Cos";
						Name = "Cos";
						ClickFn = Calc.KeyFn.Key_Cos;
						ZIndex = FnFrameZIndex;
					});
					Sin = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 2,Y = 1};
						Text = "Sin";
						Name = "Sin";
						ClickFn = Calc.KeyFn.Key_Sin;
						ZIndex = FnFrameZIndex;
					});
					Tan = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 1,Y = 2};
						Text = "Tan";
						Name = "Tan";
						ClickFn = Calc.KeyFn.Key_Tan;
						ZIndex = FnFrameZIndex;
					});
					Pi = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 2,Y = 2};
						Text = "Pi";
						Name = "Pi";
						ClickFn = Calc.KeyFn.Key_Pi;
						ZIndex = FnFrameZIndex;
					});
					Log = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 1,Y = 3};
						Text = "Log";
						Name = "Log";
						ClickFn = Calc.KeyFn.Key_Log;
						ZIndex = FnFrameZIndex;
					});
					Exp = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 2,Y = 3};
						Text = "Exp";
						Name = "Exp";
						ClickFn = Calc.KeyFn.Key_Exp;
						ZIndex = FnFrameZIndex;
					});
					Bin = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 1,Y = 4};
						Text = "Bin";
						Name = "Bin";
						ClickFn = Calc.KeyFn.Key_Bin;
						ZIndex = FnFrameZIndex;
					});
					Dec = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 2,Y = 4};
						Text = "Dec";
						Name = "Dec";
						ClickFn = Calc.KeyFn.Key_Dec;
						ZIndex = FnFrameZIndex;
					});
					Rad = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 1,Y = 5};
						Text = "Rad";
						Name = "Rad";
						ClickFn = Calc.KeyFn.Key_Rad;
						ZIndex = FnFrameZIndex;
					});
					Deg = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 2,Y = 5};
						Text = "Deg";
						Name = "Deg";
						ClickFn = Calc.KeyFn.Key_Deg;
						ZIndex = FnFrameZIndex;
					});
					Mod = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 1,Y = 6};
						Text = "Mod";
						Name = "Mod";
						ClickFn = Calc.KeyFn.Key_Mod;
						ZIndex = FnFrameZIndex;
					});
					Fact = MaterialUI.Create(DrowButton,{
						GridSizeX = 1/2;
						GridSizeY = SizeY;
						Pos = {X = 2,Y = 6};
						Text = "!";
						Name = "Fact";
						ClickFn = Calc.KeyFn.Key_Fact;
						ZIndex = FnFrameZIndex;
					});
				});
			},function(this)
				Store.FnFrame = this
			end);
		},function(this)
			Store.FnFrameHolder = this
		end);
	})
	
	--// RAD 모드
	local function RefreshRadMode(New)
		Calc:SetRadMode(New)
		
		Store.DegAndRadFrame.Main.DEG.TextColor3 = 
			New and 
			RotModeDisabledColor[MaterialUI.CurrentTheme] or 
			RotModeEnabledColor[MaterialUI.CurrentTheme]
		
		Store.DegAndRadFrame.Main.RAD.TextColor3 = 
			New and 
			RotModeEnabledColor[MaterialUI.CurrentTheme] or 
			RotModeDisabledColor[MaterialUI.CurrentTheme]
	end
	RefreshRadMode(Calc:GetRadMode())
	
	Store.DegAndRadFrame.MouseButton1Click:Connect(function()
		RefreshRadMode(not Calc:GetRadMode())
	end)
	
	
	--// Fn 메뉴 열기
	local function OpenFnFrame()
		Store.DegAndRadFrame.Visible = true
		AdvancedTween:StopTween(Store.FnFrame)
		Store.FnFrame.Position = UDim2.new(1,-FnToggleSizeX,0,0);
		Store.FnFrame.AnchorPoint = Vector2.new(0,0)
		
		AdvancedTween:StopTween(Store.FnFrameHolder)
		Store.FnFrameHolder.BackgroundTransparency = 1;
		Store.FnFrameHolder.Visible = true
		
		AdvancedTween:StopTween(Store.FnFrameCloseIcon)
		Store.FnFrameCloseIcon.Rotation = 90
		
		AdvancedTween:RunTween(Store.FnFrameHolder,{
			Time = 0.35;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			BackgroundTransparency = 0.6;
		})
		
		AdvancedTween:RunTween(Store.FnFrame,{
			Time = 0.35;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Position = UDim2.new(1,0,0,0);
			AnchorPoint = Vector2.new(1,0);
		})
		
		AdvancedTween:RunTween(Store.FnFrameCloseIcon,{
			Time = 0.35;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Rotation = -90;
		})
	end
	Store.FnToggleButton.MouseButton1Click:Connect(OpenFnFrame)
	
	--// Fn 메뉴 닫기
	local function CloseFnFrame()
		Store.DegAndRadFrame.Visible = false
		AdvancedTween:RunTween(Store.FnFrameHolder,{
			Time = 0.35;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			BackgroundTransparency = 1;
		},function()
			Store.FnFrameHolder.Visible = false
		end)
		AdvancedTween:RunTween(Store.FnFrame,{
			Time = 0.35;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Position = UDim2.new(1,-FnToggleSizeX,0,0);
			AnchorPoint = Vector2.new(0,0)
		})
		AdvancedTween:RunTween(Store.FnFrameCloseIcon,{
			Time = 0.35;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Rotation = 90;
		})
	end
	Store.FnFrameHolder.MouseButton1Click:Connect(CloseFnFrame)
	
	--// 함수 목록 아이템은 누르면 닫힘
	for _,Item in pairs(Store.FnFrame.Holder:GetChildren()) do
		Item.MouseButton1Click:Connect(function()
			CloseFnFrame()
		end)
	end
	
	--// UI 등록
	Calc.UI.SetBackNumberText = function(Text)
		Store.BackNumberText.Text = Text
	end
	Calc.UI.SetModeText = function(Text)
		Store.ModeText.Text = Text
	end
	Calc.UI.SetNumberText = function(Text)
		Store.NumberText.Text = Text
	end
	
	local function ModeClearEffect()
		AdvancedTween:StopTween(Store.ModeText)
		Store.ModeText.Position = UDim2.new(0,0,1,0);
		
		AdvancedTween:RunTween(Store.ModeText,{
			Time = 0.4;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Position = UDim2.new(0,0,0,0);
		})
	end
	local function NumberClearEffect()
		AdvancedTween:StopTween(Store.NumberText)
		Store.NumberText.Position = UDim2.new(1,-4,1,0);
		Store.NumberText.Size = UDim2.new(0,Store.NumberText.TextBounds.X,1,0);
		
		AdvancedTween:RunTween(Store.NumberText,{
			Time = 0.4;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Position = UDim2.new(1,-4,0,0);
		})
	end
	local function BackNumberClearEffect()
		AdvancedTween:StopTween(Store.BackNumberText)
		Store.BackNumberText.Position = UDim2.new(0,0,1,0);
		
		AdvancedTween:RunTween(Store.BackNumberText,{
			Time = 0.4;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Position = UDim2.new(0,0,0,0);
		})
	end
	
	--// 모드만 바뀔때 이팩트
	Calc.UI.EffectSetModeWithOutOtherEffect = function()
		ModeClearEffect()
	end
	
	--// 이팩트
	Calc.UI.EffectSetMode = function()
		ModeClearEffect()
		NumberClearEffect()
		BackNumberClearEffect()
	end
	Calc.UI.EffectC = function()
		ModeClearEffect()
		NumberClearEffect()
		BackNumberClearEffect()
	end
	Calc.UI.EffectCE = function()
		NumberClearEffect()
	end
	Calc.UI.EffectNumberChange = function()
		NumberClearEffect()
	end
	Calc.UI.EffectEq = function()
		ModeClearEffect()
		NumberClearEffect()
		BackNumberClearEffect()
	end
	
	--// 한글자 한글자씩 숫자가 바뀔때 이팩트
	Calc.UI.EffectNumberClick = function(Text)
		AdvancedTween:RunTween(Store.NumberText,{
			Time = 0.3;
			Easing = AdvancedTween.EasingFunctions.Exp2;
			Direction = AdvancedTween.EasingDirection.Out;
		},{
			Size = UDim2.new(0,Store.NumberText.TextBounds.X,1,0);
		})
	end
	--Calc.UI.EffectSetMode
	
	local FocusIndex = 0
	
	local PointerEffect = function()
		--// 포인터 반짝임
		local NowFocusIndex = FocusIndex
		while true do
			if NowFocusIndex ~= FocusIndex then
				break
			end
			AdvancedTween:RunTween(Store.NumberPointer,{
				Time = 0.5,
				Easing = AdvancedTween.EasingFunctions.Exp2,
				Direction = AdvancedTween.EasingDirection.Out
			},{
				BackgroundTransparency = 0;
			})
			wait(0.5)
			if NowFocusIndex ~= FocusIndex then
				break
			end
			AdvancedTween:RunTween(Store.NumberPointer,{
				Time = 0.5,
				Easing = AdvancedTween.EasingFunctions.Exp2,
				Direction = AdvancedTween.EasingDirection.Out
			},{
				BackgroundTransparency = 1;
			})
			wait(0.5)
		end
	end
	
	--// 창이 포커스됨
	local WindowFocusConnection = Interface.WindowFocused:Connect(function()
		FocusIndex = FocusIndex + 1
		--// 포인터 반짝임
		spawn(PointerEffect)
	end)
	
	--// 창이 언 포커스됨
	local WindowUnFocusConnection = Interface.WindowFocusReleased:Connect(function()
		FocusIndex = FocusIndex + 1
		AdvancedTween:StopTween(Store.NumberPointer)
		Store.NumberPointer.BackgroundTransparency = 1
	end)
	
	local function UnloadUI()
		if WindowFocusConnection then
			WindowFocusConnection:Disconnect()
			WindowFocusConnection = nil
		end
		if WindowUnFocusConnection then
			WindowUnFocusConnection:Disconnect()
			WindowUnFocusConnection = nil
		end
	end
	
	return UnloadUI
end
return module
