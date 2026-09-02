--[[
    NYX HUB — Mobile Optimized Script Hub
    Features: Combat, Visuals, Movement, World, Utilities
    Works with: Synapse X, Krnl, Fluxus, ScriptWare (mobile)
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local GuiService = game:GetService("GuiService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings Defaults
local Settings = {
    Aimbot = {
        Enabled = false,
        Hitbox = "Head", -- Head, Torso, HumanoidRootPart
        Smoothing = 0.35,
        Prediction = 0.13,
        FOV = 180,
        StickyTarget = true,
        DistanceLimit = 500,
        SilentAim = false,
        FreeAim = false,
        Triggerbot = false,
        TriggerDelay = 0.1,
        HoldToFire = false,
        Tracers = true,
        HitMarkers = true,
        HitLogs = true,
        TargetIgnore = {}, -- ignored player names
    },
    Visuals = {
        Enabled = false,
        Boxes2D = true,
        Boxes3D = false,
        Skeleton = true,
        Names = true,
        Health = true,
        Distance = true,
        Flags = true,
        Chams = true,
        ChamFill = Color3.fromRGB(255, 0, 80),
        ChamOutline = Color3.fromRGB(255, 255, 255),
        ChamMaterial = Enum.Material.ForceField,
        OffscreenArrows = true,
        Snaplines = true,
        ChinaHat = false,
        GrenadeRadius = true,
        FuseIndicator = true,
        CustomCrosshair = true,
        Radar = true,
        RadarZoom = 1,
        RadarPosition = Vector2.new(0.85, 0.1),
        LivePreview = false,
    },
    Movement = {
        Fly = false,
        FlySpeed = 50,
        FlyDamping = 0.95,
        Walkspeed = 16,
        BunnyHop = false,
        Noclip = false,
        Desync = false,
        DesyncMarker = false,
    },
    World = {
        AmbientColor = Color3.fromRGB(70, 70, 70),
        OutdoorColor = Color3.fromRGB(128, 128, 128),
        Brightness = 2,
        Exposure = 1,
        SkyColorShift = false,
        FogColor = Color3.fromRGB(180, 180, 180),
        FogStart = 100,
        FogEnd = 500,
        CustomSkybox = false,
        Stars = true,
        SunTexture = "",
        MoonTexture = "",
        WeaponAppearance = false,
        WeaponColor = Color3.fromRGB(255, 0, 0),
    },
    UI = {
        AutoOffset = true,
        ConfigSaveLoad = true,
        Watermark = true,
        StreamProof = false,
        Keybinds = {},
    }
}

-- Saved Config
local Config = {
    Keybinds = {},
    Theme = {
        Accent = Color3.fromRGB(255, 60, 120),
        Background = Color3.fromRGB(20, 20, 25),
        WindowBg = Color3.fromRGB(30, 30, 38),
        Text = Color3.fromRGB(240, 240, 240),
    }
}

-- ========== UI LIBRARY ==========
local UI = {}
UI.Theme = Config.Theme
UI.Elements = {}
UI.Open = false
UI.Tabs = {}
UI.CurrentTab = nil
UI.WindowVisible = true

-- UI Functions
function UI:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyxHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    
    -- Stream-proof mode
    if Settings.UI.StreamProof then
        ScreenGui.Enabled = false
        -- Bypass for streamproof would go here (using protected functions)
    end
    
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 380, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    MainFrame.BackgroundColor3 = UI.Theme.WindowBg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Drop shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 16, 1, 16)
    Shadow.Position = UDim2.new(0, -8, 0, -8)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(8, 8, 9, 9)
    Shadow.ImageTransparency = 0.5
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = UI.Theme.Background
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, -10, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Nyx Hub"
    Title.TextColor3 = UI.Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 35)
    CloseBtn.Position = UDim2.new(1, -45, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 22
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        UI.WindowVisible = not UI.WindowVisible
        MainFrame.Visible = UI.WindowVisible
    end)
    
    -- Make draggable (touch + mouse)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 85, 1, -45)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = UI.Theme.Background
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingBottom = UDim.new(0, 5)
    TabPadding.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -85, 1, -45)
    ContentContainer.Position = UDim2.new(0, 85, 0, 45)
    ContentContainer.BackgroundColor3 = UI.Theme.WindowBg
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.ScrollBarImageColor3 = UI.Theme.Accent
    ContentContainer.Parent = MainFrame
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 8)
    ContentList.Parent = ContentContainer
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.Parent = ContentContainer
    
    UI.MainFrame = MainFrame
    UI.ScreenGui = ScreenGui
    UI.ContentContainer = ContentContainer
    UI.ContentList = ContentList
    UI.TabContainer = TabContainer
    UI.TabList = TabList
    
    return UI
end

function UI:CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.BackgroundColor3 = Color3.new(1, 1, 1)
    TabBtn.BackgroundTransparency = 0.9
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = icon.." "..name
    TabBtn.TextColor3 = UI.Theme.Text
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 12
    TabBtn.TextWrapped = true
    TabBtn.Parent = UI.TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = TabBtn
    
    -- Content Page
    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = UI.ContentContainer
    
    local PageList = Instance.new("UIListLayout")
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 6)
    PageList.Parent = Page
    
    TabBtn.MouseButton1Click:Connect(function()
        -- Hide all pages
        for _, tab in pairs(UI.Tabs) do
            tab.Page.Visible = false
            tab.Button.BackgroundTransparency = 0.9
        end
        -- Show this page
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.7
        UI.CurrentTab = {Page = Page, Button = TabBtn}
    end)
    
    table.insert(UI.Tabs, {Page = Page, Button = TabBtn})
    
    -- If first tab, show it
    if #UI.Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.7
    end
    
    local TabAPI = {}
    
    function TabAPI:CreateSection(title)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, 0, 0, 35)
        Section.BackgroundColor3 = UI.Theme.Background
        Section.BorderSizePixel = 0
        Section.Parent = Page
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = Section
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.TextColor3 = UI.Theme.Accent
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.Parent = Section
        
        -- Add spacing after section
        local Spacer = Instance.new("Frame")
        Spacer.Size = UDim2.new(1, 0, 0, 4)
        Spacer.BackgroundTransparency = 1
        Spacer.Parent = Page
        
        return Section
    end
    
    function TabAPI:CreateToggle(title, default, callback)
        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(1, 0, 0, 45)
        Toggle.BackgroundColor3 = Color3.new(1, 1, 1)
        Toggle.BackgroundTransparency = 0.95
        Toggle.BorderSizePixel = 0
        Toggle.Parent = Page
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.TextColor3 = UI.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.Parent = Toggle
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
        ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
        ToggleBtn.BackgroundColor3 = default and UI.Theme.Accent or Color3.fromRGB(50, 50, 55)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Text = ""
        ToggleBtn.Parent = Toggle
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleBtn
        
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 18, 0, 18)
        Dot.Position = default and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
        Dot.BackgroundColor3 = Color3.new(1, 1, 1)
        Dot.BorderSizePixel = 0
        Dot.Parent = ToggleBtn
        
        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(1, 0)
        DotCorner.Parent = Dot
        
        local isToggled = default or false
        
        ToggleBtn.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            ToggleBtn.BackgroundColor3 = isToggled and UI.Theme.Accent or Color3.fromRGB(50, 50, 55)
            Dot:TweenPosition(
                UDim2.new(isToggled and 1 or 0, isToggled and -22 or 4, 0.5, -9),
                Enum.EasingDirection.InOut,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            if callback then callback(isToggled) end
        end)
        
        return {
            SetValue = function(val)
                isToggled = val
                ToggleBtn.BackgroundColor3 = val and UI.Theme.Accent or Color3.fromRGB(50, 50, 55)
                Dot.Position = UDim2.new(val and 1 or 0, val and -22 or 4, 0.5, -9)
            end,
            GetValue = function() return isToggled end,
            Button = ToggleBtn,
        }
    end
    
    function TabAPI:CreateSlider(title, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 65)
        SliderFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        SliderFrame.BackgroundTransparency = 0.95
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Page
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 0, 25)
        Label.Position = UDim2.new(0, 10, 0, 2)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.TextColor3 = UI.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0.3, 0, 0, 25)
        ValueLabel.Position = UDim2.new(1, -100, 0, 2)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(default)
        ValueLabel.TextColor3 = UI.Theme.Accent
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 13
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
        ValueLabel.Parent = SliderFrame
        
        local SliderBg = Instance.new("Frame")
        SliderBg.Size = UDim2.new(1, -20, 0, 15)
        SliderBg.Position = UDim2.new(0, 10, 0, 35)
        SliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        SliderBg.BorderSizePixel = 0
        SliderBg.Parent = SliderFrame
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(1, 0)
        SliderCorner.Parent = SliderBg
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = UI.Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBg
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill
        
        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 20, 0, 20)
        Knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
        Knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Knob.BorderSizePixel = 0
        Knob.Parent = SliderBg
        
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob
        
        local dragging = false
        
        local function setValueFromX(x)
            local relX = math.clamp((x - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * relX
            val = math.floor(val * 100) / 100
            Fill.Size = UDim2.new(relX, 0, 1, 0)
            Knob.Position = UDim2.new(relX, -10, 0.5, -10)
            ValueLabel.Text = tostring(val)
            if callback then callback(val) end
            return val
        end
        
        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setValueFromX(input.Position.X)
            end
        end)
        
        SliderBg.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setValueFromX(input.Position.X)
            end
        end)
        
        SliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        return {
            SetValue = function(val)
                local relX = (val - min) / (max - min)
                Fill.Size = UDim2.new(relX, 0, 1, 0)
                Knob.Position = UDim2.new(relX, -10, 0.5, -10)
                ValueLabel.Text = tostring(val)
            end,
            GetValue = function() return tonumber(ValueLabel.Text) end,
        }
    end
    
    function TabAPI:CreateDropdown(title, options, default, callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, 0, 0, 45)
        DropdownFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        DropdownFrame.BackgroundTransparency = 0.95
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Parent = Page
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.TextColor3 = UI.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.Parent = DropdownFrame
        
        local DropdownBtn = Instance.new("TextButton")
        DropdownBtn.Size = UDim2.new(0.45, 0, 0, 30)
        DropdownBtn.Position = UDim2.new(0.55, -10, 0.5, -15)
        DropdownBtn.BackgroundColor3 = UI.Theme.Background
        DropdownBtn.BorderSizePixel = 0
        DropdownBtn.Text = default or options[1]
        DropdownBtn.TextColor3 = UI.Theme.Text
        DropdownBtn.Font = Enum.Font.Gotham
        DropdownBtn.TextSize = 13
        DropdownBtn.TextTruncate = Enum.TextTruncate.AtEnd
        DropdownBtn.Parent = DropdownFrame
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = DropdownBtn
        
        local OptionsFrame = Instance.new("ScrollingFrame")
        OptionsFrame.Size = UDim2.new(0.45, 0, 0, 0)
        OptionsFrame.Position = UDim2.new(0.55, -10, 0.5, 15)
        OptionsFrame.BackgroundColor3 = UI.Theme.Background
        OptionsFrame.BorderSizePixel = 0
        OptionsFrame.ScrollBarThickness = 2
        OptionsFrame.Visible = false
        OptionsFrame.ZIndex = 10
        OptionsFrame.Parent = DropdownFrame
        
        local OptionsCorner = Instance.new("UICorner")
        OptionsCorner.CornerRadius = UDim.new(0, 4)
        OptionsCorner.Parent = OptionsFrame
        
        local OptionsList = Instance.new("UIListLayout")
        OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsList.Parent = OptionsFrame
        
        local function populateOptions()
            for _, opt in pairs(OptionsFrame:GetChildren()) do
                if opt:IsA("TextButton") then
                    opt:Destroy()
                end
            end
            for i, opt in pairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 25)
                OptBtn.BackgroundColor3 = Color3.new(1, 1, 1)
                OptBtn.BackgroundTransparency = 0.95
                OptBtn.Text = opt
                OptBtn.TextColor3 = UI.Theme.Text
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                OptBtn.Parent = OptionsFrame
                OptBtn.MouseButton1Click:Connect(function()
                    DropdownBtn.Text = opt
                    OptionsFrame.Visible = false
                    if callback then callback(opt) end
                end)
            end
            OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
        end
        
        populateOptions()
        
        DropdownBtn.MouseButton1Click:Connect(function()
            OptionsFrame.Visible = not OptionsFrame.Visible
            if OptionsFrame.Visible then
                OptionsFrame.Size = UDim2.new(0.45, 0, 0, math.min(#options * 25, 120))
            else
                OptionsFrame.Size = UDim2.new(0.45, 0, 0, 0)
            end
        end)
        
        return {
            SetValue = function(val)
                DropdownBtn.Text = val
                if callback then callback(val) end
            end,
            GetValue = function() return DropdownBtn.Text end,
            Refresh = function(newOptions)
                options = newOptions
                populateOptions()
            end,
        }
    end
    
    function TabAPI:CreateTextbox(title, placeholder, callback)
        local TextboxFrame = Instance.new("Frame")
        TextboxFrame.Size = UDim2.new(1, 0, 0, 45)
        TextboxFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        TextboxFrame.BackgroundTransparency = 0.95
        TextboxFrame.BorderSizePixel = 0
        TextboxFrame.Parent = Page
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.TextColor3 = UI.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.Parent = TextboxFrame
        
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(0.55, 0, 0, 30)
        TextBox.Position = UDim2.new(0.45, -10, 0.5, -15)
        TextBox.BackgroundColor3 = UI.Theme.Background
        TextBox.BorderSizePixel = 0
        TextBox.PlaceholderText = placeholder or ""
        TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        TextBox.Text = ""
        TextBox.TextColor3 = UI.Theme.Text
        TextBox.Font = Enum.Font.Gotham
        TextBox.TextSize = 13
        TextBox.ClearTextOnFocus = false
        TextBox.Parent = TextboxFrame
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = TextBox
        
        TextBox.FocusLost:Connect(function(enterPressed)
            if callback then callback(TextBox.Text) end
        end)
        
        return {
            SetValue = function(val) TextBox.Text = val end,
            GetValue = function() return TextBox.Text end,
        }
    end
    
    function TabAPI:CreateLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 25)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = UI.Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.TextWrapped = true
        Label.Parent = Page
        return Label
    end
    
    function TabAPI:CreateButton(title, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 35)
        Button.BackgroundColor3 = UI.Theme.Accent
        Button.BorderSizePixel = 0
        Button.Text = title
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 14
        Button.Parent = Page
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 4)
        Corner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        
        return Button
    end
    
    return TabAPI
end

function UI:Notify(title, message, duration)
    duration = duration or 3
    local Notify = Instance.new("Frame")
    Notify.Size = UDim2.new(0, 250, 0, 60)
    Notify.Position = UDim2.new(1, -260, 1, -70)
    Notify.BackgroundColor3 = UI.Theme.WindowBg
    Notify.BorderSizePixel = 0
    Notify.ClipsDescendants = true
    Notify.Parent = UI.ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Notify
    
    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 4, 1, 0)
    AccentBar.BackgroundColor3 = UI.Theme.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Notify
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -15, 0, 22)
    TitleLabel.Position = UDim2.new(0, 12, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = UI.Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Notify
    
    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(1, -15, 0, 25)
    MsgLabel.Position = UDim2.new(0, 12, 0, 28)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message or ""
    MsgLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextSize = 12
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextYAlignment = Enum.TextYAlignment.Top
    MsgLabel.TextWrapped = true
    MsgLabel.Parent = Notify
    
    Notify:TweenPosition(
        UDim2.new(1, -260, 1, -130),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true
    )
    
    task.wait(duration)
    
    Notify:TweenPosition(
        UDim2.new(1, -260, 1, -70),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Quad,
        0.3,
        true,
        function()
            Notify:Destroy()
        end
    )
end

function UI:Watermark()
    if not Settings.UI.Watermark then return end
    
    local Watermark = Instance.new("TextLabel")
    Watermark.Name = "Watermark"
    Watermark.Size = UDim2.new(0, 200, 0, 20)
    Watermark.Position = UDim2.new(0, 10, 0, 10)
    Watermark.BackgroundTransparency = 1
    Watermark.Text = "NYX HUB | "..LocalPlayer.Name
    Watermark.TextColor3 = UI.Theme.Accent
    Watermark.Font = Enum.Font.GothamBold
    Watermark.TextSize = 13
    Watermark.TextXAlignment = Enum.TextXAlignment.Left
    Watermark.TextYAlignment = Enum.TextYAlignment.Center
    Watermark.Parent = UI.ScreenGui
    
    -- FPS counter
    local FPS = Instance.new("TextLabel")
    FPS.Name = "FPS"
    FPS.Size = UDim2.new(0, 100, 0, 20)
    FPS.Position = UDim2.new(0, 10, 0, 32)
    FPS.BackgroundTransparency = 1
    FPS.Text = "FPS: 60"
    FPS.TextColor3 = Color3.fromRGB(200, 200, 200)
    FPS.Font = Enum.Font.Gotham
    FPS.TextSize = 12
    FPS.TextXAlignment = Enum.TextXAlignment.Left
    FPS.Parent = UI.ScreenGui
    
    RunService.RenderStepped:Connect(function()
        FPS.Text = "FPS: "..math.floor(1 / RunService.RenderStepped:Wait())
    end)
end

-- ========== COMBAT SYSTEM ==========
local Combat = {}
local AimbotTarget = nil
local LastTarget = nil

function Combat:GetClosestPlayerToCursor(fovRadius)
    local closest = nil
    local closestDist = fovRadius or math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                -- Check if ignored
                local ignored = false
                for _, name in pairs(Settings.Aimbot.TargetIgnore) do
                    if name == player.Name then ignored = true break end
                end
                if ignored then continue end
                
                local part = player.Character:FindFirstChild(Settings.Aimbot.Hitbox) or player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    local worldDist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude) or 0
                    
                    if dist < closestDist and worldDist <= Settings.Aimbot.DistanceLimit then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

function Combat:GetPredictedPosition(target)
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local targetPart = target.Character:FindFirstChild(Settings.Aimbot.Hitbox) or target.Character.HumanoidRootPart
    local targetVelocity = target.Character.HumanoidRootPart.AssemblyLinearVelocity
    
    -- Prediction
    local predictedPos = targetPart.Position + (targetVelocity * Settings.Aimbot.Prediction)
    
    return predictedPos
end

function Combat:Aimbot()
    if not Settings.Aimbot.Enabled then return end
    
    local target = Combat:GetClosestPlayerToCursor(Settings.Aimbot.FOV)
    
    if Settings.Aimbot.StickyTarget and AimbotTarget and AimbotTarget.Character and AimbotTarget.Character:FindFirstChild("Humanoid") and AimbotTarget.Character.Humanoid.Health > 0 then
        target = AimbotTarget
    end
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        AimbotTarget = target
        local predictedPos = Combat:GetPredictedPosition(target)
        if predictedPos then
            -- Smooth aim
            local currentPos = Camera.CFrame.Position
            local targetCFrame = CFrame.new(currentPos, predictedPos)
            
            if Settings.Aimbot.SilentAim then
                -- Silent aim would require remote manipulation (game-specific)
                -- For now, we set a flag for silent aim systems
                Settings.Aimbot._SilentTarget = target
                Settings.Aimbot._SilentPosition = predictedPos
            elseif Settings.Aimbot.FreeAim then
                -- Free aim - just set target for visualization
                Settings.Aimbot._FreeTarget = target
                Settings.Aimbot._FreePosition = predictedPos
            else
                -- Normal aimbot
                if Settings.Aimbot.Smoothing > 0 then
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Aimbot.Smoothing)
                else
                    Camera.CFrame = targetCFrame
                end
            end
        end
    else
        AimbotTarget = nil
    end
end

function Combat:Triggerbot()
    if not Settings.Aimbot.Triggerbot then return end
    
    local target = Combat:GetClosestPlayerToCursor(Settings.Aimbot.FOV)
    
    if target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
        -- Trigger fire
        if Settings.Aimbot.HoldToFire then
            -- Hold to fire
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                Settings.Aimbot._TriggerActive = true
            else
                Settings.Aimbot._TriggerActive = false
            end
        else
            -- Auto fire with delay
            if not Settings.Aimbot._TriggerCooldown then
                Settings.Aimbot._TriggerActive = true
                task.wait(Settings.Aimbot.TriggerDelay)
                Settings.Aimbot._TriggerActive = false
                Settings.Aimbot._TriggerCooldown = true
                task.wait(Settings.Aimbot.TriggerDelay)
                Settings.Aimbot._TriggerCooldown = nil
            end
        end
    else
        Settings.Aimbot._TriggerActive = false
    end
end

function Combat:BulletTracers()
    if not Settings.Aimbot.Tracers then return end
    
    -- Tracer would hook into remote events (game-specific)
    -- Basic visual tracer system
    local function createTracer(from, to)
        local tracer = Instance.new("Part")
        tracer.Name = "Tracer"
        tracer.Size = Vector3.new(0.1, 0.1, (to - from).Magnitude)
        tracer.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -((to - from).Magnitude / 2))
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.Material = Enum.Material.Neon
        tracer.Color = Color3.fromRGB(255, 255, 100)
        tracer.Transparency = 0.3
        tracer.Parent = Workspace
        
        task.spawn(function()
            for i = 0, 10 do
                tracer.Transparency = 0.3 + (i * 0.07)
                task.wait(0.02)
            end
            tracer:Destroy()
        end)
    end
    
    -- Hook into weapon fire events would go here
    Settings.Aimbot._CreateTracer = createTracer
end

function Combat:HitMarkers()
    if not Settings.Aimbot.HitMarkers then return end
    
    -- Hit marker UI
    local ScreenGui = UI.ScreenGui
    local HitMarker = Instance.new("Frame")
    HitMarker.Name = "HitMarker"
    HitMarker.Size = UDim2.new(0, 30, 0, 30)
    HitMarker.Position = UDim2.new(0.5, -15, 0.5, -15)
    HitMarker.BackgroundTransparency = 1
    HitMarker.Visible = false
    HitMarker.Parent = ScreenGui
    
    local lines = {}
    for i = 1, 4 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 10, 0, 2)
        line.Position = UDim2.new(0.5, 0, 0.5, -1)
        line.BackgroundColor3 = Color3.new(1, 1, 1)
        line.BorderSizePixel = 0
        line.AnchorPoint = Vector2.new(1, 0.5)
        line.Parent = HitMarker
        line.Rotation = (i - 1) * 90
        table.insert(lines, line)
    end
    
    function Combat:ShowHitMarker()
        HitMarker.Visible = true
        for _, line in pairs(lines) do
            line.Position = UDim2.new(0.5, 0, 0.5, -1)
            line:TweenPosition(
                UDim2.new(0.5, 12, 0.5, -1),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.1,
                true
            )
        end
        task.wait(0.2)
        HitMarker.Visible = false
    end
    
    Settings.Aimbot._HitMarker = HitMarker
end

-- ========== VISUALS SYSTEM ==========
local Visuals = {}
local ESPItems = {}

function Visuals:CreateESP(player)
    if ESPItems[player.Name] then return end
    
    local ScreenGui = UI.ScreenGui
    
    -- Box container
    local Box = Instance.new("Frame")
    Box.Name = "ESP_"..player.Name
    Box.Size = UDim2.new(0, 0, 0, 0)
    Box.Position = UDim2.new(0, 0, 0, 0)
    Box.BackgroundTransparency = 1
    Box.Visible = false
    Box.Parent = ScreenGui
    
    -- 2D Box
    local Box2D = Instance.new("Frame")
    Box2D.Name = "Box2D"
    Box2D.Size = UDim2.new(0, 0, 0, 0)
    Box2D.BackgroundColor3 = Color3.new(1, 1, 1)
    Box2D.BackgroundTransparency = 0.5
    Box2D.BorderSizePixel = 1
    Box2D.BorderColor3 = Color3.new(1, 1, 1)
    Box2D.Visible = false
    Box2D.Parent = Box
    
    -- Health bar
    local HealthBar = Instance.new("Frame")
    HealthBar.Name = "HealthBar"
    HealthBar.Size = UDim2.new(0, 2, 0, 0)
    HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    HealthBar.BorderSizePixel = 0
    HealthBar.Visible = false
    HealthBar.Parent = Box
    
    -- Name label
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(0, 100, 0, 20)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = player.Name
    NameLabel.TextColor3 = Color3.new(1, 1, 1)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Center
    NameLabel.Visible = false
    NameLabel.Parent = Box
    
    -- Distance label
    local DistLabel = Instance.new("TextLabel")
    DistLabel.Name = "DistLabel"
    DistLabel.Size = UDim2.new(0, 100, 0, 20)
    DistLabel.BackgroundTransparency = 1
    DistLabel.Text = ""
    DistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    DistLabel.Font = Enum.Font.Gotham
    DistLabel.TextSize = 12
    DistLabel.TextXAlignment = Enum.TextXAlignment.Center
    DistLabel.Visible = false
    DistLabel.Parent = Box
    
    -- Offscreen arrow
    local Arrow = Instance.new("ImageLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://6885100073"
    Arrow.ImageColor3 = Color3.new(1, 1, 1)
    Arrow.Visible = false
    Arrow.Parent = Box
    
    -- Snapline
    local Snapline = Instance.new("Frame")
    Snapline.Name = "Snapline"
    Snapline.Size = UDim2.new(0, 1, 0, 0)
    Snapline.BackgroundColor3 = Color3.new(1, 1, 1)
    Snapline.BackgroundTransparency = 0.3
    Snapline.BorderSizePixel = 0
    Snapline.Visible = false
    Snapline.Parent = ScreenGui
    
    ESPItems[player.Name] = {
        Box = Box,
        Box2D = Box2D,
        HealthBar = HealthBar,
        NameLabel = NameLabel,
        DistLabel = DistLabel,
        Arrow = Arrow,
        Snapline = Snapline,
    }
end

function Visuals:UpdateESP()
    for playerName, esp in pairs(ESPItems) do
        local player = Players:FindFirstChild(playerName)
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
            esp.Box.Visible = false
            esp.Snapline.Visible = false
            esp.Arrow.Visible = false
            continue
        end
        
        local humanoid = player.Character.Humanoid
        if humanoid.Health <= 0 then
            esp.Box.Visible = false
            esp.Snapline.Visible = false
            esp.Arrow.Visible = false
            continue
        end
        
        if not Settings.Visuals.Enabled then
            esp.Box.Visible = false
            esp.Snapline.Visible = false
            esp.Arrow.Visible = false
            continue
        end
        
        local rootPart = player.Character.HumanoidRootPart
        local head = player.Character:FindFirstChild("Head") or rootPart
        local screenPos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
        local headPos, headOnScreen = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.5, 0))
        
        if onScreen then
            esp.Box.Visible = true
            esp.Box.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
        else
            esp.Box.Visible = false
        end
        
        -- 2D Box
        if Settings.Visuals.Boxes2D and onScreen then
            esp.Box2D.Visible = true
            esp.Box2D.Size = UDim2.new(0, 40, 0, 60)
            esp.Box2D.Position = UDim2.new(0, screenPos.X - 20, 0, screenPos.Y - 55)
        else
            esp.Box2D.Visible = false
        end
        
        -- Health bar
        if Settings.Visuals.Health and onScreen then
            esp.HealthBar.Visible = true
            esp.HealthBar.Size = UDim2.new(0, 2, 0, 60 * (humanoid.Health / humanoid.MaxHealth))
            esp.HealthBar.Position = UDim2.new(0, screenPos.X + 22, 0, screenPos.Y - 55)
            esp.HealthBar.BackgroundColor3 = Color3.fromHSV(humanoid.Health / humanoid.MaxHealth * 0.3, 1, 1)
        else
            esp.HealthBar.Visible = false
        end
        
        -- Name
        if Settings.Visuals.Names and onScreen then
            esp.NameLabel.Visible = true
            esp.NameLabel.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 70)
            
            -- Add flags
            local flags = ""
            if player:FindFirstChild("_IsTarget") then flags = flags.."🎯" end
            if player.Character:FindFirstChild("_IsFlying") then flags = flags.."✈️" end
            esp.NameLabel.Text = player.Name..flags
        else
            esp.NameLabel.Visible = false
        end
        
        -- Distance
        if Settings.Visuals.Distance and onScreen then
            esp.DistLabel.Visible = true
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude) or 0
            esp.DistLabel.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 50)
            esp.DistLabel.Text = math.floor(dist).."m"
        else
            esp.DistLabel.Visible = false
        end
        
        -- Offscreen arrows
        if Settings.Visuals.OffscreenArrows and not onScreen then
            esp.Arrow.Visible = true
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local dir = Vector2.new(screenPos.X, screenPos.Y) - screenCenter
            if dir.Magnitude > 0 then
                local angle = math.atan2(dir.Y, dir.X)
                local radius = 100
                local arrowPos = Vector2.new(
                    math.cos(angle) * radius + screenCenter.X,
                    math.sin(angle) * radius + screenCenter.Y
                )
                esp.Arrow.Position = UDim2.new(0, arrowPos.X - 10, 0, arrowPos.Y - 10)
                esp.Arrow.Rotation = math.deg(angle) + 90
            end
        else
            esp.Arrow.Visible = false
        end
        
        -- Snapline
        if Settings.Visuals.Snaplines and onScreen then
            esp.Snapline.Visible = true
            local screenBottom = Camera.ViewportSize.Y
            esp.Snapline.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            esp.Snapline.Size = UDim2.new(0, 1, 0, screenBottom - screenPos.Y)
        else
            esp.Snapline.Visible = false
        end
    end
end

function Visuals:Chams()
    -- Apply chams to all players
    local function applyChams(player)
        if not Settings.Visuals.Chams then return end
        
        local character = player.Character
        if not character then return end
        
        local function highlightPart(part)
            if part:IsA("BasePart") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "Cham"
                highlight.FillColor = Settings.Visuals.ChamFill
                highlight.OutlineColor = Settings.Visuals.ChamOutline
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = part
                
                -- Store material
                if Settings.Visuals.ChamMaterial then
                    part.Material = Settings.Visuals.ChamMaterial
                end
                
                part:GetPropertyChangedSignal("Parent"):Connect(function()
                    if not part.Parent then
                        highlight:Destroy()
                    end
                end)
            end
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                highlightPart(part)
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                applyChams(player)
            end
            player.CharacterAdded:Connect(function()
                applyChams(player)
            end)
        end
    end
end

function Visuals:Radar()
    if not Settings.Visuals.Radar then return end
    
    local ScreenGui = UI.ScreenGui
    
    local RadarFrame = Instance.new("Frame")
    RadarFrame.Name = "Radar"
    RadarFrame.Size = UDim2.new(0, 150, 0, 150)
    RadarFrame.Position = UDim2.new(Settings.Visuals.RadarPosition.X, 0, Settings.Visuals.RadarPosition.Y, 0)
    RadarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    RadarFrame.BackgroundTransparency = 0.5
    RadarFrame.BorderSizePixel = 0
    RadarFrame.Parent = ScreenGui
    
    local RadarCorner = Instance.new("UICorner")
    RadarCorner.CornerRadius = UDim.new(1, 0)
    RadarCorner.Parent = RadarFrame
    
    local RadarDot = Instance.new("Frame")
    RadarDot.Name = "LocalDot"
    RadarDot.Size = UDim2.new(0, 4, 0, 4)
    RadarDot.Position = UDim2.new(0.5, -2, 0.5, -2)
    RadarDot.BackgroundColor3 = Color3.new(1, 1, 1)
    RadarDot.BorderSizePixel = 0
    RadarDot.Parent = RadarFrame
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = RadarDot
    
    local function updateRadar()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local dot = RadarFrame:FindFirstChild("Dot_"..player.Name)
                if not dot and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    dot = Instance.new("Frame")
                    dot.Name = "Dot_"..player.Name
                    dot.Size = UDim2.new(0, 6, 0, 6)
                    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    dot.BorderSizePixel = 0
                    dot.Parent = RadarFrame
                    
                    local dotCorner = Instance.new("UICorner")
                    dotCorner.CornerRadius = UDim.new(1, 0)
                    dotCorner.Parent = dot
                end
                
                if dot and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local localPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local playerPos = player.Character.HumanoidRootPart.Position
                    local diff = playerPos - localPos
                    
                    local radarRange = 100 * Settings.Visuals.RadarZoom
                    local relX = (diff.X / radarRange) * 75 + 75
                    local relZ = (diff.Z / radarRange) * 75 + 75
                    
                    dot.Position = UDim2.new(0, relX - 3, 0, relZ - 3)
                    dot.Visible = true
                elseif dot then
                    dot.Visible = false
                end
            end
        end
    end
    
    RunService.RenderStepped:Connect(updateRadar)
end

function Visuals:CustomCrosshair()
    if not Settings.Visuals.CustomCrosshair then return end
    
    local ScreenGui = UI.ScreenGui
    
    local Crosshair = Instance.new("Frame")
    Crosshair.Name = "CustomCrosshair"
    Crosshair.Size = UDim2.new(0, 20, 0, 20)
    Crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
    Crosshair.BackgroundTransparency = 1
    Crosshair.Parent = ScreenGui
    
    -- Animated crosshair
    local lines = {}
    for i = 1, 4 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 8, 0, 2)
        line.Position = UDim2.new(0.5, 0, 0.5, -1)
        line.BackgroundColor3 = UI.Theme.Accent
        line.BorderSizePixel = 0
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Rotation = (i - 1) * 90
        line.Parent = Crosshair
        table.insert(lines, line)
    end
    
    local function animate()
        while true do
            for i, line in pairs(lines) do
                line:TweenPosition(
                    UDim2.new(0.5, math.cos(tick() * 2 + i * 1.57) * 5, 0.5, math.sin(tick() * 2 + i * 1.57) * 5),
                    Enum.EasingDirection.InOut,
                    Enum.EasingStyle.Sine,
                    0.1,
                    true
                )
            end
            task.wait(0.1)
        end
    end
    
    task.spawn(animate)
end

-- ========== MOVEMENT SYSTEM ==========
local Movement = {}

function Movement:Fly()
    if not Settings.Movement.Fly then return end
    
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    local flySpeed = Settings.Movement.FlySpeed
    local damping = Settings.Movement.FlyDamping
    
    local bodyVelocity = rootPart:FindFirstChild("FlyVelocity")
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = rootPart
    end
    
    local bodyGyro = rootPart:FindFirstChild("FlyGyro")
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "FlyGyro"
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.Parent = rootPart
    end
    
    -- Set flag for ESP
    character:SetAttribute("_IsFlying", true)
    
    local function updateFly()
        local direction = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
            direction = direction + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
            direction = direction - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
            direction = direction - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
            direction = direction + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit
            bodyVelocity.Velocity = direction * flySpeed
        else
            bodyVelocity.Velocity = bodyVelocity.Velocity * damping
        end
        
        bodyGyro.CFrame = Camera.CFrame
    end
    
    RunService.RenderStepped:Connect(updateFly)
end

function Movement:BunnyHop()
    if not Settings.Movement.BunnyHop then return end
    
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    
    if not humanoid then return end
    
    if humanoid:GetState() == Enum.HumanoidStateType.Running or humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid.Jump = true
        end
    end
end

function Movement:Noclip()
    if not Settings.Movement.Noclip then return end
    
    local character = LocalPlayer.Character
    
    local function noclipParts()
        if not character then return end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    noclipParts()
    
    character.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end)
    
    character.ChildAdded:Connect(function(child)
        task.spawn(noclipParts)
    end)
end

function Movement:Desync()
    if not Settings.Movement.Desync then return end
    
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end
    
    -- Desync marker (visual)
    if Settings.Movement.DesyncMarker then
        local marker = Instance.new("Part")
        marker.Name = "DesyncMarker"
        marker.Size = Vector3.new(2, 2, 2)
        marker.Position = rootPart.Position
        marker.Anchored = true
        marker.CanCollide = false
        marker.Transparency = 0.7
        marker.Color = Color3.fromRGB(255, 0, 255)
        marker.Material = Enum.Material.Neon
        marker.Parent = Workspace
        
        task.spawn(function()
            task.wait(5)
            marker:Destroy()
        end)
    end
    
    -- Desync offset (game-specific implementation)
    -- This would manipulate network ownership and position replication
    Settings.Movement._DesyncActive = true
end

-- ========== WORLD SYSTEM ==========
local World = {}

function World:ApplyLighting()
    local lighting = Lighting
    
    lighting.Ambient = Settings.World.AmbientColor
    lighting.OutdoorAmbient = Settings.World.OutdoorColor
    lighting.Brightness = Settings.World.Brightness
    lighting.GlobalShadows = true
    
    -- Exposure (via ColorCorrection)
    local colorCorrection = lighting:FindFirstChild("NyxColorCorrection")
    if not colorCorrection then
        colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "NyxColorCorrection"
        colorCorrection.Parent = lighting
    end
    colorCorrection.Brightness = Settings.World.Brightness / 2
    colorCorrection.Contrast = 0.1
    
    -- Sky color shifting
    if Settings.World.SkyColorShift then
        RunService.RenderStepped:Connect(function()
            local hue = (tick() % 30) / 30
            lighting.Ambient = Color3.fromHSV(hue, 0.5, 0.5)
            lighting.OutdoorAmbient = Color3.fromHSV(hue, 0.3, 0.7)
        end)
    end
end

function World:ApplyFog()
    local lighting = Lighting
    
    lighting.FogColor = Settings.World.FogColor
    lighting.FogStart = Settings.World.FogStart
    lighting.FogEnd = Settings.World.FogEnd
    
    -- Atmosphere
    local atmosphere = lighting:FindFirstChild("NyxAtmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "NyxAtmosphere"
        atmosphere.Parent = lighting
    end
    atmosphere.Density = 0.1
    atmosphere.Color = Settings.World.FogColor
end

function World:CustomSkybox()
    if not Settings.World.CustomSkybox then return end
    
    local sky = Instance.new("Sky")
    sky.Name = "NyxSkybox"
    sky.SkyboxBk = "rbxassetid://"..(Settings.World.SunTexture or "6444320592")
    sky.SkyboxDn = "rbxassetid://"..(Settings.World.SunTexture or "6444320592")
    sky.SkyboxFt = "rbxassetid://"..(Settings.World.SunTexture or "6444320592")
    sky.SkyboxLf = "rbxassetid://"..(Settings.World.SunTexture or "6444320592")
    sky.SkyboxRt = "rbxassetid://"..(Settings.World.SunTexture or "6444320592")
    sky.SkyboxUp = "rbxassetid://"..(Settings.World.SunTexture or "6444320592")
    sky.StarCount = Settings.World.Stars and 3000 or 0
    sky.SunTextureId = "rbxassetid://"..(Settings.World.SunTexture or "6444320592")
    sky.MoonTextureId = "rbxassetid://"..(Settings.World.MoonTexture or "6444320592")
    sky.Parent = Lighting
end

function World:WeaponAppearance()
    if not Settings.World.WeaponAppearance then return end
    
    -- Would hook into viewmodel (game-specific)
    -- Basic implementation for common games
    local function applyWeaponColor()
        if LocalPlayer.Character then
            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, part in pairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Settings.World.WeaponColor
                        end
                    end
                end
            end
        end
    end
    
    LocalPlayer.CharacterAdded:Connect(function()
        task.spawn(applyWeaponColor)
    end)
    
    if LocalPlayer.Character then
        applyWeaponColor()
    end
end

-- ========== UTILITIES ==========
local Utilities = {}

function Utilities:SaveConfig()
    local config = {
        Settings = Settings,
        Keybinds = Config.Keybinds,
    }
    
    if writefile then
        writefile("nyxhub_config.json", game:GetService("HttpService"):JSONEncode(config))
        UI:Notify("Config", "Saved to nyxhub_config.json")
    else
        -- Fallback: store in Instance
        local configStore = Instance.new("StringValue")
        configStore.Name = "NyxConfig"
        configStore.Value = game:GetService("HttpService"):JSONEncode(config)
        configStore.Parent = LocalPlayer
        UI:Notify("Config", "Saved to LocalPlayer")
    end
end

function Utilities:LoadConfig()
    if readfile and isfile and isfile("nyxhub_config.json") then
        local config = game:GetService("HttpService"):JSONDecode(readfile("nyxhub_config.json"))
        if config.Settings then
            for key, value in pairs(config.Settings) do
                Settings[key] = value
            end
        end
        if config.Keybinds then
            Config.Keybinds = config.Keybinds
        end
        UI:Notify("Config", "Loaded from file")
    else
        UI:Notify("Config", "No config file found")
    end
end

function Utilities:InstanceExplorer()
    -- Simple instance explorer
    local explorerData = {}
    
    local function explore(parent, depth)
        if depth > 5 then return end
        
        for _, child in pairs(parent:GetChildren()) do
            table.insert(explorerData, {
                Name = child.Name,
                Class = child.ClassName,
                Depth = depth,
                Instance = child,
            })
            explore(child, depth + 1)
        end
    end
    
    explore(Workspace, 0)
    
    return explorerData
end

function Utilities:LuaExecutor()
    -- Integrated Lua scripting
    if not getgenv then return end
    
    -- Create a basic executor
    getgenv().execute = function(code)
        local func, err = loadstring(code)
        if func then
            local success, result = pcall(func)
            if success then
                return result
            else
                return "Error: "..tostring(result)
            end
        else
            return "Syntax Error: "..tostring(err)
        end
    end
end

function Utilities:AutoOffset()
    if not Settings.UI.AutoOffset then return end
    
    local function updateOffset()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            local offset = rootPart.Velocity * 0.13
            rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity + offset
        end
    end
    
    RunService.Stepped:Connect(updateOffset)
end

-- ========== MAIN INITIALIZATION ==========
local function Init()
    -- Create UI
    UI:CreateWindow("NYX HUB")
    
    -- Combat Tab
    local CombatTab = UI:CreateTab("Combat", "⚔")
    
    local AimbotSection = CombatTab:CreateSection("Aimbot")
    CombatTab:CreateToggle("Enable Aimbot", false, function(val)
        Settings.Aimbot.Enabled = val
        if val then
            RunService.RenderStepped:Connect(Combat.Aimbot)
        end
    end)
    
    CombatTab:CreateDropdown("Hitbox", {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, "Head", function(val)
        Settings.Aimbot.Hitbox = val
    end)
    
    CombatTab:CreateSlider("Smoothing", 0, 1, 0.35, function(val)
        Settings.Aimbot.Smoothing = val
    end)
    
    CombatTab:CreateSlider("Prediction", 0, 1, 0.13, function(val)
        Settings.Aimbot.Prediction = val
    end)
    
    CombatTab:CreateSlider("FOV", 0, 500, 180, function(val)
        Settings.Aimbot.FOV = val
    end)
    
    CombatTab:CreateSlider("Distance Limit", 0, 2000, 500, function(val)
        Settings.Aimbot.DistanceLimit = val
    end)
    
    CombatTab:CreateToggle("Sticky Target", true, function(val)
        Settings.Aimbot.StickyTarget = val
    end)
    
    local SilentAimSection = CombatTab:CreateSection("Silent Aim")
    CombatTab:CreateToggle("Silent Aim", false, function(val)
        Settings.Aimbot.SilentAim = val
    end)
    
    CombatTab:CreateToggle("Free Aim", false, function(val)
        Settings.Aimbot.FreeAim = val
    end)
    
    local TriggerbotSection = CombatTab:CreateSection("Triggerbot")
    CombatTab:CreateToggle("Triggerbot", false, function(val)
        Settings.Aimbot.Triggerbot = val
        if val then
            RunService.RenderStepped:Connect(Combat.Triggerbot)
        end
    end)
    
    CombatTab:CreateSlider("Trigger Delay", 0, 1, 0.1, function(val)
        Settings.Aimbot.TriggerDelay = val
    end)
    
    CombatTab:CreateToggle("Hold to Fire", false, function(val)
        Settings.Aimbot.HoldToFire = val
    end)
    
    local CombatVisualSection = CombatTab:CreateSection("Combat Visuals")
    CombatTab:CreateToggle("Bullet Tracers", true, function(val)
        Settings.Aimbot.Tracers = val
    end)
    
    CombatTab:CreateToggle("Hit Markers", true, function(val)
        Settings.Aimbot.HitMarkers = val
        if val then
            Combat:HitMarkers()
        end
    end)
    
    CombatTab:CreateToggle("Hit Logs", true, function(val)
        Settings.Aimbot.HitLogs = val
    end)
    
    -- Visuals Tab
    local VisualsTab = UI:CreateTab("Visuals", "👁")
    
    local ESPSection = VisualsTab:CreateSection("ESP")
    VisualsTab:CreateToggle("Enable ESP", false, function(val)
        Settings.Visuals.Enabled = val
    end)
    
    VisualsTab:CreateToggle("2D Boxes", true, function(val)
        Settings.Visuals.Boxes2D = val
    end)
    
    VisualsTab:CreateToggle("3D Boxes", false, function(val)
        Settings.Visuals.Boxes3D = val
    end)
    
    VisualsTab:CreateToggle("Skeleton", true, function(val)
        Settings.Visuals.Skeleton = val
    end)
    
    VisualsTab:CreateToggle("Names", true, function(val)
        Settings.Visuals.Names = val
    end)
    
    VisualsTab:CreateToggle("Health", true, function(val)
        Settings.Visuals.Health = val
    end)
    
    VisualsTab:CreateToggle("Distance", true, function(val)
        Settings.Visuals.Distance = val
    end)
    
    VisualsTab:CreateToggle("Flags", true, function(val)
        Settings.Visuals.Flags = val
    end)
    
    local ChamSection = VisualsTab:CreateSection("Chams")
    VisualsTab:CreateToggle("Enable Chams", true, function(val)
        Settings.Visuals.Chams = val
        if val then
            Visuals:Chams()
        end
    end)
    
    VisualsTab:CreateDropdown("Material", {"ForceField", "Neon", "Glass", "Plastic", "SmoothPlastic"}, "ForceField", function(val)
        Settings.Visuals.ChamMaterial = Enum.Material[val]
    end)
    
    local OtherVisualSection = VisualsTab:CreateSection("Other Visuals")
    VisualsTab:CreateToggle("Offscreen Arrows", true, function(val)
        Settings.Visuals.OffscreenArrows = val
    end)
    
    VisualsTab:CreateToggle("Snaplines", true, function(val)
        Settings.Visuals.Snaplines = val
    end)
    
    VisualsTab:CreateToggle("China Hat", false, function(val)
        Settings.Visuals.ChinaHat = val
    end)
    
    VisualsTab:CreateToggle("Grenade Radius", true, function(val)
        Settings.Visuals.GrenadeRadius = val
    end)
    
    VisualsTab:CreateToggle("Fuse Indicator", true, function(val)
        Settings.Visuals.FuseIndicator = val
    end)
    
    VisualsTab:CreateToggle("Custom Crosshair", true, function(val)
        Settings.Visuals.CustomCrosshair = val
        if val then
            Visuals:CustomCrosshair()
        end
    end)
    
    VisualsTab:CreateToggle("2D Radar", true, function(val)
        Settings.Visuals.Radar = val
        if val then
            Visuals:Radar()
        end
    end)
    
    VisualsTab:CreateSlider("Radar Zoom", 0.5, 3, 1, function(val)
        Settings.Visuals.RadarZoom = val
    end)
    
    -- Movement Tab
    local MovementTab = UI:CreateTab("Movement", "🏃")
    
    local FlySection = MovementTab:CreateSection("Fly")
    MovementTab:CreateToggle("Enable Fly", false, function(val)
        Settings.Movement.Fly = val
        if val then
            Movement:Fly()
        end
    end)
    
    MovementTab:CreateSlider("Fly Speed", 10, 200, 50, function(val)
        Settings.Movement.FlySpeed = val
    end)
    
    MovementTab:CreateSlider("Damping", 0.5, 1, 0.95, function(val)
        Settings.Movement.FlyDamping = val
    end)
    
    local OtherMovementSection = MovementTab:CreateSection("Other")
    MovementTab:CreateSlider("Walkspeed", 1, 100, 16, function(val)
        Settings.Movement.Walkspeed = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end)
    
    MovementTab:CreateToggle("Bunny Hop", false, function(val)
        Settings.Movement.BunnyHop = val
        if val then
            RunService.RenderStepped:Connect(Movement.BunnyHop)
        end
    end)
    
    MovementTab:CreateToggle("Noclip", false, function(val)
        Settings.Movement.Noclip = val
        if val then
            Movement:Noclip()
        end
    end)
    
    MovementTab:CreateToggle("Desync", false, function(val)
        Settings.Movement.Desync = val
        if val then
            Movement:Desync()
        end
    end)
    
    MovementTab:CreateToggle("Desync Marker", false, function(val)
        Settings.Movement.DesyncMarker = val
    end)
    
    -- World Tab
    local WorldTab = UI:CreateTab("World", "🌍")
    
    local LightingSection = WorldTab:CreateSection("Lighting")
    WorldTab:CreateSlider("Brightness", 0, 5, 2, function(val)
        Settings.World.Brightness = val
        World:ApplyLighting()
    end)
    
    WorldTab:CreateSlider("Exposure", 0, 3, 1, function(val)
        Settings.World.Exposure = val
        World:ApplyLighting()
    end)
    
    WorldTab:CreateToggle("Sky Color Shift", false, function(val)
        Settings.World.SkyColorShift = val
        if val then
            World:ApplyLighting()
        end
    end)
    
    local FogSection = WorldTab:CreateSection("Fog")
    WorldTab:CreateSlider("Fog Start", 0, 500, 100, function(val)
        Settings.World.FogStart = val
        World:ApplyFog()
    end)
    
    WorldTab:CreateSlider("Fog End", 100, 2000, 500, function(val)
        Settings.World.FogEnd = val
        World:ApplyFog()
    end)
    
    local SkyboxSection = WorldTab:CreateSection("Skybox")
    WorldTab:CreateToggle("Custom Skybox", false, function(val)
        Settings.World.CustomSkybox = val
        if val then
            World:CustomSkybox()
        end
    end)
    
    WorldTab:CreateToggle("Stars", true, function(val)
        Settings.World.Stars = val
    end)
    
    WorldTab:CreateTextbox("Sun Texture ID", "Asset ID", function(val)
        Settings.World.SunTexture = val
    end)
    
    WorldTab:CreateTextbox("Moon Texture ID", "Asset ID", function(val)
        Settings.World.MoonTexture = val
    end)
    
    local WeaponSection = WorldTab:CreateSection("Weapon Appearance")
    WorldTab:CreateToggle("Weapon Appearance", false, function(val)
        Settings.World.WeaponAppearance = val
        if val then
            World:WeaponAppearance()
        end
    end)
    
    -- Utilities Tab
    local UtilitiesTab = UI:CreateTab("Utilities", "🔧")
    
    local ConfigSection = UtilitiesTab:CreateSection("Config")
    UtilitiesTab:CreateButton("Save Config", function()
        Utilities:SaveConfig()
    end)
    
    UtilitiesTab:CreateButton("Load Config", function()
        Utilities:LoadConfig()
    end)
    
    local ScriptSection = UtilitiesTab:CreateSection("Scripting")
    local scriptBox = UtilitiesTab:CreateTextbox("Lua Script", "Enter code", function(code)
        if Utilities.execute then
            local result = Utilities.execute(code)
            UI:Notify("Script", tostring(result))
        end
    end)
    
    UtilitiesTab:CreateButton("Execute Script", function()
        local code = scriptBox.GetValue()
        if Utilities.execute and code and code ~= "" then
            local result = Utilities.execute(code)
            UI:Notify("Script", tostring(result))
        end
    end)
    
    local UISection = UtilitiesTab:CreateSection("UI Settings")
    UtilitiesTab:CreateToggle("Auto Offset", true, function(val)
        Settings.UI.AutoOffset = val
        if val then
            Utilities:AutoOffset()
        end
    end)
    
    UtilitiesTab:CreateToggle("Watermark", true, function(val)
        Settings.UI.Watermark = val
        UI:Watermark()
    end)
    
    UtilitiesTab:CreateToggle("Stream-Proof Mode", false, function(val)
        Settings.UI.StreamProof = val
    end)
    
    -- Keybind Manager
    local KeybindSection = UtilitiesTab:CreateSection("Keybinds")
    UtilitiesTab:CreateButton("Add Keybind (Press Key)", function()
        UI:Notify("Keybinds", "Click a key to bind")
        
        local keybindConnection
        keybindConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                Config.Keybinds[#Config.Keybinds + 1] = {
                    Key = input.KeyCode.Name,
                    Action = "None",
                }
                UI:Notify("Keybind", "Bound to "..input.KeyCode.Name)
                keybindConnection:Disconnect()
            end
        end)
    end)
    
    -- Initialize systems
    Combat:BulletTracers()
    Utilities:LuaExecutor()
    Utilities:AutoOffset()
    UI:Watermark()
    
    -- Player tracking for ESP
    Players.PlayerAdded:Connect(function(player)
        Visuals:CreateESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ESPItems[player.Name] = nil
    end)
    
    -- Initialize ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            Visuals:CreateESP(player)
        end
    end
    
    -- Main render loop
    RunService.RenderStepped:Connect(function()
        Combat:Aimbot()
        Combat:Triggerbot()
        Visuals:UpdateESP()
    end)
    
    -- Character added handler
    LocalPlayer.CharacterAdded:Connect(function()
        -- Reinitialize movement
        if Settings.Movement.Fly then
            Movement:Fly()
        end
        if Settings.Movement.Noclip then
            Movement:Noclip()
        end
        -- Reinitialize ESP
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                Visuals:CreateESP(player)
            end
        end
    end)
    
    UI:Notify("NYX HUB", "Loaded successfully!", 3)
end

-- Start
Init()