if getgenv().UnloadESP then
    getgenv().UnloadESP()
    wait(0.1)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserSettings = game:GetService("UserSettings")
local HttpService = game:GetService("HttpService")

local function protectGUI(gui)
    if not gui then return end
    
    local originalParent = gui.Parent
    local originalName = gui.Name
    
    local parentConnection
    parentConnection = gui:GetPropertyChangedSignal("Parent"):Connect(function()
        if gui.Parent ~= originalParent and gui.Parent ~= CoreGui then
            gui.Parent = originalParent
        end
        if gui.Parent == nil then
            gui.Parent = originalParent
        end
    end)
    
    local removeConnection
    removeConnection = gui.AncestryChanged:Connect(function()
        if gui.Parent == nil then
            gui.Parent = originalParent
        end
        if gui:IsDescendantOf(game.Players.LocalPlayer) or gui:IsDescendantOf(workspace) then
            gui.Parent = originalParent
        end
    end)
    
    return {parentConnection, removeConnection}
end

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

local function getSafeUI()
    local success, result = pcall(function()
        return gethui()
    end)
    if success and result then
        return result
    end
    return CoreGui
end

local gethui_safe = getSafeUI()

local Fonts = {
    Roboto = nil,
    Arial = nil,
    Tahoma = nil,
    Gotham = nil,
    Ubuntu = nil,
    Montserrat = nil,
    Custom = nil
}

local CustomFonts = {
    -- Original Fonts
    Tahoma = { url = "https://github.com/k0nkx/UI-Lib-Tuff/raw/refs/heads/main/Windows-XP-Tahoma.ttf" },
    Gotham = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Gotham/Regular/Gotham-Regular.ttf" },
    Ubuntu = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Ubuntu/Regular/Ubuntu-Regular.ttf" },
    Montserrat = { url = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Montserrat/Regular/Montserrat-Regular.ttf" },

    -- Geometric & Modern Sans
    Inter = { url = "https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Regular.otf" },
    Poppins = { url = "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" },
    Roboto = { url = "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Regular.ttf" },
    OpenSans = { url = "https://github.com/google/fonts/raw/main/ofl/opensans/OpenSans%5Bwdth,wght%5D.ttf" },
    Kanit = { url = "https://github.com/google/fonts/raw/main/ofl/kanit/Kanit-Regular.ttf" },

    -- Monospace (Great for Coding/Console UIs)
    JetBrainsMono = { url = "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf" },
    FiraCode = { url = "https://github.com/tonsky/FiraCode/raw/master/distr/ttf/FiraCode-Regular.ttf" },
    Inconsolata = { url = "https://github.com/google/fonts/raw/main/ofl/inconsolata/static/Inconsolata-Regular.ttf" },
    SpaceMono = { url = "https://github.com/google/fonts/raw/main/ofl/spacemono/SpaceMono-Regular.ttf" },
    Hack = { url = "https://github.com/source-foundry/Hack/raw/master/build/ttf/Hack-Regular.ttf" },

    -- Display & Bold Stylized
    BebasNeue = { url = "https://github.com/google/fonts/raw/main/ofl/bebasneue/BebasNeue-Regular.ttf" },
    Oswald = { url = "https://github.com/google/fonts/raw/main/ofl/oswald/static/Oswald-Regular.ttf" },
    ArchivoBlack = { url = "https://github.com/google/fonts/raw/main/ofl/archivoblack/ArchivoBlack-Regular.ttf" },
    Syne = { url = "https://github.com/google/fonts/raw/main/ofl/syne/Syne%5Bwght%5D.ttf" },
    Outfit = { url = "https://github.com/google/fonts/raw/main/ofl/outfit/static/Outfit-Regular.ttf" },

    -- Serif & Classic
    PlayfairDisplay = { url = "https://github.com/google/fonts/raw/main/ofl/playfairdisplay/static/PlayfairDisplay-Regular.ttf" },
    Lora = { url = "https://github.com/google/fonts/raw/main/ofl/lora/static/Lora-Regular.ttf" },
    Merriweather = { url = "https://github.com/google/fonts/raw/main/ofl/merriweather/static/Merriweather-Regular.ttf" },
    PTSerif = { url = "https://github.com/google/fonts/raw/main/ofl/ptserif/PTSerif-Regular.ttf" },
    LibreBaskerville = { url = "https://github.com/google/fonts/raw/main/ofl/librebaskerville/LibreBaskerville-Regular.ttf" },

    -- Retro & Niche
    PressStart2P = { url = "https://github.com/google/fonts/raw/main/ofl/pressstart2p/PressStart2P-Regular.ttf" },
    Silkscreen = { url = "https://github.com/google/fonts/raw/main/ofl/silkscreen/Silkscreen-Regular.ttf" },
    PixelifySans = { url = "https://github.com/google/fonts/raw/main/ofl/pixelifysans/PixelifySans%5Bwght%5D.ttf" },
    Lexend = { url = "https://github.com/google/fonts/raw/main/ofl/lexend/static/Lexend-Regular.ttf" }
}

local function LoadCustomFont(fontName)
    local fontData = CustomFonts[fontName]
    if not fontData then return nil end
    
    local fileName = fontName .. ".ttf"
    local fontFileName = fontName .. ".font"
    
    if not isfile(fileName) then
        local success, result = pcall(function()
            return game:HttpGet(fontData.url)
        end)
        if success and result then
            writefile(fileName, result)
        else
            return nil
        end
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
    
    writefile(fontFileName, HttpService:JSONEncode(fontConfig))
    return Font.new(getcustomasset(fontFileName), Enum.FontWeight.Regular)
end

local Settings = {
    Main = {
        Enabled = true,
        RenderDistance = 10000,
    },
    
    Chams = {
        Enabled = true,
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
        UseCustomFont = true,
        CustomFontName = "Tahoma",
    },
    
    DistanceText = {
        Enabled = true,
        Color = { Color = rgb(255, 255, 255) },
        Position = "Bottom",
        Size = 12,
        UseCustomFont = true,
        CustomFontName = "Tahoma",
    },
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EspObject"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Cache = Instance.new("ScreenGui")
Cache.Name = "EspCache"
Cache.Enabled = false
Cache.ResetOnSpawn = false
Cache.Parent = gethui_safe

local guiProtections = {}
table.insert(guiProtections, protectGUI(ScreenGui))
table.insert(guiProtections, protectGUI(Cache))

local EspPlayers = {}
local EspConnections = {}
local LoopConnection = nil
local LoadedCustomFonts = {}

local function enforceGUIParent()
    if ScreenGui and ScreenGui.Parent ~= CoreGui then
        ScreenGui.Parent = CoreGui
    end
    if Cache and Cache.Parent ~= gethui_safe and Cache.Parent ~= CoreGui then
        Cache.Parent = gethui_safe
    end
end

local function Create(instance, options)
    local Ins = Instance.new(instance)
    for prop, value in pairs(options) do
        Ins[prop] = value
    end
    return Ins
end

local function GetFontForText(settings)
    if settings.UseCustomFont then
        if not LoadedCustomFonts[settings.CustomFontName] then
            local font = LoadCustomFont(settings.CustomFontName)
            if font then
                LoadedCustomFonts[settings.CustomFontName] = font
            else
                return Font.new("rbxasset://fonts/families/Arial.json")
            end
        end
        return LoadedCustomFonts[settings.CustomFontName]
    else
        return Font.new("rbxasset://fonts/families/Arial.json")
    end
end

local function ConvertScreenPoint(world_position)
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

local function BoxSolve(rootPart)
    if not rootPart then
        return nil, nil, nil, nil
    end
    
    local ViewportTop = rootPart.Position + (rootPart.CFrame.UpVector * 1.8) + Camera.CFrame.UpVector
    local ViewportBottom = rootPart.Position - (rootPart.CFrame.UpVector * 2.5) - Camera.CFrame.UpVector
    local Distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    
    local Top, TopIsRendered = ConvertScreenPoint(ViewportTop)
    local Bottom, BottomIsRendered = ConvertScreenPoint(ViewportBottom)
    
    local Width = math.max(math.floor(math.abs(Top.X - Bottom.X)), 8)
    local Height = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 12)
    local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
    local BoxPosition = Vector2.new(math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5), math.floor(math.min(Top.Y, Bottom.Y)))
    
    return BoxSize, BoxPosition, TopIsRendered, Distance
end

local function CreateObject(player)
    local Data = {
        Items = {},
        Info = {}
    }
    
    local Items = Data.Items
    
    Items.Holder = Create("Frame", {
        Parent = ScreenGui,
        Visible = false,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0.433, 0, 0.326, 0),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(0, 211, 0, 240),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.HolderGradient = Create("UIGradient", {
        Rotation = 0,
        Name = "",
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(255, 255, 255))
        }),
        Parent = Items.Holder,
        Enabled = true
    })
    
    Items.Left = Create("Frame", {
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
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Left,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.LeftTexts = Create("Frame", {
        LayoutOrder = -100,
        Parent = Items.Left,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIListLayout", {
        Parent = Items.LeftTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Bottom = Create("Frame", {
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
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Bottom,
        Padding = dim(0, 1)
    })
    
    Items.BottomTexts = Create("Frame", {
        LayoutOrder = 1,
        Parent = Items.Bottom,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIListLayout", {
        Parent = Items.BottomTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Top = Create("Frame", {
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
    
    Create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Top,
        Padding = dim(0, 1)
    })
    
    Items.TopTexts = Create("Frame", {
        LayoutOrder = -100,
        Parent = Items.Top,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIListLayout", {
        Parent = Items.TopTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Right = Create("Frame", {
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
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Items.Right,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.RightTexts = Create("Frame", {
        LayoutOrder = 100,
        Parent = Items.Right,
        BackgroundTransparency = 1,
        Name = "",
        BorderColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIListLayout", {
        Parent = Items.RightTexts,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Items.Corners = Create("Frame", {
        Parent = Cache,
        Name = "",
        BackgroundTransparency = 1,
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.BottomLeftX = Create("ImageLabel", {
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
    
    Create("UIGradient", { Parent = Items.BottomLeftX })
    
    Items.BottomLeftY = Create("ImageLabel", {
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
    
    Create("UIGradient", { Rotation = -90, Parent = Items.BottomLeftY })
    
    Items.BottomRightX = Create("ImageLabel", {
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
    
    Create("UIGradient", { Parent = Items.BottomRightX })
    
    Items.BottomRightY = Create("ImageLabel", {
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
    
    Create("UIGradient", { Rotation = 90, Parent = Items.BottomRightY })
    
    Items.TopLeftY = Create("ImageLabel", {
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
    
    Create("UIGradient", { Rotation = 90, Parent = Items.TopLeftY })
    
    Items.TopRightY = Create("ImageLabel", {
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
    
    Create("UIGradient", { Rotation = -90, Parent = Items.TopRightY })
    
    Items.TopRightX = Create("ImageLabel", {
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
    
    Create("UIGradient", { Parent = Items.TopRightX })
    
    Items.TopLeftX = Create("ImageLabel", {
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
    
    Create("UIGradient", { Parent = Items.TopLeftX })
    
    Items.Box = Create("Frame", {
        Parent = Cache,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIStroke", {
        Parent = Items.Box,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Inner = Create("Frame", {
        Parent = Items.Box,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.UIStroke = Create("UIStroke", {
        Color = rgb(255, 255, 255),
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = Items.Inner
    })
    
    Items.BoxGradient = Create("UIGradient", {
        Parent = Items.UIStroke,
        Color = Settings.Box.Gradient.ColorSequence,
        Enabled = Settings.Box.GradientEnabled,
        Rotation = Settings.Box.Gradient.Rotation
    })
    
    Items.Inner2 = Create("Frame", {
        Parent = Items.Inner,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIStroke", {
        Parent = Items.Inner2,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Healthbar = Create("Frame", {
        Name = Settings.Healthbar.Position,
        Parent = Cache,
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(0, Settings.Healthbar.Thickness, 0, Settings.Healthbar.Thickness),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(0, 0, 0)
    })
    
    Items.HealthbarAccent = Create("Frame", {
        Parent = Items.Healthbar,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.HealthbarFade = Create("Frame", {
        Parent = Items.Healthbar,
        Name = "",
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(0, 0, 0)
    })
    
    Items.HealthbarGradient = Create("UIGradient", {
        Enabled = Settings.Healthbar.GradientEnabled,
        Parent = Items.HealthbarAccent,
        Rotation = Settings.Healthbar.Gradient.Rotation,
        Color = Settings.Healthbar.Gradient.ColorSequence
    })
    
    local nameFont = GetFontForText(Settings.NameText)
    local distanceFont = GetFontForText(Settings.DistanceText)
    
    Items.Text = Create("TextLabel", {
        FontFace = nameFont,
        TextColor3 = Settings.NameText.Color.Color,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Cache,
        Name = Settings.NameText.Position,
        Text = player.Name,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = Settings.NameText.Size,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIStroke", {
        Parent = Items.Text,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Distance = Create("TextLabel", {
        FontFace = distanceFont,
        TextColor3 = Settings.DistanceText.Color.Color,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Cache,
        Name = Settings.DistanceText.Position,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = Settings.DistanceText.Size,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Create("UIStroke", {
        Parent = Items.Distance,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Data.RefreshChams = function()
        local Character = Data.Info.Character
        if not Data.Highlight then
            Data.Highlight = Create("Highlight", {
                FillColor = Settings.Chams.Fill.Color,
                Enabled = Settings.Chams.Enabled,
                OutlineTransparency = Settings.Chams.Outline.Transparency,
                Adornee = Character,
                FillTransparency = Settings.Chams.Fill.Transparency,
                OutlineColor = Settings.Chams.Outline.Color,
                Parent = CoreGui
            })
        else
            Data.Highlight.Adornee = Character
        end
    end
    
    local HealthTween = nil
    
    Data.HealthChanged = function(Value)
        if not Settings.Healthbar.Enabled then
            return
        end
        
        local Multiplier = math.clamp(Value / 100, 0, 1)
        local isHorizontal = Settings.Healthbar.Position == "Top" or Settings.Healthbar.Position == "Bottom"
        
        local targetSize
        local targetPosition
        
        if isHorizontal then
            targetSize = dim2(1 - Multiplier, -2, 1, -2)
            targetPosition = dim2(Multiplier, 1, 0, 1)
        else
            targetSize = dim2(1, 0, 1 - Multiplier, 0)
            targetPosition = dim2(0, 1, Multiplier, 1)
        end
        
        if Settings.Healthbar.Tween and TweenService then
            if HealthTween and HealthTween.Cancel then
                HealthTween:Cancel()
            end
            
            local tweenInfo = TweenInfo.new(
                Settings.Healthbar.TweenSpeed,
                Enum.EasingStyle[Settings.Healthbar.EasingStyle],
                Enum.EasingDirection[Settings.Healthbar.EasingDirection]
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
        
        local conn = Humanoid.HealthChanged:Connect(function(h)
            Data.HealthChanged(h)
        end)
        table.insert(EspConnections, conn)
        
        Data.HealthChanged(Humanoid.Health)
        Data.RefreshChams()
    end
    
    Data.Destroy = function()
        if Items.Holder then
            Items.Holder:Destroy()
        end
        if Data.Highlight then
            Data.Highlight:Destroy()
        end
        EspPlayers[player.Name] = nil
    end
    
    Data.RefreshDescendants()
    
    local conn = player.CharacterAdded:Connect(function()
        Data.RefreshDescendants()
    end)
    table.insert(EspConnections, conn)
    
    if Settings.Box.Enabled then
        if Settings.Box.Type == "Corner" then
            Items.Corners.Parent = Items.Holder
            Items.Box.Parent = Cache
        else
            Items.Box.Parent = Items.Holder
            Items.Corners.Parent = Cache
        end
    end
    
    if Settings.NameText.Enabled then
        Items.Text.Parent = Items[Settings.NameText.Position .. "Texts"]
        if Settings.NameText.Position == "Top" or Settings.NameText.Position == "Bottom" then
            Items.Text.AutomaticSize = Enum.AutomaticSize.Y
            Items.Text.TextXAlignment = Enum.TextXAlignment.Center
        else
            Items.Text.AutomaticSize = Enum.AutomaticSize.XY
            Items.Text.TextXAlignment = Settings.NameText.Position == "Right" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        end
    end
    
    if Settings.DistanceText.Enabled then
        Items.Distance.Parent = Items[Settings.DistanceText.Position .. "Texts"]
        if Settings.DistanceText.Position == "Top" or Settings.DistanceText.Position == "Bottom" then
            Items.Distance.AutomaticSize = Enum.AutomaticSize.Y
            Items.Distance.TextXAlignment = Enum.TextXAlignment.Center
        else
            Items.Distance.AutomaticSize = Enum.AutomaticSize.XY
            Items.Distance.TextXAlignment = Settings.DistanceText.Position == "Right" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        end
    end
    
    if Settings.Healthbar.Enabled then
        Items.Healthbar.Parent = Items[Settings.Healthbar.Position]
        Items.Healthbar.Visible = true
    end
    
    if Settings.Box.Fill then
        Items.Holder.BackgroundTransparency = 0
        if Settings.Box.FillGradientEnabled then
            Items.HolderGradient.Color = Settings.Box.FillGradient.ColorSequence
            Items.HolderGradient.Transparency = Settings.Box.FillGradient.Transparency
            Items.HolderGradient.Rotation = Settings.Box.FillGradient.Rotation
        end
    end
    
    EspPlayers[player.Name] = Data
end

local function Update()
    if not Settings.Main.Enabled then
        return
    end
    
    enforceGUIParent()
    
    for _, Data in pairs(EspPlayers) do
        if Data.Info and Data.Info.Character and Data.Info.Humanoid and Data.Info.Humanoid.RootPart and Data.Items then
            local Items = Data.Items
            local BoxSize, BoxPos, OnScreen, Distance = BoxSolve(Data.Info.Humanoid.RootPart)
            local Holder = Items.Holder
            
            if Holder and Settings.Main.RenderDistance then
                if Distance and Distance <= Settings.Main.RenderDistance and OnScreen then
                    Holder.Visible = true
                    Holder.Position = dim_offset(BoxPos.X, BoxPos.Y)
                    Holder.Size = dim2(0, BoxSize.X, 0, BoxSize.Y)
                    
                    if Settings.DistanceText.Enabled and Items.Distance then
                        Items.Distance.Text = tostring(math.round(Distance)) .. "m"
                    end
                else
                    Holder.Visible = false
                end
            end
        end
    end
end

local function Unload()
    for _, conn in pairs(EspConnections) do
        conn:Disconnect()
    end
    if LoopConnection then
        RunService:UnbindFromRenderStep("Run Loop")
        LoopConnection = nil
    end
    for _, data in pairs(EspPlayers) do
        if data.Destroy then
            data.Destroy()
        end
    end
    if ScreenGui then
        ScreenGui:Destroy()
    end
    if Cache then
        Cache:Destroy()
    end
    for _, protection in pairs(guiProtections) do
        if protection then
            for _, conn in pairs(protection) do
                if conn and conn.Disconnect then
                    conn:Disconnect()
                end
            end
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        CreateObject(player)
    end
end

local playerAddedConn = Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        CreateObject(player)
    end
end)
table.insert(EspConnections, playerAddedConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
    if EspPlayers[player.Name] then
        EspPlayers[player.Name].Destroy()
    end
end)
table.insert(EspConnections, playerRemovingConn)

LoopConnection = RunService:BindToRenderStep("Run Loop", 400, Update)

getgenv().UnloadESP = Unload
