local NotificationLibrary = {}

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local function createObject(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function protectGui(screenGui)
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    elseif gethui then
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
        TextStrokeTransparency = 0.5
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

function NotificationLibrary:Initialize(position)
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
        Position = position or UDim2.new(0.85, 0, 0.7, 0),
        Size = UDim2.new(0, 250, 0, 300)
    })

    createObject("UIListLayout", {
        Parent = self.notificationsFrame,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
end

function NotificationLibrary:Notify(options)
    assert(self.notificationsFrame, "NotificationLibrary is not initialized. Call Initialize() first.")

    local text = options.text or "Notification"
    local duration = options.duration or 5
    local font = options.font or Enum.Font.SourceSans
    local textColor = options.textColor or Color3.fromRGB(255, 255, 255)
    local textSize = options.textSize or 18
    local textStrokeColor = options.textStrokeColor or Color3.fromRGB(0, 0, 0)
    local textStrokeTransparency = options.textStrokeTransparency or 0.5
    local richText = options.richText or false

    local notification = createObject("TextLabel", {
        Parent = self.notificationsFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 30),
        Text = text,
        Font = font,
        TextColor3 = textColor,
        TextSize = textSize,
        TextStrokeColor3 = textStrokeColor,
        TextStrokeTransparency = textStrokeTransparency,
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = richText
    })

    fadeIn(notification, function()
        task.delay(duration, function()
            fadeOut(notification, function()
                notification:Destroy()
            end)
        end)
    end)
end

return NotificationLibrary
