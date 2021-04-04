local settings = {};

function settings.init(Info)
    local Data = Info.Data;

    local settingsTable = {};
    settings.settingsTable = settingsTable;

    -- data 는 self 호출이 있어야 넘어감
    settingsTable.FontSize = Data:Load("settingsfontSize"); -- display font size
    local BindToFontSizeChanged = {};
    settingsTable.BindToFontSizeChanged = function(func)
        local funcId = tostring(func);
        BindToFontSizeChanged[funcId] = func;
        return function()
            BindToFontSizeChanged[funcId] = nil;
        end,funcId;
    end;
    settingsTable.setFontSize = function(FontSize)
        -- 저장시키기
        Data:Save("settingsfontSize",FontSize);
        for _,func in pairs(BindToFontSizeChanged) do
            func(FontSize);
        end
    end;

    return settingsTable;
end

return settings;