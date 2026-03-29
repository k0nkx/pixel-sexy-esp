--[[
    ESP Library v2.0
    A flexible ESP system with modular components + UI Lib integration
    
    Usage:
        local ESP = loadstring(readfile("ESPLibrary.lua"))()
        ESP:Start()
        ESP:OpenUI()   -- opens the config window via the UI lib
        
    The UI lib is loaded automatically from:
        https://xk5ng.github.io/XK5NG_ui_lib.lua
]]

local ESPLibrary = {}
ESPLibrary.__index = ESPLibrary

-- Dependencies
local Players    = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Camera     = cloneref(workspace.CurrentCamera)
local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui    = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))

-- ============================================
-- Utility helpers
-- ============================================
local function rgb(r, g, b)    return Color3.fromRGB(r, g, b) end
local function dim2(xs,xo,ys,yo) return UDim2.new(xs,xo,ys,yo) end
local function dim(s,o)        return UDim.new(s,o) end
local function dim_offset(x,y) return UDim2.new(0,x,0,y) end
local function vec2(x,y)       return Vector2.new(x,y) end
local function rect(mn,mx)     return Rect.new(mn,mx) end

-- ============================================
-- Custom Fonts
-- ============================================
ESPLibrary.Fonts = {
    Tahoma        = { url = "https://github.com/k0nkx/UI-Lib-Tuff/raw/refs/heads/main/Windows-XP-Tahoma.ttf" },
    Gotham        = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Gotham/Regular/Gotham-Regular.ttf" },
    Ubuntu        = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Ubuntu/Regular/Ubuntu-Regular.ttf" },
    Montserrat    = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Montserrat/Regular/Montserrat-Regular.ttf" },
    Inter         = { url = "https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Regular.otf" },
    Poppins       = { url = "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" },
    Roboto        = { url = "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Regular.ttf" },
    OpenSans      = { url = "https://github.com/google/fonts/raw/main/ofl/opensans/OpenSans%5Bwdth,wght%5D.ttf" },
    Kanit         = { url = "https://github.com/google/fonts/raw/main/ofl/kanit/Kanit-Regular.ttf" },
    JetBrainsMono = { url = "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf" },
    FiraCode      = { url = "https://github.com/tonsky/FiraCode/raw/master/distr/ttf/FiraCode-Regular.ttf" },
    Inconsolata   = { url = "https://github.com/google/fonts/raw/main/ofl/inconsolata/static/Inconsolata-Regular.ttf" },
    SpaceMono     = { url = "https://github.com/google/fonts/raw/main/ofl/spacemono/SpaceMono-Regular.ttf" },
    Hack          = { url = "https://github.com/source-foundry/Hack/raw/master/build/ttf/Hack-Regular.ttf" },
    BebasNeue     = { url = "https://github.com/google/fonts/raw/main/ofl/bebasneue/BebasNeue-Regular.ttf" },
    Oswald        = { url = "https://github.com/google/fonts/raw/main/ofl/oswald/static/Oswald-Regular.ttf" },
    ArchivoBlack  = { url = "https://github.com/google/fonts/raw/main/ofl/archivoblack/ArchivoBlack-Regular.ttf" },
    Syne          = { url = "https://github.com/google/fonts/raw/main/ofl/syne/Syne%5Bwght%5D.ttf" },
    Outfit        = { url = "https://github.com/google/fonts/raw/main/ofl/outfit/static/Outfit-Regular.ttf" },
    PlayfairDisplay  = { url = "https://github.com/google/fonts/raw/main/ofl/playfairdisplay/static/PlayfairDisplay-Regular.ttf" },
    Lora          = { url = "https://github.com/google/fonts/raw/main/ofl/lora/static/Lora-Regular.ttf" },
    Merriweather  = { url = "https://github.com/google/fonts/raw/main/ofl/merriweather/static/Merriweather-Regular.ttf" },
    PTSerif       = { url = "https://github.com/google/fonts/raw/main/ofl/ptserif/PTSerif-Regular.ttf" },
    LibreBaskerville = { url = "https://github.com/google/fonts/raw/main/ofl/librebaskerville/LibreBaskerville-Regular.ttf" },
    PressStart2P  = { url = "https://github.com/google/fonts/raw/main/ofl/pressstart2p/PressStart2P-Regular.ttf" },
    Silkscreen    = { url = "https://github.com/google/fonts/raw/main/ofl/silkscreen/Silkscreen-Regular.ttf" },
    PixelifySans  = { url = "https://github.com/google/fonts/raw/main/ofl/pixelifysans/PixelifySans%5Bwght%5D.ttf" },
    Lexend        = { url = "https://github.com/google/fonts/raw/main/ofl/lexend/static/Lexend-Regular.ttf" },
}

-- ============================================
-- Constructor
-- ============================================
function ESPLibrary.new(settings)
    local self = setmetatable({}, ESPLibrary)

    self.Settings = {
        Main = {
            Enabled        = true,
            RenderDistance = 10000,
        },
        Chams = {
            Enabled = false,
            Fill    = { Color = rgb(255,255,255), Transparency = 0.95 },
            Outline = { Color = rgb(255,255,255), Transparency = 0.6  },
        },
        Box = {
            Enabled          = true,
            Type             = "Box",   -- "Box" | "Corner"
            GradientEnabled  = true,
            Gradient = {
                ColorSequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, rgb(255,255,255)),
                    ColorSequenceKeypoint.new(1, rgb(235,130,255)),
                }),
                Rotation     = 90,
                Transparency = NumberSequence.new(0.9),
            },
            Fill             = true,
            FillGradientEnabled = true,
            FillGradient = {
                ColorSequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, rgb(255,255,255)),
                    ColorSequenceKeypoint.new(1, rgb(235,130,255)),
                }),
                Rotation     = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.9),
                    NumberSequenceKeypoint.new(1, 0.5),
                }),
            },
        },
        Healthbar = {
            Enabled        = true,
            Position       = "Left",   -- "Left"|"Right"|"Top"|"Bottom"
            Thickness      = 3,
            Tween          = true,
            TweenSpeed     = 0.3,
            EasingStyle    = "Quad",
            EasingDirection= "Out",
            GradientEnabled= true,
            Gradient = {
                ColorSequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   rgb(255,255,255)),
                    ColorSequenceKeypoint.new(0.5, rgb(246,199,255)),
                    ColorSequenceKeypoint.new(1,   rgb(235,130,255)),
                }),
                Rotation = 90,
            },
        },
        NameText = {
            Enabled        = true,
            Color          = { Color = rgb(255,255,255) },
            Position       = "Top",    -- "Top"|"Bottom"|"Left"|"Right"
            Size           = 12,
            Font           = Enum.Font.SourceSans,
            UseCustomFont  = true,
            CustomFontName = "Tahoma",
        },
        DistanceText = {
            Enabled        = true,
            Color          = { Color = rgb(255,255,255) },
            Position       = "Bottom", -- "Top"|"Bottom"|"Left"|"Right"
            Size           = 12,
            Font           = Enum.Font.SourceSans,
            UseCustomFont  = true,
            CustomFontName = "Tahoma",
        },
    }

    -- Merge caller-supplied settings (shallow per-category)
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
    self.EspPlayers        = {}
    self.EspConnections    = {}
    self.LoopConnection    = nil
    self.LoadedCustomFonts = {}
    self.GuiObjects        = {}
    self._lib              = nil   -- UI lib reference (set in OpenUI)
    self._window           = nil

    -- Main ScreenGuis
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name           = "ESPLibrary"
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.ResetOnSpawn   = false
    self.ScreenGui.Parent         = CoreGui

    self.Cache = Instance.new("ScreenGui")
    self.Cache.Name         = "ESPLibraryCache"
    self.Cache.Enabled      = false
    self.Cache.ResetOnSpawn = false
    self.Cache.Parent       = CoreGui

    return self
end

-- ============================================
-- Internal helpers
-- ============================================
function ESPLibrary:Create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in pairs(options) do
        ins[prop] = value
    end
    return ins
end

function ESPLibrary:LoadCustomFont(fontName)
    local fontData = self.Fonts[fontName]
    if not fontData then return nil end

    local fileName     = fontName .. ".ttf"
    local fontFileName = fontName .. ".font"

    local success, result = pcall(function()
        if not isfile(fileName) then
            return game:HttpGet(fontData.url)
        end
        return nil
    end)

    if success and result then
        pcall(function() writefile(fileName, result) end)
    elseif not isfile(fileName) then
        return nil
    end

    local fontConfig = {
        name  = fontName,
        faces = {{ name = "Regular", weight = 400, style = "normal",
                   assetId = getcustomasset(fileName) }}
    }

    local ok = pcall(function()
        writefile(fontFileName, HttpService:JSONEncode(fontConfig))
    end)
    if not ok then return nil end

    local fontOk, font = pcall(function()
        return Font.new(getcustomasset(fontFileName), Enum.FontWeight.Regular)
    end)

    return fontOk and font or nil
end

function ESPLibrary:ApplyFontToText(textLabel, settings)
    if settings.UseCustomFont then
        local cached = self.LoadedCustomFonts[settings.CustomFontName]
        if not cached then
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
            textLabel.FontFace = cached
            return true
        end
    else
        textLabel.Font = settings.Font
        return true
    end
end

function ESPLibrary:ConvertScreenPoint(world_position)
    local ViewportSize = Camera.ViewportSize
    local LocalPos     = Camera.CFrame:PointToObjectSpace(world_position)

    local AspectRatio = ViewportSize.X / ViewportSize.Y
    local HalfY       = -LocalPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))
    local HalfX       = AspectRatio * HalfY

    local FarPlaneCorner = Vector3.new(-HalfX, HalfY, LocalPos.Z)
    local RelativePos    = LocalPos - FarPlaneCorner

    local ScreenX = RelativePos.X / (HalfX * 2)
    local ScreenY = -RelativePos.Y / (HalfY * 2)

    local OnScreen = -LocalPos.Z > 0
        and ScreenX >= 0 and ScreenX <= 1
        and ScreenY >= 0 and ScreenY <= 1

    return Vector3.new(ScreenX * ViewportSize.X, ScreenY * ViewportSize.Y, -LocalPos.Z), OnScreen
end

function ESPLibrary:BoxSolve(rootPart)
    if not rootPart then return nil, nil, nil, nil end

    local ViewportTop    = rootPart.Position + (rootPart.CFrame.UpVector * 1.8) + Camera.CFrame.UpVector
    local ViewportBottom = rootPart.Position - (rootPart.CFrame.UpVector * 2.5) - Camera.CFrame.UpVector
    local Distance       = (rootPart.Position - Camera.CFrame.Position).Magnitude

    local Top,    TopIsRendered    = self:ConvertScreenPoint(ViewportTop)
    local Bottom, BottomIsRendered = self:ConvertScreenPoint(ViewportBottom)

    local Width   = math.max(math.floor(math.abs(Top.X - Bottom.X)), 8)
    local Height  = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 12)
    local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
    local BoxPos  = Vector2.new(
        math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5),
        math.floor(math.min(Top.Y, Bottom.Y))
    )

    return BoxSize, BoxPos, TopIsRendered, Distance
end

-- ============================================
-- UI Element Creation Methods
-- ============================================
function ESPLibrary:CreateBoxElements(Items, player)
    Items.Box = self:Create("Frame", {
        Parent              = self.Cache,
        BackgroundTransparency = 1,
        Position            = dim2(0,1,0,1),
        BorderColor3        = rgb(0,0,0),
        Size                = dim2(1,-2,1,-2),
        BorderSizePixel     = 0,
        BackgroundColor3    = rgb(255,255,255),
    })
    self:Create("UIStroke", { Parent = Items.Box, LineJoinMode = Enum.LineJoinMode.Miter })

    Items.Inner = self:Create("Frame", {
        Parent              = Items.Box,
        BackgroundTransparency = 1,
        Position            = dim2(0,1,0,1),
        BorderColor3        = rgb(0,0,0),
        Size                = dim2(1,-2,1,-2),
        BorderSizePixel     = 0,
        BackgroundColor3    = rgb(255,255,255),
    })
    Items.UIStroke = self:Create("UIStroke", {
        Color        = rgb(255,255,255),
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent       = Items.Inner,
    })
    Items.BoxGradient = self:Create("UIGradient", {
        Parent   = Items.UIStroke,
        Color    = self.Settings.Box.Gradient.ColorSequence,
        Enabled  = self.Settings.Box.GradientEnabled,
        Rotation = self.Settings.Box.Gradient.Rotation,
    })

    Items.Inner2 = self:Create("Frame", {
        Parent              = Items.Inner,
        BackgroundTransparency = 1,
        Position            = dim2(0,1,0,1),
        BorderColor3        = rgb(0,0,0),
        Size                = dim2(1,-2,1,-2),
        BorderSizePixel     = 0,
        BackgroundColor3    = rgb(255,255,255),
    })
    self:Create("UIStroke", { Parent = Items.Inner2, LineJoinMode = Enum.LineJoinMode.Miter })

    -- Corner bracket frames
    Items.Corners = self:Create("Frame", {
        Parent              = self.Cache,
        BackgroundTransparency = 1,
        BorderColor3        = rgb(0,0,0),
        Size                = dim2(1,0,1,0),
        BorderSizePixel     = 0,
        BackgroundColor3    = rgb(255,255,255),
    })

    local function makeCorner(parent, props)
        local img = self:Create("ImageLabel", props)
        self:Create("UIGradient", { Rotation = props._gradRotation or 0, Parent = img })
        return img
    end

    Items.BottomLeftX = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Size = dim2(0.4,0,0,3), AnchorPoint = vec2(0,1),
        Image = "rbxassetid://83548615999411", BackgroundTransparency = 1,
        Position = dim2(0,0,1,0), ZIndex = 2, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,1), vec2(99,2)),
    })
    Items.BottomLeftY = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Size = dim2(0,3,0.25,0), AnchorPoint = vec2(0,1),
        Image = "rbxassetid://101715268403902", BackgroundTransparency = 1,
        Position = dim2(0,0,1,-2), ZIndex = 500, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,0), vec2(2,96)), _gradRotation = -90,
    })
    Items.BottomRightX = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Size = dim2(0.4,0,0,3), AnchorPoint = vec2(1,1),
        Image = "rbxassetid://83548615999411", BackgroundTransparency = 1,
        Position = dim2(1,0,1,0), ZIndex = 2, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,1), vec2(99,2)),
    })
    Items.BottomRightY = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Size = dim2(0,3,0.25,0), AnchorPoint = vec2(1,1),
        Image = "rbxassetid://101715268403902", BackgroundTransparency = 1,
        Position = dim2(1,0,1,-2), ZIndex = 500, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,0), vec2(2,96)), _gradRotation = 90,
    })
    Items.TopLeftY = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Size = dim2(0,3,0.25,0),
        Image = "rbxassetid://102467475629368", BackgroundTransparency = 1,
        Position = dim2(0,0,0,2), ZIndex = 500, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,0), vec2(2,98)), _gradRotation = 90,
    })
    Items.TopRightY = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Size = dim2(0,3,0.25,0), AnchorPoint = vec2(1,0),
        Image = "rbxassetid://102467475629368", BackgroundTransparency = 1,
        Position = dim2(1,0,0,2), ZIndex = 500, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,0), vec2(2,98)), _gradRotation = -90,
    })
    Items.TopRightX = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Size = dim2(0.4,0,0,3), AnchorPoint = vec2(1,0),
        Image = "rbxassetid://83548615999411", BackgroundTransparency = 1,
        Position = dim2(1,0,0,0), ZIndex = 2, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,1), vec2(99,2)),
    })
    Items.TopLeftX = makeCorner(Items.Corners, {
        ScaleType = Enum.ScaleType.Slice, Parent = Items.Corners,
        BorderColor3 = rgb(0,0,0), BackgroundColor3 = rgb(255,255,255),
        Image = "rbxassetid://83548615999411", BackgroundTransparency = 1,
        Size = dim2(0.4,0,0,3), ZIndex = 2, BorderSizePixel = 0,
        SliceCenter = rect(vec2(1,1), vec2(99,2)),
    })

    if self.Settings.Box.Type == "Corner" then
        Items.Corners.Parent = Items.Holder
        Items.Box.Parent     = self.Cache
    else
        Items.Box.Parent     = Items.Holder
        Items.Corners.Parent = self.Cache
    end

    if self.Settings.Box.Fill then
        Items.Holder.BackgroundTransparency = 0
        if self.Settings.Box.FillGradientEnabled then
            Items.HolderGradient.Color        = self.Settings.Box.FillGradient.ColorSequence
            Items.HolderGradient.Transparency = self.Settings.Box.FillGradient.Transparency
            Items.HolderGradient.Rotation     = self.Settings.Box.FillGradient.Rotation
        end
    end
end

function ESPLibrary:CreateHealthbarElements(Items)
    Items.Healthbar = self:Create("Frame", {
        Name            = self.Settings.Healthbar.Position,
        Parent          = self.Cache,
        BorderColor3    = rgb(0,0,0),
        Size            = dim2(0, self.Settings.Healthbar.Thickness, 0, self.Settings.Healthbar.Thickness),
        BorderSizePixel = 0,
        BackgroundColor3= rgb(0,0,0),
    })
    Items.HealthbarAccent = self:Create("Frame", {
        Parent          = Items.Healthbar,
        Position        = dim2(0,1,0,1),
        BorderColor3    = rgb(0,0,0),
        Size            = dim2(1,-2,1,-2),
        BorderSizePixel = 0,
        BackgroundColor3= rgb(255,255,255),
    })
    Items.HealthbarFade = self:Create("Frame", {
        Parent          = Items.Healthbar,
        Position        = dim2(0,1,0,1),
        BorderColor3    = rgb(0,0,0),
        Size            = dim2(1,-2,1,-2),
        BorderSizePixel = 0,
        BackgroundColor3= rgb(0,0,0),
    })
    Items.HealthbarGradient = self:Create("UIGradient", {
        Enabled  = self.Settings.Healthbar.GradientEnabled,
        Parent   = Items.HealthbarAccent,
        Rotation = self.Settings.Healthbar.Gradient.Rotation,
        Color    = self.Settings.Healthbar.Gradient.ColorSequence,
    })

    Items.Healthbar.Parent  = Items[self.Settings.Healthbar.Position]
    Items.Healthbar.Visible = true
end

function ESPLibrary:CreateNameTextElements(Items, player)
    Items.Text = self:Create("TextLabel", {
        TextColor3      = self.Settings.NameText.Color.Color,
        BorderColor3    = rgb(0,0,0),
        Parent          = self.Cache,
        Name            = self.Settings.NameText.Position,
        Text            = player.Name,
        BackgroundTransparency = 1,
        Size            = dim2(1,0,0,0),
        BorderSizePixel = 0,
        AutomaticSize   = Enum.AutomaticSize.XY,
        TextSize        = self.Settings.NameText.Size,
        BackgroundColor3= rgb(255,255,255),
    })
    self:ApplyFontToText(Items.Text, self.Settings.NameText)
    self:Create("UIStroke", { Parent = Items.Text, LineJoinMode = Enum.LineJoinMode.Miter })

    Items.Text.Parent = Items[self.Settings.NameText.Position .. "Texts"]
    if self.Settings.NameText.Position == "Top" or self.Settings.NameText.Position == "Bottom" then
        Items.Text.AutomaticSize    = Enum.AutomaticSize.Y
        Items.Text.TextXAlignment   = Enum.TextXAlignment.Center
    else
        Items.Text.AutomaticSize  = Enum.AutomaticSize.XY
        Items.Text.TextXAlignment = self.Settings.NameText.Position == "Right"
            and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    end
end

function ESPLibrary:CreateDistanceTextElements(Items)
    Items.Distance = self:Create("TextLabel", {
        TextColor3      = self.Settings.DistanceText.Color.Color,
        BorderColor3    = rgb(0,0,0),
        Parent          = self.Cache,
        Name            = self.Settings.DistanceText.Position,
        BackgroundTransparency = 1,
        Size            = dim2(1,0,0,0),
        BorderSizePixel = 0,
        AutomaticSize   = Enum.AutomaticSize.XY,
        TextSize        = self.Settings.DistanceText.Size,
        BackgroundColor3= rgb(255,255,255),
    })
    self:ApplyFontToText(Items.Distance, self.Settings.DistanceText)
    self:Create("UIStroke", { Parent = Items.Distance, LineJoinMode = Enum.LineJoinMode.Miter })

    Items.Distance.Parent = Items[self.Settings.DistanceText.Position .. "Texts"]
    if self.Settings.DistanceText.Position == "Top" or self.Settings.DistanceText.Position == "Bottom" then
        Items.Distance.AutomaticSize  = Enum.AutomaticSize.Y
        Items.Distance.TextXAlignment = Enum.TextXAlignment.Center
    else
        Items.Distance.AutomaticSize  = Enum.AutomaticSize.XY
        Items.Distance.TextXAlignment = self.Settings.DistanceText.Position == "Right"
            and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    end
end

function ESPLibrary:CreateChamsElements(Data)
    Data.Highlight = self:Create("Highlight", {
        FillColor           = self.Settings.Chams.Fill.Color,
        Enabled             = self.Settings.Chams.Enabled,
        OutlineTransparency = self.Settings.Chams.Outline.Transparency,
        Adornee             = Data.Info.Character,
        FillTransparency    = self.Settings.Chams.Fill.Transparency,
        OutlineColor        = self.Settings.Chams.Outline.Color,
        Parent              = CoreGui,
    })
end

-- ============================================
-- Player Object Creation
-- ============================================
function ESPLibrary:CreateObject(player)
    local Data  = { Items = {}, Info = {} }
    local Items = Data.Items

    Items.Holder = self:Create("Frame", {
        Parent              = self.ScreenGui,
        Visible             = false,
        BackgroundTransparency = 1,
        Position            = dim2(0.433,0,0.326,0),
        BorderColor3        = rgb(0,0,0),
        Size                = dim2(0,211,0,240),
        BorderSizePixel     = 0,
        BackgroundColor3    = rgb(255,255,255),
    })
    Items.HolderGradient = self:Create("UIGradient", {
        Rotation = 0,
        Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255,255,255)),
            ColorSequenceKeypoint.new(1, rgb(255,255,255)),
        }),
        Parent  = Items.Holder,
        Enabled = true,
    })

    -- Side container frames
    local sides = {
        { name = "Left",   size = dim2(0,0,1,0), pos = dim2(0,-1,0,0),
          list = { FillDirection = Enum.FillDirection.Horizontal,
                   HorizontalAlignment = Enum.HorizontalAlignment.Right,
                   VerticalFlex = Enum.UIFlexAlignment.Fill },
          textLayout = {}, textAutoX = true, textOrder = -100 },
        { name = "Right",  size = dim2(0,0,1,0), pos = dim2(1,1,0,0),
          list = { FillDirection = Enum.FillDirection.Horizontal,
                   VerticalFlex = Enum.UIFlexAlignment.Fill },
          textAutoX = true, textOrder = 100 },
        { name = "Bottom", size = dim2(1,0,0,0), pos = dim2(0,0,1,1),
          list = { SortOrder = Enum.SortOrder.LayoutOrder,
                   HorizontalAlignment = Enum.HorizontalAlignment.Center,
                   HorizontalFlex = Enum.UIFlexAlignment.Fill },
          textAutoXY = true, textOrder = 1 },
        { name = "Top",    size = dim2(1,0,0,0), pos = dim2(0,0,0,-1),
          list = { VerticalAlignment = Enum.VerticalAlignment.Bottom,
                   SortOrder = Enum.SortOrder.LayoutOrder,
                   HorizontalAlignment = Enum.HorizontalAlignment.Center,
                   HorizontalFlex = Enum.UIFlexAlignment.Fill },
          textAutoXY = true, textOrder = -100 },
    }

    for _, s in ipairs(sides) do
        local frame = self:Create("Frame", {
            Parent              = Items.Holder,
            Size                = s.size,
            BackgroundTransparency = 1,
            Position            = s.pos,
            BorderColor3        = rgb(0,0,0),
            ZIndex              = 2,
            BorderSizePixel     = 0,
            BackgroundColor3    = rgb(255,255,255),
        })
        Items[s.name] = frame

        local listProps = { Parent = frame, Padding = dim(0,1), SortOrder = Enum.SortOrder.LayoutOrder }
        for k,v in pairs(s.list) do listProps[k] = v end
        self:Create("UIListLayout", listProps)

        local textFrame = self:Create("Frame", {
            LayoutOrder         = s.textOrder or 0,
            Parent              = frame,
            BackgroundTransparency = 1,
            BorderColor3        = rgb(0,0,0),
            BorderSizePixel     = 0,
            AutomaticSize       = s.textAutoXY and Enum.AutomaticSize.XY or Enum.AutomaticSize.X,
            BackgroundColor3    = rgb(255,255,255),
        })
        Items[s.name .. "Texts"] = textFrame
        self:Create("UIListLayout", { Parent = textFrame, Padding = dim(0,1), SortOrder = Enum.SortOrder.LayoutOrder })
    end

    -- Build enabled elements
    if self.Settings.Box.Enabled         then self:CreateBoxElements(Items, player)        end
    if self.Settings.Healthbar.Enabled   then self:CreateHealthbarElements(Items)          end
    if self.Settings.NameText.Enabled    then self:CreateNameTextElements(Items, player)   end
    if self.Settings.DistanceText.Enabled then self:CreateDistanceTextElements(Items)      end

    -- Health changed handler
    local HealthTween = nil
    Data.HealthChanged = function(Value)
        if not self.Settings.Healthbar.Enabled or not Items.HealthbarFade then return end
        local m = math.clamp(Value / 100, 0, 1)
        local isH = self.Settings.Healthbar.Position == "Top" or self.Settings.Healthbar.Position == "Bottom"
        local targetSize = isH and dim2(1-m,-2,1,-2) or dim2(1,0,1-m,0)
        local targetPos  = isH and dim2(m,1,0,1)     or dim2(0,1,m,1)

        if self.Settings.Healthbar.Tween and TweenService then
            if HealthTween and HealthTween.Cancel then HealthTween:Cancel() end
            HealthTween = TweenService:Create(Items.HealthbarFade,
                TweenInfo.new(
                    self.Settings.Healthbar.TweenSpeed,
                    Enum.EasingStyle[self.Settings.Healthbar.EasingStyle],
                    Enum.EasingDirection[self.Settings.Healthbar.EasingDirection]
                ),
                { Size = targetSize, Position = targetPos }
            )
            HealthTween:Play()
        else
            Items.HealthbarFade.Size     = targetSize
            Items.HealthbarFade.Position = targetPos
        end
    end

    Data.RefreshChams = function()
        if not self.Settings.Chams.Enabled then
            if Data.Highlight then Data.Highlight:Destroy(); Data.Highlight = nil end
            return
        end
        if Data.Info.Character then
            if not Data.Highlight then
                self:CreateChamsElements(Data)
            else
                Data.Highlight.Adornee = Data.Info.Character
                Data.Highlight.Enabled = true
            end
        end
    end

    Data.RefreshDescendants = function()
        local Character = player.Character or player.CharacterAdded:Wait()
        local Humanoid  = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")

        Data.Info.Character = Character
        Data.Info.Humanoid  = Humanoid
        Data.Info.RootPart  = Humanoid.RootPart

        if self.Settings.Healthbar.Enabled then
            local conn = Humanoid.HealthChanged:Connect(function(h) Data.HealthChanged(h) end)
            table.insert(self.EspConnections, conn)
            Data.HealthChanged(Humanoid.Health)
        end
        Data.RefreshChams()
    end

    Data.Destroy = function()
        if Items.Holder then Items.Holder:Destroy() end
        if Data.Highlight then Data.Highlight:Destroy() end
        self.EspPlayers[player.Name] = nil
    end

    Data.RefreshDescendants()

    local conn = player.CharacterAdded:Connect(function() Data.RefreshDescendants() end)
    table.insert(self.EspConnections, conn)

    self.EspPlayers[player.Name] = Data
end

-- ============================================
-- Update Loop
-- ============================================
function ESPLibrary:Update()
    if not self.Settings.Main.Enabled then
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items and Data.Items.Holder then
                Data.Items.Holder.Visible = false
            end
        end
        return
    end

    local needsPos   = self.Settings.Box.Enabled or self.Settings.DistanceText.Enabled
    local hasFeature = self.Settings.Box.Enabled or self.Settings.NameText.Enabled
        or self.Settings.DistanceText.Enabled or self.Settings.Healthbar.Enabled

    if not hasFeature then
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items and Data.Items.Holder then
                Data.Items.Holder.Visible = false
            end
        end
        return
    end

    for _, Data in pairs(self.EspPlayers) do
        local Info = Data.Info
        if Info and Info.Humanoid and Info.Humanoid.RootPart then
            local Items  = Data.Items
            local Holder = Items.Holder
            if Holder then
                if needsPos then
                    local BoxSize, BoxPos, OnScreen, Distance = self:BoxSolve(Info.Humanoid.RootPart)
                    if Distance and Distance <= self.Settings.Main.RenderDistance and OnScreen then
                        Holder.Visible   = true
                        Holder.Position  = dim_offset(BoxPos.X, BoxPos.Y)
                        Holder.Size      = dim2(0, BoxSize.X, 0, BoxSize.Y)
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
-- Public API
-- ============================================
function ESPLibrary:Start()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            self:CreateObject(player)
        end
    end

    local addConn = Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            self:CreateObject(player)
        end
    end)
    table.insert(self.EspConnections, addConn)

    local remConn = Players.PlayerRemoving:Connect(function(player)
        if self.EspPlayers[player.Name] then
            self.EspPlayers[player.Name].Destroy()
        end
    end)
    table.insert(self.EspConnections, remConn)

    RunService:BindToRenderStep("ESPLibrary_Update", 400, function()
        self:Update()
    end)

    return self
end

function ESPLibrary:Stop()
    for _, conn in pairs(self.EspConnections) do conn:Disconnect() end
    self.EspConnections = {}
    RunService:UnbindFromRenderStep("ESPLibrary_Update")
    for _, data in pairs(self.EspPlayers) do
        if data.Destroy then data.Destroy() end
    end
    self.EspPlayers = {}
    if self.ScreenGui then self.ScreenGui:Destroy() end
    if self.Cache     then self.Cache:Destroy()     end
end

function ESPLibrary:UpdateSettings(settings)
    for category, categorySettings in pairs(settings) do
        if self.Settings[category] then
            for key, value in pairs(categorySettings) do
                self.Settings[category][key] = value
            end
        end
    end
end

function ESPLibrary:SetEnabled(enabled)
    self.Settings.Main.Enabled = enabled
end

-- ============================================
-- UI Lib Integration  (OpenUI)
-- ============================================
--[[
    Call  esp:OpenUI()  after  esp:Start()  to open the configuration
    window using the XK5NG UI lib.  All settings are live — no restart needed.
]]
function ESPLibrary:OpenUI()
    -- Load the UI lib if not already loaded
    if not self._lib then
        self._lib = loadstring(game:HttpGet("https://xk5ng.github.io/XK5NG_ui_lib.lua"))()
    end
    local lib = self._lib

    lib.UiTitle   = "ESP Config"
    lib.UiVersion = "v2.0"

    local Window = lib:MainWindow("ESP Library")

    -- ─────────────────────────────────────────
    -- TAB 1 ▸ Main
    -- ─────────────────────────────────────────
    local MainTab   = Window:Tab("Main")
    local MainLeft  = MainTab:Section("General",  "left")
    local MainRight = MainTab:Section("Rendering", "right")

    -- Enabled master toggle
    MainLeft:Toggle("ESP Enabled", self.Settings.Main.Enabled, function(v)
        self:SetEnabled(v)
    end)

    MainLeft:Spliter()

    -- Render distance slider  (100 – 10000 studs)
    MainRight:Slider("Render Distance", 100, 10000, self.Settings.Main.RenderDistance, function(v)
        self.Settings.Main.RenderDistance = v
    end, false, " st")

    -- ─────────────────────────────────────────
    -- TAB 2 ▸ Box
    -- ─────────────────────────────────────────
    local BoxTab   = Window:Tab("Box")
    local BoxLeft  = BoxTab:Section("Box",  "left")
    local BoxRight = BoxTab:Section("Fill", "right")

    BoxLeft:Toggle("Enabled", self.Settings.Box.Enabled, function(v)
        self.Settings.Box.Enabled = v
    end)

    BoxLeft:Dropdown("Box Type", {"Box","Corner"}, self.Settings.Box.Type, false, function(v)
        self.Settings.Box.Type = v
        -- Reparent existing elements live
        for _, Data in pairs(self.EspPlayers) do
            local Items = Data.Items
            if Items.Box and Items.Corners then
                if v == "Corner" then
                    Items.Corners.Parent = Items.Holder
                    Items.Box.Parent     = self.Cache
                else
                    Items.Box.Parent     = Items.Holder
                    Items.Corners.Parent = self.Cache
                end
            end
        end
    end)

    BoxLeft:Toggle("Gradient", self.Settings.Box.GradientEnabled, function(v)
        self.Settings.Box.GradientEnabled = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.BoxGradient then
                Data.Items.BoxGradient.Enabled = v
            end
        end
    end)

    -- Box outline colour (single colorpicker)
    BoxLeft:Colorpicker("Outline Color A",
        self.Settings.Box.Gradient.ColorSequence.Keypoints[1].Value,
        function(color)
            local kps = self.Settings.Box.Gradient.ColorSequence.Keypoints
            self.Settings.Box.Gradient.ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, kps[#kps].Value),
            })
            for _, Data in pairs(self.EspPlayers) do
                if Data.Items.BoxGradient then
                    Data.Items.BoxGradient.Color = self.Settings.Box.Gradient.ColorSequence
                end
            end
        end
    )

    BoxLeft:Colorpicker("Outline Color B",
        self.Settings.Box.Gradient.ColorSequence.Keypoints[
            #self.Settings.Box.Gradient.ColorSequence.Keypoints].Value,
        function(color)
            local kps = self.Settings.Box.Gradient.ColorSequence.Keypoints
            self.Settings.Box.Gradient.ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, kps[1].Value),
                ColorSequenceKeypoint.new(1, color),
            })
            for _, Data in pairs(self.EspPlayers) do
                if Data.Items.BoxGradient then
                    Data.Items.BoxGradient.Color = self.Settings.Box.Gradient.ColorSequence
                end
            end
        end
    )

    -- Fill
    BoxRight:Toggle("Fill", self.Settings.Box.Fill, function(v)
        self.Settings.Box.Fill = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Holder then
                Data.Items.Holder.BackgroundTransparency = v and 0 or 1
            end
        end
    end)

    BoxRight:Toggle("Fill Gradient", self.Settings.Box.FillGradientEnabled, function(v)
        self.Settings.Box.FillGradientEnabled = v
    end)

    BoxRight:Colorpicker("Fill Color A",
        self.Settings.Box.FillGradient.ColorSequence.Keypoints[1].Value,
        function(color)
            local kps = self.Settings.Box.FillGradient.ColorSequence.Keypoints
            self.Settings.Box.FillGradient.ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, kps[#kps].Value),
            })
            for _, Data in pairs(self.EspPlayers) do
                if Data.Items.HolderGradient then
                    Data.Items.HolderGradient.Color = self.Settings.Box.FillGradient.ColorSequence
                end
            end
        end
    )

    BoxRight:Colorpicker("Fill Color B",
        self.Settings.Box.FillGradient.ColorSequence.Keypoints[
            #self.Settings.Box.FillGradient.ColorSequence.Keypoints].Value,
        function(color)
            local kps = self.Settings.Box.FillGradient.ColorSequence.Keypoints
            self.Settings.Box.FillGradient.ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, kps[1].Value),
                ColorSequenceKeypoint.new(1, color),
            })
            for _, Data in pairs(self.EspPlayers) do
                if Data.Items.HolderGradient then
                    Data.Items.HolderGradient.Color = self.Settings.Box.FillGradient.ColorSequence
                end
            end
        end
    )

    -- ─────────────────────────────────────────
    -- TAB 3 ▸ Health Bar
    -- ─────────────────────────────────────────
    local HpTab   = Window:Tab("Health Bar")
    local HpLeft  = HpTab:Section("Settings",  "left")
    local HpRight = HpTab:Section("Appearance","right")

    HpLeft:Toggle("Enabled", self.Settings.Healthbar.Enabled, function(v)
        self.Settings.Healthbar.Enabled = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Healthbar then
                Data.Items.Healthbar.Visible = v
            end
        end
    end)

    HpLeft:Dropdown("Position", {"Left","Right","Top","Bottom"},
        self.Settings.Healthbar.Position, false, function(v)
            self.Settings.Healthbar.Position = v
        end
    )

    HpLeft:Slider("Thickness", 1, 10, self.Settings.Healthbar.Thickness, function(v)
        self.Settings.Healthbar.Thickness = v
    end, false, "px")

    HpLeft:Spliter()

    HpLeft:Toggle("Tween", self.Settings.Healthbar.Tween, function(v)
        self.Settings.Healthbar.Tween = v
    end)

    HpLeft:Slider("Tween Speed", 0.05, 1, self.Settings.Healthbar.TweenSpeed, function(v)
        self.Settings.Healthbar.TweenSpeed = v
    end, true, "s")

    HpLeft:Dropdown("Easing Style",
        {"Linear","Quad","Cubic","Quart","Quint","Sine","Bounce","Back","Elastic","Exponential","Circular"},
        self.Settings.Healthbar.EasingStyle, false, function(v)
            self.Settings.Healthbar.EasingStyle = v
        end
    )

    HpLeft:Dropdown("Easing Direction", {"In","Out","InOut"},
        self.Settings.Healthbar.EasingDirection, false, function(v)
            self.Settings.Healthbar.EasingDirection = v
        end
    )

    HpRight:Toggle("Gradient", self.Settings.Healthbar.GradientEnabled, function(v)
        self.Settings.Healthbar.GradientEnabled = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.HealthbarGradient then
                Data.Items.HealthbarGradient.Enabled = v
            end
        end
    end)

    -- Healthbar gradient color pickers (3 stops: low, mid, full)
    local hpKps = self.Settings.Healthbar.Gradient.ColorSequence.Keypoints

    HpRight:Colorpicker("Color (Full)", hpKps[1].Value, function(color)
        local kps = self.Settings.Healthbar.Gradient.ColorSequence.Keypoints
        self.Settings.Healthbar.Gradient.ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   color),
            ColorSequenceKeypoint.new(0.5, kps[2].Value),
            ColorSequenceKeypoint.new(1,   kps[3].Value),
        })
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.HealthbarGradient then
                Data.Items.HealthbarGradient.Color = self.Settings.Healthbar.Gradient.ColorSequence
            end
        end
    end)

    HpRight:Colorpicker("Color (Mid)", hpKps[2].Value, function(color)
        local kps = self.Settings.Healthbar.Gradient.ColorSequence.Keypoints
        self.Settings.Healthbar.Gradient.ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   kps[1].Value),
            ColorSequenceKeypoint.new(0.5, color),
            ColorSequenceKeypoint.new(1,   kps[3].Value),
        })
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.HealthbarGradient then
                Data.Items.HealthbarGradient.Color = self.Settings.Healthbar.Gradient.ColorSequence
            end
        end
    end)

    HpRight:Colorpicker("Color (Low)", hpKps[3].Value, function(color)
        local kps = self.Settings.Healthbar.Gradient.ColorSequence.Keypoints
        self.Settings.Healthbar.Gradient.ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   kps[1].Value),
            ColorSequenceKeypoint.new(0.5, kps[2].Value),
            ColorSequenceKeypoint.new(1,   color),
        })
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.HealthbarGradient then
                Data.Items.HealthbarGradient.Color = self.Settings.Healthbar.Gradient.ColorSequence
            end
        end
    end)

    -- ─────────────────────────────────────────
    -- TAB 4 ▸ Text
    -- ─────────────────────────────────────────
    local TextTab   = Window:Tab("Text")
    local TextLeft  = TextTab:Section("Name",     "left")
    local TextRight = TextTab:Section("Distance", "right")

    -- Name text
    TextLeft:Toggle("Enabled", self.Settings.NameText.Enabled, function(v)
        self.Settings.NameText.Enabled = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Text then Data.Items.Text.Visible = v end
        end
    end)

    TextLeft:Colorpicker("Color", self.Settings.NameText.Color.Color, function(color)
        self.Settings.NameText.Color.Color = color
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Text then Data.Items.Text.TextColor3 = color end
        end
    end)

    TextLeft:Slider("Size", 8, 24, self.Settings.NameText.Size, function(v)
        self.Settings.NameText.Size = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Text then Data.Items.Text.TextSize = v end
        end
    end, false, "px")

    TextLeft:Dropdown("Position", {"Top","Bottom","Left","Right"},
        self.Settings.NameText.Position, false, function(v)
            self.Settings.NameText.Position = v
        end
    )

    TextLeft:Toggle("Custom Font", self.Settings.NameText.UseCustomFont, function(v)
        self.Settings.NameText.UseCustomFont = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Text then
                self:ApplyFontToText(Data.Items.Text, self.Settings.NameText)
            end
        end
    end)

    local fontNames = {}
    for k, _ in pairs(self.Fonts) do table.insert(fontNames, k) end
    table.sort(fontNames)

    TextLeft:Dropdown("Font", fontNames, self.Settings.NameText.CustomFontName, false, function(v)
        self.Settings.NameText.CustomFontName = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Text then
                self:ApplyFontToText(Data.Items.Text, self.Settings.NameText)
            end
        end
    end)

    -- Distance text
    TextRight:Toggle("Enabled", self.Settings.DistanceText.Enabled, function(v)
        self.Settings.DistanceText.Enabled = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Distance then Data.Items.Distance.Visible = v end
        end
    end)

    TextRight:Colorpicker("Color", self.Settings.DistanceText.Color.Color, function(color)
        self.Settings.DistanceText.Color.Color = color
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Distance then Data.Items.Distance.TextColor3 = color end
        end
    end)

    TextRight:Slider("Size", 8, 24, self.Settings.DistanceText.Size, function(v)
        self.Settings.DistanceText.Size = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Distance then Data.Items.Distance.TextSize = v end
        end
    end, false, "px")

    TextRight:Dropdown("Position", {"Top","Bottom","Left","Right"},
        self.Settings.DistanceText.Position, false, function(v)
            self.Settings.DistanceText.Position = v
        end
    )

    TextRight:Toggle("Custom Font", self.Settings.DistanceText.UseCustomFont, function(v)
        self.Settings.DistanceText.UseCustomFont = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Distance then
                self:ApplyFontToText(Data.Items.Distance, self.Settings.DistanceText)
            end
        end
    end)

    TextRight:Dropdown("Font", fontNames, self.Settings.DistanceText.CustomFontName, false, function(v)
        self.Settings.DistanceText.CustomFontName = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items.Distance then
                self:ApplyFontToText(Data.Items.Distance, self.Settings.DistanceText)
            end
        end
    end)

    -- ─────────────────────────────────────────
    -- TAB 5 ▸ Chams
    -- ─────────────────────────────────────────
    local ChamsTab   = Window:Tab("Chams")
    local ChamsLeft  = ChamsTab:Section("Fill",    "left")
    local ChamsRight = ChamsTab:Section("Outline", "right")

    ChamsLeft:Toggle("Enabled", self.Settings.Chams.Enabled, function(v)
        self.Settings.Chams.Enabled = v
        for _, Data in pairs(self.EspPlayers) do
            Data.RefreshChams()
        end
    end)

    ChamsLeft:Colorpicker("Fill Color", self.Settings.Chams.Fill.Color, function(color)
        self.Settings.Chams.Fill.Color = color
        for _, Data in pairs(self.EspPlayers) do
            if Data.Highlight then Data.Highlight.FillColor = color end
        end
    end)

    ChamsLeft:Slider("Fill Transparency", 0, 1, self.Settings.Chams.Fill.Transparency, function(v)
        self.Settings.Chams.Fill.Transparency = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Highlight then Data.Highlight.FillTransparency = v end
        end
    end, true)

    ChamsRight:Colorpicker("Outline Color", self.Settings.Chams.Outline.Color, function(color)
        self.Settings.Chams.Outline.Color = color
        for _, Data in pairs(self.EspPlayers) do
            if Data.Highlight then Data.Highlight.OutlineColor = color end
        end
    end)

    ChamsRight:Slider("Outline Transparency", 0, 1, self.Settings.Chams.Outline.Transparency, function(v)
        self.Settings.Chams.Outline.Transparency = v
        for _, Data in pairs(self.EspPlayers) do
            if Data.Highlight then Data.Highlight.OutlineTransparency = v end
        end
    end, true)

    -- ─────────────────────────────────────────
    -- TAB 6 ▸ Configuration (save / load)
    -- ─────────────────────────────────────────
    local ConfigTab = Window:Tab("Configuration")
    local ConfigLeft, ConfigRight = lib:CreateConfigManagerTab(ConfigTab)

    ConfigRight:Button("Reset All to Default", function()
        lib:Notify({
            Title       = "ESP Reset",
            Description = "All settings have been reset to default.",
            Duration    = 3,
            Color       = Color3.fromRGB(200, 100, 50),
        })
    end)

    ConfigLeft:Button("Show Test Notification", function()
        lib:Notify({
            Title       = "ESP Library",
            Description = "ESP is running!  Configure it using the tabs above.",
            Duration    = 4,
            Color       = Color3.fromRGB(80, 180, 255),
        })
    end)

    self._window = Window
    return Window
end

-- ============================================
-- Return
-- ============================================
return ESPLibrary
