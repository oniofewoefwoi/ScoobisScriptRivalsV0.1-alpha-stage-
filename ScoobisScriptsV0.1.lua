-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // Variables
local aimbotEnabled = false
local espEnabled = false
local speedEnabled = false
local speedValue = 16 -- default speed (used as speed multiplier)

local espObjects = {} -- track ESP elements for cleanup

-- Movement keys state
local moveKeys = {
    W = false,
    A = false,
    S = false,
    D = false
}

-- // Clean up old UI
pcall(function()
    LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("RivalsHackUI"):Destroy()
end)

-- // UI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "RivalsHackUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 1
frame.Size = UDim2.new(0, 220, 0, 220) -- bigger for slider and speed toggle
frame.Position = UDim2.new(0, 20, 0.5, -110)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Rivals Hack Menu"
title.Size = UDim2.new(1, 0, 0, 25)
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Aimbot button
local aimButton = Instance.new("TextButton", frame)
aimButton.Size = UDim2.new(1, -20, 0, 40)
aimButton.Position = UDim2.new(0, 10, 0, 30)
aimButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
aimButton.TextColor3 = Color3.new(1, 1, 1)
aimButton.Text = "Aimbot: OFF"
aimButton.Font = Enum.Font.SourceSans
aimButton.TextSize = 16

aimButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

-- ESP button
local espButton = Instance.new("TextButton", frame)
espButton.Size = UDim2.new(1, -20, 0, 40)
espButton.Position = UDim2.new(0, 10, 0, 80)
espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espButton.TextColor3 = Color3.new(1, 1, 1)
espButton.Text = "ESP: OFF"
espButton.Font = Enum.Font.SourceSans
espButton.TextSize = 16

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    toggleESP(espEnabled)
end)

-- Speed hack toggle button
local speedToggleButton = Instance.new("TextButton", frame)
speedToggleButton.Size = UDim2.new(1, -20, 0, 30)
speedToggleButton.Position = UDim2.new(0, 10, 0, 130)
speedToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedToggleButton.TextColor3 = Color3.new(1, 1, 1)
speedToggleButton.Text = "Speed Hack: OFF"
speedToggleButton.Font = Enum.Font.SourceSans
speedToggleButton.TextSize = 16

speedToggleButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedToggleButton.Text = "Speed Hack: " .. (speedEnabled and "ON" or "OFF")
end)

-- Speed slider label
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 170)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.Text = "Speed: 16"

-- Speed slider background
local speedSliderBack = Instance.new("Frame", frame)
speedSliderBack.Size = UDim2.new(1, -20, 0, 20)
speedSliderBack.Position = UDim2.new(0, 10, 0, 190)
speedSliderBack.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedSliderBack.BorderSizePixel = 0
speedSliderBack.AnchorPoint = Vector2.new(0, 0)

-- Speed slider fill
local speedSliderFill = Instance.new("Frame", speedSliderBack)
speedSliderFill.Size = UDim2.new(speedValue/100, 0, 1, 0)
speedSliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
speedSliderFill.BorderSizePixel = 0

-- Speed slider draggable button
local speedSliderButton = Instance.new("TextButton", speedSliderBack)
speedSliderButton.Size = UDim2.new(0, 14, 1, 0)
speedSliderButton.Position = UDim2.new(speedValue/100, -7, 0, 0)
speedSliderButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
speedSliderButton.Text = ""
speedSliderButton.AutoButtonColor = false
speedSliderButton.BorderSizePixel = 0
speedSliderButton.Modal = true

local dragging = false

local function updateSpeedSlider(inputPosX)
    local relativeX = math.clamp(inputPosX - speedSliderBack.AbsolutePosition.X, 0, speedSliderBack.AbsoluteSize.X)
    local percent = relativeX / speedSliderBack.AbsoluteSize.X
    speedValue = math.floor(percent * 100)
    if speedValue < 1 then speedValue = 1 end
    speedSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    speedSliderButton.Position = UDim2.new(percent, -7, 0, 0)
    speedLabel.Text = "Speed: "..speedValue
end

speedSliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

speedSliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

speedSliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        updateSpeedSlider(input.Position.X)
        dragging = true
    end
end)

speedSliderBack.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSpeedSlider(input.Position.X)
    end
end)

-- Helper to create drawing objects (boxes and tracers)
local Drawing = Drawing or nil -- Some executor environments provide Drawing API

-- Function to get bounding box corners of the entire character in world space
local function getCharacterBoundingBoxParts(char)
    local parts = {}
    -- List of body parts to include
    local bodyPartNames = {
        "Head", "HumanoidRootPart",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot",
        "Torso", "UpperTorso", "LowerTorso"
    }

    for _, name in ipairs(bodyPartNames) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    return parts
end

-- Function to get 2D screen points bounding all parts
local function getScreenBoundingBox(parts)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    for _, part in ipairs(parts) do
        local corners = {
            part.CFrame * CFrame.new(part.Size.X/2, part.Size.Y/2, part.Size.Z/2).Position,
            part.CFrame * CFrame.new(part.Size.X/2, part.Size.Y/2, -part.Size.Z/2).Position,
            part.CFrame * CFrame.new(part.Size.X/2, -part.Size.Y/2, part.Size.Z/2).Position,
            part.CFrame * CFrame.new(part.Size.X/2, -part.Size.Y/2, -part.Size.Z/2).Position,
            part.CFrame * CFrame.new(-part.Size.X/2, part.Size.Y/2, part.Size.Z/2).Position,
            part.CFrame * CFrame.new(-part.Size.X/2, part.Size.Y/2, -part.Size.Z/2).Position,
            part.CFrame * CFrame.new(-part.Size.X/2, -part.Size.Y/2, part.Size.Z/2).Position,
            part.CFrame * CFrame.new(-part.Size.X/2, -part.Size.Y/2, -part.Size.Z/2).Position,
        }

        for _, cornerPos in ipairs(corners) do
            local screenPos, onScreen = Camera:WorldToViewportPoint(cornerPos)
            if onScreen then
                anyOnScreen = true
                minX = math.min(minX, screenPos.X)
                minY = math.min(minY, screenPos.Y)
                maxX = math.max(maxX, screenPos.X)
                maxY = math.max(maxY, screenPos.Y)
            end
        end
    end

    if anyOnScreen then
        return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
    else
        return nil, nil
    end
end

-- ESP toggle function
function toggleESP(state)
    if not state then
        -- Remove all ESP elements
        for _, espData in pairs(espObjects) do
            if espData.Box then espData.Box:Remove() end
            if espData.Tracer then espData.Tracer:Remove() end
            if espData.NameLabel then espData.NameLabel:Destroy() end
        end
        espObjects = {}
        return
    end

    -- Create ESP for players within 200 studs
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                local head = char:FindFirstChild("Head")
                local humanoid = char:FindFirstChild("Humanoid")
                if rootPart and head and humanoid and humanoid.Health > 0 then
                    local dist = (rootPart.Position - (LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")).Position or Vector3.new())).Magnitude
                    if dist <= 200 then
                        -- Create BillboardGui for name label (attached to head)
                        local nameGui = Instance.new("BillboardGui")
                        nameGui.Name = "ESPName"
                        nameGui.Adornee = head
                        nameGui.Parent = head
                        nameGui.AlwaysOnTop = true
                        nameGui.Size = UDim2.new(0, 100, 0, 25)
                        nameGui.StudsOffset = Vector3.new(0, 2.5, 0)

                        local nameLabel = Instance.new("TextLabel", nameGui)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Size = UDim2.new(1, 0, 1, 0)
                        nameLabel.Text = player.Name
                        nameLabel.TextColor3 = Color3.new(1, 0, 0)
                        nameLabel.TextStrokeTransparency = 0
                        nameLabel.Font = Enum.Font.SourceSansBold
                        nameLabel.TextScaled = true

                        -- Drawing for box and tracer
                        if Drawing then
                            local box = Drawing.new("Square")
                            box.Color = Color3.new(1, 0, 0)
                            box.Thickness = 2
                            box.Filled = false
                            box.Transparency = 1

                            local tracer = Drawing.new("Line")
                            tracer.Color = Color3.new(1, 0, 0)
                            tracer.Thickness = 1.5
                            tracer.Transparency = 1

                            espObjects[player] = {
                                Box = box,
                                Tracer = tracer,
                                NameLabel = nameGui,
                                Character = char,
                                RootPart = rootPart,
                                Head = head,
                            }
                        else
                            -- Fallback if Drawing not available: remove old esp data to avoid leaks
                            espObjects[player] = {
                                NameLabel = nameGui,
                                Character = char,
                            }
                        end
                    else
                        -- Remove if out of range
                        if espObjects[player] then
                            if espObjects[player].Box then espObjects[player].Box:Remove() end
                            if espObjects[player].Tracer then espObjects[player].Tracer:Remove() end
                            if espObjects[player].NameLabel then espObjects[player].NameLabel:Destroy() end
                            espObjects[player] = nil
                        end
                    end
                end
            end
        end
    end
end

-- Update ESP every frame
RunService.RenderStepped:Connect(function()
    if espEnabled and Drawing then
        local viewportSize = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y)
        local screenBottomCenter = Vector2.new(viewportSize.X/2, viewportSize.Y)

        for player, espData in pairs(espObjects) do
            local char = espData.Character
            if char and char.Parent and espData.RootPart and espData.Head then
                -- Get all relevant parts for bounding box
                local parts = getCharacterBoundingBoxParts(char)
                local topLeft, bottomRight = getScreenBoundingBox(parts)
                if topLeft and bottomRight then
                    local boxPos = Vector2.new(topLeft.X, topLeft.Y)
                    local boxSize = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)

                    -- Position box
                    espData.Box.Position = boxPos
                    espData.Box.Size = boxSize
                    espData.Box.Visible = true

                    -- Draw tracer line from bottom center to head
                    local headPos, headOnScreen = Camera:WorldToViewportPoint(espData.Head.Position)
                    if headOnScreen then
                        espData.Tracer.From = screenBottomCenter
                        espData.Tracer.To = Vector2.new(headPos.X, headPos.Y)
                        espData.Tracer.Visible = true
                    else
                        espData.Tracer.Visible = false
                    end
                else
                    espData.Box.Visible = false
                    espData.Tracer.Visible = false
                end
            else
                -- Character no longer valid, remove esp data
                if espData.Box then espData.Box:Remove() end
                if espData.Tracer then espData.Tracer:Remove() end
                if espData.NameLabel then espData.NameLabel:Destroy() end
                espObjects[player] = nil
            end
        end
    end
end)

-- Refresh ESP every 10 seconds to detect new players
spawn(function()
    while true do
        wait(10)
        if espEnabled then
            toggleESP(false)
            toggleESP(true)
        end
    end
end)

-- Get closest target by 3D distance to player
local function getClosestTarget()
    local closest = nil
    local shortest = math.huge
    local localRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    if not localRoot then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            local humanoid = char and char:FindFirstChild("Humanoid")
            if rootPart and humanoid and humanoid.Health > 0 then
                local dist = (rootPart.Position - localRoot.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = char
                end
            end
        end
    end
    return closest
end

-- Aimbot with instant snap (reduce trailing by multiple mousemoverel calls)
local mousemoverel = mousemoverel or (Input and Input.MouseMove) or getgenv().mousemoverel
if not mousemoverel then
    warn("❌ Your executor does not support 'mousemoverel'. Aimbot won't work.")
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and mousemoverel then
        local target = getClosestTarget()
        if target and target:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Head.Position)
            if onScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local aimPos = Vector2.new(screenPos.X, screenPos.Y)
                local delta = (aimPos - screenCenter)
                -- Call mousemoverel 2 times for faster snapping, reducing trailing
                for i = 1, 2 do
                    mousemoverel(delta.X / 2, delta.Y / 2)
                end
            end
        end
    end
end)

-- Ensure WalkSpeed is set to default for compatibility
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
end

-- Handle movement keys to toggle movement flags
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then moveKeys.W = true
    elseif key == Enum.KeyCode.A then moveKeys.A = true
    elseif key == Enum.KeyCode.S then moveKeys.S = true
    elseif key == Enum.KeyCode.D then moveKeys.D = true
    elseif key == Enum.KeyCode.RightShift then
        -- Toggle UI visibility
        gui.Enabled = not gui.Enabled
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then moveKeys.W = false
    elseif key == Enum.KeyCode.A then moveKeys.A = false
    elseif key == Enum.KeyCode.S then moveKeys.S = false
    elseif key == Enum.KeyCode.D then moveKeys.D = false
    end
end)

-- Move the player using CFrame if speed hack enabled
RunService.Heartbeat:Connect(function(deltaTime)
    if speedEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local moveDir = Vector3.new(0, 0, 0)
        if moveKeys.W then moveDir = moveDir + Vector3.new(0, 0, -1) end
        if moveKeys.S then moveDir = moveDir + Vector3.new(0, 0, 1) end
        if moveKeys.A then moveDir = moveDir + Vector3.new(-1, 0, 0) end
        if moveKeys.D then moveDir = moveDir + Vector3.new(1, 0, 0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            local camCFrame = Camera.CFrame
            local lookVec = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
            local rightVec = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit

            local moveVec = (lookVec * moveDir.Z + rightVec * moveDir.X).Unit
            local newPos = hrp.CFrame.Position + moveVec * speedValue * deltaTime
            hrp.CFrame = CFrame.new(newPos, newPos + hrp.CFrame.LookVector)
        end
    end
end)
