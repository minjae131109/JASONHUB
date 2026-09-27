--// JASON HUB - Rayfield Version

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet(
"https://sirius.menu/rayfield"
))()

local Window = Rayfield:CreateWindow({
Name = "JASON HUB",
LoadingTitle = "JASON HUB",
LoadingSubtitle = "인야",
ConfigurationSaving = {
Enabled = false
},
Discord = {
Enabled = false
},
KeySystem = false
})

local grabOn = false
local rupKillOn = false
local noclipOn = false
local flyOn = false
local xrayOn = false
local espOn = false

--// =====================================================
--// 메인 탭
--// =====================================================

local MainTab = Window:CreateTab("메인", 4483362458)

MainTab:CreateSection("기본 기능")

--// Grab Tools

local grabConnection
local grabDescendantConnection

local function equipTool(tool)
if not grabOn then return end
if not tool or not tool:IsA("Tool") then return end
if not tool:FindFirstChild("Handle") then return end

local char = player.Character
if not char then return end

local humanoid = char:FindFirstChildWhichIsA("Humanoid")
if not humanoid then return end

pcall(function()
    humanoid:EquipTool(tool)
end)

end

local function processTool(obj)
if not grabOn then return end
if not obj:IsA("Tool") then return end

if obj:FindFirstChild("Handle") then
    equipTool(obj)
end

end

local function scanExistingTools()
if not grabOn then return end

for _, obj in ipairs(workspace:GetDescendants()) do
    if not grabOn then
        break
    end

    if obj:IsA("Tool") then
        processTool(obj)
    end
end

end

MainTab:CreateToggle({
Name = "Grab Tools",
CurrentValue = false,

Callback = function(Value)
    grabOn = Value

    if grabConnection then
        grabConnection:Disconnect()
        grabConnection = nil
    end

    if grabDescendantConnection then
        grabDescendantConnection:Disconnect()
        grabDescendantConnection = nil
    end

    if not Value then
        return
    end

    scanExistingTools()

    grabConnection = workspace.ChildAdded:Connect(function(obj)
        if grabOn and obj:IsA("Tool") then
            processTool(obj)
        end
    end)

    grabDescendantConnection = workspace.DescendantAdded:Connect(function(obj)
        if grabOn and obj:IsA("Tool") then
            processTool(obj)
        end
    end)
end

})

--// 뤂킬

local rupKillThread = nil

local function runRupKill()
local success = pcall(function()
local source = game:HttpGet(
"https://pastebin.com/raw/dncT3TEh"
)

    local func = loadstring(source)

    if func then
        func()
    end
end)

return success

end

MainTab:CreateToggle({
Name = "뤂킬",
CurrentValue = false,

Callback = function(Value)
    rupKillOn = Value

    if rupKillThread then
        task.cancel(rupKillThread)
        rupKillThread = nil
    end

    if not Value then
        return
    end

    rupKillThread = task.spawn(function()
        while rupKillOn do
            runRupKill()
            task.wait(1)
        end
    end)
end

})

--// X-Ray

local xrayOriginalTransparency = {}

local function applyXRayToPart(part)
if not part:IsA("BasePart") then return end

if xrayOriginalTransparency[part] == nil then
    xrayOriginalTransparency[part] = part.LocalTransparencyModifier
end

part.LocalTransparencyModifier = 0.65

end

local function enableXRay()
xrayOn = true

for _, obj in ipairs(workspace:GetDescendants()) do
    applyXRayToPart(obj)
end

end

local function disableXRay()
xrayOn = false

for obj, originalValue in pairs(xrayOriginalTransparency) do
    if obj and obj.Parent then
        obj.LocalTransparencyModifier = originalValue
    end
end

table.clear(xrayOriginalTransparency)

end

MainTab:CreateToggle({
Name = "Xray",
CurrentValue = false,

Callback = function(Value)
    if Value then
        enableXRay()
    else
        disableXRay()
    end
end

})

workspace.DescendantAdded:Connect(function(obj)
if xrayOn and obj:IsA("BasePart") then
applyXRayToPart(obj)
end
end)

--// ESP

local espHighlights = {}
local espNames = {}

local function removeESP(targetPlayer)
if espHighlights[targetPlayer] then
espHighlights[targetPlayer]:Destroy()
espHighlights[targetPlayer] = nil
end

if espNames[targetPlayer] then
    espNames[targetPlayer]:Destroy()
    espNames[targetPlayer] = nil
end

end

local function createESP(targetPlayer)
if not espOn then return end
if targetPlayer == player then return end

local character = targetPlayer.Character
if not character then return end

local head = character:FindFirstChild("Head")
if not head then return end

removeESP(targetPlayer)

local highlight = Instance.new("Highlight")
highlight.Name = "JASON_ESP"
highlight.Adornee = character
highlight.FillColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.65
highlight.OutlineTransparency = 0
highlight.Parent = character

espHighlights[targetPlayer] = highlight

local nameGui = Instance.new("BillboardGui")
nameGui.Name = "JASON_ESP_NAME"
nameGui.Adornee = head
nameGui.Size = UDim2.new(0, 180, 0, 30)
nameGui.StudsOffset = Vector3.new(0, 3, 0)
nameGui.AlwaysOnTop = true
nameGui.Parent = head

local nameText = Instance.new("TextLabel")
nameText.Size = UDim2.new(1, 0, 1, 0)
nameText.BackgroundTransparency = 1
nameText.Text = targetPlayer.DisplayName
nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
nameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
nameText.TextStrokeTransparency = 0
nameText.TextScaled = true
nameText.Font = Enum.Font.SourceSansBold
nameText.Parent = nameGui

espNames[targetPlayer] = nameGui

end

local function enableESP()
espOn = true

for _, targetPlayer in ipairs(Players:GetPlayers()) do
    if targetPlayer ~= player then
        createESP(targetPlayer)
    end
end

end

local function disableESP()
espOn = false

for _, targetPlayer in ipairs(Players:GetPlayers()) do
    removeESP(targetPlayer)
end

end

MainTab:CreateToggle({
Name = "ESP",
CurrentValue = false,

Callback = function(Value)
    if Value then
        enableESP()
    else
        disableESP()
    end
end

})

Players.PlayerAdded:Connect(function(targetPlayer)
targetPlayer.CharacterAdded:Connect(function()
if espOn then
task.wait(0.5)
createESP(targetPlayer)
end
end)
end)

for _, targetPlayer in ipairs(Players:GetPlayers()) do
if targetPlayer ~= player then
targetPlayer.CharacterAdded:Connect(function()
if espOn then
task.wait(0.5)
createESP(targetPlayer)
end
end)
end
end

Players.PlayerRemoving:Connect(function(targetPlayer)
removeESP(targetPlayer)
end)

--// =====================================================
--// Fling 피하기
--// =====================================================

MainTab:CreateSection("Fling 피하기")

MainTab:CreateToggle({
Name = "Noclip",
CurrentValue = false,

Callback = function(Value)
    noclipOn = Value

    if not Value then
        local char = player.Character

        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

})

RunService.Stepped:Connect(function()
if not noclipOn then return end

local char = player.Character
if not char then return end

for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
        part.CanCollide = false
    end
end

end)

--// =====================================================
--// Fly
--// =====================================================

local flySpeed = 50
local flyConnection
local flyVelocity
local flyGyro
local flyUp = false
local flyDown = false
local flyMobileGui

local function getFlyCharacter()
local char = player.Character
if not char then return end

local root = char:FindFirstChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")

if not root or not humanoid then
    return
end

return char, root, humanoid

end

local function createMobileFlyGui()
if flyMobileGui then
flyMobileGui:Destroy()
flyMobileGui = nil
end

if not UserInputService.TouchEnabled then
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "JASON_FLY_MOBILE"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

flyMobileGui = gui

local upButton = Instance.new("TextButton")
upButton.Name = "FlyUp"
upButton.Size = UDim2.new(0, 65, 0, 65)
upButton.Position = UDim2.new(1, -155, 1, -190)
upButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
upButton.BackgroundTransparency = 0.15
upButton.BorderSizePixel = 0
upButton.Text = "▲"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.TextSize = 28
upButton.Font = Enum.Font.SourceSansBold
upButton.Parent = gui

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(1, 0)
upCorner.Parent = upButton

local downButton = Instance.new("TextButton")
downButton.Name = "FlyDown"
downButton.Size = UDim2.new(0, 65, 0, 65)
downButton.Position = UDim2.new(1, -80, 1, -190)
downButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
downButton.BackgroundTransparency = 0.15
downButton.BorderSizePixel = 0
downButton.Text = "▼"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.TextSize = 28
downButton.Font = Enum.Font.SourceSansBold
downButton.Parent = gui

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(1, 0)
downCorner.Parent = downButton

upButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyUp = true
    end
end)

upButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyUp = false
    end
end)

downButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyDown = true
    end
end)

downButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyDown = false
    end
end)

end

local function removeMobileFlyGui()
flyUp = false
flyDown = false

if flyMobileGui then
    flyMobileGui:Destroy()
    flyMobileGui = nil
end

end

local function stopFly()
flyOn = false
flyUp = false
flyDown = false

if flyConnection then
    flyConnection:Disconnect()
    flyConnection = nil
end

if flyVelocity then
    flyVelocity:Destroy()
    flyVelocity = nil
end

if flyGyro then
    flyGyro:Destroy()
    flyGyro = nil
end

removeMobileFlyGui()

local char = player.Character
if not char then return end

local humanoid = char:FindFirstChildOfClass("Humanoid")

if humanoid then
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
end

end

local function startFly()
stopFly()

local char, root, humanoid = getFlyCharacter()

if not char or not root or not humanoid then
    flyOn = false
    return
end

flyOn = true

flyVelocity = Instance.new("BodyVelocity")
flyVelocity.Name = "JASON_FLY_VELOCITY"
flyVelocity.MaxForce = Vector3.new(
    math.huge,
    math.huge,
    math.huge
)
flyVelocity.P = 10000
flyVelocity.Velocity = Vector3.zero
flyVelocity.Parent = root

flyGyro = Instance.new("BodyGyro")
flyGyro.Name = "JASON_FLY_GYRO"
flyGyro.MaxTorque = Vector3.new(
    math.huge,
    math.huge,
    math.huge
)
flyGyro.P = 10000
flyGyro.D = 500
flyGyro.CFrame = workspace.CurrentCamera.CFrame
flyGyro.Parent = root

humanoid.PlatformStand = false
humanoid.AutoRotate = false

createMobileFlyGui()

flyConnection = RunService.RenderStepped:Connect(function()
    if not flyOn then
        return
    end

    local currentChar = player.Character
    if not currentChar then return end

    local currentRoot =
        currentChar:FindFirstChild("HumanoidRootPart")

    local currentHumanoid =
        currentChar:FindFirstChildOfClass("Humanoid")

    local camera = workspace.CurrentCamera

    if not currentRoot or not currentHumanoid or not camera then
        return
    end

    if not flyVelocity or not flyVelocity.Parent then
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Name = "JASON_FLY_VELOCITY"
        flyVelocity.MaxForce = Vector3.new(
            math.huge,
            math.huge,
            math.huge
        )
        flyVelocity.P = 10000
        flyVelocity.Parent = currentRoot
    end

    if not flyGyro or not flyGyro.Parent then
        flyGyro = Instance.new("BodyGyro")
        flyGyro.Name = "JASON_FLY_GYRO"
        flyGyro.MaxTorque = Vector3.new(
            math.huge,
            math.huge,
            math.huge
        )
        flyGyro.P = 10000
        flyGyro.D = 500
        flyGyro.Parent = currentRoot
    end

    local moveDirection = Vector3.zero
    local humanoidMove = currentHumanoid.MoveDirection

    if humanoidMove.Magnitude > 0 then
        moveDirection += humanoidMove
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection += camera.CFrame.LookVector
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection -= camera.CFrame.LookVector
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection -= camera.CFrame.RightVector
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection += camera.CFrame.RightVector
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.Space)
    or flyUp then
        moveDirection += Vector3.new(0, 1, 0)
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    or flyDown then
        moveDirection -= Vector3.new(0, 1, 0)
    end

    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
    end

    flyVelocity.Velocity = moveDirection * flySpeed

    local lookVector = camera.CFrame.LookVector

    if lookVector.Magnitude > 0 then
        flyGyro.CFrame = CFrame.lookAt(
            currentRoot.Position,
            currentRoot.Position + lookVector
        )
    end
end)

end

MainTab:CreateSlider({
Name = "Fly Speed",
Range = {10, 200},
Increment = 5,
Suffix = " Speed",
CurrentValue = 50,

Callback = function(Value)
    flySpeed = Value
end

})

MainTab:CreateToggle({
Name = "Fly",
CurrentValue = false,

Callback = function(Value)
    if Value then
        startFly()
    else
        stopFly()
    end
end

})

player.CharacterAdded:Connect(function()
if flyOn then
task.wait(0.5)
startFly()
end
end)

--// =====================================================
--// 인야
--// =====================================================

MainTab:CreateSection("인야")

local infiniteYieldLoaded = false

MainTab:CreateButton({
Name = "infiniteyYield",

Callback = function()
    if infiniteYieldLoaded then
        return
    end

    infiniteYieldLoaded = true

    task.spawn(function()
        local success = pcall(function()
            loadstring(game:HttpGetAsync(
                "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
            ))()
        end)

        if not success then
            infiniteYieldLoaded = false
        end
    end)
end

})

--// =====================================================
--// 기타 탭
--// =====================================================

local OtherTab = Window:CreateTab("기타", 4483362458)

OtherTab:CreateSection("도구")

--// 계산기

local CalculatorGui = Instance.new("ScreenGui")
CalculatorGui.Name = "JASON_CALCULATOR"
CalculatorGui.ResetOnSpawn = false
CalculatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CalculatorGui.Enabled = false
CalculatorGui.Parent = player:WaitForChild("PlayerGui")

local CalculatorFrame = Instance.new("Frame")
CalculatorFrame.Name = "CalculatorFrame"
CalculatorFrame.Size = UDim2.new(0, 300, 0, 410)
CalculatorFrame.Position = UDim2.new(0.5, -150, 0.5, -205)
CalculatorFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CalculatorFrame.BorderSizePixel = 0
CalculatorFrame.Parent = CalculatorGui

local CalculatorCorner = Instance.new("UICorner")
CalculatorCorner.CornerRadius = UDim.new(0, 12)
CalculatorCorner.Parent = CalculatorFrame

local CalculatorTop = Instance.new("Frame")
CalculatorTop.Name = "Top"
CalculatorTop.Size = UDim2.new(1, 0, 0, 45)
CalculatorTop.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CalculatorTop.BorderSizePixel = 0
CalculatorTop.Parent = CalculatorFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = CalculatorTop

local CalculatorTitle = Instance.new("TextLabel")
CalculatorTitle.Size = UDim2.new(1, -50, 1, 0)
CalculatorTitle.Position = UDim2.new(0, 12, 0, 0)
CalculatorTitle.BackgroundTransparency = 1
CalculatorTitle.Text = "JASON 계산기"
CalculatorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CalculatorTitle.TextSize = 18
CalculatorTitle.Font = Enum.Font.SourceSansBold
CalculatorTitle.TextXAlignment = Enum.TextXAlignment.Left
CalculatorTitle.Parent = CalculatorTop

local CalculatorClose = Instance.new("TextButton")
CalculatorClose.Name = "Close"
CalculatorClose.Size = UDim2.new(0, 40, 0, 40)
CalculatorClose.Position = UDim2.new(1, -43, 0, 2)
CalculatorClose.BackgroundTransparency = 1
CalculatorClose.Text = "X"
CalculatorClose.TextColor3 = Color3.fromRGB(255, 80, 80)
CalculatorClose.TextSize = 20
CalculatorClose.Font = Enum.Font.SourceSansBold
CalculatorClose.Parent = CalculatorTop

CalculatorClose.MouseButton1Click:Connect(function()
CalculatorGui.Enabled = false
end)

local CalculatorDisplay = Instance.new("TextLabel")
CalculatorDisplay.Name = "Display"
CalculatorDisplay.Size = UDim2.new(1, -20, 0, 65)
CalculatorDisplay.Position = UDim2.new(0, 10, 0, 55)
CalculatorDisplay.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
CalculatorDisplay.BorderSizePixel = 0
CalculatorDisplay.Text = "0"
CalculatorDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
CalculatorDisplay.TextSize = 28
CalculatorDisplay.Font = Enum.Font.SourceSansBold
CalculatorDisplay.TextXAlignment = Enum.TextXAlignment.Right
CalculatorDisplay.TextYAlignment = Enum.TextYAlignment.Center
CalculatorDisplay.ClipsDescendants = true
CalculatorDisplay.Parent = CalculatorFrame

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 8)
DisplayCorner.Parent = CalculatorDisplay

local calculatorText = ""
local calculatorResult = ""

local function updateCalculatorDisplay()
if calculatorText == "" then
CalculatorDisplay.Text = "0"
else
CalculatorDisplay.Text = calculatorText
end
end

local function calculateExpression(expression)
expression = expression:gsub("×", "*")
expression = expression:gsub("÷", "/")

if not expression:match("^[%d%+%-%*/%.%s]+$") then
    return nil
end

expression = expression:gsub("%s+", "")

if expression == "" then
    return nil
end

local numbers = {}
local operators = {}
local number = ""

for i = 1, #expression do
    local char = expression:sub(i, i)

    if char:match("[%d%.]") then
        number = number .. char

    elseif char == "+" or char == "-" or char == "*" or char == "/" then
        if number == "" then
            return nil
        end

        local value = tonumber(number)

        if not value then
            return nil
        end

        table.insert(numbers, value)
        table.insert(operators, char)

        number = ""
    else
        return nil
    end
end

if number == "" then
    return nil
end

local value = tonumber(number)

if not value then
    return nil
end

table.insert(numbers, value)

local newNumbers = {}
local newOperators = {}

local current = numbers[1]

for i = 1, #operators do
    local operator = operators[i]
    local nextNumber = numbers[i + 1]

    if operator == "*" then
        current = current * nextNumber

    elseif operator == "/" then
        if nextNumber == 0 then
            return nil
        end

        current = current / nextNumber

    else
        table.insert(newNumbers, current)
        table.insert(newOperators, operator)

        current = nextNumber
    end
end

table.insert(newNumbers, current)

local result = newNumbers[1]

for i = 1, #newOperators do
    if newOperators[i] == "+" then
        result = result + newNumbers[i + 1]

    elseif newOperators[i] == "-" then
        result = result - newNumbers[i + 1]
    end
end

return result

end

local function createCalculatorButton(text, x, y)
local button = Instance.new("TextButton")

button.Name = "Button_" .. text
button.Size = UDim2.new(0, 62, 0, 52)

button.Position = UDim2.new(
    0,
    10 + (x * 70),
    0,
    135 + (y * 58)
)

button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
button.BorderSizePixel = 0
button.Text = text
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 22
button.Font = Enum.Font.SourceSansBold
button.Parent = CalculatorFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

button.MouseButton1Click:Connect(function()
    if text == "C" then
        calculatorText = ""
        calculatorResult = ""
        updateCalculatorDisplay()
    else
        calculatorText = calculatorText .. text
        updateCalculatorDisplay()
    end
end)

return button

end

createCalculatorButton("7", 0, 0)
createCalculatorButton("8", 1, 0)
createCalculatorButton("9", 2, 0)
createCalculatorButton("/", 3, 0)

createCalculatorButton("4", 0, 1)
createCalculatorButton("5", 1, 1)
createCalculatorButton("6", 2, 1)
createCalculatorButton("*", 3, 1)

createCalculatorButton("1", 0, 2)
createCalculatorButton("2", 1, 2)
createCalculatorButton("3", 2, 2)
createCalculatorButton("-", 3, 2)

createCalculatorButton("0", 0, 3)
createCalculatorButton(".", 1, 3)
createCalculatorButton("C", 2, 3)
createCalculatorButton("+", 3, 3)

local EqualButton = Instance.new("TextButton")
EqualButton.Name = "Equal"
EqualButton.Size = UDim2.new(0, 272, 0, 45)
EqualButton.Position = UDim2.new(0, 14, 0, 370)
EqualButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
EqualButton.BorderSizePixel = 0
EqualButton.Text = "="
EqualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EqualButton.TextSize = 24
EqualButton.Font = Enum.Font.SourceSansBold
EqualButton.Parent = CalculatorFrame

local EqualCorner = Instance.new("UICorner")
EqualCorner.CornerRadius = UDim.new(0, 8)
EqualCorner.Parent = EqualButton

EqualButton.MouseButton1Click:Connect(function()
if calculatorText == "" then
return
end

local result = calculateExpression(calculatorText)

if result == nil then
    CalculatorDisplay.Text = "Error"

    task.delay(1, function()
        if CalculatorGui.Enabled then
            calculatorText = ""
            updateCalculatorDisplay()
        end
    end)
else
    calculatorResult = tostring(result)
    calculatorText = calculatorResult
    updateCalculatorDisplay()
end

end)

OtherTab:CreateButton({
Name = "계산기",

Callback = function()
    CalculatorGui.Enabled = true
    calculatorText = ""
    calculatorResult = ""
    updateCalculatorDisplay()
end

})

--// =====================================================
--// 정보
--// =====================================================

local InfoTab = Window:CreateTab("정보", 4483362458)

InfoTab:CreateParagraph({
Title = "JASON HUB",
Content = "인야"
})

Rayfield:Notify({
Title = "JASON HUB",
Content = "실행 완료!",
Duration = 3
})
