local module = {}

function module:GetRobloxFonts()
	local RobloxFonts = {} do --// 로블록스의 모든 폰트들
		--// 가져오기
		local Fonts = Enum.Font:GetEnumItems()
		
		--// 이름으로 인덱싱
		for i,Font in pairs(Fonts) do
			RobloxFonts[i] = {
				Name = string.split(tostring(Font),".")[3];
				Font = Font;
			}
		end
		
		--// 소팅 (이름 순서대로 나열)
		table.sort(RobloxFonts,function(a,b)
			return a["Name"] < b["Name"]
		end)
	end
	return RobloxFonts
end

return module
