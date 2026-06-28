--- 战斗上传数据检查，计算dps，最大攻击，最大生命

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


local hero_id_name = require("Battle.BattleData.HeroInfo")


require("Battle.BattleData.CSBattleCheck")

--D:\BattleData\verify\output

--local data = '{"sort": 1, "class_name": "BattleStage", "uid": 10671359712, "client_input": [{"attacker_team": {"team": ["111-1639153663-s0d4tT", "412-1639135216-NJt6g1", "310-1639138484-vK4ocH", "183-1639152896-ypK4Ha", "212-1639134758-Lp7YJC"], "deployment": 1, "relic": [], "heros": {"111-1639153663-s0d4tT": {"id": 111, "oid": "111-1639153663-s0d4tT", "ctime": 1639153663, "evo": 5, "ievo": 5, "attrs": {"critrate": 5120, "hp": 22792834, "atk": 2064542, "def": 362191, "hr": 35840, "dodge": 18432, "weight": 81920, "role_type": 3072}, "lv": 1, "clv": 100, "combat": 14110, "lock": false, "equips": {"5": {"id": 20205, "oid": 18, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 30201, "oid": 38, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 30202, "oid": 37, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 30203, "oid": 55, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 30204, "oid": 39, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 11112, "2": 11122, "3": 11131, "4": 11141, "5": 11151}, "sig": {}, "mystics": {}}, "412-1639135216-NJt6g1": {"id": 412, "oid": "412-1639135216-NJt6g1", "ctime": 1639135216, "evo": 8, "ievo": 5, "attrs": {"critrate": 9216, "hp": 36203455, "atk": 3512842, "def": 550192, "haste": 2048, "dodge": 4096, "weight": 81920, "role_type": 6144}, "lv": 100, "clv": 0, "combat": 22923, "lock": false, "equips": {"5": {"id": 50305, "oid": 49, "amount": 1, "exp": 10, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 20304, "oid": 25, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 50301, "oid": 28, "amount": 1, "exp": 10, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 50302, "oid": 69, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 40303, "oid": 72, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 41212, "2": 41222, "3": 41231, "4": 41241, "5": 41251}, "sig": {}, "evo_hero": {"481": 1, "484": 1, "485": 1}, "mystics": {}}, "310-1639138484-vK4ocH": {"id": 310, "oid": "310-1639138484-vK4ocH", "ctime": 1639138484, "evo": 5, "ievo": 5, "attrs": {"critrate": 5120, "hp": 21183026, "atk": 2249787, "def": 318764, "dodge": 6144, "weight": 81920, "role_type": 6144}, "lv": 1, "clv": 100, "combat": 14092, "lock": false, "equips": {"3": {"id": 20303, "oid": 24, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 30305, "oid": 59, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 30301, "oid": 67, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 30302, "oid": 56, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 30304, "oid": 57, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 31012, "2": 31022, "3": 31031, "4": 31041, "5": 31051}, "sig": {}, "mystics": {}}, "183-1639152896-ypK4Ha": {"id": 183, "oid": "183-1639152896-ypK4Ha", "ctime": 1639152896, "evo": 6, "ievo": 5, "attrs": {"critrate": 5120, "hp": 2980915, "atk": 607123, "def": 46198, "weight": 102400, "role_type": 0}, "lv": 1, "clv": 0, "combat": 3354, "lock": false, "equips": {}, "skill": {"1": 18311, "5": 18351}, "sig": {}, "mystics": {}}, "212-1639134758-Lp7YJC": {"id": 212, "oid": "212-1639134758-Lp7YJC", "ctime": 1639134758, "evo": 8, "ievo": 5, "attrs": {"critrate": 8192, "hp": 35471730, "atk": 3359981, "def": 471803, "dodge": 18432, "hr": 78848, "weight": 81920, "role_type": 4096}, "lv": 100, "clv": 0, "combat": 22142, "lock": false, "equips": {"5": {"id": 20205, "oid": 18, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 30204, "oid": 60, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 50201, "oid": 52, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 40202, "oid": 64, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 30203, "oid": 55, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 21212, "2": 21222, "3": 21231, "4": 21241, "5": 21251}, "sig": {}, "evo_hero": {"281": 1, "282": 2}, "mystics": {}}}, "dyns": {}, "team_id": 1}, "defender_team": {"team": ["282-1640158897-ASsqFr", "403-1640158897-dDJb5B", "485-1640158897-6b0tcv", "304-1640158897-MfvFh8", "406-1640158897-99pFJv"], "deployment": 1, "relic": {}, "heros": {"282-1640158897-ASsqFr": {"id": 282, "oid": "282-1640158897-ASsqFr", "ctime": 1640158897, "evo": 17, "ievo": 6, "attrs": {"critrate": 12288, "hp": 9237560886, "atk": 497062032, "def": 12749425, "rage": 0, "rageregenper": 0, "hr": 117760, "atd": 184, "dodge": 30720, "haste": 4096, "weight": 204800, "role_type": 0}, "lv": 211, "clv": 0, "combat": 3658968, "lock": false, "equips": {"1": {"id": 80101, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80102, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80103, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80104, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80105, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 28212, "2": 28223, "3": 28232, "5": 28251}, "sig": {}, "evo_hero": {"281": 16, "282": 4}, "buffs": [], "mystics": {}}, "403-1640158897-dDJb5B": {"id": 403, "oid": "403-1640158897-dDJb5B", "ctime": 1640158897, "evo": 17, "ievo": 6, "attrs": {"critrate": 12288, "hp": 8681974127, "atk": 525258613, "def": 12749425, "rage": 0, "rageregenper": 0, "hr": 117760, "atd": 184, "dodge": 30720, "haste": 4096, "weight": 81920, "role_type": 1024}, "lv": 211, "clv": 0, "combat": 3652338, "lock": false, "equips": {"1": {"id": 80101, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80102, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80103, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80104, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80105, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 40313, "2": 40324, "3": 40333, "4": 40342, "5": 40351}, "sig": {}, "evo_hero": {"481": 16, "403": 4}, "buffs": [], "mystics": {}}, "485-1640158897-6b0tcv": {"id": 485, "oid": "485-1640158897-6b0tcv", "ctime": 1640158897, "evo": 16, "ievo": 6, "attrs": {"critrate": 17408, "hp": 6706761962, "atk": 503477918, "def": 10142774, "rage": 0, "rageregenper": 0, "hr": 219136, "dodge": 152576, "weight": 102400, "role_type": 0}, "lv": 210, "clv": 0, "combat": 3177323, "lock": false, "equips": {"1": {"id": 80201, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80202, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80203, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80204, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80205, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 48512, "2": 48523, "3": 48532, "5": 48551}, "sig": {}, "evo_hero": {"481": 15, "485": 3}, "buffs": [], "mystics": {}}, "304-1640158897-MfvFh8": {"id": 304, "oid": "304-1640158897-MfvFh8", "ctime": 1640158897, "evo": 16, "ievo": 6, "attrs": {"critrate": 25600, "hp": 7888459446, "atk": 534249197, "def": 10310541, "rage": 204800, "rageregenper": 0, "res": 133, "dodge": 61440, "weight": 81920, "role_type": 5120}, "lv": 210, "clv": 0, "combat": 3519509, "lock": false, "equips": {"1": {"id": 80301, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80302, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80303, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80304, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80305, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 30413, "2": 30424, "3": 30433, "4": 30442, "5": 30451}, "sig": {}, "evo_hero": {"383": 15, "304": 3}, "buffs": [], "mystics": {}}, "406-1640158897-99pFJv": {"id": 406, "oid": "406-1640158897-99pFJv", "ctime": 1640158897, "evo": 16, "ievo": 6, "attrs": {"critrate": 17408, "hp": 5515350783, "atk": 570150415, "def": 9479374, "rage": 0, "rageregenper": 0, "hr": 219136, "dodge": 152576, "weight": 102400, "role_type": 4096}, "lv": 210, "clv": 0, "combat": 3182552, "lock": false, "equips": {"1": {"id": 80201, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80202, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80203, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80204, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80205, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 40613, "2": 40624, "3": 40633, "4": 40642, "5": 40651}, "sig": {}, "evo_hero": {"481": 15, "406": 3}, "buffs": [], "mystics": {}}}, "dyns": {}, "team_id": 1}}], "attacker_combat": 76621, "defender_combat": 17190690, "combat_rate": 0.75, "rc": 1, "cli_ver": "v1.1.0", "rounds": [{"autofight_operations": {"0": {"autofight": true}}, "attacker_dyns": {"310-1639138484-vK4ocH": {"mp_pct": 10240000, "hp_pct": 0}, "412-1639135216-NJt6g1": {"mp_pct": 0, "hp_pct": 0}, "183-1639152896-ypK4Ha": {"mp_pct": 0, "hp_pct": 0}, "212-1639134758-Lp7YJC": {"mp_pct": 8190000, "hp_pct": 0}, "111-1639153663-s0d4tT": {"mp_pct": 0, "hp_pct": 10240000}}, "defender_stats": {"406-1640158897-99pFJv": {"curMaxRage": 0, "rage": 102400, "def": 129296896000, "atk": 609224278, "hp": 0, "cure": 0, "curMaxHp": 6064731427}, "282-1640158897-ASsqFr": {"curMaxRage": 0, "rage": 102400, "def": 78612480000, "atk": 0, "hp": 0, "cure": 0, "curMaxHp": 10157708552}, "485-1640158897-6b0tcv": {"curMaxRage": 0, "rage": 102400, "def": 121539072000, "atk": 0, "hp": 0, "cure": 0, "curMaxHp": 7374818329}, "304-1640158897-MfvFh8": {"curMaxRage": 0, "rage": 102400, "def": 83702579200, "atk": 0, "hp": 0, "cure": 0, "curMaxHp": 8674223961}, "403-1640158897-dDJb5B": {"curMaxRage": 0, "rage": 102400, "def": 97357926400, "atk": 0, "hp": 0, "cure": 4288592643, "curMaxHp": 9546780144}}, "defender_dyns": {"406-1640158897-99pFJv": {"mp_pct": 10240000, "hp_pct": 0}, "282-1640158897-ASsqFr": {"mp_pct": 10240000, "hp_pct": 0}, "485-1640158897-6b0tcv": {"mp_pct": 10240000, "hp_pct": 0}, "304-1640158897-MfvFh8": {"mp_pct": 10240000, "hp_pct": 0}, "403-1640158897-dDJb5B": {"mp_pct": 10240000, "hp_pct": 0}}, "result": 1, "battle_cost_time": 1.59375, "operations": {}, "player_dead_frame": [{"instance": "412-1639135216-NJt6g1", "id": 412, "frame": 4096}, {"instance": "310-1639138484-vK4ocH", "id": 310, "frame": 4096}, {"instance": "183-1639152896-ypK4Ha", "id": 183, "frame": 4096}, {"instance": "212-1639134758-Lp7YJC", "id": 212, "frame": 4096}, {"instance": "406-1640158897-99pFJv", "id": 406, "frame": 16384}, {"instance": "304-1640158897-MfvFh8", "id": 304, "frame": 16384}, {"instance": "485-1640158897-6b0tcv", "id": 485, "frame": 16384}, {"instance": "403-1640158897-dDJb5B", "id": 403, "frame": 16384}, {"instance": "282-1640158897-ASsqFr", "id": 282, "frame": 16384}], "defender_team_id": 1, "frame": 16384, "attacker_team_id": 1, "round": 1, "attacker_stats": {"310-1639138484-vK4ocH": {"curMaxRage": 0, "rage": 102400, "def": 187411344, "atk": 480385331200, "hp": 0, "cure": 0, "curMaxHp": 23293054}, "412-1639135216-NJt6g1": {"curMaxRage": 0, "rage": 0, "def": 21063001600, "atk": 0, "hp": 0, "cure": 0, "curMaxHp": 39809659}, "212-1639134758-Lp7YJC": {"curMaxRage": 0, "rage": 81920, "def": 234034479, "atk": 51186624000, "hp": 0, "cure": 0, "curMaxHp": 39005047}, "111-1639153663-s0d4tT": {"curMaxRage": 0, "rage": 0, "def": 0, "atk": 0, "hp": 25063214, "cure": 0, "curMaxHp": 25063214}, "183-1639152896-ypK4Ha": {"curMaxRage": 0, "rage": 0, "def": 187778455, "atk": 0, "hp": 0, "cure": 0, "curMaxHp": 3277842}}}], "verify_data": {"result": 0, "cli_ver": "v1.1.0", "rounds": [{"player_dead_frame": [{"instance": "412-1639135216-NJt6g1", "frame": 8192, "id": 412}, {"instance": "183-1639152896-ypK4Ha", "frame": 16384, "id": 183}, {"instance": "212-1639134758-Lp7YJC", "frame": 19456, "id": 212}, {"instance": "310-1639138484-vK4ocH", "frame": 28672, "id": 310}, {"instance": "111-1639153663-s0d4tT", "frame": 28672, "id": 111}], "defender_dyns": {"406-1640158897-99pFJv": {"mp_pct": 10240000, "hp_pct": 10230000}, "485-1640158897-6b0tcv": {"mp_pct": 1100000, "hp_pct": 9010000}, "304-1640158897-MfvFh8": {"mp_pct": 3940000, "hp_pct": 10230000}, "403-1640158897-dDJb5B": {"mp_pct": 2290000, "hp_pct": 10230000}, "282-1640158897-ASsqFr": {"mp_pct": 3970000, "hp_pct": 10230000}}, "operations": [], "battle_cost_time": 2.7890625, "round": 1, "attacker_team_id": 1, "autofight_operations": {"28672": {"autofight": false}}, "attacker_stats": {"212-1639134758-Lp7YJC": {"hp": 0, "curMaxRage": 0, "cure": 0, "curMaxHp": 39005047, "def": 1087810502, "rage": 143892, "atk": 249935}, "183-1639152896-ypK4Ha": {"hp": 0, "curMaxRage": 0, "cure": 0, "curMaxHp": 3277842, "def": 206482787, "rage": 61440, "atk": 6649}, "111-1639153663-s0d4tT": {"hp": 0, "curMaxRage": 0, "cure": 0, "curMaxHp": 25063214, "def": 249178310, "rage": 93040, "atk": 130354}, "412-1639135216-NJt6g1": {"hp": 0, "curMaxRage": 0, "cure": 0, "curMaxHp": 39809659, "def": 312272412, "rage": 138240, "atk": 549412}, "310-1639138484-vK4ocH": {"hp": 0, "curMaxRage": 0, "cure": 0, "curMaxHp": 23293054, "def": 249422362, "rage": 241633, "atk": 1936929}}, "defender_team_id": 1, "defender_stats": {"282-1640158897-ASsqFr": {"hp": 10157324702, "curMaxRage": 0, "cure": 0, "curMaxHp": 10157708552, "def": 383850, "rage": 397450, "atk": 1087810502}, "485-1640158897-6b0tcv": {"hp": 6493348420, "curMaxRage": 0, "cure": 0, "curMaxHp": 7374818329, "def": 881469909, "rage": 110730, "atk": 880876456}, "406-1640158897-99pFJv": {"hp": 6064100094, "curMaxRage": 0, "cure": 0, "curMaxHp": 6064731427, "def": 631333, "rage": 1024000, "atk": 1017024208}, "403-1640158897-dDJb5B": {"hp": 9546451851, "curMaxRage": 0, "cure": 0, "curMaxHp": 9546780144, "def": 802626, "rage": 229022, "atk": 0}, "304-1640158897-MfvFh8": {"hp": 8674093607, "curMaxRage": 0, "cure": 469857601, "curMaxHp": 8674223961, "def": 130354, "rage": 394240, "atk": 0}}, "frame": 28672, "attacker_dyns": {"212-1639134758-Lp7YJC": {"mp_pct": 1430000, "hp_pct": 0}, "183-1639152896-ypK4Ha": {"mp_pct": 610000, "hp_pct": 0}, "412-1639135216-NJt6g1": {"mp_pct": 1380000, "hp_pct": 0}, "111-1639153663-s0d4tT": {"mp_pct": 930000, "hp_pct": 0}, "310-1639138484-vK4ocH": {"mp_pct": 2410000, "hp_pct": 0}}, "result": 0}], "damage": 862707, "cost_time": {}, "hero_count": {}, "use_time": 0.027757883071899414}, "battle_data": {"battle": {"sort": 1, "common": {"seed": 8725, "seed_team": 3, "param": 2408, "sub_param": 0, "battle_mode": 0, "battle_id": 2408, "attacker_add": {}, "attacker_heirloom": {}, "attacker_user": {"uid": 10671359712, "name": "u968fu4fbfu73a9u73a9", "gender": 0, "avatar": "283", "frame": 27, "level": 49, "guild_name": "u5343u91d1u6563u5c3du8fd8u590du6765"}, "attacker_element": [], "attacker_buffs": [], "defender_heirloom": {}, "defender_user": {}, "defender_element": [], "defender_buffs": []}, "client_input": [{"attacker_team": {"team": ["111-1639153663-s0d4tT", "412-1639135216-NJt6g1", "310-1639138484-vK4ocH", "183-1639152896-ypK4Ha", "212-1639134758-Lp7YJC"], "deployment": 1, "relic": [], "heros": {"111-1639153663-s0d4tT": {"id": 111, "oid": "111-1639153663-s0d4tT", "ctime": 1639153663, "evo": 5, "ievo": 5, "attrs": {"critrate": 5120, "hp": 22792834, "atk": 2064542, "def": 362191, "hr": 35840, "dodge": 18432, "weight": 81920, "role_type": 3072}, "lv": 1, "clv": 100, "combat": 14110, "lock": false, "equips": {"5": {"id": 20205, "oid": 18, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 30201, "oid": 38, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 30202, "oid": 37, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 30203, "oid": 55, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 30204, "oid": 39, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 11112, "2": 11122, "3": 11131, "4": 11141, "5": 11151}, "sig": {}, "mystics": {}}, "412-1639135216-NJt6g1": {"id": 412, "oid": "412-1639135216-NJt6g1", "ctime": 1639135216, "evo": 8, "ievo": 5, "attrs": {"critrate": 9216, "hp": 36203455, "atk": 3512842, "def": 550192, "haste": 2048, "dodge": 4096, "weight": 81920, "role_type": 6144}, "lv": 100, "clv": 0, "combat": 22923, "lock": false, "equips": {"5": {"id": 50305, "oid": 49, "amount": 1, "exp": 10, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 20304, "oid": 25, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 50301, "oid": 28, "amount": 1, "exp": 10, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 50302, "oid": 69, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 40303, "oid": 72, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 41212, "2": 41222, "3": 41231, "4": 41241, "5": 41251}, "sig": {}, "evo_hero": {"481": 1, "484": 1, "485": 1}, "mystics": {}}, "310-1639138484-vK4ocH": {"id": 310, "oid": "310-1639138484-vK4ocH", "ctime": 1639138484, "evo": 5, "ievo": 5, "attrs": {"critrate": 5120, "hp": 21183026, "atk": 2249787, "def": 318764, "dodge": 6144, "weight": 81920, "role_type": 6144}, "lv": 1, "clv": 100, "combat": 14092, "lock": false, "equips": {"3": {"id": 20303, "oid": 24, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 30305, "oid": 59, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 30301, "oid": 67, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 30302, "oid": 56, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 30304, "oid": 57, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 31012, "2": 31022, "3": 31031, "4": 31041, "5": 31051}, "sig": {}, "mystics": {}}, "183-1639152896-ypK4Ha": {"id": 183, "oid": "183-1639152896-ypK4Ha", "ctime": 1639152896, "evo": 6, "ievo": 5, "attrs": {"critrate": 5120, "hp": 2980915, "atk": 607123, "def": 46198, "weight": 102400, "role_type": 0}, "lv": 1, "clv": 0, "combat": 3354, "lock": false, "equips": {}, "skill": {"1": 18311, "5": 18351}, "sig": {}, "mystics": {}}, "212-1639134758-Lp7YJC": {"id": 212, "oid": "212-1639134758-Lp7YJC", "ctime": 1639134758, "evo": 8, "ievo": 5, "attrs": {"critrate": 8192, "hp": 35471730, "atk": 3359981, "def": 471803, "dodge": 18432, "hr": 78848, "weight": 81920, "role_type": 4096}, "lv": 100, "clv": 0, "combat": 22142, "lock": false, "equips": {"5": {"id": 20205, "oid": 18, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 30204, "oid": 60, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "1": {"id": 50201, "oid": 52, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 40202, "oid": 64, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 30203, "oid": 55, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 21212, "2": 21222, "3": 21231, "4": 21241, "5": 21251}, "sig": {}, "evo_hero": {"281": 1, "282": 2}, "mystics": {}}}, "dyns": {}, "team_id": 1}, "defender_team": {"team": ["282-1640158897-ASsqFr", "403-1640158897-dDJb5B", "485-1640158897-6b0tcv", "304-1640158897-MfvFh8", "406-1640158897-99pFJv"], "deployment": 1, "relic": {}, "heros": {"282-1640158897-ASsqFr": {"id": 282, "oid": "282-1640158897-ASsqFr", "ctime": 1640158897, "evo": 17, "ievo": 6, "attrs": {"critrate": 12288, "hp": 9237560886, "atk": 497062032, "def": 12749425, "rage": 0, "rageregenper": 0, "hr": 117760, "atd": 184, "dodge": 30720, "haste": 4096, "weight": 204800, "role_type": 0}, "lv": 211, "clv": 0, "combat": 3658968, "lock": false, "equips": {"1": {"id": 80101, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80102, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80103, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80104, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80105, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 28212, "2": 28223, "3": 28232, "5": 28251}, "sig": {}, "evo_hero": {"281": 16, "282": 4}, "buffs": [], "mystics": {}}, "403-1640158897-dDJb5B": {"id": 403, "oid": "403-1640158897-dDJb5B", "ctime": 1640158897, "evo": 17, "ievo": 6, "attrs": {"critrate": 12288, "hp": 8681974127, "atk": 525258613, "def": 12749425, "rage": 0, "rageregenper": 0, "hr": 117760, "atd": 184, "dodge": 30720, "haste": 4096, "weight": 81920, "role_type": 1024}, "lv": 211, "clv": 0, "combat": 3652338, "lock": false, "equips": {"1": {"id": 80101, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80102, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80103, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80104, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80105, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 40313, "2": 40324, "3": 40333, "4": 40342, "5": 40351}, "sig": {}, "evo_hero": {"481": 16, "403": 4}, "buffs": [], "mystics": {}}, "485-1640158897-6b0tcv": {"id": 485, "oid": "485-1640158897-6b0tcv", "ctime": 1640158897, "evo": 16, "ievo": 6, "attrs": {"critrate": 17408, "hp": 6706761962, "atk": 503477918, "def": 10142774, "rage": 0, "rageregenper": 0, "hr": 219136, "dodge": 152576, "weight": 102400, "role_type": 0}, "lv": 210, "clv": 0, "combat": 3177323, "lock": false, "equips": {"1": {"id": 80201, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80202, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80203, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80204, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80205, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 48512, "2": 48523, "3": 48532, "5": 48551}, "sig": {}, "evo_hero": {"481": 15, "485": 3}, "buffs": [], "mystics": {}}, "304-1640158897-MfvFh8": {"id": 304, "oid": "304-1640158897-MfvFh8", "ctime": 1640158897, "evo": 16, "ievo": 6, "attrs": {"critrate": 25600, "hp": 7888459446, "atk": 534249197, "def": 10310541, "rage": 204800, "rageregenper": 0, "res": 133, "dodge": 61440, "weight": 81920, "role_type": 5120}, "lv": 210, "clv": 0, "combat": 3519509, "lock": false, "equips": {"1": {"id": 80301, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80302, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80303, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80304, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80305, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 30413, "2": 30424, "3": 30433, "4": 30442, "5": 30451}, "sig": {}, "evo_hero": {"383": 15, "304": 3}, "buffs": [], "mystics": {}}, "406-1640158897-99pFJv": {"id": 406, "oid": "406-1640158897-99pFJv", "ctime": 1640158897, "evo": 16, "ievo": 6, "attrs": {"critrate": 17408, "hp": 5515350783, "atk": 570150415, "def": 9479374, "rage": 0, "rageregenper": 0, "hr": 219136, "dodge": 152576, "weight": 102400, "role_type": 4096}, "lv": 210, "clv": 0, "combat": 3182552, "lock": false, "equips": {"1": {"id": 80201, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "2": {"id": 80202, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "3": {"id": 80203, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "4": {"id": 80204, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}, "5": {"id": 80205, "oid": 0, "amount": 1, "exp": 0, "lv": 0, "race": 0, "lrace": 0}}, "skill": {"1": 40613, "2": 40624, "3": 40633, "4": 40642, "5": 40651}, "sig": {}, "evo_hero": {"481": 15, "406": 3}, "buffs": [], "mystics": {}}}, "dyns": {}, "team_id": 1}, "operations": {}, "autofight_operations": {"0": {"autofight": true}}}], "check_battle": 1}}, "battle_time": "2021-12-22 15:41:41", "test_data": "t"}'



local function collect_states_info(verify_data)
    local player_info = {}
    local battle_cost_time = verify_data.battle_cost_time
    local player_dead_frame = {}
    for i, v in ipairs(verify_data.player_dead_frame) do
        local time = GlobalTools:ToFloat(GlobalTools:Mul(v.frame, GlobalTools.base0_1))
        time = math.min(time, battle_cost_time)
        if v.instance then
            player_dead_frame[v.instance] = time
        end
    end
    
    for k, v in pairs(verify_data.attacker_stats) do
        player_info[k] = player_info[k] or {}
        player_info[k].atk = v.atk
        player_info[k].def = v.def
        player_info[k].battle_cost_time = player_dead_frame[k] or battle_cost_time
    end
    return player_info
end

local function collect_heroes_info(heroes)
    local player_info = {}
    for k, v in pairs(heroes) do
        player_info[k] = player_info[k] or {}
        player_info[k].atk = v.attrs.atk
        player_info[k].def = v.attrs.atk
    end
    return player_info
end



local function load_source_data(filePath)  
    filePath = string.format("D:/BattleData/verify/output/" .. filePath)
    local lines = io.lines(filePath)
    local datas = {}
    while true do
        local data = lines()
        if data then
            table.insert(data)
        else
            break
        end
    end
    return datas
end


local function save_dps_info(dps_info, out_path)
    for cid, v in pairs(dps_info) do
        cid = tonumber(cid)
        local hero_info = hero_id_name[cid] or {}
        local path = string.format("%s/%s_%s.txt", out_path, tostring(cid), tostring(hero_info[2]))
        local fileHandler = io.open(path, "w+")
        --Logger.log(Json.encode(v), "before sort")
        table.sort(v, function(a, b) return a.dps > b.dps end)
        --assert(#v < 3)
        if fileHandler then
            fileHandler:write(tostring(hero_info[1]) .. "\n")
            for i, vv in ipairs(v) do
                fileHandler:write(string.format("%s\t%s\t%s\t%s\t%s\n", 
                        vv.dps, vv.uid,
                        vv.index,
                        vv.class_name,
                        vv.sort))
            end
            fileHandler:close()
        end
    end
end

local ___cheat_tab = {}

local file_name = "battle_data.txt"
local filePath = string.format("D:/BattleData/verify/output/" .. file_name)
local lines = io.lines(filePath)
local index = 0
local hero_dps = {}
while true do
    local jdata = lines()
    if not jdata then
        break
    end
    index = index + 1
    Logger.log(jdata, "check --- " .. index)
    local data = Json.decode(jdata)
    local sort = data.sort
    local class_name = data.class_name
    local uid = data.uid
    if data.battle_data.battle.client_input and data.verify_data.rounds then
        local heroes = data.battle_data.battle.client_input[1].attacker_team.heros
        local verify_data1 = data.rounds[1]
        local verify_data2 = data.verify_data.rounds[1]

        local base = collect_heroes_info(heroes)
        local client = collect_states_info(verify_data1)
        local server = collect_states_info(verify_data2)

        local max_dps = 0
        for k, v in pairs(client) do
            local dps = client[k].atk / base[k].atk / client[k].battle_cost_time
            local cid = string.split(k, "-")[1]
            hero_dps[cid] = hero_dps[cid] or {}
            local dps_data = { dps = dps, uid = uid, cid = cid, index = index, sort = sort, class_name = class_name}
            table.insert(hero_dps[cid], dps_data)
            max_dps = math.max(max_dps, dps)
        end
        if max_dps >= 30 then
            table.insert(___cheat_tab,
                    { tostring(uid), tostring(max_dps), tostring(index), tostring(sort), tostring(class_name)})
        end
        --Logger.log(dps_info, "dps_info-----------")
    else
        Logger.log(jdata, "data.client_input ===== ")
    end
end
local out_path = "D:/BattleData/verify/output/dps/"
save_dps_info(hero_dps, out_path)

local path = string.format("%s/__cheat_data.txt", out_path)
local fileHandler = io.open(path, "w+")
table.sort(___cheat_tab, function(a, b)
    if a[1] == b[1] then
        return tonumber(a[2]) > tonumber(b[2])
    else
        return tonumber(a[1]) > tonumber(b[1])
    end
end)
if fileHandler then
    for i, v in ipairs(___cheat_tab) do
        fileHandler:write(table.concat(v, "  ") .. "\n")
    end
    fileHandler:close()
end


--local out_path = "D:/BattleData/temp/"
--local function save_verify_data(tag, data)
--    data.autofight_operations = nil
--    data = table.serialize(data)
--    local path = string.format("%s/%s.txt", out_path, tag)
--    local fileHandler = io.open(path, "w+")
--    if fileHandler then
--        fileHandler:write(data)
--        fileHandler:close()
--    end
--end
--save_verify_data("client", verify_data1)
--save_verify_data("server", verify_data2)
--
Logger.log("success -------")

