local M = class("LuckyRabbitHutMainControl",LikeOO.OOControlBase)

local _Notice_Second = 34
local _Notice_Delay = 0

function M:onEnter()
	self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
	if msg == 99999 then
		self:updateMsg("common_refresh", nil, "parent")
		self:closeView()
	elseif msg == "btn_rank" then
		local params = {
			version = self.m_model.m_version,
		}
		self:openView("LuckyRabbitHut/LuckyRabbitHutRankListPop",params)
	elseif msg == "btn_bonus" then
		local params = {
			version = self.m_model.m_version,
			total_times = self.m_model.m_total_times
		}
		self:openView("LuckyRabbitHut.LuckyRabbitHutProgressPop" , params)
	elseif msg == "btn_gift" then
		local cur_ts = UserDataManager:getServerTime()
		if cur_ts >= self.m_model.end_ts then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
			return 
		end
		
		local active_data = UserDataManager:getActivesRechargeDataByOpenId(433)
		if active_data then
			self:openView("LuckyRabbitHut.LuckyRabbitGiftPop", {active_data = active_data,open_id = 433, is_token = false})
		end
	elseif msg == "btn_exchange" then
		local cur_ts = UserDataManager:getServerTime()
		if cur_ts >= self.m_model.end_ts then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
			return
		end
		local item_data = RewardUtil:getProcessRewardData(self.m_model.rabbit_ticket_data)
		if item_data.user_num <= 0 then
			GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("lucky_rabbit_hut_main_014"), delay_close = 2 })
			return
		end
		local params =
		{
			--内容
			msg = Language:getTextByKey("lucky_rabbit_hut_006"),
			--标题
			title = Language:getTextByKey("lucky_rabbit_hut_main_005"),
			version = self.m_model.m_version,
			--通知的类名
			--className = "QiXi.QiXiShopping",
			--消耗类型
			--cost_data = gift_data.cfg.price_type or 1,
			--cost_data = 1,
			--消耗
			--cost = gift_data.cfg.price or 1,
			limit_num = 999 ,--limit_num,
			clickBuy = function(num)
				self:exchange_onClick(num)
			end
		}
		self:openView("LuckyRabbitHut.LuckyRabbitHutTimesPop", params)
	elseif msg == "btn_notice" then
		local rewards =  self.m_model.gacha_reward_cfg[self.m_model.m_version]
		for i, v in ipairs(rewards) do
			rewards[i].weight = rewards[i].show_weight
		end
		self:openView("Pops.RewardPreviewPop", {show_rewards = rewards})
	elseif msg == "help_btn" then
		local gacha_cfg =  ConfigManager:getCfgByName("rabbit_gacha")
		local lang_desc = gacha_cfg[self.m_model.m_version].des
		self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("lucky_rabbit_hut_main_013"), content = Language:getTextByKey(lang_desc) })
	elseif msg == "close_view" then
		self:updateMsg("common_refresh", nil, "parent")
		static_rootControl:closeAllViewPop()
	elseif msg == "require_index" then
		self:requireIndexNetData()	
	end
end

function M:exchange_onClick(num)
	local callback = function (data)
		self.m_model:initData(data)
		self.m_view:showGetRewardTips(data)
		self.m_view:refreshUI()
	end
	local params = {
		times = num ,
		version = self.m_model.m_version , 
	}
	self.m_model:getNetData("rabbit_draw" , params , callback)
	
end

function M:requireIndexNetData()
	local callback = function (data)
		self.m_model:initData(data)
		self.m_view:refreshUI()
	end
	self.m_model:getNetData("rabbit_index" ,nil, callback)
end

function M:updateTime()
	self.m_view:updateTime()
	_Notice_Second = _Notice_Second + 1
	if _Notice_Second >= 35 then
		_Notice_Second = 0
		self.notice_show = true
		self.m_view:showRabbitTips(true)
	end
	if self.notice_show then
		_Notice_Delay = _Notice_Delay + 1
		if _Notice_Delay >= 4 then
			_Notice_Delay = 0
			self.notice_show = false
			self.m_view:showRabbitTips(false)
		end
	end
end

function M:destroy()
	self:removeTimer(self.m_timer_id)
	M.super.destroy(self)
end


return M