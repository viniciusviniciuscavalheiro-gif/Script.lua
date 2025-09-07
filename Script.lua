--// Fly Seguro com Rotação Natural (Celular)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- Configurações
local flying = false
local speed = 1
local bodyVel = nil
local tool = nil
local spamTask = nil
local bodyGyro = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0.35, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🚀 Fly Hook"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Frame

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.8, 0, 0, 40)
Button.Position = UDim2.new(0.1, 0, 0.3, 0)
Button.Text = "Fly: OFF"
Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 18
Button.Parent = Frame
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 10)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.Position = UDim2.new(0, 0, 0.65, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Velocidade: " .. speed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 16
SpeedLabel.Parent = Frame

local Minus = Instance.new("TextButton")
Minus.Size = UDim2.new(0, 40, 0, 30)
Minus.Position = UDim2.new(0.15, 0, 0.85, 0)
Minus.Text = "-"
Minus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Minus.TextColor3 = Color3.fromRGB(255, 255, 255)
Minus.Font = Enum.Font.GothamBold
Minus.TextSize = 20
Minus.Parent = Frame
Instance.new("UICorner", Minus).CornerRadius = UDim.new(0, 8)

local Plus = Instance.new("TextButton")
Plus.Size = UDim2.new(0, 40, 0, 30)
Plus.Position = UDim2.new(0.65, 0, 0.85, 0)
Plus.Text = "+"
Plus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Plus.TextColor3 = Color3.fromRGB(255, 255, 255)
Plus.Font = Enum.Font.GothamBold
Plus.TextSize = 20
Plus.Parent = Frame
Instance.new("UICorner", Plus).CornerRadius = UDim.new(0, 8)

-- Função de spam automático do Grapple Hook
local function startSpam()
	if tool then
		spamTask = RunService.RenderStepped:Connect(function()
			if tool and tool:FindFirstChild("Activated") then
				tool.Activated:Fire()
			end
		end)
	end
end

local function stopSpam()
	if spamTask then
		spamTask:Disconnect()
		spamTask = nil
	end
end

-- Função de fly
local function toggleFly()
	flying = not flying
	Button.Text = flying and "Fly: ON" or "Fly: OFF"

	if flying then
		-- Equipar Grapple Hook sem remover do inventário
		tool = Backpack:FindFirstChild("Grapple Hook") or Character:FindFirstChild("Grapple Hook")
		if tool and tool.Parent ~= Character then
			tool.Parent = Character
		end

		-- Criar BodyVelocity para voo
		if not bodyVel then
			bodyVel = Instance.new("BodyVelocity")
			bodyVel.Name = "FlightPower"
			bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bodyVel.P = 2000
			bodyVel.Parent = HRP
		end

		-- Criar BodyGyro para rotação natural (baixa força)
		if not bodyGyro then
			bodyGyro = Instance.new("BodyGyro")
			bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000) -- baixa força
			bodyGyro.P = 500
			bodyGyro.D = 2
			bodyGyro.Parent = HRP
		end

		-- Começa o spam do Grapple Hook
		startSpam()
	else
		-- Desliga BodyVelocity
		if bodyVel then
			bodyVel:Destroy()
			bodyVel = nil
		end

		-- Desliga BodyGyro
		if bodyGyro then
			bodyGyro:Destroy()
			bodyGyro = nil
		end

		-- Para o spam
		stopSpam()
	end
end

Button.MouseButton1Click:Connect(toggleFly)

-- Ajuste de velocidade incremental
Plus.MouseButton1Click:Connect(function()
	speed = speed + 1
	SpeedLabel.Text = "Velocidade: " .. speed
end)

Minus.MouseButton1Click:Connect(function()
	if speed > 1 then
		speed = speed - 1
		SpeedLabel.Text = "Velocidade: " .. speed
	end
end)

-- Loop de movimento e rotação
RunService.RenderStepped:Connect(function()
	if flying and bodyVel and bodyGyro then
		local cam = workspace.CurrentCamera

		-- Movimento
		bodyVel.Velocity = cam.CFrame.LookVector * speed

		-- Rotação suave seguindo a câmera
		local lookVector = cam.CFrame.LookVector
		local targetCFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
		bodyGyro.CFrame = targetCFrame
	end
end)
