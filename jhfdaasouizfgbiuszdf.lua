local NotificationLibrary = {}

local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local defaultSettings = {
    position = UDim2.new(0.85, 0, 0.7, 0),
    duration = 5,
    font = Enum.Font.SourceSans,
    textColor = Color3.fromRGB(255, 255, 255),
    textSize = 18,
    textStrokeColor = Color3.fromRGB(0, 0, 0),
    textStrokeTransparency = 0.5,
    richText = false
}

local function createObject(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function protectGui(screenGui)
    if gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
end

local function fadeIn(object, callback)
    object.TextTransparency = 1
    object.TextStrokeTransparency = 1
    local tween = TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        TextTransparency = 0,
        TextStrokeTransparency = defaultSettings.textStrokeTransparency
    })
    tween.Completed:Connect(callback)
    tween:Play()
end

local function fadeOut(object, callback)
    local tween = TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    tween.Completed:Connect(callback)
    tween:Play()
end

NotificationLibrary.notificationsFrame = nil

function NotificationLibrary:Initialize(settings)
    settings = settings or {}
    for key, value in pairs(defaultSettings) do
        if settings[key] == nil then
            settings[key] = value
        end
    end

    if self.notificationsFrame then
        self.notificationsFrame:Destroy()
    end

    local screenGui = createObject("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    protectGui(screenGui)

    self.notificationsFrame = createObject("Frame", {
        Name = "NotificationsFrame",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Position = settings.position,
        Size = UDim2.new(0, 250, 0, 300)
    })

    createObject("UIListLayout", {
        Parent = self.notificationsFrame,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    self.settings = settings
end

function NotificationLibrary:Notify(text)
    assert(self.notificationsFrame, "NotificationLibrary is not initialized. Call Initialize() first.")

    local settings = self.settings

    local notification = createObject("TextLabel", {
        Parent = self.notificationsFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 30),
        Text = text,
        Font = settings.font,
        TextColor3 = settings.textColor,
        TextSize = settings.textSize,
        TextStrokeColor3 = settings.textStrokeColor,
        TextStrokeTransparency = settings.textStrokeTransparency,
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = settings.richText
    })

    fadeIn(notification, function()
        task.delay(settings.duration, function()
            fadeOut(notification, function()
                notification:Destroy()
            end)
        end)
    end)
end

return NotificationLibrary
