BattleDataManager = require("Battle.BattleDataManager")
BattleDataManager:init()
ConfigManager = require("DataCenter.ConfigManager")
ConfigManager:init()

if GameVersionConfig.IS_SERVER == false then
    GlobalConfig = require("DataCenter.GlobalConfig")
    Language = require("DataCenter.Language")
    Language:init()
    UserDataManager = require("DataCenter.UserDataManager")
    UserDataManager:init()
end
BattleLevelConfig = require("Battle.battleLevelConfig")
BtnSoundConfig = require("DataCenter.BtnSoundConfig")
BattleUIConfig = require("Battle.battleUIConfig");