local ConquerorsAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Perthys/TheConquerors3-API/main/main.lua"))()
local Dump = loadstring(game:HttpGet('https://raw.githubusercontent.com/strawbberrys/LuaScripts/main/TableDumper.lua'))()

local TeamAPI = ConquerorsAPI.TeamAPI;

local LocalTeam = TeamAPI:GetLocalTeam();

local TeamData = {};
for Index, Team in pairs(TeamAPI:GetAllTeams()) do
    if not Team:IsAlliedWith(LocalTeam) then
        TeamData[Team.Name] = {}
        
        local CurrentTeamData = TeamData[Team.Name];
        
        CurrentTeamData.Name = Team.Name;
        CurrentTeamData.Researched = Team.Researched
        CurrentTeamData.Researching = Team.Researching;
        CurrentTeamData.CPM = Team.CashPerMinute
        CurrentTeamData.Cash = Team.Cash
    end
end

print("[Enemy Team Dossier]", Dump(TeamData))
