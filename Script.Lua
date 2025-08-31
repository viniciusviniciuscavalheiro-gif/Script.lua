local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local savedPosition = nil
local MENU_KEY = "yoku1"

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Botão vermelho para abrir menu via key
local OpenMenuBtn = Instance.new("TextButton")
OpenMenuBtn.Size = UDim2.new(0, 100, 0, 50)
OpenMenuBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
OpenMenuBtn.Text = "Abrir Menu"
OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
OpenMenuBtn.TextColor3 = Color3.fromRGB(255,255,255)
OpenMenuBtn.Parent = ScreenGui

-- Frame do menu
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 250, 0, 300)
MenuFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MenuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Menu Yoku Hub"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true
Title.Parent = MenuFrame

-- Label de contador/feedback
local CountdownLabel = Instance.new("TextLabel")
CountdownLabel.Size = UDim2.new(1, 0, 0, 30)
CountdownLabel.Position = UDim2.new(0,0,0.85,0)
CountdownLabel.BackgroundTransparency = 1
CountdownLabel.TextColor3 = Color3.new(1,0,0)
CountdownLabel.TextScaled = true
CountdownLabel.Parent = MenuFrame

-- Botões do menu
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.8, 0, 0, 40)
SaveBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
SaveBtn.Text = "Salvar Posição"
SaveBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
SaveBtn.TextColor3 = Color3.fromRGB(255,255,255)
SaveBtn.Parent = MenuFrame

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Size = UDim2.new(0.8, 0, 0, 40)
TeleportBtn.Position = UDim2.new(0.1,0,0.45,0)
TeleportBtn.Text = "Teleportar + Taser"
TeleportBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
TeleportBtn.TextColor3 = Color3.fromRGB(255,255,255)
TeleportBtn.Parent = MenuFrame

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.3,0,0,30)
CloseBtn.Position = UDim2.new(0.35,0,0.7,0)
CloseBtn.Text = "Fechar"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Parent = MenuFrame

CloseBtn.MouseButton1Click:Connect(function()
	MenuFrame.Visible = false
end)

-- Funções
local function TeleportInSteps(targetPos, steps)
	local startPos = root.Position
	for i = 1, steps do
		local alpha = i / steps
		local nextPos = startPos:Lerp(targetPos, alpha)
		root.CFrame = CFrame.new(nextPos)
		task.wait(0.1)
	end
end

local function FireTaser()
	local backpack = player:WaitForChild("Backpack")
	local taser = backpack:FindFirstChild("Taser Gun") or char:FindFirstChild("Taser Gun")
	if not taser then
		CountdownLabel.Text = "Taser não encontrada!"
		task.wait(1.5)
		CountdownLabel.Text = ""
		return
	end

	taser.Parent = char
	task.wait(0.05)

	local head = char:FindFirstChild("Head")
	if head then
		if taser:FindFirstChild("Activate") then
			taser:Activate()
		end

		local Packages = ReplicatedStorage:WaitForChild("Packages")
		local Net = require(Packages.Net)
		Net:RemoteEvent("UseItem"):FireServer(head, true)
	end
end

-- Botão Salvar
SaveBtn.MouseButton1Click:Connect(function()
	savedPosition = root.Position
	CountdownLabel.Text = "Posição salva!"
	task.wait(1)
	CountdownLabel.Text = ""
end)

-- Botão Teleport + Taser
TeleportBtn.MouseButton1Click:Connect(function()
	if not savedPosition then
		CountdownLabel.Text = "Nenhuma posição salva!"
		task.wait(1.5)
		CountdownLabel.Text = ""
		return
	end

	-- Cronômetro 3 segundos
	for i = 3,1,-1 do
		CountdownLabel.Text = "Preparando Taser em "..i
		task.wait(1)
	end
	CountdownLabel.Text = ""

	-- Dispara Taser primeiro
	FireTaser()
	CountdownLabel.Text = "Taser disparada!"
	task.wait(0.2)

	-- Teleporte em etapas
	TeleportInSteps(savedPosition,5)
	CountdownLabel.Text = "Teleport concluído!"
	task.wait(1)
	CountdownLabel.Text = ""
end)

-- Sistema de Key para abrir menu
OpenMenuBtn.MouseButton1Click:Connect(function()
	local input = player:PromptInput("Digite a Key para abrir o menu:", "")
	if input == MENU_KEY then
		MenuFrame.Visible = true
	else
		CountdownLabel.Text = "Key incorreta!"
		task.wait(1.5)
		CountdownLabel.Text = ""
	end
end)
