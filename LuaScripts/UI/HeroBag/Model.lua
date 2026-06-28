---@class HeroBagModel:OOControlBase
local M = class("HeroBagModel", LikeOO.OODataBase)

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘
M.jing_mai_lock_quite = 9

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.refresh_hero_list = false -- 对英雄操作需要刷新列表
	self.m_delay_time = 0.5 --长按升级延迟
	self.m_level_up = 0--快速升级展示
	self.m_show_quick_level_up = 0 --快速升级剩余显示时间
	self.isNil = false
	self.talk_interval = 5
	self.m_mode = self.m_params.mode or 1 --1 从列表进入 2 其他地方查看进入  3 其他玩家数据
	self.m_select_oid = self.m_params.select_oid --进入后默认第一次选中的英雄
	self.m_apostle = self.m_params.apostle -- 是否是好友佣兵
	self.m_type = 1 --界面类型 (1 侠客列表界面 2侠客详情界面)
	self.m_open_tab_index = 1 --默认页签索引
	self.m_sel_tab_index = 0 --当前页签索引
	self.m_hero_list_type = 1 -- 1 英雄, 2图鉴
	self.m_select_index = 1
	self.m_select_meridian_index = 1
	self.sort_type = nil
	self.send_friend_item_num = 0 --缓存赠送的道具数量
	self.isPlayOverFriendLevelUpEft = true 	-- 是否播放完好感度提升特效
	self.friendLevelUpData = nil	-- 好感度提升详细数据
	self.m_is_quick_open_needed = self.m_params.is_quick_open_needed	--是否需要展示快速导航
	self.m_is_friend_up = false	--好感度是否升级
	self.m_sig_deep_max = self:get_sig_deep_max() --当前赛季开启的经脉轮数
	if self.m_mode == 3 then
		self.m_player_data = self.m_params.player_data
		self.m_selected_id = self.m_params.oid 
		self.other_team = self.m_params.team or false 
		local heros = self.m_player_data.heros or {}
		if table.existkey(heros, self.m_selected_id) == nil then
			heros = self.m_player_data.view_heros or {}
		end
		self.m_look_heros = heros
		self.m_curlist = table.keys(heros)
		self.hero_list = self.m_curlist
		self.check_sig = self.m_params.sig or false --查看其他玩家经脉数据
		self.m_type = 2
	else
		self.hero_list = self:filtrateHero(0)
		self:initSelectId()
		if self.m_select_oid then --好感跳转羁绊专用
			for i = 1, #self.hero_list do
				local temp_oid = self.hero_list[i]
				local temp_data, temp_cfg = self:getHero(temp_oid)
				if temp_oid == self.m_select_oid then
					self.m_selected_id = temp_oid
				end
			end
			self.m_type = 2
			self.m_open_tab_index = 4
			self.m_sel_tab_index = 4
			self:updateSigData()
		end
	end
	self:resetMeridianFirstOpenIndex()
	self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp)) 
	self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
	self.data_special = table.copy(RewardUtil:getProcessRewardData(tab_yueli))
	if table.nums(self.hero_list) == 0 then
		return
	end 
	self:updateSetFettersItems()
	self:detectionEqps()
	self:detectionAttrs()
	self:getHero_lv()
	self:updateResourceData()
	if self.m_mode == 3 then
		local h_data, h_cfg = self:getSelectHeroData()
		if h_data and h_data.sig  then
			self.check_sig = true
		end
	end
	-------------------- 符篆
	self.is_open_type = 1  --1装备 --2符篆
	--优化按钮逻辑
	self.m_equip_num = 0 --当前侠客准备安装数量
	self.is_talins_red = false
	self:initHerosData()
end

-- 设置 是否播放完好感度提升特效
function M:setIsPlayOverFriendLevelUpEft(isPlayOverFriendLevelUpEft)
	self.isPlayOverFriendLevelUpEft = isPlayOverFriendLevelUpEft
end

-- 设置好感度提升详细数据
function M:setFriendLevelUpData(friendLevelUpData)
	self.friendLevelUpData = friendLevelUpData
end

function M:refreshCheck()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		if self.m_race then
			self.hero_list = self:filtrateHero(self.m_race)
		else
			self.hero_list = self:filtrateHero(0)	
		end
		if h_data == nil then
			self:initSelectId()
		end
		for k,v in pairs(self.hero_list) do
			if v == self.m_selected_id then
				self.m_select_index = k
			end
		end
	end
end

function M:initSelectId()
	self.m_selected_id = self.m_params.select_id or self.hero_list[1] or "" --当前选中的英雄
	self.m_select_book_id = 0
	local l_list, z_list = self:getHeroTj()
	if table.nums(z_list) > 0 then
		self.m_select_book_id = z_list[1].id
	elseif table.nums(l_list) > 0 then 	
		self.m_select_book_id = l_list[2].id
	end
	self:updateSigData()
end

function M:updateResourceData()
	self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp)) 
	self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
	self.data_special = table.copy(RewardUtil:getProcessRewardData(tab_yueli))
end

function M:updateHeroInfo()
	self.m_cur_Lv = nil
	self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp)) 
	self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
	self.data_special = table.copy(RewardUtil:getProcessRewardData(tab_yueli))
	self:getHero_lv()
	self:updateSigData()
	self:detectionAttrs()
end

function M:switchHeroList(race)
	self.m_race = race or 0
	self.hero_list = self:filtrateHero(race)
	if next(self.hero_list) == nil then
		self.isNil = true
		return self.hero_list
	end
	local t_data, t_cfg = self:getHero(self.m_selected_id)
	if t_data and t_cfg then
		if race ~= 0 and t_cfg.race ~= race and table.nums(self.hero_list) > 0 then
			self.m_selected_id = self.hero_list[1]
			self.m_cur_Lv = nil
		end
	end
	self.isNil = false
	return self.hero_list
end

function M:getRightHero()
	if self.m_hero_list_type == 1 then 
		for i = 1, table.nums(self.hero_list) do
			if self.m_selected_id == self.hero_list[i] and i < table.nums(self.hero_list) then
				return self.hero_list[i+1],true
			end
		end
		return self.m_selected_id ,false
	else
		local l_list, z_list = self:getHeroTj()
		for i = 1, table.nums(z_list) do
			if self.m_select_book_id == z_list[i].id and i < table.nums(z_list)  then
				return z_list[i+1].id
			elseif self.m_select_book_id == z_list[i].id and i == table.nums(z_list) then
				return l_list[1].id
			end
		end
		for i = 1, table.nums(l_list) do
			if self.m_select_book_id == l_list[i].id and i < table.nums(l_list)  then
				return l_list[i+1].id
			end
		end
	end
	return self.m_select_book_id 
end

function M:getLeftHero()
	if self.m_hero_list_type == 1 then 
		for i = 1, table.nums(self.hero_list) do
			if self.m_selected_id == self.hero_list[i] and i ~= 1 then
				return self.hero_list[i-1],true
			end
		end
		return self.m_selected_id ,false
	else
		local l_list, z_list = self:getHeroTj()
		for i = 1, table.nums(l_list) do
			if self.m_select_book_id == l_list[i].id and i ~= 1 then
				return l_list[i-1].id
			elseif self.m_select_book_id == l_list[i].id and i == 1 then
				return z_list[table.nums(z_list)].id
			end
		end
		for i = 1, table.nums(z_list) do
			if self.m_select_book_id == z_list[i].id and i ~= 1 then
				return z_list[i-1].id
			end
		end
	end
	return self.m_select_book_id 
end

--过滤后的英雄列表
function M:filtrateHero(race_id)
	local hero_list = self:getAllHeroIds()
	if race_id == 0 then
		UserDataManager.hero_data:heroIdsSort(hero_list, "team")
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

function M:checkRaceMask()
	local new_tab = {}
	local hero_list = self:getAllHeroIds()
	local heros = {}
	for k,v in pairs(hero_list) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if new_tab[l_hero_cfg.race] == nil then
			new_tab[l_hero_cfg.race] = 0
		end
		new_tab[l_hero_cfg.race] = new_tab[l_hero_cfg.race]+1
	end
	return new_tab
end

function M:getAllHeroIds()
	local ids = table.copy(UserDataManager.hero_data:getHerosId()) 
	return ids
end

function M:getHero(id)
	local  data, cfg = UserDataManager.hero_data:getHeroDataById(id)
	return data, cfg
end

function M:getHeroCfg(id)
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
	return cfg
end

function M:getHeroDataByIndex(index)
	return self.hero_list[index]
end

function M:getHeroIndexByOid(oid)
	for k,v in pairs(self.hero_list) do
		if oid == v then
			return k
		end
	end
	return -1
end

--英雄图鉴数据
function M:getHeroTj()
    local book_tab = ConfigManager:getCfgByName("book")
	local z_list = {} --紫卡
	local l_list = {} --蓝卡
	for k,v in pairs(book_tab) do
		if v.unlock == 1 then
			if v.type == 2 then
				table.insert(z_list, {id = k, data = v})
			else
				table.insert(l_list, {id = k, data = v})
			end
		end
	end
	self:heroIdsSort(z_list)
	self:heroIdsSort(l_list)
    return l_list, z_list
end

--图鉴排序
function M:heroIdsSort(bks)
    local function sortFunc(id_one, id_two)
        local sequence1 = id_one.data.sequence
		local sequence2 = id_two.data.sequence
		local type_1 = id_one.data.sequence
		local type_2 = id_two.data.sequence
		if type_1 == type_2 then
			return sequence1 < sequence2
		else
			return type_1 < type_2
		end
    end
    table.sort(bks, sortFunc)
end

--当前选中英雄信息
function M:getSelectHeroData()
	if self.m_mode == 3 then --其他玩家的英雄
		local heros = self.m_look_heros or {}
		local data = heros[self.m_selected_id]
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
		--data.clv = data.lv
		return data, cfg
	else
		if self.m_hero_list_type == 1 then
			return self:getHero(self.m_selected_id)
		else	
			return self:getHeroCfg(self.m_select_book_id)
		end
	end
end


function M:switchHeroSkin(skinCfg)
	self.curSelectSkin = skinCfg
end

function M:getHeroBigAnim()
	local hero_data = nil
	local temp_cfg = nil
	if self.m_hero_list_type == 1 then
		hero_data, temp_cfg = self:getSelectHeroData()
	else	
		temp_cfg = self:getSelectHeroData()
	end
	if self.curSelectSkin ~= nil then
		return self.curSelectSkin.hero_spine
	end
	local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, temp_cfg)
	if shin_data_cfg and next(shin_data_cfg) then
		return shin_data_cfg.hero_spine
	elseif 	temp_cfg then
		return temp_cfg.hero_spine
	else
		return "hero_0003_SkeletonData"	
	end
end

function M:getSpinePos()
	local temp_cfg = nil
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		temp_cfg = h_cfg
	else	
		temp_cfg = self:getSelectHeroData()
	end
	if temp_cfg == nil then
		return Vector3(0,0,0)
	end
	local id = temp_cfg.id
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	local data_scale = hero_tab[id]["hero_scale"] or 1
	return data_pos, data_scale
end

function M:getPoetry()
	local temp_cfg = nil
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		temp_cfg = h_cfg
	else	
		temp_cfg = self:getSelectHeroData()
	end
	if temp_cfg then
		local poetry = string.gsub(Language:getTextByKey(temp_cfg.poetry), "\\n", "\n")
		local poe =  string.split(poetry,"\n")
		return poe
	end	
	return ""
end

--获取英雄装备列表 
function M:getHeroEquList()
	if self.m_hero_list_type == 1 then
		if self.isNil == true then
			return {}
		end
		local h_data, h_cfg = self:getSelectHeroData()
		return h_data.equips or {}
	end
	return {}
end

--获取英雄秘籍列表 
function M:getHeroMysticsList()
	if self.m_hero_list_type == 1 then
		if self.isNil == true then
			return {}
		end
		local h_data, h_cfg = self:getSelectHeroData()
		return h_data.mystics or {}
	end
	return {}
end

function M:getCurHeroCfg()
	local temp_cfg = nil
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		temp_cfg = h_cfg
	elseif self.m_hero_list_type == 2 then
		temp_cfg = self:getSelectHeroData()
	end
	return temp_cfg
end

--英雄升级客户端变化
function M:hero_lvUp(callback)
	local up_expend = GameUtil:getHeroUpGrade(self.m_cur_Lv)
    local need_exp = up_expend.exp
	local need_coin = up_expend.coin
	local need_special = up_expend.special_num 
	self.data_exp.user_num = self.data_exp.user_num - need_exp
	self.data_coin.user_num = self.data_coin.user_num - need_coin
	self.data_special.user_num = self.data_special.user_num - need_special
	self.m_cur_Lv = self.m_cur_Lv + 1
	if type(callback) == "function" then
		callback()
	end
end

--是否加锁
function M:getHeroLock()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		return h_data.lock
	end
	return false
end

function M:getHeroTypeDes()
	local temp_cfg = self:getCurHeroCfg()
	return temp_cfg.type_des01
end

--英雄种族
function M:getRace()
	local temp_cfg = nil
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		temp_cfg = h_cfg
	else	
		temp_cfg = self:getSelectHeroData()
	end
	if temp_cfg then
		return temp_cfg.race
	end
	return 0
end

--记录装备信息
function M:detectionEqps()
	if self.m_hero_list_type == 2 then
		return
	end
	local h_data, h_cfg = self:getSelectHeroData()
	self.last_eqps = table.copy(h_data.equips)
end

--是否开启神器功能
function M:checkArtifact()
	if self.m_mode == 3 then
		return self:checkHaveArtifact()
	else
		if self.m_hero_list_type == 1 then
			local flag, tips = BtnOpenUtil:isBtnOpen(32)
			return flag, tips	
		elseif 	self.m_hero_list_type == 2 then
			return false
		end
	end
end

function M:checkHaveArtifact()
	local h_data, h_cfg = self:getSelectHeroData()
	if h_data.artifact == nil or next(h_data.artifact) == nil then
		return false
	else
		return true	
	end	
end

function M:getArtifactData()
	if self.m_hero_list_type == 2 then
		return nil, nil
	end
	local h_data, h_cfg = self:getSelectHeroData()
	if h_data.artifact then
		local art_cfg = UserDataManager.artifact_data:getArtifactConfigByCid(h_data.artifact.id)
		return h_data.artifact, art_cfg
	end
	return nil, nil
end

function M:getHeroName()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		local skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(h_data, h_cfg)
		if skin_cfg and next(skin_cfg) then
			return Language:getTextByKey(skin_cfg.name)
		else
			return Language:getTextByKey(h_cfg.name)
		end
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		local skin_cfg = UserDataManager.hero_data:getHeroDefaultSkinCfgByHeroCfg( h_cfg)
		return Language:getTextByKey(skin_cfg.name)
	end
	return ""
end

function M:getHeroClassName()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		return Language:getTextByKey(h_cfg.class)
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		return Language:getTextByKey(h_cfg.class)
	end
	return ""
end

function M:checkHeroSP()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		return h_cfg.is_sp~=0
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		return h_cfg.is_sp~=0
	end
	return false
end

function M:getHero_SPInfo()
	local is_sp=false
	local sp_bg_name="sp_yaodao_bg"
	local h_data=nil
	local h_cfg=nil
	local sp_mul_lan_name=""
	local sp_efffect_name=""
	if self.m_hero_list_type == 1 then
		h_data, h_cfg = self:getSelectHeroData()
		is_sp=h_cfg.is_sp~=0
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		is_sp=h_cfg.is_sp~=0
	end
	if is_sp then
		local settingData=GlobalConfig.SP_TYPE_SETTING[h_cfg.is_sp]
		sp_bg_name=settingData.sp_bg_name
		sp_mul_lan_name=Language:getTextByKey(settingData.name)
		sp_efffect_name=settingData.sp_bg_effect_name
	end
	return is_sp,sp_bg_name,sp_mul_lan_name,sp_efffect_name
end

function M:getHeroAttackDes()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		return Language:getTextByKey(h_cfg.type_des03)
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		return Language:getTextByKey(h_cfg.type_des03)
	end
	return ""
end

--英雄品质
function M:getEvo()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		return h_data.evo
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		return h_cfg.max_evo
	end
	return 5
end

--英雄主属性
function M:getPro()
	if self.m_hero_list_type == 1 then
		local h_data, h_cfg = self:getSelectHeroData()
		return h_data.type
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		return h_cfg.type
	end
end

function M:checkEqpForId(index)
	local h_data, h_cfg = self:getSelectHeroData()
	local equips = h_data.equips or {}
	return equips[tostring(index)]
end

function M:checkMysticEqpForId(index)
	local mystics = self:getHeroMysticData()
	local mystic_data_id = mystics[tostring(index)]
	return mystic_data_id
end

function M:getHeroMysticData()
	local h_data, h_cfg = self:getSelectHeroData()
	local mystics = h_data.mystics or {}
	--for i, v in pairs(mystics) do
	--	v.owner = h_data.oid
	--end
	return mystics
end


function M:getMysticDataById(mystic_id)
	local mystic_data=nil
	if self.m_mode == 3 then
		mystic_data=self.m_player_data.user.mystics[tostring(mystic_id)]
		if mystic_data.star==nil then
			mystic_data.star=0
		end
	else
		mystic_data=UserDataManager.mystic_data:getMysticDataById(mystic_id)
	end
	return mystic_data
end

function M:getMysticGroup(mystic_Ids)
	local mysticsData=nil
	if self.m_mode == 3 then
		mysticsData=self.m_player_data.user.mystics
	end
	local _, activation_group  = UserDataManager.mystic_data:getMysticGroup(mystic_Ids,mysticsData)
	return activation_group
end

--格子数量
function M:getHeroGrideNum()
	local hero_list = UserDataManager.hero_data:getHerosId() 
    local vip = ConfigManager:getCfgByName("vip")
	local vip_lv = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local vip_item = vip[vip_lv] or {hero_limit = 0}
    local num = vip_item.hero_limit + UserDataManager.extra_hero_grid
    return #hero_list, num
end

--是否开启经脉
function M:checkExclusive(hero_data)
	if self.m_mode == 3 then--查看其他玩家数据
		if self.check_sig == true then
			return true
		end
		return false
	else
		local open_flag = BtnOpenUtil:isBtnOpen(147)
		if not open_flag then
			return false
		else
			open_flag = BtnOpenUtil:isBtnOpen(148)
			if not open_flag then
				return false
			end
		end
		local h_data = hero_data
		if hero_data == nil then
			h_data = self:getSelectHeroData()
		end
		local open_evo = ConfigManager:getMeridianOpenEvoByPos(1)
		if h_data and h_data.evo >= open_evo then
			return true
		else
			return false	
		end
	end
end

--是否其他英雄是否开启经脉
function M:checkExclusiveByHeroId(hero_id)
	local h_data, h_cfg = nil
	if self.m_hero_list_type == 1 then
		h_data, h_cfg = self:getHero(hero_id)
	end
	if (h_cfg and h_cfg.evo == 3) then
		return false
	end
	return self:checkExclusive(h_data)
end

function M:checkInitEvo()
	local h_data, h_cfg = self:getSelectHeroData()
	if self.m_mode == 3 and self.check_sig == false then
		return false
	end
	if h_cfg.evo == 3  then
		return false
	else
		return true	
	end
end

function M:getHero_lv()
	local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	if self.m_hero_list_type == 2 then
		return self:getMaxlv()
	end
	local h_data, h_cfg = self:getSelectHeroData()
	if h_data and h_data.clv > 0 then
		local upgrade_cfg = hero_upgrade[tonumber(h_data.clv )]
		if self.m_cur_Lv == nil then
			self.m_cur_Lv = upgrade_cfg.display_level or 1
		end
		return upgrade_cfg.display_level
	end
	if self.m_cur_Lv == nil then
		if h_data then
			self.m_cur_Lv = h_data.lv or 1
		else
			self.m_cur_Lv = 1
		end
	end
	local upgrade_cfg = hero_upgrade[tonumber(self.m_cur_Lv)] 
	if upgrade_cfg then
		return upgrade_cfg.display_level
	else
		return 1	
	end
end

function M:getCurNetLv()
	local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	local h_data, h_cfg = self:getSelectHeroData()
	if h_data then
		if h_data.clv > 0 then
			local upgrade_cfg = hero_upgrade[tonumber(h_data.clv )]
			return upgrade_cfg.display_level
		else
			local upgrade_cfg = hero_upgrade[tonumber(h_data.lv)]
			return upgrade_cfg.display_level
		end
	end
	return self:getHero_lv()
end

function M:getTrueHeroLv()
	if self.m_hero_list_type == 2 then
		return self:getMaxlv()
	end
	local h_data, h_cfg = self:getSelectHeroData()
	return h_data.lv
end

function M:getMaxlv()
	local data, cfg = self:getSelectHeroData()
	local tab_ = ConfigManager:getCfgByName("hero_evolution")
	local max_lv = tab_[cfg.max_evo]["level_max"]
	return max_lv
end

--当前属性
function M:getHeroAttrs()
	local hero_attr = {}
	local lv = self:getHero_lv() or 1
	if self.m_mode == 3 then--查看其他玩家数据
		local h_data, h_cfg = self:getSelectHeroData()
		local combat_lv = h_data.clv > h_data.lv  and h_data.clv or h_data.lv
		h_data.attrs = UserDataManager:computCfgAttrs(h_cfg, combat_lv, h_data.evo)
		hero_attr = UserDataManager:getHeroAttrsByData(h_data, h_cfg, nil, false, self.m_player_data)
	else
		if self.m_hero_list_type == 2 then --查看图鉴数据
			local max_lv = self:getHero_lv()
			local h_cfg = self:getSelectHeroData()
			hero_attr = UserDataManager:computCfgAttrs(h_cfg, max_lv, h_cfg.max_evo)
			for k,v in pairs(hero_attr) do
				hero_attr[k] = math.floor(v + 0.5)
			end
		else
			local h_data, h_cfg = self:getSelectHeroData()
			local combat_lv = 0
			if h_data.clv > 0 and h_data.clv > h_data.lv then
				combat_lv = h_data.clv
			else
				combat_lv = lv
			end
			h_data.attrs = UserDataManager:computCfgAttrs(h_cfg, combat_lv, h_data.evo)
			hero_attr = UserDataManager:getHeroAttrsByData(h_data, h_cfg, nil, true, nil, true)
		end
	end	
	local attrs = {}
	local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
	for k,v in pairs(hero_attar_tab) do
		if v.user_key  == "atk" or v.user_key  == "hp" or v.user_key  == "def" then
			if hero_attr[v.user_key] then
				attrs[v.user_key] = hero_attr[v.user_key]
			else
				attrs[v.user_key] = 0
			end
		end
	end
	return attrs
end

--记录上一次的属性
function M:detectionAttrs()
	self.last_attrs = {}
	self.last_lv = clone(self:getHero_lv()) 
	self.last_attrs = table.copy(self:getHeroAttrs()) 
	self.last_combat = self:getHero_Combat()
end

function M:checkCanLvUp(lv)
	local hero_data, hero_cfg = self:getHero(self.m_selected_id)
	for k,v in pairs(hero_cfg.skill) do
		local index=0
		for kk,vv in pairs(v) do
			index=index+1
			if vv[2] == lv +1 and index~=4 then
				return true
			end
		end
	end
	return false
end


--战力
function M:getHero_Combat()
	local lv = self:getHero_lv() or 1
	local comb = 0
	if self.m_mode == 3 then--查看其他玩家数据
		local heros = self.m_look_heros or {}
		local data = heros[self.m_selected_id]
		-- if data and data.combat then
		-- 	comb = data.combat
		-- else
			local h_data, h_cfg = self:getSelectHeroData()
			local combat_lv = h_data.clv > h_data.lv  and h_data.clv or h_data.lv
			h_data.attrs = UserDataManager:computCfgAttrs(h_cfg, combat_lv, h_data.evo)
			comb = UserDataManager:computeHeroCombat(h_data, h_cfg, false, self.m_player_data)
		-- end
	else
		if self.m_hero_list_type == 2 then --查看图鉴数据
			local max_lv = self:getHero_lv()
			local h_cfg = self:getSelectHeroData()
			local attr = UserDataManager:computCfgAttrs(h_cfg, max_lv, h_cfg.max_evo)
			comb = UserDataManager:computeAttrsCombat(attr)
		else
			local h_data, h_cfg = self:getSelectHeroData()
			local combat_lv = 0
			if h_data.clv > 0 and h_data.clv > h_data.lv then
				combat_lv = h_data.clv
			else
				combat_lv = lv
			end
			h_data.attrs = UserDataManager:computCfgAttrs(h_cfg, combat_lv, h_data.evo)
			comb = UserDataManager:computeHeroCombat(h_data, h_cfg,nil,nil,nil,true)
		end
	end	
	return math.floor(comb + 0.5)
end

--获取技能信息  
--params  is_awaken  登仙楼的tips，不考虑技能是否真的替换，都需要显示强化版技能
function M:getHeroSkill(is_awaken)  
	if self.m_hero_list_type == 2 then--图鉴数据
		local h_cfg = self:getSelectHeroData()
		return h_cfg.skill
	end
	local h_data, h_cfg = self:getSelectHeroData()
	local replace_skill = self:getCurSKill() --替换技能
	if replace_skill and next(replace_skill) then --说明此人登仙
		local skills = self:dealHeroSkill(replace_skill,h_cfg.skill,h_data,is_awaken)
		return skills
	end
	return h_cfg.skill
end

--获取目前可以突破的技能
function M:getCurBreakSkill()
	local skills = self:getHeroSkill()
	local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
	local meridians_cultivation_cfg_item=meridians_cultivation_cfg[self.sig_deep+1]
	local open_maxlv_skill_index=meridians_cultivation_cfg_item.open_maxlv_skill_index
	local skill=skills[open_maxlv_skill_index]
	return skill
end

function M:dealHeroSkill(awaken_skill,ori,h_data,is_awaken)
	local skill = table.copy(ori)
	local cfg_awaken_skill = "awaken_skill"
	local cfg_replace_skill = "replace_skill"
	local m_awaken_cfg = ConfigManager:getCfgByName("awaken")
	local cur_cfg = m_awaken_cfg[h_data.id]
	for i = 1,2 do  --策划的配置是两个可以替换的技能
		local cur_awaken_skill_cfg = cur_cfg[cfg_awaken_skill .. i]
		local cur_replace_skill_pos = cur_cfg[cfg_replace_skill .. i]
		local cur_awaken_skill = awaken_skill[tostring(cur_replace_skill_pos)]
		local show_flag
		if cur_awaken_skill then
			show_flag = cur_awaken_skill.replaced == 1 or is_awaken
		else
			show_flag = false
		end
		if cur_awaken_skill and show_flag then  --说明存在且替换了				
			local cur_skill_id =  cur_awaken_skill.skill_id
			local be_replace_skill_list,first_id,cur_level,replaced,awaken_god_cfg_id = self:getTargetSkillData(cur_skill_id,cur_awaken_skill_cfg)--替换后的组
			local select_id = 0
			for k,v in pairs(skill) do --循环去找对应的技能组
				for k1,v1 in pairs(v) do  --在技能组里配对  v1[1]  = skilld_id  v1[2] = unlock_lv
					if v1[1] == first_id then  --说明应该替换这个组
						select_id = k
					end
				end
			end
			local new_skill_list = {}
			if select_id ~= 0 and skill[select_id] then   --替换对应的组
				for k,v in ipairs(skill[select_id]) do
					table.insert(new_skill_list,{replaced[k],k > cur_level and awaken_god_cfg_id[k] or 1})
					--v[1] = be_replace_skill_list[k]
					--v[2] =
				end
			end	
			skill[select_id] = new_skill_list
		end
	end
	return skill
end

function M:chrckSkillLvByIndex(index)
	local skill_lv = 1
	local c_lv = self:getHero_lv()
	local skill_cfg = self:getHeroSkill()
	local skill_data = skill_cfg[index]
	for i = 1, #skill_data do
		if c_lv >= skill_data[i][2] then
			if i > 1 then
				skill_lv = i
			else
				skill_lv = 1
			end
		
		end
	end
	--4级时候经脉没解锁技能第4等级，强制显示为3等级
	if (not self:checkSkillLv4Unlock(index)) and skill_lv>3 then
		skill_lv=3
	end
	return skill_lv
end

--skillIndex 几号技能
--检测技能等级4是否解锁
function M:checkSkillLv4Unlock(skillIndex)
	local meridians_cultivation_cfg=ConfigManager:getCfgByName("meridians_cultivation")
	local index_cfg=nil
	local h_data, h_cfg = self:getSelectHeroData()
	for i, v in pairs(meridians_cultivation_cfg) do
		if v.open_maxlv_skill_index then
			if v.open_maxlv_skill_index==skillIndex then
				index_cfg=v
				index_cfg.id=i
			end
		end
	end

	local clv=self:getHero_lv()
	local sig_deep = self.sig_deep or 0
	local unlock=clv>=index_cfg.hero_lv_limit and sig_deep>=index_cfg.id
	return unlock
end

function M:checkMaxLv()
	if self.m_hero_list_type == 2 then
		return false
	end
	local m_tv = ConfigManager:getCfgByName("hero_evolution")
	local h_data, h_cfg = self:getSelectHeroData()
	local cur_evo = m_tv[h_data.evo]
	if self.m_cur_Lv >= cur_evo.level_max then
		return true
	end
	return false
end

--英雄限定的最大等级
function M:checkMaxEvo()
	local h_data, h_cfg = self:getSelectHeroData()
	if h_data and h_cfg then
		return h_data.evo == h_cfg.max_evo
	end
	return false
end

function M:checkCanLevelUp()
	local up_expend = GameUtil:getHeroUpGrade(self.m_cur_Lv)
	local next_expend = GameUtil:getHeroUpGrade(self.m_cur_Lv + 1)
	if up_expend["coin"] > self.data_coin.user_num then
		return false, 1
	end
	if up_expend["exp"] > self.data_exp.user_num then
		return false, 2
	end
	if up_expend["special_num"] > self.data_special.user_num then
		return false, 3
	end
	if next_expend["team_level"] > self:getLowLvFoFour() then
		local count = next_expend["team_level"];
		return false, 4, count
	end
	return true
end

--获取英雄最低等级
function M:checkLowestLv()
	local tab = UserDataManager.hero_data:getLevelTop()
	if next(tab) == nil then
		return 300
	end
	if #tab < 5 then
		return 0
	end
	local min_lv = tab[1][2]
	for k,v in pairs(tab) do
		if min_lv > v[2] then
			min_lv =  v[2]
		end
	end
	return min_lv
end

--自身以外等级最大的4张卡 的最低
function M:getLowLvFoFour()
	local tab = table.copy(UserDataManager.hero_data:getLevelTop()) 
	if next(tab) == nil then
		return 300
	end
	if #tab < 5 then
		return 0
	end
	local index = -1
	for i,v in pairs(tab) do
		if v[1] == self.m_selected_id then --排除可能存在的自己
			table.remove(tab,i)
			break
		end
	end
	table.sort(tab, function(data1, data2)
		return data1[2] > data2[2]
	end)
	return tab[4][2]
end


function M:updateSigData()
	if self.m_hero_list_type == 2 then
		return
	end
	self.sig_cfg = self:getCurMeridianData()
	local h_data, h_cfg = self:getSelectHeroData()
	local sig_data
	local mystic_type = ConfigManager:getMysticTypeByPos(self.m_select_meridian_index)
	if self.m_mode == 3 then -- 其它玩家
		local sig = h_data.sig or {}
		sig_data = sig[tostring(mystic_type)]
	else
		if h_data then
			local sig = h_data.sig or {}
			sig_data = sig[tostring(mystic_type)]
		end
	end
	if sig_data then
		if sig_data.lv then
			self.sig_lv = sig_data.lv
			self.sig_deep = sig_data.deep or 0
			self.sig_active = true
		else
			self.sig_lv = 0
			self.sig_deep = 0
			self.sig_active = false
		end
	else
		self.sig_lv = -1
		self.sig_deep = 0
		self.sig_active = false
	end
	
	local max_len = table.nums(self.sig_cfg.level_up) - 1 
	if self.sig_lv < max_len then
		self.sig_nextdata = self.sig_cfg.level_up[self.sig_lv + 1]
	else
		self.sig_nextdata = self.sig_cfg.level_up[self.sig_lv]	
	end
	self:initCurHeroSigCanBreak()

	--一键突破花费
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep)
	local lower_level = meridians_cultivation_cfg_item.lower_level or 10 -- 当前阶段的最高等级
	local data_special = RewardUtil:getProcessRewardData(self.sig_nextdata.levelup_cost[1]).user_num
	local sig_onedata = 0
	for i = self.sig_lv + 1, lower_level do
		if self.sig_cfg.level_up[i] then
			local cost = self.sig_cfg.level_up[i].levelup_cost
			sig_onedata = sig_onedata + cost[1][3]
			if sig_onedata <= data_special then
				self.sig_onedata = sig_onedata
				self.sig_one_maxlv = i
			elseif i == self.sig_lv + 1 then
				self.sig_onedata = sig_onedata
			end
		end
	end
end

-- 经脉数据
function M:getSigDataByType(sig_type)
	local h_data, h_cfg = self:getSelectHeroData()
	local sig
	local sig_data
	if self.m_mode == 3 then -- 其它玩家
		sig = h_data.sig or {}
	else
		if h_data then
			sig = h_data.sig or {}
		end
	end
	if sig then
		sig_data = sig[tostring(sig_type)]
	end
	return sig_data
end

-- 经脉是否可以重置
function M:getSigCanReset()
	local h_data, h_cfg = self:getSelectHeroData()
	local sig = h_data.sig or {}
	local flag = false
	for k, v in pairs(sig) do
		local lv = v.lv or 0
		if lv > -1 then
			flag = true
			break
		end
	end
	return flag
end

--当前阶段经脉数据
function M:getCurMeridianData()
	local mystic_type = ConfigManager:getMysticTypeByPos(self.m_select_meridian_index)
	local mer_tab = ConfigManager:getCfgByName("equip_heroes")
	local cur_hero_data = nil
	local temp_cfg = self:getCurHeroCfg()
	if 	temp_cfg then
		cur_hero_data = mer_tab[temp_cfg.equip_heroes_id]
	end
	if cur_hero_data == nil then

		cur_hero_data = mer_tab[1]
	end
	return cur_hero_data[mystic_type] or {}
end

--根据个位index获取穴位数据
function M:getPassNameByIndex(index)
	local id = math.min(self.sig_deep, GlobalConfig.HERO_SIG_DEEP_MAX - 1) * 10 + index
	if self.sig_cfg.level_up[id] then
		return self.sig_cfg.level_up[id]
	else
		return self.sig_cfg.level_up[30]	
	end
end

--根据获取当前进度
function M:getPassNumByIndex()
	if self:checkMaxSig() then
		return 11
	end
	local index = self.sig_lv
	return index%10 + 1
end

function M:getMeridianAttrs()
	local all_attrs = {[901] = 0, [902] = 0, [903] = 0, [904] = 0, [905] = 0, [906] = 0, [908] = 0, [909] = 0, [915] = 0, [918] = 0}
	local h_data, h_cfg = self:getSelectHeroData()
	local e_attrs =  UserDataManager:getEquipHeroesAttrs(h_data, h_cfg) -- 经脉加成
	UserDataManager:appendCfgAttrs(e_attrs, all_attrs)
	local mystics = self:getHeroMysticData()
	local mystics_data = UserDataManager.mystic_data:getMysticesData()
	local hero_data
	local inlay_mystic 
	if self.m_look_heros then
		hero_data = self.m_look_heros[self.m_selected_id]
		inlay_mystic = self.m_player_data.inlay_mystic
		mystics_data=self.m_player_data.user.mystics
	end
	if hero_data==nil then
		hero_data=UserDataManager.hero_data:getHeroDataById(self.m_selected_id)
	end
	local m_attrs = UserDataManager:getMysticsAttrs(mystics, mystics_data,hero_data,inlay_mystic) -- 秘籍加成
	UserDataManager:appendCfgAttrs(m_attrs, all_attrs)
	local base_attrs = h_data.attrs
	local new_all_attrs = UserDataManager:getAddHeroAttrs(all_attrs, base_attrs)
	local cfg_attrs = {}
	for k,v in pairs(new_all_attrs) do
		local attr_id = GameUtil:getAttrsId(k)
		table.insert(cfg_attrs, {attr_id,v})
	end
	table.sort(cfg_attrs, function(data1, data2)
		return data1[1] < data2[1]
	end)
	return cfg_attrs
end

--是否达到最大等级
function M:checkMaxSig()
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep)
	local next_meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep+1)
	-- if next_meridians_cultivation_cfg_item then --检测下一阶段的赛季开启条件
	-- 	local season = UserDataManager:getCurSeason()
	-- 	if next_meridians_cultivation_cfg_item.season_unlock > season then --未到达下一阶段的开启赛季
	-- 		return true
	-- 	end
	-- end
	local lower_level = meridians_cultivation_cfg_item.lower_level or 10
	if self.sig_lv >= lower_level then
		return true
	end
	return false
end

--经脉是否可以到达下一阶段
function M:checkSigCanBreach()
	if self.sig_deep >= GlobalConfig.HERO_SIG_DEEP_MAX then
		return false
	end
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep+1)
	if meridians_cultivation_cfg_item then
		local season = UserDataManager:getCurSeason()
		return season >= meridians_cultivation_cfg_item.season_unlock
	end
	return false
end

function M:getSigMeridiansCultivationCfg(sig_deep)
	--local sig_deep=GlobalConfig.SLOTPOS_SIGDEEP[slotPos]
	sig_deep = math.min(sig_deep or 0, GlobalConfig.HERO_SIG_DEEP_MAX)
	local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
	local meridians_cultivation_cfg_item = meridians_cultivation_cfg[sig_deep] or meridians_cultivation_cfg[4] or {}
	return meridians_cultivation_cfg_item
end


function M:initCurHeroSigCanBreak()
	local h_data, h_cfg = self:getSelectHeroData()
	local sig = h_data.sig or {}
	local max_lv_num = 0
	self.lock_season = 0
	self.unlock3 = 0
	for i = 1, GlobalConfig.HERO_SIG_NUM do
		local sig_data = sig[tostring(i)]
		if sig_data then
			local sig_deep = sig_data.deep or 0
			if sig_deep < GlobalConfig.HERO_SIG_DEEP_MAX then
				local sig_lv = sig_data.lv or 0
				local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(sig_deep)
				local next_meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(sig_deep + 1)
				if next_meridians_cultivation_cfg_item then
					self.lock_season = next_meridians_cultivation_cfg_item.season_unlock
					self.unlock3 = next_meridians_cultivation_cfg_item.unlock_condition_param3 or 0
				end
				local lower_level = meridians_cultivation_cfg_item.lower_level or 10 -- 当前阶段的最高等级
				if sig_lv == lower_level then
					max_lv_num = max_lv_num + 1
				end
			end
		end
	end
	local cur_season = UserDataManager:getCurSeason()
	local cur_stage = UserDataManager:getCurStage()
	self.sig_can_break = (max_lv_num == GlobalConfig.HERO_SIG_NUM) and ((cur_season >= self.lock_season) or (self.unlock3 > 0 and cur_stage >= self.unlock3))

	local next_meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep + 1)
	if next_meridians_cultivation_cfg_item  then
		local hero_lv=self:getHero_lv()
		if next_meridians_cultivation_cfg_item.open_maxlv_skill_index~=0 and next_meridians_cultivation_cfg_item.open_maxlv_skill_index~=nil then
			if next_meridians_cultivation_cfg_item.hero_lv_limit>hero_lv then
				self.sig_can_break=false
			end
		end
	end
end

--可突破时突破的是不是技能
function M:Skill4CanBreak()
	if self.sig_can_break then
		local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
		local next_meridians_cultivation_cfg_item = meridians_cultivation_cfg[self.sig_deep + 1] or meridians_cultivation_cfg[4]
		if next_meridians_cultivation_cfg_item  then
			if next_meridians_cultivation_cfg_item.open_maxlv_skill_index~=0 then
				return true
			end
		end
	end
	return false
end

function M:GetCanBreakSlotType()
	if self.sig_can_break then
		local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
		local next_meridians_cultivation_cfg_item = meridians_cultivation_cfg[self.sig_deep+1] or meridians_cultivation_cfg[4]
		local slot_pos=next_meridians_cultivation_cfg_item.open_mystic_slot
		local common_cfg=ConfigManager:getCfgByName("common")
		return common_cfg[831].value[slot_pos]
	end
end

function M:getCurHeroSigCanBreak()
	return self.sig_can_break or false
end

function M:getShowHeroSigBreakCfg()
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep + 1)
	return meridians_cultivation_cfg_item or {}
end

--修正经脉境界显示问题，改为：空--小周天--大周天--圆满--化境
function M:getShowHeroSigBreakCfgNew()
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep)
	return meridians_cultivation_cfg_item or {}
end

function M:getCurHeroSigBreakCost()
	local meridians_cultivation_cfg_item = self:getShowHeroSigBreakCfg()
	return meridians_cultivation_cfg_item.cost or {}
end

function M:meridanCanLevelUp()
	local tab = self:getCurMeridianData()
	local h_data, h_cfg = self:getSelectHeroData()
	local eqp_levelup = tab["level_up"]
	local level_cfg = eqp_levelup[self.sig_lv + 1]
	if level_cfg == nil then
		return false, Language:getTextByKey("new_str_0279")
	end
	if level_cfg.unlock_rank and level_cfg.unlock_rank > 0 then
		if h_data.evo > level_cfg.unlock_rank then
			return false, Language:getTextByKey("new_str_0512") 
		else
			return false, Language:getTextByKey("new_str_0513") 	
		end
	else
		return true	
	end
end

-- 秘籍是否开启
function M:meridanOpenFlagByPos(pos)
	local h_data, h_cfg = self:getSelectHeroData()
	local open_order = h_cfg.open_order or {}
	local open_order_pos = -1
	for k,v in ipairs(open_order) do
		if v == pos then
			open_order_pos = k
			break
		end
	end
	local open_evo = ConfigManager:getMeridianOpenEvoByPos(open_order_pos)
	if h_data.evo >= open_evo then
		return true, Language:getTextByKey("new_str_0512")
	else
		local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[open_evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
		return false, Language:getTextByKey("new_str_0749", Language:getTextByKey(quality_item.name))
	end
end

-- 秘籍位置是否开启
function M:meridanPosOpenFlagByPos(pos)
	local need_sig_deep=GlobalConfig.SLOTPOS_SIGDEEP[pos]
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(need_sig_deep)
	if math.min(self.sig_deep, GlobalConfig.HERO_SIG_DEEP_MAX) >= need_sig_deep then
		return true, Language:getTextByKey("new_str_0512")
	else
		return false, Language:getTextByKey("mystic_str_0060", meridians_cultivation_cfg_item.lv_name)
	end
end

-- 秘籍第一个开启的位置
function M:resetMeridianFirstOpenIndex()
	local h_data, h_cfg = self:getSelectHeroData()
	local open_order = h_cfg.open_order or {}
	local first_open_index = nil
	for k,v in ipairs(open_order) do
		local open_evo = ConfigManager:getMeridianOpenEvoByPos(k)
		if h_data.evo >= open_evo then
			if first_open_index then
				first_open_index = math.min(first_open_index, v)
			else
				first_open_index = v
			end
		end
	end
	self.m_select_meridian_index = first_open_index or 1
end

function M:getBaseInfoCellByIndex(index)
	local temp_cfg = self:getCurHeroCfg()
	if temp_cfg then
		if index == 1 then
			return "anecdote_sex", temp_cfg.sex
		elseif index == 2 then
			return "anecdote_height", temp_cfg.height
		elseif index == 3 then
			return "anecdote_age", temp_cfg.age
		elseif index == 4 then
			return "anecdote_birthday", temp_cfg.birthday
		elseif index == 5 then
			return "anecdote_potential", temp_cfg.potential
		elseif index == 6 then
			return "anecdote_nature", temp_cfg.nature
		elseif index == 7 then
			return "anecdote_like", temp_cfg.like
		elseif index == 8 then
			return "anecdote_hate", temp_cfg.hate
		elseif index == 9 then
			return "anecdote_interest", temp_cfg.interest
		elseif index == 10 then
			return "anecdote_characteristic", temp_cfg.characteristic
		end
	end
	return "", nil
end

function M:getAncedoteDescByIndex(index)
	local legend = "legend"..index
	local temp_cfg = self:getCurHeroCfg()
	return Language:getTextByKey(temp_cfg["legend"][index])
end

function M:getAncedotName(index)
	if index == 1 then
		return "anecdote_2"
	elseif index == 2 then
		return "anecdote_3"
	elseif index == 3 then
		return "anecdote_4"
	elseif index == 4 then
		return "anecdote_5"
	elseif index == 5 then
		return "anecdote_6"
	end
end

function M:getAncedoteSkillByIndex(index)
	local temp_cfg = self:getCurHeroCfg()
	return temp_cfg["legend_skill"][index]
end

--检测传记开启条件
function M:checkAncedoteOpenByIndex(index)
	if self.m_hero_list_type == 2 then
		local book_cfg = UserDataManager:getHeroMaxEvo(self.m_select_book_id)
		if book_cfg ~= nil then
			local h_cfg =self:getCurHeroCfg()
			local evo = book_cfg.max_evo
			if evo >= h_cfg.evo + index then
				return true
			else
				return false
			end
		end
		return false
	end
	local h_data, h_cfg = self:getSelectHeroData()
	if h_data then
		local cfg_hero = UserDataManager:getCfgHero()
		local evo = h_data.evo
		if cfg_hero[tostring(h_cfg.id)] ~= nil then
			evo = cfg_hero[tostring(h_cfg.id)]["max_evo"] or evo
		end
		if evo >= h_cfg.evo + index then
			return true
		else
			return false	
		end
	else
		return false	
	end
end

function M:getSKillImprove()
	local temp_cfg = self:getCurHeroCfg()
	return UserDataManager.skillImprove_data.m_skillImprove[temp_cfg.id]
end

function M:checkHaveHero(id)
	return  UserDataManager.hero_data:checkHeroCollect(id)
end

function M:checkRedPoint()
	local bl = false
	if self.m_hero_list_type == 2 then
		bl = UserDataManager.hero_data:checkHeroCollectPoint(self.m_select_book_id)
	end
	return bl
end

--游戏内英雄的最大等级
function M:checkEvoMax()
	local hero_evo_tab = ConfigManager:getCfgByName("hero_evolution")
	local hero_max_cfg = hero_evo_tab[#hero_evo_tab]
	return self.m_cur_Lv >= hero_max_cfg.level_max
end

function M:checkHeroUnlock(id)
	return 	UserDataManager.hero_data:checkHeroCollectPoint(id)
end

function M:checkTjPoint()
	return 	UserDataManager.hero_data:checkHeroRedPoint()
end

--当前英雄是否在共鸣水晶中
function M:inCrystal()
	local crystal_tab = UserDataManager.hero_data:getCrystalAllHerosId()
	local lv5_tab = UserDataManager.hero_data:getLevelTop()
	if crystal_tab[self.m_selected_id] == 1 then
		for kk,vv in pairs(lv5_tab) do
			if self.m_selected_id == vv[1] then
				return false
			end
		end
		return true
	end
	return false
end

function M:getCurMoveX(num, max_h)
	local rate = num/640
	local n_num = (max_h/2)*rate
	return n_num
end

function M:subName()
	local plyType = nil
	local cfg = self:getCurHeroCfg()
	local name_path = string.split(cfg.prefab,"/")
	plyType = name_path[1]
	return plyType
end

function M:getTalkSe()
	local dialogue_tab = self:getHeroFetterBank() 
	local all_num = 3 + #dialogue_tab
	local ran_dom = math.random(1, all_num)
	if ran_dom > #dialogue_tab then
		local lines_data = self:getCurLines()
		if lines_data then
			return lines_data.se_id
		end
	else
		local se_id = self:getHeroFeetersDialogue(dialogue_tab[ran_dom])
		return se_id
	end
	return ""
end

--获得声音bank
function M:getCurHeroBank()
	local lines_data = self:getCurLines()
	if lines_data then
		return lines_data.bank
	end
	return nil
end

--好感解锁声音
function M:getHeroFetterBank()
	local friend_data = self:getFettersData()
	local h_data, h_cfg = self:getSelectHeroData()
	local fetters_tab = ConfigManager:getCfgByName("hero_fetters")
	local cur_hero = fetters_tab[h_cfg.id]
	local dialogue_tab = {}
	for i = 1, friend_data.lv do
		if cur_hero and cur_hero[i] then
			if #cur_hero[i].dialogue > 0 then
				table.insert(dialogue_tab, tonumber(cur_hero[i].dialogue))
			end
		end
	end
	return dialogue_tab
end

function M:getHeroFeetersDialogue(id)
	local fetters_tab = ConfigManager:getCfgByName("random_disposition")
	if fetters_tab[id] then
		local cur_fetter = fetters_tab[id]
		return cur_fetter.se_id
	end
	return 
end

function M:getCurLines()
	local cfg = self:getCurHeroCfg()
	if cfg == nil then
		return nil
	end
	local h_data, h_cfg = self:getSelectHeroData()
	local talk = ConfigManager:getCfgByName("random_lines")
	if h_data and h_data.skin then
		for k,v in pairs(talk) do
			if h_data.skin == v.skin and v.type == 3 then
				return v
			end
		end
	else
		local cur_skin = h_cfg.skin[1]
		for k,v in pairs(talk) do
			if cur_skin == v.skin and v.type == 3 then
				return v
			end
		end
	end
	for k,v in pairs(talk) do
		if cfg.id == v.hero_detail_id and v.type == 3 then
			return v
		end
	end
	return nil
end

function M:getFetterNode()
	local hero_friend = ConfigManager:getCfgByName("hero_friend")
	local c_id = 0
	if self.m_hero_list_type == 1 then 
		local h_data, h_cfg = self:getSelectHeroData()
		c_id = h_cfg.id
	elseif self.m_hero_list_type == 2 then
		local h_cfg = self:getSelectHeroData()
		c_id = h_cfg.id
	end
	local cur_fetter_tab = {}
	if self.m_mode ~= 3 then
		if hero_friend then
			for k,v in pairs(hero_friend) do
				if c_id == v.main_hero then
					v.id = k
					table.insert(cur_fetter_tab, v)
				end
			end
		end
	end
	return cur_fetter_tab
end
--刷新缓存好感道具
function M:updateSetFettersItems()
	self.t_fetter_data = self:getFettersData()
	self.fetters_items = self:getFettersItems()
	self.oneLevelGiftData = self:getFettersItems(1) or {}
end

--获取当前英雄可用的好感道具表
function M:getFettersItems(friendLevel)
	local h_data, h_cfg = self:getSelectHeroData()
	local favorite_gift = h_cfg.favorite_gift or {}
	if not friendLevel then
		local fetter_data = self:getFettersData()
		friendLevel = fetter_data.lv
	end
	local items = UserDataManager.item_data:getItemsTabBySubType(favorite_gift, friendLevel)
	self.t_fetter_data = self:getFettersData()
	local function sortFunc(id_one, id_two)
        local data1, cfg1 = UserDataManager.item_data:getItemDataById(id_one)
        local data2, cfg2 = UserDataManager.item_data:getItemDataById(id_two)
		local deg_num1 = self:checkItemEffectDeg(cfg1) --是否递减
		local deg_num2 = self:checkItemEffectDeg(cfg2)
		local hv1 = data1.num > 0 and 0 or 1
		local hv2 = data2.num > 0 and 0 or 1
		if hv1 == hv2 then 
			if deg_num1 == deg_num2 then 
				if deg_num1 == 1 then 
					if cfg1.quality == cfg2.quality then
						return tonumber(id_one) > tonumber(id_two)
					else
						return cfg1.quality < cfg2.quality
					end
				else
					if cfg1.quality == cfg2.quality then
						return tonumber(id_one) > tonumber(id_two)
					else
						return cfg1.quality > cfg2.quality
					end
				end
			else
				return deg_num1 > deg_num2
			end
		else
			return hv1 < hv2	
		end
    end
    table.sort(items, sortFunc)
	return items
end

--检测好感道具数值是否有递减 1没有递减 0有递减
function M:checkItemEffectDeg(item_cfg)
	local tab = {}
	for k,v in pairs(item_cfg.effect) do
		table.insert(tab, {lv = v[1], num =v[2]})
	end
	local init_num = tab[1].num or 0
	local cur_num =  0
	for k,v in pairs(item_cfg.effect) do
		if v[1] == self.t_fetter_data.lv then
			cur_num = v[2]
		end
	end
	if init_num == cur_num then
		return 1
	else
		return 0	
	end
end

--当前英雄好感信息
function M:getFettersData()
	local h_data, h_cfg = self:getSelectHeroData()
	local data = UserDataManager.m_friendliness[tostring(h_cfg.id)] or {point=0,lv=0}
	return data
end

function M:getFetterEqpMaxNum()
	local data = self:getFettersData()
	local cfg = self:getCurHeroCfg()
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[cfg.role_type or 1]
		if fet_tab then
			if data.lv +1 < #fet_tab then
				return fet_tab[data.lv +1]
			else
				return fet_tab[#fet_tab]	
			end
		end
	end
	return nil
end

function M:getFetterEqp()
	local data = self:getFettersData()
	local cfg = self:getCurHeroCfg()
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[cfg.role_type or 1]
		return fet_tab[data.lv]
	end
	return nil
end

function M:getFetterTab(data)
	local new_tab = {}
	if data.level > #data.level_buff then
		data.level = #data.level_buff
	end
	for k = 1 , data.level do
		local pro = data.level_buff[k][1]
		local p_key = GameUtil:getAttrsKey(pro[1])
		local p_name = GameUtil:getAttrsName(p_key)
		local enum_cfg = GameUtil:getAttrCfg(pro[1])
		local des_count = nil
		local des_lv = nil
		local com_cfg = ConfigManager:getCommonValueById(293)
		if k == 1 then
			des_count = Language:getTextByKey("hero_ui_str_0017")
		else
			if com_cfg[k] then
				des_lv = com_cfg[k]
			else
				des_count = ""
			end
		end
		if GameUtil:attrTransition(enum_cfg.user_key) == true then
			if enum_cfg.user_key == "critrate" then
				local params = {
					num = p_name.." +"..GameUtil:formatNum(pro[2]).."%",
					act_num = p_name.."<Color=#FFFFFF> +"..GameUtil:formatNum(pro[2]).."%</Color>",
					des = des_count,
					des_lv = des_lv
				}
				table.insert( new_tab, params)
			else
				local params = {
					num = p_name.." +"..GameUtil:formatNum(pro[2]*100).."%",
					act_num = p_name.."<Color=#FFFFFF> +"..GameUtil:formatNum(pro[2]*100).."%</Color>" ,
					des = des_count,
					des_lv = des_lv
				}
				table.insert( new_tab, params)
			end
		else
			local params = {
				num =  p_name.." +"..pro[2],
				act_num = p_name.."<Color=#FFFFFF> +"..pro[2].."</Color>",
				des = des_count,
				des_lv = des_lv
			}
			table.insert(new_tab, params)
		end
	end
	return new_tab
end

--计算羁绊级别
function M:checkFetterLv(id)
	for i,v in pairs(UserDataManager.active_links) do
		if id == tonumber(i) then
			return v
		end
	end
	return 0
end


function M:getFeeterProByLv(id, lv)
	if lv == 0 then
		return "anecdote_no_select"
	end
	local hero_friend = ConfigManager:getCfgByName("hero_friend")
	local feeter_data = hero_friend[id]
	local level_buff = feeter_data.level_buff[lv]
	if level_buff == nil then
		level_buff =  feeter_data.level_buff[#feeter_data.level_buff]
	end
	local pro = level_buff[1] or 0
	local p_key = GameUtil:getAttrsKey(pro[1])
	local p_name = GameUtil:getAttrsName(p_key)
	local enum_cfg = GameUtil:getAttrCfg(pro[1])
	if GameUtil:attrTransition(enum_cfg.user_key) == true then
		if enum_cfg.user_key == "critrate" then
			return p_name.." +"..GameUtil:formatNum(pro[2]).."%"
		end
		return p_name.." +"..GameUtil:formatNum(pro[2]*100).."%"
	else
		return p_name.." +"..pro[2]
	end
end

function M:checkFetterCanRevd()
	local tab = self:getFetterNode()
	local can_rcvd = UserDataManager.can_rcvd
	for k,v in pairs(tab) do
		if can_rcvd[tostring(v.id)] then
			return true
		end
	end
	return false
end

--检查是否可以快速升级
function M:checkCanQuickLevelUp()
	return self:checkQuick()
end

function M:checkQuick()
	local min_lv = self:getLowLvFoFour()
	local evo_lv = self:getCurEvoMaxlv() --品质直升等级
	local team_lv = self:getHeroUpgradeData(min_lv) --队伍直升等级上限--根据其他四张卡牌判断
	local q_lv_tab = table.copy(ConfigManager:getCommonValueById(339)) 
	table.insert(q_lv_tab, evo_lv)
	if team_lv > 0 then
		table.insert(q_lv_tab, team_lv)
	else
		if self.m_cur_Lv >= 80 then
			return false
		end
	end
	local upperLv = math.min(team_lv, evo_lv)
	local remove_t = {}
	for i,v in pairs(q_lv_tab) do
		if self.m_cur_Lv >= v then
			remove_t[v] = true 
		elseif v > upperLv then
			remove_t[v] = true 
		end
	end
	for i = #q_lv_tab, 1, -1 do
		if remove_t[q_lv_tab[i]] then
			table.remove(q_lv_tab, i)
		end
	end
	if next(q_lv_tab) == nil then
		return false
	end
	local can_lv_list = self:checkCanQuickUpLv(q_lv_tab)
	table.sort(can_lv_list, function(data1, data2)
		return data1 > data2
	end)
	if #can_lv_list > 0 then
		return true, can_lv_list[1]
	end
	return false
end

function M:checkCanQuickUpLv(list)
	local remove_t = {}
	for k,v in pairs(list) do
		local cost_items = self:checkUpgradeNum(v)
		if next(cost_items) ~= nil and self.data_exp.user_num >= cost_items.exp and self.data_coin.user_num >= cost_items.coin and self.data_special.user_num >= cost_items.special_num then
		
		else
			remove_t[v] = true 	
		end
	end
	local q_lv_tab = list
	for i = #q_lv_tab, 1, -1 do
		if remove_t[q_lv_tab[i]] then
			table.remove(q_lv_tab, i)
		end
	end
	return q_lv_tab
end



function M:getCurEvoMaxlv()
	local data, cfg = self:getSelectHeroData()
	local tab_ = ConfigManager:getCfgByName("hero_evolution")
	local max_lv = tab_[data.evo]["level_max"]
	return max_lv
end


function M:getHeroUpgradeData(lv)
	local hero_upgrade = ConfigManager:getCommonValueById(340) or {}
	for i,v in pairs(hero_upgrade) do
		local data = hero_upgrade[i]
		local next_data = hero_upgrade[i+1]
		if i < #hero_upgrade then
			if lv >= data[1] and lv < next_data[1] then
				return data[2]
			end
		elseif i == #hero_upgrade and lv >= data[1] then
			return data[2]
		end
	end
	return 0
end


function M:checkUpgradeNum(next_lv)
	local up_expend = GameUtil:getHeroUpGrade(next_lv-1, self.m_cur_Lv)
	--local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	local cost_items = {}
	if self.m_cur_Lv > next_lv then
		return cost_items
	end
	return up_expend
end

--检查英雄是否可以升级
function M:checkCanLvTrue(oid, lv)
	local hero_data , hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if hero_data then
		local up_expend = GameUtil:getHeroUpGrade(lv-1, hero_data.lv)
		local data_exp = RewardUtil:getProcessRewardData(tab_exp)
		local data_coin = RewardUtil:getProcessRewardData(tab_money)
		local data_special = RewardUtil:getProcessRewardData(tab_yueli)
		if next(up_expend) ~= nil and data_exp.user_num >= up_expend.exp and data_coin.user_num >= up_expend.coin and data_special.user_num >= up_expend.special_num then
			return true
		else
			return false		
		end
	else
		return false	
	end
	return false
end

function M:getHeroSkinData()
	local hero_skins = UserDataManager:getHeroSkins()
	local hero_data, hero_cfg = self:getSelectHeroData()
	local cur_skin = hero_data.skin or 0
	local skin = hero_cfg.skin or {}
	local show_data = {}
	local select_index = 1
	for i, v in ipairs(skin) do
		local skin_cfg = ConfigManager:getHeroSkinCfg(v)
		local select_flag = cur_skin == v
		if cur_skin == 0 then
			select_flag = i == 1
		end
		if select_flag then
			select_index = i
		end
		table.insert(show_data, {id = v, cfg = skin_cfg, own_flag = i == 1 or hero_skins[tostring(v)] ~= nil, select_flag = select_flag})
	end
	return show_data, select_index
end

function M:getHeroSkinBtnShow()
	local flag = false
	if self.m_mode ~= 3 then
		local _, hero_cfg = self:getSelectHeroData()
		local skin = hero_cfg.skin or {}
		flag = #skin > 1
	end
	return flag
end

function M:getMeridianAttrTipsStr(cell_data, index)
	local previous_pass_data = self:getPassNameByIndex(index - 1)
	local previous_attr = previous_pass_data.attr or {}
	local attr = cell_data.attr or {}
	return self:getAttrTipsStr(attr, previous_attr)
end

function M:getMeridiansCultivationAttrTipsStr()
	local sig_deep = math.min(self.sig_deep, GlobalConfig.HERO_SIG_DEEP_MAX - 1)
	local previous_meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(sig_deep)
	local previous_attr = previous_meridians_cultivation_cfg_item.attr or {}
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(sig_deep + 1)
	local attr = meridians_cultivation_cfg_item.attr or {}
	return self:getAttrTipsStr(attr, previous_attr)
end

function M:getAttrTipsStr(attr, previous_attr)
	local tips_str = ""
	for k,v in ipairs(attr) do
		local attr_name = GameUtil:getAttrsName(GameUtil:getAttrsKey(v[1]))
		local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
		local hero_enumeration_item = hero_enumeration[v[1]]
		local previous_attr_value = 0
		for k1,v1 in ipairs(previous_attr) do
			if v1[1] == v[1] then
				previous_attr_value = v1[2] or 0
				break
			end
		end
		local add_attr_value = v[2] - previous_attr_value
		local hh = "\n" --换行符
		if k == 1 then
			hh = ""
		end
		if add_attr_value > 0 then
			if hero_enumeration_item.is_percent ~= 0 then
				local attr_value = add_attr_value * 100
				attr_value = math.floor(attr_value*10 + 0.5)/10
				tips_str = tips_str..hh.. attr_name .. "+" .. GameUtil:formatNum(attr_value).."%"
			else
				local attr_value = add_attr_value
				attr_value = math.floor(attr_value + 0.5)
				tips_str = tips_str ..hh .. attr_name .. "+" .. GameUtil:formatNum(attr_value)
			end
		end
	end
	return tips_str
end

--检测经脉突破限制
function M:checkIntensifyLimit()
	local meridians_cultivation_cfg_item = self:getSigMeridiansCultivationCfg(self.sig_deep+1)
	local h_data, h_cfg = self:getSelectHeroData()
	if h_data.evo >= meridians_cultivation_cfg_item.limit then
		return true
	else
		local com_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[meridians_cultivation_cfg_item.limit]
		return false, Language:getTextByKey(com_data.name) 
	end
end

function M:checkHeroEquips()
	local h_data, h_cfg = self:getSelectHeroData()
	if next(h_data.equips) == nil then
		return false
	end 
	return true
end

function M:updateRefreshHeroListType(bl)
	if bl == true then
		if self.m_type == 2 then
			self.refresh_hero_list = bl
		end
	else
		self.refresh_hero_list = bl
	end
end

--根据英雄获取好感道具列表
function M:getFriendShipList()
	local fetters_item_cfg = ConfigManager:getCfgByName("fetters_item")
	for k,v in pairs(fetters_item_cfg) do

	end
	return {}
end

--是否显示好感
function M:checkOpenFriendShip()
	local _, hero_cfg = self:getSelectHeroData()
	if hero_cfg.evo == 3 then
		return false
	else
		return true	
	end
end


--好感达到最高等级
function M:checkFriendMaxLv()
	local friend_data = self:getFettersData()
	local cfg = self:getCurHeroCfg()
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[cfg.role_type or 1]
		if fet_tab then
			if friend_data.lv >= #fet_tab then
				return true
			end
		end
	end
	return false
end

--是否开启好感 
function M:checkOpenFriend()
	local h_data, h_cfg = self:getSelectHeroData()
	local astrict_evo = ConfigManager:getCommonValueById(465,3)
	return h_data.evo >= astrict_evo
end

function M:getOpenFriendFetterLv()
	local astrict_evo = ConfigManager:getCommonValueById(465,3)
	local cur_qualiey_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[astrict_evo]
	return Language:getTextByKey(cur_qualiey_data.name)
end

--英雄喜欢的物品类型
function M:getHeroLickTypeStr()
	local h_data, h_cfg = self:getSelectHeroData()
	local sub_type_name = ""
	for i = 1,#h_cfg.favorite_gift do
		local rew_id = h_cfg.favorite_gift[i]
		if i > 1 then
			sub_type_name = sub_type_name.."、"..Language:getTextByKey('tid#haoganleixingname_'..rew_id)	
		else
			sub_type_name = sub_type_name ..Language:getTextByKey('tid#haoganleixingname_'..rew_id)	
		end
	end
	return Language:getTextByKey("hero_ui_str_0037", sub_type_name)
end

--一键赠送道具筛选
function M:getAllGiftData()
	if not self.fetters_items then
		return {}
	end
	local fetter_data = self:getFettersData()
	local lv_cfg = self:getFetterEqpMaxNum()
	local curExp = fetter_data.point
	local needExp = lv_cfg.upgrade - curExp
	-- 是否足够升一级
	local isCanLevelUp = false
	if needExp <= 0 then
		-- 老号处理，需要经验如果是负数(-1)，说明是老号的积攒经验
		isCanLevelUp = true
		return {}, -1, isCanLevelUp
	end
	local fetterLv = fetter_data.lv
	local canSendItemList = {}
	local cansendItemCount= 0
	for _, itemId in pairs(self.fetters_items) do
		local item_data, item_cfg = UserDataManager.item_data:getItemDataById(itemId)
		if item_data.num > 0 then
			-- 可赠送道具数量，
			cansendItemCount = cansendItemCount + 1
			if needExp <= 0 then
				break
			end
			local itemExp = 0
			local needCount = 0
			for _, eftInfoData in pairs(item_cfg.effect) do
				if eftInfoData[1] == fetterLv then
					itemExp = eftInfoData[2]
				end
			end
			if itemExp > 0 then
				needCount = math.ceil(needExp / itemExp)
				if item_data.num < needCount then
					needCount = item_data.num
					needExp = needExp - itemExp * needCount
				else
					isCanLevelUp = true
					needExp = 0
				end
				table.insert(canSendItemList, {
					item_data = item_data,
					item_cfg = item_cfg,
					needCount = needCount,
					itemId = itemId,
				})
			end
		end
	end
	return canSendItemList, needExp, isCanLevelUp
end

function M:getMaxFriendShipLvBySeason()
	local max_level = ConfigManager:getCommonValueById(533, 999)
	local cur_season = UserDataManager:getCurSeason()
	local friend_ship_cfg = ConfigManager:getCommonValueById(636, {})
	local min_season, max_season = 0
	if #friend_ship_cfg > 0 then
		max_season = friend_ship_cfg[#friend_ship_cfg][1]
		min_season = friend_ship_cfg[1][1]
	else
		return max_level
	end
	if cur_season < min_season then
		return max_level
	elseif cur_season >= max_season then
		return friend_ship_cfg[#friend_ship_cfg][3]
	end
	for i = 1, #friend_ship_cfg do
		local friend_ship_tab = friend_ship_cfg[i]
		local need_season = friend_ship_tab[1]
		if cur_season == need_season then
			max_level = friend_ship_tab[3]
			break
		end
	end
	return max_level

end
-- 获取好感度展示属性相关参数(用于UI展示)
function M:getHeroAttrsData()
	local _, h_cfg = self:getSelectHeroData()
	local fetter_data = self:getFettersData()
	local fetterData = {}
	local curHeroFriendLevel = 0
	if h_cfg then
		local hero_id = h_cfg.id
		local new_data = UserDataManager.m_friendliness[tostring(hero_id)]
		local m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
		local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
		if fetters_level_tab then
			local fet_tab = fetters_level_tab[m_hero_cfg.role_type or 1]
			-- 好感度不为0
			if fetter_data.lv > 0 then
				curHeroFriendLevel = fetter_data.lv
				-- 是否最后一个好感度等级
				if (new_data.lv >= #fet_tab) then
					for _, itemData in pairs(fet_tab[#fet_tab].Meridian_attr) do
						local key = GameUtil:getAttrsKey(itemData[1])
						local name = GameUtil:getAttrsName(key)
						table.insert(fetterData, {
							attrsName = name,
							curNum = itemData[2],
							lastNum = itemData[2],
							attrKeyId = itemData[1],
							attrKey = key,
							isNotChange = true,
							-- 未格式化的当前值（老号处理，好感度提升详细展示界面用）
							curAttrNumber = itemData[2],
							-- 当前attr的纯数字值，无百分数（老号处理，好感度提升详细展示界面用）
							attrValue = -1,
						})
					end
				else
					local tempList = {}
					for _, itemData in pairs(fet_tab[new_data.lv].Meridian_attr) do
						tempList[itemData[1]] = itemData
					end
					for _, itemData in pairs(fet_tab[new_data.lv + 1].Meridian_attr) do
						local attrId = itemData[1]
						local attrKey = GameUtil:getAttrsKey(attrId)
						local name = GameUtil:getAttrsName(attrKey)
						local curAttrData = tempList[attrId]
						local isExistCurAttr = (curAttrData ~= nil)
						local curNum = isExistCurAttr and curAttrData[2] or 0
						local lastNum = itemData[2]
						table.insert(fetterData, {
							attrsName = name,
							curNum = curNum,
							lastNum = lastNum,
							attrKeyId = attrId,
							attrKey = attrKey,
							isNotChange = (curNum == lastNum),
							-- 未格式化的当前值（老号处理，好感度提升详细展示界面用）
							curAttrNumber = curNum,
							-- 当前attr的纯数字值，无百分数（老号处理，好感度提升详细展示界面用）
							attrValue = -1,
						})
					end
				end
			else
				for _, itemData in pairs(fet_tab[1].Meridian_attr) do
					local attrId = itemData[1]
					local attrKey = GameUtil:getAttrsKey(attrId)
					local name = GameUtil:getAttrsName(attrKey)
					table.insert(fetterData, {
						attrsName = name,
						curNum = 0,
						lastNum = itemData[2],
						attrKeyId = attrId,
						attrKey = attrKey,
						isNotChange = false,
						-- 未格式化的当前值（老号处理，好感度提升详细展示界面用）
						curAttrNumber = 0,
						-- 当前attr的纯数字值，无百分数（老号处理，好感度提升详细展示界面用）
						attrValue = -1,
					})
				end
			end
		end
	end

	-- 侠客好感度是否最大等级
	local maxLevel = self:getMaxFriendShipLvBySeason() 
	local isMaxLevel = curHeroFriendLevel >= maxLevel
	-- 通过百分比获取对应值
	local last_attrs = table.copy(self:getHeroAttrs())
	local temp_attrs = {}
	local xlsxHeroEnumeration = ConfigManager:getCfgByName("hero_enumeration")
	for _, itemData in pairs(fetterData) do
		-- 当前值，可能是百分比
		local giftData = xlsxHeroEnumeration[itemData.attrKeyId]
		local lastTempValue = self:friendLikeValueFormat(itemData.attrKey, itemData.lastNum)
		local curTempValue = self:friendLikeValueFormat(itemData.attrKey, itemData.curNum)
		if giftData.base_on_id > 0 then
			-- 计算百分比类显示准确值的显示值，例：  生命：1% >> 2%(20)
			local tempKey = GameUtil:getAttrsKey(giftData.base_on_id)
			if last_attrs[tempKey] then
				local curNum = itemData.curNum
				local attrValue = last_attrs[tempKey]
				local lastAddAttrValue = (curNum > 0) and (attrValue / (1 + curNum)) * itemData.lastNum or (attrValue * itemData.lastNum)
				lastAddAttrValue = math.floor(lastAddAttrValue)
				itemData.lastNum = lastTempValue .. "("..lastAddAttrValue..")"
				if isMaxLevel then
					local curAddAttrValue = (curNum > 0) and (attrValue / (1 + curNum)) * itemData.curNum or (attrValue * itemData.curNum)
					curAddAttrValue = math.floor(curAddAttrValue)
					--curAddAttrValue = self:friendLikeValueFormat(itemData.attrKey, curAddAttrValue)
					itemData.curNum = curTempValue .. "("..curAddAttrValue..")"
				else
					itemData.curNum = curTempValue
				end
				itemData.attrValue = attrValue
			else
				itemData.lastNum = lastTempValue
				itemData.curNum = curTempValue
			end
		else
			itemData.lastNum = lastTempValue
			itemData.curNum = curTempValue
		end
	end

	table.sort(fetterData, function(itemData1, itemData2)
		local curAttrId1 = itemData1.attrKeyId
		local curAttrId2 = itemData2.attrKeyId
		local base_on_id1 = xlsxHeroEnumeration[curAttrId1].base_on_id
		local base_on_id2 = xlsxHeroEnumeration[curAttrId2].base_on_id
		curAttrId1 = base_on_id1 > 0 and base_on_id1 or curAttrId1
		curAttrId2 = base_on_id2 > 0 and base_on_id2 or curAttrId2
		if curAttrId1 ~= curAttrId2 then
			return curAttrId1 < curAttrId2
		end
	end)
	return fetterData
end

-- 好感度属性格式化
function M:friendLikeValueFormat(attrKey, num)
	if num <= 0 then
		return tostring(num)
	end
	if GameUtil:canPerAttrTransition(attrKey) == true then
		num = GameUtil:formatNum(num * 100)
	end
	if GameUtil:attrTransition(attrKey) == true then
		return tostring(num).."%"
	end
	return tostring(num)
end

function M:IsLink()
	if self.m_mode == 3 then
		return false
	end
	-- local _, h_cfg = self:getSelectHeroData()
	-- if h_cfg.islink == 1 or h_cfg.id > 700 then
	-- 	return true
	-- else
	-- 	return false	
	-- end
	return false
end

--是否需要显示职业等级
function M:showRoleType()
	if self.m_mode == 3 then
		local data, cfg = self:getSelectHeroData()
		if data.book and next(data.book) ~= nil then
			local role_level = data.book.lv or 0
			return role_level >= 1
		end
		return false	
	end
	local roleUpGradeLv = ConfigManager:getCommonValueById(602,0)  -- 图鉴升级开启等级
	local role_level = UserDataManager.hero_data:getHeroRoleLevelById(self.m_selected_id) -- 职业等级
	return role_level >= 1
end


-- 获取职业等级配置信息
function M:getHeroRoleCfg()
	local heroRoleCfg = {}
	local role_level = 0
	local data, cfg = self:getSelectHeroData()
	local cur_season = UserDataManager:getCurSeason() -- 当前赛季
	if self.m_mode == 3 then 
		if data.book and next(data.book) ~= nil then
			role_level = data.book.lv or 0
		end
	else
		role_level = UserDataManager.hero_data:getHeroRoleLevelById(self.m_selected_id) -- 职业等级
	end
	if role_level > 0 and cfg then
		local role_type = cfg.role_type or 0
		if role_type ~= 0 then
			local herorole = ConfigManager:getCfgByName("herorole")
			local heroRoleItem = herorole[role_type] or {}
			local seasonHeroRoleCfg = heroRoleItem[role_level] or {}
			if seasonHeroRoleCfg.season and seasonHeroRoleCfg.season <= cur_season then -- 根据赛季取配置
				heroRoleCfg = seasonHeroRoleCfg
			end
		end
	end
	return heroRoleCfg
end

--经脉免费重置使用的次数
function M:getUseFreeNum()
	return UserDataManager.m_sig_reset_times or 0
end

--获取免费次数总量
function M:getAllFreeNum()
	return ConfigManager:getCommonValueById(601,30)
end

--是否还有免费次数
function M:HavFreeNum()
	return self:getUseFreeNum() < self:getAllFreeNum()
end

--秘籍槽位是否显示
function M:meridianShowByID(index)
	local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
	if meridians_cultivation_cfg[index] == nil then
		return false
	end
	local open_flag = false
	local cur_mer_cfg = meridians_cultivation_cfg[index] or meridians_cultivation_cfg[0]
	local season_num = UserDataManager:getCurSeason()
	if cur_mer_cfg.season_unlock and season_num >= cur_mer_cfg.season_unlock then
		open_flag = true
	end
	
	--超前开启条件
	if open_flag == false then
		if cur_mer_cfg.unlock_condition_param3 and cur_mer_cfg.unlock_condition_param3 > 0 then
			local cur_stage = UserDataManager:getCurStage()
			if cur_stage >= cur_mer_cfg.unlock_condition_param3 then
				open_flag = true
			end
		end
	end
	
	return open_flag
end

--秘籍槽位限制秘籍类型
function M:meridianShowTypeByID(index)
	--index=GlobalConfig.SLOTPOS_SIGDEEP[index]
	--local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
	--local meridians_cfg = meridians_cultivation_cfg[index]
	--if meridians_cfg == nil then
	--	return 0
	--end
	--if meridians_cfg.mystic_type and #meridians_cfg.mystic_type > 1 then
	--	return 0
	--elseif meridians_cfg.mystic_type and #meridians_cfg.mystic_type == 1 then
	--	return meridians_cfg.mystic_type[1] -- 1 先天  2 绝技
	--end
	--return 0
	local common_cfg=ConfigManager:getCfgByName("common")
	local common_cfg_item=common_cfg[831]
	return common_cfg_item.value[index]
end

--根据类型获取秘籍列表
function M:getMysticByType(m_type)
	if m_type == nil or m_type == 0 then
		return UserDataManager.mystic_data:getMysticesId()
	else
		local m_type_ids = {}
		local ids = UserDataManager.mystic_data:getMysticesId()
		for k,v in pairs(ids) do
			local data, cfg = UserDataManager.mystic_data:getMysticDataById(v)
			if cfg.type == m_type then
				table.insert( m_type_ids, v)
			end
		end
		return m_type_ids
	end
	return {}
end

--获取是否开启天命化星
function M:getFatesInfo(oid)
	local fates_tabel = UserDataManager:getFatesInfo()
	for i, v in pairs(fates_tabel) do
		for hero_i, hero_v in pairs(v.heros) do
			if hero_v == oid then
				return i, true
			end
		end
	end
	return 0,false
end

--通过星辰id获取天命化星星辰信息
function M:getFateByStarId(star_id)
	local fate_star = ConfigManager:getCfgByName("fate_star")
	return fate_star[tonumber(star_id)]
end

--通过英雄id获取星辰信息
function M:getFatesByHeroId(hero_id)
	local fate_star = ConfigManager:getCfgByName("fate_star")
	for i, v in pairs(fate_star) do
		for hero_i, hero_v in ipairs(v.hero_group) do
			if hero_id == hero_v then
				return v,tostring(i)
			end
		end
	end
	return { },0
end

--获取星辰开启英雄数量
function M:getStarStartNum(star_id)
	local fates_tabel = UserDataManager:getFatesInfo()
	for i, v in pairs(fates_tabel) do
		if i == star_id then
			return v
		end
	end
	return {}
end

--获取英雄天命页签是否开启
function M:getHeroStarBtnShow()
	local flag = false
	local server_unlock_season = 0
	local season_data = UserDataManager.m_season_data or {}
	if season_data and next(season_data) and season_data.season then
		server_unlock_season = season_data.season
	end
	if self.m_mode ~= 3 then
		local hero_data, hero_cfg = self:getSelectHeroData()
		local fate_open = self:getFateIsOpen(hero_cfg.id) --赛季
		--flag = hero_data.evo >= 24 and fate_open == 1 and BtnOpenUtil:isBtnOpen(256)
		flag = server_unlock_season >= fate_open and BtnOpenUtil:isBtnOpen(256) --修改天命页签开启条件，去掉英雄等级限制
	end
	return flag
end

--获取天命信息
function M:getFateCommonData(hero_id)
	local poetry_data = ConfigManager:getCfgByName("fate_common")
	if poetry_data ~= nil then
		for i, v in pairs(poetry_data) do
			if i == hero_id then
				return v
			end
		end
	end
	return { }
end

--获取英雄是否开启天命
function M:getFateIsOpen(hero_id)
	local fate_data = self:getFateCommonData(hero_id)
	local fate_open = fate_data.fate_open or 999
	return fate_open
end

--刷新领悟天命数量
function M:getFateNum(fate_data)
	local num = 0
	for i, v in pairs(fate_data) do
		num = num + 1
	end
	return num
end

--获取技能信息
function M:getFateSkillData()
	local _, hero_cfg = self:getSelectHeroData()
	local fate_skill = ConfigManager:getCfgByName("fate_skill")
	return fate_skill[hero_cfg.id] or {}
end

--获取加成属性
function M:setAdditionData(star_id,add_base,hero_oid)
	local star_start_num = self:getStarStartNum(star_id)
	local hp_value,atk_value,def_value = 0,0,0
	local light_num = self:getFateNum(star_start_num.heros or {})
	local current_add_base = add_base[light_num] * 0.01
	local data, cfg = UserDataManager.hero_data:getHeroDataById(hero_oid)
	local fate_build_hp_add, fate_build_atk_add, fate_build_def_add = self:getFateBuildAddAttr()
	hp_value = data.attrs.hp * (current_add_base + fate_build_hp_add) 
	atk_value = data.attrs.atk * (current_add_base + fate_build_atk_add)
	def_value = data.attrs.def * (current_add_base + fate_build_def_add)
	return math.floor(hp_value + 0.5),math.floor(atk_value + 0.5),math.floor(def_value + 0.5)
end

function M:getFateBuildAddAttr()
	local building_data = UserDataManager.m_fate_building
	local cur_floor = building_data.lv or 0
	local cur_cfg = ConfigManager:getCfgByName("fate_building") or {}
	local add_attr = cur_cfg[cur_floor] and cur_cfg[cur_floor].attr or {}
	local hp_add = add_attr[1] and add_attr[1][2] or 0
	local atk_add = add_attr[2] and add_attr[2][2] or 0
	local def_add = add_attr[3] and add_attr[3][2] or 0
	return hp_add, atk_add, def_add
end

--获取天命技能边框
function M:getFateSkillIconName(star_id)
	local fate_star = ConfigManager:getCfgByName("fate_star")
	return fate_star[tonumber(star_id)].fate_skill_icon
end

--经脉轮数
function M:get_sig_deep_max()
	local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
	local lun_num = 0
	local season = UserDataManager:getCurSeason()
	local cur_stage = UserDataManager:getCurStage()
	for k,v in pairs(meridians_cultivation_cfg) do
		local unlock3 = v.unlock_condition_param3 or 0
		if k > 0 and ((v.season_unlock and season >= v.season_unlock) or (unlock3 > 0 and cur_stage >= unlock3)) then
			lun_num = lun_num + 1
		end
	end
	return lun_num
end

-------------------------------符篆
--获取英雄符篆列表 
function M:getHeroTalinsManList()
	--if self.m_hero_list_type == 1 then
	--	if self.isNil == true then
	--		return {}
	--	end
		local h_data, h_cfg = self:getSelectHeroData()
		return h_data.seal_character or {}
	--end
	--return {}
end

function M:checkTalisForId(index)
	local h_data, h_cfg = self:getSelectHeroData()
	local seal_data = h_data.seal_character or {}
	return seal_data[tostring(index)]
end

function M:getTalisSuitConfigByCid(cid)
	local talis_detail = ConfigManager:getCfgByName("seal_character_suit")
	return talis_detail[cid]
end

function M:getTalisConfigByCid(cid)
	local talis_detail = ConfigManager:getCfgByName("seal_character_team")
	return talis_detail[cid]
end


--获取共鸣效果 
function M:getHeroTalinsEfeectNum(pos)
	local curNum = 0
	local allNum = 4
	local cfg = ConfigManager:getCfgByName("seal_character_suit")
	local data = self:getCurrentTalinsDataByPos(pos)
	if not data then return curNum,allNum end 
	local team_id = cfg[data.id].team
	local quaily_id = cfg[data.id].quality
	local talinsData = self:getHeroTalinsManList()
	for k,v in pairs(talinsData) do
		local t_id = cfg[v.id].team
		local q_id = cfg[v.id].quality
		if t_id == team_id and quaily_id == q_id then
			curNum = curNum + 1
		end
	end
	return curNum,allNum
end

function M:getCurrentTalinsDataByPos(index)
	local h_data, h_cfg = self:getSelectHeroData()
	local equips = h_data.seal_character or {}
	return equips[tostring(index)]
end

function M:getTalisData()
	return UserDataManager.talis_data:getTalisData() or {}
end

function M:IsTalinsRedPoint(data)
	local flag = false
	local talins_data = self:getTalisData()
	local cfg = ConfigManager:getCfgByName("seal_character_suit")
	local data_team_id = cfg[data.id].team or 0
	local data_quaily = cfg[data.id].quality or 0 
	for k,v in pairs(talins_data) do 
		local team_id = cfg[v.id].team
		local quaily = cfg[v.id].quality
		if team_id == data_team_id then
			if data_quaily < quaily then
				flag = true
			end
		end
	end
	return flag
end
--判断登仙的状态
function M:dealState()
	self:initHerosData()
	self.m_current_mode = 0
	local data,_ = self:getHero(self.m_selected_id)
	if data and next(data) then
		local id = data.id
		if self.m_god_god_heros[tostring(id)] then
			self.m_current_mode = 2
		elseif self.m_fly_heros[tostring(id)] then
			self.m_current_mode = 1
		end
	end
	return self.m_current_mode
end

function M:initHerosData()
	local awakensystemdata = self.m_mode == 3 and self.m_player_data.awaken or UserDataManager:getmAwakenSystemData()
	self.m_god_god_heros = awakensystemdata.god_heros or {}
	self.m_fly_heros = awakensystemdata.fly_heros or {}
	self.m_replace_skill = awakensystemdata.skills or {}
end

function M:getCurSKill()
	local data1, cfg = self:getSelectHeroData(self.m_selected_id)
	local cur_skill = self.m_replace_skill[tostring(data1.id)]  --当前侠客的技能
	return cur_skill or {}
end

--根据skill的id  来找到去替换了谁   替换   被替换 需要的登仙level
function M:getTargetSkillData(skill_id,replace_skill)
	local be_replaced = {}
	local awaken_god_cfg_id = {}
	local replaced = {}
	local first_id = replace_skill[1][2]
	local cur_level = 1 
	for k,v in ipairs(replace_skill) do
		table.insert(be_replaced,v[2])
		table.insert(replaced,v[1])
		table.insert(awaken_god_cfg_id,v[3])
		if skill_id == v[1] then
			cur_level = k
		end
	end
	return be_replaced,first_id,cur_level,replaced,awaken_god_cfg_id
end

function M:getHeroid()
	local data1, cfg = self:getSelectHeroData()
	return data1.id
end

--共鸣相关
--返回属性加成,技能配置
function M:getEchoParams()
	local hero, cfg = self:getSelectHeroData()
	--共鸣配置
	local echo_cfg = ConfigManager:getCfgByName("hero_resonance")
	local hero_echo_cfg = echo_cfg[hero.id]
	if hero_echo_cfg == nil then
		Logger.logError(" 没有共鸣配置 " .. hero.id )
		return nil, nil
	end
	local level_cfg = nil
	if hero.resonance_lv == nil or hero.resonance_lv <= 0 then
		local index = 1
		--local index = #hero_echo_cfg --0时返回最大一级的配置
		level_cfg = hero_echo_cfg[index]
	else
		level_cfg = hero_echo_cfg[hero.resonance_lv] --当前共鸣等级的对应配置
	end
	--共鸣技能配置
	local skill_cfg = ConfigManager:getCfgByName("resonance_skill")
	local hero_skill_cfg = skill_cfg[hero.id]
	if hero_skill_cfg == nil then
		Logger.logError(" 没有共鸣技能配置 " .. hero.id )
		return level_cfg.attr, nil
	end
	local skills = {}
	for k, v in pairs(hero_echo_cfg) do
		if v.skill and #v.skill > 0 then
			local idx = v.skill[1]
			local name_text = hero_skill_cfg.name[idx]
			local des_text = hero_skill_cfg.des[idx]
			local icon_img = hero_skill_cfg.icon[idx]
			table.insert(skills, {index = idx, lv = k, name = name_text, des = des_text, icon = icon_img})
		end
	end

	return level_cfg.attr, skills
end

--更新所有侠客战力
function M:updateHeroesCombat()
	for k, v in pairs(self.hero_list) do
		local hero, hero_cfg = self:getHero(v)
		local combat = UserDataManager:computeHeroCombat(hero, hero_cfg)
		hero.combat = combat
	end
end

return M
