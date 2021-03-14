local module = {}

local SecondsToHours = 3600
local SecondsToMinutes = 60

function module:TickToTime(Tick)
	local TimeTable = {
		Hours = math.floor(Tick/SecondsToHours);
		Minutes = math.floor(Tick/SecondsToMinutes%60);
		Seconds = math.floor(Tick%60);
	}
	
	return TimeTable
end

local WORD = {
	"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
	"1","2","3","4","5","6","7","8","9","0"
}
function module:MakeID()
	local ID = ""
	for _ = 1,8 do
		ID = ID .. WORD[math.random(1,#WORD)]
	end
	return ID
end

return module
