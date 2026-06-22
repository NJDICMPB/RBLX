--[[
    ╔═════════════════════════════════════════════════════════════╗
    ║                       CristineHakdog                        ║
    ║                       Blair - Roblox                        ║
    ║                                                             ║
    ║  Features:                                                  ║
    ║    • Ghost ESP, Object ESP, Items ESP, Room ESP             ║
    ║    • Speed Hack (Toggle)                                    ║
    ║    • Ghost Informations                                     ║
    ╚═════════════════════════════════════════════════════════════╝
--]]

if not game:IsLoaded() then game.Loaded:Wait() end
if game:GetService("HttpService"):JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/".. game.PlaceId .."/universe")).universeId ~= 2239430935 then return; end

--------------------
-- [[ SERVICES ]] --
--------------------
local HttpService   = game:GetService("HttpService")
local Players       = game:GetService("Players")
local StarterGui    = game:GetService("StarterGui")
local Lighting      = game:GetService("Lighting")
local RStorage      = game:GetService("ReplicatedStorage")
local UserIS        = game:GetService("UserInputService")
local RService      = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer.PlayerGui
local Mouse       = LocalPlayer:GetMouse()

if game.PlaceId == 6137321701 then
    StarterGui:SetCore("SendNotification", { Title = "CristineHakdog"; Text = "No Loading in Lobby!" })
    return
end

-- ════════════════════════════════════════════════════════════════
--  LOADING / SUCCESS  UI  (Journal-inspired: dark bg, green border,
--  salmon/pink title, neon green accents)
-- ════════════════════════════════════════════════════════════════
local function MakeNotifGui(titleText, bodyText, isSuccess)
    -- Remove any old notif
    if PlayerGui:FindFirstChild("CristineNotif") then
        PlayerGui:FindFirstChild("CristineNotif"):Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name            = "CristineNotif"
    gui.ResetOnSpawn    = false
    gui.DisplayOrder    = 999
    gui.Parent          = PlayerGui

    -- Dark semi-transparent full-screen tint (only on loading, not success)
    if not isSuccess then
        local overlay = Instance.new("Frame", gui)
        overlay.Size                  = UDim2.new(1,0,1,0)
        overlay.BackgroundColor3      = Color3.fromRGB(0,0,0)
        overlay.BackgroundTransparency = 0.45
        overlay.BorderSizePixel       = 0
        overlay.ZIndex                = 1
    end

    -- Card — matches Journal: rounded, dark purple-black bg, green neon border
    local card = Instance.new("Frame", gui)
    card.AnchorPoint            = Vector2.new(0.5, 0.5)
    card.Position               = UDim2.new(0.5,0, isSuccess and 0.08 or 0.5, 0)
    card.Size                   = UDim2.new(0, isSuccess and 340 or 400, 0, isSuccess and 72 or 130)
    card.BackgroundColor3       = Color3.fromRGB(18, 10, 22)
    card.BackgroundTransparency = 0
    card.BorderSizePixel        = 0
    card.ZIndex                 = 2
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color     = isSuccess and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(80, 220, 80)
    stroke.Thickness = 2
    stroke.ZIndex    = 3

    -- Gradient inside card (purple → dark, like journal bg)
    local grad = Instance.new("UIGradient", card)
    grad.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(28, 14, 38)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 22, 14)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(10,  8, 18)),
    })
    grad.Rotation = 135

    -- Icon stripe on the left
    local stripe = Instance.new("Frame", card)
    stripe.Size             = UDim2.new(0, 6, 1, -16)
    stripe.Position         = UDim2.new(0, 8, 0, 8)
    stripe.BackgroundColor3 = isSuccess and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(60, 200, 60)
    stripe.BorderSizePixel  = 0
    stripe.ZIndex           = 3
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(1, 0)

    -- Title — salmon/pink like "Journal" header
    local title = Instance.new("TextLabel", card)
    title.Size               = UDim2.new(1, -32, 0, 28)
    title.Position           = UDim2.new(0, 24, 0, 10)
    title.BackgroundTransparency = 1
    title.Font               = Enum.Font.FredokaOne
    title.Text               = titleText
    title.TextColor3         = isSuccess and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(240, 140, 160)
    title.TextScaled         = true
    title.TextXAlignment     = Enum.TextXAlignment.Left
    title.ZIndex             = 3

    -- Body text
    local body = Instance.new("TextLabel", card)
    body.Size                = UDim2.new(1, -32, 1, -52)
    body.Position            = UDim2.new(0, 24, 0, 42)
    body.BackgroundTransparency = 1
    body.Font                = Enum.Font.SourceSansBold
    body.Text                = bodyText
    body.TextColor3          = Color3.fromRGB(200, 210, 200)
    body.TextScaled          = true
    body.TextXAlignment      = Enum.TextXAlignment.Left
    body.TextYAlignment      = Enum.TextYAlignment.Top
    body.ZIndex              = 3

    -- Spinner dots for loading
    if not isSuccess then
        local dotsLabel = Instance.new("TextLabel", card)
        dotsLabel.Size               = UDim2.new(1,-32, 0, 18)
        dotsLabel.Position           = UDim2.new(0, 24, 1, -26)
        dotsLabel.BackgroundTransparency = 1
        dotsLabel.Font               = Enum.Font.FredokaOne
        dotsLabel.Text               = "● ● ●"
        dotsLabel.TextColor3         = Color3.fromRGB(80, 200, 80)
        dotsLabel.TextScaled         = true
        dotsLabel.TextXAlignment     = Enum.TextXAlignment.Left
        dotsLabel.ZIndex             = 3
        -- Animate dots opacity
        task.spawn(function()
            local chars = {"●      ●      ●", "●  ●  ●", "● ● ●", "●●●"}
            local idx = 1
            while gui.Parent do
                dotsLabel.Text = chars[idx]
                idx = (idx % #chars) + 1
                task.wait(0.35)
            end
        end)
    end

    return gui
end

-- Show LOADING ui immediately
local LoadingGui = MakeNotifGui("✦ CristineHakdog", "Loading Blair Script…", false)

-- ════════════════════════════════════════════════════════════════
--  WAIT FOR GAME
-- ════════════════════════════════════════════════════════════════
print("Loading Blair Script!")
repeat task.wait(.1) until game.Workspace:FindFirstChild(LocalPlayer.Name)
repeat task.wait(.1) until game.Workspace[LocalPlayer.Name]:FindFirstChild("HumanoidRootPart")
repeat task.wait(.1) until game.Workspace:FindFirstChild("Map")
repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Van")
repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Doors")
repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Items")
repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Zones")
repeat task.wait(.1) until PlayerGui:FindFirstChild("Journal")
repeat task.wait(.1) until RStorage:FindFirstChild("ActiveChallenges")
repeat task.wait(.1) until RStorage:FindFirstChild("Remotes")
task.wait(5)

local Success, Result = pcall(function()

-- ════════════════════════════════════════════════════════════════
--  UTILITY MODULE
-- ════════════════════════════════════════════════════════════════
local Utility = (function()
local U = { Threads = {}; AllIDs = {}; FoundAnything = ""; ActualHour = os.date("!*t").hour; }
do
    function U:Instance(Name, Data)
        local obj = Instance.new(Name, Data.Parent)
        for k, v in next, Data do
            if k ~= "Parent" then
                if typeof(v) == "Instance" then v.Parent = obj else obj[k] = v end
            end
        end
        return obj
    end
    function U:CombineTable(...) local t={} for _,v in ipairs({...}) do for _,x in ipairs(v) do table.insert(t,x) end end return t end
    function U:GetTableKeys(T) local t={} for k in pairs(T) do table.insert(t,k) end return t end
    function U:SaveConfig(Config, Dir, File)
        if not isfolder(Dir) then
            local parts = Dir:split("/"); local tmp = parts[1]; makefolder(tmp)
            for _,f in pairs(parts) do if f~=tmp then tmp=tmp.."/"..f; makefolder(tmp) end end
        end
        writefile(Dir.."/"..File, HttpService:JSONEncode(Config))
        return self:LoadConfig(Config, Dir, File)
    end
    function U:LoadConfig(Config, Dir, File)
        local ok, res = pcall(function()
            if not isfolder(Dir) then
                local parts = Dir:split("/"); local tmp = parts[1]; makefolder(tmp)
                for _,f in pairs(parts) do if f~=tmp then tmp=tmp.."/"..f; makefolder(tmp) end end
            end
            return HttpService:JSONDecode(readfile(Dir.."/"..File))
        end)
        return ok and res or self:SaveConfig(Config, Dir, File)
    end
    function U:Thread(ID, Callback)
        local t = coroutine.create(Callback); self.Threads[ID] = t
        return setmetatable({ ID=ID; Thread=t;
            Start  = function() coroutine.resume(t) end;
            Stop   = function() coroutine.close(t) end;
            Status = function() return coroutine.status(t) end;
        }, {})
    end
    function U:Teleporter(PlaceID)
        local Last; local ServerFile = pcall(function() U.AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json")) end)
        if not ServerFile then table.insert(U.AllIDs, U.ActualHour); writefile("NotSameServers.json", HttpService:JSONEncode(U.AllIDs)) end
        local Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..PlaceID..'/servers/Public?sortOrder=Asc&limit=100'..(U.FoundAnything~="" and "&cursor="..U.FoundAnything or "")))
        if Site.nextPageCursor and Site.nextPageCursor~="null" and Site.nextPageCursor~=nil then U.FoundAnything = Site.nextPageCursor end
        local Num,ExtraNum = 0,0
        for _,Server in pairs(Site.data) do
            ExtraNum+=1; local Possible=true; local ID=tostring(Server.id)
            if tonumber(Server.maxPlayers)>tonumber(Server.playing) then
                if ExtraNum~=1 and tonumber(Server.playing)<Last or ExtraNum==1 then Last=tonumber(Server.playing) elseif ExtraNum~=1 then continue end
                for _,Existing in pairs(U.AllIDs) do
                    if Num~=0 then if ID==tostring(Existing) then Possible=false end
                    else if tonumber(U.ActualHour)~=tonumber(Existing) then pcall(function() delfile("NotSameServers.json"); U.AllIDs={}; table.insert(U.AllIDs,U.ActualHour) end) end end
                    Num+=1
                end
                if Possible then table.insert(U.AllIDs,ID); task.wait(); pcall(function() writefile("NotSameServers.json",HttpService:JSONEncode(U.AllIDs)); task.wait(); game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID,ID,LocalPlayer) end); task.wait(4) end
            end
        end
    end
end
return U
end)()

-- ════════════════════════════════════════════════════════════════
--  BLAIR DATA
-- ════════════════════════════════════════════════════════════════
local BlairData = {
    ["Ghost Type"] = {
        ["Banshee"]     ={["Evidence"]={"EMF Level 5","SLS Anomaly","Freezing Temp."}};
        ["Demon"]       ={["Evidence"]={"Freezing Temp.","Ghost Writing","Spirit Box"}};
        ["Faejkur"]     ={["Evidence"]={"EMF Level 5","Freezing Temp.","Ghost Writing"}};
        ["Harrow"]      ={["Evidence"]={"SLS Anomaly","Ghost Orb","Ghost Writing"}};
        ["Lament"]      ={["Evidence"]={"Ghost Orb","EMF Level 5","Spirit Box"}};
        ["Mare"]        ={["Evidence"]={"Freezing Temp.","SLS Anomaly","Spirit Box"}};
        ["Nook"]        ={["Evidence"]={"EMF Level 5","Freezing Temp.","Ghost Orb"}};
        ["Poltergeist"] ={["Evidence"]={"Ultraviolet","Ghost Orb","Spirit Box"}};
        ["Revenant"]    ={["Evidence"]={"EMF Level 5","Ultraviolet","Ghost Writing"}};
        ["Shade"]       ={["Evidence"]={"EMF Level 5","SLS Anomaly","Ghost Writing"}};
        ["Spirit"]      ={["Evidence"]={"Ultraviolet","Ghost Writing","Spirit Box"}};
        ["Strigoi"]     ={["Evidence"]={"Ultraviolet","Ghost Orb","EMF Level 5"}};
        ["Vuult"]       ={["Evidence"]={"EMF Level 5","Ghost Orb","SLS Anomaly"}};
        ["Wraith"]      ={["Evidence"]={"Freezing Temp.","Ghost Orb","SLS Anomaly"}};
        ["Yama"]        ={["Evidence"]={"Ghost Writing","Spirit Box","SLS Anomaly"}};
        ["Yurei"]       ={["Evidence"]={"Ultraviolet","Freezing Temp.","Spirit Box"}};
        ["Zozo"]        ={["Evidence"]={"EMF Level 5","Ultraviolet","Spirit Box"}};
    };
    ["Items"] = {
        ["Incense Burner"]={Parent=game.Workspace["Map"]["Items"]};["Lighter"]={Parent=game.Workspace["Map"]["Items"]};
        ["Crucifix"]={Parent=game.Workspace["Map"]["Items"]};["Flashlight"]={Parent=game.Workspace["Map"]["Items"]};
        ["Strong Flashlight"]={Parent=game.Workspace["Map"]["Items"]};["UV Light"]={Parent=game.Workspace["Map"]["Items"]};
        ["GlowStick"]={Parent=game.Workspace["Map"]["Items"]};["Photo Camera"]={Parent=game.Workspace["Map"]["Items"]};
        ["Video Camera"]={Parent=game.Workspace["Map"]["Items"]};["Trail Camera"]={Parent=game.Workspace["Map"]["Items"]};
        ["SLS Camera"]={Parent=game.Workspace["Map"]["Items"]};["EMF Reader"]={Parent=game.Workspace["Map"]["Items"]};
        ["Thermometer"]={Parent=game.Workspace["Map"]["Items"]};["Spirit Box"]={Parent=game.Workspace["Map"]["Items"]};
        ["Ghost Writing Book"]={Parent=game.Workspace["Map"]["Items"]};
        ["Parabolic Microphone"]={Parent=game.Workspace["Map"]["Items"]};
        ["Salt"]={Parent=game.Workspace["Map"]["Items"]};["Sanity Soda"]={Parent=game.Workspace["Map"]["Items"]};
    };
}

-- ════════════════════════════════════════════════════════════════
--  CONFIG
-- ════════════════════════════════════════════════════════════════
local Config = {
    ["CustomSprint"]      = false;
    ["CustomSprintSpeed"] = "13";
    ["Fullbright"]        = false;
    ["NoClipDoor"]        = false;
    ["ESP"]               = false;
    ["ESPList"]           = {};
    ["SideStatus"]        = false;
    ["SideStatusScale"]   = "1";
}
local Directory = "CristineHakdog/Blair"
local File_Name = "Settings.json"
Config = Utility:LoadConfig(Config, Directory, File_Name)

-- Clean up old UI
if PlayerGui.Journal.Background:FindFirstChild("Settings") then PlayerGui.Journal.Background:FindFirstChild("Settings"):Destroy() end
if PlayerGui:FindFirstChild("Statusifier") then PlayerGui:FindFirstChild("Statusifier"):Destroy() end
if PlayerGui:FindFirstChild("ESPPanel")    then PlayerGui:FindFirstChild("ESPPanel"):Destroy()    end

-- ════════════════════════════════════════════════════════════════
--  COLOURS (Journal palette)
-- ════════════════════════════════════════════════════════════════
-- Journal uses: deep purple-black bg, bright green neon borders,
-- salmon/pink headings, white body text, dark inner panels
local C = {
    BG          = Color3.fromRGB(18,  10, 22);   -- main card bg
    BG2         = Color3.fromRGB(10,   6, 14);   -- inner panel
    BorderGreen = Color3.fromRGB(60, 210, 90);   -- journal green border
    BorderRed   = Color3.fromRGB(200,  30, 30);  -- settings bar accent
    Title       = Color3.fromRGB(240, 140, 160); -- salmon like "Journal"
    TitleGreen  = Color3.fromRGB(100, 230, 120); -- green title variant
    Text        = Color3.fromRGB(210, 210, 210);
    TextDim     = Color3.fromRGB(150, 140, 160);
    OnGreen     = Color3.fromRGB(50, 200, 80);
    OnBg        = Color3.fromRGB(10,  60, 20);
    OffGrey     = Color3.fromRGB(60,  55, 70);
    OffBg       = Color3.fromRGB(22,  10, 28);
    BarBg       = Color3.fromRGB(12,   6, 18);
}

-- ════════════════════════════════════════════════════════════════
--  SETTINGS BAR  (attached to Journal like before)
-- ════════════════════════════════════════════════════════════════
local SettingsBar = Utility:Instance("Frame", {
    Name                  = "Settings";
    Parent                = PlayerGui.Journal.Background;
    AnchorPoint           = Vector2.new(0, 1);
    BackgroundColor3      = C.BarBg;
    BackgroundTransparency = 0.05;
    BorderSizePixel       = 0;
    Size                  = UDim2.new(1, 0, 0, 52);
    Utility:Instance("UICorner",   { CornerRadius = UDim.new(0, 10) });
    Utility:Instance("UIStroke",   { Color = C.BorderGreen; Thickness = 1.5 });
    Utility:Instance("UIListLayout",{
        Padding              = UDim.new(0, 5);
        FillDirection        = Enum.FillDirection.Horizontal;
        HorizontalAlignment  = Enum.HorizontalAlignment.Center;
        VerticalAlignment    = Enum.VerticalAlignment.Center;
    });
    Utility:Instance("UIPadding",  { PaddingLeft=UDim.new(0,6); PaddingRight=UDim.new(0,6) });
})

-- ────────────────────────────────────────────────────────────────
-- Helper: make a settings button cell
-- Structure:
--   Frame (column)
--     TextBox (optional, top)        ← speed / scale input
--     TextButton (label row, above)  ← "ESP List" / "Close List"  (optional)
--     TextButton (main toggle)
--       TextLabel  (name)
--       Frame      (indicator bar)
-- ────────────────────────────────────────────────────────────────
local function MakeCell(name)
    local col = Utility:Instance("Frame", {
        Name                  = name;
        Parent                = SettingsBar;
        BackgroundTransparency = 1;
        BorderSizePixel       = 0;
        Size                  = UDim2.new(0, 88, 1, -6);
        Utility:Instance("UIListLayout", {
            Padding             = UDim.new(0, 2);
            FillDirection       = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            VerticalAlignment   = Enum.VerticalAlignment.Center;
        });
    })
    return col
end

local function MakeTextInput(parent, placeholder, configKey)
    local val = (configKey and Config[configKey]) or placeholder
    local box = Utility:Instance("TextBox", {
        Parent                = parent;
        BackgroundColor3      = C.BG2;
        BackgroundTransparency = 0;
        BorderSizePixel       = 0;
        Size                  = UDim2.new(1, 0, 0, 16);
        Font                  = Enum.Font.FredokaOne;
        Text                  = tostring(val);
        PlaceholderText       = placeholder;
        PlaceholderColor3     = C.TextDim;
        TextColor3            = C.Text;
        TextScaled            = true;
        ClearTextOnFocus      = false;
        Utility:Instance("UICorner",  { CornerRadius = UDim.new(0, 4) });
        Utility:Instance("UIStroke",  { Color = C.BorderGreen; Thickness = 1 });
    })
    box:GetPropertyChangedSignal("Text"):Connect(function()
        box.Text = string.match(box.Text, "%d*[%.]?%d*") or ""
    end)
    box.FocusLost:Connect(function()
        if configKey then
            Config[configKey] = box.Text
            Utility:SaveConfig(Config, Directory, File_Name)
        end
    end)
    return box
end

local function MakeTopBtn(parent, text, width)
    local btn = Utility:Instance("TextButton", {
        Parent                = parent;
        BackgroundColor3      = C.BG2;
        BackgroundTransparency = 0;
        BorderSizePixel       = 0;
        Size                  = UDim2.new(1, 0, 0, 14);
        Font                  = Enum.Font.FredokaOne;
        Text                  = text;
        TextColor3            = C.TitleGreen;
        TextScaled            = true;
        Utility:Instance("UICorner",  { CornerRadius = UDim.new(0, 4) });
        Utility:Instance("UIStroke",  { Color = C.BorderGreen; Thickness = 1 });
    })
    return btn
end

local function MakeToggleBtn(parent, labelText, enabled)
    local btn = Utility:Instance("TextButton", {
        Parent                = parent;
        BackgroundColor3      = enabled and C.OnBg or C.OffBg;
        BackgroundTransparency = 0;
        BorderSizePixel       = 0;
        Size                  = UDim2.new(1, 0, 0, enabled and 26 or 26);
        Text                  = "";
        Utility:Instance("UICorner",  { CornerRadius = UDim.new(0, 6) });
        Utility:Instance("UIStroke",  { Color = enabled and C.OnGreen or C.OffGrey; Thickness = 1.2 });
        Utility:Instance("TextLabel", {
            Name                  = "Label";
            AnchorPoint           = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            Position              = UDim2.new(0.5, 0, 0.44, 0);
            Size                  = UDim2.new(0.95, 0, 0.6, 0);
            Font                  = Enum.Font.FredokaOne;
            Text                  = labelText;
            TextColor3            = enabled and C.OnGreen or C.TextDim;
            TextScaled            = true;
            TextStrokeTransparency = 0.6;
            TextStrokeColor3      = Color3.fromRGB(0,0,0);
        });
        Utility:Instance("Frame", {
            Name             = "Bar";
            AnchorPoint      = Vector2.new(0.5, 1);
            BackgroundColor3 = enabled and C.OnGreen or C.OffGrey;
            BorderSizePixel  = 0;
            Position         = UDim2.new(0.5, 0, 1, -1);
            Size             = UDim2.new(0.7, 0, 0, 2);
            Utility:Instance("UICorner", { CornerRadius = UDim.new(1,0) });
        });
    })
    return btn
end

local function SetToggleVisual(btn, on)
    btn.BackgroundColor3        = on and C.OnBg  or C.OffBg
    btn["UIStroke"].Color       = on and C.OnGreen or C.OffGrey
    btn["Label"].TextColor3     = on and C.OnGreen or C.TextDim
    btn["Bar"].BackgroundColor3 = on and C.OnGreen or C.OffGrey
end

-- ════════════════════════════════════════════════════════════════
--  ESP FLOATING PANEL  (Journal-styled: dark, green border, salmon title)
-- ════════════════════════════════════════════════════════════════
local ESPPanelGui = Utility:Instance("ScreenGui", {
    Name          = "ESPPanel";
    Parent        = PlayerGui;
    ResetOnSpawn  = false;
    DisplayOrder  = 98;
})
local ESPOverlay = Utility:Instance("TextButton", {
    Parent                = ESPPanelGui;
    BackgroundColor3      = Color3.fromRGB(0,0,0);
    BackgroundTransparency = 0.55;
    BorderSizePixel       = 0;
    Size                  = UDim2.new(1,0,1,0);
    Text                  = "";
    ZIndex                = 1;
    Visible               = false;
})
local ESPCard = Utility:Instance("Frame", {
    Parent                = ESPPanelGui;
    AnchorPoint           = Vector2.new(0.5, 0.5);
    Position              = UDim2.new(0.5, 0, 0.5, 0);
    Size                  = UDim2.new(0, 360, 0, 440);
    BackgroundColor3      = C.BG;
    BackgroundTransparency = 0;
    BorderSizePixel       = 0;
    ZIndex                = 2;
    Visible               = false;
    ClipsDescendants      = true;
    Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 14) });
    Utility:Instance("UIStroke", { Color = C.BorderGreen; Thickness = 2; ZIndex = 3 });
    Utility:Instance("UIGradient", {
        Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(28,14,38));
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12,22,12));
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 8,18));
        });
        Rotation = 135;
    });
})

-- Title bar (like Journal header)
local ESPTitleBar = Utility:Instance("Frame", {
    Parent                = ESPCard;
    BackgroundColor3      = Color3.fromRGB(14, 8, 20);
    BackgroundTransparency = 0;
    BorderSizePixel       = 0;
    Size                  = UDim2.new(1, 0, 0, 40);
    ZIndex                = 3;
    Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 14) });
})
Utility:Instance("TextLabel", {
    Parent                = ESPTitleBar;
    AnchorPoint           = Vector2.new(0, 0.5);
    BackgroundTransparency = 1;
    Position              = UDim2.new(0, 14, 0.5, 0);
    Size                  = UDim2.new(0.7, 0, 0.85, 0);
    Font                  = Enum.Font.FredokaOne;
    Text                  = "ESP Targets";
    TextColor3            = C.Title;
    TextScaled            = true;
    TextXAlignment        = Enum.TextXAlignment.Left;
    ZIndex                = 4;
})
local ESPCloseBtn = Utility:Instance("TextButton", {
    Parent                = ESPTitleBar;
    AnchorPoint           = Vector2.new(1, 0.5);
    BackgroundColor3      = Color3.fromRGB(60, 10, 10);
    BackgroundTransparency = 0;
    BorderSizePixel       = 0;
    Position              = UDim2.new(1, -8, 0.5, 0);
    Size                  = UDim2.new(0, 28, 0, 28);
    Font                  = Enum.Font.FredokaOne;
    Text                  = "✕";
    TextColor3            = Color3.fromRGB(255, 180, 180);
    TextScaled            = true;
    ZIndex                = 5;
    Utility:Instance("UICorner", { CornerRadius = UDim.new(0,8) });
    Utility:Instance("UIStroke", { Color = Color3.fromRGB(180,30,30); Thickness=1; ZIndex=5 });
})

-- Scroll area
local ESPScroll = Utility:Instance("ScrollingFrame", {
    Parent                = ESPCard;
    AnchorPoint           = Vector2.new(0.5, 1);
    BackgroundTransparency = 1;
    BorderSizePixel       = 0;
    Position              = UDim2.new(0.5, 0, 1, -8);
    Size                  = UDim2.new(1, -16, 1, -52);
    ZIndex                = 3;
    AutomaticCanvasSize   = Enum.AutomaticSize.Y;
    CanvasSize            = UDim2.new(0,0,0,0);
    ScrollBarImageColor3  = C.BorderGreen;
    ScrollBarThickness    = 4;
    ScrollingDirection    = Enum.ScrollingDirection.Y;
    Utility:Instance("UIGridLayout", {
        CellSize    = UDim2.new(0.5, -8, 0, 44);
        CellPadding = UDim2.new(0, 6, 0, 6);
        SortOrder   = Enum.SortOrder.LayoutOrder;
    });
    Utility:Instance("UIPadding", {
        PaddingLeft   = UDim.new(0,6);
        PaddingRight  = UDim.new(0,6);
        PaddingTop    = UDim.new(0,4);
        PaddingBottom = UDim.new(0,4);
    });
})

-- Build ESP item list  (+Ghost Room)
local ESPItemList = Utility:CombineTable(
    {"Ghost", "Ghost Room", "BooBoo Doll", "Generator", "Players", "Cursed Object", "Backpack"},
    Utility:GetTableKeys(BlairData["Items"])
)

local ESPSelected = Config["ESPList"] or {}
local ESPButtons  = {}

for _, item in pairs(ESPItemList) do
    local on = table.find(ESPSelected, item) ~= nil

    local row = Utility:Instance("Frame", {
        Name             = item;
        Parent           = ESPScroll;
        BackgroundColor3 = on and Color3.fromRGB(10,50,18) or Color3.fromRGB(14,8,20);
        BorderSizePixel  = 0;
        ZIndex           = 4;
        Utility:Instance("UICorner",  { CornerRadius = UDim.new(0,8) });
        Utility:Instance("UIStroke",  { Color = on and C.BorderGreen or Color3.fromRGB(45,20,60); Thickness=1.2; ZIndex=4 });
    })
    Utility:Instance("TextLabel", {
        Parent                = row;
        Name                  = "Lbl";
        AnchorPoint           = Vector2.new(0,0.5);
        BackgroundTransparency = 1;
        Position              = UDim2.new(0, 8, 0.5, 0);
        Size                  = UDim2.new(1, -46, 1, 0);
        Font                  = Enum.Font.FredokaOne;
        Text                  = item;
        TextColor3            = on and C.OnGreen or C.TextDim;
        TextScaled            = true;
        TextXAlignment        = Enum.TextXAlignment.Left;
        TextTruncate          = Enum.TextTruncate.AtEnd;
        ZIndex                = 5;
    })
    -- Pill toggle
    local pill = Utility:Instance("Frame", {
        Parent           = row;
        AnchorPoint      = Vector2.new(1,0.5);
        BackgroundColor3 = on and C.OnGreen or C.OffGrey;
        BorderSizePixel  = 0;
        Position         = UDim2.new(1,-8, 0.5,0);
        Size             = UDim2.new(0,28,0,14);
        ZIndex           = 5;
        Utility:Instance("UICorner", { CornerRadius = UDim.new(1,0) });
    })
    local dot = Utility:Instance("Frame", {
        Parent           = pill;
        AnchorPoint      = on and Vector2.new(1,0.5) or Vector2.new(0,0.5);
        BackgroundColor3 = Color3.fromRGB(255,255,255);
        BorderSizePixel  = 0;
        Position         = on and UDim2.new(1,-2,0.5,0) or UDim2.new(0,2,0.5,0);
        Size             = UDim2.new(0,10,0,10);
        ZIndex           = 6;
        Utility:Instance("UICorner", { CornerRadius = UDim.new(1,0) });
    })

    local function SetRow(state)
        on = state
        local idx = table.find(ESPSelected, item)
        if state and not idx   then table.insert(ESPSelected, item)
        elseif not state and idx then table.remove(ESPSelected, idx) end

        row.BackgroundColor3        = state and Color3.fromRGB(10,50,18) or Color3.fromRGB(14,8,20)
        row["UIStroke"].Color       = state and C.BorderGreen or Color3.fromRGB(45,20,60)
        row["Lbl"].TextColor3       = state and C.OnGreen or C.TextDim
        pill.BackgroundColor3       = state and C.OnGreen or C.OffGrey
        dot.AnchorPoint             = state and Vector2.new(1,0.5) or Vector2.new(0,0.5)
        dot.Position                = state and UDim2.new(1,-2,0.5,0) or UDim2.new(0,2,0.5,0)

        Config["ESPList"] = ESPSelected
        Utility:SaveConfig(Config, Directory, File_Name)
    end

    -- Click-only (not Down) to avoid scroll mis-taps
    local hitbox = Utility:Instance("TextButton", {
        Parent                = row;
        BackgroundTransparency = 1;
        BorderSizePixel       = 0;
        Size                  = UDim2.new(1,0,1,0);
        Text                  = "";
        ZIndex                = 7;
    })
    hitbox.MouseButton1Click:Connect(function() SetRow(not on) end)
    ESPButtons[item] = { Row=row; SetRow=SetRow }
end

-- Panel open/close
local ESPPanelOpen = false
local function OpenESP()  ESPPanelOpen=true;  ESPOverlay.Visible=true;  ESPCard.Visible=true  end
local function CloseESP() ESPPanelOpen=false; ESPOverlay.Visible=false; ESPCard.Visible=false end
ESPCloseBtn.MouseButton1Click:Connect(CloseESP)
ESPOverlay.MouseButton1Click:Connect(CloseESP)

-- ════════════════════════════════════════════════════════════════
--  SIDEBAR  (CreateInfo)
-- ════════════════════════════════════════════════════════════════
local function CreateInfo(name)
    local sideGui
    if PlayerGui:FindFirstChild("Statusifier") then
        sideGui = PlayerGui:FindFirstChild("Statusifier")
    else
        sideGui = Utility:Instance("ScreenGui", {
            Name="Statusifier"; Parent=PlayerGui; ResetOnSpawn=false; Enabled=Config["SideStatus"];
            Utility:Instance("Frame", {
                Name="Container"; BackgroundTransparency=1;
                Position=UDim2.new(0,8,0.38,0); Size=UDim2.new(0,170,0,0);
                Utility:Instance("UIListLayout", { Padding=UDim.new(0,6) });
                Utility:Instance("UIScale", { Scale=1 });
            });
        })
    end
    local Data = {}
    Data.Frame = Utility:Instance("Frame", {
        Name=name; Parent=sideGui["Container"]; AutomaticSize=Enum.AutomaticSize.Y;
        BackgroundColor3=Color3.fromRGB(14,8,20); BackgroundTransparency=0.05;
        BorderSizePixel=0; Size=UDim2.new(1,0,0,0);
        Utility:Instance("UICorner",  { CornerRadius=UDim.new(0,8) });
        Utility:Instance("UIStroke",  { Color=C.BorderGreen; Thickness=1 });
        Utility:Instance("UIPadding", { PaddingLeft=UDim.new(0,6); PaddingRight=UDim.new(0,6); PaddingBottom=UDim.new(0,4) });
        Utility:Instance("TextLabel", {
            BackgroundTransparency=1; Size=UDim2.new(1,0,0,18);
            Font=Enum.Font.FredokaOne; Text="⚠ "..name:upper();
            TextColor3=C.Title; TextScaled=true;
            TextXAlignment=Enum.TextXAlignment.Left; TextStrokeTransparency=0.5;
        });
        Utility:Instance("Frame", {
            AutomaticSize=Enum.AutomaticSize.Y; BackgroundTransparency=1;
            Position=UDim2.new(0,0,0,20); Size=UDim2.new(1,0,0,0);
            Utility:Instance("UIListLayout", { Padding=UDim.new(0,2) });
        });
    })
    Data.List = Data.Frame["Frame"]
    Data.AddInfo = function(text)
        return Utility:Instance("TextLabel", {
            Parent=Data.List; BackgroundTransparency=1; Size=UDim2.new(1,0,0,16);
            Font=Enum.Font.SourceSansBold; Text=text; TextColor3=C.Text;
            TextScaled=true; TextXAlignment=Enum.TextXAlignment.Left;
            TextStrokeTransparency=0.7; TextStrokeColor3=Color3.fromRGB(0,0,0);
        })
    end
    return Data
end

-- ════════════════════════════════════════════════════════════════
--  CreateESP helper (unchanged logic)
-- ════════════════════════════════════════════════════════════════
local function CreateESP(Type, Properties)
    local Data = {}
    if Type == "Text" then
        if Properties.ParentText and Properties.ParentText:FindFirstChild("ESP_Text") then
            Data.ESP = Properties.ParentText["ESP_Text"]
            Data.ESP.Size        = Properties.Size or UDim2.new(5,0,2,0)
            Data.ESP.StudsOffset = Properties.StudsOffset or Vector3.new(0,2,0)
            Data.ESP.Enabled     = Properties.Enabled or false
            Data.ESP["Title"].Text       = Properties.Text
            Data.ESP["Title"].TextColor3 = Properties.Color or Color3.fromRGB(255,255,255)
            if Properties.Distance and Data.ESP:FindFirstChild("Distance") then Data.Distance = Data.ESP["Distance"]; Data.Distance.TextColor3 = Properties.Color or Color3.fromRGB(255,255,255) end
        elseif Properties.Parent and Properties.Parent:FindFirstChild("ESP_Text") then
            Data.ESP = Properties.Parent["ESP_Text"]
            Data.ESP.Size        = Properties.Size or UDim2.new(5,0,2,0)
            Data.ESP.StudsOffset = Properties.StudsOffset or Vector3.new(0,2,0)
            Data.ESP.Enabled     = Properties.Enabled or false
            Data.ESP["Title"].Text       = Properties.Text
            Data.ESP["Title"].TextColor3 = Properties.Color or Color3.fromRGB(255,255,255)
            if Properties.Distance and Data.ESP:FindFirstChild("Distance") then Data.Distance = Data.ESP["Distance"]; Data.Distance.TextColor3 = Properties.Color or Color3.fromRGB(255,255,255) end
        else
            Data.ESP = Utility:Instance("BillboardGui", {
                Name="ESP_Text"; Parent=Properties.ParentText or Properties.Parent;
                ResetOnSpawn=Properties.ResetOnSpawn or false; AlwaysOnTop=true;
                Enabled=Properties.Enabled or false;
                Size=Properties.Size or UDim2.new(5,0,2,0);
                StudsOffset=Properties.StudsOffset or Vector3.new(0,2,0);
                Utility:Instance("TextLabel", {
                    Name="Title"; BackgroundTransparency=1; Size=UDim2.new(1,0,0.5,0);
                    Font=Enum.Font.FredokaOne; Text=Properties.Text;
                    TextColor3=Properties.Color or Color3.fromRGB(255,255,255); TextScaled=true;
                });
            })
            if Properties.Distance then
                Data.Distance = Utility:Instance("TextLabel", {
                    Name="Distance"; Parent=Data.ESP; BackgroundTransparency=1;
                    Position=UDim2.new(0,0,0.5,0); Size=UDim2.new(1,0,0.5,0);
                    Font=Enum.Font.FredokaOne; Text="0m";
                    TextColor3=Properties.Color or Color3.fromRGB(255,255,255); TextScaled=true;
                })
            end
        end
        if Properties.Distance then
            task.spawn(function()
                while task.wait() do
                    if Data.Destroyed then break end
                    pcall(function() Data.Distance.Text = math.floor((Properties.Distance.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude*100)/100 .."m" end)
                end
            end)
        end
        return setmetatable({ ESP=Data.ESP; Distance=Data.Distance;
            Enable  = function() pcall(function() Data.ESP.Enabled=true  end) end;
            Disable = function() pcall(function() Data.ESP.Enabled=false end) end;
            Destroy = function() pcall(function() Data.Destroyed=true; Data.ESP:Destroy() end) end;
        }, {})
    elseif Type == "Highlight" then
        if Properties.ParentHighlight and Properties.ParentHighlight:FindFirstChild("ESP_Highlight") then Properties.ParentHighlight["ESP_Highlight"]:Destroy() end
        if Properties.Parent          and Properties.Parent:FindFirstChild("ESP_Highlight")          then Properties.Parent["ESP_Highlight"]:Destroy() end
        Data.ESP = Utility:Instance("Highlight", {
            Name="ESP_Highlight"; Parent=Properties.ParentHighlight or Properties.Parent;
            Enabled=Properties.Enabled or false;
            FillColor=Properties.Color or Color3.fromRGB(255,255,255);
            FillTransparency=Properties.FillTransparency or 0.75;
        })
        return setmetatable({ ESP=Data.ESP;
            Enable  = function() pcall(function() Data.ESP.Enabled=true  end) end;
            Disable = function() pcall(function() Data.ESP.Enabled=false end) end;
            Destroy = function() pcall(function() Data.ESP:Destroy() end) end;
        }, {})
    elseif Type == "Text & Highlight" then
        Data.TextESP      = CreateESP("Text",      Properties)
        Data.HighlightESP = CreateESP("Highlight", Properties)
        return setmetatable({ TextESP=Data.TextESP; HighlightESP=Data.HighlightESP;
            Enable  = function() pcall(function() Data.TextESP:Enable();  Data.HighlightESP:Enable()  end) end;
            Disable = function() pcall(function() Data.TextESP:Disable(); Data.HighlightESP:Disable() end) end;
            Destroy = function() pcall(function() Data.TextESP:Destroy(); Data.HighlightESP:Destroy() end) end;
        }, {})
    elseif Type == "Backpack" then
        if Properties.Parent and Properties.Parent:FindFirstChild("ESP_Backpack") then
            Data.ESP = Properties.Parent["ESP_Backpack"]
            Data.ESP.MaxDistance = Properties.MaxDistance or 15
            Data.ESP.Size        = Properties.Size or UDim2.new(2,0,2,0)
            Data.ESP.StudsOffset = Properties.StudsOffset or Vector3.new(2,1,1)
            Data.ESP.Enabled     = Properties.Enabled or false
        else
            Data.ESP = Utility:Instance("BillboardGui", {
                Name="ESP_Backpack"; Parent=Properties.Parent; ResetOnSpawn=Properties.ResetOnSpawn or false;
                AlwaysOnTop=true; MaxDistance=Properties.MaxDistance or 15;
                Size=Properties.Size or UDim2.new(2,0,2,0); StudsOffset=Properties.StudsOffset or Vector3.new(2,1,1);
                Enabled=Properties.Enabled or false;
                Utility:Instance("Frame", {
                    BackgroundTransparency=1; Size=UDim2.new(1,0,1,0);
                    Utility:Instance("UIListLayout", { HorizontalAlignment=Enum.HorizontalAlignment.Center });
                });
            })
        end
        Data.Slots = {}
        for Slot=1,5 do
            if Data.ESP["Frame"]:FindFirstChild("Slot_"..Slot) then Data.Slots[Slot]=Data.ESP["Frame"]:FindFirstChild("Slot_"..Slot)
            else Data.Slots[Slot]=Utility:Instance("TextLabel",{ Name="Slot_"..Slot; Parent=Data.ESP["Frame"]; BackgroundTransparency=1; Size=UDim2.new(1,0,0.2,0); Font=Enum.Font.SourceSansBold; Text=""; TextColor3=Color3.fromRGB(255,255,255); TextScaled=true; TextStrokeTransparency=0 }) end
        end
        return setmetatable({ ESP=Data.ESP; Slots=Data.Slots;
            Enable  = function() pcall(function() Data.ESP.Enabled=true  end) end;
            Disable = function() pcall(function() Data.ESP.Enabled=false end) end;
            Destroy = function() pcall(function() Data.Destroyed=true; Data.ESP:Destroy() end) end;
        }, {})
    end
end

-- ════════════════════════════════════════════════════════════════
--  INITIALIZE  (ESP holders, doors, lighting save)
-- ════════════════════════════════════════════════════════════════
local Sprinting    = false
local Doors        = {}
local function PopulateDoors(Model)
    for _,v in pairs(Model:GetChildren()) do
        if not table.find({"Part","MeshPart","Model"}, v.ClassName) then continue end
        if #v:GetChildren()>0 then PopulateDoors(v) end
        if (v.ClassName=="Part" or v.ClassName=="MeshPart") and v.CanCollide then table.insert(Doors,v) end
    end
end
PopulateDoors(game.Workspace["Map"]["Doors"])

local SavedLighting = {}
for _,k in pairs({"Ambient","OutdoorAmbient","Brightness"}) do SavedLighting[k]=Lighting[k] end
local AtmosphereDensity = Lighting["Atmosphere"].Density

local LowestTemp    = nil
local CryingCount   = 0
local DoorCount     = 0
local ManifestCount = 0
local blinkConnection

local BooBooESP     = {}
local GeneratorESP  = {}
local GhostESP      = {}
local PlayerESP     = {}
local CursedObjESP  = nil
local ItemsESP      = {}
local GhostRoomESP  = nil   -- NEW

task.spawn(function()
    repeat task.wait() until game.Workspace:FindFirstChild("BooBooDoll")
    BooBooESP["Text"]      = CreateESP("Text",      { Text="[BooBoo]";     Distance=game.Workspace["BooBooDoll"]; Parent=game.Workspace["BooBooDoll"]; Color=Color3.fromRGB(0,255,255) })
    BooBooESP["Highlight"] = CreateESP("Highlight", { Parent=game.Workspace["BooBooDoll"]; Color=Color3.fromRGB(0,255,255) })

    repeat task.wait() until #game.Workspace["Map"]["Generators"]:GetChildren()>0
    if game.Workspace["Map"]["Generators"]:GetChildren()[1]:WaitForChild("Highlight",1) then game.Workspace["Map"]["Generators"]:GetChildren()[1]["Highlight"]:Destroy() end
    local Gen = game.Workspace["Map"]["Generators"]:GetChildren()[1]
    GeneratorESP["Text"]      = CreateESP("Text",      { Text="[Generator]"; Distance=Gen; Parent=Gen; Color=Color3.fromRGB(255,16,240) })
    GeneratorESP["Highlight"] = CreateESP("Highlight", { Parent=Gen; Color=Color3.fromRGB(255,16,240) })
end)

if game.Workspace:FindFirstChild("Ghost") then
    if game.Workspace["Ghost"]:WaitForChild("Highlight",1) then game.Workspace["Ghost"]["Highlight"]:Destroy() end
    local G = game.Workspace["Ghost"]
    GhostESP["Text"]      = CreateESP("Text",      { Text="[Ghost]"; Distance=G.PrimaryPart; ParentText=G:WaitForChild("Head"); Color=Color3.fromRGB(255,0,0) })
    GhostESP["Highlight"] = CreateESP("Highlight", { Parent=G; Color=Color3.fromRGB(255,0,0) })
end

for _,player in pairs(Players:GetChildren()) do
    if player==LocalPlayer then continue end
    repeat task.wait() until player.Character
    PlayerESP[player.Name] = {}
    PlayerESP[player.Name]["Player"]   = player
    PlayerESP[player.Name]["ESP"]      = CreateESP("Text & Highlight", { Text=player.DisplayName; ParentText=player.Character:FindFirstChild("Head"); ParentHighlight=player.Character; Color=Color3.fromRGB(255,255,255); FillTransparency=1 })
    PlayerESP[player.Name]["Backpack"] = CreateESP("Backpack", { Parent=player.Character })
end

local function ValidateItemESP(item)
    if item.Name=="Tarot Cards" or item.Name=="Music Box" then return false end
    if not table.find(Utility:GetTableKeys(BlairData["Items"]), item.Name) then return false end
    if item.Name=="Incense Burner" then
        if item:WaitForChild("Used").Value then return false end
        if item:WaitForChild("GhostIncensed").Value then return false end
    end
    if item.Name=="Photo Camera" and item:FindFirstChild("PhotoCameraMemory") then
        if item["PhotoCameraMemory"]:WaitForChild("Memory").Value==100 then return false end
        if item["PhotoCameraMemory"]:WaitForChild("MemoryCapacity").Text=="100/100 MB" then return false end
    end
    return true
end

task.spawn(function()
    task.wait(5)
    for _,item in pairs(game.Workspace["Map"]["Items"]:GetChildren()) do
        if not ValidateItemESP(item) then continue end
        if not table.find(Config["ESPList"], item.Name) then continue end
        local Item = { ["Item"]=item }
        Item["ESP"] = CreateESP("Highlight", { Parent=item; Color=Color3.fromRGB(0,255,0) })
        table.insert(ItemsESP, Item)
    end
end)

-- ════════════════════════════════════════════════════════════════
--  SETTINGS BAR CELLS
-- ════════════════════════════════════════════════════════════════

-- ── Custom Sprint ──────────────────────────────────────────────
local SprintCell     = MakeCell("Sprint")
local SprintSpeedBox = MakeTextInput(SprintCell, "13", "CustomSprintSpeed")
local SprintBtn      = MakeToggleBtn(SprintCell, "Custom Sprint", Config["CustomSprint"])
SprintBtn.MouseButton1Click:Connect(function()
    Config["CustomSprint"] = not Config["CustomSprint"]
    SetToggleVisual(SprintBtn, Config["CustomSprint"])
    Utility:SaveConfig(Config, Directory, File_Name)
end)

-- ── Fullbright ─────────────────────────────────────────────────
local FBCell = MakeCell("Fullbright")
local FBBtn  = MakeToggleBtn(FBCell, "Fullbright", Config["Fullbright"])
FBBtn.Size   = UDim2.new(1, 0, 1, -6)   -- taller since no textbox above
FBBtn.MouseButton1Click:Connect(function()
    Config["Fullbright"] = not Config["Fullbright"]
    SetToggleVisual(FBBtn, Config["Fullbright"])
    Utility:SaveConfig(Config, Directory, File_Name)
    if Config["Fullbright"] then
        Lighting.Ambient         = Color3.fromRGB(138,138,138)
        Lighting.OutdoorAmbient  = Color3.fromRGB(128,128,128)
        Lighting.Brightness      = 2
        Lighting["Atmosphere"].Density = 0
    else
        for k,v in pairs(SavedLighting) do Lighting[k]=v end
        Lighting["Atmosphere"].Density = AtmosphereDensity
    end
end)
UserIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        Config["Fullbright"] = not Config["Fullbright"]
        SetToggleVisual(FBBtn, Config["Fullbright"])
        Utility:SaveConfig(Config, Directory, File_Name)
        if Config["Fullbright"] then
            Lighting.Ambient=Color3.fromRGB(138,138,138); Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
            Lighting.Brightness=2; Lighting["Atmosphere"].Density=0
        else
            for k,v in pairs(SavedLighting) do Lighting[k]=v end
            Lighting["Atmosphere"].Density=AtmosphereDensity
        end
    end
end)

-- ── No Clip Door ───────────────────────────────────────────────
local NCCell = MakeCell("NoClip")
local NCBtn  = MakeToggleBtn(NCCell, "No Clip Door", Config["NoClipDoor"])
NCBtn.Size   = UDim2.new(1, 0, 1, -6)
NCBtn.MouseButton1Click:Connect(function()
    Config["NoClipDoor"] = not Config["NoClipDoor"]
    SetToggleVisual(NCBtn, Config["NoClipDoor"])
    Utility:SaveConfig(Config, Directory, File_Name)
    if Config["NoClipDoor"] then
        for _,v in pairs(Doors) do v.CanCollide=false end
        game.Workspace["Map"]["Van"]["Van"]["Door"]["Lines"]["Part"].CanCollide=false
        game.Workspace["Map"]["Van"]["Van"]["Door"]["Main"].CanCollide=false
    else
        for _,v in pairs(Doors) do v.CanCollide=true end
        game.Workspace["Map"]["Van"]["Van"]["Door"]["Lines"]["Part"].CanCollide=true
        game.Workspace["Map"]["Van"]["Van"]["Door"]["Main"].CanCollide=true
    end
end)
UserIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        Config["NoClipDoor"] = not Config["NoClipDoor"]
        SetToggleVisual(NCBtn, Config["NoClipDoor"])
        Utility:SaveConfig(Config, Directory, File_Name)
        if Config["NoClipDoor"] then
            for _,v in pairs(Doors) do v.CanCollide=false end
            game.Workspace["Map"]["Van"]["Van"]["Door"]["Lines"]["Part"].CanCollide=false
            game.Workspace["Map"]["Van"]["Van"]["Door"]["Main"].CanCollide=false
        else
            for _,v in pairs(Doors) do v.CanCollide=true end
            game.Workspace["Map"]["Van"]["Van"]["Door"]["Lines"]["Part"].CanCollide=true
            game.Workspace["Map"]["Van"]["Van"]["Door"]["Main"].CanCollide=true
        end
    end
end)

-- ── ESP  (ESP List btn on top, ESP toggle below) ───────────────
local ESPCell    = MakeCell("ESP")
local ESPListBtn = MakeTopBtn(ESPCell, "☰ ESP List")
local ESPBtn     = MakeToggleBtn(ESPCell, "ESP", Config["ESP"])

ESPListBtn.MouseButton1Click:Connect(function()
    if ESPPanelOpen then
        CloseESP()
        ESPListBtn.Text = "☰ ESP List"
    else
        OpenESP()
        ESPListBtn.Text = "✕ Close List"
    end
end)
-- Also close panel → reset button text
ESPCloseBtn.MouseButton1Click:Connect(function() ESPListBtn.Text = "☰ ESP List" end)
ESPOverlay.MouseButton1Click:Connect(function()  ESPListBtn.Text = "☰ ESP List" end)

ESPBtn.MouseButton1Click:Connect(function()
    Config["ESP"] = not Config["ESP"]
    SetToggleVisual(ESPBtn, Config["ESP"])
    Utility:SaveConfig(Config, Directory, File_Name)
end)

-- ── Side Status ────────────────────────────────────────────────
local SideCell     = MakeCell("Status")
local SideScaleBox = MakeTextInput(SideCell, "1", "SideStatusScale")
local SideBtn      = MakeToggleBtn(SideCell, "Side Status", Config["SideStatus"])
SideBtn.MouseButton1Click:Connect(function()
    Config["SideStatus"] = not Config["SideStatus"]
    SetToggleVisual(SideBtn, Config["SideStatus"])
    Utility:SaveConfig(Config, Directory, File_Name)
    if PlayerGui:FindFirstChild("Statusifier") then
        PlayerGui["Statusifier"].Enabled = Config["SideStatus"]
    end
end)

-- ════════════════════════════════════════════════════════════════
--  CURSED OBJECT SIDEBAR
-- ════════════════════════════════════════════════════════════════
local Objects = CreateInfo("Cursed Object")
task.spawn(function()
    pcall(function()
        local function AddCursedESP(Display, Parent)
            CursedObjESP = CreateESP("Text", { Text=Display; Parent=Parent; Color=Color3.fromRGB(215,252,0) })
            if Config["ESP"] and table.find(Config["ESPList"],"Cursed Object") then CursedObjESP:Enable() else CursedObjESP:Disable() end
        end
        local function FindInPlayers(Name)
            for _,P in pairs(Players:GetChildren()) do
                if P.Backpack:FindFirstChild(Name) then return P.Backpack:FindFirstChild(Name) end
                if P.Character and P.Character:FindFirstChild(Name) then return P.Character:FindFirstChild(Name) end
            end
        end
        local function TryFind(Name, Parent, T)
            local f = Parent:WaitForChild(Name, T or 10)
            if f then return f end
            return FindInPlayers(Name)
        end

        local SC = game.Workspace:WaitForChild("SummoningCircle", 10)
        if SC then Objects.AddInfo("Summoning Circle"); AddCursedESP("[Summoning Circle]", SC) end
        local SB = game.Workspace:WaitForChild("Spirit Board", 10)
        if SB then Objects.AddInfo("Spirit Board"); AddCursedESP("[Spirit Board]", SB) end
        local TC = TryFind("Tarot Cards", game.Workspace["Map"]["Items"], 10) or FindInPlayers("Tarot Cards")
        if TC then Objects.AddInfo("Tarot Cards"); AddCursedESP("[Tarot Cards]", TC) end
        local MB = TryFind("Music Box", game.Workspace["Map"]["Items"], 10) or FindInPlayers("Music Box")
        if MB then Objects.AddInfo("Music Box"); AddCursedESP("[Music Box]", MB) end

        game.Workspace.ChildAdded:Connect(function(c)
            if c.Name=="SummoningCircle" then Objects.AddInfo("Summoning Circle"); AddCursedESP("[Summoning Circle]", c) end
            if c.Name=="Spirit Board"    then Objects.AddInfo("Spirit Board");     AddCursedESP("[Spirit Board]", c)     end
        end)
        game.Workspace["Map"]["Items"].ChildAdded:Connect(function(c)
            if c.Name=="Tarot Cards" then Objects.AddInfo("Tarot Cards"); AddCursedESP("[Tarot Cards]", c) end
            if c.Name=="Music Box"   then Objects.AddInfo("Music Box");   AddCursedESP("[Music Box]", c)   end
        end)
        for _,P in pairs(Players:GetChildren()) do
            P.CharacterAdded:Connect(function(char)
                char.ChildAdded:Connect(function(c)
                    if c.Name=="Tarot Cards" then AddCursedESP("[Tarot Cards]", c) end
                    if c.Name=="Music Box"   then AddCursedESP("[Music Box]", c)   end
                end)
            end)
            P.Backpack.ChildAdded:Connect(function(c)
                if c.Name=="Tarot Cards" then AddCursedESP("[Tarot Cards]", c) end
                if c.Name=="Music Box"   then AddCursedESP("[Music Box]", c)   end
            end)
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
--  ROOM SIDEBAR  (+ Ghost Room ESP)
-- ════════════════════════════════════════════════════════════════
local Room         = CreateInfo("Possible Room")
local RoomName     = Room.AddInfo("Room Name")
local RoomTemp     = Room.AddInfo("Room Temp")
local RoomWater    = Room.AddInfo("Water Running")
local RoomSalt     = Room.AddInfo("Salt Stepped"); RoomSalt.Visible=false
local RoomCrying   = Room.AddInfo("Ghost Crying"); RoomCrying.Visible=false
local RoomDoor     = Room.AddInfo("Door Interact"); RoomDoor.Visible=false
local RoomManifest = Room.AddInfo("Manifest");      RoomManifest.Visible=false

local RoomThread = Utility:Thread("Room", function()
    local CurHighlightRoom = nil
    local RoomESPObj = nil
    while task.wait() do
        local LowestRoom = nil
        for _,v in pairs(game.Workspace["Map"]["Zones"]:GetChildren()) do
            if v.ClassName~="Part" and v.ClassName~="UnionOperation" then continue end
            if v:FindFirstChild("Exclude") then continue end
            if not v:FindFirstChild("_____Temperature") then continue end
            if not v["_____Temperature"]:FindFirstChild("_____LocalBaseTemp") then continue end
            if LowestRoom==nil then LowestRoom=v; continue end
            if v["_____Temperature"]["_____LocalBaseTemp"].Value > LowestRoom["_____Temperature"]["_____LocalBaseTemp"].Value then continue end
            LowestRoom = v
        end
        if LowestRoom and LowestRoom["_____Temperature"] then
            local raw  = LowestRoom["_____Temperature"].Value
            local ti   = math.floor(raw*100)
            local tw   = math.floor(ti/100)
            local td   = math.abs(ti)%100
            local tstr = tostring(tw)..".".. (td<10 and "0"..tostring(td) or tostring(td))
            RoomName.Text = "Room: "..LowestRoom.Name
            RoomTemp.Text = "Temp: "..tstr.."°C"
            LowestTemp    = LowestRoom

            -- Ghost Room ESP (new)
            if CurHighlightRoom ~= LowestRoom then
                -- Destroy old
                if RoomESPObj then pcall(function() RoomESPObj.Destroy() end) end
                pcall(function()
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:FindFirstChild("RoomESP_Att0") then hrp:FindFirstChild("RoomESP_Att0"):Destroy() end
                    if game.Workspace.Terrain:FindFirstChild("RoomESP_Att1") then game.Workspace.Terrain:FindFirstChild("RoomESP_Att1"):Destroy() end
                    if game.Workspace.Terrain:FindFirstChild("RoomESP_Beam") then game.Workspace.Terrain:FindFirstChild("RoomESP_Beam"):Destroy() end
                end)

                -- Create new floating label
                RoomESPObj = CreateESP("Text", {
                    Text        = "[Ghost Room] "..LowestRoom.Name;
                    Parent      = LowestRoom;
                    Distance    = LowestRoom;
                    Color       = Color3.fromRGB(255,140,0);
                    Size        = UDim2.new(8,0,2,0);
                    StudsOffset = Vector3.new(0,5,0);
                })
                -- Only show if ESP + Ghost Room selected
                if Config["ESP"] and table.find(Config["ESPList"],"Ghost Room") then
                    RoomESPObj.Enable()
                else
                    RoomESPObj.Disable()
                end

                -- Beam
                pcall(function()
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local att0 = Instance.new("Attachment"); att0.Name="RoomESP_Att0"; att0.Parent=hrp
                    local att1 = Instance.new("Attachment"); att1.Name="RoomESP_Att1"; att1.WorldPosition=LowestRoom.Position; att1.Parent=game.Workspace.Terrain
                    local beam = Instance.new("Beam")
                    beam.Name="RoomESP_Beam"; beam.Attachment0=att0; beam.Attachment1=att1
                    beam.Color=ColorSequence.new(Color3.fromRGB(255,140,0)); beam.Width0=0.1; beam.Width1=0.1
                    beam.FaceCamera=true; beam.LightEmission=1; beam.Transparency=NumberSequence.new(0.2)
                    beam.Parent=game.Workspace.Terrain
                end)
                CurHighlightRoom = LowestRoom
            else
                if RoomESPObj and RoomESPObj.ESP then
                    pcall(function() RoomESPObj.ESP["Title"].Text = "[Ghost Room] "..LowestRoom.Name end)
                end
            end
        end

        local FoundWater=false
        for _,w in pairs(game.Workspace["Map"]["Water"]:GetChildren()) do
            if #w:GetChildren()>0 and w:FindFirstChild("WaterRunning") then FoundWater=true; break end
        end
        RoomWater.Visible = FoundWater
        if not RoomSalt.Visible then
            for _,s in pairs(game.Workspace["Map"]["Misc"]:GetChildren()) do
                if s.Name=="SaltStepped" then RoomSalt.Visible=true end
            end
        end
        if CryingCount>0   then RoomCrying.Visible=true;   RoomCrying.Text="Ghost Crying: "..CryingCount   end
        if DoorCount>0     then RoomDoor.Visible=true;     RoomDoor.Text="Door Interact: "..DoorCount       end
        if ManifestCount>0 then RoomManifest.Visible=true; RoomManifest.Text="Manifest: "..ManifestCount    end
    end
end):Start()

-- ════════════════════════════════════════════════════════════════
--  GHOST SIDEBAR
-- ════════════════════════════════════════════════════════════════
local Ghost        = CreateInfo("Ghost Status")
local GhostActivity   = Ghost.AddInfo("Activity")
local GhostLocation   = Ghost.AddInfo("Location")
local GhostSpeed      = Ghost.AddInfo("WalkSpeed")
local GhostBlink      = Ghost.AddInfo("Blink")
local GhostDuration   = Ghost.AddInfo("Duration")
local GhostDisruption = Ghost.AddInfo("Disrupting")
local GhostBanshee    = Ghost.AddInfo("Banshee Scream"); GhostBanshee.Visible=false
local GhostFaejkur    = Ghost.AddInfo("Faejkur Laugh");  GhostFaejkur.Visible=false
local GhostYama       = Ghost.AddInfo("Yama Roar");      GhostYama.Visible=false

local function FindParabolic(Obj)
    for _,p in pairs(Obj:GetChildren()) do
        if p.Name~="Parabolic Microphone" then continue end
        if p:FindFirstChild("Handle") then
            if p.Handle:FindFirstChild("BansheeScream") and p.Handle["BansheeScream"].Playing then GhostBanshee.Visible=true end
            if p.Handle:FindFirstChild("FaeLaugh")      and p.Handle["FaeLaugh"].Playing      then GhostFaejkur.Visible=true end
        end
    end
end

Utility:Thread("Ghost", function()
    while task.wait() do
        GhostActivity.Text = "Activity: "..RStorage["Activity"].Value
        GhostDisruption.Visible = RStorage["Disruption"].Value and true or false
        if game.Workspace:FindFirstChild("Ghost") then
            if game.Workspace["Ghost"]:FindFirstChild("Hunting") then
                if game.Workspace["Ghost"]["Hunting"].Value then
                    for _,v in pairs({GhostLocation,GhostSpeed,GhostBlink,GhostDuration}) do v.Visible=true end
                else
                    GhostLocation.Visible=true
                end
            end
            pcall(function()
                local G = game.Workspace:WaitForChild("Ghost",5)
                GhostLocation.Text = G:WaitForChild("Zone",5).Value.Name or ""
                GhostSpeed.Text    = "Walk Speed: "..math.floor(G.Humanoid.WalkSpeed*1000)/1000
                GhostDuration.Text = "Duration: "..RStorage["HuntDuration"].Value
            end)
        else
            for _,v in pairs({GhostLocation,GhostSpeed,GhostBlink,GhostDuration}) do v.Visible=false end
        end
        if not GhostBanshee.Visible or not GhostFaejkur.Visible then
            for _,P in pairs(Players:GetChildren()) do if P.Character then FindParabolic(P.Character) end end
            FindParabolic(game.Workspace["Map"]["Items"])
        end
    end
end):Start()

if game.Workspace:FindFirstChild("Ghost") then
    local stamp=tick()
    pcall(function()
        blinkConnection = game.Workspace["Ghost"]:WaitForChild("Head"):GetPropertyChangedSignal("Transparency"):Connect(function()
            GhostBlink.Text = "Blink: "..math.floor((tick()-stamp)*1000)/1000 .."s"; stamp=tick()
        end)
    end)
end

game.Workspace.ChildAdded:Connect(function(inst)
    if inst.Name~="Ghost" then return end
    if inst:WaitForChild("Highlight",1) then inst["Highlight"]:Destroy() end
    GhostESP["Text"]      = CreateESP("Text",      { Text="[Ghost]"; Distance=inst.PrimaryPart; Parent=inst:WaitForChild("Head",1); Color=Color3.fromRGB(255,0,0) })
    GhostESP["Highlight"] = CreateESP("Highlight", { Parent=inst; Color=Color3.fromRGB(255,0,0) })
    local stamp=tick()
    pcall(function()
        blinkConnection = inst:WaitForChild("Head",1):GetPropertyChangedSignal("Transparency"):Connect(function()
            GhostBlink.Text="Blink: "..math.floor((tick()-stamp)*1000)/1000 .."s"; stamp=tick()
        end)
    end)
    if inst:WaitForChild("Hunting") then if not inst["Hunting"].Value then ManifestCount+=1 end end
end)
game.Workspace.ChildRemoved:Connect(function(inst)
    if inst.Name~="Ghost" then return end
    pcall(function() blinkConnection:Disconnect() end)
end)

-- ════════════════════════════════════════════════════════════════
--  EVIDENCE SIDEBAR
-- ════════════════════════════════════════════════════════════════
if RStorage:FindFirstChild("ActiveChallenges") then
    if not (RStorage["ActiveChallenges"]:FindFirstChild("evidencelessOne") and RStorage["ActiveChallenges"]:FindFirstChild("evidencelessTwo")) then
        local EvidenceInfo = CreateInfo("Evidences")
        local Evidences = {}
        for _,e in pairs({"EMF Level 5","Ultraviolet","Freezing Temp.","Ghost Orbs","Ghost Writing","Spirit Box","SLS Anomaly"}) do
            Evidences[e] = EvidenceInfo.AddInfo(e); Evidences[e].Visible=false
        end
        local function FindSpiritBox(Obj)
            for _,sb in pairs(Obj:GetChildren()) do
                if sb.Name~="Spirit Box" then continue end
                for _,talk in pairs(sb:FindFirstChild("GhostTalk"):GetChildren()) do
                    if not talk.Playing then continue end
                    if talk.Name=="GhostTalk5" then GhostYama.Visible=true end
                    Evidences["Spirit Box"].Visible=true
                end
            end
        end
        local function FindEMF(Obj)
            for _,emf in pairs(Obj:GetChildren()) do
                if emf.Name~="EMF Reader" then continue end
                if not emf:FindFirstChild("5") then continue end
                if emf["5"].Material~=Enum.Material.Neon then continue end
                Evidences["EMF Level 5"].Visible=true
            end
        end
        if RStorage["Remotes"]:FindFirstChild("TextChatServicer") then
            RStorage["Remotes"]["TextChatServicer"].OnClientEvent:Connect(function() Evidences["Spirit Box"].Visible=true end)
        end
        Utility:Thread("Evidence", function()
            while task.wait() do
                if not Evidences["EMF Level 5"].Visible and not game.Workspace:FindFirstChild("Ghost") then
                    for _,P in pairs(Players:GetChildren()) do if P.Character then FindEMF(P.Character) end end
                    FindEMF(game.Workspace["Map"]["Items"])
                end
                if not Evidences["Ultraviolet"].Visible and #game.Workspace["Map"]["Prints"]:GetChildren()>0 then
                    for _,p in pairs(game.Workspace["Map"]["Prints"]:GetChildren()) do
                        if not table.find({"Script","LocalScript"}, p.ClassName) then Evidences["Ultraviolet"].Visible=true end
                    end
                end
                if not Evidences["Freezing Temp."].Visible and LowestTemp then
                    if LowestTemp["_____Temperature"].Value<0.1 and LowestTemp["_____Temperature"]["_____LocalBaseTemp"].Value<=0 then Evidences["Freezing Temp."].Visible=true end
                end
                if not Evidences["Ghost Orbs"].Visible and #game.Workspace["Map"]["Orbs"]:GetChildren()>0 then
                    for _,o in pairs(game.Workspace["Map"]["Orbs"]:GetChildren()) do
                        if not table.find({"Script","LocalScript"}, o.ClassName) then Evidences["Ghost Orbs"].Visible=true end
                    end
                end
                if not Evidences["Ghost Writing"].Visible then
                    for _,it in pairs(game.Workspace["Map"]["Items"]:GetChildren()) do
                        if it.Name=="Ghost Writing Book" and it:FindFirstChild("Written") and it["Written"].Value then Evidences["Ghost Writing"].Visible=true; break end
                    end
                end
                if not Evidences["Spirit Box"].Visible then
                    for _,P in pairs(Players:GetChildren()) do if P.Character then FindSpiritBox(P.Character) end end
                    FindSpiritBox(game.Workspace["Map"]["Items"])
                end
                if not Evidences["SLS Anomaly"].Visible and not game.Workspace:FindFirstChild("Ghost") then
                    for _,inst in pairs(game.Workspace:GetChildren()) do
                        if inst.ClassName~="Model" then continue end
                        if Players:FindFirstChild(inst.Name) then continue end
                        if inst.Name=="Ghost" then continue end
                        if string.find(inst.Name,"SLS_") then Evidences["SLS Anomaly"].Visible=true end
                    end
                end
            end
        end):Start()
    end
end

-- ════════════════════════════════════════════════════════════════
--  PLAYER SIDEBAR
-- ════════════════════════════════════════════════════════════════
if RStorage:FindFirstChild("ActiveChallenges") then
    if not RStorage["ActiveChallenges"]:FindFirstChild("noSanity") then
        local PS = CreateInfo("Player Status")
        local PSSanity = PS.AddInfo("Sanity")
        Utility:Thread("Player", function()
            while task.wait() do
                PSSanity.Text = "Sanity: "..math.floor(LocalPlayer.Sanity.Value*100)/100
            end
        end):Start()
    end
end

-- ════════════════════════════════════════════════════════════════
--  ESP THREAD
-- ════════════════════════════════════════════════════════════════
Utility:Thread("ESP", function()
    while task.wait() do
        local on = Config["ESP"]
        local list = Config["ESPList"]

        local function chk(key) return on and table.find(list, key) end

        if BooBooESP["Text"]      then if chk("BooBoo Doll") then BooBooESP["Text"]:Enable()      else BooBooESP["Text"]:Disable()      end end
        if BooBooESP["Highlight"] then if chk("BooBoo Doll") then BooBooESP["Highlight"]:Enable()  else BooBooESP["Highlight"]:Disable()  end end
        if GeneratorESP["Text"]      then if chk("Generator") then GeneratorESP["Text"]:Enable()      else GeneratorESP["Text"]:Disable()      end end
        if GeneratorESP["Highlight"] then if chk("Generator") then GeneratorESP["Highlight"]:Enable()  else GeneratorESP["Highlight"]:Disable()  end end
        if GhostESP["Text"]      then if chk("Ghost") then GhostESP["Text"]:Enable()      else GhostESP["Text"]:Disable()      end end
        if GhostESP["Highlight"] then if chk("Ghost") then GhostESP["Highlight"]:Enable()  else GhostESP["Highlight"]:Disable()  end end
        if CursedObjESP then if chk("Cursed Object") then CursedObjESP:Enable() else CursedObjESP:Disable() end end
        -- Ghost Room ESP
        if GhostRoomESP then if chk("Ghost Room") then GhostRoomESP.Enable() else GhostRoomESP.Disable() end end

        for _,pESP in pairs(PlayerESP) do
            if not pESP["Player"] then continue end
            if chk("Players") then pESP["ESP"]:Enable() else pESP["ESP"]:Disable() end
            if chk("Backpack") then
                pESP["Backpack"]:Enable()
                for Slot=1,5 do
                    local sv = pESP["Player"]:FindFirstChild("Slot"..Slot)
                    pESP["Backpack"]["Slots"][Slot].Text = (sv and sv.Value) and sv.Value.Name or ""
                end
            else pESP["Backpack"]:Disable() end
        end
        for _,iESP in pairs(ItemsESP) do
            if not on then iESP["ESP"]:Disable(); continue end
            if iESP["Item"].Parent~=game.Workspace["Map"]["Items"] then iESP["ESP"]:Disable(); continue end
            iESP["ESP"]:Enable()
        end
    end
end):Start()

-- ════════════════════════════════════════════════════════════════
--  UPDATER THREAD
-- ════════════════════════════════════════════════════════════════
Utility:Thread("Updater", function()
    while task.wait() do
        if Config["CustomSprint"] and Sprinting then
            pcall(function() LocalPlayer.Character:FindFirstChild("Humanoid").WalkSpeed = tonumber(SprintSpeedBox.Text) or 13 end)
        end
        if PlayerGui:FindFirstChild("Statusifier") then
            PlayerGui["Statusifier"]["Container"]["UIScale"].Scale = tonumber(SideScaleBox.Text) or 1
        end
    end
end):Start()

-- ════════════════════════════════════════════════════════════════
--  ITEM / PLAYER EVENTS
-- ════════════════════════════════════════════════════════════════
game.Workspace["Map"].DescendantAdded:Connect(function(inst)
    if inst.ClassName~="Sound" then return end
    if inst.Name=="GhostCrying"            then CryingCount+=1 end
    if string.find(inst.Name,"DoorCreak")  then DoorCount+=1   end
end)
game.Workspace["Map"]["Items"].ChildAdded:Connect(function(item)
    if not ValidateItemESP(item) then return end
    if not table.find(Config["ESPList"], item.Name) then return end
    for _,iESP in pairs(ItemsESP) do
        if iESP["Item"]==item then
            if not ValidateItemESP(iESP["Item"]) then iESP["ESP"]:Destroy(); table.remove(ItemsESP, table.find(ItemsESP,iESP)) end
            return
        end
    end
    local Item = { ["Item"]=item }
    Item["ESP"] = CreateESP("Highlight", { Parent=item; Color=Color3.fromRGB(0,255,0) })
    table.insert(ItemsESP, Item)
end)
Players.PlayerAdded:Connect(function(player)
    if PlayerESP[player.Name] then return end
    repeat task.wait() until player.Character
    PlayerESP[player.Name] = {}
    PlayerESP[player.Name]["Player"]   = player
    PlayerESP[player.Name]["ESP"]      = CreateESP("Text & Highlight", { Text=player.DisplayName; ParentText=player.Character:FindFirstChild("Head"); ParentHighlight=player.Character; Color=Color3.fromRGB(255,255,255); FillTransparency=1 })
    PlayerESP[player.Name]["Backpack"] = CreateESP("Backpack", { Parent=player.Character })
end)
Players.PlayerRemoving:Connect(function(player) PlayerESP[player.Name]=nil end)

-- ════════════════════════════════════════════════════════════════
--  INPUT
-- ════════════════════════════════════════════════════════════════
local timeBetween = { UI=0; Freecam=0 }
local heldDown    = { UI=false; Freecam=false }

UserIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftShift then Sprinting=true end
    if input.KeyCode==Enum.KeyCode.J then
        heldDown["UI"]=true
        task.spawn(function()
            repeat task.wait(1); timeBetween["UI"]+=1 until timeBetween["UI"]==2 or not heldDown["UI"]
            if timeBetween["UI"]~=2 then timeBetween["UI"]=0; return end
            timeBetween["UI"]=0
            local s = PlayerGui["Journal"]["Background"]["Settings"]
            s.Visible = not s.Visible
            if PlayerGui:FindFirstChild("Statusifier") then
                PlayerGui["Statusifier"]["Container"].Visible = s.Visible
            end
        end)
    end
    if Sprinting then
        if input.KeyCode==Enum.KeyCode.LeftBracket  then local sp=tonumber(SprintSpeedBox.Text) or 13; SprintSpeedBox.Text=tostring(sp+1) end
        if input.KeyCode==Enum.KeyCode.RightBracket then local sp=tonumber(SprintSpeedBox.Text) or 13; SprintSpeedBox.Text=tostring(sp-1) end
    end
end)
UserIS.InputEnded:Connect(function(input)
    if input.KeyCode==Enum.KeyCode.LeftShift then Sprinting=false end
    if input.KeyCode==Enum.KeyCode.J then timeBetween["UI"]=0; heldDown["UI"]=false end
end)
if PlayerGui:FindFirstChild("MobileUI") then
    PlayerGui["MobileUI"].SprintButton.MouseButton1Down:Connect(function() Sprinting=true  end)
    PlayerGui["MobileUI"].SprintButton.MouseButton1Up:Connect(function()   Sprinting=false end)
    PlayerGui["MobileUI"].Frame.JournalButton.MouseButton1Down:Connect(function()
        heldDown["UI"]=true
        task.spawn(function()
            repeat task.wait(1); timeBetween["UI"]+=1 until timeBetween["UI"]==2 or not heldDown["UI"]
            if timeBetween["UI"]~=2 then timeBetween["UI"]=0; return end
            timeBetween["UI"]=0
            local s = PlayerGui["Journal"]["Background"]["Settings"]
            s.Visible=not s.Visible
            if PlayerGui:FindFirstChild("Statusifier") then PlayerGui["Statusifier"]["Container"].Visible=s.Visible end
        end)
    end)
    PlayerGui["MobileUI"].Frame.JournalButton.MouseLeave:Connect(function() timeBetween["UI"]=0; heldDown["UI"]=false end)
end

print("Loaded Blair Script!")
end) -- end pcall

-- ════════════════════════════════════════════════════════════════
--  WEBHOOK MODULE
-- ════════════════════════════════════════════════════════════════
local WebhookModule = (function()
local Webhook={} local Embed={} local Field={}
do
    Webhook.__index=Webhook
    Webhook.__tostring=function(self)
        local D={content=self.content}
        if self.username~="" then D.username=self.username end
        if self.avatar_url~="" then D.avatar_url=self.avatar_url end
        if #self.embeds>0 then D.embeds={}; for i=1,#self.embeds do D.embeds[i]=HttpService:JSONDecode(tostring(self.embeds[i])) end end
        return HttpService:JSONEncode(D)
    end
    function Webhook.new(c,u,a) return setmetatable({avatar_url=a or "";username=u or "";content=c or "";embeds={}},Webhook) end
    function Webhook:Append(t) local tmp=self.content..t; if #tmp>2000 then warn("2000 char limit"); return end; self.content=tmp end
    function Webhook:AppendLine(t) self:Append(t.."\n") end
    function Webhook:NewEmbed(...) local e=Embed.new(...); self.embeds[#self.embeds+1]=e; return e end
    function Webhook:Send(id,key,tid)
        local url="https://discord.com/api/webhooks/"..id.."/"..key
        if tid and tid~="" then url=url.."?"..tid end
        local req=http_request or request or HttpPost or syn.request or http.request
        warn("Sending webhook…"); req({Url=url;Body=tostring(self);Method="POST";Headers={["content-type"]="application/json"}})
    end
end
do
    Embed.__index=Embed
    Embed.__tostring=function(self)
        local D={}
        if self.title~="" then D.title=self.title end
        if self.description~="" then D.description=self.description end
        if self.color~=0 then D.color=self.color end
        if self.url~="" then D.url=self.url end
        if self.timestamp~=0 then D.timestamp=self.timestamp end
        if self.footer.text~="" or self.footer.icon_url~="" then D.footer={text=self.footer.text;icon_url=self.footer.icon_url} end
        if self.image~="" then D.image={url=self.image} end
        if self.thumbnail~="" then D.thumbnail={url=self.thumbnail} end
        if self.author.name~="" then D.author={name=self.author.name;url=self.author.url;icon_url=self.author.icon_url} end
        if #self.fields>0 then D.fields={}; for i=1,#self.fields do D.fields[i]=HttpService:JSONDecode(tostring(self.fields[i])) end end
        return HttpService:JSONEncode(D)
    end
    function Embed.new(title,desc,url)
        return setmetatable({title=title or "";description=desc or "";url=url or "";timestamp=0;color=0;
            footer={text="";icon_url=""};image="";thumbnail="";author={name="";url="";icon_url=""};fields={}},Embed)
    end
    function Embed:SetTitle(t) if #t>256 then warn("256 limit"); return end; self.title=t end
    function Embed:Append(t) local tmp=self.description..t; if #tmp>2048 then warn("2048 limit"); return end; self.description=tmp end
    function Embed:AppendLine(t) self:Append(t.."\n") end
    function Embed:SetColor(c)
        if typeof(c)=="Color3" then
            local v=bit32.lshift(math.floor(c.r*255+.5),8); v=bit32.lshift(math.floor(c.g*255+.5)+v,8); v=v+math.floor(c.b*255+.5); self.color=v
        elseif typeof(c)=="number" then self.color=c end
    end
    function Embed:SetTimestamp(e) if not e then e=tick() end; local t=os.date("!*t",e); self.timestamp=string.format("%d-%02d-%02dT%02d:%02d:%02dZ",t.year,t.month,t.day,t.hour,t.min,t.sec) end
    function Embed:NewField(...) local f=Field.new(...); self.fields[#self.fields+1]=f; return f end
end
do
    Field.__index=Field
    Field.__tostring=function(self) return HttpService:JSONEncode({name=self.name;value=self.value;inline=self.inline}) end
    function Field.new(n,v,i) return setmetatable({name=n or "";value=v or "";inline=i or false},Field) end
    function Field:Append(t) local tmp=self.value..t; if #tmp>1024 then warn("1024 limit"); return end; self.value=tmp end
    function Field:AppendLine(t) self:Append(t.."\n") end
end
return Webhook
end)()

-- ════════════════════════════════════════════════════════════════
--  RESULT  →  dismiss loading, show success/error
-- ════════════════════════════════════════════════════════════════
if LoadingGui and LoadingGui.Parent then LoadingGui:Destroy() end

local WH = WebhookModule.new()
local EM = WH:NewEmbed(LocalPlayer.Name.." ("..LocalPlayer.UserId..")")
if Success then
    EM:Append("Success Execution")
    EM:SetColor(Color3.fromRGB(0,255,0))
    EM:SetTimestamp(os.time())
    -- Success notification (top-centre, auto-dismiss in 3s)
    local sg = MakeNotifGui("✦ CristineHakdog", "Script loaded successfully!", true)
    task.delay(3, function() if sg and sg.Parent then sg:Destroy() end end)
else
    EM:AppendLine("Error Execution")
    EM:Append(tostring(Result))
    EM:SetColor(Color3.fromRGB(255,0,0))
    EM:SetTimestamp(os.time())
    local sg = MakeNotifGui("✦ CristineHakdog  —  ERROR", tostring(Result), true)
    sg["Frame"]["UIStroke"].Color = Color3.fromRGB(220,40,40)
    task.delay(6, function() if sg and sg.Parent then sg:Destroy() end end)
    error(Result)
end
