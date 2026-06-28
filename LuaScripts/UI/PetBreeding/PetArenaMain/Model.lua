---@class PetArenaMainModel: OODataBase
local M = class("PetArenaMainModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("pet_arena_index")
end

function M:onEnter()
    self.m_data = self.m_data or {}
    self:initData(self.m_data)
    self.m_reward_cfg = nil
    self.m_feed_pet_ids = {}
    self.m_season_refresh = false
    self.m_jump_battle = UserDataManager.local_data:getUserDataByKey("PetJumpBattle", false)
end

function M:initData(data)
    self.m_score = data.score
    self.m_week_times = data.week_times
    self.m_week_recv = data.week_recv
    self.m_end_time = data.pet_pvp_season_data.end_time
    self.m_cur_season = data.pet_pvp_season_data.season
    self.m_is_can_match = not data.no_enter
end

function M:getShowCfgList()
    local pet_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    local cfg_list = {}
    for i = 1, 3 do
        local data, cfg = UserDataManager.pet_data:getPetDataById(pet_ids[i])
        if cfg then
            table.insert(cfg_list, cfg)
        else
            table.insert(cfg_list, {})
        end
    end
    return cfg_list
end

function M:getMoonList()
    local pet_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    local mood_cfg = ConfigManager:getCfgByName("mood_random")
    self.moon_list = {}
    for i = 1, 3 do
        local data, cfg = UserDataManager.pet_data:getPetDataById(pet_ids[i])
        if data then
            if data.mood then
                table.insert(self.moon_list, mood_cfg[data.mood])
            else
                Logger.logError("该宠物没有mood字段！, id is" .. pet_ids[i])
                table.insert(self.moon_list, { })
            end
        else
            table.insert(self.moon_list, { })
        end
    end
    return self.moon_list
end

function M:getMoonCfgByIndex(index)
    local cur_mood_cfg = {}
    if self.moon_list[index] then
        cur_mood_cfg = self.moon_list[index]
    end
    return cur_mood_cfg
end

function M:getRemainingTime()
    local end_time = self.m_end_time
    return end_time - UserDataManager:getServerTime()
end

function M:getScore()
    return self.m_score
end

function M:setScore(score)
    self.m_score = score
end

function M:getWeekTimes()
    return self.m_week_times
end

function M:setWeekTimes(times)
    self.m_week_times = times
end

function M:getAddPetCfg()
    local add_cfg = ConfigManager:getCfgByName("pet_arena_buff")
    if add_cfg[self.m_cur_season] then
        return add_cfg[self.m_cur_season]
    else
        Logger.logError("pet_arena_buff表没有赛季" .. self.m_cur_season .. "的数据")
        return nil
    end

end

function M:getAwardList()
    if not self.m_reward_cfg then
        self.m_reward_cfg = ConfigManager:getCfgByName("pet_arena_reward")
    end
    return self.m_reward_cfg
end

function M:getAwardCfgByIndex(index)
    if not self.m_reward_cfg then
        self.m_reward_cfg = ConfigManager:getCfgByName("pet_arena_reward")
    end
    return self.m_reward_cfg[index]
end

function M:checkReceivedList(index)
    if table.indexof(self.m_week_recv, index) then
        return true
    end
    return false
end

function M:updateRewardState(recvList)
    self.m_week_recv = recvList
end

function M:setJumpState()
    if self.m_jump_battle then
        self.m_jump_battle = false
    else
        self.m_jump_battle = true
    end
end

function M:getJumpState()
    return self.m_jump_battle
end

function M:getQualityImgByIndex(index)
    local pet_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    local data = UserDataManager.pet_data:getPetDataById(pet_ids[index])
    local quality = 1
    if data then
        quality = GameUtil:getPetQualityByData(data)
        if quality == 1 then
            return "a_cw_djg_pinzhi_zi"
        elseif quality == 2 then
            return "a_cw_djg_pinzhi_huang"
        elseif quality == 3 then
            return "a_cw_djg_pinzhi_hong"
        elseif quality == 4 then
            return "a_cw_djg_pinzhi_bai"
        elseif quality == 5 then
            return "a_cw_djg_pinzhi_cai"
        end
    end
    return "a_cw_djg_pinzhi_putong"
end

function M:setSeasonState(state)
    self.m_season_refresh = state
end

function M:getSeasonState()
    return self.m_season_refresh
end

function M:destroy()
    self.m_week_recv = nil
    self.m_reward_cfg = nil
    self.m_moon_list = nil
    UserDataManager.local_data:setUserDataByKey("PetJumpBattle", self.m_jump_battle)
    M.super.destroy(self)
end

return M