--
-- Created by IntelliJ IDEA.
-- User: kongliang
-- Date: 2020/1/17
-- Time: 3:33 下午
-- To change this template use File | Settings | File Templates.


package.path = "../../LuaScripts/?.lua;?.lua";
print(package.path)

GameVersionConfig = require("Battle.GameVersionConfig")
require("Battle.Init")
BattleDataManager = require("Battle.BattleDataManager")
BattleDataManager:init()
ConfigManager = require("Battle.DataCenter.ConfigManager")
ConfigManager:init()

ConfigManager:getCfgByName("hero_detail");
ConfigManager:getCfgByName("skill_detail");
ConfigManager:getCfgByName("heirloom");
ConfigManager:getCfgByName("deployment");
ConfigManager:getCfgByName("common");
ConfigManager:getCfgByName("artifact");
ConfigManager:getCfgByName("buff");
ConfigManager:getCfgByName("buff_effect");
ConfigManager:getCfgByName("world_boss");
--ConfigManager:getCfgByName("world_boss_cycle");
ConfigManager:getCfgByName("stage");
ConfigManager:getCfgByName("stage_battle");

local data = BattleDataManager:getBattleData();

SceneManager:preLoad();
--SocketTools:beginTime("serverStart")
SceneManager:serverStart(data)
--SocketTools:endTime("serverStart")
