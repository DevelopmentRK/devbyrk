local CFG = getgenv().rk
if type(CFG) ~= "table" then
    return
end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local VirtualInput     = game:GetService("VirtualInputManager")
local CoreGui          = game:GetService("CoreGui")
local StarterGui       = game:GetService("StarterGui")
local GuiService       = game:GetService("GuiService")
local Workspace        = game:GetService("Workspace")

local function cref(x)
    if cloneref then
        local ok, v = pcall(cloneref, x)
        if ok and v then
            return v
        end
    end
    return x
end

Players          = cref(Players)
RunService       = cref(RunService)
UserInputService = cref(UserInputService)
TweenService     = cref(TweenService)
VirtualInput     = cref(VirtualInput)
CoreGui          = cref(CoreGui)
Workspace        = cref(Workspace)

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function hui()
    if gethui then
        local ok, g = pcall(gethui)
        if ok and g then
            return g
        end
    end
    return CoreGui
end

local function protect(gui)
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    elseif protect_gui then
        pcall(protect_gui, gui)
    end
    gui.Parent = hui()
end

if getgenv()._rk and getgenv()._rk.unload then
    pcall(getgenv()._rk.unload)
end

local RK = {
    connections = {};
    bindNames   = {};
    gui         = {};
    beams       = {};
    cache       = {
        friends = {};
        staff   = {};
        rank    = {};
        userid  = {};
        char    = {};
        hum     = {};
        hrp     = {};
        tool    = {};
    };
    state = {
        loaded     = false;
        panic      = false;
        tbOn       = false;
        avOn       = false;
        m1         = false;
        fireGen    = 0;
        acquiredAt = 0;
        hadTarget  = false;
        nextClick  = 0;
        staffHere  = false;
        viewedBy   = {};
        viewedLock = {};
        aimTarget  = nil;
        notifyOk   = false;
        lastTool   = nil;
    };
}

getgenv()._rk = RK

local function wipe(t)
    for i = #t, 1, -1 do
        t[i] = nil
    end
    for k in pairs(t) do
        t[k] = nil
    end
end

local function track(conn)
    RK.connections[#RK.connections + 1] = conn
    return conn
end

local function bindStep(name, prio, fn)
    RunService:BindToRenderStep(name, prio, fn)
    RK.bindNames[#RK.bindNames + 1] = name
end

local function m1up()
    if not RK.state.m1 then
        return
    end
    RK.state.m1 = false
    if mouse1release then
        pcall(mouse1release)
        return
    end
    local pos = UserInputService:GetMouseLocation()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end)
end

local function m1down()
    if RK.state.m1 then
        return
    end
    RK.state.m1 = true
    if mouse1press then
        pcall(mouse1press)
        return
    end
    local pos = UserInputService:GetMouseLocation()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
    end)
end

local function dead()
    RK.state.loaded = false
    for _, c in ipairs(RK.connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
    wipe(RK.connections)
    for _, n in ipairs(RK.bindNames) do
        pcall(function()
            RunService:UnbindFromRenderStep(n)
        end)
    end
    wipe(RK.bindNames)
    for _, g in ipairs(RK.gui) do
        pcall(function()
            g:Destroy()
        end)
    end
    wipe(RK.gui)
    for _, b in ipairs(RK.beams) do
        if type(b) == "table" then
            for _, x in pairs(b) do
                pcall(function()
                    x:Destroy()
                end)
            end
        end
    end
    wipe(RK.beams)
    m1up()
end

RK.unload = dead

local function notify(title, text, dur)
    if not RK.state.notifyOk then
        return
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = dur or 3;
        })
    end)
end

local function bootVisual()
    local gui = Instance.new("ScreenGui")
    gui.Name = "rk_boot"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1e9
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    protect(gui)
    RK.gui[#RK.gui + 1] = gui

    local dim = Instance.new("Frame")
    dim.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
    dim.BackgroundTransparency = 0.35
    dim.BorderSizePixel = 0
    dim.Size = UDim2.fromScale(1, 1)
    dim.Parent = gui

    local wrap = Instance.new("Frame")
    wrap.AnchorPoint = Vector2.new(0.5, 0.5)
    wrap.Position = UDim2.fromScale(0.5, 0.5)
    wrap.Size = UDim2.fromOffset(280, 92)
    wrap.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel = 0
    wrap.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = wrap

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 1
    stroke.Thickness = 1
    stroke.Parent = wrap

    local mark = Instance.new("TextLabel")
    mark.BackgroundTransparency = 1
    mark.Size = UDim2.new(1, 0, 0, 36)
    mark.Position = UDim2.fromOffset(0, 14)
    mark.Font = Enum.Font.GothamBlack
    mark.Text = "rk"
    mark.TextColor3 = Color3.fromRGB(245, 245, 245)
    mark.TextSize = 28
    mark.TextTransparency = 1
    mark.Parent = wrap

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, 0, 0, 16)
    sub.Position = UDim2.fromOffset(0, 48)
    sub.Font = Enum.Font.Gotham
    sub.Text = tostring(game.PlaceId)
    sub.TextColor3 = Color3.fromRGB(160, 160, 168)
    sub.TextSize = 12
    sub.TextTransparency = 1
    sub.Parent = wrap

    local barBg = Instance.new("Frame")
    barBg.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0
    barBg.Position = UDim2.fromOffset(24, 72)
    barBg.Size = UDim2.fromOffset(232, 3)
    barBg.Parent = wrap

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.fromScale(0, 1)
    bar.Parent = barBg

    local barCorner2 = Instance.new("UICorner")
    barCorner2.CornerRadius = UDim.new(1, 0)
    barCorner2.Parent = bar

    local ti = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(wrap, ti, {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(stroke, ti, {Transparency = 0.82}):Play()
    TweenService:Create(mark, ti, {TextTransparency = 0}):Play()
    TweenService:Create(sub, ti, {TextTransparency = 0}):Play()
    TweenService:Create(barBg, ti, {BackgroundTransparency = 0}):Play()

    local t0 = os.clock()
    local dur = 0.7
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local a = math.clamp((os.clock() - t0) / dur, 0, 1)
        bar.Size = UDim2.fromScale(a, 1)
        if a >= 1 then
            conn:Disconnect()
        end
    end)
    RK.connections[#RK.connections + 1] = conn

    task.delay(dur + 0.12, function()
        local out = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(wrap, out, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, out, {Transparency = 1}):Play()
        TweenService:Create(mark, out, {TextTransparency = 1}):Play()
        TweenService:Create(sub, out, {TextTransparency = 1}):Play()
        TweenService:Create(barBg, out, {BackgroundTransparency = 1}):Play()
        TweenService:Create(bar, out, {BackgroundTransparency = 1}):Play()
        TweenService:Create(dim, out, {BackgroundTransparency = 1}):Play()
        task.wait(0.24)
        if gui.Parent then
            gui:Destroy()
        end
    end)
end

local KEY_MAP = {
    mousebutton1 = Enum.UserInputType.MouseButton1;
    mouse1 = Enum.UserInputType.MouseButton1;
    mb1 = Enum.UserInputType.MouseButton1;
    mousebutton2 = Enum.UserInputType.MouseButton2;
    mouse2 = Enum.UserInputType.MouseButton2;
    mb2 = Enum.UserInputType.MouseButton2;
    mousebutton3 = Enum.UserInputType.MouseButton3;
    mouse3 = Enum.UserInputType.MouseButton3;
    mousebutton4 = Enum.UserInputType.MouseButton4;
    mouse4 = Enum.UserInputType.MouseButton4;
    mb4 = Enum.UserInputType.MouseButton4;
    x1 = Enum.UserInputType.MouseButton4;
    sideback = Enum.UserInputType.MouseButton4;
    mousebutton5 = Enum.UserInputType.MouseButton5;
    mouse5 = Enum.UserInputType.MouseButton5;
    mb5 = Enum.UserInputType.MouseButton5;
    x2 = Enum.UserInputType.MouseButton5;
    sideforward = Enum.UserInputType.MouseButton5;
}

local function parseBind(raw)
    if type(raw) ~= "string" then
        return nil
    end
    local s = raw:gsub("%s+", "")
    if s == "" then
        return nil
    end
    local low = s:lower()
    if low == "none" or low == "nil" then
        return nil
    end
    if KEY_MAP[low] then
        return {kind = "mouse"; mouse = KEY_MAP[low]}
    end
    local ok, key = pcall(function()
        return Enum.KeyCode[s]
    end)
    if ok and key then
        return {kind = "key"; key = key}
    end
    if #s == 1 then
        local up = s:upper()
        local ok2, key2 = pcall(function()
            return Enum.KeyCode[up]
        end)
        if ok2 and key2 then
            return {kind = "key"; key = key2}
        end
    end
    return nil
end

local KB = CFG.Keybinds or {}
local AV = CFG["Aim View"] or {}
local TB = (CFG.Combat and CFG.Combat["Trigger Bot"]) or {}
local ST = CFG.Staff or {}
local CK = CFG.Checks or {}
local AVATAR = CFG.Avatar or {}
local ANIM = CFG.Animations or {}
local MAIN = CFG.Main or {}

local BINDS = {
    tb     = parseBind(KB["Trigger Bot"]);
    av     = parseBind(AV.Key or KB["Aim View"]);
    panic  = parseBind(KB.Panic or (MAIN.Panic and MAIN.Panic.Key));
}

local function bindDown(bind)
    if not bind then
        return false
    end
    if bind.kind == "mouse" then
        return UserInputService:IsMouseButtonPressed(bind.mouse)
    end
    return UserInputService:IsKeyDown(bind.key)
end

local function inputMatches(bind, input)
    if not bind then
        return false
    end
    if bind.kind == "mouse" then
        return input.UserInputType == bind.mouse
    end
    return input.KeyCode == bind.key
end

local function rng(a, b)
    if type(a) == "table" then
        a, b = a[1], a[2]
    end
    a, b = tonumber(a) or 0, tonumber(b) or 0
    if b < a then
        a, b = b, a
    end
    if a == b then
        return a
    end
    return a + (b - a) * math.random()
end

local function charOf(plr)
    if not plr then
        return nil
    end
    local c = RK.cache.char[plr]
    if c and c.Parent then
        return c
    end
    c = plr.Character
    RK.cache.char[plr] = c
    return c
end

local function humOf(model)
    if not model then
        return nil
    end
    local h = RK.cache.hum[model]
    if h and h.Parent == model then
        return h
    end
    h = model:FindFirstChildOfClass("Humanoid")
    RK.cache.hum[model] = h
    return h
end

local function hrpOf(model)
    if not model then
        return nil
    end
    local p = RK.cache.hrp[model]
    if p and p.Parent == model then
        return p
    end
    p = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    RK.cache.hrp[model] = p
    return p
end

local function bodyEffects(model)
    return model and model:FindFirstChild("BodyEffects")
end

local function koValue(model)
    local be = bodyEffects(model)
    if not be then
        return false
    end
    local n = be:FindFirstChild("K.O") or be:FindFirstChild("KO") or be:FindFirstChild("Ko")
    return n and n.Value == true
end

local function grabbed(model)
    return model and model:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
end

local function reloading(model)
    local be = bodyEffects(model)
    local r = be and be:FindFirstChild("Reload")
    return r and r.Value == true
end

local function mousePosValue(model)
    local be = bodyEffects(model)
    if not be then
        return nil
    end
    local n = be:FindFirstChild("MousePos")
        or be:FindFirstChild("MousePosDEBUG")
        or be:FindFirstChild("MOUSE")
        or be:FindFirstChild("MousePosition")
    if n and typeof(n.Value) == "Vector3" then
        return n.Value
    end
    return nil
end

local function equippedTool(model)
    model = model or charOf(LP)
    if not model then
        return nil
    end
    local t = RK.cache.tool[model]
    if t and t.Parent == model then
        return t
    end
    t = model:FindFirstChildOfClass("Tool")
    RK.cache.tool[model] = t
    return t
end

local function isKnifeName(name)
    if not name or name == "" then
        return false
    end
    local low = string.lower(name)
    return string.find(low, "knife", 1, true) ~= nil
        or string.find(low, "katana", 1, true) ~= nil
        or string.find(low, "blade", 1, true) ~= nil
        or string.find(low, "melee", 1, true) ~= nil
        or string.find(low, "fist", 1, true) ~= nil
        or string.find(low, "punch", 1, true) ~= nil
end

local function weaponOk()
    local t = equippedTool()
    if not t then
        return false
    end
    if CK.Knife and isKnifeName(t.Name) then
        return false
    end
    return true
end

local function crewOf(plr)
    local df = plr:FindFirstChild("DataFolder")
    local info = df and df:FindFirstChild("Information")
    local crew = info and info:FindFirstChild("Crew")
    if crew then
        return tostring(crew.Value or "")
    end
    if plr.Team then
        return tostring(plr.Team.Name)
    end
    return ""
end

local function sameCrew(plr)
    if LP.Team and plr.Team and LP.Team == plr.Team then
        return true
    end
    local a, b = crewOf(LP), crewOf(plr)
    if a == "" or b == "" then
        return false
    end
    return a == b
end

local function resolveUserId(q)
    if type(q) == "number" then
        return q
    end
    if type(q) ~= "string" then
        return nil
    end
    q = q:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^@", "")
    if q == "" then
        return nil
    end
    if RK.cache.userid[q] then
        return RK.cache.userid[q]
    end
    local n = tonumber(q)
    if n then
        RK.cache.userid[q] = n
        return n
    end
    local low = string.lower(q)
    local list = Players:GetPlayers()
    for i = 1, #list do
        local p = list[i]
        if string.lower(p.Name) == low then
            RK.cache.userid[q] = p.UserId
            return p.UserId
        end
    end
    local id
    pcall(function()
        id = Players:GetUserIdFromNameAsync(q)
    end)
    if id then
        RK.cache.userid[q] = id
    end
    return id
end

local function playerFromQuery(q)
    if type(q) ~= "string" or q == "" then
        return nil
    end
    local low = string.lower(q)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.lower(p.Name) == low or string.lower(p.DisplayName) == low then
            return p
        end
        if tostring(p.UserId) == q then
            return p
        end
    end
    return Players:FindFirstChild(q)
end

local function isStaff(plr)
    if not plr or plr == LP then
        return false
    end
    local v = RK.cache.staff[plr]
    if v == nil then
        return false
    end
    return v
end

local function cachePlayer(plr)
    if not plr or plr == LP then
        return
    end
    RK.cache.friends[plr] = false
    RK.cache.staff[plr] = false
    task.spawn(function()
        local ok, fr = pcall(function()
            return LP:IsFriendsWith(plr.UserId)
        end)
        RK.cache.friends[plr] = ok and fr or false
        local extra = (CK["Staff Settings"] and CK["Staff Settings"]["Extra UserIds"]) or {}
        for _, id in ipairs(extra) do
            if plr.UserId == id then
                RK.cache.staff[plr] = true
                RK.cache.rank[plr] = 255
                return
            end
        end
        local ss = CK["Staff Settings"] or {}
        local gid = ss["Group Id"]
        local minr = ss["Min Rank"] or 10
        if not gid or gid == 0 then
            RK.cache.staff[plr] = false
            return
        end
        local rank = 0
        pcall(function()
            rank = plr:GetRankInGroup(gid)
        end)
        RK.cache.rank[plr] = rank
        RK.cache.staff[plr] = rank >= minr
    end)
end

local function targetAllowed(plr, model)
    if not model then
        return false
    end
    if not plr then
        if CK.NPC then
            return false
        end
    else
        if plr == LP then
            return false
        end
        if CK.Friends and RK.cache.friends[plr] then
            return false
        end
        if CK["Roblox Crew"] and sameCrew(plr) then
            return false
        end
        if CK.Staff and isStaff(plr) then
            return false
        end
    end

    local hum = humOf(model)
    if CK.Dead then
        if not hum or hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
            return false
        end
    end
    if CK.Health then
        local hs = CK["Health Settings"] or {}
        local minT = hs["Target Min"] or 1
        if hum and hum.Health < minT then
            return false
        end
    end
    if CK["K.O"] and koValue(model) then
        return false
    end
    if CK.Grabbed and grabbed(model) then
        return false
    end
    if CK.Forcefield and model:FindFirstChildOfClass("ForceField") then
        return false
    end
    if CK.Distance then
        local hrp = hrpOf(model)
        local me = hrpOf(charOf(LP))
        if hrp and me then
            local maxd = TB["Hitscan Distance"] or 400
            if (hrp.Position - me.Position).Magnitude > maxd then
                return false
            end
        end
    end
    return true
end

local function localBlocked()
    local C = CK.Local or {}
    local model = charOf(LP)
    if not model then
        return true
    end
    if C["K.O"] and koValue(model) then
        return true
    end
    if C.Grabbed and grabbed(model) then
        return true
    end
    if C.Forcefield and model:FindFirstChildOfClass("ForceField") then
        return true
    end
    if C.Reloading and reloading(model) then
        return true
    end
    if C.Typing and UserInputService:GetFocusedTextBox() then
        return true
    end
    if CK.Health then
        local hum = humOf(model)
        local hs = CK["Health Settings"] or {}
        local minL = hs["Local Min"] or 1
        if hum and hum.Health < minL then
            return true
        end
    end
    return false
end

local function combatFrozen()
    if RK.state.panic then
        return true
    end
    if MAIN["Place Lock"] then
        local want = tonumber(MAIN["Place Id"]) or 0
        if want ~= 0 and want ~= game.PlaceId then
            return true
        end
    end
    if ST.Enabled and ST["On Staff In Server"] and ST["On Staff In Server"]["Disable Combat"] and RK.state.staffHere then
        return true
    end
    if ST.Enabled and ST["On Aim Viewed"] and ST["On Aim Viewed"]["Disable Combat"] then
        if next(RK.state.viewedBy) then
            return true
        end
    end
    return false
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
rayParams.RespectCanCollide = false

local excludeBuf = {}

local function refreshExclude()
    excludeBuf[1] = charOf(LP)
    excludeBuf[2] = Camera
    if RK.beams[1] then
        excludeBuf[3] = Workspace.Terrain
    else
        excludeBuf[3] = nil
    end
    rayParams.FilterDescendantsInstances = excludeBuf
end

local function partToVictim(part)
    if not part then
        return nil, nil
    end
    local model = part:FindFirstAncestorOfClass("Model")
    if not model or model == charOf(LP) then
        return nil, nil
    end
    local plr = Players:GetPlayerFromCharacter(model)
    if not targetAllowed(plr, model) then
        return nil, nil
    end
    return plr, model
end

local function crosshairHit()
    Camera = Workspace.CurrentCamera
    local maxd = (CK.Distance and (TB["Hitscan Distance"] or 400)) or 2000
    local loc = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(loc.X, loc.Y)
    refreshExclude()
    local hit = Workspace:Raycast(ray.Origin, ray.Direction * maxd, rayParams)
    if hit then
        return partToVictim(hit.Instance)
    end
    return nil, nil
end

local FOV_PARTS = {"Head", "HumanoidRootPart"}

local function fovHit()
    Camera = Workspace.CurrentCamera
    local fov = TB.FOV or {}
    local best = fov.Size or 18
    local bestPlr, bestModel = nil, nil
    local vs = Camera.ViewportSize
    local center = Vector2.new(vs.X * 0.5, vs.Y * 0.5)
    local list = Players:GetPlayers()
    for i = 1, #list do
        local plr = list[i]
        if plr ~= LP then
            local model = charOf(plr)
            if model and targetAllowed(plr, model) then
                for p = 1, #FOV_PARTS do
                    local part = model:FindFirstChild(FOV_PARTS[p])
                    if part then
                        local v, on = Camera:WorldToViewportPoint(part.Position)
                        if on then
                            local dx, dy = v.X - center.X, v.Y - center.Y
                            local d = math.sqrt(dx * dx + dy * dy)
                            if d < best then
                                best, bestPlr, bestModel = d, plr, model
                            end
                        end
                    end
                end
            end
        end
    end
    if not CK.NPC then
        local kids = Workspace:GetChildren()
        for i = 1, #kids do
            local model = kids[i]
            if model:IsA("Model") and humOf(model) and not Players:GetPlayerFromCharacter(model) then
                if targetAllowed(nil, model) then
                    local part = model:FindFirstChild("Head") or hrpOf(model)
                    if part then
                        local v, on = Camera:WorldToViewportPoint(part.Position)
                        if on then
                            local dx, dy = v.X - center.X, v.Y - center.Y
                            local d = math.sqrt(dx * dx + dy * dy)
                            if d < best then
                                best, bestPlr, bestModel = d, nil, model
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPlr, bestModel
end

local function gunPart(model)
    local tool = equippedTool(model)
    if tool then
        return tool:FindFirstChild("Default")
            or tool:FindFirstChild("Handle")
            or tool:FindFirstChild("Muzzle")
            or tool:FindFirstChildWhichIsA("BasePart")
    end
    return model:FindFirstChild("Head") or hrpOf(model)
end

local function modeActive(mode, held, toggled)
    mode = mode or "Hold"
    if mode == "Always" then
        return true
    end
    if mode == "Toggle" then
        return toggled
    end
    return held
end

local function featureOn(which)
    if which == "tb" then
        return TB.Enabled and modeActive(TB.Mode, bindDown(BINDS.tb), RK.state.tbOn)
    elseif which == "av" then
        return AV.Enabled and modeActive(AV.Mode, bindDown(BINDS.av), RK.state.avOn)
    end
    return false
end

local function recountStaff()
    local any = false
    local list = Players:GetPlayers()
    for i = 1, #list do
        local p = list[i]
        if p ~= LP and isStaff(p) then
            any = true
            break
        end
    end
    RK.state.staffHere = any
end

local function markViewed(plr, on)
    if on then
        if not RK.state.viewedBy[plr] then
            RK.state.viewedBy[plr] = true
            if ST.Notify and ST.Notify["Aim Viewing You"] then
                local old = RK.state.notifyOk
                RK.state.notifyOk = true
                notify("rk / staff", plr.Name .. " is aim viewing you", 5)
                RK.state.notifyOk = old
            end
            if ST["On Aim Viewed"] and ST["On Aim Viewed"].Panic and MAIN.Panic and MAIN.Panic.Enabled then
                RK.state.panic = true
                m1up()
            end
        end
    else
        RK.state.viewedBy[plr] = nil
        RK.state.viewedLock[plr] = 0
    end
end

local staffRay = RaycastParams.new()
staffRay.FilterType = Enum.RaycastFilterType.Exclude
staffRay.IgnoreWater = true

local function staffScan()
    if not ST.Enabled then
        return
    end
    recountStaff()
    local avd = ST["Aim View Detect"]
    if not avd or not avd.Enabled then
        return
    end
    local me = charOf(LP)
    if not me then
        return
    end
    local need = avd["Hit Frames"] or 8
    local maxd = avd["Max Distance"] or 800
    local list = Players:GetPlayers()
    for i = 1, #list do
        local plr = list[i]
        if plr ~= LP and isStaff(plr) then
            local model = charOf(plr)
            if not model then
                markViewed(plr, false)
            else
                local mp = mousePosValue(model)
                local originPart = gunPart(model) or model:FindFirstChild("Head")
                if not mp or not originPart then
                    markViewed(plr, false)
                else
                    local origin = originPart.Position
                    local delta = mp - origin
                    local mag = delta.Magnitude
                    if mag < 2 or mag > maxd then
                        markViewed(plr, false)
                    else
                        staffRay.FilterDescendantsInstances = {model}
                        local hit = Workspace:Raycast(origin, delta.Unit * math.min(mag + 4, maxd), staffRay)
                        local onMe = hit and hit.Instance and hit.Instance:IsDescendantOf(me)
                        if not onMe then
                            local hrp = hrpOf(me)
                            local head = me:FindFirstChild("Head")
                            if hrp and (mp - hrp.Position).Magnitude < 6 then
                                onMe = true
                            elseif head and (mp - head.Position).Magnitude < 5 then
                                onMe = true
                            end
                        end
                        local n = (RK.state.viewedLock[plr] or 0) + (onMe and 1 or -2)
                        if n < 0 then
                            n = 0
                        end
                        RK.state.viewedLock[plr] = n
                        markViewed(plr, n >= need)
                    end
                end
            end
        end
    end
end

local function ensureBeam()
    if RK.beams[1] then
        return RK.beams[1]
    end
    local a0 = Instance.new("Attachment")
    local a1 = Instance.new("Attachment")
    a0.Name = "rk_av0"
    a1.Name = "rk_av1"
    a0.Parent = Workspace.Terrain
    a1.Parent = Workspace.Terrain
    local beam = Instance.new("Beam")
    beam.Name = "rk_aimview"
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Segments = 2
    beam.Width0 = AV.Width or 0.12
    beam.Width1 = (AV.Width or 0.12) * 0.55
    beam.Color = ColorSequence.new(AV.Color or Color3.fromRGB(255, 40, 40))
    beam.Transparency = NumberSequence.new(0.05)
    beam.Enabled = false
    beam.Parent = Workspace.Terrain
    RK.beams[1] = {beam = beam; a0 = a0; a1 = a1}
    return RK.beams[1]
end

local function closestToCursor()
    local best, who = 1e9, nil
    local loc = UserInputService:GetMouseLocation()
    local list = Players:GetPlayers()
    Camera = Workspace.CurrentCamera
    for i = 1, #list do
        local plr = list[i]
        if plr ~= LP then
            local model = charOf(plr)
            local hrp = model and hrpOf(model)
            if hrp then
                local v, on = Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local dx, dy = v.X - loc.X, v.Y - loc.Y
                    local d = dx * dx + dy * dy
                    if d < best then
                        best, who = d, plr
                    end
                end
            end
        end
    end
    return who
end

local function stepAimView()
    if not AV.Enabled then
        if RK.beams[1] then
            RK.beams[1].beam.Enabled = false
        end
        return
    end
    local pack = ensureBeam()
    local on = featureOn("av") and not RK.state.panic
    if not on then
        pack.beam.Enabled = false
        return
    end
    local tgt = RK.state.aimTarget
    if AV.Mode == "Always" or (AV.Target and AV.Target ~= "" and not tgt) then
        tgt = playerFromQuery(AV.Target) or tgt
        RK.state.aimTarget = tgt
    end
    if not tgt then
        pack.beam.Enabled = false
        return
    end
    local model = charOf(tgt)
    if not model then
        pack.beam.Enabled = false
        return
    end
    local mp = mousePosValue(model)
    local from
    if AV.From == "Head" then
        from = model:FindFirstChild("Head") or hrpOf(model)
    else
        from = gunPart(model)
    end
    if not mp or not from then
        pack.beam.Enabled = false
        return
    end
    pack.a0.WorldPosition = from.Position
    pack.a1.WorldPosition = mp
    pack.beam.Color = ColorSequence.new(AV.Color or Color3.fromRGB(255, 40, 40))
    pack.beam.Width0 = AV.Width or 0.12
    pack.beam.Enabled = true
end

local ANIM_KEYS = {
    Walk  = {"walk", "WalkAnim"};
    Run   = {"run", "RunAnim"};
    Idle  = {"idle", "Animation1", "IdleAnim"};
    Jump  = {"jump", "JumpAnim"};
    Fall  = {"fall", "FallAnim"};
    Climb = {"climb", "ClimbAnim"};
    Swim  = {"swim", "Swim"};
}

local PACKS = {
    astronaut = {Walk=891636393; Run=891636393; Jump=891627522; Idle=891621366; Fall=891617961; Climb=891609353; Swim=891639666};
    bubbly    = {Walk=910034870; Run=910025107; Jump=910016857; Idle=910004836; Fall=910001910; Climb=909997997; Swim=910028158};
    cartoony  = {Walk=742640026; Run=742638842; Jump=742637942; Idle=742637544; Fall=742637151; Climb=742636889; Swim=742639220};
    elder     = {Walk=845403856; Run=845386501; Jump=845398858; Idle=845397899; Fall=845396048; Climb=845392038; Swim=845401742};
    knight    = {Walk=657552124; Run=657564596; Jump=658409194; Idle=657595757; Fall=657600338; Climb=658360781; Swim=657560551};
    levitation= {Walk=616013216; Run=616010382; Jump=616008936; Idle=616006778; Fall=616005863; Climb=616003713; Swim=616011509};
    mage      = {Walk=707897309; Run=707861613; Jump=707853694; Idle=707742142; Fall=707829716; Climb=707826056; Swim=707876443};
    ninja     = {Walk=656121766; Run=656118852; Jump=656117878; Idle=656117400; Fall=656115606; Climb=656114359; Swim=656119721};
    pirate    = {Walk=750785693; Run=750783738; Jump=750782230; Idle=750781874; Fall=750780242; Climb=750779899; Swim=750784579};
    robot     = {Walk=616095330; Run=616091570; Jump=616090535; Idle=616088211; Fall=616087089; Climb=616086039; Swim=616092998};
    rthro     = {Walk=2510202577; Run=2510198475; Jump=2510197830; Idle=2510197257; Fall=2510195892; Climb=2510192778; Swim=2510199791};
    stylish   = {Walk=616146177; Run=616140816; Jump=616139451; Idle=616136790; Fall=616134815; Climb=616133594; Swim=616143378};
    superhero = {Walk=616122287; Run=616117076; Jump=616115533; Idle=616111295; Fall=616108001; Climb=616104706; Swim=616119360};
    toy       = {Walk=782843345; Run=782842708; Jump=782847020; Idle=782841498; Fall=782846423; Climb=782843869; Swim=782844582};
    vampire   = {Walk=1083473930; Run=1083462077; Jump=1083455352; Idle=1083445855; Fall=1083443588; Climb=1083435858; Swim=1083462077};
    zombie    = {Walk=616168032; Run=616163682; Jump=616161997; Idle=616158929; Fall=616157476; Climb=616156119; Swim=616165109};
    werewolf  = {Walk=1083188343; Run=1083178339; Jump=1083185231; Idle=1083173789; Fall=1083171281; Climb=1083173283; Swim=1083182912};
}

local function packKey(s)
    s = string.lower(tostring(s or ""))
    s = s:gsub("animation pack", ""):gsub("animations", ""):gsub("pack", "")
    s = s:gsub("[^%w]", "")
    return s
end

local function parseAnimId(raw, slot, packName)
    if type(raw) == "number" and raw > 0 then
        return raw
    end
    if type(raw) == "string" then
        local s = raw:gsub("^%s+", ""):gsub("%s+$", "")
        if s ~= "" and s ~= "0" then
            local num = s:match("(%d+)")
            if num and (s:lower():find("rbxassetid", 1, true) or tonumber(s) == tonumber(num)) then
                return tonumber(num)
            end
            local key = packKey(s)
            if PACKS[key] and PACKS[key][slot] then
                return PACKS[key][slot]
            end
            for name, pack in pairs(PACKS) do
                if key == name .. string.lower(slot) or key == string.lower(slot) .. name then
                    return pack[slot]
                end
            end
        end
    end
    local pk = packKey(packName)
    if pk ~= "" and PACKS[pk] then
        return PACKS[pk][slot]
    end
    return nil
end

local function setAnimId(animate, names, id)
    if not id or id == 0 then
        return
    end
    local asset = "rbxassetid://" .. tostring(id)
    local function apply(obj)
        if obj:IsA("Animation") then
            obj.AnimationId = asset
        elseif obj:IsA("StringValue") then
            local n = string.lower(obj.Name)
            if n:find("anim", 1, true) or tostring(obj.Value):find("rbxassetid", 1, true) then
                obj.Value = asset
            end
        end
    end
    for _, n in ipairs(names) do
        local folder = animate:FindFirstChild(n) or animate:FindFirstChild(string.lower(n))
        if folder then
            apply(folder)
            local desc = folder:GetDescendants()
            for i = 1, #desc do
                apply(desc[i])
            end
        end
    end
end

local function applyAnimations(model)
    local A = (getgenv().rk and getgenv().rk.Animations) or ANIM
    if not A or not A.Enabled then
        return
    end
    local animate = model:FindFirstChild("Animate")
    if not animate then
        animate = model:WaitForChild("Animate", 3)
    end
    if not animate then
        return
    end
    local pack = A.Pack
    setAnimId(animate, ANIM_KEYS.Walk,  parseAnimId(A.Walk,  "Walk",  pack))
    setAnimId(animate, ANIM_KEYS.Run,   parseAnimId(A.Run,   "Run",   pack))
    setAnimId(animate, ANIM_KEYS.Idle,  parseAnimId(A.Idle,  "Idle",  pack))
    setAnimId(animate, ANIM_KEYS.Jump,  parseAnimId(A.Jump,  "Jump",  pack))
    setAnimId(animate, ANIM_KEYS.Fall,  parseAnimId(A.Fall,  "Fall",  pack))
    setAnimId(animate, ANIM_KEYS.Climb, parseAnimId(A.Climb, "Climb", pack))
    setAnimId(animate, ANIM_KEYS.Swim,  parseAnimId(A.Swim,  "Swim",  pack))
    pcall(function()
        animate.Disabled = true
        animate.Disabled = false
    end)
end

local SCALE_NAMES = {
    "BodyWidthScale", "BodyHeightScale", "BodyDepthScale",
    "HeadScale", "BodyProportionScale", "BodyTypeScale"
}

local function stealAppearance(model, dummy)
    local hum = humOf(model)
    local dhum = humOf(dummy)
    local classes = {"Shirt", "Pants", "ShirtGraphic", "BodyColors"}
    for i = 1, #classes do
        local src = dummy:FindFirstChildOfClass(classes[i])
        if src then
            local old = model:FindFirstChildOfClass(classes[i])
            if old then
                old:Destroy()
            end
            src:Clone().Parent = model
        end
    end
    local kids = model:GetChildren()
    for i = 1, #kids do
        local ch = kids[i]
        if ch:IsA("Accessory") or ch:IsA("Hat") then
            ch:Destroy()
        end
    end
    local dkids = dummy:GetChildren()
    for i = 1, #dkids do
        local ch = dkids[i]
        if ch:IsA("Accessory") or ch:IsA("Hat") then
            local clone = ch:Clone()
            if hum then
                pcall(function()
                    hum:AddAccessory(clone)
                end)
            end
            if clone.Parent ~= model then
                clone.Parent = model
            end
        end
    end
    local dHead = dummy:FindFirstChild("Head")
    local mHead = model:FindFirstChild("Head")
    if dHead and mHead then
        local face = dHead:FindFirstChild("face") or dHead:FindFirstChildOfClass("Decal")
        if face then
            local old = mHead:FindFirstChild("face") or mHead:FindFirstChildOfClass("Decal")
            if old then
                old:Destroy()
            end
            face:Clone().Parent = mHead
        end
    end
    if hum and dhum and hum.RigType == Enum.HumanoidRigType.R15 and dhum.RigType == Enum.HumanoidRigType.R15 then
        local items = Enum.BodyPartR15:GetEnumItems()
        for i = 1, #items do
            local bp = items[i]
            if bp ~= Enum.BodyPartR15.Unknown and bp ~= Enum.BodyPartR15.RootPart then
                local part = dummy:FindFirstChild(bp.Name)
                if part and part:IsA("BasePart") then
                    pcall(function()
                        hum:ReplaceBodyPartR15(bp, part:Clone())
                    end)
                end
            end
        end
    else
        local meshes = dummy:GetChildren()
        for i = 1, #meshes do
            local ch = meshes[i]
            if ch:IsA("CharacterMesh") then
                local olds = model:GetChildren()
                for j = 1, #olds do
                    if olds[j]:IsA("CharacterMesh") and olds[j].BodyPart == ch.BodyPart then
                        olds[j]:Destroy()
                    end
                end
                ch:Clone().Parent = model
            end
        end
    end
    if hum and dhum then
        for i = 1, #SCALE_NAMES do
            local a = hum:FindFirstChild(SCALE_NAMES[i])
            local b = dhum:FindFirstChild(SCALE_NAMES[i])
            if a and b then
                a.Value = b.Value
            end
        end
    end
end

local function applyAvatar(model)
    local A = (getgenv().rk and getgenv().rk.Avatar) or AVATAR
    if not A or not A.Enabled then
        return
    end
    local id = resolveUserId(A.Target)
    if not id then
        return
    end
    local hum = humOf(model)
    if not hum then
        return
    end
    local dummy
    pcall(function()
        dummy = Players:CreateHumanoidModelFromUserId(id)
    end)
    if not dummy then
        local desc
        pcall(function()
            desc = Players:GetHumanoidDescriptionFromUserId(id)
        end)
        if desc then
            pcall(function()
                desc.IdleAnimation = 0
                desc.WalkAnimation = 0
                desc.RunAnimation = 0
                desc.JumpAnimation = 0
                desc.FallAnimation = 0
                desc.ClimbAnimation = 0
                desc.SwimAnimation = 0
            end)
            pcall(function()
                dummy = Players:CreateHumanoidModelFromDescription(desc, hum.RigType)
            end)
            pcall(function()
                hum:ApplyDescription(desc)
            end)
        end
    end
    if dummy then
        dummy.Name = "rk_av"
        dummy.Parent = Workspace
        pcall(function()
            dummy:PivotTo(CFrame.new(0, 10000, 0))
        end)
        task.wait(0.45)
        stealAppearance(model, dummy)
        dummy:Destroy()
    end
    local AN = (getgenv().rk and getgenv().rk.Animations) or ANIM
    if AN and AN.Enabled then
        applyAnimations(model)
    end
end

local function onCharacter(model)
    RK.cache.char[LP] = model
    RK.cache.hum[model] = nil
    RK.cache.hrp[model] = nil
    RK.cache.tool[model] = nil
    track(model.ChildAdded:Connect(function(ch)
        if ch:IsA("Tool") then
            RK.cache.tool[model] = ch
        end
    end))
    track(model.ChildRemoved:Connect(function(ch)
        if ch:IsA("Tool") then
            RK.cache.tool[model] = model:FindFirstChildOfClass("Tool")
        end
    end))
    task.spawn(function()
        model:WaitForChild("Humanoid", 10)
        model:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.35)
        local Av = (getgenv().rk and getgenv().rk.Avatar) or AVATAR
        local An = (getgenv().rk and getgenv().rk.Animations) or ANIM
        if Av and Av.Enabled and Av["Apply On Respawn"] ~= false then
            applyAvatar(model)
        end
        if An and An.Enabled and An["Apply On Respawn"] ~= false then
            applyAnimations(model)
        end
        task.wait(1.1)
        if model.Parent then
            Av = (getgenv().rk and getgenv().rk.Avatar) or AVATAR
            An = (getgenv().rk and getgenv().rk.Animations) or ANIM
            if Av and Av.Enabled and Av["Apply On Respawn"] ~= false then
                applyAvatar(model)
            end
            if An and An.Enabled and An["Apply On Respawn"] ~= false then
                applyAnimations(model)
            end
        end
    end)
end

local function fireCycle(hasTarget)
    local now = os.clock()
    local tbOn = featureOn("tb") and not combatFrozen() and not localBlocked()
    if TB.RequireWeapon and tbOn and not weaponOk() then
        tbOn = false
    end

    local want = false
    local cps = rng(TB.CPS or {8; 11})
    if cps < 1 then
        cps = 1
    elseif cps > 25 then
        cps = 25
    end
    local seq = 1 / cps
    local releaseMs = rng(TB.Release or {8; 16})

    if tbOn and hasTarget then
        local chance = TB["Shoot Chance"] or 100
        if chance >= 100 or math.random(1, 100) <= chance then
            if not RK.state.hadTarget then
                RK.state.acquiredAt = now + rng(TB["First Shot Delay"] or {35; 70}) / 1000
            end
            if now >= RK.state.acquiredAt and now >= RK.state.nextClick then
                want = true
                RK.state.nextClick = now + seq
            end
        end
    end

    RK.state.hadTarget = hasTarget and tbOn

    if want then
        RK.state.fireGen = RK.state.fireGen + 1
        local gen = RK.state.fireGen
        m1down()
        task.delay(releaseMs / 1000, function()
            if RK.state.fireGen == gen then
                m1up()
            end
        end)
    elseif RK.state.m1 and not (tbOn and hasTarget) then
        m1up()
    end

    if not tbOn then
        m1up()
    end
end

local function stepCombat()
    Camera = Workspace.CurrentCamera
    if not featureOn("tb") then
        if RK.state.m1 then
            m1up()
        end
        return
    end
    local has = false
    local mode = TB["Fire When"]
    local _, model
    if mode == "FOV" and TB.FOV and TB.FOV.Enabled then
        _, model = fovHit()
    else
        _, model = crosshairHit()
    end
    has = model ~= nil
    fireCycle(has)
end

track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then
        return
    end
    if inputMatches(BINDS.panic, input) and MAIN.Panic and MAIN.Panic.Enabled then
        RK.state.panic = not RK.state.panic
        if RK.state.panic then
            m1up()
        end
        return
    end
    if inputMatches(BINDS.tb, input) and TB.Mode == "Toggle" then
        RK.state.tbOn = not RK.state.tbOn
    end
    if inputMatches(BINDS.av, input) then
        if AV.Mode == "Toggle" then
            RK.state.avOn = not RK.state.avOn
        end
        RK.state.aimTarget = closestToCursor() or playerFromQuery(AV.Target)
    end
end))

local list0 = Players:GetPlayers()
for i = 1, #list0 do
    local p = list0[i]
    if p ~= LP then
        cachePlayer(p)
        track(p.CharacterAdded:Connect(function(m)
            RK.cache.char[p] = m
            RK.cache.hum[m] = nil
            RK.cache.hrp[m] = nil
            RK.cache.tool[m] = nil
        end))
    end
end

track(Players.PlayerAdded:Connect(function(p)
    cachePlayer(p)
    track(p.CharacterAdded:Connect(function(m)
        RK.cache.char[p] = m
        RK.cache.hum[m] = nil
        RK.cache.hrp[m] = nil
        RK.cache.tool[m] = nil
    end))
    task.delay(0.4, function()
        recountStaff()
        if ST.Enabled and ST.Notify and ST.Notify.Join and isStaff(p) then
            local old = RK.state.notifyOk
            RK.state.notifyOk = true
            notify("rk / staff", p.Name .. " joined  rank " .. tostring(RK.cache.rank[p] or "?"), 5)
            RK.state.notifyOk = old
            if ST["On Staff In Server"] and ST["On Staff In Server"].Panic and MAIN.Panic and MAIN.Panic.Enabled then
                RK.state.panic = true
                m1up()
            end
        end
    end)
end))

track(Players.PlayerRemoving:Connect(function(p)
    RK.cache.friends[p] = nil
    RK.cache.staff[p] = nil
    RK.cache.rank[p] = nil
    RK.cache.char[p] = nil
    RK.state.viewedBy[p] = nil
    RK.state.viewedLock[p] = nil
    if RK.state.aimTarget == p then
        RK.state.aimTarget = nil
    end
    task.defer(recountStaff)
end))

if LP.Character then
    onCharacter(LP.Character)
end
track(LP.CharacterAdded:Connect(onCharacter))

bindStep("rk_combat", Enum.RenderPriority.Last.Value, function()
    if not RK.state.loaded then
        return
    end
    stepCombat()
    if AV.Enabled or RK.state.avOn then
        stepAimView()
    elseif RK.beams[1] then
        RK.beams[1].beam.Enabled = false
    end
end)

track(task.spawn(function()
    while getgenv()._rk == RK do
        staffScan()
        task.wait(ST["Scan Rate"] or 0.25)
    end
end))

bootVisual()
RK.state.loaded = true
RK.state.notifyOk = true
task.delay(0.85, function()
    notify("rk", "pid " .. tostring(game.PlaceId) .. "  re-exec table to reload", 3)
    task.wait(3.2)
    RK.state.notifyOk = false
end)

if TB.Mode == "Always" then
    RK.state.tbOn = true
end
if AV.Mode == "Always" then
    RK.state.avOn = true
    RK.state.aimTarget = playerFromQuery(AV.Target)
end
if AVATAR.Enabled and LP.Character then
    task.spawn(applyAvatar, LP.Character)
end
if ANIM.Enabled and LP.Character then
    task.spawn(applyAnimations, LP.Character)
end