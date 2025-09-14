--[[ 
    Script: arquia Hub
    Função: Clone Flor (tapete clone toggle)
    Fix: toggle ON/OFF, plataforma invisível para reduzir pullback do server
    by: izanax111
]]

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "arquiaHub"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 150, 0, 60)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -10, 1, -10)
ToggleButton.Position = UDim2.new(0, 5, 0, 5)
ToggleButton.Text = "🌸 Clone: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.Arcade
ToggleButton.TextSize = 16
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
ToggleButton.Parent = Frame
ToggleButton.BorderSizePixel = 0

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 8)
UICornerBtn.Parent = ToggleButton

-- Estado
local running = false
local conn
local supportPart

-- Função para pegar clone do Quantum Cloner
local function getClone()
    return workspace:FindFirstChild(player.UserId .. "_Clone")
end

-- Criar suporte invisível
local function createSupport()
    local part = Instance.new("Part")
    part.Size = Vector3.new(6, 1, 6)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 1
    part.Name = "CloneSupport"
    part.Parent = workspace
    return part
end

-- Toggle
ToggleButton.MouseButton1Click:Connect(function()
    running = not running

    if running then
        ToggleButton.Text = "🌸 Clone: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 60, 20)

        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")

        local clone = getClone()
        if not clone or not clone:FindFirstChild("HumanoidRootPart") then
            warn("⚠️ Clone não encontrado! Use o item Quantum Cloner primeiro.")
            running = false
            ToggleButton.Text = "🌸 Clone: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
            return
        end

        local rootClone = clone.HumanoidRootPart

        -- Desliga humanoid do clone
        local humanoid = clone:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:Destroy() end

        -- Suporte invisível
        supportPart = createSupport()

        -- Loop
        conn = runService.Heartbeat:Connect(function()
            if running and root and rootClone and supportPart then
                local underFeet = root.Position - Vector3.new(0, root.Size.Y/2 + 2, 0)

                -- suporte segue
                supportPart.CFrame = CFrame.new(underFeet - Vector3.new(0, 2, 0))

                -- clone sempre puxado pro suporte (não mexemos direto no playerRoot)
                rootClone.CFrame = supportPart.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            end
        end)

    else
        ToggleButton.Text = "🌸 Clone: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 20, 20)

        if conn then
            conn:Disconnect()
            conn = nil
        end
        if supportPart then
            supportPart:Destroy()
            supportPart = nil
        end
    end
end)
