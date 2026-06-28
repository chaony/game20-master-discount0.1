local M = class("FriendPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_tab_index = self.m_params.tab_index or 1
	self.m_friend_tab_index = 1
	self.m_unlock_mercenary = BtnOpenUtil:isBtnOpen(48)
	self.m_unlock_master = BtnOpenUtil:isBtnOpen(51)
	self.m_friend_num = 0
	self.m_heart_num = 0
	self.m_give_num = 0
	self.m_friend_sort = 1
	self.m_mail_select_index = 1
	self.m_offline_invite = self.m_params.offline_invite or 1 -- 离线：0不显示邀请，1显示邀请
	self.m_type = self.m_params.type or 0
	self.m_invite_callback = self.m_params.invite_callback
	self.m_mercenary_hero = {} -- 雇佣的英雄
	self.m_mercenary_race = 1 -- 佣兵种族筛选
	self.m_show_btn_list = self.m_params.show_btn or {} -- 需要显示的btn
	self.m_cheer_callback = self.m_params.cheer_callback
	self:mailOnEnter()
end

function M:setTabIndex(index)
	self.m_tab_index = index
end

function M:isHaveData()
	if self.m_tab_index == 1 then
		if self.m_friend_data then
			return true
		end
	elseif  self.m_tab_index == 2 then
		if self.m_mercenary_data then
			return true
		end
	elseif	 self.m_tab_index == 3 then 
		if self.m_master_apprentice_data then
			return true
		end
	end
end

-------------- 好友 --------------------------------------------
function M:setFriendsData(data)
	self.m_friend_data = data
	self.m_friend_num = #self.m_friend_data.friends_info or 0
	self:friendSort()
end

function M:getFriendDataByIndex(index)
	return self.m_friend_data.friends_info[index]
end

function M:setFriendSort(sort_s)
	self.m_friend_sort = sort_s or 1
	self:friendSort()
end

function M:friendSort()
	if self.m_friend_sort == 1 then -- 状态排序
		local function timeSort(data1, data2)
			-- if data1.is_online == 0 and data2.is_online == 0 then
				return data1.last_active_time > data2.last_active_time
			-- end
			-- return data1.is_online ~= 0
		end
		table.sort( self.m_friend_data.friends_info, timeSort )
	elseif self.m_friend_sort ==2 then -- 名字排序
		local function nameSort(data1, data2)
			return data1.name < data2.name
		end
		table.sort( self.m_friend_data.friends_info, nameSort )
	end
end


-------------- 好友申请 --------------------------------------------
function M:setApplyData(data)
	self.m_apply_data = data
	self:setApplyFriendsData(data)
end

function M:setApplyFriendsData(data)
	self.m_friends = data.messages or {}
	self.m_apply_msg_num = #self.m_friends or 0
	self.m_apply_list_num = self.m_apply_msg_num
end

function M:getDataByIndex(index)
	if self.m_friend_tab_index == 2 then
		return self.m_friends[index]
	elseif self.m_friend_tab_index == 3 then
		return self.m_recommend[index]
	elseif self.m_friend_tab_index == 4 then
		return self.m_blackes[index]	
	end
end

function M:getListNum()
	if self.m_friend_tab_index == 2 then
		return self.m_apply_list_num, self.m_friends
	elseif self.m_friend_tab_index == 3 then
		return self.m_recommend_num, self.m_recommend
	elseif self.m_friend_tab_index == 4 then
		return self.m_black_list_num, self.m_blackes
	end
end

function M:setApplysData(data)
	self.m_friends = data.messages or {}
	self.m_friend_num = data.friends_num or 0
	self.m_apply_msg_num = #self.m_friends or 0
	self.m_apply_list_num = self.m_apply_msg_num
end

function M:setSearchFriend(data)
	self.m_recommend = data.user_info
	self.m_recommend_num = #self.m_recommend
	self.m_search_bl = true
end

function M:setSearchFriendApplyStatus(index)
	if self.m_recommend[index] then
		self.m_recommend[index].is_applied = 1
	end
end

-------------- 推荐列表 --------------------------------------------
function M:setRecommendFriendData(data)
	self.m_recommend = data.recommend
	self.m_recommend_num = #self.m_recommend
	self.m_search_bl = false
end

function M:updateAllRecommendFriendStatus()
	for k,v in pairs(self.m_recommend) do
		v.is_applied = 1
	end
end

-------------- 黑名单 --------------------------------------------
function M:setBlackesData(data)
	self.m_blackes = data.blacklist_infos
	self.m_black_list_num = #self.m_blackes
end

function M:removeBlackesByIndex(index)
	table.remove(self.m_blackes, index)
	self.m_black_list_num = #self.m_blackes
end


-------------- 佣兵 --------------------------------------------
function M:setMercenaryData(data)
	self.m_mercenary_data = data
	self:setMercenaryRace(self.m_mercenary_race)
end

-- function M:getMercenaryHeroDataByIndex(index)
-- 	return self.m_mercenary_data.hero_grids[index]
-- end

function M:getMercenaryHero()
	return self.m_mercenary_data.apostles
end

function M:getUserData()
	return self.m_mercenary_data.user_data
end

function M:setHeroApplayed(data)
	for i,v in ipairs(self.m_mercenary_data.hero_grids) do
		if v.id == data.id then
			v.apply_flag = data.flag
		end
	end
end

function M:setMercenaryRace(data)
	self.m_mercenary_race = data
	if data == 1 then
		self.m_mercenary_hero = self.m_mercenary_data.hero_grids
	else
		local list = {}
		for i,v in ipairs(self.m_mercenary_data.hero_grids) do
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
			if hero_cfg.race == data - 1 then
				table.insert(list, v)
			end 
		end
		self.m_mercenary_hero = list
	end
end


-------------- 师徒 --------------------------------------------

function M:setMasterApprenticeData(data)
	self.m_master_apprentice_data = data
	self.m_master_status = self.m_master_apprentice_data.status --身份 0:未开启 1:徒弟 2:师傅
	if self.m_master_status == 1 then
		self:setApprenticeData(self.m_master_apprentice_data.mentor)
	elseif 	self.m_master_status == 2 then
		self:setMasterData(self.m_master_apprentice_data.pupils)
	end
	self.m_appostle = data.apostle or {} -- 雇佣的英雄
	self.m_apostle_etime = data.apostle_etime
	self.m_red_packet = data.red_packet -- 红包
	self.m_relivev_info = data.relieve_info or {} --解除信息
end

function M:isMaster()
	if self.m_master_status == 2 then
		return true
	elseif 	self.m_master_status == 1 then
		return false 
	end
end

function M:setMasterData(data)
	if data then
		self.apprenttices = data or {}
	else
		self.apprenttices = {}	
	end
end

function M:getApprenById(id)
	for k,v in pairs(self.apprenttices) do
		if v.uid == id then
			return v
		end
	end
end

function M:setApprenticeData(data)
	if data then
		self.m_mastet_data = data or {}	
	else
		self.m_mastet_data = {}		
	end
end

function M:checkRelivevData(id)
	for k,v in pairs(self.m_relivev_info) do
		if v[1] == id then
			return v[2]
		end
	end
end

--出师进度
function M:progressToText()
	local open_tab = BtnOpenUtil:getBtnCfg(52)
	local max_num = open_tab.unlock_condition_param + 1
	return UserDataManager.stage_id.."/"..max_num
end

--出师进度
function M:progressToRate()
	local open_tab = BtnOpenUtil:getBtnCfg(52)
	local max_num = open_tab.unlock_condition_param + 1
	return UserDataManager.stage_id/max_num
end

function M:getShowStageName()
	local cfg = BtnOpenUtil:getBtnCfg(52)
	local stage_data =self:getStageName(cfg.unlock_condition_param)
	return Language:getTextByKey(stage_data.map_point_name) 
end

--计算时间
function M:figureTim(tim)
	local now_tim = UserDataManager:getServerTime()
	local diff_tim = now_tim - tim 
	return GameUtil:formatTimeBySecond(diff_tim)
end

function M:getStageName(id)
	local stage_tab = ConfigManager:getCfgByName("stage")
	local stage_data = stage_tab[id]
	return stage_data
end

function M:getHeroByStageHeros(id)
	local hero_data = self.m_mastet_data.stage_heros[id]
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	return hero_data, hero_cfg
end

function M:getAppostleHeroById(id)
	local data = self.m_appostle[id]
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
	return data,cfg
end

function M:getCoundTime()
	local now_tim = UserDataManager:getServerTime()
	local tim = self.m_apostle_etime - now_tim
	return tim
end

function M:getRewardAdd()
	local ma_vip = self.m_mastet_data.vip -- 师傅的vip
	local m_vip = UserDataManager.user_data.user_status.vip --
	local vip_bonus =  ConfigManager:getCommonValueById(215) --最高享受比自身等级高3级的加成
	local bonus_vip = 0
	if ma_vip > m_vip then
		if (ma_vip - m_vip) > vip_bonus then
			bonus_vip = m_vip + vip_bonus
		else
			bonus_vip = ma_vip
		end
		local vip_tab = ConfigManager:getCfgByName("vip")
		local vip_data = vip_tab[bonus_vip] 
		local coin_value = vip_data["idle_coin"] -- 额外金币加成
		local hero_exp_value = vip_data["idle_hero_exp"] -- 额外英雄经验加成
		local num_1, num_2 = self:getStageIdle()
		local coin_num = coin_value*num_1
		local hero_exp_num = hero_exp_value*num_2
		return self:formNum(coin_num), self:formNum(hero_exp_num)
	else
		return 0,0	
	end
end

function M:formNum(num)
	local t1, t2 = math.modf(num)
	return t1
end

function M:getStageIdle()
	local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
    local idle_cfg = stage_idle_tab[idle_id]
    return idle_cfg["coin"], idle_cfg["hero_exp"]
end

------------邮件---------------------------------------------

function M:mailOnEnter()
	self.m_mail_ids = {}
	self.m_mail_list_data = {}
	self.m_mail_select_index = 0
	self.m_rewards = {}
end

function M:setSelectIndex(index)
	self.m_mail_select_index = index;
end

function M:setMailData(data)
	if data then
		if #self.m_mail_ids == 0 then -- 有数据只更新一次，避免新数据导致邮件数据混乱
			self.m_mail_ids = data.all_mail_ids or {}
		end
		
		for i,v in ipairs(data.mail or {}) do
			self.m_mail_list_data[#self.m_mail_list_data  +1] = v
		end
	end
end

function M:getLoadMail()
	local mails = {}
	local num = #self.m_mail_list_data
	for i=num + 1, num + 10 do
		local id = self.m_mail_ids[i]
		if id then
			mails[#mails+1] = id
		end
	end
	return mails
end

--function M:AddMailData(data)
--	for i,v in ipairs(data or {}) do
--		self.m_mail_list_data[#self.m_mail_list_data + 1] = v
--	end
--end

function M:getMailByIndex(index)
	return self.m_mail_list_data[index]
end

-- 邮件已读状态设置
function M:setMailStatus(ids, status)
	for i,v in ipairs(ids) do
		for ii,vv in ipairs(self.m_mail_list_data) do
			if vv.id == v then
				vv.status = status
				break
			end
		end
	end
end

-- 邮件领取状态设置
function M:setMailReceived(ids)
	for i,v in ipairs(ids) do
		for ii,vv in ipairs(self.m_mail_list_data) do
			if vv.id == v then
				vv.is_received = true
				vv.status = 1
				break
			end
		end
	end
end

function M:deleteMail(ids)
	for i,v in ipairs(ids or {}) do
		for m,n in ipairs(self.m_mail_ids) do
			if v == n then
				table.remove(self.m_mail_ids,m)
				break
			end
		end

		for m,n in ipairs(self.m_mail_list_data) do
			if v == n.id then
				table.remove(self.m_mail_list_data,m)
				break
			end
		end
	end
end

function M:checkIsFriends(id)
	for k,v in pairs(self.m_friend_data.friends_info) do
		if id == v.uid then
			return true
		end
	end	
	return false
end


return M
