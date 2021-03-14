local module = {}

--// TODO : DEG RAD 모드 저장
--// TODO : 단축키 지정
--// TODO : 키보드 인풋 받기

local Memory = "0"

local Mode = ""
local BackNumber = "0"
local Number = "0"
local RadMode = true

local void = function()end

local UI = {
	--// 텍스트
	SetNumberText = void;
	SetModeText = void;
	SetBackNumberText = void;
	
	--// 이팩트
	EffectEq = void; --// = 키 이팩트
	EffectC = void; --// 모두 지우기 이팩트
	EffectCE = void; --// 박스 값만 지우기 이팩트
	EffectNumberChange = void; --// sin cos tan -/+ 같은 한번 누르면 바로 값이 나오는거
	EffectNumberClick = void; --// 숫자키와 지우기 키 클릭 이팩트
	EffectSetMode = void; --// 모드 바뀔때 이팩트
	EffectSetModeWithOutOtherEffect = void; --// 모드 만 바뀔때 이팩트
}
module.UI = UI

local SaveFn = {
	SaveRadMode = void;
}
module.SaveFn = SaveFn

--// -----------------------
--//  Calc function
--// -----------------------
local function Reverse(Number)
	return tostring( -tonumber(Number) )
end

local function Rad(Number)
	return tostring( math.rad( tonumber(Number) ) )
end

local function Deg(Number)
	return tostring( math.deg( tonumber(Number) ) )
end

local function Cos(Number)
	if RadMode then
		return tostring( math.cos( tonumber(Number) ) )
	else
		return tostring( math.cos( math.rad( tonumber(Number) ) ) )
	end
end

local function Sin(Number)
	if RadMode then
		return tostring( math.sin( tonumber(Number) ) )
	else
		return tostring( math.sin( math.rad( tonumber(Number) ) ) )
	end
end

local function Tan(Number)
	if RadMode then
		return tostring( math.tan( tonumber(Number) ) )
	else
		return tostring( math.tan( math.rad( tonumber(Number) ) ) )
	end
end

local function DoMod(X,Y)
	return tostring( math.fmod( X,Y ) )
end

local function DecToBin(Number)
	Number = tonumber(Number)
	
	if Number > 2147483647 then
		--// 오버플러
		error("Overflow")
	end
	
	local Bin = ""
	while Number > 0 do
		local Rest = math.fmod(Number,2)
		Bin = Bin .. Rest
		Number=(Number-Rest)/2
	end
	local Ret = string.reverse(tostring(Bin))
	return #Ret == 0 and "0" or Ret
end

local function BinToDec(Number)
	if #Number > 32 then
		--// 오버플러
		error("Overflow")
	end
	
	Number = string.reverse(Number)
	local sum = 0
	
	for i = 1, string.len(Number) do
		local num = string.sub(Number, i,i) == "1" and 1 or 0
		sum = sum + num * math.pow(2, i-1)
	end
	
	return tostring(sum)
	--return tostring(tonumber(Number,2))
end

local function Factorial(x,y)
	if x > 9999999 then
		error("Overflow")
	end
	local Index = 1
	for i = y or 1,x do
		Index = Index * i
	end
	return Index
end

local function Log(X,Y)
	return math.log(X,Y)
end

local function Exp(X)
	return tostring(math.exp(tonumber(X)))
end

--// -----------------------
--//  Value function
--// -----------------------

local function Calc()
	if Mode == "-" then
		--// 빼기
		Number = tonumber(BackNumber) - tonumber(Number)
	elseif Mode == "+" then
		--// 더하기
		Number = tonumber(BackNumber) + tonumber(Number)
	elseif Mode == "*" then
		--// 곱하기
		Number = tonumber(BackNumber) * tonumber(Number)
	elseif Mode == "/" then
		--// 나누기
		Number = tonumber(BackNumber) / tonumber(Number)
	elseif Mode == "^" then
		--// 제곱셈
		Number = tonumber(BackNumber) ^ tonumber(Number)
	elseif Mode == "!" then
		--// 펙토리얼
		Number = Factorial(tonumber(BackNumber),tonumber(Number))
	elseif Mode == "Mod" then
		--// 모드(나머지)
		Number = DoMod(tonumber(BackNumber),tonumber(Number))
	elseif Mode == "Log" then
		--// 로그
		Number = Log(tonumber(BackNumber),tonumber(Number))
	elseif Mode == "?" then
		--// 랜덤
		Number = math.random(tonumber(Number),tonumber(BackNumber))
	end
	Number = tostring(Number)
end

local function SetMode(NewMode,NewNumber)
	if Number == "Error" then
		Number = "0"
	end
	
	local OnlyModeChanged = Number == "0"
	
	if Mode == "" then
		BackNumber = Number
		Number = NewNumber or "0"
	elseif Number ~= "0" then
		local Pass = pcall(Calc)
		if Pass then
			BackNumber = Number
			Number = NewNumber or "0"
		else
			BackNumber = "0"
			Number = "Error"
			Mode = ""
			UI.SetModeText(Mode)
			UI.SetNumberText(Number)
			UI.SetBackNumberText(BackNumber)
			UI.EffectSetMode()
			return
		end
		UI.EffectNumberChange()
	end
	
	Mode = NewMode
	UI.SetModeText(Mode)
	UI.SetNumberText(Number)
	UI.SetBackNumberText(BackNumber)
	if OnlyModeChanged then
		UI.EffectSetModeWithOutOtherEffect()
	else
		UI.EffectSetMode()
	end
end

local function Remove0(Number)
	--// 앞부분의 쓸모없이 있는 0 을 제거 (05 처럼 적히지 않고 5 로 바로 적힘)
	if Number == "0" or (not tonumber(Number)) then
		return ""
	elseif Number == "-0" then
		return "-"
	elseif Number == "Error" then
		return ""
	end
	return Number
end

local KeyFn = {
	SetRadMode = function(IsRad)
		RadMode = IsRad
	end;
	Key_Zero = function() --// 0
		Number = Remove0(Number) .. "0"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_One = function() --// 1
		Number = Remove0(Number) .. "1"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Two = function() --// 2
		Number = Remove0(Number) .. "2"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Three = function() --// 3
		Number = Remove0(Number) .. "3"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Four = function() --// 4
		Number = Remove0(Number) .. "4"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Five = function() --// 5
		Number = Remove0(Number) .. "5"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Six = function() --// 6
		Number = Remove0(Number) .. "6"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Seven = function() --// 7
		Number = Remove0(Number) .. "7"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Eight = function() --// 8
		Number = Remove0(Number) .. "8"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Nine = function() --// 9
		Number = Remove0(Number) .. "9"
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Dot = function() --// . (소숫점)
		if string.find(Number,"%.") then
			if not tonumber(Number) then
				Number = "Error"
			else
				Number = tostring(math.floor(tonumber(Number)))
			end
		else
			Number = Number .. "."
		end
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Del = function() --// 지우기
		--// 오류의 경우 아에 0으로 시작
		if Number == "Error" then
			Number = "0"
		end
		if Number == "-0" then
			Number = "0"
		end
		
		--// 한글자 지우기
		Number = string.sub(Number,1,#Number - 1)
		
		if Number == "" then
			--// 만약 아무 글자도 없으면 0
			Number = "0"
		elseif Number == "-" then
			--// - 만 남으면 입력을 위해 -0 으로
			Number = "-0"
		end
		
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_Reverse = function() --// 부호 반대
		local Pass,RetValue = pcall( Reverse,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberClick()
	end;
	Key_CE = function() --// 입력창 지우기
		Number = "0"
		UI.SetNumberText(Number)
		UI.EffectCE()
	end;
	Key_C = function() --// 지우기
		Number = "0"
		BackNumber = "0"
		Mode = ""
		UI.SetModeText(Mode)
		UI.SetNumberText(Number)
		UI.SetBackNumberText(BackNumber)
		UI.EffectC()
	end;
	Key_Sub = function() --// 빼기
		SetMode("-")
	end;
	Key_Sum = function() --// 더하기
		SetMode("+")
	end;
	Key_Multiple = function() --// 곱하기
		SetMode("*")
	end;
	Key_Divide = function() --// 나누기
		SetMode("/")
	end;
	Key_Power = function() --// 제곱셈
		SetMode("^")
	end;
	Key_Fact = function() --// 펙토리얼
		SetMode("!","1")
	end;
	Key_Rand = function() --// 랜덤
		SetMode("?")
	end;
	Key_Mod = function() --// 랜덤
		SetMode("Mod")
	end;
	Key_Log = function() --// 랜덤
		SetMode("Log")
	end;
	Key_Exp = function() --// 싸인
		local Pass,RetValue = pcall( Exp,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Sin = function() --// 싸인
		local Pass,RetValue = pcall( Sin,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Cos = function() --// 코싸인
		local Pass,RetValue = pcall( Cos,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Tan = function() --// 탄젠트
		local Pass,RetValue = pcall( Tan,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Pi = function() --// 파이
		Number = "3.1415926535898"
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Dec = function() --// 데미칼(바이너리 to 십진)
		local Pass,RetValue = pcall( BinToDec,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Bin = function() --// 바이너리 (십진 to 바이너리)
		local Pass,RetValue = pcall( DecToBin,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Rad = function() --// 탄젠트
		local Pass,RetValue = pcall( Rad,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Deg = function() --// 탄젠트
		local Pass,RetValue = pcall( Deg,Number )
		if Pass then
			Number = RetValue
		else
			Number = "Error"
		end
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_Eq = function() --// EQ (=)
		if Number == "Error" then
			Number = "0"
		end
		
		-- - + * / ^ ! ? Mod
		local Pass = pcall(Calc)
		if not Pass then
			Number = "Error"
		end
		
		Mode = ""
		UI.SetModeText(Mode)
		
		BackNumber = "0"
		UI.SetNumberText(Number)
		UI.SetBackNumberText(BackNumber)
		UI.EffectEq()
	end;
	Key_M = function()
		Memory = Number
	end;
	Key_MR = function()
		Number = Memory
		UI.SetNumberText(Number)
		UI.EffectNumberChange()
	end;
	Key_MC = function()
		Memory = "0"
	end
}
module.KeyFn = KeyFn

function module:GetMode()
	return Mode
end
function module:GetNumber()
	return Number
end
function module:GetBackNumber()
	return BackNumber
end
function module:GetMemory()
	return Memory
end
function module:GetRadMode()
	return RadMode
end
function module:SetRadMode(New)
	RadMode = New
	SaveFn.SaveRadMode(New)
end

--function module:init(NewUI)
--	UI = NewUI
	
--	UI.SetNumberText(Number)
--	UI.SetBackNumberText(BackNumber)
--	UI.SetModeText(Mode)
	
--	return {
--		Mode = Mode;
--		BackNumber = BackNumber;
--		Number = Number;
--	}
--end

return module
