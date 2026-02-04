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
local FlyEnabled = false
local HitboxEnabled = false

-- --- CONFIGURATION FOV ---
local FovEnabled = false
local FovRadius = 100 -- Taille par défaut
local FovCircle = Drawing.new("Circle") -- Utilise la librairie Drawing de l'exécuteur

-- Configuration visuelle du Cercle
FovCircle.Visible = false
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 1
FovCircle.Filled = false

-- --- CONFIGURATION FENÊTRE ---
local Window = Rayfield:CreateWindow({
    Name = "By Sysfault",
    LoadingTitle = "Sysfault Hub v4",
    LoadingSubtitle = "Aimbot + FOV Zone",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local MoveTab = Window:CreateTab("Déplacement", 4483362458)
local VisualTab = Window:CreateTab("Visuel", 4483362458)

-- --- SYSTÈME DE COULEUR (RGB) ---
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            local color = Color3.fromHSV(i, 1, 1)
            Rayfield:ModifyTheme({AccentColor = color})
            -- Le cercle change aussi de couleur !
            FovCircle.Color = color
            task.wait(0.02)
        end
    end
end)

-- --- GESTION DU CERCLE FOV ---
RunService.RenderStepped:Connect(function()
    -- Le cercle suit la souris
    FovCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FovCircle.Radius = FovRadius
    
    -- Affiche le cercle seulement si l'option est activée
    if FovEnabled then
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end
end)

-- --- 1. AIMBOT (AVEC FOV CHECK) ---
local function GetClosestPlayer()
    local target = nil
    local shortestDist = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    
                    -- NOUVEAU : On vérifie si le joueur est DANS le cercle (si FOV est activé)
                    if dist < shortestDist then
                        if FovEnabled and dist > FovRadius then
                            -- Si le joueur est hors du cercle, on l'ignore
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
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

CombatTab:CreateToggle({
    Name = "Afficher FOV (Zone)",
    CurrentValue = false,
    Callback = function(Value)
        FovEnabled = Value
    end
})

CombatTab:CreateSlider({
    Name = "Rayon de la Zone (Taille)",
    Range = {50, 800},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 100,
    Flag = "FovSize",
    Callback = function(Value)
        FovRadius = Value
    end
})

CombatTab:CreateToggle({
    Name = "Hitbox Géante",
    CurrentValue = false,
    Callback = function(Value)
        HitboxEnabled = Value
        if not Value then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    v.Character.Head.Size = Vector3.new(2, 1, 1)
                    v.Character.Head.Transparency = 0
                end
            end
        end
    end
})

-- --- BOUCLE HITBOX ---
RunService.RenderStepped:Connect(function()
    if HitboxEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                v.Character.Head.Size = Vector3.new(5, 5, 5)
                v.Character.Head.CanCollide = false
                v.Character.Head.Transparency = 0.5
            end
        end
    end
end)

-- --- RESTE DES FONCTIONS (FLY, NOCLIP, ESP) ---
-- (J'ai condensé ici pour que ce soit propre, copie les blocs du script précédent pour Fly/Noclip/ESP si besoin, ou garde ceux ci-dessous)

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

-- Fly et ESP (Code identique au précédent pour assurer la compatibilité)
-- ... (Si tu as besoin que je remette tout le bloc Fly/ESP dis le moi, mais c'est le même code)

-- Exemple simple ESP pour compléter ce script
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
