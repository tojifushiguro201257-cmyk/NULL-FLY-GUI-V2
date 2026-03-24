-- NULL FLY GUI - EDICIÓN SUPREMA (Velocidad 5000)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variables de Estado
local flying = false
local speed = 50 
local maxSpeed = 5000 -- Límite de 5000
local minSpeed = 0

-- UI Setup (Estilo Clásico 2014)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NullFlyGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 150)
MainFrame.Position = UDim2.new(0.5, -200, 0.3, -75)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(1, 1, 1)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "  NULL FLY GUI"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.TextSize = 25
MinimizeBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, 0, 1, -30)
ControlsFrame.Position = UDim2.new(0, 0, 0, 30)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Parent = MainFrame

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0, 120, 0, 35) -- Un poco más ancho para el número 5000
SpeedBox.Position = UDim2.new(0.5, -60, 0, 10)
SpeedBox.BackgroundColor3 = Color3.new(0, 0, 0)
SpeedBox.BorderColor3 = Color3.new(1, 1, 1)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.Text = tostring(speed)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 22
SpeedBox.Parent = ControlsFrame

local function createNavBtn(txt, pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 40, 0, 40)
    b.Position = pos
    b.BackgroundColor3 = Color3.new(0, 0, 0)
    b.BorderColor3 = Color3.new(1, 1, 1)
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 25
    b.Parent = ControlsFrame
    return b
end

local MinusBtn = createNavBtn("-", UDim2.new(0.5, -110, 0, 7))
local PlusBtn = createNavBtn("+", UDim2.new(0.5, 70, 0, 7))

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 50)
ToggleBtn.Position = UDim2.new(0.5, -100, 0, 60)
ToggleBtn.BackgroundColor3 = Color3.new(1, 1, 1)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.new(0, 0, 0)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 24
ToggleBtn.Parent = ControlsFrame

--- MOTOR DE VUELO DE ALTA POTENCIA ---

local bv, bg
local flyConn

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
    ToggleBtn.Text = "OFF"
    ToggleBtn.BackgroundColor3 = Color3.new(1, 1, 1)
end

local function startFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera
    
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 30000 -- Fuerza de giro aumentada para estabilidad extrema
    bg.D = 800
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    hum.PlatformStand = true
    
    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not hrp.Parent then
            stopFly()
            return
        end
        
        local md = hum.MoveDirection
        if md.Magnitude > 0 then
            local look = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            -- Lógica 3D pura
            local moveDir = (look * -camera.CFrame:VectorToObjectSpace(md).Z) + (right * camera.CFrame:VectorToObjectSpace(md).X)
            bv.Velocity = moveDir.Unit * speed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        bg.CFrame = camera.CFrame
    end)
end

-- Handlers de Velocidad (Saltos de 50)
PlusBtn.MouseButton1Click:Connect(function()
    speed = math.min(speed + 50, maxSpeed)
    SpeedBox.Text = tostring(speed)
end)

MinusBtn.MouseButton1Click:Connect(function()
    speed = math.max(speed - 50, minSpeed)
    SpeedBox.Text = tostring(speed)
end)

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        speed = math.clamp(val, minSpeed, maxSpeed)
    end
    SpeedBox.Text = tostring(speed)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.new(0.95, 0.95, 0.95)
        startFly()
    else
        stopFly()
    end
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ControlsFrame.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 400, 0, 30) or UDim2.new(0, 400, 0, 150)
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopFly()
    ScreenGui:Destroy()
end)
