local M = class("UnionMainPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("")
end

function M:onEnter()
	self.m_manage_enum_tab = {president = 1, elder = 2, others = 0}
	self.m_data = self.m_params
	self:updateListData(self.m_data.players)
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self:updateListData(self.m_data.players)
end

function M:updateListData(data)
	self.m_list_data = data
end

function M:getPresidentData()
	for i,v in ipairs(self.m_list_data) do
		if v.uid == self.m_data.guild.president then
			return v
		end
	end
end

function M:getSelfUnionData()
	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	for i,v in ipairs(self.m_list_data) do
		if self_uid == v.uid then
			return v
		end
	end
end

function M:getUnionData()
	local guild_cfg = ConfigManager:getCfgByName("guild")
	local cfg = guild_cfg[self.m_data.guild.level]
	return self.m_data.guild, cfg
end

function M:getIsNPC(uid)
	for i,v in ipairs(self.m_data.guild.npc) do
		if v == uid then
			return true
		end
	end
	return false
end

function M:getIsManager()
	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	local manage_flag = self.m_manage_enum_tab.others
	if self_uid == self.m_data.guild.president then
		 return  self.m_manage_enum_tab.president
	else
		for i, v in pairs(self.m_data.guild.elders) do
			if v == self_uid then
				return  self.m_manage_enum_tab.elder
			end
		end
	end
	return self.m_manage_enum_tab.others
end

function M:isShowImpeachBtn()
	local is_show =  false
	if self.m_data and self.m_data.can_impeach and self.m_data.can_impeach == 1 then
		is_show = true
	end
	return is_show
end
function M:callBack(data)
	local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    if guild_id and guild_id > 0 then
    	M.super.callBack(self,data)
    else
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("union_str_0028"), delay_close = 2})
        static_rootControl:closeAllViewPop()
    end
end

function M:checkCanSendMail()
	if self.m_data.send_mail_etime == nil then
		return true
	end
	if self.m_data.send_mail_etime == 0 or UserDataManager:getServerTime() > self.m_data.send_mail_etime then
		return true
	end
	return false
end

function M:getMailDownTime()
	if self.m_data.send_mail_etime == nil then
		return 0
	end
	return GameUtil:formatTimeBySecond(self.m_data.send_mail_etime - UserDataManager:getServerTime(),999) 
end

function M:updateTripodOnceRedPoint()
	--神炉红点
	local min_tripod_lv = 0
	local min_tripod_num = 20
	local min_tripod_k = 0
	local min_condition_lv = 0
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	for k,v in pairs(guild_tripod) do
		local type_cfg = guild_tripod[k] or {}
		local lv = UserDataManager.tripods[tostring(k)] or 1
		local cfg = type_cfg.config[lv+1]
		if cfg then
			if min_tripod_lv == 0 or min_tripod_lv < lv then
				min_tripod_num = cfg.lvup_cost[3]
				min_tripod_k = k
				min_condition_lv= cfg.condition_lv
			end
		end
	end
	if UserDataManager.guild_lv >= min_condition_lv then
		local tripod_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.TRIPOD_COIN,0,0})
		if tripod_data.user_num >= min_tripod_num then
			UserDataManager.red_dot["tripod_once"] = {status = 1}
		end
	end
end

return M
