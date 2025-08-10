--[[
    警告：注意！此脚本尚未经过ScriptBlox验证。使用风险自负！
]]
loadstring(game:HttpGet(("https://raw.githubusercontent.com/REDzHUB/LibraryV2/main/redzLib")))()
MakeWindow({
    Hub = {
        Title = "透视功能",  -- 原"Esp"
        Animation = "by thaibao7444"  -- 保留作者信息
    },
    Key = {
        KeySystem = false,
        Title = "密钥系统",  -- 原"Key System"
        Description = "",
        KeyLink = "",
        Keys = {"1234"},
        Notifi = {
            Notifications = true,
            CorrectKey = "正在运行脚本...",  -- 原"Running the Script..."
            Incorrectkey = "密钥不正确",  -- 原"The key is incorrect"
            CopyKeyLink = "已复制到剪贴板"  -- 原"Copied to Clipboard"
        }
    }
})

local Main = MakeTab({Name = "透视功能"})  -- 原"Esp"

local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
ESP:Toggle(true)
ESP.Players = false
ESP.Tracers = false
ESP.Boxes = false
ESP.Names = false
ESP.TeamColor = false
ESP.TeamMates = false

local Toggle = AddToggle(Main, {
    Name = "启用",  -- 原"Enable"
    Default = false,
    Callback = function(Value)
        ESP.Players = Value
    end
})

local Toggle = AddToggle(Main, {
    Name = "显示名称",  -- 原"Name"
    Default = false,
    Callback = function(Value)
        ESP.Names = Value
    end
})

local Toggle = AddToggle(Main, {
    Name = "显示方框",  -- 原"Box"
    Default = false,
    Callback = function(Value)
        ESP.Boxes = Value
    end
})

local Toggle = AddToggle(Main, {
    Name = "显示射线",  -- 原"Tracer"
    Default = false,
    Callback = function(Value)
        ESP.Tracers = Value
    end
})

local Toggle = AddToggle(Main, {
    Name = "队伍检测",  -- 原"Team check"
    Default = false,
    Callback = function(Value)
        ESP.TeamColor = Value
    end
})

local Toggle = AddToggle(Main, {
    Name = "队伍颜色",  -- 原"Team color"
    Default = false,
    Callback = function(Value)
        ESP.TeamMates = Value
    end
})

AddColorPicker(Main, {
    Name = "颜色",  -- 原"Color"
    Default = Color3.fromRGB(255, 255, 0),
    Callback = function(Value)
        ESP.Color = Value
    end
})
