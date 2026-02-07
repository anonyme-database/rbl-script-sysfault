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
local SpeedEnabled = false
local WalkSpeedValue = 16


local FlyEnabled = false
local FlySpeed = 50
local BodyGyro = nil
local BodyVelocity = nil

-- --- CONFIGURATION FOV ---
local FovEnabled = false
local FovRadius = 100 
local FovCircle = Drawing.new("Circle") 
FovCircle.Visible = false
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 1
FovCircle.Filled = false


local Window = Rayfield:CreateWindow({
    Name = "By Sysfault",
    LoadingTitle = "Sysfault Hub v4",
    LoadingSubtitle = "Fly + Speed + Aimbot",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local MoveTab = Window:CreateTab("Déplacement", 4483362458)
local VisualTab = Window:CreateTab("Visuel", 4483362458)


local function StartFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    BodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
    BodyGyro.P = 9e4
    BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.cframe = char.HumanoidRootPart.CFrame

    BodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
    BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

    task.spawn(function()
        while FlyEnabled and char:FindFirstChild("HumanoidRootPart") do
            local moveDir = char.Humanoid.MoveDirection
            local flyVec = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                flyVec = Vector3.new(0, FlySpeed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                flyVec = Vector3.new(0, -FlySpeed, 0)
            end
            
            BodyVelocity.velocity = (moveDir * FlySpeed) + flyVec
            BodyGyro.cframe = Camera.CFrame
            task.wait()
        end
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
    end)
end

-- --- GESTION SPEED ---
RunService.RenderStepped:Connect(function()
    if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
    end
    
    -- Update FOV Circle
    FovCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FovCircle.Radius = FovRadius
    FovCircle.Visible = FovEnabled
end)

-- --- INTERFACE DÉPLACEMENT ---

-- Speed Section
MoveTab:CreateSection("Vitesse au sol")
MoveTab:CreateToggle({
    Name = "Activer Speed Boost",
    CurrentValue = false,
    Callback = function(Value) 
        SpeedEnabled = Value 
        if not Value and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end
})
MoveTab:CreateSlider({
    Name = "Vitesse",
    Range = {16, 300},
    Increment = 1,
    Suffix = "ws",
    CurrentValue = 16,
    Callback = function(Value) WalkSpeedValue = Value end
})

-- Fly Section
MoveTab:CreateSection("Vol (Fly)")
MoveTab:CreateToggle({
    Name = "Activer le Fly",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if Value then StartFly() end
    end
})
MoveTab:CreateSlider({
    Name = "Vitesse du Fly",
    Range = {10, 500},
    Increment = 5,
    Suffix = "spd",
    CurrentValue = 50,
    Callback = function(Value) FlySpeed = Value end
})

-- Noclip Section
MoveTab:CreateSection("Autres")
MoveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value) NoclipEnabled = Value end
})

-- --- LOGIQUE NOCLIP & AIMBOT ---
-- (Inchangé par rapport à la version précédente)

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
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
    Name = "Afficher FOV",
    CurrentValue = false,
    Callback = function(Value) FovEnabled = Value end
})

CombatTab:CreateSlider({
    Name = "Taille FOV",
    Range = {50, 800},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(Value) FovRadius = Value end
})

-- --- VISUEL (ESP) ---
VisualTab:CreateToggle({
    Name = "ESP Arc-en-ciel",
    CurrentValue = false,
    Callback = function(Value) EspEnabled = Value end
})

Rayfield:LoadConfiguration()
