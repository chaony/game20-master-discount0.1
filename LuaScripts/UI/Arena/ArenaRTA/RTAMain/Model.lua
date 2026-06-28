---@class RTAMainModel:OODataBase
---@field m_control RTAMainControl
local M = class("RTAMainModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)

	self:getData("rta_index")
end

function M:onEnter()
	--self.matchRemainingTime=9999999
	--self.matchCurTime=-1
	--
	--self.m_cur_step=-1
	--self.inited=false
	self.cur_seclect_ban_oid=-1
	self.win_num=self.m_data.win_num

	ChatUtil:setRTAHeartInternal(self.m_data.sync_interval)
	self:resetState()
	self:initData()
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self:initData()
end

function M:initData()
	self.advanceLv=1
	self.overTime=200

	self.selected_ids ={}

	--1:由rta主界面进轮选人界面  2：进入ban选人界面
	self.battleVSMode=1

	self.inMatching=false
	self.m_match_id =nil
	self.m_select_islock=false
	self.m_is_myTurn=false

	self.m_promote_flag=self.m_data.promote_flag
	--self.m_promote_flag=2

	self.m_cur_tier=self.m_data.tier>0 and self.m_data.tier or 1

	self.m_own_pre_selected_num=0
	self.m_other_pre_selected_num=0

	local cfg=ConfigManager:getCfgByName("rta_rule")
	self.m_limit_cfg=cfg[self.m_data.rule]
	self:switchHeroList()
end


function M:cancelMatch()
	self.matchCurTime=-1
end

function M:getFormationBattleData()
	local self_uid=UserDataManager.user_data:getUid()
	local battleData=nil
	if self.m_sync_data.battle.atker.uid==self_uid then
		battleData=self.m_sync_data.battle.atker
	else
		battleData=self.m_sync_data.battle.defer
	end
	return battleData
end

function M:lockSelectHero()
	self.m_select_islock=true
end

function M:unlockSelectHero()
	self.m_select_islock=false
end


--全服禁用侠客
function M:getServerBanHeros()
	return self.m_data.global_ban_heros
end


function M:getSelfScore()
	return self.m_data.score
end

function M:update_Sync_data(data)
	self.m_sync_data=data
	--执行一次即可
	self.forbidenIds=self.m_data.global_ban_heros or {}
	if data.pre_ban_heros~=nil then
		for i = 1, 2 do
			if data.pre_ban_heros[i] then
				self.forbidenIds[#self.forbidenIds+1]=data.pre_ban_heros[i]
			end
		end
	end

	if self.pre_ban_heros==nil then
		self.pre_ban_heros=data.pre_ban_heros or {}
	end
	self:update_selected_oids()
end


function M:set_cur_match_id(match_id)
	self.m_match_id =match_id
end

--胜率计算
function M:calculateWinRate()
	local rate=0
	if self.m_data.win_num==nil or self.m_data.lose_num==nil then
		rate=0
	else
		rate=self.m_data.win_num*100/(self.m_data.win_num+self.m_data.lose_num)
	end
	return rate
end

--本期结束剩余时间
function M:calculateOverRemainingTime()
	return GameUtil:formatTimeBySecond(self.m_data.end_ts-UserDataManager:getServerTime())
end

function M:judgeForbidden(hero_id)
	local index_id=table.indexof(self.forbidenIds,hero_id)
	return index_id and true
end

function M:judgeSelected(id)
	local index_id=table.indexof(self.selected_ids, id)
	return index_id and true
end

--更新已选侠客
function M:update_selected_oids()
	local ownData=self:getUserInfoBySort(1)
	local enemyData=self:getUserInfoBySort(2)
	self.pre_selected_num=self.selected_ids and #self.selected_ids or 0
	self.selected_ids ={}
	if ownData.heros then
		for i, hero in pairs(ownData.heros) do
			table.insert(self.selected_ids,hero.tid)
		end
	end

	if enemyData.heros then
		for i, hero in pairs(enemyData.heros) do
			table.insert(self.selected_ids,hero.tid)
		end
	end
	self.cur_selected_num=#self.selected_ids
end

function M:selectedHaveChanged()
	return self.cur_selected_num~=self.pre_selected_num
end

function M:updateBanHeros(heros_ban)
	self.heros_ban=heros_ban
end

function M:getHero(id)
	local  data, cfg = UserDataManager.hero_data:getHeroDataById(id)
	return data, cfg
end

function M:getHeroDataByIndex(index)
	return self.hero_list[index]
end

function M:switchHeroList(race)
	self.m_race = race or 0
	self.hero_list = self:filtrateHero(self.m_race)
	if next(self.hero_list) == nil then
		self.isNil = true
		return self.hero_list
	end

	return self.hero_list
end

--过滤后的英雄列表
function M:filtrateHero(race_id)
	local hero_list = self:getAllHeroIds()
	if race_id == 0 then
		UserDataManager.hero_data:heroIdsSort(hero_list)
		return hero_list
	end
	local heros = {}
	if race_id == 100 then  -- SP
		for k,v in pairs(hero_list) do
			local l_hero_data, l_hero_cfg = self:getHero(v)
			if l_hero_cfg.is_sp == 1 then
				table.insert(heros, v)
			end
		end
	else
		for k,v in pairs(hero_list) do
			local l_hero_data, l_hero_cfg = self:getHero(v)
			if race_id == l_hero_cfg.race then
				table.insert(heros, v)
			end
		end
	end

	UserDataManager.hero_data:heroIdsSort(heros, "team")
	return heros
end

function M:getAllHeroIds()
	local ids = table.copy(UserDataManager.hero_data:getHerosId())
	return ids
end

function M:getMatchRemainingTime()
	if self.matchCurTime<self.matchRemainingTime then
		self.matchCurTime = self.matchCurTime+1
	end
	return self.matchCurTime
end

function M:init_isatker()
	local self_uid=UserDataManager.user_data:getUid()
	self.isAtker=self_uid==self.m_sync_data.atker.uid
end

function M:isOwnTurn(uid)
	local self_uid=UserDataManager.user_data:getUid()
	self.m_is_myTurn=uid==self_uid
	return self.m_is_myTurn
end

--sort==1是自己，2是对方
function M:getUserInfoBySort(sort)
	local self_uid=UserDataManager.user_data:getUid()
	local matchData = self.m_sync_data or {}
	if matchData.atker==nil then
		return {}
	end
	if sort == 1 then -- 左边

		if self_uid==matchData.atker.uid then

			return matchData.atker or {}
		else
			return matchData.defer or {}
		end
	else --  右边
		if self_uid~=matchData.atker.uid then
			return matchData.atker or {}
		else
			return matchData.defer or {}
		end
	end
end

function M:getChatMsgByChannel(channel_id)
	if channel_id == nil then
		return
	end
	local other_msg, private_msg = {}, {}
	if channel_id == __CHAT_CHANNEL.PRIVATE then
		private_msg = ChatUtil:getLatestPrivateMsg(channel_id)

	else
		other_msg = ChatUtil:getChannelMsg(channel_id)
		private_msg =  ChatUtil:getLatestPrivateMsg()
	end

	local last_msg = {}
	local sort_tab = self:sortNewChatMsg(private_msg, other_msg)
	for i = #sort_tab - 1, #sort_tab do
		if sort_tab[i] and next(sort_tab) then
			local msg = sort_tab[i].is_private and private_msg[sort_tab[i].msg_index] or other_msg[sort_tab[i].msg_index]
			last_msg = msg
		end
	end

	return last_msg
end

function M:sortNewChatMsg(private_msg, other_msg)
	local sort_tab = {} --
	if other_msg and next(other_msg) then
		for i = #other_msg - 1, #other_msg do
			if other_msg[i] then
				sort_tab[#sort_tab + 1] = {msg_time = other_msg[i].time, msg_index = i, is_private = false}
			end
		end
	end
	if private_msg and next(private_msg) then
		for i = #private_msg - 1, #private_msg do
			if private_msg[i] then
				sort_tab[#sort_tab + 1] = {msg_time = private_msg[i].time, msg_index = i, is_private = true}
			end
		end
	end
	table.sort(sort_tab, function(a, b)
		return a.msg_time < b.msg_time
	end)
	return sort_tab
end

function M:getCurSelectedSpineName()

end

--检测是否当前轮
function M:resetState()
	self.matchRemainingTime=9999999
	self.matchCurTime=-1

	self.cur_seclect_hero_oid=nil
	self.cur_seclect_ban_oid=-1

	self.m_cur_step=-1
	self.inited=false
	self.inMatching=false
end


return M
