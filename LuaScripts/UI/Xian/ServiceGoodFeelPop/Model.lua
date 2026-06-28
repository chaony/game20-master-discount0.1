local M = class("ServiceGoodFeelPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_transfer = "up_to_down"
    self:getData()
end

function M:onEnter()
    self.m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    self.select_index = self.m_vip
    self.m_vip_exp = UserDataManager.user_data:getUserStatusDataByKey("vip_exp") or 0
    self.m_max_vip = self:getMaxVip()
    self:autoSelectIndex()
end

--自动获取当前选中区域
function M:autoSelectIndex()
    for i = 0, self.m_vip do
        local reward_status = self:checkCanGet(i)
        if reward_status == 1 then
            self.select_index = i
            return
        end
    end
    if self.m_vip < self.m_max_vip then
        self.select_index = self.m_vip + 1
    else
        self.select_index = self.m_vip  
    end
end

function M:getVipTableData()
    local vip_table_data = {}
    local cur_season = UserDataManager:getCurSeason()
    local vip_tab = ConfigManager:getCfgByName("vip")
    for index, item in pairs(vip_tab) do
        if item.season and item.season <= cur_season then
            vip_table_data[index] = item
        end
    end
    return vip_table_data
end


function M:getNextVip()
    local vip_tab = self:getVipTableData()
    if table.nums(vip_tab) > self.m_vip then
        return self.m_vip + 1
    else
        return self.m_vip
    end
end

function M:getMaxVip()
    local vip_tab = self:getVipTableData()
    local num = math.max(5, self.m_vip+2)
    local tab_max_num = table.nums(vip_tab)-1
    return math.min(num, tab_max_num)
end

function M:getVipProgress()
    local vip_tab = self:getVipTableData()
    local max_num = table.nums(vip_tab) 
    if max_num > self.m_vip+1 then
        local next_cfg = vip_tab[self.m_vip + 1]
        return self.m_vip_exp, next_cfg.exp
    else
        local max_cfg = vip_tab[max_num-1]
        return max_cfg.exp, max_cfg.exp
    end
end

function M:getVipCfg(lv)
    local vip_tab = self:getVipTableData()
    return vip_tab[lv]
end

--获取价格
function M:getPrice(lv)
    local vip_tab = self:getVipTableData()
    return vip_tab[lv].price_new,vip_tab[lv].price_old
end

function M:getFuliList()
    --local new_tab = {}
    local c_table = self:checkBuLv(self.select_index)
    --local next_vip_tab = self:getVipCfg(self.select_index-1)
    local function sortFunc(id_one, id_two)
        local is_new1 = self:checkIsNew(id_one.sort) == true and 1 or 0
        local is_new2 = self:checkIsNew(id_two.sort) == true and 1 or 0
        if is_new1 == is_new2 then
            return id_one.sort  < id_two.sort
        else
            return is_new1 > is_new2
        end
    end
    table.sort(c_table, sortFunc)
    return c_table
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
    if vip_cfg.gacha_receive_bless_times and vip_cfg.gacha_receive_bless_times > 0 then
        local des_cfg = self:getVipDes("gacha_receive_bless_times")
        if des_cfg then
            table.insert(new_tab,{sort = des_cfg.sort, data = {des_cfg.des, self:setDes2(des_cfg.des2, vip_cfg.gacha_receive_bless_times)}})
        end
    end
    
    return new_tab
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


function M:checkIsNew(k1)
    local vip_tab = self:getVipTableData()
    if self.select_index == 0 then
        return true
    else
        local last_table = self:checkBuLv(self.select_index - 1)
        for k,v in pairs(last_table) do
            if k1 == v.sort then
                return false
            end
        end
    end
    return true
end

function M:checkCanGet(index)
    local vip_received = UserDataManager.vip_received 
    if self.m_vip >= index then
        for k,v in pairs(vip_received) do
            if v == index then
                return 2
            end
        end
        return 1
    else
        return 0    
    end
    return 0
end

function M:checkBtnCanGet(bl)
    if bl == 1 then
        --左
        for i = 0, self.select_index - 1  do
            local reward_status = self:checkCanGet(i)
            if reward_status == 1 then
                return true
            end
        end
    else
        --右
        for i = self.select_index+1, self.m_vip do
            local reward_status = self:checkCanGet(i)
            if reward_status == 1 then
                return true
            end          
        end
    end
    return false
end

function M:setDes2(str, num)
    num = GameUtil:formatNum(num)
    local count = Language:getTextByKey(str, tostring(num))
    local ss = Language:getTextByKey(str)
    local ss2 = Language:getTextByKey(ss, tostring(num))
    return count
end

--英雄初始数量
function M:getCsHeroNum()
    local cs_cfg = self:getVipCfg(0)
    return cs_cfg.hero_limit
end

function M:getShowVipList()
    
end



return M
