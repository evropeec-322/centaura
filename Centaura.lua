-- // Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- // Settings
local ESPEnabled = false
local AimbotEnabled = false
local AimbotKey = Enum.KeyCode.E
local AimbotFOV = 150
local TargetPart = "Head"
local TeamCheck = true

-- // GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ESP_Aimbot_GUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 200)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🎯 ESP & Aimbot Menu"
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local function createButton(text, posY)
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.new(1, -20, 0, 35)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	return btn
end

local ESPBtn = createButton("ESP: OFF", 40)
local AimbotBtn = createButton("Aimbot: OFF", 80)
local TeamCheckBtn = createButton("TeamCheck: ON", 120)

local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.TextSize = 14

CloseBtn.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end)

-- // Button Logic
ESPBtn.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	ESPBtn.Text = ESPEnabled and "ESP: ON ✅" or "ESP: OFF ❌"
end)

AimbotBtn.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	AimbotBtn.Text = AimbotEnabled and "Aimbot: ON ✅" or "Aimbot: OFF ❌"
end)

TeamCheckBtn.MouseButton1Click:Connect(function()
	TeamCheck = not TeamCheck
	TeamCheckBtn.Text = TeamCheck and "TeamCheck: ON" or "TeamCheck: OFF"
end)

-- // Aimbot Logic
local function GetClosestPlayer()
	local closest = nil
	local shortest = AimbotFOV
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character and player.Character:FindFirstChild(TargetPart) then
			if not TeamCheck or player.Team ~= LP.Team then
				local pos, onScreen = Camera:WorldToViewportPoint(player.Character[TargetPart].Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
					if dist < shortest then
						shortest = dist
						closest = player
					end
				end
			end
		end
	end
	return closest
end

-- // ESP Logic
local function CreateESP(player)
	if player == LP then return end
	local function apply()
		if player.Character and not player.Character:FindFirstChildOfClass("Highlight") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "Highlight_ESP"
			highlight.FillColor = Color3.new(1, 0, 0)
			highlight.OutlineColor = Color3.new(1, 1, 1)
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
			highlight.Adornee = player.Character
			highlight.Parent = player.Character
		end
	end
	apply()
	if not player.Character then
		player.CharacterAdded:Once(function()
			wait(1)
			apply()
		end)
	end
end

local function IsVisible(part)
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {LP.Character}

	local result = workspace:Raycast(origin, direction, params)
	return result and result.Instance:IsDescendantOf(part.Parent)
end

-- // Main Loops
RS.RenderStepped:Connect(function()
	-- Aimbot
	if AimbotEnabled then
		local target = GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild(TargetPart) then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[TargetPart].Position)
		end
	end

	-- ESP
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP then
			if not TeamCheck or player.Team ~= LP.Team then
				if player.Character and player.Character:FindFirstChild("Head") then
					local esp = player.Character:FindFirstChildOfClass("Highlight")
					if not esp and ESPEnabled then
						CreateESP(player)
						esp = player.Character:FindFirstChildOfClass("Highlight")
					end
					if esp then
						esp.Enabled = ESPEnabled
						local visible = IsVisible(player.Character.Head)
						esp.FillColor = visible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
					end
				end
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(1)
		if ESPEnabled then
			CreateESP(player)
		end
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LP then
		CreateESP(player)
	end
end

-- // Hotkey Toggle
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == AimbotKey then
		AimbotEnabled = not AimbotEnabled
		AimbotBtn.Text = AimbotEnabled and "Aimbot: ON ✅" or "Aimbot: OFF ❌"
	end
end)
