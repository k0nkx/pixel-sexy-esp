-- Load ESP Library
local ESPLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/pixel-sexy-esp/refs/heads/main/Optimized%20esp%20module.lua?token=GHSAT0AAAAAADRVYZILGEHOIJ2B5YHDHW2A2OCAR6A"))()

-- ur ui lib here
local Aero =loadstring(game:HttpGet(" UH IDK "))()

-- put the settings table here I'm to lazy
local settings = { ... } -- Same settings table

-- Initialize ESP
ESPLib.Initialize(settings)

-- Create Aero Window
local window = Aero:CreateWindow("ESP Settings", Enum.KeyCode.RightShift)

-- Create categories
local main = window:CreateCategory("Main")
local visual = window:CreateCategory("Visuals")
local text = window:CreateCategory("Text")
local colors = window:CreateCategory("Colors")

-- Add elements
main:CreateToggle("Enable ESP", settings.Main.Enabled, function(Value)
    settings.Main.Enabled = Value
    ESPLib.UpdateSettings(settings)
end)

main:CreateSlider("Render Distance", settings.Main.RenderDistance, 500, 20000, function(Value)
    settings.Main.RenderDistance = Value
    ESPLib.UpdateSettings(settings)
end)

visual:CreateToggle("Box ESP", settings.Box.Enabled, function(Value)
    settings.Box.Enabled = Value
    ESPLib.UpdateSettings(settings)
end)

visual:CreateDropdown("Box Type", {"Box", "Corner"}, settings.Box.Type, function(Value)
    settings.Box.Type = Value
    ESPLib.UpdateSettings(settings)
end)

visual:CreateToggle("Healthbar", settings.Healthbar.Enabled, function(Value)
    settings.Healthbar.Enabled = Value
    ESPLib.UpdateSettings(settings)
end)

visual:CreateDropdown("Healthbar Position", {"Left", "Right", "Top", "Bottom"}, settings.Healthbar.Position, function(Value)
    settings.Healthbar.Position = Value
    ESPLib.UpdateSettings(settings)
end)

text:CreateToggle("Name Tags", settings.NameText.Enabled, function(Value)
    settings.NameText.Enabled = Value
    ESPLib.UpdateSettings(settings)
end)

text:CreateSlider("Name Text Size", settings.NameText.Size, 8, 24, function(Value)
    settings.NameText.Size = Value
    ESPLib.UpdateSettings(settings)
end)

text:CreateToggle("Distance Text", settings.DistanceText.Enabled, function(Value)
    settings.DistanceText.Enabled = Value
    ESPLib.UpdateSettings(settings)
end)

colors:CreateToggle("Chams", settings.Chams.Enabled, function(Value)
    settings.Chams.Enabled = Value
    ESPLib.UpdateSettings(settings)
end)

colors:CreateColorPicker("Chams Color", settings.Chams.Fill.Color, function(Value)
    settings.Chams.Fill.Color = Value
    ESPLib.UpdateSettings(settings)
end)
