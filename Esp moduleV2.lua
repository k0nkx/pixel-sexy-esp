--[[
    ESP Library v2.0 - Clean Version
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
local UserInputService = cloneref(game:GetService("UserInputService"))

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
}

function ESPLibrary.new(settings)
    local self = setmetatable({}, ESPLibrary)
    
    -- Default settings
    self.Settings = {
        Main = {
            Enabled = true,
            RenderDistance = 10000,
            ToggleKey = "Insert",
        },
        Chams = {
            Enabled = false,
            Fill = { Color = rgb(255, 255, 255), Transparency = 0.95 },
            Outline = { Color = rgb(255, 255, 255), Transparency = 0.6 },
        },
        Box = {
            Enabled = true,
            Type = "Box",
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
            Thickness = 2,
            Color = rgb(255, 255, 255),
        },
        Healthbar = {
            Enabled = true,
            Position = "Left",
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
            Position = "Top",
            Size = 12,
            Font = Enum.Font.SourceSans,
            UseCustomFont = true,
            CustomFontName = "Tahoma",
            Outline = true,
            OutlineColor = rgb(0, 0, 0),
        },
        DistanceText = {
            Enabled = true,
            Color = { Color = rgb(255, 255, 255) },
            Position = "Bottom",
            Size = 12,
            Font = Enum.Font.SourceSans,
            UseCustomFont = true,
            CustomFontName = "Tahoma",
            Outline = true,
            OutlineColor = rgb(0, 0, 0),
        },
    }
    
    -- Override with user settings
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
    self.ToggleConnection = nil
    
    -- GUI containers
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

-- Helper functions
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
        pcall(function() writefile(fileName, result) end)
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
    
    pcall(function() writefile(fontFileName, HttpService:JSONEncode(fontConfig)) end)
    
    local fontSuccess, font = pcall(function()
        return Font.new(getcustomasset(fontFileName), Enum.FontWeight.Regular)
    end)
    
    return fontSuccess and font or nil
end

function ESPLibrary:ApplyFontToText(textLabel, settings)
    if settings.UseCustomFont then
        if not self.LoadedCustomFonts[settings.CustomFontName] then
            local font = self:LoadCustomFont(settings.CustomFontName)
            if font then
                self.LoadedCustomFonts[settings.CustomFontName] = font
                textLabel.FontFace = font
                return true
            end
        else
            textLabel.FontFace = self.LoadedCustomFonts[settings.CustomFontName]
            return true
        end
    end
    textLabel.Font = settings.Font
    return true
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

-- UI Element Creation Methods
function ESPLibrary:CreateBoxElements(Items)
    Items.Box = self:Create("Frame", {
        Parent = self.Cache,
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
    })
    
    local stroke = self:Create("UIStroke", {
        Parent = Items.Box,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = self.Settings.Box.Thickness,
        Color = self.Settings.Box.Color,
    })
    
    Items.Inner = self:Create("Frame", {
        Parent = Items.Box,
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
    })
    
    Items.UIStroke = self:Create("UIStroke", {
        Color = self.Settings.Box.Color,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = Items.Inner,
        Thickness = math.max(1, self.Settings.Box.Thickness - 1),
    })
    
    Items.BoxGradient = self:Create("UIGradient", {
        Parent = Items.UIStroke,
        Color = self.Settings.Box.Gradient.ColorSequence,
        Enabled = self.Settings.Box.GradientEnabled,
        Rotation = self.Settings.Box.Gradient.Rotation
    })
    
    Items.Inner2 = self:Create("Frame", {
        Parent = Items.Inner,
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
    })
    
    self:Create("UIStroke", {
        Parent = Items.Inner2,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Thickness = math.max(1, self.Settings.Box.Thickness - 2),
        Color = self.Settings.Box.Color,
    })
    
    Items.Corners = self:Create("Frame", {
        Parent = self.Cache,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
    })
    
    -- Corner elements
    Items.BottomLeftX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0.4, 0, 0, 3),
        AnchorPoint = vec2(0, 1),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, 0),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
    Items.BottomLeftY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0, 3, 0.25, 0),
        AnchorPoint = vec2(0, 1),
        Image = "rbxassetid://101715268403902",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, -2),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 96))
    })
    
    Items.BottomRightX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0.4, 0, 0, 3),
        AnchorPoint = vec2(1, 1),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
    Items.BottomRightY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0, 3, 0.25, 0),
        AnchorPoint = vec2(1, 1),
        Image = "rbxassetid://101715268403902",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 1, -2),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 96))
    })
    
    Items.TopLeftY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0, 3, 0.25, 0),
        Image = "rbxassetid://102467475629368",
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, 2),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 98))
    })
    
    Items.TopRightY = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0, 3, 0.25, 0),
        AnchorPoint = vec2(1, 0),
        Image = "rbxassetid://102467475629368",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 0, 2),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 0), vec2(2, 98))
    })
    
    Items.TopRightX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0.4, 0, 0, 3),
        AnchorPoint = vec2(1, 0),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        Position = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
    Items.TopLeftX = self:Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        Size = dim2(0.4, 0, 0, 3),
        Image = "rbxassetid://83548615999411",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(1, 1), vec2(99, 2))
    })
    
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
        Size = dim2(0, self.Settings.Healthbar.Thickness, 0, self.Settings.Healthbar.Thickness),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(0, 0, 0)
    })
    
    Items.HealthbarAccent = self:Create("Frame", {
        Parent = Items.Healthbar,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.HealthbarFade = self:Create("Frame", {
        Parent = Items.Healthbar,
        Position = dim2(0, 1, 0, 1),
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
        Parent = self.Cache,
        Name = self.Settings.NameText.Position,
        Text = player.Name,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = self.Settings.NameText.Size,
    })
    
    self:ApplyFontToText(Items.Text, self.Settings.NameText)
    
    if self.Settings.NameText.Outline then
        self:Create("UIStroke", {
            Parent = Items.Text,
            LineJoinMode = Enum.LineJoinMode.Miter,
            Color = self.Settings.NameText.OutlineColor,
            Thickness = 1,
        })
    end
    
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
        Parent = self.Cache,
        Name = self.Settings.DistanceText.Position,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = self.Settings.DistanceText.Size,
    })
    
    self:ApplyFontToText(Items.Distance, self.Settings.DistanceText)
    
    if self.Settings.DistanceText.Outline then
        self:Create("UIStroke", {
            Parent = Items.Distance,
            LineJoinMode = Enum.LineJoinMode.Miter,
            Color = self.Settings.DistanceText.OutlineColor,
            Thickness = 1,
        })
    end
    
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
    if Data.Highlight then
        Data.Highlight:Destroy()
    end
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

-- Player Object Creation
function ESPLibrary:CreateObject(player)
    local Data = {
        Items = {},
        Info = {}
    }
    
    local Items = Data.Items
    
    Items.Holder = self:Create("Frame", {
        Parent = self.ScreenGui,
        Visible = false,
        BackgroundTransparency = 1,
        Position = dim2(0.433, 0, 0.326, 0),
        Size = dim2(0, 211, 0, 240),
        BorderSizePixel = 0,
    })
    
    Items.HolderGradient = self:Create("UIGradient", {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(255, 255, 255))
        }),
        Parent = Items.Holder,
        Enabled = true
    })
    
    -- Container frames
    Items.Left = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Position = dim2(0, -1, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
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
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
    })
    
    self:Create("UIListLayout", {
        Parent = Items.LeftTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Bottom = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, 1),
        ZIndex = 2,
        BorderSizePixel = 0,
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
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
    })
    
    self:Create("UIListLayout", {
        Parent = Items.BottomTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Top = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, -1),
        ZIndex = 2,
        BorderSizePixel = 0,
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
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
    })
    
    self:Create("UIListLayout", {
        Parent = Items.TopTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Right = self:Create("Frame", {
        Parent = Items.Holder,
        Size = dim2(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Position = dim2(1, 1, 0, 0),
        ZIndex = 2,
        BorderSizePixel = 0,
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
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
    })
    
    self:Create("UIListLayout", {
        Parent = Items.RightTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Create elements
    if self.Settings.Box.Enabled then
        self:CreateBoxElements(Items)
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
    
    local HealthTween = nil
    
    Data.HealthChanged = function(Value)
        if not self.Settings.Healthbar.Enabled or not Items.Healthbar then return end
        
        local Multiplier = math.clamp(Value / 100, 0, 1)
        local isHorizontal = self.Settings.Healthbar.Position == "Top" or self.Settings.Healthbar.Position == "Bottom"
        
        local targetSize, targetPosition
        if isHorizontal then
            targetSize = dim2(1 - Multiplier, -2, 1, -2)
            targetPosition = dim2(Multiplier, 1, 0, 1)
        else
            targetSize = dim2(1, 0, 1 - Multiplier, 0)
            targetPosition = dim2(0, 1, Multiplier, 1)
        end
        
        if self.Settings.Healthbar.Tween and TweenService then
            if HealthTween then HealthTween:Cancel() end
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
            self:CreateChamsElements(Data)
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
        if Items.Holder then Items.Holder:Destroy() end
        if Data.Highlight then Data.Highlight:Destroy() end
        self.EspPlayers[player.Name] = nil
    end
    
    Data.RefreshDescendants()
    
    local conn = player.CharacterAdded:Connect(function()
        Data.RefreshDescendants()
    end)
    table.insert(self.EspConnections, conn)
    
    self.EspPlayers[player.Name] = Data
end

-- Update Loop
function ESPLibrary:Update()
    if not self.Settings.Main.Enabled then
        for _, Data in pairs(self.EspPlayers) do
            if Data.Items and Data.Items.Holder then
                Data.Items.Holder.Visible = false
            end
        end
        return
    end
    
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
            
            if needsPositionCalc then
                local BoxSize, BoxPos, OnScreen, Distance = self:BoxSolve(Data.Info.Humanoid.RootPart)
                
                if Distance and Distance <= self.Settings.Main.RenderDistance and OnScreen then
                    if Holder then
                        Holder.Visible = true
                        Holder.Position = dim_offset(BoxPos.X, BoxPos.Y)
                        Holder.Size = dim2(0, BoxSize.X, 0, BoxSize.Y)
                        
                        if self.Settings.DistanceText.Enabled and Items.Distance then
                            Items.Distance.Text = tostring(math.round(Distance)) .. "m"
                        end
                    end
                else
                    if Holder then
                        Holder.Visible = false
                    end
                end
            elseif Holder then
                Holder.Visible = true
            end
        end
    end
end

-- Public API
function ESPLibrary:Start()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            self:CreateObject(player)
        end
    end
    
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
    
    self.LoopConnection = RunService:BindToRenderStep("ESPLibrary_Update", 400, function()
        self:Update()
    end)
    
    -- Keybind toggle
    self.ToggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[self.Settings.Main.ToggleKey] then
            self.Settings.Main.Enabled = not self.Settings.Main.Enabled
        end
    end)
    
    return self
end

function ESPLibrary:Stop()
    for _, conn in pairs(self.EspConnections) do
        conn:Disconnect()
    end
    self.EspConnections = {}
    
    if self.LoopConnection then
        RunService:UnbindFromRenderStep("ESPLibrary_Update")
        self.LoopConnection = nil
    end
    
    if self.ToggleConnection then
        self.ToggleConnection:Disconnect()
        self.ToggleConnection = nil
    end
    
    for _, data in pairs(self.EspPlayers) do
        if data.Destroy then data.Destroy() end
    end
    self.EspPlayers = {}
    
    if self.ScreenGui then self.ScreenGui:Destroy() end
    if self.Cache then self.Cache:Destroy() end
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

function ESPLibrary:GetSettings()
    return self.Settings
end

-- UI Integration
function ESPLibrary:CreateUI(uiLib, notifyCallback)
    local Window = uiLib:MainWindow("Pixel Sexy ESP")
    local MainTab = Window:Tab("ESP")
    
    -- Left Section
    local LeftSection = MainTab:Section("Main Controls", "left")
    
    local espEnabled = self.Settings.Main.Enabled
    LeftSection:Toggle("ESP Enabled", espEnabled, function(v)
        espEnabled = v
        self.Settings.Main.Enabled = v
        if notifyCallback then
            notifyCallback("ESP", v and "Enabled" or "Disabled", v and 2 or 1)
        end
    end)
    
    LeftSection:Keybind("Toggle Keybind", self.Settings.Main.ToggleKey, true, true, true, function(v)
        if v then
            espEnabled = not espEnabled
            self.Settings.Main.Enabled = espEnabled
            if notifyCallback then
                notifyCallback("ESP", espEnabled and "Enabled" or "Disabled", 1)
            end
        end
    end, true)
    
    LeftSection:Slider("Render Distance", 500, 5000, self.Settings.Main.RenderDistance, function(v)
        self.Settings.Main.RenderDistance = v
    end, false, " studs")
    
    LeftSection:Spliter()
    LeftSection:Label("━━━━━ Box Settings ━━━━━")
    
    local boxEnabled = self.Settings.Box.Enabled
    LeftSection:Toggle("Box ESP", boxEnabled, function(v)
        boxEnabled = v
        self.Settings.Box.Enabled = v
    end)
    
    LeftSection:Dropdown("Box Type", {"Box", "Corner"}, self.Settings.Box.Type, false, function(v)
        self.Settings.Box.Type = v
    end)
    
    LeftSection:Slider("Box Thickness", 1, 5, self.Settings.Box.Thickness, function(v)
        self.Settings.Box.Thickness = v
    end, false, "px")
    
    LeftSection:Colorpicker("Box Color", self.Settings.Box.Color, function(color)
        self.Settings.Box.Color = color
    end)
    
    LeftSection:Toggle("Box Fill", self.Settings.Box.Fill, function(v)
        self.Settings.Box.Fill = v
    end)
    
    LeftSection:Toggle("Gradient Effect", self.Settings.Box.GradientEnabled, function(v)
        self.Settings.Box.GradientEnabled = v
    end)
    
    LeftSection:Spliter()
    LeftSection:Label("━━━━━ Chams Settings ━━━━━")
    
    local chamsEnabled = self.Settings.Chams.Enabled
    LeftSection:Toggle("Chams", chamsEnabled, function(v)
        chamsEnabled = v
        self.Settings.Chams.Enabled = v
    end)
    
    LeftSection:Colorpicker("Fill Color", self.Settings.Chams.Fill.Color, function(color)
        self.Settings.Chams.Fill.Color = color
    end)
    
    LeftSection:Slider("Fill Transparency", 0, 1, self.Settings.Chams.Fill.Transparency, function(v)
        self.Settings.Chams.Fill.Transparency = v
    end, true)
    
    LeftSection:Colorpicker("Outline Color", self.Settings.Chams.Outline.Color, function(color)
        self.Settings.Chams.Outline.Color = color
    end)
    
    LeftSection:Slider("Outline Transparency", 0, 1, self.Settings.Chams.Outline.Transparency, function(v)
        self.Settings.Chams.Outline.Transparency = v
    end, true)
    
    -- Right Section
    local RightSection = MainTab:Section("Visual Settings", "right")
    
    RightSection:Label("━━━━━ Healthbar ━━━━━")
    
    local healthEnabled = self.Settings.Healthbar.Enabled
    RightSection:Toggle("Healthbar", healthEnabled, function(v)
        healthEnabled = v
        self.Settings.Healthbar.Enabled = v
    end)
    
    RightSection:Dropdown("Position", {"Left", "Right", "Top", "Bottom"}, self.Settings.Healthbar.Position, false, function(v)
        self.Settings.Healthbar.Position = v
    end)
    
    RightSection:Slider("Thickness", 2, 10, self.Settings.Healthbar.Thickness, function(v)
        self.Settings.Healthbar.Thickness = v
    end, false, "px")
    
    RightSection:Toggle("Tween Animation", self.Settings.Healthbar.Tween, function(v)
        self.Settings.Healthbar.Tween = v
    end)
    
    RightSection:Toggle("Gradient", self.Settings.Healthbar.GradientEnabled, function(v)
        self.Settings.Healthbar.GradientEnabled = v
    end)
    
    RightSection:Spliter()
    RightSection:Label("━━━━━ Text Settings ━━━━━")
    
    local nameEnabled = self.Settings.NameText.Enabled
    RightSection:Toggle("Name Text", nameEnabled, function(v)
        nameEnabled = v
        self.Settings.NameText.Enabled = v
    end)
    
    RightSection:Slider("Name Size", 10, 24, self.Settings.NameText.Size, function(v)
        self.Settings.NameText.Size = v
    end, false, "px")
    
    RightSection:Colorpicker("Name Color", self.Settings.NameText.Color.Color, function(color)
        self.Settings.NameText.Color.Color = color
    end)
    
    RightSection:Toggle("Name Outline", self.Settings.NameText.Outline, function(v)
        self.Settings.NameText.Outline = v
    end)
    
    RightSection:Spliter()
    
    local distanceEnabled = self.Settings.DistanceText.Enabled
    RightSection:Toggle("Distance Text", distanceEnabled, function(v)
        distanceEnabled = v
        self.Settings.DistanceText.Enabled = v
    end)
    
    RightSection:Slider("Distance Size", 10, 20, self.Settings.DistanceText.Size, function(v)
        self.Settings.DistanceText.Size = v
    end, false, "px")
    
    RightSection:Colorpicker("Distance Color", self.Settings.DistanceText.Color.Color, function(color)
        self.Settings.DistanceText.Color.Color = color
    end)
    
    return self
end

return ESPLibrary
