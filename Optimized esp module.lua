-- ESPLib Module
local ESPLib = {}

-- Services
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))

-- Private variables
local Camera = nil
local EspInstances = {}
local EspConnections = {}
local LoopConnection = nil
local LoadedCustomFonts = {}
local ScreenGui = nil
local Cache = nil
local ActiveSettings = nil

-- Update camera reference
local function UpdateCamera()
    Camera = cloneref(workspace.CurrentCamera)
end
UpdateCamera()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(UpdateCamera)

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

local function Create(instance, options)
    local Ins = Instance.new(instance)
    for prop, value in pairs(options) do
        Ins[prop] = value
    end
    return Ins
end

-- Font handling
local CustomFonts = {
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

local function LoadCustomFont(fontName)
    local fontData = CustomFonts[fontName]
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

local function ApplyFontToText(textLabel, settings)
    if settings.UseCustomFont then
        if not LoadedCustomFonts[settings.CustomFontName] then
            local font = LoadCustomFont(settings.CustomFontName)
            if font then
                LoadedCustomFonts[settings.CustomFontName] = font
                textLabel.FontFace = font
                return true
            else
                textLabel.Font = settings.Font
                return false
            end
        else
            textLabel.FontFace = LoadedCustomFonts[settings.CustomFontName]
            return true
        end
    else
        textLabel.Font = settings.Font
        return true
    end
end

-- Math/Conversion functions
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

-- UI Element Creators
local function CreateBoxElements(Items, settings)
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
        Color = settings.Gradient.ColorSequence,
        Enabled = settings.GradientEnabled,
        Rotation = settings.Gradient.Rotation
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
    
    Items.Corners = Create("Frame", {
        Parent = Cache,
        Name = "",
        BackgroundTransparency = 1,
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    -- Corner elements creation (simplified for brevity)
    Items.BottomLeftX = Create("ImageLabel", {
        ScaleType = Enum.ScaleType.Slice,
        Parent = Items.Corners,
        BorderColor3 = rgb(0, 0, 0),
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
    
    -- Additional corner elements would go here (simplified)
    
    if settings.Type == "Corner" then
        Items.Corners.Parent = Items.Holder
        Items.Box.Parent = Cache
    else
        Items.Box.Parent = Items.Holder
        Items.Corners.Parent = Cache
    end
    
    if settings.Fill then
        Items.Holder.BackgroundTransparency = 0
        if settings.FillGradientEnabled then
            Items.HolderGradient.Color = settings.FillGradient.ColorSequence
            Items.HolderGradient.Transparency = settings.FillGradient.Transparency
            Items.HolderGradient.Rotation = settings.FillGradient.Rotation
        end
    end
end

local function CreateHealthbarElements(Items, settings)
    Items.Healthbar = Create("Frame", {
        Name = settings.Position,
        Parent = Cache,
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(0, settings.Thickness, 0, settings.Thickness),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(0, 0, 0)
    })
    
    Items.HealthbarAccent = Create("Frame", {
        Parent = Items.Healthbar,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    Items.HealthbarFade = Create("Frame", {
        Parent = Items.Healthbar,
        Position = dim2(0, 1, 0, 1),
        BorderColor3 = rgb(0, 0, 0),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(0, 0, 0)
    })
    
    Items.HealthbarGradient = Create("UIGradient", {
        Enabled = settings.GradientEnabled,
        Parent = Items.HealthbarAccent,
        Rotation = settings.Gradient.Rotation,
        Color = settings.Gradient.ColorSequence
    })
    
    Items.Healthbar.Parent = Items[settings.Position]
    Items.Healthbar.Visible = true
end

local function CreateNameTextElements(Items, player, settings)
    Items.Text = Create("TextLabel", {
        TextColor3 = settings.Color.Color,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Cache,
        Name = settings.Position,
        Text = player.Name,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = settings.Size,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    ApplyFontToText(Items.Text, settings)
    
    Create("UIStroke", {
        Parent = Items.Text,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Text.Parent = Items[settings.Position .. "Texts"]
    if settings.Position == "Top" or settings.Position == "Bottom" then
        Items.Text.AutomaticSize = Enum.AutomaticSize.Y
        Items.Text.TextXAlignment = Enum.TextXAlignment.Center
    else
        Items.Text.AutomaticSize = Enum.AutomaticSize.XY
        Items.Text.TextXAlignment = settings.Position == "Right" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    end
end

local function CreateDistanceTextElements(Items, settings)
    Items.Distance = Create("TextLabel", {
        TextColor3 = settings.Color.Color,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Cache,
        Name = settings.Position,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = settings.Size,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    
    ApplyFontToText(Items.Distance, settings)
    
    Create("UIStroke", {
        Parent = Items.Distance,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    
    Items.Distance.Parent = Items[settings.Position .. "Texts"]
    if settings.Position == "Top" or settings.Position == "Bottom" then
        Items.Distance.AutomaticSize = Enum.AutomaticSize.Y
        Items.Distance.TextXAlignment = Enum.TextXAlignment.Center
    else
        Items.Distance.AutomaticSize = Enum.AutomaticSize.XY
        Items.Distance.TextXAlignment = settings.Position == "Right" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    end
end

local function CreateChamsElements(Data, settings)
    Data.Highlight = Create("Highlight", {
        FillColor = settings.Fill.Color,
        Enabled = settings.Enabled,
        OutlineTransparency = settings.Outline.Transparency,
        Adornee = Data.Info.Character,
        FillTransparency = settings.Fill.Transparency,
        OutlineColor = settings.Outline.Color,
        Parent = CoreGui
    })
end

local function CreateContainerFrames(Items, settings)
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
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(255, 255, 255))
        }),
        Parent = Items.Holder,
        Enabled = true
    })
    
    -- Create all position frames (Left, Right, Top, Bottom)
    local positions = {"Left", "Right", "Top", "Bottom"}
    for _, pos in pairs(positions) do
        Items[pos] = Create("Frame", {
            Parent = Items.Holder,
            Size = pos == "Left" or pos == "Right" and dim2(0, 0, 1, 0) or dim2(1, 0, 0, 0),
            Name = "",
            BackgroundTransparency = 1,
            Position = pos == "Left" and dim2(0, -1, 0, 0) or 
                      pos == "Right" and dim2(1, 1, 0, 0) or
                      pos == "Top" and dim2(0, 0, 0, -1) or
                      dim2(0, 0, 1, 1),
            BorderColor3 = rgb(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        Create("UIListLayout", {
            FillDirection = (pos == "Left" or pos == "Right") and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
            HorizontalAlignment = pos == "Left" and Enum.HorizontalAlignment.Right or 
                                 pos == "Right" and Enum.HorizontalAlignment.Left or 
                                 Enum.HorizontalAlignment.Center,
            VerticalAlignment = pos == "Top" and Enum.VerticalAlignment.Bottom or 
                               pos == "Bottom" and Enum.VerticalAlignment.Top or 
                               Enum.VerticalAlignment.Center,
            Parent = Items[pos],
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Items[pos .. "Texts"] = Create("Frame", {
            LayoutOrder = (pos == "Left" or pos == "Top") and -100 or 100,
            Parent = Items[pos],
            BackgroundTransparency = 1,
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = (pos == "Left" or pos == "Right") and Enum.AutomaticSize.X or Enum.AutomaticSize.XY,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        Create("UIListLayout", {
            Parent = Items[pos .. "Texts"],
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    end
end

-- Main ESP Object Creator
local function CreateESPObject(player, settings)
    local Data = {
        Items = {},
        Info = {}
    }
    
    local Items = Data.Items
    
    -- Create container frames
    CreateContainerFrames(Items, settings)
    
    -- Create elements based on settings
    if settings.Box.Enabled then
        CreateBoxElements(Items, settings.Box)
    end
    
    if settings.Healthbar.Enabled then
        CreateHealthbarElements(Items, settings.Healthbar)
    end
    
    if settings.NameText.Enabled then
        CreateNameTextElements(Items, player, settings.NameText)
    end
    
    if settings.DistanceText.Enabled then
        CreateDistanceTextElements(Items, settings.DistanceText)
    end
    
    -- Setup health changed handler
    local HealthTween = nil
    
    Data.HealthChanged = function(Value)
        if not settings.Healthbar.Enabled or not Items.Healthbar then
            return
        end
        
        local Multiplier = math.clamp(Value / 100, 0, 1)
        local isHorizontal = settings.Healthbar.Position == "Top" or settings.Healthbar.Position == "Bottom"
        
        local targetSize
        local targetPosition
        
        if isHorizontal then
            targetSize = dim2(1 - Multiplier, -2, 1, -2)
            targetPosition = dim2(Multiplier, 1, 0, 1)
        else
            targetSize = dim2(1, 0, 1 - Multiplier, 0)
            targetPosition = dim2(0, 1, Multiplier, 1)
        end
        
        if settings.Healthbar.Tween and TweenService then
            if HealthTween and HealthTween.Cancel then
                HealthTween:Cancel()
            end
            
            local tweenInfo = TweenInfo.new(
                settings.Healthbar.TweenSpeed,
                Enum.EasingStyle[settings.Healthbar.EasingStyle],
                Enum.EasingDirection[settings.Healthbar.EasingDirection]
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
    
    -- Setup chams
    Data.RefreshChams = function()
        if not settings.Chams.Enabled then
            if Data.Highlight then
                Data.Highlight:Destroy()
                Data.Highlight = nil
            end
            return
        end
        
        local Character = Data.Info.Character
        if Character then
            if not Data.Highlight then
                CreateChamsElements(Data, settings.Chams)
            else
                Data.Highlight.Adornee = Character
                Data.Highlight.Enabled = true
            end
        end
    end
    
    -- Setup character tracking
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
        
        if settings.Healthbar.Enabled then
            local conn = Humanoid.HealthChanged:Connect(function(h)
                Data.HealthChanged(h)
            end)
            table.insert(EspConnections, conn)
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
    end
    
    Data.RefreshDescendants()
    
    local conn = player.CharacterAdded:Connect(function()
        Data.RefreshDescendants()
    end)
    table.insert(EspConnections, conn)
    
    return Data
end

-- Update function
local function Update(settings)
    if not settings.Main.Enabled then
        for _, data in pairs(EspInstances) do
            if data.Items and data.Items.Holder then
                data.Items.Holder.Visible = false
            end
        end
        return
    end
    
    local hasAnyFeature = settings.Box.Enabled or settings.NameText.Enabled or 
                          settings.DistanceText.Enabled or settings.Healthbar.Enabled
    
    if not hasAnyFeature then
        for _, data in pairs(EspInstances) do
            if data.Items and data.Items.Holder then
                data.Items.Holder.Visible = false
            end
        end
        return
    end
    
    local needsPositionCalc = settings.Box.Enabled or settings.DistanceText.Enabled
    
    for _, data in pairs(EspInstances) do
        if data.Info and data.Info.Character and data.Info.Humanoid and data.Info.Humanoid.RootPart then
            local Items = data.Items
            local Holder = Items.Holder
            
            if Holder then
                if needsPositionCalc then
                    local BoxSize, BoxPos, OnScreen, Distance = BoxSolve(data.Info.Humanoid.RootPart)
                    
                    if Distance and Distance <= settings.Main.RenderDistance and OnScreen then
                        Holder.Visible = true
                        Holder.Position = dim_offset(BoxPos.X, BoxPos.Y)
                        Holder.Size = dim2(0, BoxSize.X, 0, BoxSize.Y)
                        
                        if settings.DistanceText.Enabled and Items.Distance then
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

-- Public API
function ESPLib.Initialize(settings)
    -- Validate settings structure
    assert(settings, "Settings table required")
    assert(settings.Main, "Main settings required")
    assert(settings.Box, "Box settings required")
    assert(settings.Healthbar, "Healthbar settings required")
    assert(settings.NameText, "NameText settings required")
    assert(settings.DistanceText, "DistanceText settings required")
    assert(settings.Chams, "Chams settings required")
    
    ActiveSettings = settings
    
    -- Create GUI containers
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESPLib"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    Cache = Instance.new("ScreenGui")
    Cache.Name = "ESPLibCache"
    Cache.Enabled = false
    Cache.ResetOnSpawn = false
    Cache.Parent = CoreGui
    
    -- Create ESP objects for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local espObject = CreateESPObject(player, settings)
            EspInstances[player] = espObject
        end
    end
    
    -- Connect events
    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            local espObject = CreateESPObject(player, settings)
            EspInstances[player] = espObject
        end
    end)
    table.insert(EspConnections, playerAddedConn)
    
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        if EspInstances[player] then
            EspInstances[player].Destroy()
            EspInstances[player] = nil
        end
    end)
    table.insert(EspConnections, playerRemovingConn)
    
    -- Start update loop
    LoopConnection = RunService:BindToRenderStep("ESPLib_Update", 400, function()
        Update(settings)
    end)
    
    return true
end

function ESPLib.UpdateSettings(newSettings)
    ActiveSettings = newSettings
    -- Recreate all ESP objects with new settings
    ESPLib.Unload()
    ESPLib.Initialize(newSettings)
end

function ESPLib.Unload()
    for _, conn in pairs(EspConnections) do
        conn:Disconnect()
    end
    EspConnections = {}
    
    if LoopConnection then
        RunService:UnbindFromRenderStep("ESPLib_Update")
        LoopConnection = nil
    end
    
    for _, data in pairs(EspInstances) do
        if data.Destroy then
            data.Destroy()
        end
    end
    EspInstances = {}
    
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
    
    if Cache then
        Cache:Destroy()
        Cache = nil
    end
    
    LoadedCustomFonts = {}
end

function ESPLib.IsLoaded()
    return LoopConnection ~= nil
end

function ESPLib.GetSettings()
    return ActiveSettings
end

return ESPLib
