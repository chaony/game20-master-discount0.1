local M = class("WdTowerControl",LikeOO.OOControlBase)

function M:onEnter()
	--self.m_guide_file_name = "UI.YinTower.Guide"
	self:updateTime()
	self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

--function M:startGuide()
--    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(41, 2)
--    if have_guide then
--        if self.m_guide then
--            self.m_guide:start()
--        end
--    end
--end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("common_refresh" ,nil ,"parent")
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
		self:openView("YinTower.YinTowerDeffDetail", {floor = self.m_model.m_data.floor,
													  vsn = self.m_model.m_data.vsn,
													  index = data.index,
													  assist_heros = self.m_model.m_data.assist_heros,
													  cell_data = cell_data_temp,
													  enemyCombat = self.m_model:getEnemyCombat(data.index),
													  m_battle = self.m_model:getQuickPass(data.index)})
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
			self:openView("YinTower.YinTowerGreatReward", {index = data.index, cell_data = cell_data_temp})
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
	elseif msg == "help_btn" then
		self:openHelpPop()
	elseif msg == "rank_btn" then
		self:openView("WdTower.WdTowerRank", {vsn = self.m_model.m_data.vsn})
	elseif msg == "gift_btn" then
		self:openView("WdTower.WdTowerGiftPop")
	elseif msg == "refreshRedPoint" then
		self.m_view:refreshRedPoint()
	elseif msg == "challenge_btn1" then
		self:battleOrOpen({index = 1})
	elseif msg == "challenge_btn2" then
		self:battleOrOpen({index = 2})
	elseif msg == "challenge_btn3" then
		self:battleOrOpen({index = 3})
	elseif msg == "reset_btn" then
		self:refreshIndexData()
	end
end

function M:requestReset()
	local function netCallback(response)
		if response.update == 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
			self:updateMsg(99999)
		end
		if response["end"] == 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
			self:updateMsg(99999)
			return
		end
		self:refreshDataWithCloudEffect(response)
	end
	local params = { version = self.m_model.m_data.vsn}
	self.m_model:getNetData("wdtower_reset_floor", params, netCallback)
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
	local cur_times = self.m_model.m_data.times or 0
	local total_times = self.m_model.m_data.total_times or 0
	if total_times - cur_times <= 0 then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wdtower_text_0007"), delay_close = 2})
		return
	end

	if self.m_model:getEndTs() > 0 and self.m_model:getActStatus() == 1 then --有次数可领取
		--local battle = self.m_model:getQuickPass(data.index)
		self.m_model.is_battle = true

		if self.m_model:checkTeam() then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wdtower_text_0004"), delay_close = 2})
		end
		local race_nums_tab = self.m_model:getRaceType()
		local races = table.keys(race_nums_tab)
		local enemy_combat = self.m_model:getEnemyCombat(data.index)
		local battle_scale = self.m_model:getTowerStageBattleScale()

		self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.WD_TOWER,
									def_data = self.m_model.m_data.events[tostring(data.index)],
									assist_heros = self.m_model.m_data.assist_heros,
									five_pos = data.index,
									heirlooms = self.m_model.m_data.heirlooms,
									races = races,
									race_nums_tab = race_nums_tab,
									wdtower_enemy_combat = enemy_combat * battle_scale[data.index],
									version = self.m_model.m_data.vsn})

	else
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("yinTower_text_0013"), delay_close = 2})
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
	local content_id = self.m_model:getDesByKey("detail1") or "tid#NfourtowerDes_8"
	local title_str = "yinTower_text_0006" --getDesByVsn
	if self.m_model:getDesByKey("title") then
		title_str = self.m_model:getDesByKey("title")
	end
	local params = {
		title = title_str,
		content = content_id
	}
	self:openView("Pops.CommonFiveLineHelpPop", params)
end

--战斗结果处理
function M:handleBattleResult(data)
	local function callback(response)
		if response then
			if response.update == 1 then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
				self:updateMsg(99999)
			end
			if response["end"] == 1 then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
				self:updateMsg(99999)
				return
			end
			if data and data.result and data.result == 1 then --胜利
				self:refreshDataWithCloudEffect(response, data.index)
			else
				self:refreshData(response)
			end
		end
	end
	self.m_model:getNetData("wdtower_index", nil, callback, nil, true)
end

--碾压
function M:autoBattle(position)
	local function netCallback(response)
		if response.update == 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
			self:updateMsg(99999)
		end
		if response["end"] == 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
			self:updateMsg(99999)
			return
		end
		if response.need_battle == 1 then --需要战斗
			self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.WD_TOWER, def_data = self.m_model.m_data.events[tostring(data.index)], assist_heros = self.m_model.m_data.assist_heros, five_pos = data.index, heirlooms = self.m_model.m_data.heirlooms ,version = self.m_model.m_data.vsn})
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
	self.m_model:getNetData("dark_tower_auto_battle", params, netCallback)
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
	if self.m_timer_id then
		self:removeTimer(self.m_timer_id)
	end
	M.super.destroy(self)
end

--更新时间
function M:updateTime()
	self.m_view:updateTime()
end

function M:refreshIndexData()
	local function netCallback(response)
		if self.m_view then
			self.m_model:updateServerData(response)
			local cur_times = self.m_model:getResetTimes()
			local params =
			{
				on_ok_call = function(msg)
					-- self:downloadRes()
					self:requestReset()
				end,
				on_cancel_call = function (msg)

				end,
				no_close_btn = false,
				tow_close_btn = true,
				text = Language:getTextByKey("wdtower_text_0005", cur_times)
			}
			static_rootControl:openView("Pops.CommonPop", params, nil, true)
		end
		RewardUtil:rewardTipsByData(response.reward)
	end
	self.m_model:getNetData("wdtower_index", nil, netCallback)
end

return M