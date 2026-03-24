local ESPLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/pixel-sexy-esp/refs/heads/main/Optimized%20esp%20module.lua"))()

-- Or if you want to embed the library directly in the script:
--[[
local ESPLib = loadstring([[
-- Paste the entire ESPLib module code here
]])()
--]]

-- Define your settings
local settings = {
    Main = {
        Enabled = true,
        RenderDistance = 10000,
    },
    
    Chams = {
        Enabled = true,
        Fill = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.95 },
        Outline = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.6 },
    },
    
    Box = {
        Enabled = true,
        Type = "Box", -- "Box" or "Corner"
        GradientEnabled = true,
        Gradient = {
            ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 130, 255))
            }),
            Rotation = 90,
        },
        Fill = true,
        FillGradientEnabled = true,
        FillGradient = {
            ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 130, 255))
            }),
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.9),
                NumberSequenceKeypoint.new(1, 0.5)
            })
        },
    },
    
    Healthbar = {
        Enabled = true,
        Position = "Left", -- "Left", "Right", "Top", "Bottom"
        Thickness = 3,
        Tween = true,
        TweenSpeed = 0.3,
        EasingStyle = "Quad",
        EasingDirection = "Out",
        GradientEnabled = true,
        Gradient = {
            ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(246, 199, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 130, 255))
            }),
            Rotation = 90,
        }
    },
    
    NameText = {
        Enabled = true,
        Color = { Color = Color3.fromRGB(255, 255, 255) },
        Position = "Top", -- "Top", "Bottom", "Left", "Right"
        Size = 12,
        Font = Enum.Font.SourceSans, -- Roblox fallback font
        UseCustomFont = true, -- Set to true to use custom font
        CustomFontName = "Tahoma", -- Font name from CustomFonts table
    },
    
    DistanceText = {
        Enabled = true,
        Color = { Color = Color3.fromRGB(255, 255, 255) },
        Position = "Bottom",
        Size = 12,
        Font = Enum.Font.SourceSans,
        UseCustomFont = true,
        CustomFontName = "Tahoma",
    },
}

-- Initialize ESP
local success = ESPLib.Initialize(settings)
if success then
    print("ESP Library loaded successfully!")
else
    warn("Failed to load ESP Library")
end

-- Example: Toggle features on/off with keybinds
local UserInputService = cloneref(game:GetService("UserInputService"))

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Press F1 to toggle ESP on/off
    if input.KeyCode == Enum.KeyCode.F1 then
        settings.Main.Enabled = not settings.Main.Enabled
        ESPLib.UpdateSettings(settings)
        print("ESP Enabled: " .. tostring(settings.Main.Enabled))
    end
    
    -- Press F2 to toggle Box ESP
    if input.KeyCode == Enum.KeyCode.F2 then
        settings.Box.Enabled = not settings.Box.Enabled
        ESPLib.UpdateSettings(settings)
        print("Box ESP: " .. tostring(settings.Box.Enabled))
    end
    
    -- Press F3 to toggle Healthbar
    if input.KeyCode == Enum.KeyCode.F3 then
        settings.Healthbar.Enabled = not settings.Healthbar.Enabled
        ESPLib.UpdateSettings(settings)
        print("Healthbar: " .. tostring(settings.Healthbar.Enabled))
    end
    
    -- Press F4 to toggle Name Text
    if input.KeyCode == Enum.KeyCode.F4 then
        settings.NameText.Enabled = not settings.NameText.Enabled
        ESPLib.UpdateSettings(settings)
        print("Name Text: " .. tostring(settings.NameText.Enabled))
    end
    
    -- Press F5 to toggle Distance Text
    if input.KeyCode == Enum.KeyCode.F5 then
        settings.DistanceText.Enabled = not settings.DistanceText.Enabled
        ESPLib.UpdateSettings(settings)
        print("Distance Text: " .. tostring(settings.DistanceText.Enabled))
    end
    
    -- Press F6 to toggle Chams
    if input.KeyCode == Enum.KeyCode.F6 then
        settings.Chams.Enabled = not settings.Chams.Enabled
        ESPLib.UpdateSettings(settings)
        print("Chams: " .. tostring(settings.Chams.Enabled))
    end
    
    -- Press End to unload ESP completely
    if input.KeyCode == Enum.KeyCode.End then
        ESPLib.Unload()
        print("ESP Unloaded")
    end
end)
