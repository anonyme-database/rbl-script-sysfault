local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = false
local IsAiming = false
local EspEnabled = false
local NoclipEnabled = false
local HitboxEnabled = false

-- --- CONFIGURATION SPEED ---
local SpeedEnabled = false
local WalkSpeedValue = 16 -- Vitesse par défaut de Roblox

-- --- CONFIGURATION FOV ---
local FovEnabled = false
local FovRadius = 100 
local FovCircle = Drawing.new("Circle") 

FovCircle.Visible = false
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 1
FovCircle.Filled = false

-- --- FENÊTRE PRINCIPALE ---
local Window = Rayfield:CreateWindow({
    Name = "By Sysfault",
    LoadingTitle = "Sysfault Hub v4",
    LoadingSubtitle = "Aimbot + Speed Custom",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local MoveTab = Window:CreateTab("Déplacement", 4483362458)
local VisualTab = Window:CreateTab("Visuel", 4483362458)

-- --- RGB THEME & FOV COLOR ---
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            local color = Color3.fromHSV(i, 1, 1)
            Rayfield:ModifyTheme({AccentColor = color})
            FovCircle.Color = color
            task.wait(0.02)
        end
    end
end)

-- --- GESTION SPEED (BOUCLE) ---
RunService.RenderStepped:Connect(function()
    if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
    elseif not SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        -- On ne force pas le 16 au cas où un autre script légitime du jeu change la vitesse
    end
end)

-- --- GESTION DU CERCLE FOV ---
RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FovCircle.Radius = FovRadius
    FovCircle.Visible = FovEnabled
end)

-- --- AIMBOT LOGIC ---
local function GetClosestPlayer()
    local target = nil
    local shortestDist = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    
                    if dist < shortestDist then
                        if FovEnabled and dist > FovRadius then
                            -- Hors zone
                        else
                            shortestDist = dist
                            target = v
                        end
                    end
                end
            end
        end
    end
    return target
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = false end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and IsAiming then
        local target = GetClosestPlayer()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            end
        end
    end
end)

-- --- INTERFACE COMBAT ---
CombatTab:CreateToggle({
    Name = "Aimbot (Clic Droit)",
    CurrentValue = false,
    Callback = function(Value) AimbotEnabled = Value end
})

CombatTab:CreateToggle({
    Name = "Afficher FOV (Zone)",
    CurrentValue = false,
    Callback = function(Value) FovEnabled = Value end
})

CombatTab:CreateSlider({
    Name = "Rayon de la Zone",
    Range = {50, 800},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 100,
    Callback = function(Value) FovRadius = Value end
})

-- --- INTERFACE DÉPLACEMENT ---
MoveTab:CreateToggle({
    Name = "Activer Speed Boost",
    CurrentValue = false,
    Callback = function(Value) 
        SpeedEnabled = Value 
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Remise à zéro
        end
    end
})

MoveTab:CreateSlider({
    Name = "Vitesse de marche",
    Range = {16, 300},
    Increment = 1,
    Suffix = "ws",
    CurrentValue = 16,
    Callback = function(Value)
        WalkSpeedValue = Value
    end
})

MoveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value) NoclipEnabled = Value end
})

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- --- INTERFACE VISUEL (ESP) ---
VisualTab:CreateToggle({
    Name = "ESP Arc-en-ciel",
    CurrentValue = false,
    Callback = function(Value) EspEnabled = Value end
})

task.spawn(function()
    while true do
        if EspEnabled then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character then
                    local esp = v.Character:FindFirstChild("SysESP")
                    if not esp then
                        esp = Instance.new("Highlight")
                        esp.Name = "SysESP"
                        esp.Parent = v.Character
                        esp.FillTransparency = 0.5
                        esp.OutlineTransparency = 0
                    end
                    esp.FillColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                end
            end
        else
            for _, v in pairs(Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("SysESP") then v.Character.SysESP:Destroy() end
            end
        end
        task.wait(0.1)
    end
end)

Rayfield:LoadConfiguration()
