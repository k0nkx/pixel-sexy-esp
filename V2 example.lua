--[[
    ESP Library - Example Usage Script
    
    Instructions:
    1. Make sure ESPLibrary.lua is saved to your executor's workspace folder
    2. Run this script
]]

local ESP = loadstring(game:HttpGet("ESPLibrary.lua"))()

-- ============================================
-- Optional: customize settings before starting
-- (you can also just change everything in the UI)
-- ============================================
local esp = ESP.new({
    Main = {
        Enabled        = true,
        RenderDistance = 5000,
    },
    Box = {
        Enabled         = true,
        Type            = "Corner",   -- corner brackets instead of full box
        GradientEnabled = true,
        Fill            = true,
    },
    Healthbar = {
        Enabled   = true,
        Position  = "Left",
        Thickness = 3,
        Tween     = true,
        TweenSpeed= 0.2,
    },
    NameText = {
        Enabled        = true,
        Position       = "Top",
        Size           = 13,
        UseCustomFont  = true,
        CustomFontName = "Poppins",
    },
    DistanceText = {
        Enabled        = true,
        Position       = "Bottom",
        Size           = 11,
        UseCustomFont  = true,
        CustomFontName = "Poppins",
    },
    Chams = {
        Enabled = false,   -- turn on via the UI if you want it
    },
})

-- Start the ESP render loop
esp:Start()

-- Open the config UI window
esp:OpenUI()
