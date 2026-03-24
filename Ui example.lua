-- Load your UI library (example using a common structure)
local Library = loadstring(game:HttpGet("https://example.com/ui-library.lua"))()
local Window = Library:CreateWindow("Example")
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/pixel-sexy-esp/refs/heads/main/Optimized%20esp%20module.lua"))()

-- Create ESP instance
local esp = ESPLibrary.new({
    Box = {
        Enabled = true,
        Type = "Box",
        GradientEnabled = true,
    },
    Healthbar = {
        Enabled = true,
        Position = "Left",
        Thickness = 3,
    },
    NameText = {
        Enabled = true,
        Position = "Top",
        Size = 12,
        UseCustomFont = true,
        CustomFontName = "Tahoma",
    },
    DistanceText = {
        Enabled = true,
        Position = "Bottom",
        Size = 11,
    },
})

-- Start ESP automatically
esp:Start()

-- Create UI Toggles and Controls
local VisualsTab = Window:CreateTab("Visuals")
local ESPTab = VisualsTab:CreateSection("ESP Settings")

-- Main ESP Toggle
local espToggle = ESPTab:CreateToggle("ESP Enabled", true, function(value)
    esp:SetEnabled(value)
end)

-- Box Settings
local BoxSection = ESPTab:CreateSection("Box")
local boxToggle = BoxSection:CreateToggle("Box ESP", true, function(value)
    esp:UpdateSettings({
        Box = { Enabled = value }
    })
end)

local boxTypeDropdown = BoxSection:CreateDropdown("Box Type", {"Box", "Corner"}, function(value)
    esp:UpdateSettings({
        Box = { Type = value }
    })
end)

local boxGradientToggle = BoxSection:CreateToggle("Box Gradient", true, function(value)
    esp:UpdateSettings({
        Box = { GradientEnabled = value }
    })
end)

local boxFillToggle = BoxSection:CreateToggle("Fill Box", true, function(value)
    esp:UpdateSettings({
        Box = { Fill = value }
    })
end)

-- Healthbar Settings
local HealthSection = ESPTab:CreateSection("Healthbar")
local healthToggle = HealthSection:CreateToggle("Healthbar", true, function(value)
    esp:UpdateSettings({
        Healthbar = { Enabled = value }
    })
end)

local healthPosition = HealthSection:CreateDropdown("Position", {"Left", "Right", "Top", "Bottom"}, function(value)
    esp:UpdateSettings({
        Healthbar = { Position = value }
    })
end)

local healthThickness = HealthSection:CreateSlider("Thickness", 1, 10, 3, function(value)
    esp:UpdateSettings({
        Healthbar = { Thickness = value }
    })
end)

local healthTweenToggle = HealthSection:CreateToggle("Smooth Animation", true, function(value)
    esp:UpdateSettings({
        Healthbar = { Tween = value }
    })
end)

-- Name Text Settings
local NameSection = ESPTab:CreateSection("Name Text")
local nameToggle = NameSection:CreateToggle("Show Name", true, function(value)
    esp:UpdateSettings({
        NameText = { Enabled = value }
    })
end)

local namePosition = NameSection:CreateDropdown("Position", {"Top", "Bottom", "Left", "Right"}, function(value)
    esp:UpdateSettings({
        NameText = { Position = value }
    })
end)

local nameSize = NameSection:CreateSlider("Text Size", 8, 24, 12, function(value)
    esp:UpdateSettings({
        NameText = { Size = value }
    })
end)

local fontDropdown = NameSection:CreateDropdown("Font", {
    "Tahoma", "Gotham", "Ubuntu", "Montserrat", "Inter", 
    "Poppins", "Roboto", "OpenSans", "Kanit", "JetBrainsMono"
}, function(value)
    esp:UpdateSettings({
        NameText = { 
            UseCustomFont = true,
            CustomFontName = value 
        }
    })
end)

-- Distance Text Settings
local DistanceSection = ESPTab:CreateSection("Distance Text")
local distanceToggle = DistanceSection:CreateToggle("Show Distance", true, function(value)
    esp:UpdateSettings({
        DistanceText = { Enabled = value }
    })
end)

local distancePosition = DistanceSection:CreateDropdown("Position", {"Top", "Bottom", "Left", "Right"}, function(value)
    esp:UpdateSettings({
        DistanceText = { Position = value }
    })
end)

local distanceSize = DistanceSection:CreateSlider("Text Size", 8, 24, 11, function(value)
    esp:UpdateSettings({
        DistanceText = { Size = value }
    })
end)

-- Chams Settings
local ChamsSection = ESPTab:CreateSection("Chams")
local chamsToggle = ChamsSection:CreateToggle("Chams", false, function(value)
    esp:UpdateSettings({
        Chams = { Enabled = value }
    })
end)

-- Render Distance
local RenderSection = ESPTab:CreateSection("Performance")
local renderDistance = RenderSection:CreateSlider("Render Distance", 50, 10000, 10000, function(value)
    esp:UpdateSettings({
        Main = { RenderDistance = value }
    })
end)

-- Color Pickers (if UI library supports)
local ColorSection = ESPTab:CreateSection("Colors")
local boxColor = ColorSection:CreateColorPicker("Box Color", Color3.fromRGB(255, 255, 255), function(color)
    -- Update box gradient colors
    esp:UpdateSettings({
        Box = {
            Gradient = {
                ColorSequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 130, 255))
                })
            }
        }
    })
end)

-- Unload button
local UnloadSection = VisualsTab:CreateSection("Unload")
local unloadButton = UnloadSection:CreateButton("Unload ESP", function()
    esp:Stop()
    -- Also unload your UI if needed
    Library:Unload()
end)
