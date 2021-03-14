local module = {}

function module:Init(Data)
	local plugin = Data.Plugin
	local Interface = Data.Interface
	local SettingsHandle = Data.SettingsHandle
	local MaterialUI = Data.MaterialUI
	local Language = Data.Language
	local AdvancedTween = Data.AdvancedTween
	local PluginGuiInput = Data.PluginGuiInput
	local CustomScroll = Data.CustomScroll
	
	local Store = {}
	local Page = MaterialUI.Create("Frame",{
		Name = "Main";
		Parent = Interface;
		BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background);
		Size = UDim2.new(1,0,1,0);
		WhenCreated = function(this)
			settings().Studio.ThemeChanged:Connect(function()
				MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
				this.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.Background)
			end)
		end;
	},{
		MaterialUI.Create("Shadow");
		Holder = MaterialUI.Create("ScrollingFrame",{
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,1,-42);
			Position = UDim2.new(0,0,0,42);
			BorderSizePixel = 0;
			ScrollBarThickness = 4;
			WhenCreated = function(this)
				Store.Scroll = this
			end;
		},{
			List = MaterialUI.Create("UIListLayout",{
				WhenCreated = function(this)
					this:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						Store.Scroll.CanvasSize = UDim2.new(0,0,0,this.AbsoluteContentSize.Y)
					end)
				end;
			});
		});
		TopbarHolder = MaterialUI.Create("Frame",{
			--ClipsDescendants = true;
			BackgroundTransparency = 1;
			Size = UDim2.new(1,0,1,0);
		},{
			TopBar = MaterialUI.Create("Frame",{
				BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar);
				Size = UDim2.new(1,0,0,42);
				WhenCreated = function(this)
					settings().Studio.ThemeChanged:Connect(function()
						MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
						this.BackgroundColor3 = MaterialUI:GetColor(MaterialUI.Colors.TopBar)
					end)
				end;
			},{
				Icon = MaterialUI.Create("ImageLabel",{
					BackgroundTransparency = 1;
					Image = "http://www.roblox.com/asset/?id=6022668884";
					Size = UDim2.fromOffset(28,28);
					Position = UDim2.new(0,7,0.5,0);
					AnchorPoint = Vector2.new(0,0.5);
				});
				Text = MaterialUI.Create("TextLabel",{
					Text = "Profiler";
					Size = UDim2.new(1,0,1,0);
					Position = UDim2.new(0,42,0,0);
					Font = Enum.Font.Gotham;
					TextSize = 16;
					TextColor3 = Color3.fromRGB(255,255,255);
					TextXAlignment = Enum.TextXAlignment.Left;
					BackgroundTransparency = 1;
				});
				Shadow = MaterialUI.Create("Shadow");
			});
		});
	})
	
	local QProfiler = {}
	_G.QProfiler = QProfiler
	QProfiler.ButtonHolder = Page.Holder
	QProfiler.PageHolder = MaterialUI.Create("Frame",{
		Name = "Roots";
		Parent = Interface;
		Size = UDim2.fromScale(1,1);
		BackgroundTransparency = 1;
	})
	QProfiler.ToolTipIndex = -2147483647
	
	local MouseToolTip = script.Parent.MouseToolTip
	MouseToolTip.Parent = Interface
	QProfiler.MouseToolTip = MouseToolTip
	
	QProfiler.SettingsHandle = SettingsHandle
	QProfiler.CustomScroll = CustomScroll
end

return module
