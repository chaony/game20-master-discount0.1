---@class AchievementModel:OODataBase
local M = class("AchievementModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("quest_season_index")
end

--任务状态说明：任务已做完但是奖励没领取，不算完成
--  0，未完成
--  1，可领取，即，未完成
--  -2，已领取，即，已完成

function M:onEnter()
    self.m_data = self.m_data
    self.main_quests = self.m_data.main_quests or {} -- # 任务列表
    self.m_season_id = self.m_data.season_id -- 赛季
    self.remainingDays = self.m_data.days -- # 当前赛季剩余天数
    self.m_sel_tab_index = 1 --一级页签
    self.m_quest_data = {} --self.m_quest_data[seasonID][chapterID][questID]
    self.chapter_season_list = {} -- 本赛季有几章
    self:updateMainSeasonQuest(self.main_quests)
    self.buff_open = false
    self.buff_open = false
end

function M:getCurAttrModeBySeason()
    local mode = 24
    local open_season = ConfigManager:getCommonValueById(608,1)
    local cur_season = UserDataManager:getCurSeason()
    if cur_season >= open_season then
        mode = 25
    end
    return mode
end

-- 更新任务列表数据
function M:updateMainSeasonQuest(data)
    self.main_quests = data or {}

    self.m_quest_data = {}
    for season in pairs(self.main_quests) do
        local quest_season_cfg = ConfigManager:getCfgByName("quest_season")
        local quest_season = quest_season_cfg[tonumber(season)] or {}
        if self.main_quests[tostring(season)] then
            local sever_quest = {}
            table.merge(sever_quest, self.main_quests[tostring(season)].quests or {})-- 当前任务服务器存储任务状态列表
            for _, v in ipairs(self.main_quests[tostring(season)].quests_completed or {}) do -- 当前任务服务器存储已完成任务状态列表
                sever_quest[tostring(v)] = {status = -2, value = 0}
            end
            for i, v in pairs(quest_season) do -- 未完成的章节
                v.id = i
                if sever_quest[tostring(v.id)] then
                    local value = sever_quest[tostring(v.id)].value
                    local status = sever_quest[tostring(v.id)].status
                    local lock_flag, lock_text = self:getQuestLockFlag(tonumber(v.stage_id))
                    local target_value = v.target_value
                    if v.target_type == 1 then --关卡类型特殊处理，关卡类型的value和target_value都是关卡的id，为了展示效果作此处理
                        if value >= target_value then
                            value = 1
                        else
                            value = 0
                        end
                        target_value = 1
                    end
                    if status == 1 then
                        if v.money_count == 0 then --无积分就不需要领取，直接展示完成即可
                            status = -2
                        end
                        --征战四方特殊处理
                        if v.target_type == 333 then
                            value = target_value
                        end
                    elseif status == -2 then --已完成的任务
                        value = target_value
                    end
                    if value > target_value then --为了可领取状态下展示的value不大于target_value
                        value = target_value
                    end
                    if self.m_quest_data[tonumber(season)] == nil then
                        self.m_quest_data[tonumber(season)] = {}
                    end
                    if self.m_quest_data[tonumber(season)][tonumber(v.chapter)] == nil then
                        self.m_quest_data[tonumber(season)][tonumber(v.chapter)] = {}
                    end
                    self.m_quest_data[tonumber(season)][tonumber(v.chapter)][tonumber(v.id)] = {cfg = v, cur_progress = value, target_value = target_value, status = status,
                                                                  stage_id = i, chapter = v.chapter, lock_flag = lock_flag, lock_text = lock_text}
                end
            end
        end
    end
    
    self.chapter_season_list = {}
    for chapter in pairs(self.m_quest_data[self.m_season_id] or {}) do
        local numStr = GameUtil:numberToChineseString(chapter) -- 数字转大写
        self.chapter_season_list[#self.chapter_season_list+1] = {chapter = chapter, name= Language:getTextByKey("achievement_text1",numStr) } -- 存贮章节
    end

    self.m_rank_info = {}
    if self.main_quests[tostring(self.m_season_id)] then
        self.m_rank_info = self.main_quests[tostring(self.m_season_id)].ranks or {}
    end
    
end

function M:getQuestData(chapterID, seasonID)
    seasonID = seasonID or self.m_season_id
    if self.m_quest_data[seasonID] then
        return self.m_quest_data[seasonID][chapterID] or {}
    end
    return {}
end

-- 判断章节是否完成，即章节奖励是否已领取，领取才算完成
function M:doesChapterComplete(chapterID, seasonID)
    seasonID = seasonID or self.m_season_id
    local main_quest_data = {}
    if self.main_quests[tostring(seasonID)] then
        main_quest_data = self.main_quests[tostring(seasonID)].chapters_completed or {}
    end
    for _, v in pairs(main_quest_data) do
        if chapterID == v then
            return true
        end
    end
    return false
end

-- 通过章节获取当前赛季的成就条目
function M:getQuestSeasonByChapter(chapterId)
    local quest_season = {}
    for i, v in pairs(self:getQuestData(chapterId)) do
        quest_season[#quest_season+1] = v
    end
    
    local function sortFunc(id_one, id_two)
        local open_flag_1 = id_one.lock_flag == true and 1 or 0 -- 是否解锁
        local open_flag_2 = id_two.lock_flag == true and 1 or 0 -- 是否解锁
        if id_one.status == id_two.status then
            if open_flag_1 == open_flag_2 then
                if id_one.cfg.money_count == id_two.cfg.money_count then
                    return id_one.stage_id < id_one.stage_id
                else
                    return id_one.cfg.money_count > id_two.cfg.money_count
                end
            else
                return open_flag_1 < open_flag_2
            end
        else
            return id_one.status > id_two.status
        end
    end
    table.sort(quest_season, sortFunc)
    return quest_season
end

-- 通过章节获取完成数量
function M:getCompleteQuestNum(chapterId, quest_list)
    local complete_num = 0 -- 当前成就完成数量
    local quest_num = 0 -- 当前章节成就条目数
    local received = self:doesChapterComplete(chapterId) -- 章节奖励领取状态
    if not quest_list then
        quest_list = self:getQuestData(chapterId)
    end
    for i, v in pairs(quest_list) do
        if v.chapter == tonumber(chapterId) then
            quest_num = quest_num + 1
            if v.status == -2 then --状态2，已领取，即已完成，见任务状态说明
                complete_num = complete_num +1
            end
        end
    end
    return complete_num, quest_num, received
end

function M:doesChapterHadRewardToGet(chapterID, seasonID)
    seasonID = seasonID or self.m_season_id
    local all_quest_complete_flag = true
    local quest_list = self:getQuestData(chapterID, seasonID)
    for _, v in pairs(quest_list) do
        if v.status == 1 then --状态1，可领取，见任务状态说明
            return 1 --任务奖励可领取
        elseif v.status ~= -2 then --不是可领取状态，又不是已领取状态，那就是没完成
            all_quest_complete_flag = false
        end
    end
    if all_quest_complete_flag == true and self:doesChapterComplete(chapterID, seasonID) == false then --章节任务都完成了，但章节奖励还没领
        return 2 --章节奖励可领取
    end
    return 0 --没有奖励可领取
end

-- 判断是否解锁和解锁条件
--[[
    return lock_flag, lock_text
--]]
function M:getQuestLockFlag(stage_id)
    return ConfigManager:getQuestLockFlag(stage_id)
end

-- 获取章节详情
function M:getChapterInfoByChapterId(chapterId, seasonID)
    local cur_season = seasonID or self.m_season_id --UserDataManager:getCurSeason() -- 当前赛季
    local achievement_rewards_cfg = ConfigManager:getCfgByName("achievement_rewards")
    local quest_season = achievement_rewards_cfg[cur_season] or {}
    local chapter_info = {}
    for chapter_id, v in pairs(quest_season) do
        chapter_info[chapter_id] = v
    end
    return chapter_info[chapterId]
end

-- 检查上一章节是否完成当前章节是否解锁
function M:checkChapterLockState( index )
    local receivedChapter = {}
    local flag = false -- 章节解锁
    for i, v in pairs(self.chapter_season_list) do
        local complete_num, quest_num, received = self:getCompleteQuestNum(v.chapter)
        if complete_num >= quest_num and received then
            receivedChapter[#receivedChapter+1] = v.chapter
        end
    end
    if not index then
        index = self.m_sel_tab_index
    end
    local chapter_season_info = self.chapter_season_list[index] or {}
    local chapterInfo = self:getChapterInfoByChapterId(chapter_season_info.chapter)
    local pre_reward_chapter = 0
    if chapterInfo then
        pre_reward_chapter = chapterInfo.pre_reward_chapter
    end
    if pre_reward_chapter == 0 then
        flag = true
    elseif table.indexof(receivedChapter, pre_reward_chapter) then
        flag = true
    end
    return flag
end

-- 获取所有赛季的成就条目
function M:checkAllCompleteSeason()
    local completeList = {}
    for i, v in pairs(self.main_quests) do
        if tostring(i)~=tostring(self.m_season_id) then
            completeList[tonumber(i)] = self:checkAllCompleteChapter(i)
        end
    end
    return completeList
end

-- 过往赛季是否有可领取的奖励
function M:doesOldSeasonHadRewardToGet()
    local all_quest_complete_flag = false
    for seasonID, seasonData in pairs(self.m_quest_data) do
        if seasonID < self.m_season_id then
            for chapterID, chapterData in pairs(seasonData) do
                local chapterDetail = self:getChapterInfoByChapterId(chapterID, seasonID)
                if self:doesChapterComplete(chapterID, seasonID) == false and chapterDetail and chapterDetail.time_limit == 1 then
                    all_quest_complete_flag = true
                    for questID, questData in pairs(chapterData) do
                        if questData.status == 0 then
                            all_quest_complete_flag = false
                            break
                        end
                    end
                    if all_quest_complete_flag == true then
                        return true
                    else
                        return false    --本章的奖励未领取过：都完成了则可以领，展示红点；若没全部完成则后边的章节不用判断了，不展示红点，因为本章节的奖励未领，则不允许领下一章的奖励
                    end
                end
            end
        end
    end
    return false
end

--赛季buff是否开启
function M:checkSeasonBuffOpen()
    return BtnOpenUtil:isBtnOpen(336)
end


function M:getSeasonNotice()
    local season_notice_tab = ConfigManager:getCfgByName("season_notice")
    local season = UserDataManager:getCurSeason()
    local sea_notice = season_notice_tab[season]
    if sea_notice and next(sea_notice) then
        return sea_notice
    end
end


return M
