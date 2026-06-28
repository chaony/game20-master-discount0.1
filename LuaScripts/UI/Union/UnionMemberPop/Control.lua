local M = class("UnionMemberControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
	elseif msg == "cell_btn" then
		self:openView("Pops.PlayerInfo", {uid = data.data.uid, guild = self.m_model.m_data, look_model = 3})
	elseif msg == "handle_point_btn" then
		self.m_model:setTargetMember(data.data.uid)
		self.m_view:refreshUI()
		self.m_view.m_list_scroll:moveToCellIndex(data.index)
	elseif msg == "handle_btn" then
		self:memberHandle(data)
	elseif msg == "update_data" then
		self.m_model:updateData(data)
		local uid = self.m_model.m_target_uid
		self.m_model.m_target_uid = nil
		if not(self.m_model.m_is_trans) then
			self.m_model:setTargetMember(uid)
		end
		self.m_view:refreshUI()
    end
end

------------------------------------------------------------------------------------
--- 成员管理
function M:memberHandle(data)
	local member = self.m_model:getMemberData()
	if data == GlobalConfig.UNION_HANDLE_ID.PROMOTE_ELDER  then
		local guild = ConfigManager:getCfgByName("guild")
		local guild_cfg = guild[self.m_model.m_data.guild.level]
		local have = guild_cfg.elder - #self.m_model.m_data.guild.elders
		if have <= 0 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_1064"), delay_close = 2})
			return
		end

		local params =
		{
			on_ok_call = function(msg)
				self:promoteElder()
			end,
			no_close_btn = false,
			text = string.format(Language:getTextByKey("union_str_1059"), member.name)
		}
		static_rootControl:openView("Pops.CommonPop", params)
	elseif data == GlobalConfig.UNION_HANDLE_ID.CHANGE_ELITE then
		local flag = self.m_model:getIsNPC(self.m_model.m_target_uid)
		local text = string.format(Language:getTextByKey("union_str_1060"), member.name)
		local guild = ConfigManager:getCfgByName("guild")
		local guild_cfg = guild[self.m_model.m_data.guild.level]
		if flag then
			--local server_time = UserDataManager:getServerTime()
			--local time = self.m_model.m_data.guild.weekly_etime - server_time
			--if time <= 0 then
			--	return
			--end
			--local str_time = GameUtil:formatTimeBySecond2(time)
			--local have = guild_cfg.npc - self.m_model.m_data.guild.npc_lock - #self.m_model.m_data.guild.npc
			--have = have > 0 and have or 0
			--text = string.format(Language:getTextByKey("union_str_1061"), str_time, have)
			text = Language:getTextByKey("union_str_1069", member.name)
		else
			local have = guild_cfg.npc - self.m_model.m_data.guild.npc_lock - #self.m_model.m_data.guild.npc
			if have <= 0 then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_1063"), delay_close = 2})
				return
			end
		end
		local params =
		{
			on_ok_call = function(msg)
				self:changeElite()
			end,
			no_close_btn = false,
			text = text
		}
		static_rootControl:openView("Pops.CommonPop", params)
	elseif data == GlobalConfig.UNION_HANDLE_ID.DEMOTE then
		local params =
		{
			on_ok_call = function(msg)
				self:demote()
			end,
			no_close_btn = false,
			text = string.format(Language:getTextByKey("union_str_1062"), member.name)
		}
		static_rootControl:openView("Pops.CommonPop", params)
	elseif data == GlobalConfig.UNION_HANDLE_ID.DELETE then
		local params =
		{
			on_ok_call = function(msg)
				self:deleteMember()
			end,
			no_close_btn = false,
			text = string.format(Language:getTextByKey("union_str_1058"), member.name)
		}
		static_rootControl:openView("Pops.CommonPop", params)
	elseif data == GlobalConfig.UNION_HANDLE_ID.BLACK then
		local params =
		{
			on_ok_call = function(msg)
				self:black()
			end,
			no_close_btn = false,
			text = Language:getTextByKey("friend_str_0021")
		}
		static_rootControl:openView("Pops.CommonPop", params)
	elseif data == GlobalConfig.UNION_HANDLE_ID.ABDICATE then
		local params =
		{
			on_ok_call = function(msg)
				self:abdicateOwner()
			end,
			no_close_btn = false,
			text = string.format(Language:getTextByKey("union_str_1071"), member.name)
		}
		static_rootControl:openView("Pops.CommonPop", params)
	elseif data == GlobalConfig.UNION_HANDLE_ID.SEND_MAIL then
		local params =
		{
			on_ok_call = function(msg)
				self:sendMailActive()
			end,
			no_close_btn = false,
			text = string.format(Language:getTextByKey("union_str_1075"), member.name)
		}
		static_rootControl:openView("Pops.CommonPop", params)
	end
end

-- 刷新成员列表
function M:refreshMember()
	local function refreshMemberRequest(response)
		self:updateMsg("update_data", response, "Union.UnionMain")
		self:updateMsg("update_data", response)
	end
	local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
	local params = {guild_id = guild_id}
	self.m_model:getNetData("guild_guild_members", params, refreshMemberRequest)
end
-- 提升为长老
function M:promoteElder()
	local function promoteElderRequest(response)
		self:updateMsg("update_data", response, "Union.UnionMain")
		self:updateMsg("update_data", response)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
	end
	local params = {}
	params.member = self.m_model.m_target_uid
	self.m_model:getNetData("guild_promote_elder", params, promoteElderRequest)
end
-- 转让帮主
function M:abdicateOwner()
	local function abdicateOwnerRequest(response)
		if response then
			self:updateMsg("update_data", response, "Union.UnionMain")
			self.m_model.m_is_trans = true
			self:updateMsg("update_data", response)
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
		else
			self:refreshMember()
		end
	end
	local params = {}
	params.member = self.m_model.m_target_uid
	self.m_model:getNetData("guild_guild_transfer", params, abdicateOwnerRequest, false, true)
end
-- 设置无谓之手
function M:changeElite()
	local function changeEliteRequest(response)
		self:updateMsg("update_data", response, "Union.UnionMain")
		self:updateMsg("update_data", response)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
	end
	local params = {}
	params.member = self.m_model.m_target_uid
	self.m_model:getNetData("guild_change_npc", params, changeEliteRequest)
end

-- 撤职
function M:demote()
	local function demoteRequest(response)
		self:updateMsg("update_data", response, "Union.UnionMain")
		self:updateMsg("update_data", response)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
	end
	local params = {}
	params.member = self.m_model.m_target_uid
	self.m_model:getNetData("guild_demote_member", params, demoteRequest)
end

-- 踢出公会
function M:deleteMember()
	local function kickRequest(response)
		self:updateMsg("update_data", response, "Union.UnionMain")
		--self:updateMsg("update_data", response, "Union.UnionHall")
		self:updateMsg("update_data", response)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
	end
	local params = {}
	params.member = self.m_model.m_target_uid
	self.m_model:getNetData("guild_kick_member", params, kickRequest)
end

-- 加入黑名单
function M:black()
	local function blackCallback(response)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0115"), delay_close = 2})
	end
	local params = {}
	params.f_uid = self.m_model.m_target_uid
	self.m_model:getNetData("friend_add_to_blacklist", params, blackCallback)
end

-- 发送邮件
function M:sendMailActive()
	local member = self.m_model:getMemberData()
	self:openView("Union.UnionMailPop", {target_uid = member.uid})
end

return M;
