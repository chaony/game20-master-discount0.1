-- 宠物数据模板 测试使用


local pet_data_json = [[
{
        "id": 502,
        "skill": {
            "1": 50214,
            "2": 50224,
            "3": 50234,
            "4": 50244,
            "5": 50251
        },
        "mystics": {},
        "ctime": 1640534918,
        "attrs": {
            "def": 4170529.0743,
            "atk": 24124069.5311,
            "critrate": 5,
            "hp": 285611840.7279
        },
        "ievo": 5,
        "lock": false,
        "lv": 1,
        "oid": "502-1640534918-0KyggO",
        "equips": {},
        "fate_level": 0,
        "book": {}, 
        "evo": 24,
        "combat": 368971371,
        "evo_hero": {},
        "sig": {},
        "clv": 4179
    }
]]



function GeneratePetData(petData)
    if petData.skin and petData.id then
        --900101 猫
        --900001 测试狼
        ---@type Battle_CreatePlayerData
        local oneData = Json.decode(pet_data_json)
        oneData.id = petData.id
        oneData.skin = petData.skin
        oneData.skill = {
            ["1"] = tonumber(petData.id .. "16"),
            ["2"] = tonumber(petData.id .. "18"),
        }
        oneData.oid = "1"

        local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
        local hero_detail_cfg = ConfigManager:getCfgByName("hero_detail")
        if not hero_skin_cfg[petData.skin] then
            Logger.logError(petData.skin, "宠物皮肤找不到")
            return nil
        end
        if not hero_detail_cfg[petData.id] then
            Logger.logError(petData.id, "宠物配置找不到")
            return nil
        end
        return oneData
    end
end

return GeneratePetData

