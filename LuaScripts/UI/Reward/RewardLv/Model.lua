local M = class("RewardLvModel", LikeOO.OODataBase)

local rank = {5,2,10}

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_lv = self.m_params.lv or 3
	self.single_rank = self.m_params.single_rank 
	self.m_lv_data = self:getLvTab(self.m_lv)
end

function M:getCurQuestRank()
	return self.m_lv_data.cur_quest_rank
end

function M:getNextQuestRank()
	return self.m_lv_data.next_quest_rank
end

--解锁需要任务数量
function M:getRequireMents()
	return self.m_lv_data.requirements
end

function M:getCurSingleNum(quest)
	local quest_num = tostring(quest) 
	if self.single_rank[quest_num] then
		return self.single_rank[quest_num]
	end
	return 0
end

function M:getCurTeamNum(quest)
	local quest_num = tostring(quest) 
	--[[if self.team_rank[quest_num] then
		return self.team_rank[quest_num]
	end]]
	return 0
end

function M:getLvTab(lv)
	local bounty_lv = ConfigManager:getCfgByName("bounty_lv")
	return bounty_lv[lv]
end

return M
