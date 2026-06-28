---@class BattleConfigManager @
local M = class("BattleConfigManager")


function M:getHeroCurSkinCfgByData_Battle(hero_data, hero_cfg)
    local cur_skin = 0
    if hero_data then
        cur_skin = hero_data.skin or 0
    end
    if cur_skin == 0 and hero_cfg then
        local skin = hero_cfg.skin or {}
        cur_skin = skin[1]
    end
    local cur_skin_cfg = nil
    if cur_skin ~= 0 then
        cur_skin_cfg = ConfigManager:getHeroSkinCfg(cur_skin)
    end
    return cur_skin_cfg or hero_cfg
end


function M:getHeroDefaultSkinCfgByHeroCfg_Battle(hero_cfg)
    local default_skin = 0
    if hero_cfg then
        local skin = hero_cfg.skin or {}
        default_skin = skin[1] // 10 * 10 + 1
    end
    local default_skin_cfg = nil
    if default_skin ~= 0 then
        default_skin_cfg = ConfigManager:getHeroSkinCfg(default_skin)
    end
    return default_skin_cfg or hero_cfg
end


-- 获取秘籍组合
-- mystics 英雄装备的秘籍
---@return ConfigMysticBuff[]
function M:getMysticBuffs(equip_mystics, mystic_buffs)
    local buffs_config = {}
    if equip_mystics and mystic_buffs then
        local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
        local mystic_cfg = ConfigManager:getCfgByName("mystic")
        
        for i=1,5 do
            local mystics_id = equip_mystics[tostring(i)]
            if mystics_id then
                local mystic_cfg_item = mystic_cfg[mystics_id];
                if mystic_cfg_item ~= nil then
                    local buffs = mystic_buffs[tostring(mystics_id)]
                    if buffs and table.nums(buffs)>0 then
                        for i, vv in ipairs(buffs) do
                            local mystic_buff_cfg_item = mystic_buff_cfg[vv];
                            if mystic_buff_cfg_item ~= nil then
                                table.insert(buffs_config, { mystic = mystic_cfg_item, mystic_buff =  mystic_buff_cfg_item })
                            else
                                Logger.logError("秘籍 buff 配置，没有找到 id = "..vv)
                            end
                        end
                    end
                else
                    Logger.logError("秘籍配置，没有找到 id = ".. mystics_id.id)
                end
            end
        end
    end
    return buffs_config
end

-- 获取秘籍组合
-- mystics 英雄装备的秘籍 测试战斗用
---@return ConfigMysticBuff[]
function M:getMysticBuffsByConfigBattle(equip_mystics, mystic_buffs)
    local buffs_config = {}
    if equip_mystics and mystic_buffs then
        local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
        local mystic_cfg = ConfigManager:getCfgByName("mystic")

        for i=1,5 do
            local mystics_id = equip_mystics[tostring(i)]
            if mystics_id then
                local mystic_cfg_item = mystic_cfg[mystics_id];
                if mystic_cfg_item ~= nil then
                    local buffs = mystic_buffs[tostring(mystics_id)]
                    if buffs and table.nums(buffs)>0 then
                        for i, vv in ipairs(buffs) do
                            local mystic_buff_cfg_item = mystic_buff_cfg[vv];
                            if mystic_buff_cfg_item ~= nil then
                                table.insert(buffs_config, { mystic = mystic_cfg_item, mystic_buff =  mystic_buff_cfg_item })
                            else
                                Logger.logError("秘籍 buff 配置，没有找到 id = "..vv)
                            end
                        end
                    end
                else
                    Logger.logError("秘籍配置，没有找到 id = "..mystics.id)
                end
            end
        end
    end
    return buffs_config
end



-- 获取秘籍组合
-- mystics 英雄装备的秘籍
-- 一个两件套、两个两件套、一个三件套、一个四件套
function M:getMysticGroup(equip_mystics)
    local activation_group = {}
    equip_mystics = equip_mystics or {}

    local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
    local mystic_cfg = ConfigManager:getCfgByName("mystic")
    for k,v in pairs(mystic_buff_cfg) do
        local mystic_id = v.mystic_id or {}
        local len = #mystic_id
        local group = v.group
        local need_star_lv = v.lv
        local activation_len = 0
        for index, id in ipairs(mystic_id) do
            if equip_mystics[tostring(id)] ~= nil then
                --local data, cfg = self:getMysticDataById(id)
                local data = equip_mystics[tostring(id)]
                local cfg = mystic_cfg[id]
                if group == cfg.group and data.star >= need_star_lv then
                    activation_len = activation_len + 1
                end
            end
        end
        if activation_len == len then --激活
            if activation_group[group] == nil then
                activation_group[group] = v
            else
                if need_star_lv > activation_group[group].lv then-- 替换低等级的
                    activation_group[group] = v
                end
            end
        end
    end
    return table.values(activation_group)
end

return M;