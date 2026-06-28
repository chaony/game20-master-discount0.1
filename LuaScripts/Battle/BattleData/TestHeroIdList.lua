local TestHeroIdList = {
    9211,
    9212,
    9213,
    9221,
    9222,
    9223,
    9231,
    9232,
    9233,
    9241,
    9242,
    9243,
}


local hero_id_dict = {}
---@type table<number, ConfigHeroSkin>
local heroSkinConfig = ConfigManager:getCfgByName("hero_skin")
for i, v in pairs(heroSkinConfig) do
    if string.find(v.prefab, "W_Test") == nil and v.name ~= "" then
        hero_id_dict[v.hero] = true
    end
end

---@type table<number, ConfigHeroDetail>
local heroDetailConfig = ConfigManager:getCfgByName("hero_detail")
for k, v in pairs(hero_id_dict) do
    local cfg = heroDetailConfig[k]
    if cfg and cfg.is_visible == 1 then
        table.insert(TestHeroIdList, k)
    end
end

--TestHeroIdList = {
--    504
--}

--------------------------------遗物---------------------------------
---@type table<number, ConfigHeirloom>
local heirloomConfig = ConfigManager:getCfgByName("heirloom")
local id_id = {}
for k, v in pairs(heirloomConfig) do
    if not id_id[v.group_id] or id_id[v.group_id] < k then
        id_id[v.group_id] = k
    end
end
local heirloom_ids = {}
for i, v in pairs(id_id) do
    table.insert(heirloom_ids, v)
end


--------------------------------秘籍----------------------------------
local mysticCfg = ConfigManager:getCfgByName("mystic")
local mystic_ids = table.keys(mysticCfg)

return {
    hero_ids = TestHeroIdList,
    heirloom_ids = heirloom_ids,
    mystic_ids = mystic_ids;
}