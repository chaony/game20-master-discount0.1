local M = class("CompareSwordFightReportPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "load_rank" then
		self:loadRank()
	elseif msg == "switchNode" then
		local groupId = data.groupId or 0
		local round = data.round or 0
		local day_idx = data.day_idx or 0
		
		self:switchNode(groupId , round ,day_idx)
		
	elseif msg == "click_type_btn" then
		if self.m_model.open_type == 3 then --晋级赛  全部战报
			local function receivetCallback(response)
				--RewardUtil:rewardTipsByData(response.reward)
				self.m_model:updateData(response)
				self.m_view:refreshUI()
			end
			local params = {}
			params.typ = self.m_model.typ 
			params.round_stage = data
			self.m_model:getNetData("full_service_top_battle_log", params, receivetCallback)
		elseif self.m_model.open_type == 4 then
			local function receivetCallback(response)
				--RewardUtil:rewardTipsByData(response.reward)
				self.m_model:updateData(response)
				self.m_view:refreshUI()
			end
			local params = {}
			params.typ = self.m_model.typ
			params.round_stage = data
			params.uid = self.m_model.uid
			self.m_model:getNetData("full_service_top_personal_battle_log", params, receivetCallback)
		else
			local function receivetCallback(response)
				local aa = 1
				--RewardUtil:rewardTipsByData(response.reward)
				self.m_model:updateData(response)
				self.m_view:refreshUI()
			end
			local params = {}
			params.uid = self.m_model.uid
			local cfg = ConfigManager:getCfgByName("full_service_phase")
			local day = cfg[self.m_model.version][4].start_day or 8
			params.active_day = data + (day -1)
			self.m_model:getNetData("full_service_point_race_user_battle_log", params, receivetCallback)
		end
	elseif msg == "btn_fightData" then
		self:requestVideo(data.battle_log_id)
	elseif msg == "btn_dropDown" then 
		self.m_view.dD_open = not self.m_view.dD_open
		self.m_view:refreshDropDown()
	end
end

function M:switchNode(group , round  , sel_day_idx) --天数是活动开始的总时间
	if group == self.m_model.sel_group and round == self.m_model.sel_round and sel_day_idx - 1 + self.m_model.point_race_start_day == self.m_model.sel_day then
		return
	end
	if group == self.m_model.sel_group then	--没有切换组

		self.m_model.sel_round = round
	else
		--切换为其他组 默认为第一回合
		self.m_model.sel_round = 1
	end
	self.m_model.sel_group = group
	self.m_model.sel_day = self.m_model.point_race_start_day + sel_day_idx - 1
	self.m_view:updateTabScroll()
	self.m_model.rank_data[self.m_model.open_type] = {}
	self:requestRankData()
end

function M:requestRankData()
	local function netCallback(response)
		if response and self.m_model then
			self.m_model:updateData(response)
			self.m_view:refreshUI()
		end
	end
	local params = { typ = self.m_model.typ,
					 active_day = self.m_model.sel_day,
					 group_id = self.m_model.sel_group - 1,
					 rounds = self.m_model.sel_round - 1,
					 start = 0, stop = 10 }
	self.m_model:getNetData("full_service_point_race_battle_log", params, netCallback, nil, nil, nil)
end

function M:loadRank()
	local cur_num, total_num = self.m_model:getRankNums()
	if cur_num >= 1000 or cur_num >= total_num then
		return
	end
	self.m_view:lockTouch()
	local function netCallback(response)
		self.m_view:unlockTouch()
		self.m_model:updateData(response)
		self.m_load_end = true
		self.m_view:refreshUI()
	end
	local netUrl = ""
	if self.m_model.open_type == 1 then
		netUrl = "full_service_point_race_battle_log"
	end
	local start_pos , end_pos = self.m_model:getLoadIndex()
	self.m_model:getNetData(netUrl, {typ = self.m_model.typ,
									 active_day = self.m_model.sel_day,
									 group_id = self.m_model.sel_group - 1,
									 rounds = self.m_model.sel_round - 1,
									 start = start_pos,
									 stop = end_pos,
									 --start = cur_num + 1, 
									 --stop = cur_num + 10,
	}, netCallback, true, true)
end

function M:requestVideo(id)
	--self:openView("Pops.BattleStatistics", {battle_id = id, mode = GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE})
	if self.m_model.open_type == 2 or self.m_model.open_type == 1 then
		self:openView("CompareSwordWithWorld.CompareSwordBattleDetail", {battle_id = id, mode = GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE})
	else
		self:openView("CompareSwordWithWorld.CompareSwordBattleDetail", {battle_id = id, mode = GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION})
	end
end
function M:destroy()

	M.super.destroy(self)
end


return M