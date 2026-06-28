local M = class("RewardSpecialModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_select_index = 1
	self.m_unlock_ids = self.m_params.unlock_num or {} --解锁的任务
	self.m_bounty_ids = self.m_params.single_his_done or {} --历史完成悬赏
	self.m_task_ids = self.m_params.task_done or {} --历史完成的江湖任务
	self.m_bounty_lv = self.m_params.level or 1
	self.single_quest = self.m_params.single_quest or {} --悬赏任务
end

function M:getLockList()
	local new_tab = {}
	for k,v in pairs(self.m_unlock_ids) do
		table.insert(new_tab, k)
	end
	return new_tab
end

function M:getLockData(id)
	return self.m_unlock_ids[tostring(id)]
end

function M:getTaskNums(id)
	local table_cfg =  self:getLeftTab()
	local cfg = table_cfg[self.m_bounty_lv][id]
	if cfg == nil then
		cfg = table_cfg[id]
	end
	local num = 0
	for k,v in pairs(cfg.level) do
		for kk,vv in pairs(v) do
			if vv ~= 0 then
				num = num + 1
			end
		end
	end
	return num
end

function M:getLeftTab()
	local table_cfg =  ConfigManager:getCfgByName("bounty_unlock")
	return table_cfg
end

function M:getCurTabCfg()
	local table_cfg =  self:getLeftTab()
	if table_cfg[self.m_bounty_lv][self.m_select_index] == nil then
		return table_cfg[self.m_select_index]["level"]
	end
	return table_cfg[self.m_bounty_lv][self.m_select_index]["level"]
end

function M:checkFinalReward(id)
	local table_cfg =  self:getLeftTab()
	local final_tab = table_cfg[self.m_bounty_lv][self.m_select_index]
	
	if final_tab == nil then
		final_tab = table_cfg[self.m_select_index]
	end
	local tab = final_tab["final_reward"]
	for k,v in pairs(tab) do
		if id == v then
			return true
		end
	end
	return false
end

function M:getBountyCfg(id)
	local table_cfg =  ConfigManager:getCfgByName("bounty_quest")
	return table_cfg[id]
end

function M:getLastPos(id, index)
	local list = self:getCurTabCfg()
	local cur_cfg = self:getBountyCfg(id)
	local pos_list = {}
	for k,v in pairs(cur_cfg.bounty_id) do
		local lv_list = list[index-1]
		local pos = self:getPosSub(lv_list, v)
		if pos ~= -1 then
			table.insert( pos_list, pos)
		end
	end
	return pos_list
end

function M:getPosSub(lv_list, bounty_id)
	for k,v in pairs(lv_list) do
		if bounty_id == v then
			return k
		end
	end
	return -1
end

function M:getIndexed(id, index)
	local list = self:getCurTabCfg()
	for i = index + 1, table.nums(list) do
		local cur_list = list[i]
		for k = 1 ,table.nums(cur_list) do
			local c_id = cur_list[k]
			if c_id ~= 0 then
				local cur_cfg = self:getBountyCfg(c_id)
				for kk,vv in pairs(cur_cfg.bounty_id) do
					if id == vv then
						return true
					end
				end 
				
			end
		end
	end
	return false
end

--检测前置任务是否解锁
function M:bountyActivate(id)
	local cfg = self:getBountyCfg(id)
	local stage_id = UserDataManager:getCurStage()
	if stage_id < cfg.stage_id then
		return false
	end
	if cfg.quest_id and next(cfg.quest_id) ~=nil and self:checkTask(cfg.quest_id) == false then
		return false
	end
	if cfg.bounty_id and next(cfg.bounty_id) ~=nil then
		for k,v in pairs(cfg.bounty_id) do
			if self:checkBounty(cfg.bounty_id[k]) == false then
				return false
			end
		end
	end
	for k,v in pairs(cfg.lv_id) do
		if  v > self.m_bounty_lv then
			return false
		end
	end
	-- if cfg.lv_id and cfg.lv_id[1] > self.m_bounty_lv then
	-- 	return false
	-- end
	return true
end



function M:getAllLockConditions(id)
	local new_tab = {}
	local cfg = self:getBountyCfg(id)
	if cfg.stage_id and cfg.stage_id ~= 0 then
		local stage_id = UserDataManager:getCurStage()
		table.insert(new_tab,{des =Language:getTextByKey(cfg.unlock_des[1][1]), bl = stage_id >= cfg.stage_id })
	end
	if cfg.quest_id and next(cfg.quest_id) ~=nil then
		table.insert(new_tab,{des =Language:getTextByKey(cfg.unlock_des[2]), bl = self:checkTask(cfg.quest_id) })
	end
	if cfg.bounty_id and next(cfg.bounty_id) ~=nil then
		for i,v in ipairs(cfg.bounty_id) do
			table.insert(new_tab,{des =Language:getTextByKey(cfg.unlock_des[3][i]), bl = self:checkBounty(cfg.bounty_id[i]) })
		end
	end
	for k,v in pairs(cfg.lv_id) do
		if  v ~= 0  then
			if #cfg.unlock_des[4] >0 then
				table.insert(new_tab,{des =Language:getTextByKey(cfg.unlock_des[4]), bl = self.m_bounty_lv >= v })
			end
			
		end
	end

	-- if cfg.lv_id and cfg.lv_id[1] ~= 0 then
	-- 	table.insert(new_tab,{des =Language:getTextByKey(cfg.unlock_des[4]), bl = self.m_bounty_lv >= cfg.lv_id })
	-- end
	return new_tab
end

function M:checkBottonActivate(id, index)
	local list = self:getCurTabCfg()
	if index < table.nums(list) then
		local cur_list = list[index+1]
		for k,v in pairs(cur_list) do
			local c_id = cur_list[k]
			if c_id ~= 0 then
				local bl = self:bountyActivate(c_id)
				if bl == true then
				 	return true
				end
			end
		end
	end
	return false
end

function M:checkTask(id)
	for k,v in pairs(self.m_task_ids) do
		if id == v then
			return true
		end
	end	
	return false
end

function M:checkBounty(id)
	for k,v in pairs(self.m_bounty_ids) do
		if id == v then
			return true
		end
	end	
	return false
end

function M:checkQuest(id)
	for k,v in pairs(self.single_quest) do
		if id == tonumber(k) and (v.quest_status == 1 or v.quest_status == 2) then --id 一致 且在派遣中
			return true
		end
	end	
	return self:checkBounty(id)
	
end

return M
