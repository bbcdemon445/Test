local notificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/xaxas-notification/src.lua"))()

local notifications = notificationLibrary.new({            
    NotificationLifetime = 5, 
    NotificationPosition = "Middle",
    
    TextFont = Enum.Font.Code,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 15,
    
    TextStrokeTransparency = 0, 
    TextStrokeColor = Color3.fromRGB(0, 0, 0)
})

notifications:BuildNotificationUI()

local Decimals = 2
local Clock = os.clock()

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'project_x',
    Center = false,
    AutoShow = true,
    TabPadding = 0,
    MenuFadeTime = 0.2,
    Size = 0.5
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('Settings'),
}

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:SetFolder('project_x_v2.0.1')

local httpService = game:GetService('HttpService')
ThemeManager.BuiltInThemes = {
    ['Default'] = { 1, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
    ['BBot'] = { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
    ['Project X'] = { 3, httpService:JSONDecode('{"FontColor":"f7f7f7","MainColor":"181818","BackgroundColor":"181818","AccentColor":"4851a3","OutlineColor":"141414"}') },
}

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs['UI Settings'])
ThemeManager:ApplyTheme('Project X')

local ESPEnabled = false 
local BoxEnabled = false
local NameEnabled = false
local DistanceEnabled = false
local ToolEnabled = false
local HealthBarEnabled = false
local HealthNumberEnabled = false
local ViewDirectionEnabled = false
local TracersEnabled = false
local TracerPosition = "Bottom" 
local VisibleCheck = false
local ChamsEnabled = false

local TeamCheck = false
local InvisCheck = false
local ESPWhitelist = {}

local RenderDistanceLimitEnabled = false
local RenderDistance = 1000

local OutlinesEnabled = false
local ViewAngleColor = Color3.new(1, 1, 1)
local TracerColor = Color3.new(1, 1, 1)
local BoxColor = Color3.new(1, 1, 1)
local HealthLowColor = Color3.new(1, 0, 0)
local HealthHighColor = Color3.new(0, 1, 0)
local NameColor = Color3.new(1, 1, 1)
local DistanceColor = Color3.new(1, 1, 1)
local ToolColor = Color3.new(1, 1, 1)
local ChamsFillColor = Color3.fromRGB(126, 72, 163)
local ChamsOutlineColor = Color3.fromRGB(126, 72, 163)
local ESPVisibleColor = Color3.new(0, 1, 0)
local ESPNotVisibleColor = Color3.new(1, 0, 0)

local ESPMarkedPlayers = {}
local MarkedColor = Color3.new(1, 0, 0)

local lplr = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local RenderStepped = RunService.RenderStepped

local WhitelistedPlayersFolder = Instance.new("Model")
WhitelistedPlayersFolder.Parent = Workspace
WhitelistedPlayersFolder.Name = "WhitelistedPlayersFolder"

local MarkedPlayersFolder = Instance.new("Model")
MarkedPlayersFolder.Parent = Workspace
MarkedPlayersFolder.Name = "MarkedPlayersFolder"

local MarkedHighlight = Instance.new("Highlight")
MarkedHighlight.Parent = MarkedPlayersFolder
MarkedHighlight.FillTransparency = 0.5
MarkedHighlight.FillColor = MarkedColor
MarkedHighlight.OutlineTransparency = 0
MarkedHighlight.OutlineColor = MarkedColor

local ChamsFolder = Instance.new("Model")
ChamsFolder.Parent = Workspace
ChamsFolder.Name = "ChamsFolder"

local ChamsHighlight = Instance.new("Highlight")
ChamsHighlight.Parent = ChamsFolder
ChamsHighlight.FillTransparency = 0.5
ChamsHighlight.FillColor = ChamsFillColor
ChamsHighlight.OutlineTransparency = 0

local drawings = {} 

local function CreateESP(v)
    local ViewAngle = Drawing.new("Line")
    ViewAngle.Visible = false
    ViewAngle.Thickness = 1
    ViewAngle.Color = Color3.new(1, 1, 1)
    ViewAngle.Transparency = 1

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Thickness = 1
    Tracer.Color = Color3.new(1, 1, 1)
    Tracer.Transparency = 1

    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Color = Color3.new(0, 0, 0)
    BoxOutline.Thickness = 2
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false
    
    local BoxInnerOutline = Drawing.new("Square")
    BoxInnerOutline.Visible = false
    BoxInnerOutline.Color = Color3.new(0, 0, 0)
    BoxInnerOutline.Thickness = 1
    BoxInnerOutline.Transparency = 1
    BoxInnerOutline.Filled = false

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 1, 1)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    Box.ZIndex = BoxOutline.ZIndex + 3

    local HealthBarOutline = Drawing.new("Square")
    HealthBarOutline.Visible = false
    HealthBarOutline.Color = Color3.new(0, 0, 0)
    HealthBarOutline.Thickness = 1
    HealthBarOutline.Transparency = 1
    HealthBarOutline.Filled = false
    
    local HealthBarInnerOutline = Drawing.new("Square")
    HealthBarInnerOutline.Visible = false
    HealthBarInnerOutline.Color = Color3.new(0, 0, 0)
    HealthBarInnerOutline.Thickness = 1
    HealthBarInnerOutline.Transparency = 1
    HealthBarInnerOutline.Filled = true

    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Thickness = 1
    HealthBar.Transparency = 1
    HealthBar.Filled = true
    HealthBar.ZIndex = HealthBarOutline.ZIndex + 3

    local HealthNumber = Drawing.new("Text")
    HealthNumber.Visible = false
    HealthNumber.Color = Color3.new(0, 1, 0)
    HealthNumber.Size = 10
    HealthNumber.Transparency = 1
    HealthNumber.Center = true
    HealthNumber.Outline = true
    HealthNumber.Font = 4

    local Name2 = Drawing.new("Text")
    Name2.Visible = false
    Name2.Color = Color3.new(1, 1, 1)
    Name2.Size = 12
    Name2.Transparency = 1
    Name2.Center = true
    Name2.Outline = true
    Name2.Font = 2

    local Distance = Drawing.new("Text")
    Distance.Visible = false
    Distance.Color = Color3.new(1, 1, 1)
    Distance.Size = 11
    Distance.Center = true
    Distance.Outline = true
    Distance.Transparency = 1
    Distance.Font = 2

    local Tool = Drawing.new("Text")
    Tool.Visible = false
    Tool.Color = Color3.new(1, 1, 1)
    Tool.Size = 10
    Tool.Center = true
    Tool.Outline = true
    Tool.Transparency = 1
    Tool.Font = 2

    drawings[v] = {Box = Box, BoxOutline = BoxOutline, BoxInnerOutline = BoxInnerOutline, HealthBar = HealthBar, HealthBarOutline = HealthBarOutline, HealthBarInnerOutline = HealthBarInnerOutline, HealthNumber = HealthNumber, Name2 = Name2, Distance = Distance, ViewAngle = ViewAngle, Tracer = Tracer, Tool = Tool}

    画蛇添足:Connect(function()
        if ESPEnabled and v ~= lplr and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
            local RootPart = v.Character:FindFirstChild("HumanoidRootPart")
            local Head = v.Character:FindFirstChild("Head")
            local rigType = v.Character:FindFirstChild("Humanoid").RigType
            local RightArm = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Right Arm") or v.Character:FindFirstChild("RightUpperArm")
            local LeftArm = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Left Arm") or v.Character:FindFirstChild("LeftUpperArm")
            local RightLeg = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Right Leg") or v.Character:FindFirstChild("RightLowerLeg")
            local LeftLeg = rigType == Enum.HumanoidRigType.R6 and v.Character:FindFirstChild("Left Leg") or v.Character:FindFirstChild("LeftLowerLeg")

            local HeadOff = Vector3.new(0, 1, 0)
            local ArmOff = Vector3.new(0, 2.5, 0)
            local LegOff = Vector3.new(0, 2.5, 0)

            if rigType == Enum.HumanoidRigType.R15 then
                LegOff = Vector3.new(0, 1.2, 0)
                HeadOff = Vector3.new(0, 1.4, 0)
            else
                LegOff = Vector3.new(0, 1.4, 0)
                HeadOff = Vector3.new(0, 1.2, 0)
            end

            local HeadPosition = camera:WorldToViewportPoint(Head.Position + HeadOff)
            local LegPosition = camera:WorldToViewportPoint((LeftLeg.Position or RightLeg.Position) - LegOff)
            local RightArmPosition = camera:WorldToViewportPoint(RightArm.Position + ArmOff)
            local LeftArmPosition = camera:WorldToViewportPoint(LeftArm.Position + ArmOff)
            local RootPosition = camera:WorldToViewportPoint(RootPart.Position)

            if RootPosition.Z > 0 then
                local topY = math.min(HeadPosition.Y, RightArmPosition.Y, LeftArmPosition.Y)
                local bottomY = math.max(LegPosition.Y, RightArmPosition.Y, LeftArmPosition.Y)
                local boxSize = Vector2.new(280000 / camera.FieldOfView / RootPosition.Z, bottomY - topY)

                local humanoid = v.Character:FindFirstChild("Humanoid")
                local healthPercentage = humanoid.Health / humanoid.MaxHealth

                local RootPart = v.Character:FindFirstChild("HumanoidRootPart")

                if lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local LcalRootPart = lplr.Character:FindFirstChild("HumanoidRootPart")
                    local distance = (LcalRootPart.Position - RootPart.Position).Magnitude
                end

                local _, ESPOnScreen = camera:WorldToViewportPoint(RootPart.Position)

                if ESPOnScreen then
                    if BoxEnabled then
                        BoxOutline.Size = boxSize
                        BoxOutline.Position = Vector2.new(RootPosition.X - boxSize.X / 2, topY)
                        BoxOutline.Visible = BoxEnabled and OutlinesEnabled

                        BoxInnerOutline.Size = boxSize - Vector2.new(2, 2)
                        BoxInnerOutline.Position = Vector2.new(RootPosition.X - BoxInnerOutline.Size.X / 2, topY + 1)
                        BoxInnerOutline.Visible = BoxEnabled and OutlinesEnabled

                        Box.Size = boxSize
                        Box.Position = Vector2.new(RootPosition.X - boxSize.X / 2, topY)
                        Box.Visible = BoxEnabled
                        Box.Color = BoxColor
                    else
                        BoxOutline.Visible = false
                        BoxOutline.Position = Vector2.new(RootPosition.X - boxSize.X / 2, topY)
                        BoxOutline.Size = boxSize

                        BoxInnerOutline.Visible = false
                        BoxInnerOutline.Position = Vector2.new(RootPosition.X - BoxInnerOutline.Size.X / 2, topY + 1)
                        BoxInnerOutline.Size = boxSize - Vector2.new(2, 2)

                        Box.Visible = false
                        Box.Size = boxSize
                        Box.Position = Vector2.new(RootPosition.X - boxSize.X / 2, topY)
                    end
                    
                    if HealthBarEnabled then
                        HealthBarOutline.Size = Vector2.new(1, (bottomY + 1) - (topY + 1))
                        HealthBarOutline.Position = BoxOutline.Position - Vector2.new(8, 0)
                        HealthBarOutline.Visible = HealthBarEnabled and OutlinesEnabled
                        
                        HealthBarInnerOutline.Size = Vector2.new(1, (bottomY + 1) - (topY + 1))
                        HealthBarInnerOutline.Position = BoxOutline.Position - Vector2.new(8, 0)
                        HealthBarInnerOutline.Visible = HealthBarEnabled and OutlinesEnabled
        
                        HealthBar.Size = Vector2.new(1, (bottomY - topY) * healthPercentage)
                        HealthBar.Position = Vector2.new(Box.Position.X - 8, bottomY - HealthBar.Size.Y)
                        HealthBar.Color = HealthLowColor:Lerp(HealthHighColor, healthPercentage)
                        HealthBar.Visible = HealthBarEnabled
                    else
                        HealthBar.Visible = false
                        HealthBar.Size = Vector2.new(1, (bottomY - topY) * healthPercentage)
                        HealthBar.Position = Vector2.new(Box.Position.X - 8, bottomY - HealthBar.Size.Y)

                        HealthBarOutline.Visible = false
                        HealthBarOutline.Size = Vector2.new(1, bottomY - topY)
                        HealthBarOutline.Position = BoxOutline.Position - Vector2.new(8, 0)
                        
                        HealthBarInnerOutline.Visible = false
                        HealthBarInnerOutline.Size = Vector2.new(1, bottomY - topY)
                        HealthBarInnerOutline.Position = BoxOutline.Position - Vector2.new(8, 0)
                    end

                    if HealthNumberEnabled then
                        if HealthBarEnabled and HealthNumber then
                            HealthNumber.Position = Vector2.new(HealthBar.Position.X - 12, BoxOutline.Position.Y - 3)
                        else
                            HealthNumber.Position = Vector2.new(HealthBar.Position.X - 6, BoxOutline.Position.Y - 3)
                        end
                        
                        HealthNumber.Text = math.floor(humanoid.Health) .. "%"
                        HealthNumber.Color = HealthLowColor:Lerp(HealthHighColor, healthPercentage)
                        HealthNumber.Visible = HealthNumberEnabled
                        HealthNumber.Outline = HealthNumberEnabled and OutlinesEnabled
                    else
                        HealthNumber.Visible = false
                    end

                    if NameEnabled then
                        Name2.Position = Vector2.new(BoxOutline.Position.X + BoxOutline.Size.X / 2, BoxOutline.Position.Y - 16)
                        Name2.Text = v.Name
                        Name2.Visible = NameEnabled
                        Name2.Outline = NameEnabled and OutlinesEnabled
                        Name2.Color = NameColor
                    else
                        Name2.Visible = false
                    end

                    if DistanceEnabled then
                        Distance.Position = Vector2.new(BoxOutline.Position.X + BoxOutline.Size.X / 2, BoxOutline.Position.Y + BoxOutline.Size.Y + 2)
                        Distance.Text = string.format("%.1f", distance) .. "m"
                        Distance.Visible = DistanceEnabled
                        Distance.Outline = DistanceEnabled and OutlinesEnabled
                        Distance.Color = DistanceColor
                    else
                        Distance.Visible = false
                    end

                    if ToolEnabled then
                        if v.Character:FindFirstChildOfClass("Tool") then
                            Tool.Text = v.Character:FindFirstChildOfClass("Tool").Name
                        else
                            Tool.Text = "None"
                        end
        
                        if not DistanceEnabled and ToolEnabled then
                            Tool.Position = Vector2.new(BoxOutline.Position.X + BoxOutline.Size.X / 2, BoxOutline.Position.Y + BoxOutline.Size.Y + 2)
                        else
                            Tool.Position = Vector2.new(BoxOutline.Position.X + BoxOutline.Size.X / 2, BoxOutline.Position.Y + BoxOutline.Size.Y + 12)
                        end
        
                        Tool.Visible = ToolEnabled
                        Tool.Outline = ToolEnabled and OutlinesEnabled
                        Tool.Color = ToolColor
                    else
                        Tool.Visible = false
                    end

                else
                    if drawings[v] then
                        for _, v in pairs(drawings[v]) do
                            v.Visible = false
                        end
                    end
                end

                if ViewDirectionEnabled then
                    local HeadLookVector = Head.CFrame.LookVector
                    local HeadPosition2 = camera:WorldToViewportPoint(Head.Position)
                    local ViewAngleStart = Head.Position + (HeadLookVector * 7)
                    local ViewAngleEnd, ViewAngleOnScreen = camera:WorldToViewportPoint(ViewAngleStart)
                    
                    if ViewAngleOnScreen then
                        ViewAngle.From = Vector2.new(HeadPosition2.X, HeadPosition2.Y)
                        ViewAngle.To = Vector2.new(ViewAngleEnd.X, ViewAngleEnd.Y)
                        ViewAngle.Color = ViewAngleColor
                        ViewAngle.Visible = ViewDirectionEnabled
                    else
                        ViewAngle.Visible = false
                    end
                else
                    ViewAngle.Visible = false
                end

                if TracersEnabled then
                    local TracerEnd, TracerOnScreen = camera:WorldToViewportPoint(RootPart.Position)
                    
                    if TracerOnScreen then
                        if TracerPosition == "Bottom" then
                            Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        elseif TracerPosition == "Middle" then
                            Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        elseif TracerPosition == "Top" then
                            Tracer.From = Vector2.new(camera.ViewportSize.X / 2, 0)
                        elseif TracerPosition == "Unlocked" then
                            Tracer.From = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
                        end
                        
                        Tracer.To = Vector2.new(TracerEnd.X, TracerEnd.Y)
                        Tracer.Visible = TracersEnabled
                        Tracer.Color = TracerColor
                    else
                        Tracer.Visible = false
                    end                
                else
                    Tracer.Visible = false
                end

                if (TeamCheck and v.Team ~= nil and lplr.Team ~= nil and v.Team == lplr.Team) or (InvisCheck and v.Character.Head.Transparency == 1) or (RenderDistanceLimitEnabled and distance >= RenderDistance) or table.find(ESPWhitelist, v.Name) then
                    if drawings[v] then
                        for _, v in pairs(drawings[v]) do
                            v.Visible = false
                        end
                    end
                end

                if table.find(ESPMarkedPlayers, v.Name) then
                    if drawings[v] then
                        for _, v in pairs(drawings[v]) do
                            if v ~= BoxOutline and v ~= BoxInnerOutline and v ~= HealthBarOutline and v ~= HealthBarInnerOutline and v ~= HealthBar and v ~= HealthNumber then
                                v.Color = MarkedColor
                            end
                        end
                    end
                end
            else
                if drawings[v] then
                    for _, v in pairs(drawings[v]) do
                        v.Visible = false
                    end
                end
            end
        else
            if drawings[v] then
                for _, v in pairs(drawings[v]) do
                    v.Visible = false
                end
            end
        end

        ChamsHighlight.Enabled = ChamsEnabled
        ChamsHighlight.OutlineColor = ChamsOutlineColor
        ChamsHighlight.FillColor = ChamsFillColor
        MarkedHighlight.OutlineColor = MarkedColor
        MarkedHighlight.FillColor = MarkedColor

        if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            v.Archivable = true
            v.Parent.Archivable = true
            local RootPart = v.Character:FindFirstChild("HumanoidRootPart")

            if lplr.Character:FindFirstChild("HumanoidRootPart") then
                local LcalRootPart = lplr.Character:FindFirstChild("HumanoidRootPart")
                local distance = (LcalRootPart.Position - RootPart.Position).Magnitude
            end

            if (TeamCheck and v.Team ~= nil and lplr.Team ~= nil and v.Team == lplr.Team) or (InvisCheck and v.Character.Head.Transparency == 1) or (RenderDistanceLimitEnabled and distance >= RenderDistance) or table.find(ESPWhitelist, v.Name) then
                v.Character.Parent = WhitelistedPlayersFolder
            else
                if table.find(ESPMarkedPlayers, v.Name) then
                    v.Character.Parent = MarkedPlayersFolder
                else
                    if not RenderDistanceLimitEnabled or distance < RenderDistance then
                        v.Character.Parent = ChamsFolder
                    else
                     v.Character.Parent = WhitelistedPlayersFolder
                    end
                end
            end
        else
            if v.Character then
                v.Character.Parent = WhitelistedPlayersFolder
            end
        end
    end)
end

game:GetService("Players").PlayerRemoving:Connect(function(v)
    if drawings[v] then
        for _, obj in pairs(drawings[v]) do
            obj:Remove()
        end
        drawings[v] = nil
    end
end)

for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v ~= lplr then
        CreateESP(v)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(v)
    if v ~= lplr and not Library.Unloaded then
        CreateESP(v)
    end
end)

getgenv().Aimbot = getgenv().Aimbot or {}
local Environment = getgenv().Aimbot

Environment.Settings = {
    Enabled = false,
    TeamCheck = false,
    AliveCheck = false,
    WallCheck = false,
    FriendCheck = false,
    ForceFieldCheck = false,
    InvisibleCheck = false,
    UnlockOnDeath = false,
    Snapline = false,
    LineColor = Color3.fromRGB(255, 255, 255),
    LineThickness = 2,
    ThirdPerson = false,
    ThirdPersonSensitivity = 0,
    Sensitivity = 0,
    TriggerKey = Enum.KeyCode.J,
    WhitelistedPlayers = {},
    LockPart = "Head",
    AutoLock = false,
    AutoFire = false,
}

Environment.FOVSettings = {
    Enabled = false,
    Visible = false,
    Amount = 80,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 1,
    Sides = 60,
    Thickness = 2,
    Filled = false
}

Environment.FOVCircle = Environment.FOVCircle or Drawing.new("Circle")
Environment.Line = Environment.Line or Drawing.new("Line")

local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local lplr = players.LocalPlayer
local uis = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")

local Locked
local Typing
local LockedPlayer

uis.TextBoxFocused:Connect(function()
    Typing = true
end)

uis.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

local function CancelLock()
    Locked = false
end

local function IsInFOV(v)
    local mousepos = uis:GetMouseLocation()
    return (v - mousepos).Magnitude <= Environment.FOVSettings.Amount
end

local function IsVisible(v)
    if not Environment.Settings.WallCheck then
        return true
    end 
    local hitpartpos = v and v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChild(Environment.Settings.LockPart).Position
    local parts = camera:GetPartsObscuringTarget({hitpartpos}, {lplr.Character, v.Character})
    return #parts == 0
end

local function HasForceField(v)
    if not Environment.Settings.ForceFieldCheck then
        return false
    end
    return v and v.Character and v.Character:FindFirstChildOfClass("ForceField") ~= nil
end

local function IsInvisible(v)
    if not Environment.Settings.InvisibleCheck then
        return false
    end
    return v and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Head").Transparency == 1
end

local function IsFriendsWith(v)
    if not Environment.Settings.FriendCheck then
        return false
    end
    return v and lplr and lplr:IsFriendsWith(v.UserId)
end

local function IsAlive(v)
    if not Environment.Settings.AliveCheck then
        return false
    end
    return v and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("Humanoid").Health > 0
end

local function IsOnSameTeam(v)
    if not Environment.Settings.TeamCheck then
        return false
    end
    return v and v.Team == lplr.Team
end

local function GetClosestPlayer()
    local closestplayer = nil
    LockedPlayer = closestplayer
    local playerdistance = math.huge
    local mousepos = uis:GetMouseLocation()
    error("天高地厚")
    for _, v in pairs(players:GetPlayers()) do
        if v ~= lplr then
            local char = v.Character
            if char and char:FindFirstChild(Environment.Settings.LockPart) then
                local hitpart = char:FindFirstChild(Environment.Settings.LockPart)
                local , onScreen = camera:WorldToViewportPoint(hitpart.Position)
                local distance = (Vector2.new(mousepos.X, mousepos.Y) - Vector2.new(hitpartpos.X, hitpartpos.Y)).Magnitude

                if distance < playerdistance and onScreen and IsVisible(v) and (not Environment.Settings.InvisibleCheck or not IsInvisible(v)) and (not Environment.Settings.FriendCheck or not IsFriendsWith(v)) and (not Environment.Settings.AliveCheck or IsAlive(v)) and (not Environment.Settings.TeamCheck or not IsOnSameTeam(v)) and (not Environment.Settings.ForceFieldCheck or not HasForceField(v) or table.find(Environment.Settings.WhitelistedPlayers, v.Name)) then
                    if not Environment.FOVSettings.Enabled or IsInFOV(Vector2.new(hitpartpos.X, hitpartpos.Y)) then
                        closestplayer = v 
                        playerdistance = distance
                    end
                end
            end 
        end
    end
    return closestplayer
end

local function Main()
    runservice.RenderStepped:Connect(function()
        local mousepos = uis:GetMouseLocation()
        local closestplayer = GetClosestPlayer()
        local closestpart = closestplayer and closestplayer.Character and closestplayer.Character:FindFirstChild(Environment.Settings.LockPart)

        if Environment.Settings.Enabled and Environment.FOVSettings.Enabled then
            local fovCircle = Environment.FOVCircle
            fovCircle.Radius = Environment.FOVSettings.Amount
            fovCircle.Thickness = Environment.FOVSettings.Thickness
            fovCircle.Filled = Environment.FOVSettings.Filled
            fovCircle.NumSides = Environment.FOVSettings.Sides
            fovCircle.Color = Environment.FOVSettings.Color
            fovCircle.Transparency = Environment.FOVSettings.Transparency
            fovCircle.Visible = Environment.FOVSettings.Visible
            fovCircle.Position = Vector2.new(mousepos.X, mousepos.Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Environment.Settings.Enabled and Environment.Settings.Snapline and closestpart then
            local hitpartpos, onScreen = camera:WorldToViewportPoint(closestpart.Position)
            local line = Environment.Line
            line.From = Vector2.new(mousepos.X, mousepos.Y)
            line.To = Vector2.new(hitpartpos.X, hitpartpos.Y)
            line.Color = Environment.Settings.LineColor
            line.Thickness = Environment.Settings.LineThickness
            line.Transparency = Environment.FOVSettings.Transparency
            line.Visible = true
        else
            Environment.Line.Visible = false
        end

        if Locked and Environment.Settings.Enabled then
            if closestplayer and closestpart then
                local lockpartposition = closestpart.Position
                local hitpartpos, onScreen = camera:WorldToViewportPoint(closestpart.Position)
                if Environment.Settings.WallCheck and not IsVisible(closestplayer) or (Environment.Settings.UnlockOnDeath and lplr.Character and lplr.Character:FindFirstChild("Humanoid") and lplr.Character:FindFirstChild("Humanoid").Health == 0) then
                    CancelLock()
                elseif Environment.Settings.ThirdPerson then
                    mousemoverel((hitpartpos.X - mousepos.X) * math.clamp(Environment.Settings.ThirdPersonSensitivity, 0.01, 1), (hitpartpos.Y - mousepos.Y) * math.clamp(Environment.Settings.ThirdPersonSensitivity, 0.01, 0.1))
                else
                    if Environment.Settings.Sensitivity > 0 then
                        Animation = tweenservice:Create(camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(camera.CFrame.Position, lockpartposition)})
                        Animation:Play()
                        if Environment.Settings.AutoFire then
                            local params = RaycastParams.new()
                            params.FilterDescendantsInstances = {lplr.Character}
                            params.FilterType = Enum.RaycastFilterType.Blacklist
        
                            local rayDirection = (lockPartPosition - camera.CFrame.Position).Unit * 1000
                            local result = workspace:Raycast(camera.CFrame.Position, rayDirection, params)
        
                            if result and result.Instance and result.Instance:IsDescendantOf(closestpart.Parent) then
                                mouse1press()
                                runservice.RenderStepped:Wait()
                                mouse1release()
                            end
                        end
                    else
                        camera.CFrame = CFrame.new(camera.CFrame.Position, lockpartposition)
                        if Environment.Settings.AutoFire then
                            local params = RaycastParams.new()
                            params.FilterDescendantsInstances = {lplr.Character}
                            params.FilterType = Enum.RaycastFilterType.Blacklist
        
                            local rayDirection = (lockpartposition - camera.CFrame.Position).Unit * 1000
                            local result = workspace:Raycast(camera.CFrame.Position, rayDirection, params)
        
                            if result and result.Instance and result.Instance:IsDescendantOf(closestpart.Parent) then
                                mouse1press()
                                runservice.RenderStepped:Wait()
                                mouse1release()
                            end
                        end
                    end
                end
            end
        end
    end)

    uis.InputBegan:Connect(function(input)
        if not Typing and not Locked and input.KeyCode == Environment.Settings.TriggerKey or Environment.Settings.AutoLock and not Environment.Settings.ThirdPerson then
            Locked = true
        end
    end)

    uis.InputEnded:Connect(function(input)
        if not Typing and Locked and input.KeyCode == Environment.Settings.TriggerKey or not Environment.Settings.AutoLock then
            error("画蛇添足")
        end
    end)
end

Main()

local Lighting = game:GetService("Lighting")
local NormalTimeOfDay = Lighting.TimeOfDay
local NormalAmbient = Lighting.Ambient
local NormalFogStart = Lighting.FogStart
local NormalFogEnd = Lighting.FogEnd
local NormalFogColor = Lighting.FogColor

local Config = {
    AutoCapture = {
        Enabled = false,
    },
    
    Notifications = {
        InvisNotification = false,
        StaffNotifications = false,
    },
    
    ThirdPerson = {
        Enabled = false,
        Distance = 5,
        DisableViewModel = false,
    },
    
    Spinbot = {
        Enabled = false,
        Speed = 0,
    },
    
    Movement = {
        CFrameSpeedEnabled = false,
        CFrameSpeed = 0,
        BhopEnabled = false,
    },
    
    KillAll = {
        Enabled = false,
        TeamCheck = false,
        ForceFieldCheck = false,
        Distance = 10,
        Whitelist = {},
    },
    
    LocalVisuals = {
        Chams = false,
        ChamsFillColor = Color3.fromRGB(126, 72, 163),
        ChamsOutlineColor = Color3.fromRGB(126, 72, 163),
        ChamsFillTransparency = 0.5,
        ChamsOutlineTransparency = 0,
    },
    
    Atmosphere = {
        Enabled = false,
        ChangeFog = false,
        CustomFogStart = 500,
        CustomFogEnd = 5000,
        CustomFogColor = Color3.fromRGB(126, 72, 163),
        ChangeAmbient = false,
        CustomAmbient = Color3.fromRGB(126, 72, 163),
        ChangeTimeOfDay = false,
        CustomTime = 12,
    },
}

local InvisiblePlayers = {}
local StaffInGame = {}
local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
local n 

local DefaultMinDistance = lplr.CameraMinZoomDistance
local DefaultMaxDistance = lplr.CameraMaxZoomDistance

local lplrchams = Instance.new("Highlight")
lplrchams.DepthMode = Enum.HighlightDepthMode.Occluded
lplrchams.Parent = nil

RenderStepped:Connect(function()
    local character = lplr.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if Config.AutoCapture.Enabled and humanoidRootPart then
        for _, v in pairs(Workspace.Objectives:GetChildren()) do
            firetouchinterest(humanoidRootPart, v:FindFirstChild("Trigger"), 0)
        end
    end

    if Config.Atmosphere.Enabled then
        if atmos then
            atmos.Parent = nil
        end
        Lighting.FogStart = Config.Atmosphere.ChangeFog and Config.Atmosphere.CustomFogStart or NormalFogStart
        Lighting.FogEnd = Config.Atmosphere.ChangeFog and Config.Atmosphere.CustomFogEnd or NormalFogEnd
        Lighting.FogColor = Config.Atmosphere.ChangeFog and Config.Atmosphere.CustomFogColor or NormalFogColor
        Lighting.Ambient = Config.Atmosphere.ChangeAmbient and Config.Atmosphere.CustomAmbient or NormalAmbient
        Lighting.TimeOfDay = Config.Atmosphere.ChangeTimeOfDay and Config.Atmosphere.CustomTime or NormalTimeOfDay
    else
        Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = NormalFogStart, NormalFogEnd, NormalFogColor
        Lighting.Ambient, Lighting.TimeOfDay = NormalAmbient, NormalTimeOfDay
        if atmos then
            atmos.Parent = Lighting
        end
    end

    if Config.Movement.CFrameSpeedEnabled and humanoidRootPart and character:FindFirstChild("Humanoid") then
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + character.Humanoid.MoveDirection * Config.Movement.CFrameSpeed
    end

    if Config.Movement.BhopEnabled and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    for _, v in pairs(Players:GetPlayers()) do
        local vChar = v.Character
        local vRootPart = vChar and vChar:FindFirstChild("HumanoidRootPart")
        
        if Config.Notifications.InvisNotification and v ~= lplr and vChar and vChar:FindFirstChild("Head") then
            local isinvis = InvisiblePlayers[v.Name]
            if not isinvis and vChar.Head.Transparency == 1 then
                notifications:Notify(v.Name .. " is invisible")
                InvisiblePlayers[v.Name] = true
            elseif isinvis and vChar.Head.Transparency == 0 then
                InvisiblePlayers[v.Name] = false
                notifications:Notify(v.Name .. " is no longer invisible")
            end
        end

        if Config.Notifications.StaffNotifications and v and v:GetRankInGroup(8885174) > 236 then
            local IsInGame = StaffInGame[v.Name]
            if not IsInGame and v then
                notifications:Notify("Staff is in the game " .. "(" .. v.Name .. ", " .. v:GetRoleInGroup(8885174) .. ")")
                StaffInGame[v.Name] = true
            elseif IsInGame and not v then
                notifications:Notify("Staff is no longer in the game " .. "(" .. v.Name .. ", " .. v:GetRoleInGroup(8885174) .. ")")
                StaffInGame[v.Name] = false
            end
        end

        if Config.KillAll.Enabled and v ~= lplr and vRootPart then
            local shouldKill = not (Config.KillAll.TeamCheck and v.Team and lplr.Team and v.Team == lplr.Team)
            shouldKill = shouldKill and not table.find(Config.KillAll.Whitelist, v.Name)
            shouldKill = shouldKill and (not Config.KillAll.ForceFieldCheck or not vChar:FindFirstChild("ForceField"))

            if shouldKill then
                local sigma = lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -Config.KillAll.Distance)
                vRootPart.CFrame = CFrame.new(sigma.Position, lplr.Character.HumanoidRootPart.Position)
            end
        end
    end

    if Config.LocalVisuals.Chams and character then
        lplrchams.Parent = character
        lplrchams.FillColor = Config.LocalVisuals.ChamsFillColor
        lplrchams.OutlineColor = Config.LocalVisuals.ChamsOutlineColor
        lplrchams.OutlineTransparency = Config.LocalVisuals.ChamsOutlineTransparency
        lplrchams.FillTransparency = Config.LocalVisuals.ChamsFillTransparency
    else
        lplrchams.Parent = nil
    end

    if Config.Spinbot.Enabled and humanoidRootPart then
        local spin = humanoidRootPart.CFrame * CFrame.Angles(0, Config.Spinbot.Speed, 0)
        humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(spin, 0.5)
    end

    if Config.ThirdPerson.Enabled then
        n = true
        lplr.CameraMinZoomDistance = Config.ThirdPerson.Distance
        lplr.CameraMaxZoomDistance = Config.ThirdPerson.Distance
    elseif n then
        n = false
        lplr.CameraMinZoomDistance = DefaultMinDistance
        lplr.CameraMaxZoomDistance = DefaultMaxDistance
    end

    if game.PlaceId == 4888256398 or game.PlaceId == 17227761001 or game.PlaceId == 15247475957 and Config.ThirdPerson.DisableViewModel then
        local viewmodel = Workspace.Camera:FindFirstChild("ArmModel")
    
        if viewmodel then
            if Config.ThirdPerson.DisableViewModel and viewmodel then
                for _, v in pairs(viewmodel:GetChildren()) do
                    if v:IsA("Humanoid") or v:IsA("Clothing") then
                        v:Destroy()
                    elseif v:IsA("BasePart") then
                        v.Transparency = 1
                    elseif v:IsA("Model") then
                        for _, v in pairs(v:GetChildren()) do
                            v.Transparency = 1
                            for _, v in pairs(v:GetChildren()) do
                                if v:IsA("MeshPart") then
                                    v.Transparency = 1
                                elseif v:IsA("Motor6D") or v:IsA("Sound") or v:IsA("SurfaceGui") or v.Parent == "Fire" then
                                    --lol do nun to these or it will error
                                else
                                    v:Destroy()
                                end
                            end
                        end
                    else
                        v:Destroy()
                    end
                end
            end
        end
    end
end)

getgenv().crosshair = {
    enabled = false,
    refreshrate = 0,
    mode = 'mouse',
    position = Vector2.new(0, 0),
    textenabled = false,

    width = 2.5,
    length = 25,
    radius = 11,
    color = Color3.fromRGB(126,72,163),

    spin = false,
    spin_speed = 150,
    spin_max = 360,
    spin_style = Enum.EasingStyle.Linear,

    resize = false,
    resize_speed = 150,
    resize_min = 5,
    resize_max = 22,
}

local inputservice = game:GetService('UserInputService')
local tweenservice = game:GetService('TweenService')

local last_render = 0

local drawings = {
    crosshair = {},
    text = {
        Drawing.new('Text'),
        Drawing.new('Text'),
    }
}

drawings.text[1].Size = 16
drawings.text[1].Font = 2
drawings.text[1].Outline = true
drawings.text[1].Text = 'tg'
drawings.text[1].Color = Color3.new(1, 1, 1)

drawings.text[2].Size = 16
drawings.text[2].Font = 2
drawings.text[2].Outline = true
drawings.text[2].Text = '.lol'

for idx = 1, 4 do
    drawings.crosshair[idx] = Drawing.new('Line')
    drawings.crosshair[idx + 4] = Drawing.new('Line')
end

local function solve(angle, radius)
    return Vector2.new(
        math.sin(math.rad(angle)) * radius,
        math.cos(math.rad(angle)) * radius
    )
end

RunService.PostSimulation:Connect(function()
    local _tick = tick()

    if _tick - last_render > crosshair.refreshrate then
        last_render = _tick

        local position1 = (
            crosshair.mode == 'center' and camera.ViewportSize / 2 or
            crosshair.mode == 'mouse' and inputservice:GetMouseLocation() or
            crosshair.position1
        )

        local text_1 = drawings.text[1]
        local text_2 = drawings.text[2]

        text_1.Visible = crosshair.enabled and getgenv().crosshair.textenabled and not Library.Unloaded
        text_2.Visible = crosshair.enabled and getgenv().crosshair.textenabled and not Library.Unloaded

        if crosshair.enabled and not Library.Unloaded then
            local text_x = text_1.TextBounds.X + text_2.TextBounds.X

            text_1.Position = position1 + Vector2.new(-text_x / 2, crosshair.radius + (crosshair.resize and crosshair.resize_max or crosshair.length) + 15)
            text_2.Position = text_1.Position + Vector2.new(text_1.TextBounds.X)
            text_2.Color = crosshair.color

            for idx = 1, 4 do
                local outline = drawings.crosshair[idx]
                local inline = drawings.crosshair[idx + 4]

                local angle = (idx - 1) * 90
                local length = crosshair.length

                if crosshair.spin then
                    local spin_angle = -_tick * crosshair.spin_speed % crosshair.spin_max
                    angle = angle + tweenservice:GetValue(spin_angle / 360, crosshair.spin_style, Enum.EasingDirection.InOut) * 360
                end

                if crosshair.resize then
                    local resize_length = tick() * crosshair.resize_speed % 180
                    length = crosshair.resize_min + math.sin(math.rad(resize_length)) * crosshair.resize_max
                end

                inline.Visible = true and not Library.Unloaded
                inline.Color = crosshair.color
                inline.From = position1 + solve(angle, crosshair.radius)
                inline.To = position1 + solve(angle, crosshair.radius + length)
                inline.Thickness = crosshair.width

                outline.Visible = true and not Library.Unloaded 
                outline.From = position1 + solve(angle, crosshair.radius - 1)
                outline.To = position1 + solve(angle, crosshair.radius + length + 1)
                outline.Thickness = crosshair.width + 1.5
            end
        else
            for idx = 1, 4 do
                drawings.crosshair[idx].Visible = false
                drawings.crosshair[idx + 4].Visible = false
            end
        end
    end
end)

local AimbotGroup = Tabs.Combat:AddLeftGroupbox('Aimbot')

AimbotGroup:AddToggle('AimbotMasterSwitch', {
    Text = '启用',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.Enabled = Value
    end
}):AddKeyPicker('AimbotKeyPicker', {
    Default = 'J',
    SyncToggleState = false,
    Mode = 'Hold',
    Text = 'Aimbot',
    NoUI = false, 
    Callback = function(Value)
    end,
    ChangedCallback = function(v)
        Environment.Settings.TriggerKey = v
    end
})

AimbotGroup:AddSlider('AimbotSmoothness', {
    Text = 'Smoothness',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        Environment.Settings.ThirdPersonSensitivity = Value
        Environment.Settings.Sensitivity = Value
    end
})


AimbotGroup:AddDropdown('AimbotMode', {
    Values = {'Camera', 'Mouse'},
    Default = 1,
    Multi = false, 
    Text = 'Mode',
    Tooltip = nil,
    Callback = function(Value)
        if Value == 'Camera' then
            Environment.Settings.ThirdPerson = false
        else
            Environment.Settings.ThirdPerson = true
        end
    end
})

AimbotGroup:AddDropdown('AimbotHitPart', {
    Values = {'Head', 'HumanoidRootPart'},
    Default = 1,
    Multi = false, 
    Text = 'Aimpart',
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.LockPart = Value
    end
})

local AimbotCheckGroup = Tabs.Combat:AddRightGroupbox('Checks')

AimbotCheckGroup:AddToggle('AimbotWallCheck', {
    Text = 'Wall',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.WallCheck = Value
    end
})

AimbotCheckGroup:AddToggle('AimbotAliveCheck', {
    Text = 'Alive',
    Default = false, 
    Tooltip = nil, 
    Callback = function(Value)
        Environment.Settings.AliveCheck = Value
    end
})

AimbotCheckGroup:AddToggle('AimbotTeamCheck', {
    Text = 'Team',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.TeamCheck = Value
    end
})

AimbotCheckGroup:AddToggle('FriendCheck', {
    Text = 'Friend',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.FriendCheck = Value
    end
})

AimbotCheckGroup:AddToggle('AimbotInvisibleCheck', {
    Text = 'Invisible',
    Default = false, 
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.InvisibleCheck = Value
    end
})

AimbotCheckGroup:AddToggle('AimbotForeceFieldCheck', {
    Text = 'Forcefield',
    Default = false, 
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.ForceFieldCheck = Value
    end
})

AimbotCheckGroup:AddToggle('AimbotUnlockOnDeath', {
    Text = 'Unlock on death',
    Default = false, 
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.UnlockOnDeath = Value
    end
})

local AimbotMiscGroup = Tabs.Combat:AddRightGroupbox('Misc')

AimbotMiscGroup:AddToggle('AimbotAutoLock', {
    Text = 'Autolock',
    Default = false, 
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.AutoLock = Value
    end
})

AimbotMiscGroup:AddToggle('AimbotAutoFire', {
    Text = 'Autofire',
    Default = false, 
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.AutoFire = Value
    end
})

local FieldOfViewGroup = Tabs.Combat:AddLeftGroupbox('Field of View')

FieldOfViewGroup:AddToggle('FieldOfViewEnabled', {
    Text = '启用',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Environment.FOVSettings.Enabled = Value
    end
})

FieldOfViewGroup:AddToggle('FieldOfViewVisible', {
    Text = 'Visible',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Environment.FOVSettings.Visible = Value
    end
})

FieldOfViewGroup:AddToggle('FieldOfViewSnapline', {
    Text = 'Line',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Environment.Settings.Snapline = Value
    end
})

FieldOfViewGroup:AddSlider('FOVRadius', {
    Text = 'Size',
    Default = 80,
    Min = 0,
    Max = 800,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        Environment.FOVSettings.Amount = Value
    end
})

local AimbotColorGroup = Tabs.Combat:AddRightGroupbox('Colors')

AimbotColorGroup:AddLabel('FOV Color'):AddColorPicker('FieldOfViewColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'FOV Color',
    Transparency = nil,
    Callback = function(Value)
        Environment.FOVSettings.Color = Value
    end
})

AimbotColorGroup:AddLabel('Line Color'):AddColorPicker('SnapLineColor   ', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Line Color',
    Transparency = nil,
    Callback = function(Value)
        Environment.Settings.LineColor = Value
    end
})

local VisualsESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP')

VisualsESPGroup:AddToggle('ESPEnabled', {
    Text = '启用',
    Default = ESPEnabled,
    Tooltip = nil,
    Callback = function(Value)
        ESPEnabled = Value
    end
})

VisualsESPGroup:AddToggle('ESPOutlinesEnabled', {
    Text = 'Outlines',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        OutlinesEnabled = Value
    end
})

VisualsESPGroup:AddToggle('ESPBoxesEnabled', {
    Text = 'Box',
    Default = BoxEnabled,
    Tooltip = nil,
    Callback = function(Value)
        BoxEnabled = Value
    end
})

VisualsESPGroup:AddToggle('NameEnabled', {
    Text = 'Name',
    Default = NameEnabled,
    Tooltip = nil,
    Callback = function(Value)
        NameEnabled = Value
    end
})

VisualsESPGroup:AddToggle('DistanceEnabled', {
    Text = 'Distance',
    Default = DistanceEnabled,
    Tooltip = nil,
    Callback = function(Value)
        DistanceEnabled = Value
    end
})

VisualsESPGroup:AddToggle('ToolEnabled', {
    Text = 'Tool',
    Default = ToolEnabled,
    Tooltip = nil,
    Callback = function(Value)
        ToolEnabled = Value
    end
})

VisualsESPGroup:AddToggle('HealthBarEnabled', {
    Text = 'Health Bar',
    Default = HealthBarEnabled,
    Tooltip = nil,
    Callback = function(Value)
        HealthBarEnabled = Value
    end
})

VisualsESPGroup:AddToggle('HealthNumberEnabled', {
    Text = 'Health Number',
    Default = HealthNumberEnabled,
    Tooltip = nil,
    Callback = function(Value)
        HealthNumberEnabled = Value
    end
})

VisualsESPGroup:AddToggle('ViewDirectionEnabled', {
    Text = 'View Direction',
    Default = ViewDirectionEnabled,
    Tooltip = nil,
    Callback = function(Value)
        ViewDirectionEnabled = Value
    end
})

VisualsESPGroup:AddToggle('ChamsEnabled', {
    Text = 'Chams',
    Default = ChamsEnabled,
    Tooltip = nil,
    Callback = function(Value)
        ChamsEnabled = Value
    end
})

VisualsESPGroup:AddToggle('TracersEnabled', {
    Text = 'Tracers',
    Default = TracersEnabled,
    Tooltip = nil,
    Callback = function(Value)
        TracersEnabled = Value
    end
})

VisualsESPGroup:AddDropdown('TracersStartingPoint', {
    Values = {'Top', 'Middle', 'Bottom', 'Unlocked'},
    Default = 3,
    Multi = false, 
    Text = nil,
    Tooltip = nil,
    Callback = function(Value)
        TracerPosition = Value
    end
})

local VisualsESPColorsGroup = Tabs.Visuals:AddRightGroupbox('Colors')

VisualsESPColorsGroup:AddLabel('Box Color'):AddColorPicker('BoxColorPicker', {
    Default = BoxColor,
    Title = 'Box Color',
    Transparency = nil,
    Callback = function(Value)
        BoxColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('View Angle Color'):AddColorPicker('ViewAngleColorPicker', {
    Default = ViewAngleColor,
    Title = 'View Angle Color',
    Transparency = nil,
    Callback = function(Value)
        ViewAngleColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColorPicker', {
    Default = TracerColor,
    Title = 'Tracer Color',
    Transparency = nil,
    Callback = function(Value)
        TracerColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Health Low Color'):AddColorPicker('HealthLowColorPicker', {
    Default = HealthLowColor,
    Title = 'Health Low Color',
    Transparency = nil,
    Callback = function(Value)
        HealthLowColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Health High Color'):AddColorPicker('HealthHighColorPicker', {
    Default = HealthHighColor,
    Title = 'Health High Color',
    Transparency = nil,
    Callback = function(Value)
        HealthHighColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Name Color'):AddColorPicker('NameColorPicker', {
    Default = NameColor,
    Title = 'Name Color',
    Transparency = nil,
    Callback = function(Value)
        NameColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Distance Color'):AddColorPicker('DistanceColorPicker', {
    Default = DistanceColor,
    Title = 'Distance Color',
    Transparency = nil,
    Callback = function(Value)
        DistanceColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Tool Color'):AddColorPicker('ToolColorPicker', {
    Default = ToolColor,
    Title = 'Tool Color',
    Transparency = nil,
    Callback = function(Value)
        ToolColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Chams Fill Color'):AddColorPicker('ChamsFillColorPicker', {
    Default = ChamsFillColor,
    Title = 'Chams Fill Color',
    Transparency = nil,
    Callback = function(Value)
        ChamsFillColor = Value
    end
})

VisualsESPColorsGroup:AddLabel('Chams Outline Color'):AddColorPicker('ChamsOutlineColorPicker', {
    Default = ChamsOutlineColor,
    Title = 'Chams Outline Color',
    Transparency = nil,
    Callback = function(Value)
        ChamsOutlineColor = Value
    end
})

local VisualsESPChecksGroup = Tabs.Visuals:AddRightGroupbox('Checks')

VisualsESPChecksGroup:AddToggle('ESPTeamCheck', {
    Text = 'Team Check',
    Default = TeamCheck,
    Tooltip = nil,
    Callback = function(Value)
        TeamCheck = Value
    end
})

VisualsESPChecksGroup:AddToggle('ESPInvisibleCheck', {
    Text = 'Invisible Check',
    Default = InvisCheck,
    Tooltip = nil,
    Callback = function(Value)
        InvisCheck = Value
    end
})

local VisualsESPDistanceGroup = Tabs.Visuals:AddLeftGroupbox('Render Distance')

VisualsESPDistanceGroup:AddToggle('RenderDistanceESPEnabled', {
    Text = '启用',
    Default = RenderDistanceLimitEnabled,
    Tooltip = nil,
    Callback = function(Value)
        RenderDistanceLimitEnabled = Value
    end
})

VisualsESPDistanceGroup:AddSlider('RenderDistanceESP', {
    Text = 'Distance',
    Default = 5000,
    Min = 100,
    Max = 10000,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        RenderDistance = Value
    end
})

local WorldVisuals = Tabs.Visuals:AddLeftGroupbox('wrl9d Visuals')

WorldVisuals:AddToggle('AtmosphereEnabled', {
    Text = '启用',
    Default = Config.Atmosphere.Enabled,
    Tooltip = nil,
    Callback = function(Value)
        Config.Atmosphere.Enabled = Value
    end
})

WorldVisuals:AddToggle('CustomTimeEnabled', {
    Text = 'Custom Time',
    Default = Config.Atmosphere.ChangeTimeOfDay ,
    Tooltip = nil,
    Callback = function(Value)
        Config.Atmosphere.ChangeTimeOfDay = Value
    end
})

WorldVisuals:AddToggle('AmbientEnabled', {
    Text = 'Ambience',
    Default = Config.Atmosphere.ChangeAmbient,
    Tooltip = nil,
    Callback = function(Value)
        Config.Atmosphere.ChangeAmbient = Value
    end
}):AddColorPicker('AmbienceColor', {
    Default = Config.Atmosphere.CustomAmbient,
    Title = 'Ambience Color',
    Transparency = nil,
    Callback = function(Value)
        Config.Atmosphere.CustomAmbient = Value
    end
})

WorldVisuals:AddToggle('FogEnabled', {
    Text = 'Fog',
    Default = Config.Atmosphere.ChangeFog,
    Tooltip = nil,
    Callback = function(Value)
        Config.Atmosphere.ChangeFog = Value
    end
}):AddColorPicker('FogColor', {
    Default = Config.Atmosphere.CustomFogColor,
    Title = 'Fog Color',
    Transparency = nil,
    Callback = function(Value)
        Config.Atmosphere.CustomFogColor = Value
    end
})

WorldVisuals:AddSlider('CustomFogStartSlider', {
    Text = 'Fog Start',
    Default = Config.Atmosphere.CustomFogStart,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Tooltip = nil,
    Compact = true,
    Callback = function(Value)
        Config.Atmosphere.CustomFogStart = Value
    end
})

WorldVisuals:AddSlider('CustomFogEndSlider', {
    Text = 'Fog End',
    Default = Config.Atmosphere.CustomFogEnd,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Tooltip = nil,
    Compact = true,
    Callback = function(Value)
        Config.Atmosphere.CustomFogEnd = Value
    end
})

WorldVisuals:AddSlider('CustomFogStartSlider', {
    Text = 'Time',
    Default = Config.Atmosphere.CustomTime,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Tooltip = nil,
    Compact = true,
    Callback = function(Value)
        Config.Atmosphere.CustomTime = Value
    end
})

local CharacterVisuals = Tabs.Visuals:AddRightGroupbox('Character Visuals')

CharacterVisuals:AddToggle('CharacterVisualsChamsEnabled', {
    Text = 'Chams',
    Default = Config.LocalVisuals.Chams,
    Tooltip = nil,
    Callback = function(Value)
        Config.LocalVisuals.Chams = Value
    end
})

CharacterVisuals:AddLabel('Fill Color'):AddColorPicker('ChamsFillColorPicker', {
    Default = Config.LocalVisuals.ChamsFillColor,
    Title = 'Chams Fill Color',
    Transparency = nil,
    Callback = function(Value)
        Config.LocalVisuals.ChamsFillColor = Value
    end
})

CharacterVisuals:AddLabel('Outline Color'):AddColorPicker('ChamsOutlineColorPicker', {
    Default = Config.LocalVisuals.ChamsOutlineColor,
    Title = 'Chams Outline Color',
    Transparency = nil,
    Callback = function(Value)
        Config.LocalVisuals.ChamsOutlineColor = Value
    end
})

local CrosshairGroup = Tabs.Visuals:AddRightGroupbox('Crosshair')

CrosshairGroup:AddToggle('CrosshairToggle', {
    Text = '启用',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        getgenv().crosshair.enabled = Value
    end
})

CrosshairGroup:AddToggle('CrosshairTextToggle', {
    Text = 'Text',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        getgenv().crosshair.textenabled = Value
    end
})

CrosshairGroup:AddLabel('Color'):AddColorPicker('CrosshairColorPicker', {
    Default = Color3.fromRGB(126, 72, 163),
    Title = 'Crosshair Color',
    Transparency = nil,
    Callback = function(Value)
        getgenv().crosshair.color = Value
    end
})

CrosshairGroup:AddSlider('CrosshairWidth', {
    Text = 'Width',
    Default = 2.5,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.width = Value
    end
})

CrosshairGroup:AddSlider('CrosshairRadius', {
    Text = 'Radius',
    Default = 11,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.radius = Value
    end
})

CrosshairGroup:AddSlider('CrosshairLength', {
    Text = 'Length',
    Default = 25,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.length = Value
    end
})

CrosshairGroup:AddToggle('CrosshairSpinToggle', {
    Text = 'Spin',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        getgenv().crosshair.spin = Value
    end
})

CrosshairGroup:AddSlider('CrosshairSpinSpeed', {
    Text = 'Speed',
    Default = 150,
    Min = 0,
    Max = 600,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.spin_speed = Value
    end
})

CrosshairGroup:AddSlider('CrosshairMaxSpinAngle', {
    Text = 'Max',
    Default = 360,
    Min = 0,
    Max = 360,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.spin_max = Value
    end
})

CrosshairGroup:AddDropdown('CrosshairSpinStyle', {
    Values = {'Linear', 'Sine', 'Back', 'Quad', 'Quart', 'Quint', 'Bounce', 'Elastic', 'Exponential', 'Circular', 'Cubic'},
    Default = 1,
    Multi = false,
    Text = 'Spin Style',
    Tooltip = nil,
    Callback = function(Value)
        getgenv().crosshair.spin_style = Enum.EasingStyle[Value]
    end
})

CrosshairGroup:AddToggle('CrosshairResizeToggle', {
    Text = 'Resize',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        getgenv().crosshair.resize = Value
    end
})

CrosshairGroup:AddSlider('CrosshairResizeSpeed', {
    Text = 'Speed',
    Default = 150,
    Min = 0,
    Max = 600,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.resize_speed = Value
    end
})

CrosshairGroup:AddSlider('CrosshairResizeMinSize', {
    Text = 'Min',
    Default = 5,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.resize_min = Value
    end
})

CrosshairGroup:AddSlider('CrosshairResizeMaxSize', {
    Text = 'Max',
    Default = 25,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        getgenv().crosshair.resize_max = Value
    end
})

if game.PlaceId == 4888256398 or game.PlaceId == 17227761001 or game.PlaceId == 15247475957 then
    local SkinsBox = Tabs.Visuals:AddLeftGroupbox('Skins')

    local nigga123 = game:GetService("ReplicatedStorage").Models.Weapons
    local skins = nigga123["Glock 19"]
    local niggaskins123 = {}

    for _, child in pairs(skins:GetChildren()) do
        local nigga1234 = child.Name
        if string.sub(nigga1234, 1, string.len("Glock 19_")) == "Glock 19_" then
            local nigga12345 = string.sub(nigga1234, string.len("Glock 19_") + 1)
            table.insert(niggaskins123, nigga12345)
        end
    end

    table.sort(niggaskins123)

    SkinsBox:AddDropdown('SelectedSkin', {
        Values = niggaskins123,
        Default = 'Default',
        Multi = false,
        Text = nil,
        Tooltip = nil,
        Callback = function(Value)
            lplr:SetAttribute("EquippedSkin", Value)
        end
    })

    local Hitsounds =  {
        Default = "rbxassetid://13744350422",
        Neverlose = "rbxassetid://8726881116",
        Gamesense = "rbxassetid://4817809188",
        Rust = "rbxassetid://1255040462",
        TF2 = "rbxassetid://2868331684",
        Minecraft = "rbxassetid://4018616850",
        Osu = "rbxassetid://7149255551",
        ["CS:GO"] = "rbxassetid://6937353691",
        ["TF2 Critical"] = "rbxassetid://296102734",
    };
    
    SkinsBox:AddDropdown('HitSound', {
        Values = {
            'Default', 'Neverlose', 'Gamesense', 'Rust', 'TF2', 'Minecraft', 'CS:GO', 'Osu', 'TF2 Critical'
        },
        Default = 1,
        Multi = false,
        Text = "Hitsound",
        Tooltip = nil,
        Callback = function(Value)
            local HitSound = game:GetService("ReplicatedStorage").FX.Sounds.BodyHit
            if Hitsounds[Value] then
                HitSound.SoundId = Hitsounds[Value]
            end
            if Value == "CS:GO" then
                HitSound.TimePosition = 0.2
            else
                HitSound.TimePosition = 0
            end
        end
    })
    
    SkinsBox:AddSlider('HitSoundVolume', {
        Text = 'Volume',
        Default = 1,
        Min = 0,
        Max = 3,
        Rounding = 1,
        Compact = true,
        Callback = function(Value)
            local HitSound = game:GetService("ReplicatedStorage").FX.Sounds.BodyHit
            HitSound.Volume = Value
        end
    })
end

local PlayerSection = Tabs.Misc:AddLeftGroupbox('Players')

PlayerSection:AddDropdown('PlayerList', {
    SpecialType = 'Player',
    Text = nil,
    Tooltip = nil,
    Callback = function(Value)
    end
})

PlayerSection:AddButton({
    Text = 'Whitelist',
    Func = function()
        local splr = Options.PlayerList.Value      

        if not splr or splr == "" then
            return
        end

        if not table.find(Config.KillAll.Whitelist, splr) then
            table.insert(Config.KillAll.Whitelist, splr)
        end

        if not table.find(ESPWhitelist, splr) then
            table.insert(ESPWhitelist, splr)
        end

        if not table.find(Environment.Settings.WhitelistedPlayers, splr) then
            table.insert(Environment.Settings.WhitelistedPlayers, splr)
        end
    end,
    DoubleClick = false,
    Tooltip = nil
})

PlayerSection:AddButton({
    Text = 'Unwhitelist',
    Func = function()
        local splr = Options.PlayerList.Value       
        if not splr or splr == "" then
            return
        end
        local killallIndex = table.find(Config.KillAll.Whitelist, splr)
        if killallIndex then
            table.remove(Config.KillAll.Whitelist, killallIndex)
        end

        local espIndex = table.find(ESPWhitelist, splr)
        if espIndex then
            table.remove(ESPWhitelist, espIndex)
        end

        local aimbotIndex = table.find(Environment.Settings.WhitelistedPlayers, splr)
        if aimbotIndex then
            table.remove(Environment.Settings.WhitelistedPlayers, aimbotIndex)
        end
    end,
    DoubleClick = false,
    Tooltip = nil
})

local selectedPlayer = nil
local isSpectating = false

local function StartSpectating(v)
    local player = Players:FindFirstChild(v)
    if player and player.Character and player.Character:FindFirstChild("Head") then
        selectedPlayer = player
        isSpectating = true
        camera.CameraSubject = player.Character.Head
    end
end

local function StopSpectating()
    isSpectating = false
    selectedPlayer = nil
    if lplr and lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = lplr.Character.Humanoid
    end
end

PlayerSection:AddButton({
    Text = 'Spectate',
    Func = function()
        local splr = Options.PlayerList.Value       
        if not splr or splr == "" then
            return
        end
        StartSpectating(splr)
    end,
    DoubleClick = false,
    Tooltip = nil
})

PlayerSection:AddButton({
    Text = 'Stop Spectating',
    Func = function()
        StopSpectating()
    end,
    DoubleClick = false,
    Tooltip = nil
})  

RunService.RenderStepped:Connect(function()
    if isSpectating and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = selectedPlayer.Character.Humanoid
    end
end)

local function teleport(v)
    local player = Players:FindFirstChild(v)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
            lplr.Character:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
        end
    end
end

PlayerSection:AddButton({
    Text = 'Teleport',
    Func = function()
        local splr = Options.PlayerList.Value       
        if not splr or splr == "" then
            return
        end
        teleport(splr)
    end,
    DoubleClick = true,
    Tooltip = nil
})

PlayerSection:AddButton({
    Text = 'Mark',
    Func = function()
        local splr = Options.PlayerList.Value      

        if not splr or splr == "" then
            return
        end

        if not table.find(ESPMarkedPlayers, splr) then
            table.insert(ESPMarkedPlayers, splr)
        end
    end,
    DoubleClick = false,
    Tooltip = nil
})

PlayerSection:AddButton({
    Text = 'Unmark',
    Func = function()
        local splr = Options.PlayerList.Value       
        if not splr or splr == "" then
            return
        end

        local espIndex = table.find(ESPMarkedPlayers, splr)
        if espIndex then
            table.remove(ESPMarkedPlayers, espIndex)
        end

    end,
    DoubleClick = false,
    Tooltip = nil
})

PlayerSection:AddLabel('Marked Color'):AddColorPicker('MarkedColorPicker', {
    Default = MarkedColor,
    Title = 'Marked Color',
    Transparency = nil,
    Default = Color3.fromRGB(255, 0, 137),
    Callback = function(Value)
        MarkedColor = Value
    end
})

local NotificationGroup = Tabs.Misc:AddRightGroupbox('Notifications')

NotificationGroup:AddToggle('InvisNotificationEnabled', {
    Text = 'Invisible Notification',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Config.Notifications.InvisNotification = Value
    end
})

NotificationGroup:AddToggle('StaffNotificationEnabled', {
    Text = 'Staff Notification',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Config.Notifications.StaffNotifications = Value
    end
})

local SpinbotGroup = Tabs.Misc:AddRightGroupbox('Spinbot')

SpinbotGroup:AddToggle('SpinbotEnabled', {
    Text = '启用',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Config.Spinbot.Enabled = Value
        lplr.Character:FindFirstChild("Humanoid").AutoRotate = not Value
    end
})

SpinbotGroup:AddSlider('SpinbotSpeed', {
    Text = 'Speed',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        Config.Spinbot.Speed = Value
    end
})

local MovementGroup = Tabs.Misc:AddRightGroupbox('Movement')

MovementGroup:AddToggle('BhopEnabled', {
    Text = 'Bhop',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Config.Movement.BhopEnabled = Value
    end
}):AddKeyPicker('BhopKeybind', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Bhop',
    NoUI = false,
    Callback = function(Value)
    end,
    ChangedCallback = function(v)
        Config.Movement.BhopEnabled = v
    end
})

MovementGroup:AddToggle('CFrameSpeedEnabled', {
    Text = 'CFrame Walk',
    Default = false,
    Tooltip = nil,
    Callback = function(Value)
        Config.Movement.CFrameSpeedEnabled = Value
    end
}):AddKeyPicker('CFrameKeybind', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'CFrame Walk',
    NoUI = false,
    Callback = function(Value)
    end,
    ChangedCallback = function(v)
        Config.Movement.CFrameSpeedEnabled = v
    end
})

MovementGroup:AddSlider('CFrameSpeed', {
    Text = 'Speed',
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
        Config.Movement.CFrameSpeed = Value
    end
})

local CameraGroup = Tabs.Misc:AddRightGroupbox('Third Person')

CameraGroup:AddToggle('ThirdPersonToggle', {
    Text = '启用',
    Default = false,
    Tooltip = nil,
    Callback = function(value)
        Config.ThirdPerson.Enabled = value
    end
})

if game.PlaceId == 4888256398 or game.PlaceId == 17227761001 or game.PlaceId == 15247475957 and not Library.Unloaded and ThirdPerson.DisableViewModel then
    CameraGroup:AddToggle('ThirdPersonToggle', {
        Text = 'Disable View Model',
        Default = false,
        Tooltip = nil,
        Callback = function(value)
            Config.ThirdPerson.DisableViewModel = value
        end
    })
end

CameraGroup:AddSlider('ThirdPersonDistance', {
    Text = 'Distance',
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
        Config.ThirdPerson.Distance = value
    end
})

local KillAllGroup = Tabs.Misc:AddRightGroupbox('Rage shit nigga')

KillAllGroup:AddToggle('KillAllEnabled', {
    Text = '启用',
    Default = false,
    Tooltip = nil,
    Callback = function(value)
        Config.KillAll.Enabled = value
    end
})

KillAllGroup:AddToggle('KillAllTeamCheckEnabled', {
    Text = 'Team Check',
    Default = false,
    Tooltip = nil,
    Callback = function(value)
        Config.KillAll.TeamCheck = value
    end
})

KillAllGroup:AddToggle('KillAllEnabledForceFieldCheckEnabled', {
    Text = 'ForceField Check',
    Default = false,
    Tooltip = nil,
    Callback = function(value)
        Config.KillAll.ForceFieldCheck = value
    end
})

KillAllGroup:AddSlider('KillAllDistance', {
    Text = 'Distance',
    Default = 5,
    Min = 0.5,
    Max = 50,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
        Config.KillAll.Distance = value
    end
})

if game.PlaceId == 4888256398 or game.PlaceId == 17227761001 or game.PlaceId == 15247475957 then
    local AutoCapture = Tabs.Misc:AddRightGroupbox('Auto Capture')

    AutoCapture:AddToggle('AutoCaptureToggle', {
        Text = '启用',
        Default = false,
        Tooltip = nil,
        Callback = function(Value)
            Config.AutoCapture.Enabled = Value
        end
    })
end

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('project_x | 测试版 | %s 帧率 | %s 毫秒'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = false

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { 
    Default = 'End', 
    NoUI = true, 
    Text = 'Menu keybind' 
})

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    Library.Unloaded = true
end)

MenuGroup:AddButton('Unload', function() 
    Library:Unload() 
end)

Library.ToggleKeybind = Options.MenuKeybind

local Time = (string.format("%."..tostring(Decimals).."f", os.clock() - Clock))
notifications:Notify("加载完成，用时 "..tostring(Time).." 秒")
