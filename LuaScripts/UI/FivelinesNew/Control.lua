local M = class("FivelinesNewControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_guide_file_name = "UI.FivelinesNew.Guide"
	self:updateTime()
	self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(41, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
		self:closeView()
	elseif msg == "guide_btn" then --快速导航
		self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 83})
	elseif msg == "guardinfo" then --英雄层
		local cell_data_temp = {}
		if self.m_model.m_data and self.m_model.m_data.events and data then
			cell_data_temp = self.m_model.m_data.events[tostring(data.index)]
		end
		if data then
			cell_data_temp.hero_data = data.cell_data
			cell_data_temp.battle_or_rolling = self.m_model:battleOrRolling(data.index)
		end
		self:openView("FivelinesNew.FiveLinesDeffDetailNew", {index = data.index, cell_data = cell_data_temp,enemyCombat = self.m_model:getEnemyCombat(data.index),m_battle = self.m_model:getQuickPass(data.index)})
	elseif msg == "box" then --宝箱
		local cell_data_temp = {}
		if self.m_model.m_data then
			if self.m_model.m_data.events and data then
				cell_data_temp = self.m_model.m_data.events[tostring(data.index)]
			end
			cell_data_temp.vsn = self.m_model.m_data.vsn
		end
		if data then
			cell_data_temp.bao_xiang_icon = data.cell_data.show_pic
		end
		if data and data.cell_data and data.cell_data.type ~= 4 and self.m_model:getIsStatue(data.index) == 0  then
			self:openView("FivelinesNew.FiveLinesGreatRewardNew", {index = data.index, cell_data = cell_data_temp})
		end
	elseif msg == "relic_formation_btn" then --查看遗物奖励
		self:openView("MazeStage.MazeStageRelicFormationShow", {data = self.m_model.m_data,tips_text = "four_tower_str_0015",common_title_text = "four_tower_str_0014", team_key = "four_tower"})
	elseif msg == "heirloom_di" then --遗物
		local data_info = {cfg = self.m_model:getHeirloom(data.index)}
		self:openView("MazeStage.MazeStageRelicLook", {data = data_info})
	elseif msg == "reward_open_btn" then  --领取奖励
		self:battleOrOpen(data)
	elseif msg == "next_btn" then --下一关
		self:nextFlood()
	elseif msg == "battle_end_refresh_ui" then --战斗结束
		self:handleBattleResult(data)
	elseif msg == "quest_special_btn" then --里程奖励
		local reward_data = self.m_model:getTowerRewardWeek()
		self:openView("FivelinesNew.FiveLineTaskMainChapterNew",{svn = self.m_model.m_data.vsn,reward_data = reward_data,win_times = self.m_model.m_data.win_times,received = self.m_model.m_data.received})
	elseif msg == "help_btn" then
		self:openHelpPop()
	elseif msg == "quest_reward" then --领取里程奖励
		self:questRecvSpecial(data)
	end
end

--  特殊任务领奖  quest_type: 任务类型  quest_id: 任务id
function M:questRecvSpecial(data)
	local function netCallback(response)
		if self.m_view then
			self.m_model:updateServerData(response)
			self:refreshData(response)
		end
		RewardUtil:rewardTipsByData(response.reward)
	end
	local params = {quest_id = data.cell_data.id, vsn = self.m_model.m_data.vsn}
	self.m_model:getNetData("four_tower_receive_ques", params, netCallback)
end

--刷新数据
function M:refreshData(response)
	self.m_model:updateServerData(response)
	self.m_view:refreshUI()
end

--刷新数据，带云雾效果
function M:refreshDataWithCloudEffect(response)
	self:refreshDataWithCloudEffectCore(response)
	self.m_view:maskOn(1.6)
end

function M:refreshDataWithCloudEffectCore(response)
	self.m_view:showCloud()
	--0.7秒后数据和UI
	local function callback1()
		self:refreshData(response)
	end
	self:setOnceTimer(0.7, callback1)
	--1.5秒后标题闪光
	local function callback2()
		self.m_view:showEffectTX()
	end
	self:setOnceTimer(1.5, callback2)
end

--刷新数据，带飞遗物效果和云雾效果
function M:refreshDataWithHairloomFlyAndCloudEffect(response, current_battle_cell_index)
	if current_battle_cell_index then
		self.m_view:flyHeirloom(current_battle_cell_index)
		local function callback()
			self:refreshDataWithCloudEffectCore(response)
		end
		self:setOnceTimer(1.2, callback)
		self.m_view:maskOn(2.9)
	end
end

--战斗或开始奖励
function M:battleOrOpen(data)
	local type = data.cell_data.type
	local is_remain_time = self.m_model:getRemainTimes() > 0 --有次数可领取
	if self.m_model:getRemainTimes() > 0 then --有次数可领取
		local is_restart = data.is_restart
		--local battle = self.m_model:battleOrRolling(data.index)
		local battle = self.m_model:getQuickPass(data.index)
		if type == 1 or type == 2 or type == 3 then
			self.m_model.is_battle = true
			if is_restart or battle ~= 1 then
				self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.FOUR_TOWER, def_data = self.m_model.m_data.events[tostring(data.index)], assist_heros = self.m_model.m_data.assist_heros, five_pos = data.index, heirlooms = self.m_model.m_data.heirlooms ,version = self.m_model.m_data.vsn})
			else --碾压
				self:autoBattle(data.index)
			end
		elseif type == 4 then --遗物
			self:receiveHeirloom(data.index)
		elseif type == 5 or type == 6 or type == 7 then --宝箱
			local is_nextflood = self.m_model:IsNextFlood()
			local is_extraTime = self.m_model:getExtraTime() > self.m_model.m_data.buy_box_times
			self:buyBox(data)
		end
	else
		if self.m_model:IsNextFlood() then
			self:buyBox(data)
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("four_tower_str_0008"), delay_close = 2})
		end
	end
	
end

function M:buyBox(data)
	if self.m_model:getIsStatue(data.index) == 1 then ---额外开启宝箱次数不足
		self:nextFlood()
	else
		self:receiveBox(data.index)
	end
end

--打开帮助页面
function M:openHelpPop()
	local params = {
		title = "tid#tower1",
		content = "tid#NfourtowerDes_8"
	}
	self:openView("Pops.CommonFiveLineHelpPop", params)
end

--战斗结果处理
function M:handleBattleResult(data)
	local function callback(response)
		if data and data.result and data.result == 1 then --胜利
			self:refreshDataWithCloudEffect(response, data.index)
		else
			self:refreshData(response)
		end
	end
	self.m_model:getNetData("four_tower_index", nil, callback, nil, true)
end

--碾压
function M:autoBattle(position)
	local function netCallback(response)
		if response.need_battle == 1 then --需要战斗
			self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.FOUR_TOWER, def_data = self.m_model.m_data.events[tostring(data.index)], assist_heros = self.m_model.m_data.assist_heros, five_pos = data.index, heirlooms = self.m_model.m_data.heirlooms ,version = self.m_model.m_data.vsn})
			return
		end
		local function tipCallback()
			self:refreshDataWithCloudEffect(response, position)
		end
		local heirlooms = {}
		if response and response.reward then
			heirlooms = response.reward.ft_heirloom or {}
		end
		RewardUtil:rewardTipsByData(response.reward, {heirloom = heirlooms}, tipCallback) --展示奖励
	end
	local params = {
		position = position,
		vsn = self.m_model.m_data.vsn
	}
	self.m_model:getNetData("four_tower_auto_battle", params, netCallback)
end

--领取遗物
function M:receiveHeirloom(position)
	local function netCallback(response)
		local function tipCallback()
			if response.floor ~= self.m_model.m_data.floor then
				self:refreshDataWithCloudEffect(response)
			else
				self:refreshData(response)
			end
		end
		local heirlooms = {}
		if response and response.reward then
			heirlooms = response.reward.ft_heirloom or {}
		end
		RewardUtil:rewardTipsByData({heirloom = heirlooms}, nil, tipCallback) --展示已领取奖励
	end
	local params = {
		position = position,
		vsn = self.m_model.m_data.vsn
	}
	self.m_model:getNetData("four_tower_receive_heirloom", params, netCallback)
end

--领取宝箱
function M:receiveBox(position)
	local function netCallback(response)
		local function tipCallback()
			if response.floor ~= self.m_model.m_data.floor then
				self:refreshDataWithCloudEffect(response)
			else
				self:refreshData(response)
			end
		end
		RewardUtil:rewardTipsByData(response.reward, nil, tipCallback) --展示已领取奖励
	end
	local params = {
		position = position,
		vsn = self.m_model.m_data.vsn
	}
	self.m_model:getNetData("four_tower_receive_box", params, netCallback)
end

--手动进入下一关
function M:nextFlood()
	local function netCallback(response)
		self:refreshDataWithCloudEffect(response)
	end
	local params = {
		vsn = self.m_model.m_data.vsn
	}
	self.m_model:getNetData("four_tower_enter_next_floor", params, netCallback)
end

function M:destroy()
	M.super.destroy(self)

end

--更新时间
function M:updateTime()
	self.m_view:updateTime()
end


return M