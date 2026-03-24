local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/pixel-sexy-esp/refs/heads/main/Optimized%20esp%20module.lua"))()

-- Create ESP with custom settings
local esp = ESPLibrary.new({
    Box = {
        Enabled = true,
        Type = "Corner",
    },
    NameText = {
        Enabled = true,
        Position = "Top",
        Size = 14,
    },
    DistanceText = {
        Enabled = true,
        Position = "Bottom",
    }
})

-- Start the ESP
esp:Start()

-- Later, to stop
-- esp:Stop()
