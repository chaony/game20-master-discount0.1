local M = class("FiveLineTaskMainChapterNewModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
	--self.m_transfer = "scale"
end

function M:onEnter()
	self.m_data = self.m_data or {}
	self.m_data.received = self.m_params.received
	self.reward_data = self.m_params.reward_data
	self.svn = self.m_params.svn
	self:initData()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self:setStatus()
	self:initMainQuestsData()
	self:arrayAgain(self.reward_data)
end

function M:initMainQuestsData()
	self.is_has_drop = false
	self.m_show_point_cfg = { name = Language:getTextByKey("four_tower_str_0016",self.reward_data[#self.reward_data].cfg.num),drop = {self.reward_data[#self.reward_data].cfg.rewards[#self.reward_data[#self.reward_data].cfg.rewards]} }
	local show_point = {}
	for i, v in ipairs(self.reward_data) do
		if v.status == 0 then
			table.insert(show_point,{name = Language:getTextByKey("four_tower_str_0016",v.cfg.num),drop = {v.cfg.rewards[#v.cfg.rewards]}})
			if #show_point > 0 then
				self.is_has_drop = true
				self.m_show_point_cfg = show_point[1]
			end
			break
		end
	end
	local data_info = self.reward_data[#self.reward_data]
	table.insert(show_point,{name = Language:getTextByKey("four_tower_str_0005",data_info.cfg.num),drop = {data_info.cfg.rewards[#data_info.cfg.rewards]}})
end

--重新排列
function M:arrayAgain(show_data)
	--数据重新排列
	table.sort(
			show_data,
			function(data1, data2)
				if data1.status == data2.status then
					return data1.id < data2.id
				else
					return data1.status > data2.status
				end
			end
	)
end

--设置奖励状态
function M:setStatus()
	for i, v in ipairs(self.reward_data) do
		local is_receive = self:rewardIsReceive(v.id)
		local is_flood = self.m_params.win_times
		if is_receive then --已领取
			v.status = -1
		elseif is_flood >= v.cfg.num and not is_receive then --可领取
			v.status = 2
		else
			v.status = 0
		end
	end
end

--是否已领取奖励
function M:rewardIsReceive(id)
	if self.m_data.received ~= nil then
		for i, v in ipairs(self.m_data.received) do
			if v == id then
				return true
			end
		end
	end
	return false
end

function M:getMainQuestsData()
	return self.reward_data or {}
end

function M:getShowPointCfg()
	return self.m_show_point_cfg
end

function M:getQuestLockFlag(stage_id)
	return ConfigManager:getQuestLockFlag(stage_id)
end

return M
