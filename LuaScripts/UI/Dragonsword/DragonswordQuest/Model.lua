local M = class("DragonswordQuestModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_quests = self.m_params.quests  --任务状态
    self.m_version = self.m_params.version  --版本号
    self.m_start_time = self.m_params.start_time --开始时间
    self.current_open_day = self.m_params.current_day or 0 --活动开始第几天
end

--更新奖励领取数据
function M:updateServerData(serverData)
	if serverData and serverData["end"] then
        UserDataManager.active_121_end = true
    end
    table.merge(self.m_quests, serverData.quests)
end

--计算今天是活动开始的第几天
function M:getTodayIsOpenDay()
    local cur_tim = UserDataManager:getServerTime() --当前时间
    local surplus_time = cur_tim - self.m_start_time --从活动开始到当前时间的差值
    local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
    return remain_day + 1
end


--获取数据
function M:getCfgData()
    local show_data = {}
    local dragonsword_quest = ConfigManager:getCfgByName("dragonsword_quest")
    for k, v in pairs(dragonsword_quest[self.m_version]) do
        if v.day == self.current_open_day then
            local quest_status_table = self:getQuestStatus(k)
            local quest_status = quest_status_table.status
            if quest_status == 1 then   -- -1可领取，0未完成，2已领取
                quest_status = -1
            end
            table.insert(show_data, {id = k,cfg = v,quest_value = quest_status_table.value or 0,quest_status = quest_status})
        end
    end
    --数据重新排列
    table.sort(
        show_data,
        function(data1, data2)
            if data1.quest_status == data2.quest_status then
                return data1.id < data2.id
            else
                return data1.quest_status < data2.quest_status
            end
        end
    )
    return show_data
end

--获取任务状态
function M:getQuestStatus(quest_id)
    for i, v in pairs(self.m_quests) do
        if i == tostring(quest_id) then
            return v
        end
    end
    return {}
end

return M
