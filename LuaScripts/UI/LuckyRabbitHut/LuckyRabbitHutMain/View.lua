local M = class("LuckyRabbitHutMainView", LikeOO.OOPopBase)

M.m_uiName = "LuckyRabbitHut/LuckyRabbitHutMain"
M.m_iphoneXAdapter = true
M.m_size_type = 1  --

local _boss_transform_ = {  --记录boss模型在场景中的transform三项数据 
	{P = Vector3(0, -0.5, -2.71), R = Quaternion.Euler(0, 0, 0), S = Vector3(1, 1, 1)},
}

function M:onEnter()
	self.role_parent = self:findGameObject("role_3d")
	
	self.notice_cfg =  ConfigManager:getCfgByName("rabbit_notice")
	self.gacha_cfg =  ConfigManager:getCfgByName("rabbit_gacha")
	
	self.start_return = self.gacha_cfg[self.m_model.m_version].start_return
	self.start_ts , self.end_ts , self.show_ts = self.m_model:getActiveTs()
	self.notice_idx = 1
	self:refreshUI()
end

function M:refreshUI()
	--self:creatRole3D()
	self:updateTime()
	self.start_ts , self.end_ts , self.show_ts = self.m_model:getActiveTs()

	local red_flag = RedPointUtil:localRedPointJudge("luckyRabbit_gift")
	self:setObjectVisible("img_rp_gift" ,not self.m_model.is_show_date and red_flag)
	
	if self.m_attr_node then
		self.m_attr_node:refreshUI()
	else
		self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 47})
	end
	
	self:setTextByLanKey("close_title_text", "lucky_rabbit_hut_main_013")	--瑞兔小斋
	self:setTextByLanKey("txt_bonusPool_title", "lucky_rabbit_hut_main_009")	--分红奖池
	self:setTextByLanKey("txt_share_title", "lucky_rabbit_hut_main_010")	--个人股份
	self:setTextByLanKey("txt_bonus_title", "lucky_rabbit_hut_main_011")	--分红奖励
	self:setTextByLanKey("txt_totalReward_title", "lucky_rabbit_hut_main_012")	--总奖励
	
	local bonus_info = self.m_model:getBonusInfo()
	local rate_txt = string.format("%.1f", bonus_info.rate * 100) .."%"
	self:setTextByLanKey("txt_bonusPool_value", bonus_info.jackpot)
	self:setTextByLanKey("txt_share_value", rate_txt)
	self:setTextByLanKey("txt_bonus_value", bonus_info.bonus)
	self:setTextByLanKey("txt_totalReward_value", bonus_info.bonus_total)

	local self_rank = self.m_model.m_self_rank == 0 and "未上榜" or self.m_model.m_self_rank
	local lang_self_rank = Language:getTextByKey("lucky_rabbit_hut_main_001" , self_rank)
	self:setTextByLanKey("txt_rank_btn", lang_self_rank)

	local total_ratio = (self.start_return + self.m_model:getExReturnRatio()) * 100 
	local lang_self_rate = Language:getTextByKey("lucky_rabbit_hut_main_002" , string.format("%.0f",total_ratio) .. "%")
	self:setTextByLanKey("txt_bonus_btn", lang_self_rate)
	self:setTextByLanKey("txt_gift_btn", "lucky_rabbit_hut_main_007")	--瑞兔礼包
	self:setTextByLanKey("txt_notice_btn", "lucky_rabbit_hut_main_008")	--瑞兔公告
	
	self:setTextByLanKey("txt_timeTitle", "lucky_rabbit_hut_main_004")	--活动剩余时间
	
	local item_data = RewardUtil:getProcessRewardData(self.m_model.rabbit_ticket_data)
	
	self:setTextByLanKey("txt_exchange_btn", "lucky_rabbit_hut_main_005")	--兑换纪念币
	local self_times = Language:getTextByKey("lucky_rabbit_hut_main_003" , self.m_model.m_self_times)	--个人兑换次数
	self:setTextByLanKey("txt_exchange_tips", self_times)
	self:setTextByLanKey("txt_leftCoin_title", "lucky_rabbit_hut_main_006")	--剩余
	self:setTextByLanKey("txt_leftCoin_value", item_data.user_num)
	self:setImg(item_data.icon_name, item_data.atlas_name, "img_coin_icon")
	
	self:setObjectVisible("img_rp_exchange" ,not self.m_model.is_show_date and item_data.user_num > 0)
end

function M:updateTime()
	local cur_ts = UserDataManager:getServerTime()
	if cur_ts >= self.show_ts then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
		self:updateMsg("close_view")
	end
	local left_ts_txt = ""
	if cur_ts <= self.end_ts then
		local left_ts = self.end_ts - cur_ts
		left_ts_txt = GameUtil:formatTimeBySecond(left_ts)
	else
		left_ts_txt = "gf_str_0150"
	end
	self:setTextByLanKey("txt_timeValue", left_ts_txt)	
end

function M:showRabbitTips(show)
	local tipsWordsList = self.notice_cfg[self.m_model.m_version]
	if show then
		self.notice_idx = self.notice_idx >= #tipsWordsList and 1 or self.notice_idx + 1
	end
	self:setObjectVisible("img_rabbit_notice_left", show)
	self:setTextByLanKey("txt_rabbit_notice_left" , tipsWordsList[self.notice_idx].words)
end

function M:showGetRewardTips(data)
	if data.reward then
		RewardUtil:rewardTipsByData(data.reward)  --获得奖励弹窗
	end
end

--function M:creatRole3D()
--	UIUtil.destroyAllChild(self.role_parent.transform)
--	ResourceUtil:LoadRole3dAsync("A_Xian/A_Xian", self.role_parent, function(obj)
--		obj.transform:SetParent(self.role_parent.transform, false)
--		obj.transform.localPosition = _boss_transform_[1].P
--		obj.transform.localRotation = _boss_transform_[1].R
--		obj.transform.localScale = _boss_transform_[1].S
--	end, true)
--end


function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end

return M