shared.TheConquerorsAPISignals = shared.TheConquerorsAPISignals or {}

for _, Signal in ipairs(shared.TheConquerorsAPISignals) do
    Signal:Disconnect();
end

shared.TheConquerorsAPISignals = {};

shared.TheConquerorsAPI = {
    Enabled = false;
} 

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Dump = loadstring(game:HttpGet('https://raw.githubusercontent.com/strawbberrys/LuaScripts/main/TableDumper.lua'))()
local Signal = loadstring(game:HttpGet('https://gist.githubusercontent.com/stravant/8820ed7386bd1f9264396f61fc851e3d/raw/9771ee1ec040a7cdfc44ac765714ad5cf5bf6fb0/RobloxSignal.lua'))();

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
local TeamNameCache = {}

local Classes = {};

local function AddConnection(Connection)
    return table.insert(shared.TheConquerorsAPISignals, Connection);
end

local BuildingDynamicProperties = {
    ["CFrame"] = function(self)
        return self.Instance:GetPivot();
    end;
    ["Owner"] = function(self)
        local TeamName = self.Instance.Parent.Name;

        return TeamNameCache[TeamName]
    end;
    ["Team"] = function(self)
        local TeamName = self.Instance.Parent.Name;

        return TeamNameCache[TeamName]
    end;
}

local Building = {} function Building:__index(Index)
    local Stats = rawget(self, "Torso");
    local Stat = Stats:FindFirstChild(Index);
    
    return rawget(Building, Index) or (Stat and #Stat:GetChildren() == 0 and Stat.Value) or BuildingDynamicProperties[Index] and BuildingDynamicProperties[Index](self); 
end

local BuildingCache = {}

function Building.new(BuildingObject)
    local self = BuildingCache[BuildingObject] or setmetatable({}, Building)
    
    BuildingCache[BuildingObject] = self;
    
    local Torso = BuildingObject:FindFirstChild("Torso");
    
    self.Name = BuildingObject.Name;
    self.Type = BuildingObject.Name;
    self.Instance = BuildingObject;
    self.Torso = Torso;
    self.InternalSignals = {
        Destroying = AddConnection(BuildingObject.Destroying:Connect(function()
            self:Destroy();
        end))
    };

    local Producing = Torso:FindFirstChild("Producing")

    if Producing then
        self.Producable = true;

        local UnitConstructing = Signal.new(); self.UnitConstructing = UnitConstructing;
        
        AddConnection(Producing.ChildAdded:Connect(function(Object)
            local Team = Object:WaitForChild("Team", .2);
            local TeamObject = TeamNameCache[Team.Value.Name]

            TeamObject.UnitConstructing:Fire(self, Object.Name)
            UnitConstructing:Fire(TeamObject, Object.Name);
        end))
    end

    return self
end

function Building:Destroy()
    BuildingCache[self.Instance] = nil;
    return Remotes.Destroy:FireServer(self.Instance);
end

function Building:DeployUnit(UnitType)
    return Remotes.DeployUnit:FireServer(UnitType, self.Instance)
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
        local TeamName = self.Instance.Parent.Name;

        return TeamNameCache[TeamName]
    end;
    ["Team"] = function(self)
        local TeamName = self.Instance.Parent.Name;

        return TeamNameCache[TeamName]
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
    
    self.Name = UnitObject.Name;
    self.Type = UnitObject.Name;
    self.Instance = UnitObject;
    self.Torso = Torso;
    self.InternalSignals = {
        Destroying = AddConnection(UnitObject.Destroying:Connect(function()
            UnitCache[UnitObject]:Disconnect();
        end))
    };

    if self.Name:lower():find("missile") then
        self.IsMissile = true;

        local Launched = Signal.new(); self.Launched = Launched;

        local MissileAlreadyFired = Torso:FindFirstChild("MissileAlreadyFired");

        AddConnection(MissileAlreadyFired:GetPropertyChangedSignal("Value"):Connect(function()
            if MissileAlreadyFired.Value then   
                Launched:Fire();
            end
        end))
    end

    local Producing = Torso:FindFirstChild("Producing")

    if Producing then
        self.Producable = true;

        local UnitConstructing = Signal.new(); self.UnitConstructing = UnitConstructing;
        
        AddConnection(Producing.ChildAdded:Connect(function(Object)
            local Team = Object:WaitForChild("Team", .2);
            local TeamObject = TeamNameCache[Team.Value.Name]

            TeamObject.UnitConstructing:Fire(self, Object.Name)
            UnitConstructing:Fire(TeamObject, Object.Name);
        end))
    end
    
    
    
    return self;
end

function Unit:MoveTo(Goal, IsWaypoint) --(Goal: Vector3 [Destination You Want To Move To], IsWaypoint: boolean [If the destination will be followed after the last one is done]) -> (nil)
    return AddToQueue(self.Instance, Goal, IsWaypoint)
end

function Unit:Destroy()
    UnitCache[self.Instance] = nil;
    Remotes.Destroy:FireServer(self.Instance);
end

function Unit:DeployUnit(UnitType)
    return Remotes.DeployUnit:FireServer(UnitType, self.Instance)
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
    ["Missiles"] = function(self)
        local Missiles = {};

        for _, Missile in ipairs(self.Units) do
            if Missile.Name:lower():find("missile") then
                
                table.insert(Missiles, Missile);
            end
        end

        return Missiles;
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
    
    local ColorName = tostring(TeamOBJ.TeamColor);

    TeamNameCache[ColorName] = self;
    Team.Name = ColorName;

    local ActualTeamname = TeamOBJ.Name self.ActualTeamname = ActualTeamname;
    local Color = TeamOBJ.TeamColor; self.Color = Color; -- Color3
    local Instance = TeamOBJ; self.Instance = Instance; -- TeamService Instance
    local WorkspaceInstance =  TeamsInstance:FindFirstChild(ColorName); self.WorkspaceInstance = WorkspaceInstance; -- Workspace Instance (holds units and buildings)
    local Stats = TeamSettings:FindFirstChild(ColorName); self.Stats = Stats  -- Stats Instance (holds stats and reseaarch etc)

    local UnitDeployed = Signal.new(); self.UnitDeployed = UnitDeployed 
    local UnitDeployedSignal = WorkspaceInstance.ChildAdded:Connect(function(Child)
        local Torso = Child:WaitForChild("Torso", .2)

        if Torso and not Torso:FindFirstChild("BuildProgress") then
            UnitDeployed:Fire(Classes.Unit.new(Child))
        end
    end) AddConnection(UnitDeployedSignal);

    -- local UnitGarrisoned = Signal.new(); self.UnitGarrisoned = UnitGarrisoned -- todo: intereferes with unitkilled;
    -- local UnitDeployed_UnitGarrisonedSignal = UnitDeployed:Connect(function()

    -- end)

    local UnitConstructing = Signal.new(); self.UnitConstructing = UnitConstructing; -- start Deploying


    local UnitKilled = Signal.new(); self.UnitKilled = UnitKilled
    local UnitKilledSignal = WorkspaceInstance.ChildRemoved:Connect(function(Child)
        local Torso = Child:FindFirstChild("Torso")

        if Torso and not Torso:FindFirstChild("BuildProgress") then
            local UnitClass = Classes.Unit.new(Child);
            local Health = UnitClass.Health
            
            UnitKilled:Fire(UnitClass);
        end
    end); AddConnection(UnitKilledSignal)

    local BuildingConstructing = Signal.new(); self.BuildingConstructing = BuildingConstructing
    local BuildingConstructingSignal = WorkspaceInstance.ChildAdded:Connect(function(Child)
        local Torso = Child:WaitForChild("Torso", .2)

        if Torso and Torso:FindFirstChild("BuildProgress") then
            BuildingConstructing:Fire(Classes.Building.new(Child))
        end
    end) AddConnection(BuildingConstructingSignal);

    local BuildingDestroyed = Signal.new(); self.BuildingDestroyed = BuildingDestroyed
    local BuildingDestroyedSignal = WorkspaceInstance.ChildRemoved:Connect(function(Child)
        local Torso = Child:FindFirstChild("Torso")

        if Torso and Torso:FindFirstChild("BuildProgress") then
            BuildingDestroyed:Fire(Classes.Building.new(Child))
        end
    end); AddConnection(BuildingDestroyedSignal)

    local MissileLaunched = Signal.new(); self.MissileLaunched = MissileLaunched;
    
    for _, Unit in ipairs(self.Missiles) do
        local Torso = Unit.Torso;
        local MissileAlreadyFired = Torso:FindFirstChild("MissileAlreadyFired");

        AddConnection(MissileAlreadyFired:GetPropertyChangedSignal("Value"):Connect(function()
            MissileLaunched:Fire(Unit)
        end))
    end

    AddConnection(UnitDeployed:Connect(function(Unit)
        local Torso = Unit.Torso;
        local MissileAlreadyFired = Torso:WaitForChild("MissileAlreadyFired", .5);

        if MissileAlreadyFired then
            AddConnection(MissileAlreadyFired:GetPropertyChangedSignal("Value"):Connect(function()
                MissileLaunched:Fire(Unit)
            end))
        end
    end))
    
    local MissileExploded = Signal.new(); self.MissileExploded = MissileExploded;

    AddConnection(workspace.DescendantAdded:Connect(function(Object)
        local MissileName = Object.Name;

        if MissileName == "BurningSoundPart" then
            MissileExploded:Fire("FireMissile", Object:GetPivot().Position);
        elseif Object:FindFirstChild("NukeLight") then
            MissileExploded:Fire("NuclearMissile", Object:GetPivot().Position);
        end
    end))

    local ResearchTable = self.Research:GetChildren()

    local ResearchDone = Signal.new(); self.ResearchDone = ResearchDone
    local ResearchUndone = Signal.new(); self.ResearchUndone = ResearchUndone
    local ResearchEnded = Signal.new(); self.ResearchEnded = ResearchEnded
    local ResearchStarted = Signal.new(); self.ResearchStarted = ResearchStarted;
    local ResearchCancelled = Signal.new(); self.ResearchCancelled = ResearchCancelled;
    local ResearchBuildingDestroyed = Signal.new(); self.ResearchBuildingDestroyed = ResearchBuildingDestroyed;

    local ProgressCache = {}
    local PriorFinishedResearch = {}

    for _, Research in ipairs(ResearchTable) do
        local Done = Research:FindFirstChild("Done");
        local Progress = Research:FindFirstChild("Progress");

        if Done then
            AddConnection(Done:GetPropertyChangedSignal("Value"):Connect(function()
                local IsDone = Done.Value;

                ProgressCache[Research] = false;
                (IsDone and ResearchDone or ResearchUndone):Fire(Research);
                
                PriorFinishedResearch[Research] = IsDone or nil
            end))
            AddConnection(Progress:GetPropertyChangedSignal("Value"):Connect(function()
                local ProgressValue = Progress.Value

                if ProgressValue == 0 and not Done.Value then
                    if PriorFinishedResearch[Research] then
                        ResearchBuildingDestroyed:Fire(Research);
                        PriorFinishedResearch[Research] = false
                    else
                        ResearchCancelled:Fire(Research);
                    end
                            
                    ProgressCache[Research] = false;
                elseif ProgressValue > 0 and not ProgressCache[Research] then
                    ProgressCache[Research] = true;

                    ResearchStarted:Fire(Research);
                end
            end))
        end
    end


    self.InternalSignals = {
        UnitDeployedSignal = UnitDeployedSignal;
        BuildingConstructingSignal = BuildingConstructingSignal;
        BuildingDestroyedSignal = BuildingDestroyedSignal;
    }

    return self;
end

function Team:GetAllUnits()
    local Result = {};

    for _, Unit in pairs(self.WorkspaceInstance:GetChildren()) do
        local Torso = Unit:WaitForChild("Torso")

        if Torso and not Torso:FindFirstChild("BuildProgress") then
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

    for _, Building in ipairs(self.WorkspaceInstance:GetChildren()) do
        local Torso = Building:FindFirstChild("Torso")

        if Torso and Torso:FindFirstChild("BuildProgress") then
            table.insert(Result, Classes.Building.new(Building))
        end
    end

    return Result;
end

Classes.Team = Team;

local function GetLocalTeam()
    return Classes.Team.new(LocalPlayer.Team)
end

local function GetAllTeams()
    local Result = {}
    
    for Index, Team in pairs(Teams:GetChildren()) do
        table.insert(Result, Classes.Team.new(Team));
    end
    
    return Result
end

local function GetAllActiveTeams() 
    local Result = {}
    
    for Index, Player in pairs(Players:GetPlayers()) do
        table.insert(Result, Classes.Team.new(Player.Team));
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
    Classes = Classes;
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
