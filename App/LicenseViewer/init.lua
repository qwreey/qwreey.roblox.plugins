local module = {}
local Page
local PageLoaded = false

local PageIndex = 50

function module:Init(SettingsHandle,MaterialUI,License,Language)
	--// 페이지 타이틀 얻어오기(로컬라이징)
	local Text = Language and Language:GetText("OpenSourceLicense") or "Open Source License"
	
	--// 상위 페이지 만들기
	Page = SettingsHandle:AddNewPage({
		--// 라이선스 뷰어 페이지
		ZIndex = PageIndex*0;
		Text = Text;
		OpenButton = SettingsHandle:AddNewButton({
			--// 최상위 설정 페이지에 라이선스 뷰어 열기 버튼 만들기
			Text = Text;
			LayoutOrder = 500;
			Icon = "http://www.roblox.com/asset/?id=6013545052";
		});
	})
	
	--// 페이지가 랜더 될 때 드로잉
	Page:GetPropertyChangedSignal("Visible"):Connect(function()
		--// 이미 로딩되었는지, 랜더되는 중인지 확인
		if (not Page.Visible) or PageLoaded then
			return
		end
		PageLoaded = true
		
		--// 각각의 페이지 생성
		for Name,Info in pairs(License) do
			local ThisPage = SettingsHandle:AddNewPage({
				--// 이 라이선스에 대한 페이지
				Text = Name;
				ZIndex = PageIndex*1;
				--Parent = Page;
				OpenButton = SettingsHandle:AddNewButton({
					--// 상위 페이지에 버튼 만들기
					Text = Name;
					Image = nil;
					Parent = Page.Holder;
				});
				XScroll = true;
			})
			
			MaterialUI.Create("TextBox",{
				Parent = ThisPage.Holder;
				Text = ("Creator : %s \nSummary : %s \nURL : %s\n\n%s"):format(
					Info.Creator,
					Info.Summary,
					Info.URL,
					Info.Raw
				);
				ZIndex = PageIndex*1;
				TextSize = 12;
				BackgroundTransparency = 1;
				TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor);
				Font = Enum.Font.Code;
				TextEditable = false;
				ClearTextOnFocus = false;
				NotTagging = true;
				TextXAlignment = Enum.TextXAlignment.Left;
				WhenCreated = function(this)
					settings().Studio.ThemeChanged:Connect(function()
						MaterialUI.CurrentTheme = tostring(settings().Studio.Theme)
						this.TextColor3 = MaterialUI:GetColor(MaterialUI.Colors.TextColor)
					end)
					local function Refresh()
						this.Size = UDim2.fromOffset(
							this.TextBounds.X,
							this.TextBounds.Y
						)
					end
					Refresh()
					this:GetPropertyChangedSignal("TextBounds"):Connect(Refresh)
				end;
			})
		end
	end)
end

return module
