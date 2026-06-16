--[[
    ╔═════════════════════════════════════════════════════════════╗
    ║                       CristineHakdog                        ║
    ║                       Blair - Roblox                        ║
    ║                                                             ║
    ║  Features:                                                  ║
    ║    • 	Ghost ESP, Object ESP, Items ESP, Room ESP            ║
	║    • 	Speed Hack (Toggle)                                   ║
    ║    • 	Ghost Informations                                    ║
    ╚═════════════════════════════════════════════════════════════╝
--]]

if not game:IsLoaded() then game.Loaded:Wait() end
if game:GetService("HttpService"):JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/".. game.PlaceId .."/universe")).universeId ~= 2239430935 then return; end

--------------------
-- [[ SERVICES ]] --
--------------------
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local Lighting = game:GetService("Lighting");
local RStorage = game:GetService("ReplicatedStorage");
local UserIS = game:GetService("UserInputService");
local RService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer.PlayerGui;
local Mouse = LocalPlayer:GetMouse();

if game.PlaceId == 6137321701 then StarterGui:SetCore("SendNotification", { Title = "CristineHakdog"; Text = "No Loading in Lobby!"; }); return; end

StarterGui:SetCore("SendNotification", { Title = "CristineHakdog"; Text = "Loading Blair Script!"; });
local Success, Result = pcall(function()
	print("Loading Blair Script!");
	repeat task.wait(.1) until game.Workspace:FindFirstChild(LocalPlayer.Name);
	print("[DEBUG] Found character");
	repeat task.wait(.1) until game.Workspace[LocalPlayer.Name]:FindFirstChild("HumanoidRootPart");
	print("[DEBUG] Found HumanoidRootPart");
	repeat task.wait(.1) until game.Workspace:FindFirstChild("Map");
	print("[DEBUG] Found Map");
	repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Van");
	print("[DEBUG] Found Map.Van");
	repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Doors");
	print("[DEBUG] Found Map.Doors");
	repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Items");
	print("[DEBUG] Found Map.Items");
	repeat task.wait(.1) until game.Workspace["Map"]:FindFirstChild("Zones");
	print("[DEBUG] Found Map.Zones");
	repeat task.wait(.1) until PlayerGui:FindFirstChild("Journal");
	print("[DEBUG] Found PlayerGui.Journal");
	repeat task.wait(.1) until RStorage:FindFirstChild("ActiveChallenges");
	print("[DEBUG] Found RStorage.ActiveChallenges");
	repeat task.wait(.1) until RStorage:FindFirstChild("Remotes");
	print("[DEBUG] Found RStorage.Remotes");
	task.wait(5);
	print("[DEBUG] All checks passed, proceeding to load modules...");

	local Utility = (function()
--// UTILITY MODULE
local Utility = {
	Threads = {},
	AllIDs = {},
	FoundAnything = "",
	ActualHour = os.date("!*t").hour,
}
do
	function Utility:Instance(Name, Data)
		local Object = Instance.new(Name, Data.Parent);
		for Index, Value in next, Data do
			if Index ~= "Parent" then
				if typeof(Value) == "Instance" then Value.Parent = Object;
				else Object[Index] = Value; end
			end
		end
		return Object;
	end
	
	function Utility:CommaValue(Text:string)
		local Value = Text;
		while true do
			local Str, Num = string.gsub(Value, "^(-?%d+)(%d%d%d)", "%1,%2");
			Value = Str
			if Num ~= 0 then else break end
		end
		return Value
	end

	function Utility:CombineTable(...:{any})
		local newTable = {}
		for _, v in ipairs({...}) do
			for i, x in ipairs(v) do
				table.insert(newTable, x)
			end
		end
		return newTable
	end

	function Utility:GetTableKeys(Table:{any})
		local newTable = {}
		for k, _ in pairs(Table) do table.insert(newTable, k) end
		return newTable
	end
	
	function Utility:Length(Table:{any})
		local Counter = 0
		for _, v in pairs(Table) do Counter += 1; end
		return Counter
	end

	function Utility:Show(UIObjects:{GuiObject}, Visible:boolean)
		for Index, Value in pairs(UIObjects) do
			Value.Visible = Visible
		end
	end
	
	function Utility:SaveConfig(Config:{any}, Directory:string, File:string)
		local HttpService = game:GetService("HttpService")
		if not isfolder(Directory) then
			local Folders = Directory:split("/")
			local tempDirectory = Folders[1]
			for _, folder in pairs(Folders) do
				if folder == tempDirectory then makefolder(folder); continue; end
				tempDirectory = tempDirectory .. "/" .. folder
				makefolder(tempDirectory)
			end
		end

		writefile(Directory .. "/" .. File, HttpService:JSONEncode(Config))
		return self:LoadConfig(Config, Directory, File)
	end

	function Utility:LoadConfig(Config:{any}, Directory:string, File:string)
		local Success, Response = pcall(function()
			local HttpService = game:GetService("HttpService")
			if not isfolder(Directory) then
				local Folders = Directory:split("/")
				local tempDirectory = Folders[1]
				for _, folder in pairs(Folders) do
					if folder == tempDirectory then makefolder(folder); continue; end
					tempDirectory = tempDirectory .. "/" .. folder
					makefolder(tempDirectory)
				end
			end

			return HttpService:JSONDecode(readfile(Directory .. "/" .. File))
		end)

		if Success then return Response
		else return self:SaveConfig(Config, Directory, File) end
	end

	function Utility:GetFiles(Directory:string)
		if not isfolder(Directory) then makefolder(Directory) end
		return listfiles(Directory)
	end
	
	function Utility:Thread(ID:string, Callback)
		local Thread = coroutine.create(Callback)
		self.Threads[ID] = Thread

		return setmetatable({
			ID = ID,
			Thread = Thread,
			Start = function() coroutine.resume(Thread); end,
			Stop = function() coroutine.close(Thread); end,
			Status = function() return coroutine.status(Thread) end,
		}, {})
	end

	function Utility:StopAllThreads()
		for i, v in pairs(self.Threads) do
			if coroutine.status(v) == "running" then
				coroutine.close(v)
			end
			self.Threads = {}
		end
	end

	function Utility:Teleporter(PlaceID)
		local Deleted = false
    	local Last
		local ServerFile = pcall(function() Utility.AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json")) end)
		if not ServerFile then
			table.insert(Utility.AllIDs, Utility.ActualHour)
			writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(Utility.AllIDs))
		end

		local Site;
		if Utility.FoundAnything == "" then
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. Utility.FoundAnything))
		end

		local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
			Utility.FoundAnything = Site.nextPageCursor
		end

		local Num = 0;
        local ExtraNum = 0
		for Index, Server in pairs(Site.data) do
            ExtraNum += 1
            local Possible = true
            ID = tostring(Server.id)
            if tonumber(Server.maxPlayers) > tonumber(Server.playing) then
                if ExtraNum ~= 1 and tonumber(Server.playing) < Last or ExtraNum == 1 then Last = tonumber(Server.playing)
                elseif ExtraNum ~= 1 then continue end

                for _, Existing in pairs(Utility.AllIDs) do
                    if Num ~= 0 then
                        if ID == tostring(Existing) then Possible = false end
                    else
                        if tonumber(Utility.ActualHour) ~= tonumber(Existing) then
                            local delFile = pcall(function()
                                delfile("NotSameServers.json")
                                Utility.AllIDs = {}
                                table.insert(Utility.AllIDs, Utility.ActualHour)
                            end)
                        end
                    end
                    Num = Num + 1
                end
                if Possible == true then
                    table.insert(Utility.AllIDs, ID)
                    task.wait()
                    pcall(function()
                        writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(Utility.AllIDs))
                        task.wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    end)
                    task.wait(4)
                end
            end
        end
	end

end
return Utility
end)()
	local BlairData = (function()
--// DATA MODULE
return {
    ["Ghost Type"] = {
        ["Banshee"] = {
            ["Evidence"] = {"EMF Level 5","SLS Anomaly","Freezing Temp."};
        };
        ["Demon"] = {
            ["Evidence"] = {"Freezing Temp.","Ghost Writing","Spirit Box"};
        };
        ["Faejkur"] = {
            ["Evidence"] = {"EMF Level 5","Freezing Temp.","Ghost Writing"};
        };
        ["Harrow"] = {
            ["Evidence"] = {"SLS Anomaly","Ghost Orb","Ghost Writing"};
        };
        ["Lament"] = {
            ["Evidence"] = {"Ghost Orb","EMF Level 5","Spirit Box"};
        };
        ["Mare"] = {
            ["Evidence"] = {"Freezing Temp.","SLS Anomaly","Spirit Box"};
        };
        ["Nook"] = {
            ["Evidence"] = {"EMF Level 5","Freezing Temp.","Ghost Orb"};
        };
        ["Poltergeist"] = {
            ["Evidence"] = {"Ultraviolet","Ghost Orb","Spirit Box"};
        };
        ["Revenant"] = {
            ["Evidence"] = {"EMF Level 5","Ultraviolet","Ghost Writing"};
        };
        ["Shade"] = {
            ["Evidence"] = {"EMF Level 5","SLS Anomaly","Ghost Writing"};
        };
        ["Spirit"] = {
            ["Evidence"] = {"Ultraviolet","Ghost Writing","Spirit Box"};
        };
        ["Strigoi"] = {
            ["Evidence"] = {"Ultraviolet","Ghost Orb","EMF Level 5"};
        };
        ["Vuult"] = {
            ["Evidence"] = {"EMF Level 5","Ghost Orb","SLS Anomaly"};
        };
        ["Wraith"] = {
            ["Evidence"] = {"Freezing Temp.","Ghost Orb","SLS Anomaly"};
        };
        ["Yama"] = {
            ["Evidence"] = {"Ghost Writing","Spirit Box","SLS Anomaly"};
        };
        ["Yurei"] = {
            ["Evidence"] = {"Ultraviolet","Freezing Temp.","Spirit Box"};
        };
        ["Zozo"] = {
            ["Evidence"] = {"EMF Level 5","Ultraviolet","Spirit Box"};
        };
    };
    ["Map"] = {

    };
    ["Items"] = {
        ["Incense Burner"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Lighter"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Crucifix"] = {Parent = game.Workspace["Map"]["Items"]};
		["Flashlight"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Strong Flashlight"] = {Parent = game.Workspace["Map"]["Items"]};
        ["UV Light"] = {Parent = game.Workspace["Map"]["Items"]};
        ["GlowStick"] = {Parent = game.Workspace["Map"]["Items"]};
		["Photo Camera"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Video Camera"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Trail Camera"] = {Parent = game.Workspace["Map"]["Items"]};
        ["SLS Camera"] = {Parent = game.Workspace["Map"]["Items"]};
		["EMF Reader"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Thermometer"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Spirit Box"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Ghost Writing Book"] = {Parent = game.Workspace["Map"]["Items"]};
		["Parabolic Microphone"] = {Parent = game.Workspace["Map"]["Items"]};
        ["Salt"] = {Parent = game.Workspace["Map"]["Items"]};
		["Sanity Soda"] = {Parent = game.Workspace["Map"]["Items"]};
    };
    ["Events"] = {
        ["Easter"] = DateTime.now().UnixTimestampMillis <= DateTime.fromLocalTime(2025, 5, 2, 12, 0, 0, 0).UnixTimestampMillis;
    }
}
end)()
	
	------------------
	-- [[ CONFIG ]] --
	------------------
	local Config = {
		["CustomLight"] = false;
		["CustomLightRange"] = "60";
		["CustomLightBrightness"] = "10";
		
		["CustomSprint"] = false;
		["CustomSprintSpeed"] = "13";
		
		["Fullbright"] = false;
		["FullbrightAmbient"] = "255";
		
		["NoClipDoor"] = false;
		
		["ESP"] = false;
		["ESPList"] = {};
		
		["Freecam"] = false;
		
		["SideStatus"] = false;
		["SideStatusScale"] = "1";
	}
	local Directory = "CristineHakdog/Blair"
	local File_Name = "Settings.json"
	Config = Utility:LoadConfig(Config, Directory, File_Name);

	if PlayerGui.Journal.Background:FindFirstChild("Settings") then PlayerGui.Journal.Background:FindFirstChild("Settings"):Destroy() end;
	if PlayerGui:FindFirstChild("Statusifier") then PlayerGui:FindFirstChild("Statusifier"):Destroy() end;

	---------------------
	-- [[ UTILITIES ]] --
	---------------------
	do
		function CreateSettings(Name, Options, Callback)
			local Enabled = Options and Options.Default or false;
			if Options and Config[Options.Config] then Enabled = Config[Options.Config] end
			local Keybind = Options and Options.Keybind or nil;
			local On = Callback and Callback.On or function() end;
			local Off = Callback and Callback.Off or function() end;
			
			local Settings;
			if PlayerGui.Journal.Background:FindFirstChild("Settings") then
				Settings = PlayerGui.Journal.Background:FindFirstChild("Settings");
			else
				Settings = Utility:Instance("Frame", {
					Name = "Settings";
					Parent = PlayerGui.Journal.Background;
					AnchorPoint = Vector2.new(0, 1);
					BackgroundTransparency = 1;
					Size = UDim2.new(1, 0, 0.04, 0);
					Utility:Instance("UIListLayout", {
						Padding = UDim.new(0, 10);
						FillDirection = Enum.FillDirection.Horizontal;
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						VerticalAlignment = Enum.VerticalAlignment.Center;
					});
				});
			end

			local Data = {Enabled = Enabled}
			Data.Button = Utility:Instance("TextButton", {
				Name = Name;
				Parent = Settings;
				BackgroundColor3 = Color3.fromRGB(0,0);
				BackgroundTransparency = 0.25;
				BorderSizePixel = 0;
				Size = UDim2.new(0.10, 0, 1, 0);
				Text = "";
				Utility:Instance("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5);
					BackgroundTransparency = 1;
					Position = UDim2.new(0.5, 0, 0.5, 0);
					Size = UDim2.new(0.9, 0, 0.7, 0);
					Font = Enum.Font.FredokaOne;
					Text = Name;
					TextColor3 = Color3.fromRGB(255, 255, 255);
					TextScaled = true;
				});
				Utility:Instance("Frame", {
					BackgroundColor3 = Data.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0);
					BorderSizePixel = 0;
					Position = UDim2.new(0, 0, 1, 0);
					Size = UDim2.new(1, 0, 0, 2);
				});
			});
			Data.Toggle = Data.Button["Frame"];
			
			function Data:AddTextbox(Properties, Options)
				Properties.Text = Options and Config[Options.Config] or Properties.Text or "";
				local Display = Options and Options.Display or "";
				local Type = Options and Options.Type or "Text";
				local Negative = Options and Options.Negative or false;
				local Control = Utility:Instance("TextBox", {
					Parent = Data.Button;
					AnchorPoint = Vector2.new(0.5, 1);
					BackgroundColor3 = Color3.fromRGB(0, 0, 0);
					BackgroundTransparency = 0.25;
					BorderSizePixel = 0;
					Position = UDim2.new(0.5, 0, 0, -2);
					Size = UDim2.new(0.8, 0, 0.8, 0);
					Font = Enum.Font.SourceSansBold;
					TextColor3 = Color3.fromRGB(255, 255, 255);
					TextScaled = true;
					Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 5); });
					Utility:Instance("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5);
						BackgroundTransparency = 1;
						Position = UDim2.new(0.5, 0, -0.1, 0);
						Size = UDim2.new(0.9, 0, 0.6, 0);
						Font = Enum.Font.FredokaOne;
						Text = Display;
						TextColor3 = Color3.fromRGB(255, 255, 255);
						TextScaled = true;
						TextStrokeTransparency = 0;
						TextXAlignment = Enum.TextXAlignment.Left;
					});
				});
				for Index, Value in pairs(Properties or {}) do
					Control[Index] = Value;
					if Index == "Text" and Options.Config then
						Config[Options.Config] = Value;
						Utility:SaveConfig(Config, Directory, File_Name);
					end
				end;
				
				if Type == "Integer" then Control:GetPropertyChangedSignal("Text"):Connect(function() Control.Text = string.match(Control.Text, (Negative and "[-]?" or "").."%d*"); end) end
				if Type == "Number" then Control:GetPropertyChangedSignal("Text"):Connect(function() Control.Text = string.match(Control.Text, (Negative and "[-]?" or "").."%d*[%.]?%d*"); end) end
				
				Control.FocusLost:Connect(function()
					if Options.Config then
						Config[Options.Config] = Control.Text;
						Utility:SaveConfig(Config, Directory, File_Name);
					end
				end)
				
				return Control;
			end;

			function Data:AddDropdrown(Properties, Options)
				local Selected = Options and Config[Options.Config] or {};
				local List = Options and Options.List or {};
				local Control = { Selected = Selected; };
				Control.Button = Utility:Instance("TextButton", {
					Parent = Data.Button;
					AnchorPoint = Vector2.new(0.5, 1);
					BackgroundColor3 = Color3.fromRGB(0, 0, 0);
					BackgroundTransparency = 0.25;
					BorderSizePixel = 0;
					Position = UDim2.new(0.5, 0, 0, -2);
					Size = UDim2.new(0.8, 0, 0.8, 0);
					Font = Enum.Font.SourceSansBold;
					Text = "Open List";
					TextColor3 = Color3.fromRGB(255, 255, 255);
					TextScaled = true;
					Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 5); });
				});
				for Index, Value in pairs(Properties or {}) do
					if Control.Button[Index] then Control.Button[Index] = Value; end
				end;
				Control.Scroll = Utility:Instance("Frame", {
					Parent = Data.Button;
					AnchorPoint = Vector2.new(0.5, 0);
					BackgroundColor3 = Color3.fromRGB(0, 0, 0);
					BackgroundTransparency = 0.25;
					BorderSizePixel = 0;
					Position = UDim2.new(0.5, 0, 0, 0);
					Size = UDim2.new(1.1, 0, 10, 0);
					Visible = false;
					ZIndex = 2;
					ClipsDescendants = true;
					Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 10); });
					Utility:Instance("ScrollingFrame", {
						AnchorPoint = Vector2.new(0.5, 0.5);
						BackgroundColor3 = Color3.fromRGB(0, 0, 0);
						BackgroundTransparency = 1;
						Position = UDim2.new(0.5, 0, 0.5, 0);
						Size = UDim2.new(1, 0, 0.96, 0);
						ZIndex = 2;
						AutomaticCanvasSize = Enum.AutomaticSize.Y;
						CanvasSize = UDim2.new(0, 0, 0, 0);
						ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
						ScrollBarThickness = 5;
						Utility:Instance("UIListLayout", { Padding = UDim.new(0, 3); HorizontalAlignment = Enum.HorizontalAlignment.Center; });
						Utility:Instance("UIPadding", { PaddingLeft = UDim.new(0.06, 0); PaddingRight = UDim.new(0.06, 0); });
					})
				});
				for _, Item in pairs(List) do
					local Button = Utility:Instance("TextButton", {
						Name = Item;
						Parent = Control.Scroll["ScrollingFrame"];
						BackgroundColor3 = Color3.fromRGB(40, 40, 40);
						Size = UDim2.new(1, 0, 0.1, 0);
						Text = "";
						ZIndex = 2;
						Utility:Instance("UICorner", { CornerRadius = UDim.new(1, 0); });
						Utility:Instance("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5);
							BackgroundTransparency = 1;
							Position = UDim2.new(0.5, 0, 0.5, 0);
							Size = UDim2.new(0.9, 0, 0.9, 0);
							ZIndex = 2;
							Font = Enum.Font.SourceSansBold;
							Text = Item;
							TextColor3 = Color3.fromRGB(255, 255, 255);
							TextScaled = true;
						});
					});
					if table.find(Control.Selected, Item) then Button.BackgroundColor3 = Color3.fromRGB(0, 211, 0);
					else Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40); end

					Button.MouseButton1Down:Connect(function()
						if table.find(Control.Selected, Item) then
							table.remove(Control.Selected, table.find(Control.Selected, Item));
							Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
						else
							table.insert(Control.Selected, Item);
							Button.BackgroundColor3 = Color3.fromRGB(0, 211, 0);
						end
						if Options.Config then
							Config[Options.Config] = Control.Selected;
							Utility:SaveConfig(Config, Directory, File_Name);
						end
						if Options.Callback then Options.Callback(Control.Selected); end
					end)
				end

				Control.Button.MouseButton1Down:Connect(function()
					Control.Scroll.Visible = not Control.Scroll.Visible
					if Control.Scroll.Visible then Control.Button.Text = "Close List";
					else Control.Button.Text = "Open List"; end
				end)

				return Control;
			end

			function Data:AddButton(Properties, Options)
				local Display = Options and Options.Display or "";
				local Control = { Debounce = false; };
				Control.Button = Utility:Instance("TextButton", {
					Parent = Data.Button;
					AnchorPoint = Vector2.new(0.5, 1);
					BackgroundColor3 = Color3.fromRGB(0, 0, 0);
					BackgroundTransparency = 0.25;
					BorderSizePixel = 0;
					Position = UDim2.new(0.5, 0, 0, -2);
					Size = UDim2.new(0.8, 0, 0.8, 0);
					Font = Enum.Font.SourceSansBold;
					Text = Display;
					TextColor3 = Color3.fromRGB(255, 255, 255);
					TextScaled = true;
					Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 5); });
				});
				for Index, Value in pairs(Properties or {}) do
					if Control.Button[Index] then Control.Button[Index] = Value; end
				end;

				Control.Button.MouseButton1Down:Connect(function()
					if Control.Debounce then return; end
					if Options.Callback then Options.Callback(); end

					Control.Debounce = true;
					task.spawn(function()
						task.wait(1);
						Control.Debounce = false;
					end)
				end)

				return Control;
			end
			
			function Data:Set(Value)
				Data.Enabled = Value;
				if Options.Config then
					Config[Options.Config] = Data.Enabled;
					Utility:SaveConfig(Config, Directory, File_Name);
				end
				if Data.Enabled then pcall(function() On(); Data.Toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0); end)
				else pcall(function() Off(); Data.Toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0); end) end
			end
			Data:Set(Data.Enabled);
			
			Data.Button.MouseButton1Down:Connect(function() Data:Set(not Data.Enabled); end)
			if UserIS.KeyboardEnabled and UserIS.MouseEnabled and not UserIS.TouchEnabled then
				if Keybind ~= nil then
					Data.Button["TextLabel"].Text = Name .." [".. Keybind.Name .."]";
					UserIS.InputBegan:Connect(function(input, gameProcessed)
						if gameProcessed then return; end
						if input.KeyCode == Keybind then Data:Set(not Data.Enabled); end
					end)
				end
			end

			return Data;
		end
		function CreateInfo(Name, Options)
			local SideInfo;
			if PlayerGui:FindFirstChild("Statusifier") then
				SideInfo = PlayerGui:FindFirstChild("Statusifier");
			else
				SideInfo = Utility:Instance("ScreenGui", {
					Name = "Statusifier";
					Parent = PlayerGui;
					ResetOnSpawn = false;
					Enabled = Config["SideStatus"];
					Utility:Instance("Frame", {
						Name = "Container";
						BackgroundTransparency = 1;
						Position = UDim2.new(0, 0, 0.55, 0);
						Size = UDim2.new(0, 150, 0, 0);
						Utility:Instance("UIListLayout", { Padding = UDim.new(0, 5); });
						Utility:Instance("UIScale", { Scale = 1; });
					});
				});
			end

			local Data = {}
			Data.Frame = Utility:Instance("Frame", {
				Name = Name;
				Parent = SideInfo["Container"];
				AutomaticSize = Enum.AutomaticSize.Y;
				BackgroundColor3 = Color3.fromRGB(0, 0, 0);
				BackgroundTransparency = 0.5;
				Size = UDim2.new(1, 0, 0, 0);
				Utility:Instance("TextLabel", {
					BackgroundTransparency = 1;
					Size = UDim2.new(1, 0, 0, 15);
					Font = Enum.Font.SourceSansBold;
					Text = "[ "..Name.." ]";
					TextColor3 = Color3.fromRGB(255, 255, 255);
					TextScaled = true;
				});
				Utility:Instance("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y;
					BackgroundTransparency = 1;
					Position = UDim2.new(0, 0, 0, 15);
					Size = UDim2.new(1, 0, 0, 0);
					Utility:Instance("UIListLayout", { Padding = UDim.new(0, 0); });
				});
			});
			Data.List = Data.Frame["Frame"];
			Data.AddInfo = function(Text)
				return Utility:Instance("TextLabel", {
					Parent = Data.List;
					BackgroundTransparency = 1;
					Size = UDim2.new(1, 0, 0, 15);
					Font = Enum.Font.SourceSans;
					Text = Text;
					TextColor3 = Color3.fromRGB(255, 255, 255);
					TextScaled = true;
				});
			end;

			return Data;
		end
		function CreateESP(Type, Properties)
			local Type = Type or "Text";
			local Data = {};
			if Type == "Text" then
				if Properties.ParentText and Properties.ParentText:FindFirstChild("ESP_Text") then
					Data.ESP = Properties.ParentText["ESP_Text"];
					Data.ESP.Size = Properties.Size or UDim2.new(5, 0, 2, 0);
					Data.ESP.StudsOffset = Properties.StudsOffset or Vector3.new(0, 2, 0);
					Data.ESP.Enabled = Properties.Enabled or false;
					Data.ESP["Title"].Text = Properties.Text;
					Data.ESP["Title"].TextColor3 = Properties.Color or Color3.fromRGB(255, 255, 255);
					if Properties.Distance and Data.ESP:FindFirstChild("Distance") then
						Data.Distance = Data.ESP["Distance"];
						Data.Distance.TextColor3 = Properties.Color or Color3.fromRGB(255, 255, 255);
					end
				elseif Properties.Parent and Properties.Parent:FindFirstChild("ESP_Text") then
					Data.ESP = Properties.Parent["ESP_Text"];
					Data.ESP.Size = Properties.Size or UDim2.new(5, 0, 2, 0);
					Data.ESP.StudsOffset = Properties.StudsOffset or Vector3.new(0, 2, 0);
					Data.ESP.Enabled = Properties.Enabled or false;
					Data.ESP["Title"].Text = Properties.Text;
					Data.ESP["Title"].TextColor3 = Properties.Color or Color3.fromRGB(255, 255, 255);
					if Properties.Distance and Data.ESP:FindFirstChild("Distance") then
						Data.Distance = Data.ESP["Distance"];
						Data.Distance.TextColor3 = Properties.Color or Color3.fromRGB(255, 255, 255);
					end
				else
					Data.ESP = Utility:Instance("BillboardGui", {
						Name = "ESP_Text";
						Parent = Properties.ParentText or Properties.Parent;
						ResetOnSpawn = Properties.ResetOnSpawn or false;
						AlwaysOnTop = true;
						Enabled = Properties.Enabled or false;
						Size = Properties.Size or UDim2.new(5, 0, 2, 0);
						StudsOffset = Properties.StudsOffset or Vector3.new(0, 2, 0);
						Utility:Instance("TextLabel", {
							Name = "Title";
							BackgroundTransparency = 1;
							Size = UDim2.new(1, 0, 0.5, 0);
							Font = Enum.Font.FredokaOne;
							Text = Properties.Text;
							TextColor3 = Properties.Color or Color3.fromRGB(255, 255, 255);
							TextScaled = true;
						});
					});
					if Properties.Distance then
						Data.Distance = Utility:Instance("TextLabel", {
							Name = "Distance";
							Parent = Data.ESP;
							BackgroundTransparency = 1;
							Position = UDim2.new(0, 0, 0.5, 0);
							Size = UDim2.new(1, 0, 0.5, 0);
							Font = Enum.Font.FredokaOne;
							Text = "0m";
							TextColor3 = Properties.Color or Color3.fromRGB(255, 255, 255);
							TextScaled = true;
						});
					end
				end
				if Properties.Distance then
					task.spawn(function()
						while task.wait() do
							if Data.Destroyed then break; end
							if not Properties.Distance then break; end
							pcall(function() Data.Distance.Text = (math.floor((Properties.Distance.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude * 100) / 100) .."m"; end)
						end
					end)
				end
				return setmetatable({
					ESP = Data.ESP;
					Distance = Data.Distance;
					Enable = function() pcall(function() Data.ESP.Enabled = true; end); end;
					Disable = function() pcall(function() Data.ESP.Enabled = false; end); end;
					Destroy = function() pcall(function() Data.Destroyed = true; Data.ESP:Destroy(); end); end;
				}, {});
			elseif Type == "Highlight" then
				if Properties.ParentHighlight and Properties.ParentHighlight:FindFirstChild("ESP_Highlight") then Properties.ParentHighlight["ESP_Highlight"]:Destroy(); end
				if Properties.Parent and Properties.Parent:FindFirstChild("ESP_Highlight") then Properties.Parent["ESP_Highlight"]:Destroy(); end
				Data.ESP = Utility:Instance("Highlight", {
					Name = "ESP_Highlight";
					Parent = Properties.ParentHighlight or Properties.Parent;
					Enabled = Properties.Enabled or false;
					FillColor = Properties.Color or Color3.fromRGB(255, 255, 255);
					FillTransparency = Properties.FillTransparency or 0.75;
				});
				return setmetatable({
					ESP = Data.ESP;
					Enable = function() pcall(function() Data.ESP.Enabled = true; end); end;
					Disable = function() pcall(function() Data.ESP.Enabled = false; end); end;
					Destroy = function() pcall(function() Data.ESP:Destroy(); end); end;
				}, {});
			elseif Type == "Text & Highlight" then
				Data.TextESP = CreateESP("Text", Properties);
				Data.HighlightESP = CreateESP("Highlight", Properties);
				return setmetatable({
					TextESP = Data.TextESP;
					HighlightESP = Data.HighlightESP;
					Enable = function() pcall(function() Data.TextESP:Enable(); Data.HighlightESP:Enable(); end); end;
					Disable = function() pcall(function() Data.TextESP:Disable(); Data.HighlightESP:Disable(); end); end;
					Destroy = function() pcall(function() Data.TextESP:Destroy(); Data.HighlightESP:Destroy(); end); end;
				}, {});
			elseif Type == "Backpack" then
				if Properties.Parent and Properties.Parent:FindFirstChild("ESP_Backpack") then
					Data.ESP = Properties.Parent["ESP_Backpack"];
					Data.ESP.MaxDistance = Properties.MaxDistance or 15;
					Data.ESP.Size = Properties.Size or UDim2.new(2, 0, 2, 0);
					Data.ESP.StudsOffset = Properties.StudsOffset or Vector3.new(2, 1, 1);
					Data.ESP.Enabled = Properties.Enabled or false;
				else
					Data.ESP = Utility:Instance("BillboardGui", {
						Name = "ESP_Backpack";
						Parent = Properties.Parent;
						ResetOnSpawn = Properties.ResetOnSpawn or false;
						AlwaysOnTop = true;
						MaxDistance = Properties.MaxDistance or 15;
						Size = Properties.Size or UDim2.new(2, 0, 2, 0);
						StudsOffset = Properties.StudsOffset or Vector3.new(2, 1, 1);
						Enabled = Properties.Enabled or false;
						Utility:Instance("Frame", {
							BackgroundTransparency = 1;
							Size = UDim2.new(1, 0, 1, 0);
							Utility:Instance("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Center; });
						});
					});
				end
				Data.Slots = {};
				for Slot = 1, 5 do
					if Data.ESP["Frame"]:FindFirstChild("Slot_"..tostring(Slot)) then
						Data.Slots[Slot] = Data.ESP["Frame"]:FindFirstChild("Slot_"..tostring(Slot));
					else
						Data.Slots[Slot] = Utility:Instance("TextLabel", {
							Name = "Slot_"..tostring(Slot);
							Parent = Data.ESP["Frame"];
							BackgroundTransparency = 1;
							Size = UDim2.new(1, 0, 0.2, 0);
							Font = Enum.Font.SourceSansBold;
							Text = "";
							TextColor3 = Color3.fromRGB(255, 255, 255);
							TextScaled = true;
							TextStrokeTransparency = 0;
						});
					end
				end
				return setmetatable({
					ESP = Data.ESP;
					Slots = Data.Slots;
					Enable = function() pcall(function() Data.ESP.Enabled = true; end); end;
					Disable = function() pcall(function() Data.ESP.Enabled = false; end); end;
					Destroy = function() pcall(function() Data.Destroyed = true; Data.ESP:Destroy(); end); end;
				}, {});
			end
		end
	end

	----------------------
	-- [[ INITIALIZE ]] --
	----------------------
	local FreecamModule = (function()
--// FREECAM MODULE
local Freecam = {
	Enabled = false;
	INPUT_PRIORITY = Enum.ContextActionPriority.High.Value;

	NAV_GAIN = Vector3.new(1, 1, 1) * 64;
	PAN_GAIN = Vector2.new(0.75, 1) * 8;
	FOV_GAIN = 300;

	PITCH_LIMIT = math.rad(90);

	VEL_STIFFNESS = 1.5;
	PAN_STIFFNESS = 1.0;
	FOV_STIFFNESS = 4.0;
	
	IgnoreGUI = {};
}

------------------------------------------------------------------------
-- Freecam
-- Cinematic free camera for spectating and video production.
------------------------------------------------------------------------

local pi    = math.pi
local abs   = math.abs
local clamp = math.clamp
local exp   = math.exp
local rad   = math.rad
local sign  = math.sign
local sqrt  = math.sqrt
local tan   = math.tan

local ContextActionService	= game:GetService("ContextActionService")
local Players				= game:GetService("Players")
local RunService			= game:GetService("RunService")
local StarterGui			= game:GetService("StarterGui")
local UserInputService		= game:GetService("UserInputService")
local GuiService			= game:GetService("GuiService")
local Workspace				= game:GetService("Workspace")

local Utility				= Utility

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = Workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

------------------------------------------------------------------------

local GUI = {} do
	local function Create(Name, Data)
		local Object = Instance.new(Name, Data.Parent);
		for Index, Value in next, Data do
			if Index ~= "Parent" then
				if typeof(Value) == "Instance" then Value.Parent = Object;
				else Object[Index] = Value; end
			end
		end
		return Object;
	end
	
	GUI.UI = Utility:Instance("ScreenGui", {
		Name = "MobileFreecam";
		Parent = LocalPlayer.PlayerGui;
		Enabled = false;
		Utility:Instance("Frame", {
			Name = "Controls";
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 35, 1, -179);
			Size = UDim2.new(0, 155, 0, 155);
		});
	});
	GUI.Forward = Utility:Instance("Frame", {
		Parent = GUI.UI["Controls"];
		BackgroundTransparency = 0.82;
		Position = UDim2.new(0.333, 0, 0, 0);
		Size = UDim2.new(0.333, 0, 0.333, 0);
		Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 4); });
		Utility:Instance("TextButton", { BackgroundTransparency = 1; Size = UDim2.new(1, 0, 1, 0); Text = ""; });
		Utility:Instance("TextLabel", { BackgroundTransparency = 1; Rotation = 90; Size = UDim2.new(1, 0, 1, 0); Font = Enum.Font.FredokaOne; Text = "<"; TextScaled = true; TextStrokeTransparency = 0.8; })
	});
	GUI.Backward = Utility:Instance("Frame", {
		Parent = GUI.UI["Controls"];
		BackgroundTransparency = 0.82;
		Position = UDim2.new(0.333, 0, 0.667, 0);
		Size = UDim2.new(0.333, 0, 0.333, 0);
		Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 4); });
		Utility:Instance("TextButton", { BackgroundTransparency = 1; Size = UDim2.new(1, 0, 1, 0); Text = ""; });
		Utility:Instance("TextLabel", { BackgroundTransparency = 1; Rotation = -90; Size = UDim2.new(1, 0, 1, 0); Font = Enum.Font.FredokaOne; Text = "<"; TextScaled = true; TextStrokeTransparency = 0.8; })
	});
	GUI.Left = Utility:Instance("Frame", {
		Parent = GUI.UI["Controls"];
		BackgroundTransparency = 0.82;
		Position = UDim2.new(0, 0, 0.333, 0);
		Size = UDim2.new(0.333, 0, 0.333, 0);
		Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 4); });
		Utility:Instance("TextButton", { BackgroundTransparency = 1; Size = UDim2.new(1, 0, 1, 0); Text = ""; });
		Utility:Instance("TextLabel", { BackgroundTransparency = 1; Rotation = 0; Size = UDim2.new(1, 0, 1, 0); Font = Enum.Font.FredokaOne; Text = "<"; TextScaled = true; TextStrokeTransparency = 0.8; })
	});
	GUI.Right = Utility:Instance("Frame", {
		Parent = GUI.UI["Controls"];
		BackgroundTransparency = 0.82;
		Position = UDim2.new(0.667, 0, 0.333, 0);
		Size = UDim2.new(0.333, 0, 0.333, 0);
		Utility:Instance("UICorner", { CornerRadius = UDim.new(0, 4); });
		Utility:Instance("TextButton", { BackgroundTransparency = 1; Size = UDim2.new(1, 0, 1, 0); Text = ""; });
		Utility:Instance("TextLabel", { BackgroundTransparency = 1; Rotation = 180; Size = UDim2.new(1, 0, 1, 0); Font = Enum.Font.FredokaOne; Text = "<"; TextScaled = true; TextStrokeTransparency = 0.8; })
	});
	
	if LocalPlayer.PlayerGui:FindFirstChild("TouchGui") then
		local TouchGUI = LocalPlayer.PlayerGui["TouchGui"];
		function GUI:Show() GUI.UI.Enabled = true; TouchGUI.Parent = nil end
		function GUI:Hide() GUI.UI.Enabled = false; TouchGUI.Parent = LocalPlayer.PlayerGui; end
	end
end

------------------------------------------------------------------------

local Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

------------------------------------------------------------------------

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 0

local velSpring = Spring.new(Freecam.VEL_STIFFNESS, Vector3.new())
local panSpring = Spring.new(Freecam.PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(Freecam.FOV_STIFFNESS, 0)

------------------------------------------------------------------------

local Input = {} do
	local thumbstickCurve do
		local K_CURVATURE = 2.0
		local K_DEADZONE = 0.15

		local function fCurve(x)
			return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
		end

		local function fDeadzone(x)
			return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
		end

		function thumbstickCurve(x)
			return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
		end
	end

	local gamepad = {
		ButtonX = 0,
		ButtonY = 0,
		DPadDown = 0,
		DPadUp = 0,
		ButtonL2 = 0,
		ButtonR2 = 0,
		Thumbstick1 = Vector2.new(),
		Thumbstick2 = Vector2.new(),
	}

	local keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
		RightShift = 0,
	}

	local mouse = {
		Delta = Vector2.new(),
		MouseWheel = 0,
	}

	local NAV_GAMEPAD_SPEED  = Vector3.new(1, 1, 1)
	local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	local PAN_MOUSE_SPEED    = Vector2.new(1, 1)*(pi/64)
	local PAN_GAMEPAD_SPEED  = Vector2.new(1, 1)*(pi/8)
	local FOV_WHEEL_SPEED    = 1.0
	local FOV_GAMEPAD_SPEED  = 0.25
	local NAV_ADJ_SPEED      = 0.75
	local NAV_SHIFT_MUL      = 0.25

	local navSpeed = 1

	function Input.Vel(dt)
		navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kGamepad = Vector3.new(
			thumbstickCurve(gamepad.Thumbstick1.X),
			thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
			thumbstickCurve(-gamepad.Thumbstick1.Y)
		)*NAV_GAMEPAD_SPEED

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

		return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
			and not UserInputService.GamepadEnabled and not GuiService:IsTenFootInterface() then
			local x = -UserInputService:GetMouseDelta().X
			local y = -UserInputService:GetMouseDelta().Y
			local delta = Vector2.new(y, x)
			mouse.Delta = delta
		end
		local kGamepad = Vector2.new(
			thumbstickCurve(gamepad.Thumbstick2.Y),
			thumbstickCurve(-gamepad.Thumbstick2.X)
		)*PAN_GAMEPAD_SPEED
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kGamepad + kMouse
	end

	function Input.Fov(dt)
		local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
		local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
		mouse.MouseWheel = 0
		return kGamepad + kMouse
	end

	do
		local function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function GpButton(action, state, input)
			gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		local function Thumb(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position
			return Enum.ContextActionResult.Sink
		end

		local function Trigger(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function MouseWheel(action, state, input)
			mouse[input.UserInputType.Name] = -input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, Freecam.INPUT_PRIORITY,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up, Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",          MousePan,   false, Freecam.INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
			ContextActionService:BindActionAtPriority("FreecamMouseWheel",        MouseWheel, false, Freecam.INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
			ContextActionService:BindActionAtPriority("FreecamGamepadButton",     GpButton,   false, Freecam.INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
			ContextActionService:BindActionAtPriority("FreecamGamepadTrigger",    Trigger,    false, Freecam.INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
			ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb,      false, Freecam.INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(gamepad)
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
			ContextActionService:UnbindAction("FreecamMouseWheel")
			ContextActionService:UnbindAction("FreecamGamepadButton")
			ContextActionService:UnbindAction("FreecamGamepadTrigger")
			ContextActionService:UnbindAction("FreecamGamepadThumbstick")
		end
		
		GUI.Forward.TextButton.MouseButton1Down:Connect(function() keyboard["W"] = 1; end)
		GUI.Forward.TextButton.MouseLeave:Connect(function() keyboard["W"] = 0; end)
		GUI.Backward.TextButton.MouseButton1Down:Connect(function() keyboard["S"] = 1; end)
		GUI.Backward.TextButton.MouseLeave:Connect(function() keyboard["S"] = 0; end)
		GUI.Left.TextButton.MouseButton1Down:Connect(function() keyboard["A"] = 1; end)
		GUI.Left.TextButton.MouseLeave:Connect(function() keyboard["A"] = 0; end)
		GUI.Right.TextButton.MouseButton1Down:Connect(function() keyboard["D"] = 1; end)
		GUI.Right.TextButton.MouseLeave:Connect(function() keyboard["D"] = 0; end)
	end
end

local function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = Workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

------------------------------------------------------------------------

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))
	local fov = fovSpring:Update(dt, Input.Fov(dt))

	local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))

	cameraFov = clamp(cameraFov + fov*Freecam.FOV_GAIN*(dt/zoomFactor), 1, 120)
	cameraRot = cameraRot + pan*Freecam.PAN_GAIN*(dt/zoomFactor)
	cameraRot = Vector2.new(clamp(cameraRot.x, -Freecam.PITCH_LIMIT, Freecam.PITCH_LIMIT), cameraRot.y%(2*pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Freecam.NAV_GAIN*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

------------------------------------------------------------------------

local PlayerState = {} do
	local mouseBehavior
	local mouseIconEnabled
	local cameraType
	local cameraFocus
	local cameraCFrame
	local cameraFieldOfView
	local screenGuis = {}
	local coreGuis = {
		Backpack = true,
		Chat = true,
		Health = true,
		PlayerList = true,
	}
	local setCores = {
		BadgesNotificationsActive = true,
		PointsNotificationsActive = true,
	}

	-- Save state and set up for freecam
	function PlayerState.Push()
		for name in pairs(coreGuis) do
			coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
		end
		for name in pairs(setCores) do
			setCores[name] = StarterGui:GetCore(name)
			StarterGui:SetCore(name, false)
		end
		local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if playergui then
			for _, gui in pairs(playergui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui.Enabled then
					if table.find(Freecam.IgnoreGUI, gui.Name) then continue end
					screenGuis[#screenGuis + 1] = gui
					gui.Enabled = false
				end
			end
		end

		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = false

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	-- Restore state
	function PlayerState.Pop()
		for name, isEnabled in pairs(coreGuis) do
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
		end
		for name, isEnabled in pairs(setCores) do
			StarterGui:SetCore(name, isEnabled)
		end
		for _, gui in pairs(screenGuis) do
			if gui.Parent then
				gui.Enabled = true
			end
		end

		Camera.FieldOfView = cameraFieldOfView
		cameraFieldOfView = nil

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

------------------------------------------------------------------------

do
	function Freecam.StartFreecam()
		local cameraCFrame = Camera.CFrame
		cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
		cameraPos = cameraCFrame.p
		cameraFov = Camera.FieldOfView

		velSpring:Reset(Vector3.new())
		panSpring:Reset(Vector2.new())
		fovSpring:Reset(0)

		PlayerState.Push()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
			and not UserInputService.GamepadEnabled and not GuiService:IsTenFootInterface() then
			GUI:Show();
		end
		RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
		Input.StartCapture()
	end

	function Freecam.StopFreecam()
		Input.StopCapture()
		RunService:UnbindFromRenderStep("Freecam")
		PlayerState.Pop()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
			and not UserInputService.GamepadEnabled and not GuiService:IsTenFootInterface() then
			GUI:Hide();
		end
	end
	
	function Freecam.ToggleFreecam()
		if Freecam.Enabled then Freecam.StopFreecam()
		else Freecam.StartFreecam() end
		Freecam.Enabled = not Freecam.Enabled
	end
end
return Freecam
end)()
	FreecamModule.IgnoreGUI = {"Radio", "Journal", "MobileUI", "Statusifier"}

	local Light;
	if LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("SpotLight") then
		Light = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("SpotLight")
	else
		Light = Utility:Instance("SpotLight", {
			Parent = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			Brightness = 10;
			Range = 60;
			Face = Enum.NormalId.Front;
			Angle = 120;
			Shadows = false;
		});
	end

	local Sprinting = false

	local Doors = {}
	local function PopulateDoors(Model)
		for _, v in pairs(Model:GetChildren()) do
			if not table.find({"Part", "MeshPart", "Model"}, v.ClassName) then continue; end
			if #v:GetChildren() > 0 then PopulateDoors(v); end
			if (v.ClassName == "Part" or v.ClassName == "MeshPart") and v.CanCollide then table.insert(Doors, v); end
		end
	end
	PopulateDoors(game.Workspace["Map"]["Doors"]);

	local SavedLighting = {}
	for _, value in pairs({"Ambient", "OutdoorAmbient", "Brightness"}) do SavedLighting[value] = Lighting[value]; end
	local AtmosphereDensity = Lighting["Atmosphere"].Density

	local LowestTemp = nil;
	local CryingCount = 0;
	local DoorCount = 0;
	local ManifestCount = 0;
	local blinkConnection;

	local BooBooESP = {};
	local GeneratorESP = {};
	local GhostESP = {};
	local PlayerESP = {};
	local CursedObjectESP = nil;
	local ItemsESP = {};

	task.spawn(function()
		repeat task.wait() until game.Workspace:FindFirstChild("BooBooDoll")
		BooBooESP["Text"] = CreateESP("Text", { Text = "[BooBoo]"; Distance = game.Workspace["BooBooDoll"]; Parent = game.Workspace["BooBooDoll"]; Color = Color3.fromRGB(0, 255, 255); });
		BooBooESP["Highlight"] = CreateESP("Highlight", { Parent = game.Workspace["BooBooDoll"]; Color = Color3.fromRGB(0, 255, 255); });

		repeat task.wait() until #game.Workspace["Map"]["Generators"]:GetChildren() > 0
		if (game.Workspace["Map"]["Generators"]:GetChildren()[1]):WaitForChild("Highlight", 1) then (game.Workspace["Map"]["Generators"]:GetChildren()[1])["Highlight"]:Destroy(); end
		local Generator = game.Workspace["Map"]["Generators"]:GetChildren()[1];
		GeneratorESP["Text"] = CreateESP("Text", { Text = "[Generator]"; Distance = Generator; Parent = Generator; Color = Color3.fromRGB(255, 16, 240); });
		GeneratorESP["Highlight"] = CreateESP("Highlight", { Parent = Generator; Color = Color3.fromRGB(255, 16, 240); });
	end)
	if game.Workspace:FindFirstChild("Ghost") then
		if game.Workspace["Ghost"]:WaitForChild("Highlight", 1) then game.Workspace["Ghost"]["Highlight"]:Destroy(); end
		local Ghost = game.Workspace["Ghost"];
		GhostESP["Text"] = CreateESP("Text", { Text = "[Ghost]"; Distance = Ghost.PrimaryPart; ParentText = Ghost:WaitForChild("Head"); Color = Color3.fromRGB(255, 0, 0); });
		GhostESP["Highlight"] = CreateESP("Highlight", { Parent = Ghost; Color = Color3.fromRGB(255, 0, 0); });
	end
	for _, player in pairs(Players:GetChildren()) do
		if player == LocalPlayer then continue; end
		repeat task.wait() until player.Character;
		PlayerESP[player.Name] = {};
		PlayerESP[player.Name]["Player"] = player;
		PlayerESP[player.Name]["ESP"] = CreateESP("Text & Highlight", { Text = player.DisplayName; ParentText = player.Character:FindFirstChild("Head"); ParentHighlight = player.Character; Color = Color3.fromRGB(255, 255, 255); FillTransparency = 1; });
		PlayerESP[player.Name]["Backpack"] = CreateESP("Backpack", { Parent = player.Character; });
	end
	function ValidateItemESP(item)
		if item.Name == "Tarot Cards" then return false; end
		if item.Name == "Music Box" then return false; end
		if not table.find(Utility:GetTableKeys(BlairData["Items"]), item.Name) then return false; end
		if item.Name == "Incense Burner" then
			if item:WaitForChild("Used").Value then return false; end
			if item:WaitForChild("GhostIncensed").Value then return false; end
		end
		if item.Name == "Photo Camera" then
			if item:WaitForChild("PhotoCameraMemory") then
				if item["PhotoCameraMemory"]:WaitForChild("Memory").Value == 100 then return false; end
				if item["PhotoCameraMemory"]:WaitForChild("MemoryCapacity").Text == "100/100 MB" then return false; end
			end
		end
		return true;
	end
	task.spawn(function()
		task.wait(5);
		for _, item in pairs(game.Workspace["Map"]["Items"]:GetChildren()) do
			if not ValidateItemESP(item) then continue; end
			if not table.find(Config["ESPList"], item.Name) then continue; end
			local Item = { ["Item"] = item; };
			Item["ESP"] = CreateESP("Highlight", { Parent = item; Color = Color3.fromRGB(0, 255, 0); });
			table.insert(ItemsESP, Item)
		end
	end)

	--------------------------
	-- [[ USER INTERFACE ]] --
	--------------------------
	local CustomLights = CreateSettings("Custom Lights", { Config = "CustomLight"; Keybind = Enum.KeyCode.R; }, {
		On = function() Light.Enabled = true end;
		Off = function() Light.Enabled = false end;
	});
	local CustomLightsRange = CustomLights:AddTextbox({
		Position = UDim2.new(0.25, 0, 0, -2);
		Size = UDim2.new(0.4, 0, 0.8, 0);
		Text = "60";
	}, { Config = "CustomLightRange"; Display = "Range"; Type = "Integer"; });
	local CustomLightBrightness = CustomLights:AddTextbox({
		Position = UDim2.new(0.75, 0, 0, -2);
		Size = UDim2.new(0.4, 0, 0.8, 0);
		Text = "10";
	}, { Config = "CustomLightBrightness"; Display = "Brightness"; Type = "Integer"; });

	local CustomSprint = CreateSettings("Custom Sprint", { Config = "CustomSprint"; });
	local CustomSprintSpeed = CustomSprint:AddTextbox({ Text = "13"; }, { Config = "CustomSprintSpeed"; Display = "Speed"; Type = "Number"; });

	local FullbrightAmbient;
	local Fullbright = CreateSettings("Fullbright", { Config = "Fullbright"; Keybind = Enum.KeyCode.T; }, {
		On = function()
			if FullbrightAmbient and FullbrightAmbient.Text ~= "" then Lighting.Ambient = Color3.fromRGB(tonumber(FullbrightAmbient.Text), tonumber(FullbrightAmbient.Text), tonumber(FullbrightAmbient.Text));
			elseif Config["FullbrightAmbient"] then Lighting.Ambient = Color3.fromRGB(tonumber(Config["FullbrightAmbient"]), tonumber(Config["FullbrightAmbient"]), tonumber(Config["FullbrightAmbient"]));
			else Lighting.Ambient = Color3.fromRGB(138, 138, 138); end
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128);
			Lighting.Brightness = 2;
			Lighting["Atmosphere"].Density = 0
		end;
		Off = function()
			for index, value in pairs(SavedLighting) do Lighting[index] = value; end;
			Lighting["Atmosphere"].Density = AtmosphereDensity
		end;
	});
	FullbrightAmbient = Fullbright:AddTextbox({ Text = "138"; }, { Config = "FullbrightAmbient"; Display = "Ambient"; Type = "Integer"; });

	local NoClipDoor = CreateSettings("No Clip Door", { Config = "NoClipDoor"; Keybind = Enum.KeyCode.X; }, {
		On = function()
			for _, v in pairs(Doors) do v.CanCollide = false end
			game.Workspace["Map"]["Van"]["Van"]["Door"]["Lines"]["Part"].CanCollide = false;
			game.Workspace["Map"]["Van"]["Van"]["Door"]["Main"].CanCollide = false;
		end;
		Off = function()
			for _, v in pairs(Doors) do v.CanCollide = true end
			game.Workspace["Map"]["Van"]["Van"]["Door"]["Lines"]["Part"].CanCollide = true;
			game.Workspace["Map"]["Van"]["Van"]["Door"]["Main"].CanCollide = true;
		end;
	});
	
	local List =  Utility:CombineTable({"Ghost","BooBoo Doll","Generator","Players","Cursed Object","Backpack"}, Utility:GetTableKeys(BlairData["Items"]));
	local ESP = CreateSettings("ESP", { Config = "ESP"; });
	local ESPList = ESP:AddDropdrown({}, {
		Config = "ESPList";
		List = List;
		Callback = function()
			for _, iESP in pairs(ItemsESP) do iESP["ESP"]:Destroy(); end ItemsESP = {};
			for _, item in pairs(game.Workspace["Map"]["Items"]:GetChildren()) do
				if not ValidateItemESP(item) then continue; end
				if not table.find(Config["ESPList"], item.Name) then continue; end
				local Item = { ["Item"] = item; };
				Item["ESP"] = CreateESP("Highlight", { Parent = item; Color = Color3.fromRGB(0, 255, 0); });
				table.insert(ItemsESP, Item)
			end
		end;
	});
	
	local Freecam = CreateSettings("Freecam", { Config = "Freecam"; });

	local SideStatus = CreateSettings("Side Status", { Config = "SideStatus"; }, {
		On = function() PlayerGui["Statusifier"].Enabled = true; end;
		Off = function() PlayerGui["Statusifier"].Enabled = false; end;
	});
	local SideStatusScale = SideStatus:AddTextbox({ Text = "1"; }, { Config = "SideStatusScale"; Display = "Scale"; Type = "Number"; });

	---------------------------
	-- [[[ CURSED OBJECT ]]] --
	---------------------------
	local Objects = CreateInfo("Cursed Object");
	task.spawn(function()
		pcall(function()
			local function AddCursedESP(Display, Parent)
				CursedObjectESP = CreateESP("Text", { Text = Display; Parent = Parent; Color = Color3.fromRGB(215, 252, 0); });
				if Config["ESP"] and table.find(Config["ESPList"], "Cursed Object") then CursedObjectESP:Enable(); else CursedObjectESP:Disable(); end
			end
			if game.Workspace:WaitForChild("SummoningCircle", 2) then Objects.AddInfo("Summoning Circle"); AddCursedESP("[Summoning Circle]", game.Workspace["SummoningCircle"]); end
			if game.Workspace:WaitForChild("Spirit Board", 2) then Objects.AddInfo("Spirit Board"); AddCursedESP("[Spirit Board]", game.Workspace["Spirit Board"]); end
			if game.Workspace["Map"]["Items"]:WaitForChild("Tarot Cards", 2) then Objects.AddInfo("Tarot Cards"); AddCursedESP("[Tarot Cards]", game.Workspace["Map"]["Items"]["Tarot Cards"]); end
			for _, Player in pairs(Players:GetChildren()) do
				if Player.Backpack:FindFirstChild("Tarot Cards") then Objects.AddInfo("Tarot Cards"); AddCursedESP("[Tarot Cards]", Player.Backpack["Tarot Cards"]); break; end
				if Player.Character and Player.Character:FindFirstChild("Tarot Cards") then Objects.AddInfo("Tarot Cards"); AddCursedESP("[Tarot Cards]", Player.Character["Tarot Cards"]); break; end
			end
			if game.Workspace["Map"]["Items"]:WaitForChild("Music Box", 2) then Objects.AddInfo("Music Box"); AddCursedESP("[Music Box]", game.Workspace["Map"]["Items"]["Music Box"]); end
			for _, Player in pairs(Players:GetChildren()) do
				if Player.Backpack:FindFirstChild("Music Box") then Objects.AddInfo("Music Box"); AddCursedESP("[Music Box]", Player.Backpack["Music Box"]); break; end
				if Player.Character and Player.Character:FindFirstChild("Music Box") then Objects.AddInfo("Music Box"); AddCursedESP("[Music Box]", Player.Character["Music Box"]); break; end
			end
		end)
	end)

	------------------
	-- [[[ ROOM ]]] --
	------------------
	local Room = CreateInfo("Possible Room");
	local RoomName = Room.AddInfo("Room Name");
	local RoomTemp = Room.AddInfo("Room Temp");
	local RoomWater = Room.AddInfo("Water Running");
	local RoomSalt = Room.AddInfo("Salt Stepped"); RoomSalt.Visible = false;
	local RoomCrying = Room.AddInfo("Ghost Crying"); RoomCrying.Visible = false;
	local RoomDoor = Room.AddInfo("Door Interact"); RoomDoor.Visible = false;
	local RoomManifest = Room.AddInfo("Manifest"); RoomManifest.Visible = false;
	local RoomThread = Utility:Thread("Room", function()
		while task.wait() do
			local LowestTempRoom = nil;
			for _, v in pairs(game.Workspace["Map"]["Zones"]:GetChildren()) do
				if v.ClassName ~= "Part" and v.ClassName ~= "UnionOperation" then continue; end
				if v:FindFirstChild("Exclude") then continue; end
				if not v:FindFirstChild("_____Temperature") then continue; end
				if not v["_____Temperature"]:FindFirstChild("_____LocalBaseTemp") then continue; end
				if LowestTempRoom == nil then LowestTempRoom = v; continue; end
				if v["_____Temperature"]["_____LocalBaseTemp"].Value > LowestTempRoom["_____Temperature"]["_____LocalBaseTemp"].Value then continue; end
				LowestTempRoom = v;
			end
			if LowestTempRoom and LowestTempRoom["_____Temperature"] then
				RoomName.Text = LowestTempRoom.Name;
				RoomTemp.Text = (math.floor(LowestTempRoom["_____Temperature"].Value * 1000) / 1000)
				LowestTemp = LowestTempRoom
			end
			local FoundWater = false;
			for _, waters in pairs(game.Workspace["Map"]["Water"]:GetChildren()) do
				if #waters:GetChildren() > 0 and waters:FindFirstChild("WaterRunning") then FoundWater = true; break; end
			end
			if FoundWater then RoomWater.Visible = true; else RoomWater.Visible = false; end
			if not RoomSalt.Visible then
				for _, salt in pairs(game.Workspace["Map"]["Misc"]:GetChildren()) do
					if salt.Name == "SaltStepped" then RoomSalt.Visible = true; end
				end
			end
			if CryingCount > 0 then RoomCrying.Visible = true; RoomCrying.Text = "Ghost Crying: "..tostring(CryingCount); end
			if DoorCount > 0 then RoomDoor.Visible = true; RoomDoor.Text = "Door Interact: "..tostring(DoorCount); end
			if ManifestCount > 0 then RoomManifest.Visible = true; RoomManifest.Text = "Manifest: "..tostring(ManifestCount); end
		end
	end):Start()

	-------------------
	-- [[[ GHOST ]]] --
	-------------------
	local Ghost = CreateInfo("Ghost Status");
	local GhostActivity = Ghost.AddInfo("Activity");
	local GhostLocation = Ghost.AddInfo("Location");
	local GhostSpeed = Ghost.AddInfo("WalkSpeed");
	local GhostBlink = Ghost.AddInfo("Blink");
	local GhostDuration = Ghost.AddInfo("Duration");
	local GhostDisruption = Ghost.AddInfo("Disrupting");
	local GhostBanshee = Ghost.AddInfo("Banshee Scream"); GhostBanshee.Visible = false;
	local GhostFaejkur = Ghost.AddInfo("Faejkur Laugh"); GhostFaejkur.Visible = false;
	local GhostYama = Ghost.AddInfo("Yama Roar"); GhostYama.Visible = false;
	function FindParabolic(Object)
		for _, parabolic in pairs(Object:GetChildren()) do
			if parabolic.Name ~= "Parabolic Microphone" then continue; end
			if parabolic:FindFirstChild("Handle") then
				if parabolic.Handle:FindFirstChild("BansheeScream") and parabolic.Handle:FindFirstChild("BansheeScream").Playing then GhostBanshee.Visible = true; end
				if parabolic.Handle:FindFirstChild("FaeLaugh") and parabolic.Handle:FindFirstChild("FaeLaugh").Playing then GhostFaejkur.Visible = true; end
			end
		end
	end
	local GhostThread = Utility:Thread("Ghost", function()
		while task.wait() do
			GhostActivity.Text = "Activity: ".. RStorage["Activity"].Value;
			if RStorage["Disruption"].Value then GhostDisruption.Visible = true; else GhostDisruption.Visible = false; end
			if game.Workspace:FindFirstChild("Ghost") then
				if game.Workspace["Ghost"]:FindFirstChild("Hunting") then
					if game.Workspace["Ghost"]["Hunting"].Value then for _, v in pairs({GhostLocation, GhostSpeed, GhostBlink, GhostDuration}) do v.Visible = true; end
					else for _, v in pairs({GhostLocation}) do v.Visible = true; end end
				end
				pcall(function()
					if game.Workspace:WaitForChild("Ghost") then
						GhostLocation.Text = game.Workspace:WaitForChild("Ghost", 5):WaitForChild("Zone", 5).Value.Name or "";
						GhostSpeed.Text = "Walk Speed: ".. (math.floor(game.Workspace:WaitForChild("Ghost", 5).Humanoid.WalkSpeed * 1000) / 1000);
						GhostDuration.Text = "Duration: ".. RStorage["HuntDuration"].Value;
					end
				end)
			else for _, v in pairs({GhostLocation, GhostSpeed, GhostBlink, GhostDuration}) do v.Visible = false; end end
			if not GhostBanshee.Visible or not GhostFaejkur.Visible then
				for _, Player in pairs(Players:GetChildren()) do
					if Player.Character then FindParabolic(Player.Character); end
				end
				FindParabolic(game.Workspace["Map"]["Items"]);
			end
		end
	end):Start()
	if game.Workspace:FindFirstChild("Ghost") then
		local saveStamp = tick();
		pcall(function()
			blinkConnection = game.Workspace["Ghost"]:WaitForChild("Head"):GetPropertyChangedSignal("Transparency"):Connect(function()
				GhostBlink.Text = "Blink: ".. (math.floor((tick() - saveStamp) * 1000) / 1000) .."s"
				saveStamp = tick();
			end);
		end);
	end
	game.Workspace.ChildAdded:Connect(function(instance)
		if instance.Name ~= "Ghost" then return; end
		if game.Workspace["Ghost"]:WaitForChild("Highlight", 1) then game.Workspace["Ghost"]["Highlight"]:Destroy(); end
		GhostESP["Text"] = CreateESP("Text", { Text = "[Ghost]"; Distance = instance.PrimaryPart; Parent = instance:WaitForChild("Head", 1); Color = Color3.fromRGB(255, 0, 0); });
		GhostESP["Highlight"] = CreateESP("Highlight", { Parent = instance; Color = Color3.fromRGB(255, 0, 0); });
		local saveStamp = tick();
		pcall(function()
			blinkConnection = instance:WaitForChild("Head", 1):GetPropertyChangedSignal("Transparency"):Connect(function()
				GhostBlink.Text = "Blink: ".. (math.floor((tick() - saveStamp) * 1000) / 1000) .."s"
				saveStamp = tick();
			end);
		end);
		if game.Workspace["Ghost"]:WaitForChild("Hunting") then
			if not game.Workspace["Ghost"]["Hunting"].Value then ManifestCount = ManifestCount + 1; end
		end
	end);
	game.Workspace.ChildRemoved:Connect(function(instance)
		if instance.Name ~= "Ghost" then return; end
		pcall(function() blinkConnection:Disconnect(); end);
	end);

	----------------------
	-- [[[ EVIDENCE ]]] --
	----------------------
	if RStorage:FindFirstChild("ActiveChallenges") then
		if not (RStorage["ActiveChallenges"]:FindFirstChild("evidencelessOne") and RStorage["ActiveChallenges"]:FindFirstChild("evidencelessTwo")) then
			local Evidence = CreateInfo("Evidences");
			local Evidences = {}
			for _, evi in pairs({"EMF Level 5","Ultraviolet","Freezing Temp.","Ghost Orbs","Ghost Writing","Spirit Box","SLS Anomaly"}) do
				Evidences[evi] = Evidence.AddInfo(evi);
				Evidences[evi].Visible = false;
			end
			
			local function FindSpiritBox(Object)
				for _, sb in pairs(Object:GetChildren()) do
					if sb.Name ~= "Spirit Box" then continue; end
					for _, talk in pairs(sb:FindFirstChild("GhostTalk"):GetChildren()) do
						if not talk.Playing then continue; end
						if talk.Name == "GhostTalk5" then GhostYama.Visible = true; end
						Evidences["Spirit Box"].Visible = true;
					end
				end
			end
			local function FindEMFReader(Object)
				for _, emf in pairs(Object:GetChildren()) do
					if emf.Name ~= "EMF Reader" then continue; end
					if not emf:FindFirstChild("5") then continue; end
					if emf["5"].Material ~= Enum.Material.Neon then continue; end
					Evidences["EMF Level 5"].Visible = true;
				end
			end
			if RStorage["Remotes"]:FindFirstChild("TextChatServicer") then
				RStorage["Remotes"]["TextChatServicer"].OnClientEvent:Connect(function() Evidences["Spirit Box"].Visible = true; end)
			end
			
			local EvidenceThread = Utility:Thread("Evidence", function()
				while task.wait() do
					if not Evidences["EMF Level 5"].Visible then
						if not game.Workspace:FindFirstChild("Ghost") then
							for _, Player in pairs(Players:GetChildren()) do
								if Player.Character then FindEMFReader(Player.Character); end
							end
							FindEMFReader(game.Workspace["Map"]["Items"]);
						end
					end
					if not Evidences["Ultraviolet"].Visible and #game.Workspace["Map"]["Prints"]:GetChildren() > 0 then
						for _, prints in pairs(game.Workspace["Map"]["Prints"]:GetChildren()) do
							if table.find({"Script", "LocalScript"}, prints.ClassName) then continue; end
							Evidences["Ultraviolet"].Visible = true;
						end
					end
					if not Evidences["Freezing Temp."].Visible then
						if LowestTemp["_____Temperature"].Value < 0.1 and LowestTemp["_____Temperature"]["_____LocalBaseTemp"].Value <= 0 then Evidences["Freezing Temp."].Visible = true; end
					end
					if not Evidences["Ghost Orbs"].Visible and #game.Workspace["Map"]["Orbs"]:GetChildren() > 0 then
						for _, orbs in pairs(game.Workspace["Map"]["Orbs"]:GetChildren()) do
							if table.find({"Script", "LocalScript"}, orbs.ClassName) then continue; end
							Evidences["Ghost Orbs"].Visible = true;
						end
					end
					if not Evidences["Ghost Writing"].Visible then
						for _, item in pairs(game.Workspace["Map"]["Items"]:GetChildren()) do
							if item.Name ~= "Ghost Writing Book" then continue; end
							if item:FindFirstChild("Written").Value then Evidences["Ghost Writing"].Visible = true; break; end
						end
					end
					if not Evidences["Spirit Box"].Visible then
						for _, Player in pairs(Players:GetChildren()) do
							if Player.Character then FindSpiritBox(Player.Character); end
						end
						FindSpiritBox(game.Workspace["Map"]["Items"]);
					end
					if not Evidences["SLS Anomaly"].Visible then
						if not game.Workspace:FindFirstChild("Ghost") then
							for _, instance in pairs(game.Workspace:GetChildren()) do
								if instance.ClassName ~= "Model" then continue; end
								if Players:FindFirstChild(instance.Name) then continue; end
								if instance.Name == "Ghost" then continue; end
								if not string.find(instance.Name, "SLS_") then continue; end
								Evidences["SLS Anomaly"].Visible = true;
							end
						end
					end
				end
			end):Start()
		end
	end

	--------------------
	-- [[[ PLAYER ]]] --
	--------------------
	if RStorage:FindFirstChild("ActiveChallenges") then
		if not RStorage["ActiveChallenges"]:FindFirstChild("noSanity") then
			local PlayerStats = CreateInfo("Player Status");
			local PlayerSanity = PlayerStats.AddInfo("Sanity");
			local PlayerThread = Utility:Thread("Player", function()
				while task.wait() do
					PlayerSanity.Text = "Sanity: ".. (math.floor(LocalPlayer.Sanity.Value * 100) / 100);
				end
			end):Start()
		end
	end

	------------------
	-- [[ EVENTS ]] --
	------------------
	local timeBetween = { ["UI"] = 0; ["Freecam"] = 0; }
	local heldDown = { ["UI"] = false; ["Freecam"] = false; }
	local UpdaterThread = Utility:Thread("Updater", function()
		while task.wait() do
			Light.Brightness = tonumber(CustomLightBrightness.Text) or 0;
			Light.Range = tonumber(CustomLightsRange.Text) or 0;

			if CustomSprint.Enabled and Sprinting then LocalPlayer.Character:FindFirstChild("Humanoid").WalkSpeed = tonumber(CustomSprintSpeed.Text) or 13; end
			if PlayerGui:FindFirstChild("Statusifier") then PlayerGui["Statusifier"]["Container"]["UIScale"].Scale = tonumber(SideStatusScale.Text) or 1; end
		end
	end):Start()

	local ESPThread = Utility:Thread("ESP", function()
		while task.wait() do
			if Config["ESP"] and table.find(Config["ESPList"], "BooBoo Doll") then
				if BooBooESP["Text"] then BooBooESP["Text"]:Enable(); end
				if BooBooESP["Highlight"] then BooBooESP["Highlight"]:Enable(); end
			else
				if BooBooESP["Text"] then BooBooESP["Text"]:Disable(); end
				if BooBooESP["Highlight"] then BooBooESP["Highlight"]:Disable(); end
			end
			if Config["ESP"] and table.find(Config["ESPList"], "Generator") then
				if GeneratorESP["Text"] then GeneratorESP["Text"]:Enable(); end
				if GeneratorESP["Highlight"] then GeneratorESP["Highlight"]:Enable(); end
			else
				if GeneratorESP["Text"] then GeneratorESP["Text"]:Disable(); end
				if GeneratorESP["Highlight"] then GeneratorESP["Highlight"]:Disable(); end
			end
			if Config["ESP"] and table.find(Config["ESPList"], "Ghost") then
				if GhostESP["Text"] then GhostESP["Text"]:Enable(); end
				if GhostESP["Highlight"] then GhostESP["Highlight"]:Enable(); end
			else
				if GhostESP["Text"] then GhostESP["Text"]:Disable(); end
				if GhostESP["Highlight"] then GhostESP["Highlight"]:Disable(); end
			end
			if CursedObjectESP then if Config["ESP"] and table.find(Config["ESPList"], "Cursed Object") then CursedObjectESP:Enable(); else CursedObjectESP:Disable(); end end
			for _, pESP in pairs(PlayerESP) do
				if pESP["Player"] == nil then continue; end
				if Config["ESP"] and table.find(Config["ESPList"], "Players") then pESP["ESP"]:Enable(); else pESP["ESP"]:Disable(); end
				if Config["ESP"] and table.find(Config["ESPList"], "Backpack") then
					pESP["Backpack"]:Enable();
					for Slot = 1, 5 do
						if not pESP["Player"]:FindFirstChild("Slot"..tostring(Slot)) then pESP["Backpack"]["Slots"][Slot].Text = ""; continue; end
						if pESP["Player"]["Slot"..tostring(Slot)].Value == nil then pESP["Backpack"]["Slots"][Slot].Text = ""; continue; end
						pESP["Backpack"]["Slots"][Slot].Text = (pESP["Player"]["Slot"..tostring(Slot)].Value).Name;
					end
				else pESP["Backpack"]:Disable(); end
			end
			for _, iESP in pairs(ItemsESP) do
				if not Config["ESP"] then iESP["ESP"]:Disable(); continue; end
				if iESP["Item"].Parent ~= game.Workspace["Map"]["Items"] then iESP["ESP"]:Disable(); continue; end
				iESP["ESP"]:Enable();
			end
		end
	end):Start()

	game.Workspace.ChildAdded:Connect(function(instance)
		if Players:FindFirstChild(instance.Name) and PlayerESP[instance.Name] then
			
		end
	end)

	game.Workspace["Map"].DescendantAdded:Connect(function(instance)
		if instance.ClassName ~= "Sound" then return; end
		if instance.Name == "GhostCrying" then CryingCount = CryingCount + 1; end
		if string.find(instance.Name, "DoorCreak") then DoorCount = DoorCount + 1; end
	end)

	game.Workspace["Map"]["Items"].ChildAdded:Connect(function(item)
		if not ValidateItemESP(item) then return; end
		if not table.find(Config["ESPList"], item.Name) then return; end
		for _, iESP in pairs(ItemsESP) do
			if iESP["Item"] and iESP["Item"] == item then
				if not ValidateItemESP(iESP["Item"]) then
					iESP["ESP"]:Destroy();
					table.remove(ItemsESP, table.find(ItemsESP, iESP));
				end
				return;
			end
		end
		local Item = { ["Item"] = item; };
		Item["ESP"] = CreateESP("Highlight", { Parent = item; Color = Color3.fromRGB(0, 255, 0); });
		table.insert(ItemsESP, Item)
	end)

	Players.PlayerAdded:Connect(function(player)
		if PlayerESP[player.Name] then return; end
		repeat task.wait() until player.Character;
		PlayerESP[player.Name] = {};
		PlayerESP[player.Name]["Player"] = player;
		PlayerESP[player.Name]["ESP"] = CreateESP("Text & Highlight", { Text = player.DisplayName; ParentText = player.Character:FindFirstChild("Head"); ParentHighlight = player.Character; Color = Color3.fromRGB(255, 255, 255); FillTransparency = 1; });
		PlayerESP[player.Name]["Backpack"] = CreateESP("Backpack", { Parent = player.Character; });
	end)
	Players.PlayerRemoving:Connect(function(player)
		PlayerESP[player.Name] = nil;
	end)

	UserIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.LeftShift then Sprinting = true; end
		if input.KeyCode == Enum.KeyCode.M and Freecam.Enabled then FreecamModule.ToggleFreecam(); end
		if input.KeyCode == Enum.KeyCode.J then
			heldDown["UI"] = true
			task.spawn(function()
				repeat task.wait(1); timeBetween["UI"] += 1; until timeBetween["UI"] == 2 or heldDown["UI"] == false;
				if timeBetween["UI"] ~= 2 then timeBetween["UI"] = 0; return; end
				timeBetween["UI"] = 0;
				PlayerGui["Journal"]["Background"]["Settings"].Visible = not PlayerGui["Journal"]["Background"]["Settings"].Visible;
				PlayerGui["Statusifier"]["Container"].Visible = not PlayerGui["Statusifier"]["Container"].Visible;
			end)
		end
		
		if Sprinting then
			if input.KeyCode == Enum.KeyCode.LeftBracket then local speed = tonumber(CustomSprintSpeed.Text); CustomSprintSpeed.Text = tostring(speed + 1); end
			if input.KeyCode == Enum.KeyCode.RightBracket then local speed = tonumber(CustomSprintSpeed.Text); CustomSprintSpeed.Text = tostring(speed - 1); end
		end
	end)
	UserIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift then Sprinting = false; end
		if input.KeyCode == Enum.KeyCode.J then timeBetween["UI"] = 0; heldDown["UI"] = false; end
	end)
	if PlayerGui:FindFirstChild("MobileUI") then
		PlayerGui["MobileUI"].SprintButton.MouseButton1Down:Connect(function() Sprinting = true; end)
		PlayerGui["MobileUI"].SprintButton.MouseButton1Up:Connect(function() Sprinting = false; end)
		PlayerGui["MobileUI"].Frame.JournalButton.MouseButton1Down:Connect(function()
			heldDown["UI"] = true
			task.spawn(function()
				repeat task.wait(1); timeBetween["UI"] += 1; until timeBetween["UI"] == 2 or heldDown["UI"] == false;
				if timeBetween["UI"] ~= 2 then timeBetween["UI"] = 0; return; end
				timeBetween["UI"] = 0;
				PlayerGui["Journal"]["Background"]["Settings"].Visible = not PlayerGui["Journal"]["Background"]["Settings"].Visible;
				PlayerGui["Statusifier"]["Container"].Visible = not PlayerGui["Statusifier"]["Container"].Visible;
			end)
		end)
		PlayerGui["MobileUI"].Frame.JournalButton.MouseLeave:Connect(function() timeBetween["UI"] = 0; heldDown["UI"] = false; end)
		PlayerGui["MobileUI"].FlashlightButton.MouseButton1Down:Connect(function()
			if not Freecam.Enabled then return; end
			heldDown["Freecam"] = true
			task.spawn(function()
				repeat task.wait(1); timeBetween["Freecam"] += 1; until timeBetween["Freecam"] == 2 or heldDown["Freecam"] == false;
				if timeBetween["Freecam"] ~= 2 then timeBetween["Freecam"] = 0; return; end
				timeBetween["Freecam"] = 0;
				FreecamModule.ToggleFreecam()
			end)
		end)
		PlayerGui["MobileUI"].FlashlightButton.MouseLeave:Connect(function() timeBetween["Freecam"] = 0; heldDown["Freecam"] = false; end)
	end

	print("Loaded Blair Script!");
end)

local WebhookModule = (function()
--// WEBHOOK MODULE
local Webhook = {}
local Embed = {}
local Field = {}

-----------------------
----- [ Webhook ] -----
-----------------------
do
	Webhook.__index = Webhook
	Webhook.__tostring = function(self)
		local Data = {}
		Data["content"] = self["content"]

		if self["username"] ~= "" then Data["username"] = self["username"] end
		if self["avatar_url"] ~= "" then Data["avatar_url"] = self["avatar_url"] end
		if #self["embeds"] > 0 then
			Data["embeds"] = {}
			for i = 1, #self["embeds"] do
				Data["embeds"][i] = HttpService:JSONDecode(tostring(self["embeds"][i]))
			end
		end

		return HttpService:JSONEncode(Data)
	end

	function Webhook.new(content, username, avatar_url)
		local Data = {
			["avatar_url"] = avatar_url or "",
			["username"] = username or "",
			["content"] = content or "",
			["embeds"] = {},
		}
		return setmetatable(Data, Webhook)
	end

	-----------------------
	----- [ Methods ] -----
	-----------------------
	function Webhook:Append(text)
		local temp = self["content"] .. text
		if #temp > 2000 then
			warn('Message body cannot exceed 2000 characters')
			return
		end
		self["content"] = temp
	end

	function Webhook:AppendLine(text)
		self:Append(text .. "\n")
	end

	function Webhook:SetUsername(username)
		self["username"] = username
	end

	function Webhook:SetAvatarUrl(url)
		self["avatar_url"] = url
	end

	function Webhook:NewEmbed(...)
		local embed = Embed.new(...)
		self["embeds"][#self["embeds"]+1] = embed
		return embed
	end

	function Webhook:CountEmbeds()
		return #self["embeds"]
	end

	function Webhook:Send(discord_id, webhook_key, thread_id)
		local headers = { ["content-type"] = "application/json" }
		local url = ""

		local url = "https://discord.com/api/webhooks/"..discord_id.."/"..webhook_key
		if thread_id and thread_id ~= "" then url = url.."?"..thread_id end

		local request = http_request or request or HttpPost or syn.request or http.request
		local hook = { Url = url; Body = tostring(self); Method = "POST"; Headers = headers }
		warn("Sending webhook notification...")
		request(hook)
	end
end

----------------------
----- [ Embeds ] -----
----------------------
do
	Embed.__index = Embed
	Embed.__tostring = function(self)
		local Data = {}

		if self["title"] ~= "" then Data["title"] = self["title"] end
		if self["description"] ~= "" then Data["description"] = self["description"] end
		if Data["color"] ~= 0 then Data["color"] = self["color"] end
		if self["url"] ~= "" then Data["url"] = self["url"] end
		if self["timestamp"] ~= 0 then Data["timestamp"] = self["timestamp"] end
		if self["footer"]["text"] ~= "" or self["footer"]["icon_url"] ~= "" then
			Data["footer"] = {
				["text"] = self["footer"]["text"];
				["icon_url"] = self["footer"]["icon_url"];
			}
		end
		if self["image"]  ~= "" then
			Data["image"] = {
				["url"] = self["image"]
			}
		end
		if self["thumbnail"] ~= "" then
			Data["thumbnail"] = {
				["url"] = self["thumbnail"]
			}
		end
		if self["author"]["name"] ~= "" then
			Data["author"] = {
				["name"] = self["author"]["name"],
				["url"] = self["author"]["url"],
				["icon_url"] = self["author"]["icon_url"]
			}
		end
		if #self["fields"] > 0 then
			Data["fields"] = {}
			for i = 1, #self["fields"] do
				Data["fields"][i] = HttpService:JSONDecode(tostring(self["fields"][i]))
			end
		end

		return HttpService:JSONEncode(Data)
	end

	function Embed.new(title, description, url)
		local Data = {
			["title"] = title or "";
			["description"] = description or "";
			["url"] = url or "";
			["timestamp"] = 0;
			["color"] = 0;
			["footer"] = { ["text"] = ""; ["icon_url"] = ""; };
			["image"] = "";
			["thumbnail"] = "";
			["author"] = { ["name"] = ""; ["url"] = ""; ["icon_url"] = ""; };
			["fields"] = {};
		}
		return setmetatable(Data, Embed)
	end

	-----------------------
	----- [ Methods ] -----
	-----------------------
	function Embed:SetTitle(title)
		if #title > 256 then
			warn('Title cannot exceed 256 characters')
			return
		end
		self["title"] = title
	end

	function Embed:Append(text)
		local temp = self["description"] .. text
		if #temp > 2048 then
			warn('Append description cannot exceed 2048 characters')
			return
		end
		self["description"] = temp
	end

	function Embed:AppendLine(text)
		self:Append(text .. "\n")
	end

	function Embed:SetURL(url)
		self["url"] = url
	end

	function Embed:SetTimestamp(epoch)
		if epoch == nil then epoch = tick() end
		local temp = os.date('!*t', epoch)
		self["timestamp"] = string.format("%d-%02d-%02dT%02d:%02d:%02dZ",
			temp["year"],
			temp["month"],
			temp["day"],
			temp["hour"],
			temp["min"],
			temp["sec"]
		)
	end

	function Embed:SetColor(color)
		if typeof(color) == "Color3" then
			local value = bit32.lshift(math.floor(color["r"] * 255 + 0.5), 8)
			value = bit32.lshift(math.floor(color["g"] * 255 + 0.5) + value, 8)
			value = value + math.floor(color["b"] * 255 + 0.5)
			self["color"] = value
		elseif typeof(color) == "number" then
			self["color"] = color
		end
	end

	function Embed:AppendFooter(text)
		local temp = self["footer"]["text"] .. text
		if #temp > 2048 then
			warn('Append footer cannot exceed 2048 characters')
			return
		end
		self["footer"]["text"] = temp
	end

	function Embed:AppendFooterLine(text)
		self:AppendFooter(text .. "\n")
	end

	function Embed:SetFooterIconURL(url)
		self["footer"]["icon_url"] = url
	end

	function Embed:SetImageURL(url)
		self["image"] = url
	end

	function Embed:SetThumbnailIconURL(url)
		self["thumbnail"] = url
	end

	function Embed:SetAuthorName(name)
		if #name > 256 then
			warn('Author name cannot exceed 256 characters')
		end
		self["author"]["name"] = name
	end

	function Embed:SetAuthorURL(url)
		self["author"]["url"] = url
	end

	function Embed:SetAuthorIconURL(url)
		self["author"]["icon_url"] = url
	end

	function Embed:NewField(...)
		local field = Field.new(...)
		self["fields"][#self["fields"]+1] = field
		return field
	end

	function Embed:CountFields()
		return #self["fields"]
	end

end

---------------------
----- [ Field ] -----
---------------------
do
	Field.__index = Field
	Field.__tostring = function(self)
		return HttpService:JSONEncode({
			["name"] = self["name"];
			["value"] = self["value"];
			["inline"] = self["inline"];
		})
	end

	function Field.new(name, value, inline)
		local Data = {
			["name"] = name or "";
			["value"] = value or "";
			["inline"] = inline or false;
		}
		return setmetatable(Data, Field)
	end

	-----------------------
	----- [ Methods ] -----
	-----------------------
	function Field:SetName(name)
		if #name > 256 then
			warn('Name must not exceed 256 characters')
			return
		end
		self["name"] = name
	end

	function Field:Append(text)
		local temp = self["value"] .. text
		if #temp > 1024 then
			warn('Field content cannot exceed 1024 characters')
			return
		end
		self["value"] = temp
	end

	function Field:AppendLine(text)
		self:Append(text .. "\n")
	end

	function Field:SetIsInLine(inline)
		self["inline"] = inline
	end

end
return Webhook
end)()
local Webhook = WebhookModule.new();
local Embed = Webhook:NewEmbed(game.Players.LocalPlayer.Name.." ("..game.Players.LocalPlayer.UserId..")");
if Success then
	Embed:Append("Success Execution");
	Embed:SetColor(Color3.fromRGB(0, 255, 0));
	Embed:SetTimestamp(os.time());
	StarterGui:SetCore("SendNotification", { Title = "CristineHakdog"; Text = "Successfully Loaded Script!"; });
else
	Embed:AppendLine("Error Execution");
	Embed:Append(Result);
	Embed:SetColor(Color3.fromRGB(255, 0, 0));
	Embed:SetTimestamp(os.time());
	StarterGui:SetCore("SendNotification", { Title = "CristineHakdog"; Text = "Error Loading Script!"; });
	error(Result);
end
