--[[
    ESP Library v1.0
    A flexible ESP system with modular components
]]

local ESPLibrary = {}
ESPLibrary.__index = ESPLibrary

-- Dependencies
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Camera = cloneref(workspace.CurrentCamera)
local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))

-- Utility functions
local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local function dim2(xScale, xOffset, yScale, yOffset)
    return UDim2.new(xScale, xOffset, yScale, yOffset)
end

local function dim(scale, offset)
    return UDim.new(scale, offset)
end

local function dim_offset(x, y)
    return UDim2.new(0, x, 0, y)
end

local function vec2(x, y)
    return Vector2.new(x, y)
end

local function rect(min, max)
    return Rect.new(min, max)
end

-- Custom Fonts Library
ESPLibrary.Fonts = {
    Tahoma = { url = "https://github.com/k0nkx/UI-Lib-Tuff/raw/refs/heads/main/Windows-XP-Tahoma.ttf" },
    Gotham = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Gotham/Regular/Gotham-Regular.ttf" },
    Ubuntu = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Ubuntu/Regular/Ubuntu-Regular.ttf" },
    Montserrat = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Montserrat/Regular/Montserrat-Regular.ttf" },
    Inter = { url = "https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Regular.otf" },
    Poppins = { url = "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" },
    Roboto = { url = "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Regular.ttf" },
    OpenSans = { url = "https://github.com/google/fonts/raw/main/ofl/opensans/OpenSans%5Bwdth,wght%5D.ttf" },
    Kanit = { url = "https://github.com/google/fonts/raw/main/ofl/kanit/Kanit-Regular.ttf" },
    JetBrainsMono = { url = "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf" },
    FiraCode = { url = "https://github.com/tonsky/FiraCode/raw/master/distr/ttf/FiraCode-Regular.ttf" },
    Inconsolata = { url = "https://github.com/google/fonts/raw/main/ofl/inconsolata/static/Inconsolata-Regular.ttf" },
    SpaceMono = { url = "https://github.com/google/fonts/raw/main/ofl/spacemono/SpaceMono-Regular.ttf" },
    Hack = { url = "https://github.com/source-foundry/Hack/raw/master/build/ttf/Hack-Regular.ttf" },
    BebasNeue = { url = "https://github.com/google/fonts/raw/main/ofl/bebasneue/BebasNeue-Regular.ttf" },
    Oswald = { url = "https://github.com/google/fonts/raw/main/ofl/oswald/static/Oswald-Regular.ttf" },
    ArchivoBlack = { url = "https://github.com/google/fonts/raw/main/ofl/archivoblack/ArchivoBlack-Regular.ttf" },
    Syne = { url = "https://github.com/google/fonts/raw/main/ofl/syne/Syne%5Bwght%5D.ttf" },
    Outfit = { url = "https://github.com/google/fonts/raw/main/ofl/outfit/static/Outfit-Regular.ttf" },
    PlayfairDisplay = { url = "https://github.com/google/fonts/raw/main/ofl/playfairdisplay/static/PlayfairDisplay-Regular.ttf" },
    Lora = { url = "https://github.com/google/fonts/raw/main/ofl/lora/static/Lora-Regular.ttf" },
    Merriweather = { url = "https://github.com/google/fonts/raw/main/ofl/merriweather/static/Merriweather-Regular.ttf" },
    PTSerif = { url = "https://github.com/google/fonts/raw/main/ofl/ptserif/PTSerif-Regular.ttf" },
    LibreBaskerville = { url = "https://github.com/google/fonts/raw/main/ofl/librebaskerville/LibreBaskerville-Regular.ttf" },
    PressStart2P = { url = "https://github.com/google/fonts/raw/main/ofl/pressstart2p/PressStart2P-Regular.ttf" },
    Silkscreen = { url = "https://github.com/google/fonts/raw/main/ofl/silkscreen/Silkscreen-Regular.ttf" },
    PixelifySans = { url = "https://github.com/google/fonts/raw/main/ofl/pixelifysans/PixelifySans%5Bwght%5D.ttf" },
    Lexend = { url = "https://github.com/google/fonts/raw/main/ofl/lexend/static/Lexend-Regular.ttf" }
}

-- ============================================
-- ESP Instance Class
-- ============================================

function ESPLibrary.new(settings)
    local self = setmetatable({}, ESPLibrary)
    
    -- Merge settings with defaults
    self.Settings = {
        Main = {
            Enabled = true,
            RenderDistance = 10000,
        },
        Chams = {
            Enabled = false,
            Fill = { Color = rgb(255, 255, 255), Transparency = 0.95 },
            Outline = { Color = rgb(255, 255, 255), Transparency = 0.6 },
        },
        Box = {
            Enabled = true,
            Type = "Box", -- "Box" or "Corner"
            GradientEnabled = true,
            Gradient = {
                ColorSequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, rgb(235, 130, 255))
                }),
                Rotation = 90,
                Transparency = NumberSequence.new(0.9)
            },
            Fill = true,
            FillGradientEnabled = true,
            FillGradient = {
                ColorSequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, rgb(235, 130, 255))
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
                    ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, rgb(246, 199, 255)),
                    ColorSequenceKeypoint.new(1, rgb(235, 130, 255))
                }),
                Rotation = 90,
            }
        },
        NameText = {
            Enabled = true,
            Color = { Color = rgb(255, 255, 255) },
            Position = "Top", -- "Top", "Bottom", "Left", "Right"
            Size = 12,
            Font = Enum.Font.SourceSans,
            UseCustomFont = true,
            CustomFontName = "Tahoma",
        },
        DistanceText = {
            Enabled = true,
            Color = { Color = rgb(255, 255, 255) },
            Position = "Bottom", -- "Top", "Bottom", "Left", "Right"
            Size = 12,
            Font = Enum.Font.SourceSans,
            UseCustomFont = true,
            CustomFontName = "Tahoma",
        },
    }
    
    -- Override with user settings if provided
    if settings then
        for category, categorySettings in pairs(settings) do
            if self.Settings[category] then
                for key, value in pairs(categorySettings) do
                    self.Settings[category][key] = value
                end
            end
        end
    end
    
    -- Internal state
    self.EspPlayers = {}
    self.EspConnections = {}
    self.LoopConnection = nil
    self.LoadedCustomFonts = {}
    self.GuiObjects = {}
    
    -- Initialize GUI containers
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ESPLibrary"
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui
    
    self.Cache = Instance.new("ScreenGui")
    self.Cache.Name = "ESPLibraryCache"
    self.Cache.Enabled = false
    self.Cache.ResetOnSpawn = false
    self.Cache.Parent = CoreGui
    
    return self
end

-- ============================================
-- Internal Helper Functions
-- ============================================

function ESPLibrary:Create(instance, options)
    local Ins = Instance.new(instance)
    for prop, value in pairs(options) do
        Ins[prop] = value
    end
    return Ins
end

function ESPLibrary:LoadCustomFont(fontName)
    local fontData = self.Fonts[fontName]
    if not fontData then return nil end
    
    local fileName = fontName .. ".ttf"
    local fontFileName = fontName .. ".font"
    
    local success, result = pcall(function()
        if not isfile(fileName) then
            return game:HttpGet(fontData.url)
        end
        return nil
    end)
    
    if success and result then
        local writeSuccess = pcall(function()
            writefile(fileName, result)
        end)
        if not writeSuccess then
            return nil
        end
    elseif not isfile(fileName) then
        return nil
    end
    
    local fontConfig = {
        name = fontName,
        faces = {{
            name = "Regular",
            weight = 400,
            style = "normal",
            assetId = getcustomasset(fileName)
        }}
    }
    
    local jsonSuccess = pcall(function()
        writefile(fontFileName, HttpService:JSONEncode(fontConfig))
    end)
    
    if not jsonSuccess then
        return nil
    end
    
    local fontSuccess, font = pcall(function()
        return Font.new(getcustomasset(fontFileName), Enum.FontWeight.Regular)
    end)
    
    if fontSuccess then
        return font
    end
    return nil
end

function ESPLibrary:ApplyFontToText(textLabel, settings)
    if settings.UseCustomFont then
        if not self.LoadedCustomFonts[settings.CustomFontName] then
            local font = self:LoadCustomFont(settings.CustomFontName)
            if font then
                self.LoadedCustomFonts[settings.CustomFontName] = font
                textLabel.FontFace = font
                return true
            else
                textLabel.Font = settings.Font
                return false
            end
        else
            textLabel.FontFace = self.LoadedCustomFonts[settings.CustomFontName]
            return true
        end
    else
        textLabel.Font = settings.Font
        return true
    end
end

function ESPLibrary:ConvertScreenPoint(world_position)
    local ViewportSize = Camera.ViewportSize
    local LocalPos = Camera.CFrame:PointToObjectSpace(world_position)
    
    local AspectRatio = ViewportSize.X / ViewportSize.Y
    local HalfY = -LocalPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))
    local HalfX = AspectRatio * HalfY
    
    local FarPlaneCorner = Vector3.new(-HalfX, HalfY, LocalPos.Z)
    local RelativePos = LocalPos - FarPlaneCorner
    
    local ScreenX = RelativePos.X / (HalfX * 2)
    local ScreenY = -RelativePos.Y / (HalfY * 2)
    
    local OnScreen = -LocalPos.Z > 0 and ScreenX >= 0 and ScreenX <= 1 and ScreenY >= 0 and ScreenY <= 1
    
    return Vector3.new(ScreenX * ViewportSize.X, ScreenY * ViewportSize.Y, -LocalPos.Z), OnScreen
end

function ESPLibrary:BoxSolve(rootPart)
    if not rootPart then
        return nil, nil, nil, nil
    end
    
    local ViewportTop = rootPart.Position + (rootPart.CFrame.UpVector * 1.8) + Camera.CFrame.UpVector
    local ViewportBottom = rootPart.Position - (rootPart.CFrame.UpVector * 2.5) - Camera.CFrame.UpVector
    local Distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    
    local Top, TopIsRendered = self:ConvertScreenPoint(ViewportTop)
    local Bottom, BottomIsRendered = self:ConvertScreenPoint(ViewportBottom)
    
    local Width = math.max(math.floor(math.abs(Top.X - Bottom.X)), 8)
    local Height = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 12)
    local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
    local BoxPosition = Vector2.new(math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5), math.floor(math.min(Top.Y, Bottom.Y)))
    
    return BoxSize, BoxPosition, TopIsRendered, Distance
end

-- ============================================
-- UI Element Creation Methods
-- ============================================

function ESPLibrary:CreateBoxElements(Items, player)
    Items.Box = self:Create("Frame", {
        Parent = self.Cache,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIStroke", {
        Parent = Items.Box,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Inner = self:Create("Frame", {
        Parent = Items.Box,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.UIStroke = self:Create("UIStroke", {
        Color = rgb(255, 255, 255),
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = Items.Inner
    })
    
    Items.BoxGradient = self:Create("UIGradient", {
        Parent = Items.UIStroke,
        Color = self.Settings.Box.Gradient.ColorSequence,
        Enabled = self.Settings.Box.GradientEnabled,
        Rotation = self.Settings.Box.Gradient.Rotation
    })
    
    Items.Inner2 = self:Create("Frame", {
        Parent = Items.Inner,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIStroke", {
        Parent = Items.Inner2,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Corners = self:Create("Frame", {
        Parent = self.Cache,
        Name = "",
        BackgroundTransparency = 1,
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    -- Corner elements
    Items.BottomLeftX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        BorderColor3 = rgb(0, 0, 0),
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(0.4, 0, 0, 3),
        AnchorPoint = vec2(0, 1),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
    self:Create("UIGradient", { Parent = Items.BottomLeftX })
    
    Items.BottomLeftY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        BorderColor3 = rgb(0, 0, 0),
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(0, 3, 0.25, 0),
        AnchorPoint = vec2(0, 1),
        Image = "rbxassetid://101715268403902",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, -2),
        ZIndex = 500,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 96))
    })
    
    self:Create("UIGradient", { Rotation = -90, Parent = Items.BottomLeftY })
    
    Items.BottomRightX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        BorderColor3 = rgb(0, 0, 0),
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(0.4, 0, 0, 3),
        AnchorPoint = vec2(1, 1),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 1, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
    self:Create("UIGradient", { Parent = Items.BottomRightX })
    
    Items.BottomRightY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        BorderColor3 = rgb(0, 0, 0),
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(0, 3, 0.25, 0),
        AnchorPoint = vec2(1, 1),
        Image = "rbxassetid://101715268403902",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 1, -2),
        ZIndex = 500,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 96))
    })
    
    self:Create("UIGradient", { Rotation = 90, Parent = Items.BottomRightY })
    
    Items.TopLeftY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Items.Corners,
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(0, 3, 0.25, 0),
        Image = "rbxassetid://102467475629368",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, 2),
        ZIndex = 500,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 98))
    })
    
    self:Create("UIGradient", { Rotation = 90, Parent = Items.TopLeftY })
    
    Items.TopRightY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        BorderColor3 = rgb(0, 0, 0),
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(0, 3, 0.25, 0),
        AnchorPoint = vec2(1, 0),
        Image = "rbxassetid://102467475629368",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 0, 2),
        ZIndex = 500,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 98))
    })
    
    self:Create("UIGradient", { Rotation = -90, Parent = Items.TopRightY })
    
    Items.TopRightX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        BorderColor3 = rgb(0, 0, 0),
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(0.4, 0, 0, 3),
        AnchorPoint = vec2(1, 0),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
    self:Create("UIGradient", { Parent = Items.TopRightX })
    
    Items.TopLeftX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Items.Corners,
        Name = "",
        BackgroundColor3 = rgb(255, 255, 255),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        Size = dim2(0.4, 0, 0, 3),
        ZIndex = 2,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
    self:Create("UIGradient", { Parent = Items.TopLeftX })
    
    if self.Settings.Box.Type == "Corner" then
        Items.Corners.Parent = Items.Holder
        Items.Box.Parent = self.Cache
    else
        Items.Box.Parent = Items.Holder
        Items.Corners.Parent = self.Cache
    end
    
    if self.Settings.Box.Fill then
        Items.Holder.BackgroundTransparency = 0
        if self.Settings.Box.FillGradientEnabled then
            Items.HolderGradient.Color = self.Settings.Box.FillGradient.ColorSequence
            Items.HolderGradient.Transparency = self.Settings.Box.FillGradient.Transparency
            Items.HolderGradient.Rotation = self.Settings.Box.FillGradient.Rotation
        end
    end
end

function ESPLibrary:CreateHealthbarElements(Items)
    Items.Healthbar = self:Create("Frame", {
        Name = self.Settings.Healthbar.Position,
        Parent = self.Cache,
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(0, self.Settings.Healthbar.Thickness, 0, self.Settings.Healthbar.Thickness),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(0, 0, 0)
    })
    
    Items.HealthbarAccent = self:Create("Frame", {
        Parent = Items.Healthbar,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.HealthbarFade = self:Create("Frame", {
        Parent = Items.Healthbar,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(0, 0, 0)
    })
    
    Items.HealthbarGradient = self:Create("UIGradient", {
        Enabled = self.Settings.Healthbar.GradientEnabled,
        Parent = Items.HealthbarAccent,
        Rotation = self.Settings.Healthbar.Gradient.Rotation,
        Color = self.Settings.Healthbar.Gradient.ColorSequence
    })
    
    Items.Healthbar.Parent = Items[self.Settings.Healthbar.Position]
    Items.Healthbar.Visible = true
end

function ESPLibrary:CreateNameTextElements(Items, player)
    Items.Text = self:Create("TextLabel", {
        TextColor3 = self.Settings.NameText.Color.Color,
        BorderColor3 = rgb(0, 0, 0),
        Parent = self.Cache,
        Name = self.Settings.NameText.Position,
        Text = player.Name,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = self.Settings.NameText.Size,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:ApplyFontToText(Items.Text, self.Settings.NameText)
    
    self:Create("UIStroke", {
        Parent = Items.Text,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Text.Parent = Items[self.Settings.NameText.Position .. "Texts"]
    if self.Settings.NameText.Position == "Top" or self.Settings.NameText.Position == "Bottom" then
        Items.Text.AutomaticSize = Enum.AutomaticSize.Y
        Items.Text.TextXAlignment = Enum.TextXAlignment.Center
    else
        Items.Text.AutomaticSize = Enum.AutomaticSize.XY
        Items.Text.TextXAlignment = self.Settings.NameText.Position == "Right" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    end
end

function ESPLibrary:CreateDistanceTextElements(Items)
    Items.Distance = self:Create("TextLabel", {
        TextColor3 = self.Settings.DistanceText.Color.Color,
        BorderColor3 = rgb(0, 0, 0),
        Parent = self.Cache,
        Name = self.Settings.DistanceText.Position,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = self.Settings.DistanceText.Size,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:ApplyFontToText(Items.Distance, self.Settings.DistanceText)
    
    self:Create("UIStroke", {
        Parent = Items.Distance,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Distance.Parent = Items[self.Settings.DistanceText.Position .. "Texts"]
    if self.Settings.DistanceText.Position == "Top" or self.Settings.DistanceText.Position == "Bottom" then
        Items.Distance.AutomaticSize = Enum.AutomaticSize.Y
        Items.Distance.TextXAlignment = Enum.TextXAlignment.Center
    else
        Items.Distance.AutomaticSize = Enum.AutomaticSize.XY
        Items.Distance.TextXAlignment = self.Settings.DistanceText.Position == "Right" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    end
end

function ESPLibrary:CreateChamsElements(Data)
    Data.Highlight = self:Create("Highlight", {
        FillColor = self.Settings.Chams.Fill.Color,
        Enabled = self.Settings.Chams.Enabled,
        OutlineTransparency = self.Settings.Chams.Outline.Transparency,
        Adornee = Data.Info.Character,
        FillTransparency = self.Settings.Chams.Fill.Transparency,
        OutlineColor = self.Settings.Chams.Outline.Color,
        Parent = CoreGui
    })
end

-- ============================================
-- Player Object Creation
-- ============================================

function ESPLibrary:CreateObject(player)
    local Data = {
        Items = {},
        Info = {}
    }
    
    local Items = Data.Items
    
    -- Create holder frame
    Items.Holder = self:Create("Frame", {
        Parent = self.ScreenGui,
        Visible = false,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0.433, 0, 0.326, 0),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(0, 211, 0, 240),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.HolderGradient = self:Create("UIGradient", {
        Rotation = 0,
        Name = "",
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(255, 255, 255))
        }),
        Parent = Items.Holder,
        Enabled = true
    })
    
    -- Container frames for text positioning
    Items.Left = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(0, 0, 1, 0),
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, -1, 0, 0),
        BorderColor3 = rgb(0, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Left,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.LeftTexts = self:Create("Frame", {
        LayoutOrder = -100,
        Parent = Items.Left,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        Parent = Items.LeftTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Bottom = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(1, 0, 0, 0),
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, 1),
        BorderColor3 = rgb(0, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Bottom,
        Padding = dim(0, 1)
    })
    
    Items.BottomTexts = self:Create("Frame", {
        LayoutOrder = 1,
        Parent = Items.Bottom,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        Parent = Items.BottomTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Top = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(1, 0, 0, 0),
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, -1),
        BorderColor3 = rgb(0, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Top,
        Padding = dim(0, 1)
    })
    
    Items.TopTexts = self:Create("Frame", {
        LayoutOrder = -100,
        Parent = Items.Top,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        Parent = Items.TopTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Right = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(0, 0, 1, 0),
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(1, 1, 0, 0),
        BorderColor3 = rgb(0, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Right,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.RightTexts = self:Create("Frame", {
        LayoutOrder = 100,
        Parent = Items.Right,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    self:Create("UIListLayout", {
        Parent = Items.RightTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Create elements based on settings
    if self.Settings.Box.Enabled then
        self:CreateBoxElements(Items, player)
    end
    
    if self.Settings.Healthbar.Enabled then
        self:CreateHealthbarElements(Items)
    end
    
    if self.Settings.NameText.Enabled then
        self:CreateNameTextElements(Items, player)
    end
    
    if self.Settings.DistanceText.Enabled then
        self:CreateDistanceTextElements(Items)
    end
    
    -- Setup character tracking
    local HealthTween = nil
    
    Data.HealthChanged = function(Value)
        if not self.Settings.Healthbar.Enabled or not Items.Healthbar then
            return
        end
        
        local Multiplier = math.clamp(Value / 100, 0, 1)
        local isHorizontal = self.Settings.Healthbar.Position == "Top" or self.Settings.Healthbar.Position == "Bottom"
        
        local targetSize
        local targetPosition
        
        if isHorizontal then
            targetSize = dim2(1 - Multiplier, -2, 1, -2)
            targetPosition = dim2(Multiplier, 1, 0, 1)
        else
            targetSize = dim2(1, 0, 1 - Multiplier, 0)
            targetPosition = dim2(0, 1, Multiplier, 1)
        end
        
        if self.Settings.Healthbar.Tween and TweenService then
            if HealthTween and HealthTween.Cancel then
                HealthTween:Cancel()
            end
            
            local tweenInfo = TweenInfo.new(
                self.Settings.Healthbar.TweenSpeed,
                Enum.EasingStyle[self.Settings.Healthbar.EasingStyle],
                Enum.EasingDirection[self.Settings.Healthbar.EasingDirection]
            )
            
            HealthTween = TweenService:Create(Items.HealthbarFade, tweenInfo, {
                Size = targetSize,
                Position = targetPosition
            })
            HealthTween:Play()
        else
            Items.HealthbarFade.Size = targetSize
            Items.HealthbarFade.Position = targetPosition
        end
    end
    
    Data.RefreshChams = function()
        if not self.Settings.Chams.Enabled then
            if Data.Highlight then
                Data.Highlight:Destroy()
                Data.Highlight = nil
            end
            return
        end
        
        local Character = Data.Info.Character
        if Character then
            if not Data.Highlight then
                self:CreateChamsElements(Data)
            else
                Data.Highlight.Adornee = Character
                Data.Highlight.Enabled = true
            end
        end
    end
    
    Data.RefreshDescendants = function()
        local Character = player.Character
        if not Character then
            Character = player.CharacterAdded:Wait()
        end
        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid then
            Humanoid = Character:WaitForChild("Humanoid")
        end
        
        Data.Info.Character = Character
        Data.Info.Humanoid = Humanoid
        Data.Info.RootPart = Humanoid.RootPart
        
        if self.Settings.Healthbar.Enabled then
            local conn = Humanoid.HealthChanged:Connect(function(h)
                Data.HealthChanged(h)
            end)
            table.insert(self.EspConnections, conn)
            Data.HealthChanged(Humanoid.Health)
        end
        
        Data.RefreshChams()
    end
    
    Data.Destroy = function()
        if Items.Holder then
            Items.Holder:Destroy()
        end
        if Data.Highlight then
            Data.Highlight:Destroy()
        end
        self.EspPlayers[player.Name] = nil
    end
    
    Data.RefreshDescendants()
    
    local conn = player.CharacterAdded:Connect(function()
        Data.RefreshDescendants()
    end)
    table.insert(self.EspConnections, conn)
    
    self.EspPlayers[player.Name] = Data
end

-- ============================================
-- Update and Main Loop
-- ============================================

function ESPLibrary:Update()
    -- Early exit if main ESP is disabled
    if not self.Settings.Main.Enabled then
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items and Data.Items.Holder then
                Data.Items.Holder.Visible = false
            end
        end
        return
    end
    
    -- Check if any visual features need positioning
    local needsPositionCalc = self.Settings.Box.Enabled or self.Settings.DistanceText.Enabled
    local hasAnyFeature = self.Settings.Box.Enabled or self.Settings.NameText.Enabled or 
                          self.Settings.DistanceText.Enabled or self.Settings.Healthbar.Enabled
    
    if not hasAnyFeature then
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items and Data.Items.Holder then
                Data.Items.Holder.Visible = false
            end
        end
        return
    end
    
    for _, Data in pairs(self.EspPlayers) do
        if Data.Info and Data.Info.Character and Data.Info.Humanoid and Data.Info.Humanoid.RootPart then
            local Items = Data.Items
            local Holder = Items.Holder
            
            if Holder then
                if needsPositionCalc then
                    local BoxSize, BoxPos, OnScreen, Distance = self:BoxSolve(Data.Info.Humanoid.RootPart)
                    
                    if Distance and Distance <= self.Settings.Main.RenderDistance and OnScreen then
                        Holder.Visible = true
                        Holder.Position = dim_offset(BoxPos.X, BoxPos.Y)
                        Holder.Size = dim2(0, BoxSize.X, 0, BoxSize.Y)
                        
                        if self.Settings.DistanceText.Enabled and Items.Distance then
                            Items.Distance.Text = tostring(math.round(Distance)) .. "m"
                        end
                    else
                        Holder.Visible = false
                    end
                else
                    Holder.Visible = true
                end
            end
        end
    end
end

-- ============================================
-- Public API Methods
-- ============================================

function ESPLibrary:Start()
    -- Create objects for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            self:CreateObject(player)
        end
    end
    
    -- Connect player events
    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            self:CreateObject(player)
        end
    end)
    table.insert(self.EspConnections, playerAddedConn)
    
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        if self.EspPlayers[player.Name] then
            self.EspPlayers[player.Name].Destroy()
        end
    end)
    table.insert(self.EspConnections, playerRemovingConn)
    
    -- Start render loop
    self.LoopConnection = RunService:BindToRenderStep("ESPLibrary_Update", 400, function()
        self:Update()
    end)
    
    return self
end

function ESPLibrary:Stop()
    -- Disconnect all connections
    for _, conn in pairs(self.EspConnections) do
        conn:Disconnect()
    end
    self.EspConnections = {}
    
    -- Unbind render step
    if self.LoopConnection then
        RunService:UnbindFromRenderStep("ESPLibrary_Update")
        self.LoopConnection = nil
    end
    
    -- Destroy all ESP objects
    for _, data in pairs(self.EspPlayers) do
        if data.Destroy then
            data.Destroy()
        end
    end
    self.EspPlayers = {}
    
    -- Destroy GUI containers
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    if self.Cache then
        self.Cache:Destroy()
    end
end

function ESPLibrary:UpdateSettings(settings)
    for category, categorySettings in pairs(settings) do
        if self.Settings[category] then
            for key, value in pairs(categorySettings) do
                self.Settings[category][key] = value
            end
        end
    end
    
    -- Recreate elements that need settings changes
    -- Note: This is simplified; full implementation would need to refresh affected elements
end

function ESPLibrary:SetEnabled(enabled)
    self.Settings.Main.Enabled = enabled
end

-- ============================================
-- Example Usage
-- ============================================

--[[
-- Create ESP instance with custom settings
local esp = ESPLibrary.new({
    Box = {
        Enabled = true,
        Type = "Corner",
        GradientEnabled = true,
    },
    Healthbar = {
        Enabled = true,
        Position = "Right",
        Thickness = 4,
    },
    NameText = {
        Enabled = true,
        Position = "Top",
        Size = 14,
        UseCustomFont = true,
        CustomFontName = "Poppins",
    },
    DistanceText = {
        Enabled = true,
        Position = "Bottom",
        Size = 11,
    },
})

-- Start ESP
esp:Start()

-- Toggle ESP on/off
-- esp:SetEnabled(false)

-- Update settings dynamically
-- esp:UpdateSettings({
--     Box = { Enabled = false },
--     Healthbar = { Enabled = true }
-- })

-- Stop ESP (cleanup)
-- esp:Stop()
--]]

return ESPLibrary
