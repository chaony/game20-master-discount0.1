local M = class("HeroBookModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
    self.m_open_tab_index =  self:initSelectOpen() or 1
    self.m_sel_tab_index = 0
    self.m_show_del_tim = 0.5
end

--英雄图鉴数据
function M:getHeroTj()
    local book_tab = ConfigManager:getCfgByName("book")
    local b_list = {}
    for k,v in pairs(book_tab) do
        if v.unlock == 1 then
            table.insert(b_list, {id = k, data = v})
        end
    end
    self:heroIdsSort(b_list)
    return b_list
end

function M:getAllReward()
    local rewardNode = {107,0,0}
    self.active_num = 0
    for k,v in pairs(UserDataManager.hero_data.hero_collect) do
        if v == 0 then
            self.active_num = self.active_num + 1
            local hero_cfg = self:getByCid(tonumber(k))
            if hero_cfg then
                if hero_cfg.unlock_reward and hero_cfg.unlock_reward[1] then
                    rewardNode[3] = rewardNode[3] + hero_cfg.unlock_reward[1][3]
                end
            end
        end
    end
    return rewardNode
end

function M:checkEvo(id)
    local cfg = self:getByCid(id)
    if cfg  then
        return cfg.evo 
    end
    return 1
end

function M:getByCid(id)
    return UserDataManager.hero_data:getHeroConfigByCid(id)
end

function M:checkHave(id)
    return UserDataManager.hero_data:checkHeroCollect(id) 
end

function M:checkCanShow(id)
    if UserDataManager.hero_data.hero_collect[tostring(id)] == 0 then
        local play_tj_bl = UserDataManager.local_data:getUserDataByKey("hero_book_show_"..id, 0)
        if play_tj_bl == 0 then
            return true
        else
            return false    
        end
    end
    return false
end

function M:setHeroShowStatus(id)
    UserDataManager.local_data:setUserDataByKey("hero_book_show_"..id, 1)
end

function M:setAllHeroStatus()
    for k,v in pairs(UserDataManager.hero_data.hero_collect) do
        if v == 0 then
            UserDataManager.local_data:setUserDataByKey("hero_book_show_"..k, 1)
        end
    end
end

function M:initSelectOpen()
    for i = 1,4 do
        if self:checkOpenIndex(i) == true then
            return i
        end
    end
    return 1
end

function M:checkOpenIndex(race)
    for k,v in pairs(UserDataManager.hero_data.hero_collect) do
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(k))
        if race == cfg.race and v == 0 then
            return true
        end
    end
    return false
end

function M:getFriendLines(id)
    return UserDataManager.m_friendliness[tostring(id)] or {point=0,lv=0}
end

function M:checkRedPoint(id)
    return UserDataManager.hero_data:checkHeroCollectPoint(id)
end

function M:checkRaceTypeCount(race)
    if race ~= 5 and race ~= 6 then
        return false
    end
    return false
end

function M:getHerosByRace()
    local heros = UserDataManager.hero_data:getHeroCfgMakeRace()
    if self.m_sel_tab_index == 5 then
        local ya_tab = table.copy(heros[5]) or {}
        local yi_tab = table.copy(heros[6]) or {}
        table.insertto(yi_tab, ya_tab)
        return yi_tab
    else
        return heros[self.m_sel_tab_index]
    end
    
end

function M:sortHeros(ids)
    local function sortFunc(id_one, id_two)
        local hv_1 = self:checkHave(id_one.id) == true and 1 or 0
        local hv_2 = self:checkHave(id_two.id) == true and 1 or 0
        return hv_1 < hv_2
    end
    table.sort(ids, sortFunc)
end

function M:clickHero(data)
    local str_btn = string.sub(data, 1,3)
    if str_btn == "btn" then
        return true
    else
        return false    
    end
end

-- 获取能吃的卡的类型
function M:getCanHeroRoleType()
    local race_list = {}
    local hero_id_list = UserDataManager.hero_data:getHeroRoleCanUpGradeIdList()
    for i, heroId in pairs(hero_id_list) do
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(heroId)
        if not table.indexof(race_list, hero_cfg.race)  then
            -- if hero_cfg.race == 5 or hero_cfg.race == 6 then
            --     race_list[#race_list+1] = 5
            -- else
               
            -- end
            race_list[#race_list+1] = hero_cfg.race
        end
    end
    return race_list
end

--检查是否可以领取威望系统棋子
function M:IsHavePrestigeRed(hero_id)
    if not hero_id  then return false end
    local cur_season = UserDataManager:getCurSeason() -- 当前赛季cur_season
    local open_condition = ConfigManager:getCfgByName("open_condition")
    local prestige = open_condition[383] -- 威望阁
    if cur_season < prestige.season_unlock  then
        return false
    end
    local evo_,_ = UserDataManager.hero_data:getHeroHighEvoByCid(hero_id)
    local data = UserDataManager:getHeroPrestigeData()
    local evo = evo_
    local id = hero_id
    local prestige_piece_hero_free = ConfigManager:getCfgByName("prestige_piece_hero_free")
    local cur_hero_cfg = prestige_piece_hero_free[id]
    if cur_hero_cfg then
        local have = false
        for k,v in ipairs(data) do
            if id == v then
                have = true
                break
            end
        end
        return evo >= cur_hero_cfg.unlock_quality and not have
        --self:setObjectVisible("prestige_root",evo >= cur_hero_cfg.unlock_quality and not have)
    else
        return false
    end
end

--- 网络数据回调，需要复写
function M:netData(data, tag)

end

return M