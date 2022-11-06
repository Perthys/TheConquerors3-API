local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Dump = loadstring(game:HttpGet('https://raw.githubusercontent.com/strawbberrys/LuaScripts/main/TableDumper.lua'))()

local Map = workspace:FindFirstChild("Map");
local Geometry = Map:FindFirstChild("Map");

local EnergyCrystals = Map:FindFirstChild("EnergyCrystals");
local OilSpots = Map:FindFirstChild("OilSpots");

local RemoteEventNames = {
    Iiljjii = "Destroy",
    IIjljj = "SetSkin",
    ljiIIi = "SetHover",
    jiIIIIi = "Build",
    iljiIjj = "DeployUnit",
    jjlIil = "MoveUnits",
    jIIlIlI = "Research"
}

local RemoteFunctionsNames = {
    jjjllji = "BuyRotatingLootBox",
    IIilIII = "BuyLootBox"
}

local Remotes = {}
local RemoteFunctions = {};

-- (Resource Nodes) 

local Resource = {}; Resource.__index = Resource;

local ResourceTypeMap = {
    [BrickColor.new("Really black")] = "Oil";
    [BrickColor.new("Lime green")] = "EnergyCrystal";
    [BrickColor.new("Toothpaste")] = "BlueEnergyCrystal";
}

local function FormatResourceTypeMap()
    for Index, Value in pairs(ResourceTypeMap) do
        ResourceTypeMap[tostring(Index)] = Value
        ResourceTypeMap[Index] = nil;
    end
end

local function GetResourceType(Instance)
    local Torso = Instance:FindFirstChild("Torso");
    
    if Torso then
        local Result = ResourceTypeMap[tostring(Torso.BrickColor)]
        
        print("A", Result)
        
        return Result
    end
end

function Resource.new(Instance)
    local self = setmetatable({}, Resource);
    
    self.Type = GetResourceType(Instance);
    self.Instance = Instance;
    
    local CFramePos = Instance:GetPivot()
    
    self.CFrame = CFramePos;
    self.Position = CFramePos.Position
    
    return self.Type and self;
end;

function Resource:GetNearbyEco()
    print(Dump(self));
end

local function GetAllOil()
    local Result = {};
    
    for Index, Value in pairs(EnergyCrystals:GetChildren()) do
        table.insert(Result, Resource.new(Value));
    end
    
    return Result
end

local function GetAllCrystals()
    local Result = {};
    
    for Index, Value in pairs(OilSpots:GetChildren()) do
        table.insert(Result, Resource.new(Value));
    end
    
    return Result;
end

local function GetAllResources()
    local OilTable = GetAllOil();
    
    for Index, Value in pairs(GetAllCrystals()) do
        table.insert(OilTable, Value);
    end
    
    return OilTable
end

local Resources = {
    GetAllCrystals = GetAllCrystals;
    GetAllOil = GetAllOil
    GetAllResources = GetAllResources;
};

-- (Teams)

local Team = {} Team.__index = Teams;

function Team.new()
    
end

function GetLocalTeam()
    
end

local Teams = {

}

local Enum = {
    ResourceTypes = {
        ["Oil"] = "Oil";
        ["EnergyCrystal"] = "EnergyCrystal";
        ["BlueEnergyCrystal"] = "BlueEnergyCrystal";
    }
};

local ConquerorsAPI = {
    Remotes = Remotes;
    RemoteFunctions = RemoteFunctions;
    Resources = Resources;
    Enum = Enum;
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
MapTable();

print(Dump(Remotes))



