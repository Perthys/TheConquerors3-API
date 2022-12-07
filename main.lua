shared.TheConquerorsAPI = {
    Enabled = false;
} 

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Dump = loadstring(game:HttpGet('https://raw.githubusercontent.com/strawbberrys/LuaScripts/main/TableDumper.lua'))()

local Map = workspace:FindFirstChild("Map");
local Geometry = Map:FindFirstChild("Map");

local TeamsInstance = workspace:FindFirstChild("Teams");
local TeamSettings = workspace:FindFirstChild("TeamSettings")

local EnergyCrystals = Map:FindFirstChild("EnergyCrystals");
local OilSpots = Map:FindFirstChild("OilSpots");

local RemoteEventNames = {
    IjliIlI = "Destroy",
    IIjljj = "SetSkin",
    ljiIIi = "SetHover",
    jiIIIIi = "Build",
    iljiIjj = "DeployUnit",
    jjlIil = "MoveUnits",
    jIIlIlI = "Research";
    llljii = "Chat";
    lliIIii = "Garrison";
    jjjiii = "CancelUnit";
}

local RemoteFunctionsNames = {
    jjjllji = "BuyRotatingLootBox",
    IIilIII = "BuyLootBox"
}

local Remotes, RemoteFunctions = {}, {}

local Classes = {};

local BuildingDynamicProperties = {
    ["CFrame"] = function(self)
        return self.Instance:GetPivot();
    end;
    ["Owner"] = function(self)
        return Team.new(Teams:FindFirstChild(self.Instance.Parent.Name))
    end;
}

local Building = {} function Building:__index(Index)
    local Stats = rawget(self, "Torso");
    local Stat = Stats:FindFirstChild(Index);
    
    return rawget(Building, Index) or (Stat and #Stat:GetChildren() == 0 and Stat.Value) or BuildingDynamicProperties[Index] and BuildingDynamicProperties[Index](self); 
end

local BuildingCache = {}

function Building.new(BuilingObject)
    local self = BuildingCache[UnitOBJ] or setmetatable({}, Unit)
    
    BuildingCache[BuilingObject] = self;
    
    local Torso = BuilingObject:FindFirstChild("Torso");
    
    self.Type = BuilingObject.Name;
    self.Instance = BuilingObject;
    self.Torso = Torso;
    self.InternalSignals = {
        Destroying = BuilingObject.Destroying:Connect(function()
            self:Destroy();
        end)
    };

    return self
end

function Building:Destroy()
    BuildingCache[self.Instance] = nil;
    self.InternalSignals["Destroying"]:Disconnect();
    return Remotes.Destroy:FireServer(self.Instance);
end

local BuildingAllowedUnits = {
    ["Barracks"] = {
        "Light Soldier";
        "Heavy Soldier";
        "Medic";
        "Repairman";
        "Construction Soldier";
        "Anti-Air Soldier";
        "Sniper";
        "Scout";
        "Engineer";
    };
};

function Building:DeployUnit(UnitType)
    return BuildingAllowedUnits[self.Instance.Name] and table.find(BuildingAllowedUnits[self.Instance.Name], UnitType) and Remotes.DeployUnit:FireServer(UnitType, self.Instance)
end

function Building:Garrison()
    return Remotes.Garrison:FireServer({self.Instance})
end

Classes.Building = Building;

local UnitMovementQueue = {
    ["Waypointed"] = {

    };
    ["UnWaypointed"] = {

    };
};

shared.TheConquerorsAPI["Enabled"] = true;

task.spawn(function()
    while shared.TheConquerorsAPI["Enabled"] do
        for Index, Value in pairs(UnitMovementQueue.Waypointed) do
            local RequestData = {
                ["isAWaypoint"] = true,
                ["iIjjII"] = Value;
                ["Position"] = table.create(#Value, Index);
            }
        
            Remotes.MoveUnits:FireServer(RequestData)
            
            if not shared.TheConquerorsAPI["Enabled"] then
                break
            end
            
            UnitMovementQueue.Waypointed[Index] = nil;
        end

        for Index, Value in pairs(UnitMovementQueue.UnWaypointed) do
            local RequestData = {
                ["isAWaypoint"] = false,
                ["iIjjII"] = Value;
                ["Position"] = table.create(#Value, Index);
            }
        
            Remotes.MoveUnits:FireServer(RequestData)
            
            if not shared.TheConquerorsAPI["Enabled"] then
                break
            end
            
            UnitMovementQueue.UnWaypointed[Index] = nil;
        end
            
        task.wait(0.5)
    end
end)

local function AddToQueue(Unit, Position, IsAWaypoint)
    if IsAWaypoint then
        if not UnitMovementQueue.Waypointed[Position] then
            UnitMovementQueue.Waypointed[Position] = {}
        end

        table.insert(UnitMovementQueue.Waypointed[Position], Unit)
    else
        if not UnitMovementQueue.UnWaypointed[Position] then
            UnitMovementQueue.UnWaypointed[Position] = {}
        end

        table.insert(UnitMovementQueue.UnWaypointed[Position], Unit)
    end
end

local Unit = {} 
local UnitCache = {}

local UnitDynamicProperties = {
    ["CFrame"] = function(self)
        return self.Instance:GetPivot();
    end;
    ["Owner"] = function(self)
        return Team.new(Teams:FindFirstChild(self.Instance.Parent.Name))
    end;
};

function Unit:__index(Index)
    local Stats = rawget(self, "Torso");
    local Stat = Stats:FindFirstChild(Index);
    
    return rawget(Unit, Index) or (Stat and #Stat:GetChildren() == 0 and Stat.Value) or UnitDynamicProperties[Index] and UnitDynamicProperties[Index](self); 
end

function Unit.new(UnitObject)
    local self = UnitCache[UnitObject] or setmetatable({}, Unit)
    
    UnitCache[UnitObject] = self;
    
    local Torso = UnitObject:FindFirstChild("Torso");
    
    self.Type = UnitObject.Name;
    self.Instance = UnitObject;
    self.Torso = Torso;
    self.InternalSignals = {
        Destroying = UnitObject.Destroying:Connect(function()
            UnitCache[UnitObject]:Disconnect();
        end)
    };
    
    return self;
end

function Unit:MoveTo(Goal, IsWaypoint) --(Goal: Vector3 [Destination You Want To Move To], IsWaypoint: boolean [If the destination will be followed after the last one is done]) -> (nil)
    print(Goal, IsWaypoint)
    return AddToQueue(self.Instance, Goal, IsWaypoint)
end

function Unit:Destroy()
    UnitCache[self.Instance] = nil;
    self.InternalSignals["Destroying"]:Disconnect();
    Remotes.Destroy:FireServer(self.Instance);
end

local UnitAllowedUnits = {
    ["Barracks"] = {
        "Light Soldier";
        "Heavy Soldier";
        "Medic";
        "Repairman";
        "Construction Soldier";
        "Anti-Air Soldier";
        "Sniper";
        "Scout";
        "Engineer";
    };
};

function Unit:DeployUnit(UnitType)
    return UnitAllowedUnits[self.Instance.Name] and table.find(UnitAllowedUnits[self.Instance.Name], UnitType) and Remotes.DeployUnit:FireServer(UnitType, self.Instance)
end

function Unit:Garrison()
    return Remotes.Garrison:FireServer({self.Instance})
end

Classes.Unit = Unit;

local Team = {} 
local TeamCache = {};

local TeamDynamicProperties = {
    ["Owner"] = function(self)
        return self:GetPlayers()[1];
    end;
    ["Color"] = function(self)
        return self.Instance.TeamColor;
    end;
    ["Units"] = function(self)
        return self:GetAllUnits();
    end;
    ["Buildings"] = function(self)
        return self:GetAllBuildings();
    end;
    ["UnitsResearched"] = function(self)
        local UnitsResearched = self.Stats:FindFirstChild("UnitsResearched")
        local Result = {}
        
        for Index, Unit in pairs(UnitsResearched:GetChildren()) do
            table.insert(Result, Unit.Name);
        end
        
        return Result
    end;
    ["Research"] = function(self)
        return self:GetResearchTable();
    end;
    ["Researched"] = function(self)
        local Research = self.Research;
        local Result = {}
        
        for Index, Value in pairs(Research:GetChildren()) do
            local Done = Value:FindFirstChild("Done");
            
            if Done and Done.Value then
                table.insert(Result, Value.Name);
            end
        end
        
        return Result
    end;
    ["Researching"] = function(self)
        local Research = self.Research;
        local Result = {}
        for Index, Value in pairs(Research:GetChildren()) do
            local Progress = Value:FindFirstChild("Progress");
            local Done = Value:FindFirstChild("Done")
            
            if Progress and Progress.Value > 0 and not Done.Value then
                print(Value.Name)
                table.insert(Result, Value.Name)
            end
        end
        
        return Result
    end;
    ["AvailiableResearch"] = function(self)
        local Research = self.Research;
        local Result = {}
        
        for Index, Value in pairs(Research:GetChildren()) do
            local AvailiableNow = Value:FindFirstChild("AvailiableNow");
            
            if AvailiableNow and AvailiableNow.Value then
                table.insert(Result, AvailiableNow.Name);
            end
        end
        
        return Result;
    end;
    ["Name"] = function(self)
        return tostring(self.Instance.TeamColor)
    end
}

function Team:__index(Index)
    local Stats = rawget(self, "Stats");
    local Stat = Stats:FindFirstChild(Index);

    return rawget(Team, Index) or (Stat and Stat.Value) or TeamDynamicProperties[Index] and TeamDynamicProperties[Index](self); 
end

function Team.new(TeamOBJ)
    local self = TeamCache[TeamOBJ] or setmetatable({}, Team);

    TeamCache[TeamOBJ] = self;
    
    local ColorName = tostring(TeamOBJ.TeamColor)
    
    self.Color = TeamOBJ.TeamColor
    self.Instance = TeamOBJ;
    self.WorkspaceInstance = TeamsInstance:FindFirstChild(ColorName);
    self.Stats = TeamSettings:FindFirstChild(ColorName);
    
    return self;
end

function Team:GetAllUnits()
    local Result = {};

    for _, Unit in pairs(self.WorkspaceInstance:GetChildren()) do
        if not Unit:FindFirstChild("PyramidCollisionPart") then
            table.insert(Result, Classes.Unit.new(Unit))
        end
    end

    return Result;
end

function Team:GetResearchTable()
    for Index, Value in pairs(self.Stats:GetChildren()) do
        if Value:FindFirstChild("Juggernaut") then
            return Value
        end
    end
end

function Team:IsAlliedWith(Team)
    local Allies = self.Stats:FindFirstChild("Allies");
    
    return Allies:FindFirstChild(Team.Name)
end

function Team:GetAllBuildings()
    local Result = {};

    for _, Building in pairs(self.WorkspaceInstance:GetChildren()) do
        if Building:FindFirstChild("PyramidCollisionPart") then
            
            print(Result, Classes.Building.new(Building))
            table.insert(Result, Classes.Building.new(Building))
        end
    end

    return Result;
end

Classes.Team = Team;

local function GetLocalTeam()
    return Team.new(LocalPlayer.Team)
end

local function GetAllTeams()
    local Result = {}
    
    for Index, _Team in pairs(Teams:GetChildren()) do
        table.insert(Result, Team.new(_Team));
    end
    
    return Result
end

local function GetAllActiveTeams() 
    local Result = {}
    
    for Index, Player in pairs(Players:GetPlayers()) do
        table.insert(Result, Team.new(Player.Team));
    end
    
    return Result
end

local TeamAPI = {
    GetLocalTeam = GetLocalTeam;
    GetAllTeams = GetAllTeams;
    GetAllActiveTeams = GetAllActiveTeams;
};

local ConquerorsAPI = {
    Remotes = Remotes;
    RemoteFunctions = RemoteFunctions;
    TeamAPI = TeamAPI;
}

local function SetUpRemotes()
    for Index, Value in pairs(ReplicatedStorage:GetDescendants()) do
        if Value:IsA("RemoteEvent") or Value:IsA("RemoteFunction") then
            if RemoteEventNames[Value.Name] then
                Remotes[RemoteEventNames[Value.Name]] = Value
            elseif RemoteFunctionsNames[Value.Name] then
                RemoteFunctions[RemoteFunctionsNames[Value.Name]] = Value;
            end
        end
    end
end

SetUpRemotes()

return ConquerorsAPI
