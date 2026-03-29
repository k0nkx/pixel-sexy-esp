if getgenv().UnloadESP then
    getgenv().UnloadESP()
    task.wait()
end

local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end

-- UI + ESP
local Library = loadstring(game:HttpGet("https://example.com/ui-library.lua"))()
local Window = Library:CreateWindow("hack ui title")

local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/pixel-sexy-esp/refs/heads/main/Optimized%20esp%20module.lua"))()

local esp = ESPLibrary.new({
    Main = { Enabled = true, RenderDistance = 10000 },

    Chams = {
        Enabled = false,
        Fill = { Color = rgb(255,255,255), Transparency = 0.95 },
        Outline = { Color = rgb(255,255,255), Transparency = 0.6 },
    },

    Box = {
        Enabled = true,
        Type = "Box",
        GradientEnabled = true,
        Fill = true,
        FillGradientEnabled = true
    },

    Healthbar = {
        Enabled = true,
        Position = "Left",
        Thickness = 3,
        Tween = true,
        TweenSpeed = 0.3,
        EasingStyle = "Quad",
        EasingDirection = "Out",
        GradientEnabled = true
    },

    NameText = {
        Enabled = true,
        Position = "Top",
        Size = 12,
        UseCustomFont = true,
        CustomFontName = "Tahoma"
    },

    DistanceText = {
        Enabled = true,
        Position = "Bottom",
        Size = 12,
        UseCustomFont = true,
        CustomFontName = "Tahoma"
    },
})

esp:Start()

getgenv().UnloadESP = function()
    esp:Stop()
    Library:Unload()
end

-- UI
local Tab = Window:CreateTab("ESP")
local Section = Tab:CreateSection("Main")

Section:CreateToggle("ESP Enabled", true, function(v)
    esp:SetEnabled(v)
end)

Section:CreateSlider("Render Distance", 50, 10000, 10000, function(v)
    esp:UpdateSettings({ Main = { RenderDistance = v } })
end)

-- CHAMS
local Chams = Tab:CreateSection("Chams")

Chams:CreateToggle("Enabled", false, function(v)
    esp:UpdateSettings({ Chams = { Enabled = v } })
end)

Chams:CreateSlider("Fill Transparency", 0, 100, 95, function(v)
    esp:UpdateSettings({ Chams = { Fill = { Transparency = v/100 } } })
end)

Chams:CreateSlider("Outline Transparency", 0, 100, 60, function(v)
    esp:UpdateSettings({ Chams = { Outline = { Transparency = v/100 } } })
end)

Chams:CreateColorPicker("Fill Color", rgb(255,255,255), function(c)
    esp:UpdateSettings({ Chams = { Fill = { Color = c } } })
end)

Chams:CreateColorPicker("Outline Color", rgb(255,255,255), function(c)
    esp:UpdateSettings({ Chams = { Outline = { Color = c } } })
end)

-- BOX
local Box = Tab:CreateSection("Box")

Box:CreateToggle("Enabled", true, function(v)
    esp:UpdateSettings({ Box = { Enabled = v } })
end)

Box:CreateDropdown("Type", {"Box","Corner"}, function(v)
    esp:UpdateSettings({ Box = { Type = v } })
end)

Box:CreateToggle("Gradient", true, function(v)
    esp:UpdateSettings({ Box = { GradientEnabled = v } })
end)

Box:CreateToggle("Fill", true, function(v)
    esp:UpdateSettings({ Box = { Fill = v } })
end)

Box:CreateToggle("Fill Gradient", true, function(v)
    esp:UpdateSettings({ Box = { FillGradientEnabled = v } })
end)

Box:CreateSlider("Gradient Rotation", 0, 360, 90, function(v)
    esp:UpdateSettings({ Box = { Gradient = { Rotation = v } } })
end)

Box:CreateColorPicker("Top Color", rgb(255,255,255), function(c)
    esp:UpdateSettings({
        Box = {
            Gradient = {
                ColorSequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c),
                    ColorSequenceKeypoint.new(1, rgb(235,130,255))
                })
            }
        }
    })
end)

-- HEALTHBAR
local Health = Tab:CreateSection("Healthbar")

Health:CreateToggle("Enabled", true, function(v)
    esp:UpdateSettings({ Healthbar = { Enabled = v } })
end)

Health:CreateDropdown("Position", {"Left","Right","Top","Bottom"}, function(v)
    esp:UpdateSettings({ Healthbar = { Position = v } })
end)

Health:CreateSlider("Thickness", 1, 10, 3, function(v)
    esp:UpdateSettings({ Healthbar = { Thickness = v } })
end)

Health:CreateToggle("Tween", true, function(v)
    esp:UpdateSettings({ Healthbar = { Tween = v } })
end)

Health:CreateSlider("Tween Speed", 0, 100, 30, function(v)
    esp:UpdateSettings({ Healthbar = { TweenSpeed = v/100 } })
end)

Health:CreateDropdown("Easing Style", {"Linear","Quad","Cubic","Quart","Quint"}, function(v)
    esp:UpdateSettings({ Healthbar = { EasingStyle = v } })
end)

Health:CreateDropdown("Easing Direction", {"In","Out","InOut"}, function(v)
    esp:UpdateSettings({ Healthbar = { EasingDirection = v } })
end)

Health:CreateToggle("Gradient", true, function(v)
    esp:UpdateSettings({ Healthbar = { GradientEnabled = v } })
end)

-- NAME
local Name = Tab:CreateSection("Name")

Name:CreateToggle("Enabled", true, function(v)
    esp:UpdateSettings({ NameText = { Enabled = v } })
end)

Name:CreateDropdown("Position", {"Top","Bottom","Left","Right"}, function(v)
    esp:UpdateSettings({ NameText = { Position = v } })
end)

Name:CreateSlider("Size", 8, 24, 12, function(v)
    esp:UpdateSettings({ NameText = { Size = v } })
end)

Name:CreateColorPicker("Color", rgb(255,255,255), function(c)
    esp:UpdateSettings({ NameText = { Color = { Color = c } } })
end)

Name:CreateDropdown("Font", {"Tahoma","Gotham","Roboto","Poppins"}, function(v)
    esp:UpdateSettings({ NameText = { CustomFontName = v } })
end)

-- DISTANCE
local Dist = Tab:CreateSection("Distance")

Dist:CreateToggle("Enabled", true, function(v)
    esp:UpdateSettings({ DistanceText = { Enabled = v } })
end)

Dist:CreateDropdown("Position", {"Top","Bottom","Left","Right"}, function(v)
    esp:UpdateSettings({ DistanceText = { Position = v } })
end)

Dist:CreateSlider("Size", 8, 24, 12, function(v)
    esp:UpdateSettings({ DistanceText = { Size = v } })
end)

Dist:CreateColorPicker("Color", rgb(255,255,255), function(c)
    esp:UpdateSettings({ DistanceText = { Color = { Color = c } } })
end)

-- UNLOAD
local Unload = Tab:CreateSection("Unload")

Unload:CreateButton("Unload ESP", function()
    getgenv().UnloadESP()
end)
