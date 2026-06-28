local M = class("AchievementOldSeasonPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

--任务状态说明：任务已做完但是奖励没领取，也算完成
--  0，未完成
--  1，可领取，即，已完成
--  已领取的奖励也赋值为1，作为已完成

function M:onEnter()
    self.m_season_id = 0
    self.m_sel_tab_index = 1 --一级页签
    self.m_sel_season = 1
    self.chapter_season_list = {} -- 本赛季有几章
    self.click_more_btn = 0 -- 点击第几章的index
    self.all_cell_size = {}
    self:updateData(self.m_params)
    self:initSelSeason()
end

function M:updateData(data)
    self.m_data = data or {}
    self.main_quests = self.m_data.main_quests or {} -- # 任务列表
    self.m_season_id = self.m_data.season_id or self.m_season_id
    self.old_season_list = self:getSeasonList() -- 有几个老赛季
    self:changeSeasonData(self.m_sel_tab_index)
end

function M:initSelSeason()
    for k, v in pairs(self.old_season_list or {}) do
        self.m_sel_season = v.season
        break
    end
end

-- 切换赛季数据
function M:changeSeasonData(sel_tab_index)
    local seasonInfo = self.old_season_list[sel_tab_index] or {}
    self.cur_quest_season = self:getQuestSeason(seasonInfo.season) -- 选择的赛季章节完成情况
    self.list_data = self:getChapterInfoBySeasonChapterId(seasonInfo.season) -- 初始化右侧任务数据
    self.all_cell_size = {}
    for i, v in pairs(self.list_data) do
        if v.is_child then
            self.all_cell_size[#self.all_cell_size+1] = Vector2(572, 112) -- 任务item的大小
        else
            self.all_cell_size[#self.all_cell_size+1] = Vector2(572, 144) -- 章节item的大小
        end
    end
end

-- 获取当前赛季的成就条目
function M:getSeasonList()
    local seasonList = {} -- 赛季信息
    local cur_season = self.m_season_id  -- 排除当前赛季
    for season, v in pairs(self.main_quests) do
        if _G.next(v) and tonumber(season) ~= cur_season then
            local numStr = GameUtil:numberToChineseString(tonumber(season)) -- 数字转大写
            seasonList[#seasonList+1] = {name = Language:getTextByKey("achievement_text8",numStr), season = season}
        end
    end
    local function sortFun(data1, data2)
        return tonumber(data1.season) > tonumber(data2.season)
    end
    table.sort(seasonList, sortFun)
    return seasonList
end

-- 判断是否解锁和解锁条件
--[[
    return lock_flag, lock_text
--]]
function M:getQuestLockFlag(stage_id)
    return ConfigManager:getQuestLockFlag(stage_id)
end

-- 获取赛季章节详情
function M:getChapterInfoBySeasonChapterId(cur_season, chapterId)
    if not cur_season then return {} end
    local achievement_rewards_cfg = ConfigManager:getCfgByName("achievement_rewards")
    local quest_season = achievement_rewards_cfg[tonumber(cur_season)] or {}
    local chapter_info = {}
    local sel_chapter_info = {}
    for chapter_id, v in pairs(quest_season) do
        v.reward_chapter = chapter_id
        chapter_info[#chapter_info+1] = v
        if chapter_id == tonumber(chapterId) then
            sel_chapter_info = chapter_info[chapterId] or {}
        end
    end
    local function sortFun(data1, data2)
        return tonumber(data1.reward_chapter) < tonumber(data2.reward_chapter)
    end
    table.sort(chapter_info, sortFun)
    return chapter_info, sel_chapter_info
end

-- 判断章节是否完成，即章节奖励是否已领取，领取才算完成
function M:doesChapterComplete(chapterID, seasonID)
    seasonID = seasonID or self.m_sel_season
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

-- 通过章节获取完成数量
function M:getCompleteQuestNum(chapterId)
    local complete_num = 0 -- 当前成就完成数量
    local quest_num = 0 -- 当前章节成就条目数
    local received = self:doesChapterComplete(chapterId) -- 领取状态
    for i, v in pairs(self.cur_quest_season) do
        if v.chapter == tonumber(chapterId) then
            quest_num = quest_num + 1
            if v.status == 1 then
                complete_num = complete_num +1
            end
        end
    end
    return complete_num, quest_num, received
end

-- 获取当前赛季的成就条目
function M:getQuestSeason(season)
    if not season then return {} end
    local questList = {}
    local chapterList = {} -- 章节信息
    local cur_season = season -- 赛季
    local quest_season_cfg = ConfigManager:getCfgByName("quest_season")
    local quest_season = quest_season_cfg[tonumber(cur_season)] or {}
    if self.main_quests[tostring(cur_season)] then
        local sever_quest = {}
        table.merge(sever_quest, self.main_quests[tostring(cur_season)].quests or {})-- 当前任务服务器存储任务状态列表
        for _, v in ipairs(self.main_quests[tostring(cur_season)].quests_completed or {}) do -- 已领取奖励的任务，作为已完成任务
            sever_quest[tostring(v)] = {status = 1, value = 0}
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
                if value > target_value then --为了可领取状态下展示的value不大于target_value
                    value = target_value
                end
                questList[#questList+1] = {cfg = v, cur_progress = value, target_value = target_value, status = status,
                                           stage_id = i, chapter = v.chapter, lock_flag = lock_flag, lock_text = lock_text, is_child = true}
                local numStr = GameUtil:numberToChineseString(v.chapter) -- 数字转大写
                chapterList[v.chapter] = {chapter = v.chapter, name= Language:getTextByKey("achievement_text1",numStr) } -- 存贮章节
            end
        end
        for i, v in pairs(chapterList) do
            self.chapter_season_list[#self.chapter_season_list+1] = v
        end
    end
    return questList
end

-- 点击下拉箭头创建数据 
function M:initClickSeasonChapter(sel_tab_index, chapterId)
    local seasonInfo = self.old_season_list[sel_tab_index] or 0
    local data = self:getChapterInfoBySeasonChapterId(seasonInfo.season)
    local questList = self:getQuestSeason(seasonInfo.season)
    local chapterQuests = {} -- 点击的章节任务
    for i, v in pairs(questList) do
        if v.chapter == tonumber(chapterId) then
            chapterQuests[#chapterQuests+1] = v
        end
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
            return id_one.status < id_two.status
        end
    end
    table.sort(chapterQuests, sortFunc)
    
    local index = 1
    for i, v in ipairs(data) do
        if v.reward_chapter == tonumber(chapterId) then
            index = i
            self.click_more_btn = index
        end
    end
    for i = #chapterQuests, 1, -1 do
        table.insert(data, index+1, chapterQuests[i])
    end
    self.all_cell_size = {}
    for i, v in pairs(data) do
        if v.is_child then
            self.all_cell_size[#self.all_cell_size+1] = Vector2(572, 112) -- 任务item的大小
        else
            self.all_cell_size[#self.all_cell_size+1] = Vector2(572, 144) -- 章节item的大小
        end
    end
    self.list_data = data
end

-- 通过赛季和章节检查往期赛季红点
function M:checkRedPointBySeasonChapter(season)
    local chapters = self:getChapterInfoBySeasonChapterId(season)
    for chapterID, chapterData in ipairs(chapters) do
        local complete_num, quest_num, received = self:getCompleteQuestNum(chapterID)
        if quest_num > 0 and complete_num >= quest_num and received == false and chapterData.time_limit == 1 then
            return true
        elseif received == false then --如果本章的的奖励没领取过，且已经不可领，那后边的章节即使有奖励可领也不展示红点，因为本章节的奖励未领，则不允许领下一章的奖励
            return false
        end
    end
    return false
end

return M
