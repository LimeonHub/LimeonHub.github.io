local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:Notify({
    Title = "Executing Script",
    Content = "Limeon Hub is launching...",
    Duration = 3,
    Image = 4483362458,
})
local Window = Rayfield:CreateWindow({
    Name = "Limeon Hub",
    Icon = 0,
    LoadingTitle = "Limeon Hub",
    LoadingSubtitle = "Last Updated 14.8.2025",
    ShowText = "Limeon Hub",
    Theme = "DarkBlue",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LimeonHub",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Limeon Hub | KeySystem",
        Subtitle = "Join our Discord to obtain the key",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://raw.githubusercontent.com/LimeonHub/LimeonHub.github.io/refs/heads/main/.txt"}
    }
})
Rayfield:Notify({
    Title = "Script Executed",
    Content = "Limeon Hub was successfully executed.",
    Duration = 3,
    Image = 4483362458,
})
local Tab = Window:CreateTab("🏠 Home", nil)
local Section = Tab:CreateSection("Movement")
local infiniteJumpStarted = false
Tab:CreateToggle({
    Name = "Infinite Jump (PC Only)",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        _G.infinjump = Value
        if not infiniteJumpStarted then
            infiniteJumpStarted = true
            local plr = game:GetService('Players').LocalPlayer
            local m = plr:GetMouse()
            m.KeyDown:Connect(function(k)
                if _G.infinjump and k:byte() == 32 then
                    local humanoid = plr.Character and plr.Character:FindFirstChildOfClass('Humanoid')
                    if humanoid then
                        humanoid:ChangeState('Jumping')
                        wait()
                        humanoid:ChangeState('Seated')
                    end
                end
            end)
        end
    end,
})
Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        character:WaitForChild("Humanoid").WalkSpeed = Value
    end,
})
local noclipEnabled = false
local RunService = game:GetService("RunService")
local plr = game:GetService('Players').LocalPlayer

Tab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        noclipEnabled = Value
    end,
})

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local character = plr.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)
Tab:CreateSection("Executor")
local userCode = ""
Tab:CreateInput({
    Name = "Executor",
    PlaceholderText = "Insert code...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        userCode = Text
    end,
})
Tab:CreateButton({
    Name = "Execute",
    Callback = function()
        local success, err = pcall(function()
            loadstring(userCode)()
        end)
        if not success then
            warn("Execution Error: " .. tostring(err))
        end
    end
})
Tab:CreateSection("Teleporter")

local tpTarget = nil

Tab:CreateInput({
    Name = "Target Player",
    PlaceholderText = "Enter name or display name...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        tpTarget = text:lower()
    end,
})

Tab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local ClosestMatch = nil
        local ShortestDistance = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local name = player.Name:lower()
                local displayName = player.DisplayName:lower()

                if name:find(tpTarget) or displayName:find(tpTarget) then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < ShortestDistance then
                        ClosestMatch = player
                        ShortestDistance = dist
                    end
                end
            end
        end

        if ClosestMatch then
            Character:MoveTo(ClosestMatch.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        else
            warn("No matching player found.")
        end
    end,
})

local SectionESP = Tab:CreateSection("ESP")

--===[ Mená ESP ]===--
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local nameDrawings = {}

Tab:CreateToggle({
    Name = "Enable ESP Names",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        espEnabled = Value

        for _, v in pairs(nameDrawings) do
            if v.Text then v.Text:Remove() end
        end
        nameDrawings = {}

        if espEnabled then
            local runService = game:GetService("RunService")
            local players = game:GetService("Players")
            local localPlayer = players.LocalPlayer
            local camera = workspace.CurrentCamera

            runService.RenderStepped:Connect(function()
                if not espEnabled then return end

                for _, player in pairs(players:GetPlayers()) do
                    if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        local pos, visible = camera:WorldToViewportPoint(hrp.Position)

                        if visible then
                            if not nameDrawings[player] then
                                local text = Drawing.new("Text")
                                text.Size = 16
                                text.Center = true
                                text.Outline = true
                                text.Font = 2
                                nameDrawings[player] = {Text = text}
                            end

                            local distance = math.floor((localPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            local name = player.DisplayName or player.Name
                            local textObj = nameDrawings[player].Text
                            textObj.Position = Vector2.new(pos.X, pos.Y)
                            textObj.Text = string.format("[%dm] %s", distance, name)
                            textObj.Color = espColor
                            textObj.Visible = true
                        elseif nameDrawings[player] then
                            nameDrawings[player].Text.Visible = false
                            nameDrawings[player].Text.Position = Vector2.new(-1000, -1000)
                        end
                    elseif nameDrawings[player] then
                        nameDrawings[player].Text.Visible = false
                        nameDrawings[player].Text.Position = Vector2.new(-1000, -1000)
                    end
                end

                -- Odstráni hráčov čo opustili
                for player, obj in pairs(nameDrawings) do
                    if not player.Parent then
                        if obj.Text then obj.Text:Remove() end
                        nameDrawings[player] = nil
                    end
                end
            end)
        end
    end,
})

Tab:CreateColorPicker({
    Name = "ESP Name Color",
    Color = espColor,
    Flag = "ESPNAMEColor",
    Callback = function(Color)
        espColor = Color
    end,
})

--===[ Boxy ESP ]===--
local espBoxesEnabled = false
local espBoxColor = Color3.fromRGB(0, 255, 0)
local espBoxFilled = false
local espBoxTransparency = 0.5
local boxDrawings = {}

Tab:CreateToggle({
    Name = "Enable ESP Boxes",
    CurrentValue = false,
    Flag = "ESPBoxes",
    Callback = function(Value)
        espBoxesEnabled = Value

        for _, box in pairs(boxDrawings) do
            if box.Quad then box.Quad:Remove() end
        end
        boxDrawings = {}

        if espBoxesEnabled then
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local Camera = workspace.CurrentCamera
            local LocalPlayer = Players.LocalPlayer

            RunService.RenderStepped:Connect(function()
                if not espBoxesEnabled then return end

                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        local size = Vector3.new(2, 3, 1.5)
                        local corners = {
                            hrp.CFrame * CFrame.new(-size.X, size.Y, -size.Z),
                            hrp.CFrame * CFrame.new(size.X, size.Y, -size.Z),
                            hrp.CFrame * CFrame.new(size.X, -size.Y, -size.Z),
                            hrp.CFrame * CFrame.new(-size.X, -size.Y, -size.Z),
                        }

                        local screenPoints = {}
                        local onScreen = true

                        for _, corner in pairs(corners) do
                            local screenPos, visible = Camera:WorldToViewportPoint(corner.Position)
                            if not visible then
                                onScreen = false
                                break
                            end
                            table.insert(screenPoints, Vector2.new(screenPos.X, screenPos.Y))
                        end

                        if onScreen then
                            if not boxDrawings[player] then
                                local box = Drawing.new("Quad")
                                box.Thickness = 1
                                box.Filled = espBoxFilled
                                box.Transparency = 1 - espBoxTransparency
                                box.Color = espBoxColor
                                box.Visible = true
                                boxDrawings[player] = {Quad = box}
                            end

                            local box = boxDrawings[player].Quad
                            box.Visible = true
                            box.Color = espBoxColor
                            box.Filled = espBoxFilled
                            box.Transparency = 1 - espBoxTransparency
                            box.PointA = screenPoints[1]
                            box.PointB = screenPoints[2]
                            box.PointC = screenPoints[3]
                            box.PointD = screenPoints[4]
                        elseif boxDrawings[player] then
                            local box = boxDrawings[player].Quad
                            box.Visible = false
                            box.PointA = Vector2.new(0, 0)
                            box.PointB = Vector2.new(0, 0)
                            box.PointC = Vector2.new(0, 0)
                            box.PointD = Vector2.new(0, 0)
                        end
                    elseif boxDrawings[player] then
                        local box = boxDrawings[player].Quad
                        box.Visible = false
                        box.PointA = Vector2.new(0, 0)
                        box.PointB = Vector2.new(0, 0)
                        box.PointC = Vector2.new(0, 0)
                        box.PointD = Vector2.new(0, 0)
                    end
                end

                -- Čistenie po hráčoch čo odišli
                for player, obj in pairs(boxDrawings) do
                    if not player.Parent then
                        if obj.Quad then obj.Quad:Remove() end
                        boxDrawings[player] = nil
                    end
                end
            end)
        end
    end,
})
Tab:CreateColorPicker({
    Name = "ESP Box Color",
    Color = espBoxColor,
    Flag = "ESPBoxColor",
    Callback = function(Color)
        espBoxColor = Color
    end,
})
Tab:CreateSection("Others")
Tab:CreateButton({
    Name = "Un-Execute Limeon Hub",
    Callback = function()
        Rayfield:Destroy()
    end,
})
Tab:CreateButton({
    Name = "Credits",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EnderSlovakD/DismaneScripts/refs/heads/main/Credits.lua"))()
    end,
})
local Tab = Window:CreateTab("🎮 Games", nil)
Tab:CreateButton({
    Name = "Dead Rails | Ez Win",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/DeadRails", true))()
    end,
})
Tab:CreateButton({
    Name = "Dead Rails | Bonds",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/HungHub/main/loader.lua"))()
    end,
})
Tab:CreateButton({
    Name = "Grow a Garden",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
    end,
})
Tab:CreateButton({
    Name = "Ink Game",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fqfqfqfqwgqghadfaffg/TeslHubCode/refs/heads/main/bob"))()
    end,
})
Tab:CreateButton({
    Name = "Dig It",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Initiate.lua"))()
    end,
})
Tab:CreateButton({
    Name = "Murder Mystery 2",
    Callback = function()
        loadstring(game:HttpGet('loadstring(game:HttpGet("https://soluna-script.vercel.app/murder-mystery-2.lua",true))()'))()
    end,
})
Tab:CreateButton({
    Name = "Rivals (PC)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/necode102/-loader-100/refs/heads/main/loader.lua"))()
    end,
})
local Button = Tab:CreateButton({
   Name = "Rivals | Key System (Mobile)",
   Callback = function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/RIVALS-Duck-Hub-29794"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Steal a Brainrot",
   Callback = function()
   loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/ffdfeadf0af798741806ea404682a938.lua"))() 
   end,
})
Tab:CreateButton({
    Name = "99 Days in The Forest",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua", true))()
    end,
})
local Button = Tab:CreateButton({
   Name = "Big Paintball 2 - Normal",
   Callback = function()
   loadstring(game:HttpGet("https://pastebin.com/raw/tNC6xi9M"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Big Paintball 2 - AutoFarm",
   Callback = function()
   Rayfield:Notify({
    Title = "Limeon Hub",
    Content = "Press F To Start and Close The Script",
    Duration = 3,
    Image = 4483362458,
})
   --[[
	❗❗❗❗ PRESS F TO START THE SCRIPT ❗❗❗❗
]]

local Keybind = "F"

local SessionID = string.gsub(tostring(math.random()):sub(3), "%d", function(c)
    return string.char(96 + math.random(1, 26))
end)
print('✅ | Running BigPaintball2.lua made by Astro with keybind ' .. Keybind .. '! [SessionID ' .. SessionID .. ']')

local Enabled = false
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Fehlerprotokollierung und Schutz
local function safeExecute(func)
    local success, errorMessage = pcall(func)
    if not success then
        warn('⛔ | Error occurred: ' .. errorMessage .. ' [SessionID ' .. SessionID .. ']')
    end
end

-- Gegner und Spieler an festen Positionen teleportieren
local function teleportEntities(cframe, team)
    local spawnPosition = cframe * CFrame.new(0, 0, -15) -- Feste Position vor dem Spieler

    -- Verarbeiten von Entitäten
    for _, entity in ipairs(Workspace.__THINGS.__ENTITIES:GetChildren()) do
        if entity:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = entity.HumanoidRootPart
            humanoidRootPart.CanCollide = false
            humanoidRootPart.Anchored = true
            humanoidRootPart.CFrame = spawnPosition
        elseif entity:FindFirstChild("Hitbox") then
            local directory = entity:GetAttribute("Directory")
            if not (directory == "White" and entity:GetAttribute("OwnerUID") == LocalPlayer.UserId) and 
               (not team or directory ~= team.Name) then
                entity.Hitbox.CanCollide = false
                entity.Hitbox.Anchored = true
                entity.Hitbox.CFrame = spawnPosition * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
        end
    end

    -- Verarbeiten von Spielern
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not team or team.Name ~= player.Team.Name then
                if not player.Character:FindFirstChild("ForceField") then
                    local humanoidRootPart = player.Character.HumanoidRootPart
                    humanoidRootPart.CanCollide = false
                    humanoidRootPart.Anchored = true
                    humanoidRootPart.CFrame = spawnPosition * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
                end
            end
        end
    end
end

-- Eingabeerkennung für das Umschalten
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode[Keybind] and not gameProcessedEvent then
        Enabled = not Enabled
        if Enabled then
            print('✅ | Enabled BigPaintball2.lua [SessionID ' .. SessionID .. ']')
        else
            print('❌ | Disabled BigPaintball2.lua [SessionID ' .. SessionID .. ']')
        end
    end
end)

-- Hauptschleife
while wait(0.1) do -- Optimierte Aktualisierungsrate
    safeExecute(function()
        if not Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local cframe = LocalPlayer.Character.HumanoidRootPart.CFrame -- Spielerposition
        local team = LocalPlayer.Team -- Spielerteam
        teleportEntities(cframe, team)
    end)
end
   end,
})
local Button = Tab:CreateButton({
   Name = "HyperShot",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Joshingtonn123/JoshScript/refs/heads/main/Syrexhubhypershot"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Bubble Gum Simulator INF",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Droidlol/BGSI/refs/heads/main/Endless.lua"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Doors",
   Callback = function()
   loadstring(game:HttpGet("https://rawscripts.net/raw/FLOOR-2-DOORS-Sensation-V2-20105"))()
   end,
})
local Tab = Window:CreateTab("💼 Admin", nil) -- Title, Image
local Button = Tab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Dex",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
   end,
})
local Button = Tab:CreateButton({
    Name = "UNC Test",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/unified-naming-convention/NamingStandard/refs/heads/main/UNCCheckEnv.lua"))()
    end,
})
local Button = Tab:CreateButton({
    Name = "Auto Wallhopper (Best For Mobile)",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20WallHop%20V4%20script"))()
    end,
})
local Button = Tab:CreateButton({
    Name = "Owl Hub",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))();
    end,
})
local Button = Tab:CreateButton({
    Name = "OwO Dances",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/FWwdST5Y"))()
    end,
})
local Button = Tab:CreateButton({
    Name = "Keyboard (For Mobile)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt", true))()

    end,
})
