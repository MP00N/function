local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

-- 获取游戏服务
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

-- 获取玩家和角色
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(newChar)
    character = newChar
end)

-- 获取游戏名称
local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name

-- 创建主窗口
local Window = Luna:CreateWindow({
    Name = gameName,
    Subtitle = "Luna 控制面板",
    LogoID = nil,
    LoadingEnabled = true,
    LoadingTitle = "Luna 界面套件",
    LoadingSubtitle = "由Nebula Softworks开发",
    
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "LunaConfig"
    },
    
    KeySystem = false
})

-- 创建选项卡
local MainTab = Window:CreateTab({
    Name = "主要功能",
    Icon = "star",
    ImageSource = "Material",
    ShowTitle = true
})

local SecondaryTab = Window:CreateTab({
    Name = "次级功能",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

local HighlightTab = Window:CreateTab({
    Name = "高亮功能",
    Icon = "highlight_alt",
    ImageSource = "Material",
    ShowTitle = true
})

local OtherTab = Window:CreateTab({
    Name = "其它功能",
    Icon = "more_horiz",
    ImageSource = "Material",
    ShowTitle = true
})

-- 高亮功能实现
local highlightSettings = {
    builds = {enabled = false, color = Color3.fromRGB(0, 255, 0)},
    harvest = {enabled = false, color = Color3.fromRGB(255, 255, 0)},
    scraps = {enabled = false, color = Color3.fromRGB(255, 165, 0)},
    animals = {enabled = false, color = Color3.fromRGB(0, 0, 255)},
    scps = {enabled = false, color = Color3.fromRGB(255, 0, 0)},
    interact = {enabled = false, color = Color3.fromRGB(128, 0, 128)}
}

local highlightConnections = {}
local highlightedParts = {}

-- 高亮函数
local function highlightFolder(folderName)
    if not highlightSettings[folderName].enabled then return end
    
    local folder = workspace:FindFirstChild(folderName)
    if not folder then return end
    
    -- 清除旧的连接
    if highlightConnections[folderName] then
        highlightConnections[folderName]:Disconnect()
        highlightConnections[folderName] = nil
    end
    
    -- 清除旧的高亮
    for _, part in pairs(highlightedParts[folderName] or {}) do
        if part:FindFirstChild("LunaHighlight") then
            part.LunaHighlight:Destroy()
        end
    end
    highlightedParts[folderName] = {}
    
    -- 遍历文件夹并高亮Model
    local function processModel(model)
        if not model:IsA("Model") then return end
        
        -- 为Model中的所有BasePart添加高亮
        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Name = "LunaHighlight"
                highlight.Adornee = part
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 1
                highlight.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
                highlight.Transparency = 0.5
                highlight.Color3 = highlightSettings[folderName].color
                highlight.Parent = part
                
                table.insert(highlightedParts[folderName], part)
            end
        end
    end
    
    -- 处理现有Model
    for _, child in pairs(folder:GetChildren()) do
        processModel(child)
    end
    
    -- 监听新添加的Model
    highlightConnections[folderName] = folder.ChildAdded:Connect(function(child)
        if highlightSettings[folderName].enabled then
            processModel(child)
        end
    end)
end

-- 创建高亮开关
for folderName, settings in pairs(highlightSettings) do
    HighlightTab:CreateToggle({
        Name = folderName:gsub("^%l", string.upper) .. " 高亮",
        CurrentValue = settings.enabled,
        Callback = function(enabled)
            highlightSettings[folderName].enabled = enabled
            if enabled then
                highlightFolder(folderName)
            else
                -- 关闭高亮
                if highlightConnections[folderName] then
                    highlightConnections[folderName]:Disconnect()
                    highlightConnections[folderName] = nil
                end
                
                for _, part in pairs(highlightedParts[folderName] or {}) do
                    if part and part:FindFirstChild("LunaHighlight") then
                        part.LunaHighlight:Destroy()
                    end
                end
                highlightedParts[folderName] = {}
            end
        end
    }, folderName .. "Toggle")
end

-- 无限跳跃功能
local infiniteJumpEnabled = false
MainTab:CreateToggle({
    Name = "无限跳跃",
    CurrentValue = false,
    Callback = function(Value)
        infiniteJumpEnabled = Value
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and character and character:FindFirstChild("Humanoid") then
        character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 速度修改功能
local speedEnabled = false
local originalWalkSpeed = 16
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
    originalWalkSpeed = humanoid.WalkSpeed
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
end)

MainTab:CreateToggle({
    Name = "速度修改 (50)",
    CurrentValue = false,
    Callback = function(Value)
        speedEnabled = Value
        if humanoid then
            humanoid.WalkSpeed = Value and 50 or originalWalkSpeed
        end
    end
})

-- 循环更新速度
RunService.Stepped:Connect(function()
    if humanoid then
        humanoid.WalkSpeed = speedEnabled and 50 or originalWalkSpeed
    end
end)

-- 亮夜视功能
local nightVisionEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient

MainTab:CreateToggle({
    Name = "亮夜视",
    CurrentValue = false,
    Callback = function(Value)
        nightVisionEnabled = Value
        if Value then
            originalBrightness = Lighting.Brightness
            originalAmbient = Lighting.Ambient
            originalOutdoorAmbient = Lighting.OutdoorAmbient
            
            Lighting.Brightness = 5
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        else
            Lighting.Brightness = originalBrightness
            Lighting.Ambient = originalAmbient
            Lighting.OutdoorAmbient = originalOutdoorAmbient
        end
    end
})

-- 穿墙功能
local noclipEnabled = false
MainTab:CreateToggle({
    Name = "穿墙功能",
    CurrentValue = false,
    Callback = function(Value)
        noclipEnabled = Value
    end
})

RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ESP功能
local espEnabled = false
local scrapEspEnabled = false
local berryEspEnabled = false
local deerEspEnabled = false
local espObjects = {}

-- 创建ESP框和标签
local function createEspPart(part, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPBillboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = part
    
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Parent = billboard
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Parent = frame
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = part
    
    billboard.Parent = part
    
    return {billboard = billboard, highlight = highlight}
end

-- 移除ESP
local function removeEsp(part)
    if part:FindFirstChild("ESPBillboard") then
        part.ESPBillboard:Destroy()
    end
    if part:FindFirstChild("ESPHighlight") then
        part.ESPHighlight:Destroy()
    end
end

-- 更新ESP
local function updateEsp()
    -- 清除所有ESP
    for _, espData in pairs(espObjects) do
        if espData.billboard and espData.billboard.Parent then
            espData.billboard:Destroy()
        end
        if espData.highlight and espData.highlight.Parent then
            espData.highlight:Destroy()
        end
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    -- 遍历工作区
    local function traverse(parent)
        for _, child in pairs(parent:GetChildren()) do
            -- 废铁ESP
            if scrapEspEnabled and string.find(string.lower(child.Name), "scrap") then
                local espData = createEspPart(child, "废铁", Color3.new(0.5, 0.5, 0.5))
                espObjects[child] = espData
            end
            
            -- 果子ESP
            if berryEspEnabled and string.find(string.lower(child.Name), "berry") then
                local espData = createEspPart(child, "果子", Color3.new(1, 0.4, 0.7))
                espObjects[child] = espData
            end
            
            -- 鹿ESP
            if deerEspEnabled and string.find(string.lower(child.Name), "deer") then
                local espData = createEspPart(child, "鹿", Color3.new(1, 0, 0))
                espObjects[child] = espData
            end
            
            traverse(child)
        end
    end
    
    traverse(workspace)
end

-- ESP主开关
MainTab:CreateToggle({
    Name = "ESP总开关",
    CurrentValue = false,
    Callback = function(Value)
        espEnabled = Value
        updateEsp()
    end
})

-- 废铁ESP开关
MainTab:CreateToggle({
    Name = "废铁ESP",
    CurrentValue = false,
    Callback = function(Value)
        scrapEspEnabled = Value
        updateEsp()
    end
})

-- 果子ESP开关
MainTab:CreateToggle({
    Name = "果子ESP",
    CurrentValue = false,
    Callback = function(Value)
        berryEspEnabled = Value
        updateEsp()
    end
})

-- 鹿ESP开关
MainTab:CreateToggle({
    Name = "鹿ESP",
    CurrentValue = false,
    Callback = function(Value)
        deerEspEnabled = Value
        updateEsp()
    end
})

-- 杀鹿光环功能
local deerKillerEnabled = false
local deerKillerLoop = nil
MainTab:CreateToggle({
    Name = "杀鹿光环",
    CurrentValue = false,
    Callback = function(Value)
        deerKillerEnabled = Value
        if Value then
            deerKillerLoop = RunService.Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, deer in pairs(workspace:GetDescendants()) do
                        if string.find(string.lower(deer.Name), "deer") and deer:FindFirstChild("Humanoid") then
                            -- 检查距离
                            local distance = (deer.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                            if distance <= 50 then
                                -- 更改RigType为R15
                                if deer.Humanoid.RigType == Enum.HumanoidRigType.R6 then
                                    deer.Humanoid.RigType = Enum.HumanoidRigType.R15
                                    
                                    -- 更新ESP显示
                                    if espObjects[deer] then
                                        espObjects[deer].billboard.TextLabel.Text = "死鹿"
                                        espObjects[deer].highlight.FillColor = Color3.new(0, 1, 0)
                                        espObjects[deer].highlight.OutlineColor = Color3.new(0, 1, 0)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            if deerKillerLoop then
                deerKillerLoop:Disconnect()
                deerKillerLoop = nil
            end
        end
    end
})

-- 自动交互功能
local autoInteractEnabled = false
local autoInteractConnection = nil
MainTab:CreateToggle({
    Name = "自动交互",
    CurrentValue = false,
    Callback = function(Value)
        autoInteractEnabled = Value
        if Value then
            autoInteractConnection = RunService.Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, part in pairs(workspace:GetDescendants()) do
                        if part:FindFirstChild("ProximityPrompt") then
                            local prompt = part.ProximityPrompt
                            local distance = (part.Position - character.HumanoidRootPart.Position).Magnitude
                            if distance <= prompt.MaxActivationDistance then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end)
        else
            if autoInteractConnection then
                autoInteractConnection:Disconnect()
                autoInteractConnection = nil
            end
        end
    end
})

-- 武器替换功能
local function replaceGlockWithAK47()
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Glock 17" then
            tool.Name = "AK-47"
        end
    end
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Glock 17" then
            tool.Name = "AK-47"
        end
    end
end

SecondaryTab:CreateButton({
    Name = "将 Glock 17 替换为 AK-47",
    Callback = function()
        replaceGlockWithAK47()
    end
})

-- 传送功能
local function teleportToModel(modelName, displayName)
    SecondaryTab:CreateButton({
        Name = "传送到 " .. displayName,
        Callback = function()
            local model = workspace:FindFirstChild(modelName, true)
            if model and model:IsA("Model") then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.RootPart.CFrame = model:GetPivot() * CFrame.new(0, 3, 0)
                end
            end
        end
    })
end

-- 添加传送按钮
teleportToModel("axe", "斧头")
teleportToModel("skeleton", "骷髅")

-- 逐一传送果子功能
local isTeleportingBerry = false
local teleportBerryLoop = nil

SecondaryTab:CreateToggle({
    Name = "逐一传送到果子",
    CurrentValue = false,
    Callback = function(Value)
        isTeleportingBerry = Value
        if Value then
            teleportBerryLoop = function()
                while isTeleportingBerry and character and character:FindFirstChild("HumanoidRootPart") do
                    for _, berry in ipairs(workspace:GetDescendants()) do
                        if not isTeleportingBerry then break end
                        if string.find(string.lower(berry.Name), "berry") and berry:IsA("BasePart") then
                            character.HumanoidRootPart.CFrame = berry.CFrame
                            task.wait(1)
                        end
                    end
                    task.wait()
                end
            end
            task.spawn(teleportBerryLoop)
        end
    end
})

-- 逐一传送鹿功能
local isTeleportingDeer = false
local teleportDeerLoop = nil

SecondaryTab:CreateToggle({
    Name = "逐一传送到鹿",
    CurrentValue = false,
    Callback = function(Value)
        isTeleportingDeer = Value
        if Value then
            teleportDeerLoop = function()
                while isTeleportingDeer and character and character:FindFirstChild("HumanoidRootPart") do
                    for _, deer in ipairs(workspace:GetDescendants()) do
                        if not isTeleportingDeer then break end
                        if string.find(string.lower(deer.Name), "deer") and deer:FindFirstChild("HumanoidRootPart") then
                            character.HumanoidRootPart.CFrame = deer.HumanoidRootPart.CFrame
                            task.wait(1)
                        end
                    end
                    task.wait()
                end
            end
            task.spawn(teleportDeerLoop)
        end
    end
})

-- 防掉虚空功能
local antiVoidPlatform = nil

local function createAntiVoidPlatform()
    if antiVoidPlatform then
        antiVoidPlatform:Destroy()
        antiVoidPlatform = nil
    end

    antiVoidPlatform = Instance.new("Part")
    antiVoidPlatform.Name = "AntiVoidPlatform"
    antiVoidPlatform.Size = Vector3.new(4, 0.5, 4)
    antiVoidPlatform.Material = Enum.Material.Metal
    antiVoidPlatform.Color = Color3.new(0.5, 0.5, 0.5)
    antiVoidPlatform.Transparency = 1
    antiVoidPlatform.CanCollide = true
    antiVoidPlatform.Anchored = true
    antiVoidPlatform.Parent = workspace

    if character and character:FindFirstChild("HumanoidRootPart") then
        antiVoidPlatform.Position = Vector3.new(character.HumanoidRootPart.Position.X, character.HumanoidRootPart.Position.Y - 2.5, character.HumanoidRootPart.Position.Z)
    end

    spawn(function()
        while antiVoidPlatform and antiVoidPlatform.Parent do
            if character and character:FindFirstChild("HumanoidRootPart") then
                antiVoidPlatform.Position = Vector3.new(character.HumanoidRootPart.Position.X, antiVoidPlatform.Position.Y, character.HumanoidRootPart.Position.Z)
            end
            task.wait()
        end
    end)
end

MainTab:CreateToggle({
    Name = "脚踏虚空",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            createAntiVoidPlatform()
        else
            if antiVoidPlatform then
                antiVoidPlatform:Destroy()
                antiVoidPlatform = nil
            end
        end
    end
})

-- 自瞄功能
local aimbotEnabled = false
local currentTarget = nil
local camera = workspace.CurrentCamera

-- 计算屏幕中心点
local function getScreenCenter()
    return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end

-- 获取目标在屏幕上的位置
local function getScreenPosition(position)
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- 计算两点之间的距离
local function getDistance(pos1, pos2)
    return (pos2 - pos1).Magnitude
end

-- 查找最近的敌人
local function findNearestEnemy()
    local closest = nil
    local closestDistance = math.huge
    local screenCenter = getScreenCenter()
    
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 then
            local head = model:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = getScreenPosition(head.Position)
                if onScreen then
                    local distance = getDistance(screenPos, screenCenter)
                    if distance < closestDistance then
                        closestDistance = distance
                        closest = model
                    end
                end
            end
        end
    end
    
    return closest
end

-- 自瞄循环
local aimbotLoop = nil
MainTab:CreateToggle({
    Name = "自瞄功能",
    CurrentValue = false,
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then
            aimbotLoop = RunService.RenderStepped:Connect(function()
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- 检查当前目标是否有效
                if currentTarget and (not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0) then
                    currentTarget = nil
                end
                
                -- 如果没有目标或目标无效，寻找新目标
                if not currentTarget then
                    currentTarget = findNearestEnemy()
                end
                
                -- 瞄准目标
                if currentTarget and currentTarget:FindFirstChild("Head") then
                    local head = currentTarget.Head
                    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
                end
            end)
        else
            if aimbotLoop then
                aimbotLoop:Disconnect()
                aimbotLoop = nil
            end
            currentTarget = nil
        end
    end
})

-- 制作界面开关
local craftEnabled = false
SecondaryTab:CreateButton({
    Name = "制作界面",
    Callback = function()
        craftEnabled = not craftEnabled
        local craftGui = player.PlayerGui:FindFirstChild("craft")
        if craftGui then
            craftGui.Enabled = craftEnabled
        end
    end
})

-- 完成脚本
Window:CreateHomeTab({
    SupportedExecutors = {"Synapse", "ScriptWare", "Krnl", "Fluxus"},
    DiscordInvite = "1234",
    Icon = 1
})

MainTab:BuildThemeSection()
MainTab:BuildConfigSection()

-- 确保自动加载配置
Luna:LoadAutoloadConfig()