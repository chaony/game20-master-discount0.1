local M = class("RankRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("rank_rank_quest_info",{sort = self.m_params.id})
end

function M:onEnter()
	self.m_rank_cfg = self.m_params.rank_cfg
	self.m_id = self.m_params.id
	self:initData()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self:initQuestsData()
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	local quest_id = data.quest_id
	if quest_id then
		local quests = self.m_data.quests or {}
		local quest = quests[tostring(quest_id)]
		if quest then
			quest.recv = 1
		end
		self:initQuestsData()
	end
end

function M:initQuestsData()
	self.m_red_point = 0
	-- quests
	local show_data = {}
	local quests = self.m_data.quests or {}
	local quest_rank = ConfigManager:getCfgByName("quest_rank")
	local cur_quest_rank = quest_rank[self.m_id] or {}
	for k,v in pairs(quests) do
		local key = tonumber(k)
		local cfg = cur_quest_rank[key]
		if cfg then
			table.insert(show_data, {id = key, cfg = cfg, data = v})
			local value = v.value or 0 -- 是否完成 0 未完成 1 已完成
			local recv = v.recv or 0  -- 是否领奖 0 未领奖 1 已领奖
			if value == 1 and recv == 0 then
				self.m_red_point = 1
			end
		end
	end
	table.sort(show_data, function(data1, data2)
		if data1.data.recv == data2.data.recv then
			if data1.cfg.target_value == data2.cfg.target_value then
				return data1.id < data2.id
			else
				return data1.cfg.target_value < data2.cfg.target_value
			end
		else
			return data1.data.recv < data2.data.recv
		end

	
	end)
	self.m_quests_data = show_data
end

function M:getQuestsData()
	return self.m_quests_data
end

function M:getQuestsDataCount()
	return #self.m_quests_data
end

function M:getQuestsDataByIndex(index)
    return self.m_quests_data[index]
end

return M
