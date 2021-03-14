local module = {}

local LangName = game:GetService("LocalizationService").SystemLocaleId
local DefaultLang = "en-us"

local Lang do
	local LangFile = script:FindFirstChild(LangName)
	Lang = LangFile and require(LangFile) or {}
end
local Default = require(script:FindFirstChild(DefaultLang))

function module:GetText(Key)
	return Lang[Key] or Default[Key]
end

return module
