local M = class("DragonswordMeltingModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end


function M:onEnter()
	self.m_version = self.m_params.version  --版本号
	self.m_open_data = self.m_params.open_data --open_condition表数据
	self.m_active_data = self.m_params.active_data --活动开启表
	self.m_score = self.m_params.score --累计积分
	self.m_score_done = self.m_params.score_done -- 累计积分领取的奖励
	self.m_quests = self.m_params.quests --任务状态
	self.m_open_flag = self.m_params.open_flag --活动是否在展示期
	self.current_open_day = self.m_params.current_day or 0 --活动开始第几天
end

--更新数据
function M:updateServer(response)
	self.m_score = response.score or self.m_score
	self.m_score_done = response.score_done or self.m_score_done
end

--更新任务状态
function M:updateQuests(response)
	self.m_quests = response.quests
end

--获取里程碑奖励
function M:getMilepostData()
	local dragonsword_milepost = ConfigManager:getCfgByName("dragonsword_milepost")
	return dragonsword_milepost[self.m_version] or {}
end

--获取是否领取了积分奖励
function M:getIsReceiveMilepost(score_id)
	for i, v in pairs(self.m_score_done) do
		if v == score_id then
			return true
		end
	end
	return false
end

--获取里程奖励积分
function M:getScoreNum(score_id)
	local milepost_data = self:getMilepostData()
	return milepost_data[score_id].score or 0
end

--时间转换  从具体年月日转换为时间戳
function M:stringTimeByNumberTime(time_string)
	local _, _, y, moth, d, h, mi, s = string.find(time_string, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
	return os.time({year = y, month = moth, day = d, hour = h, min = mi, sec = s})
end

--是否在活动展示期
function M:IsOpenQuest()
	local open_flag = true
	local end_time = GameUtil:stringToTimesTamp(self.m_active_data.end_time)
	local start_time = GameUtil:stringToTimesTamp(self.m_active_data.start_time)
	if end_time < UserDataManager:getServerTime() or start_time > UserDataManager:getServerTime() then
		open_flag = false
	end
	return open_flag
end

--是否有任务红点
function M:isHasQuestRed()
	for i, v in pairs(self.m_quests) do
		if v.status == 1 then
			return true
		end
	end
	return false
end

return M
