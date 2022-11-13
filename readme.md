```lua
local ConquerorsAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Perthys/TheConquerors3-API/main/main.lua"))()

-- Team {Class}
-- => [Local Team Only]
Team:RequestAlliance(Team: Team {Class}) --=> Returns True if successful
Team:Research(ResearchType); 
Team:Build(BuildingType); 
Team:Destroy(Building: Building {Class} || Unit: Unit {Class})

--=> [All Teams]
Team:GetResearchPurchaseData(ResearchType) --=> Gets Research Time Relative to how much research centers availliable)
Team:GetBuildings(Filter: Table); --=> Filter Should look Like this {"Hospital"}
Team:GetUnits(Filter: Table); --=> Filter Should look like this {"Light Soldier"]

local Teams = ConquerorsAPI.Teams; 
Teams:GetTeams(); --=> Returns A array of all Teams in the game;
Teams:GetLocalTeam(); --=> Returns Your Local Team;

local WikiData = ConquerorsAPI.WikiData; --=> Contains Default Data About All Buildings and Units;

WikiData.Survival;
WikiData.FFA;
WikiData.Normal;
WikiData["1v1"];

Gamemode.Units; --=> Example WikiData.FFA.Units.Juggernaut.Health;


local Remotes = ConquerorsAPI.Remotes; --=> We automatically Map out all the remotes

Remotes.Destroy
Remotes.SetSkin
Remotes.SetHover
Remotes.Build
Remotes.DeployUnit
Remotes.MoveUnits
Remotes.Research
Remotes.BuyRotatingLootBox
Remotes.BuyLootBox



```
