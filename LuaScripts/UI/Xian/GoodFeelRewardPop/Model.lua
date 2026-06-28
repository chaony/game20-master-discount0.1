local M = class("GoodFeelRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
end

function M:getFuliList()
    local new_tab = {}
    local c_table = self:checkBuLv(self.m_vip)
    local next_vip_tab = self:getVipCfg(self.m_vip)
	for k,v in pairs(c_table) do
		if self:checkIsChange(v.sort, v.data[2]) == true then
            table.insert(new_tab, v)
        end
	end
    table.sort(new_tab, function(data1,data2)
        local new_1 = self:checkIsNew(data1.sort) == true and 0 or 1
        local new_2 = self:checkIsNew(data2.sort) == true and 0 or 1
        return new_1 < new_2;
    end)
    return new_tab
end

function M:checkBuLv(lv)
    local new_tab = {}
    local vip_cfg = self:getVipCfg(lv)
    local cs_hero_num = self:getCsHeroNum() --英雄初始上限
    if vip_cfg.hero_limit > cs_hero_num then
        local des_cfg = self:getVipDes("hero_limit")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, (vip_cfg.hero_limit - cs_hero_num))}})
        end
    end
    if vip_cfg.idle_coin > 0 then
        local des_cfg = self:getVipDes("idle_coin")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, (vip_cfg.idle_coin * 100))}})
        end
    end
    if vip_cfg.idle_hero_exp > 0 then
        local des_cfg = self:getVipDes("idle_hero_exp")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, (vip_cfg.idle_hero_exp * 100))}})
        end
    end
    if vip_cfg.quick_idle_times > 0 then
        local des_cfg = self:getVipDes("quick_idle_times")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.quick_idle_times)}})
        end
    end
    if vip_cfg.maze_coin > 0 then
        local des_cfg = self:getVipDes("maze_coin")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, (vip_cfg.maze_coin * 100))}})
        end
    end
    if vip_cfg.maze_destiny_coin > 0 then
        local des_cfg = self:getVipDes("maze_destiny_coin")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, (vip_cfg.maze_destiny_coin * 100) )}})
        end
    end
    if vip_cfg.arena_free_times > 0 then
        local des_cfg = self:getVipDes("arena_free_times")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.arena_free_times)}})
        end
    end
    if vip_cfg.high_arena_free_times > 0 then
        local des_cfg = self:getVipDes("high_arena_free_times")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.high_arena_free_times)}})
        end
    end
    if vip_cfg.single_bounty > 0 then
        local des_cfg = self:getVipDes("single_bounty")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.single_bounty)}})
        end
    end
    if vip_cfg.master_bounty > 0 then
        local des_cfg = self:getVipDes("master_bounty")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.master_bounty)}})
        end
    end
    if vip_cfg.battle_speed > 0 then
        local des_cfg = self:getVipDes("battle_speed")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end
    if vip_cfg.arena_battle_skip > 0 then
        local des_cfg = self:getVipDes("arena_battle_skip")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end
    if vip_cfg.bounty_auto_fill > 0 then
        local des_cfg = self:getVipDes("bounty_auto_fill")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end
    if vip_cfg.open_stargazer > 0 then
        local des_cfg = self:getVipDes("open_stargazer")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end
    if vip_cfg.contribution_times > 0 then
        local des_cfg = self:getVipDes("contribution_times")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.contribution_times)}})
        end
    end
    if vip_cfg.idle_time_limit > 0 then
        local des_cfg = self:getVipDes("idle_time_limit")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.idle_time_limit)}})
        end
    end
    if vip_cfg.word_boss_challenge_times > 0 then
        local des_cfg = self:getVipDes("word_boss_challenge_times")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.word_boss_challenge_times)}})
        end
    end
    -- if vip_cfg.bounty_limit > 0 then
    --     local des_cfg = self:getVipDes("bounty_limit")
    --     if des_cfg then
    --         table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.bounty_limit)}})
    --     end
    -- end
    if vip_cfg.shop_refresh_limit > 0 then
        local des_cfg = self:getVipDes("shop_refresh_limit")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.shop_refresh_limit)}})
        end
    end
    if vip_cfg.auto_battle > 0 then
        local des_cfg = self:getVipDes("auto_battle")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.auto_battle)}})
        end
    end
    if vip_cfg.four_tower_open_times > 0 then
        local des_cfg = self:getVipDes("four_tower_open_times")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.four_tower_open_times)}})
        end
    end
    if vip_cfg.high_arena_jump > 0 then
        local des_cfg = self:getVipDes("high_arena_jump")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end
    if vip_cfg.gacha_hyperbless > 0 then
        local des_cfg = self:getVipDes("gacha_hyperbless")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.gacha_hyperbless)}})
        end
    end
    if vip_cfg.guild_make and vip_cfg.guild_make > 0 then
        local des_cfg = self:getVipDes("guild_make")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end
    if vip_cfg.tower_auto and vip_cfg.tower_auto > 0 then
        local des_cfg = self:getVipDes("tower_auto")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end
    if vip_cfg.gw_test and vip_cfg.gw_test > 0 then
        local des_cfg = self:getVipDes("gw_test")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.gw_test)}})
        end
    end
    if vip_cfg.gve_time and vip_cfg.gve_time > 0 then
        local des_cfg = self:getVipDes("gve_time")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.gve_time)}})
        end
    end
    if vip_cfg.idle_equip_exp and vip_cfg.idle_equip_exp > 0 then
        local des_cfg = self:getVipDes("idle_equip_exp")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.idle_equip_exp* 100)}})
        end
    end
    if vip_cfg.mining_time and vip_cfg.mining_time > 0 then
        local des_cfg = self:getVipDes("mining_time")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.mining_time)}})
        end
    end
    if vip_cfg.translate_auto and vip_cfg.translate_auto > 0 then
        local des_cfg = self:getVipDes("translate_auto")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.translate_auto)}})
        end
    end
    if vip_cfg.reward_auto and vip_cfg.reward_auto > 0 then
        local des_cfg = self:getVipDes("reward_auto")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.reward_auto)}})
        end
    end
    if vip_cfg.bazaar_finish_time and vip_cfg.bazaar_finish_time > 0 then
        local des_cfg = self:getVipDes("bazaar_finish_time")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.bazaar_finish_time)}})
        end
    end
    if vip_cfg.pet_max and vip_cfg.pet_max > 0 then
        local des_cfg = self:getVipDes("pet_max")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.pet_max)}})
        end
    end
    if vip_cfg.factory_time_limit and vip_cfg.factory_time_limit > 0 then
        local des_cfg = self:getVipDes("factory_time_limit")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.factory_time_limit)}})
        end
    end
    if vip_cfg.race_tower_auto and vip_cfg.race_tower_auto > 0 then
        local des_cfg = self:getVipDes("race_tower_auto")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des}})
        end
    end

    return new_tab
end

function M:getVipCfg(lv)
    local vip_tab = ConfigManager:getCfgByName("vip")
    return vip_tab[lv]
end

--英雄初始数量
function M:getCsHeroNum()
    local cs_cfg = self:getVipCfg(0)
    return cs_cfg.hero_limit
end

function M:checkIsNew(k1)
    local vip_tab = ConfigManager:getCfgByName("vip")
    if self.m_vip == 0 then
        return true
    else
        local last_table = self:checkBuLv(self.m_vip - 1)
        for k,v in pairs(last_table) do
            if k1 == v.sort then
                return false
            end
        end
    end
    return true
end

function M:checkIsChange(k1,k2)
    local vip_tab = ConfigManager:getCfgByName("vip")
    if self.m_vip == 0 then
        return true
    else
        local last_table = self:checkBuLv(self.m_vip - 1)
        for k,v in pairs(last_table) do
            if k1 == v.sort and v.data[2] == k2 then
                return false
            end
        end
    end
    return true
end


function M:getVipDes(key)
    local vip_des_table = ConfigManager:getCfgByName("vip_des")
    if vip_des_table then
        for k,v in pairs(vip_des_table) do
            if v["function"] == key then
                v.sort = k
                return v
            end
        end
    end
    return nil
end

function M:setDes2(str, num)
    num = GameUtil:formatNum(num)
    local count = Language:getTextByKey(str, tostring(num))
    local ss = Language:getTextByKey(str)
    local ss2 = Language:getTextByKey(ss, tostring(num))
    return count
end


return M
