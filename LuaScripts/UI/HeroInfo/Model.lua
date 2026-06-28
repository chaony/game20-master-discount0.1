local M = class("HeroInfoModel", LikeOO.OODataBase)

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘

function M:onCreate()
	M.super.onCreate(self)
	self.m_look_model = self.m_params.look_model or 0
	self.m_model_type = self.m_params.model_type or 0  -- 1.佣兵
	self.m_pro = self.m_params.pro or 0 --当前筛选类型
	self.m_race = self.m_params.race or 0 --当前筛选类型
	self.talk_interval = 8
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	if self.m_look_model == 1 then--查看其他玩家数据
		self.m_player_data = self.m_params.player_data
		self.m_heroid = self.m_params.oid
		local heros = self.m_player_data.heros or {}
		if table.existkey(heros, self.m_heroid) == nil then
			heros = self.m_player_data.view_heros or {}
		end
		self.m_look_heros = heros
		self.m_curlist = table.keys(heros)
	elseif self.m_look_model == 2 then--查看图鉴信息
		self.tj_id = self.m_params.tj_data
		self.m_show_new = self.m_params.show_new
		self.m_curlist = self:getHeroTj()
		self.tj_cfg = self:getTestHeroInfo()
		self.tj_hero_data = self:getHeroCfgByCid(self.tj_cfg.id)
	elseif self.m_look_model == 3 then--专属装备强化列表进入 
		self.m_heroid = self.m_params.oid
		self.m_curlist = RedPointUtil:checkExclusiveWeaponLvUp()
		UserDataManager.hero_data:heroIdsSort(self.m_curlist, "lv")
	else
		self.m_heroid = self.m_params.oid
		self.m_curlist = self:getHeroList()
	end
	self:getHeroData()
	self:detectionAttrs()
	self:detectionEqps()
	self:getHeroAttrs()
	--客户端缓存升级使用（暂不做它用）
	if self.m_herodata then
		self.m_cur_Lv = self.m_herodata.lv or 1
	else
		self.m_cur_Lv = 1	
	end
	self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp)) 
	self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
	self.data_special = table.copy(RewardUtil:getProcessRewardData(tab_yueli))
end

function M:refreshMoneyNum()
	self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp)) 
	self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
	self.data_special = table.copy(RewardUtil:getProcessRewardData(tab_yueli))
end

function M:updateSigData()
	self.sig_cfg = self:getCurMeridianData()
	if self.m_herodata then
		self.sig_lv = self.m_herodata.sig.lv or 0
		if next(self.m_herodata.sig) == nil then
			self.sig_active = false
		else
			self.sig_active = true
		end
	else
		self.sig_lv = 0
		self.sig_active = false
	end
	self.sig_data = self.sig_cfg.level_up[self.sig_lv]
	if self.sig_lv < # self.sig_cfg.level_up then
		self.sig_nextdata = self.sig_cfg.level_up[self.sig_lv + 1]
	else
		self.sig_nextdata = self.sig_cfg.level_up[self.sig_lv]	
	end
	
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

function M:updateMoney()
	self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp)) 
	self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
	self.data_special = table.copy(RewardUtil:getProcessRewardData(tab_yueli))
end

--刷新
function M:refreshData()
	self:getHeroData()
end

--是否加锁
function M:getHeroLock()
	return self.m_herodata.lock
end

function M:getHeroAttrs()
	local hero_attr = {}
	local lv = self:getHero_lv() or 1
	if self.m_look_model == 1 then--查看其他玩家数据
		self.m_herodata.attrs = UserDataManager:computCfgAttrs(self.herocfg, lv, self.m_herodata.evo)
		hero_attr = UserDataManager:getHeroAttrsByData(self.m_herodata, self.herocfg, nil, false, self.m_player_data)
	elseif self.m_look_model == 2 then --查看图鉴数据
		local max_lv = self:getHero_lv()
		hero_attr = UserDataManager:computCfgAttrs(self.tj_hero_data, max_lv,self.tj_hero_data.max_evo)
		for k,v in pairs(hero_attr) do
			hero_attr[k] = math.floor(v + 0.5)
	    end
	else
		self.m_herodata.attrs = UserDataManager:computCfgAttrs(self.herocfg, lv, self.m_herodata.evo)
		hero_attr = UserDataManager:getHeroAttrsByData(self.m_herodata, self.herocfg)
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


function M:getMaxlv()
	local tab_ = ConfigManager:getCfgByName("hero_evolution")
	local max_lv = tab_[self.herocfg.max_evo]["level_max"]
	return max_lv
end

function M:getHero_lv()
	local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	if self.m_look_model == 2 then
		return self:getMaxlv()
	end
	if self.m_herodata.clv > 0 then
		local upgrade_cfg = hero_upgrade[tonumber(self.m_herodata.clv )]
		return upgrade_cfg.display_level
	end
	if self.m_cur_Lv == nil then
		self.m_cur_Lv = 1
	end
	local upgrade_cfg = hero_upgrade[tonumber(self.m_cur_Lv)]
	return upgrade_cfg.display_level
end

function M:getHero_Combat()
	local lv = self:getHero_lv() or 1
	local comb = 0
	if self.m_look_model == 1 then--查看其他玩家数据
		self.m_herodata.attrs = UserDataManager:computCfgAttrs(self.herocfg, lv, self.m_herodata.evo)
		comb = UserDataManager:computeHeroCombat(self.m_herodata, self.herocfg, false, self.m_player_data)
	elseif self.m_look_model == 2 then--
		local attr = UserDataManager:computCfgAttrs(self.tj_hero_data, lv,self.tj_hero_data.max_evo)
		comb = UserDataManager:computeAttrsCombat(attr)
	else
		self.m_herodata.attrs = UserDataManager:computCfgAttrs(self.herocfg, lv, self.m_herodata.evo)
		comb = UserDataManager:computeHeroCombat(self.m_herodata, self.herocfg)
	end
	return math.floor(comb + 0.5)
end

--记录上一次的属性
function M:detectionAttrs()
	if self.m_look_model == 2 then
		return
	end
	self.last_attrs = {}
	self.last_lv = clone(self:getHero_lv()) 
	self.last_attrs = table.copy(self:getHeroAttrs()) 
	self.last_combat = self:getHero_Combat()
end

--记录装备信息
function M:detectionEqps()
	if self.m_look_model == 2 then
		return
	end
	self.last_eqps = table.copy(self.m_herodata.equips)
end

function M:getHero_Name()
	if self.m_look_model == 2 then
		return self.tj_hero_data.name
	end
	return self.herocfg.name 
end

function M:getHeroData()
	if self.m_look_model == 2 then
		self.herocfg = self:getHeroCfgByCid(self.tj_id)
	else
		self.m_herodata, self.herocfg =	self:getHeroById()
		self:updateSigData()
	end
end

function M:getHeroRace()
	if self.herocfg then
		return self.herocfg.race
	elseif self.tj_hero_data then
		return self.tj_hero_data.race
	else
		return 1	
	end
end

function M:getHeroType()
	if self.herocfg then
		return self.herocfg.type
	elseif self.tj_hero_data then
		return self.tj_hero_data.type
	else
		return 1	
	end
end

function M:getHeroBigAnim()
	if self.herocfg then
		return self.herocfg.hero_spine
	else
		return "hero_0003_SkeletonData"	
	end
end

--获取英雄装备列表 
function M:getHeroEquList()
	return self.m_herodata.equips or {}
end

--获取英雄信息
function M:getHeroById()
	if self.m_look_model == 1 then--查看其他玩家数据
		local heros = self.m_look_heros or {}
		local data = heros[self.m_heroid]
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
		return data, cfg
	else
		return UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	end
end

function M:checkEqpForId(index)
	local equips = self.m_herodata.equips or {}
	return equips[tostring(index)]
end

function M:getEquipDataById(id)
	local equips = self.m_player_data.equips or {}
	local data = equips[id]
	return data
end

function M:getHeroList()
	local ids = table.copy(UserDataManager.hero_data:getHerosId())
	local new_ids = {}
	if self.m_pro == 0 and self.m_race == 0 then
		new_ids = ids
		UserDataManager.hero_data:heroIdsSort(new_ids,"lv")
		return new_ids
	end
	local heros = {}
	for k,v in pairs(ids) do
		local l_hero_data, l_hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		if self.m_race == 0 or self.m_race == l_hero_cfg.race then
			if self.m_pro == 0 or self.m_pro == l_hero_cfg.type then
				table.insert(heros, v)
			end
		end
	end
	new_ids = heros
	UserDataManager.hero_data:heroIdsSort(new_ids,"lv")
	return new_ids
end

--英雄图鉴数据
function M:getHeroTj()
    local book_tab = ConfigManager:getCfgByName("book")
    local b_list = {}
    for k,v in pairs(book_tab) do
        table.insert(b_list, {id = k, data = v})
    end
    self:heroIdsSort(b_list)
    return b_list
end

--图鉴配置数据
function M:getTestHeroInfo()
	if self.m_look_model == 2 then
		for k,v in pairs(self.m_curlist) do
			if v.id == self.tj_id then
				return v
			end
		end
	end
	return nil
end

function M:getHeroCfgByCid(id)
	return UserDataManager.hero_data:getHeroConfigByCid(id)
end

function M:heroIdsSort(bks)
    local function sortFunc(id_one, id_two)
        local sequence1 = id_one.data.sequence
        local sequence2 = id_two.data.sequence
        return sequence1 < sequence2
    end
    table.sort(bks, sortFunc)
end


--根据id获取装备信息
function M:getEqpDataById(eqp_id)
	if self.m_look_model == 1 then--查看其他玩家数据
		local equips = self.m_player_data.equips or {}
		local data = equips[eqp_id]
		local cfg = nil
		if data then
			cfg = UserDataManager.equip_data:getEquipConfigByCid(data.id)
		end
		return data, cfg
	else
		return UserDataManager.equip_data:getEquipDataById(eqp_id)
	end
end

--英雄种族
function M:getRace()
	if self.m_look_model == 2 then
		return self.tj_hero_data.race
	end
	return self.herocfg.race
end

--英雄主属性
function M:getPro()
	if self.m_look_model == 2 then
		return self.tj_hero_data.type
	end
	return self.herocfg.type
end

--英雄主属性
function M:getEvo()
	if self.m_look_model == 2 then
		return self.tj_hero_data.max_evo
	end
	return self.m_herodata.evo
end


function M:netData(data, tag)
	self:getHeroData()
end

--获取技能信息
function M:getHeroSkill()
	if self.m_look_model == 2 then--查看其他玩家数据
		return self.tj_hero_data.skill
	end
	return self.herocfg.skill
end

--切换英雄 bl -1切换上一个 1 切换下一个
function M:switchTo(bl,callfunc)
	if self.m_show_new and self.m_show_new == true then
		if(callfunc)then
			callfunc()
		end
		return
	end
	local index = 1
	local oldIndex  = 1
	for k,v in pairs(self.m_curlist) do
		if self.m_heroid == v then
			index = k
			oldIndex = k 
			break
		end
	end
	if bl == 1 then
		if index < #self.m_curlist then
			index = index + 1
		elseif index == #self.m_curlist then
			index = 1
		end
	elseif bl == -1 then
		if index > 1 then
			index = index - 1
		elseif index == 1 then
			index = #self.m_curlist
		end
	end 
	if oldIndex == index then
		if(callfunc)then
			callfunc()
		end
		return
	end
	self.m_heroid = self.m_curlist[index]
	self:getHeroData()
	if(callfunc)then
       	callfunc()
    end
end

function M:getHeroCurListCount()
	local cur_list = self.m_curlist or {}
	return #cur_list
end

function M:getSpinePos()
	local id = 0
	if self.m_look_model == 2 then--查看其他玩家数据
		id = self.tj_hero_data.id
	else
		id = self.herocfg.id
	end
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	return data_pos
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
	if next_expend["team_level"] > self:checkLowestLv() then
		local count = next_expend["team_level"];
		return false, 4, count
	end
	return true
end

--获取英雄最低等级
function M:checkLowestLv()
	local tab = table.copy(UserDataManager.hero_data:getLevelTop()) 
	if next(tab) == nil then
		return 240
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

--当前英雄是否在共鸣水晶中
function M:inCrystal(id)
	local crystal_tab = table.copy(UserDataManager.hero_data:getCrystalAllHerosId())
	local lv5_tab = table.copy(UserDataManager.hero_data:getLevelTop())
	for k,v in pairs(crystal_tab) do
		if id == k then
			for kk,vv in pairs(lv5_tab) do
				if id == vv[1] then
					return false
				end
			end
			return true
		end
	end
	return false
end

function M:checkHaveExclusive()
	return true
end

function M:checkHaveArtifact()
	if self.m_herodata.artifact == nil or next(self.m_herodata.artifact) == nil then
		return false
	else
		return true	
	end
end

function M:checkMaxLv()
	local m_tv = ConfigManager:getCfgByName("hero_evolution")
	local cur_evo = m_tv[self.m_herodata.evo]
	if self.m_cur_Lv >= cur_evo.level_max then
		return true
	end
	return false
end

--英雄限定的最大等级
function M:checkMaxEvo()
	if self.m_herodata and self.herocfg then
		return self.m_herodata.evo == self.herocfg.max_evo
	end
	return false
end

--游戏内英雄的最大等级
function M:checkEvoMax()
	if self.m_herodata and self.herocfg then
		return self.m_cur_Lv == 240
	end
	return false
end

function M:checkInitEvo()
	if self.herocfg.evo == 3 or self.m_look_model == 2 then
		return false
	else
		return true	
	end
end

--是否开启专属槽位
function M:checkExclusive()
	if self.m_look_model == 1 then--查看其他玩家数据
	elseif 	self.m_look_model == 2 then
		return false
	else
		if self.m_herodata and self.m_herodata.evo >= 6 then
			return true
		else
			return false	
		end 
	end
	return false
end

function M:meridanCanLevelUp()
	local tab = ConfigManager:getCfgByName("equip_heroes")
	local eqp_levelup = tab[self.m_herodata.id]["level_up"]
	local level_cfg = eqp_levelup[self.sig_lv + 1]
	if level_cfg.unlock_rank and level_cfg.unlock_rank > 0 then
		if self.m_herodata.evo > level_cfg.unlock_rank then
			return false, Language:getTextByKey("new_str_0512") 
		else
			return false, Language:getTextByKey("new_str_0513") 	
		end
	else
		return true	
	end
	
end

--是否拥有专属装备
function M:checkHaveExclusive()
	if self.m_look_model == 1 then--查看其他玩家数据
	elseif 	self.m_look_model == 2 then
		return false
	else
		if self.m_herodata and self.m_herodata.evo >= 9 and next(self.m_herodata.sig) ~= nil then
			return true
		else
			return false	
		end 
	end
	return false
end

function M:getEvoName(index)
	local evo_data = ConfigManager:getCfgByName("hero_evolution")
	local data = evo_data[index]
	local color = GlobalConfig.HERO_QUALITY_COMMON_SETTING[index]
	local evo_name = "<color=#"..color.HC..">"..Language:getTextByKey(data.evo_name).."</color>"
	return evo_name
end

--是否开启神器功能
function M:checkArtifact()
	if self.m_look_model == 1 then--查看其他玩家数据
		return self:checkHaveArtifact()
	elseif 	self.m_look_model == 2 then
		return false
	else
		local flag, tips = BtnOpenUtil:isBtnOpen(32)
		return flag, tips	
	end
	
end

function M:getLockArtDesc()
	local stage_tab = ConfigManager:getCfgByName("stage")
	local data = stage_tab[156]
	local stage_name = Language:getTextByKey(data.map_point_name) 
	return stage_name
end

function M:getArtifactData()
	if self.m_look_model == 1 then--查看其他玩家数据
		if self:checkHaveArtifact() == true then
			if self.m_herodata.artifact then
				local  art_cfg = UserDataManager.artifact_data:getArtifactConfigByCid(self.m_herodata.artifact.id)
				return self.m_herodata.artifact, art_cfg
			end
		end
	elseif 	self.m_look_model == 2 then
		
	else
		if self.m_herodata.artifact then
			local  art_cfg = UserDataManager.artifact_data:getArtifactConfigByCid(self.m_herodata.artifact.id)
			return self.m_herodata.artifact, art_cfg
		end
	end
	return nil, nil
end

--专属数据
function M:getExWeaponData()
	if self.m_look_model == 1 then--查看其他玩家数据
	elseif 	self.m_look_model == 2 then --图鉴
	else
		if self.m_herodata.sig and self.herocfg.equip_heroes_id and next(self.m_herodata.sig) ~= nil then
			return 1,2
		end
	end
	return nil, nil
end

function M:getSkillData(id)
	local tab = ConfigManager:getCfgByName("skill_detail")
	local skill_cfg = tab[id]
	return skill_cfg
end

function M:isCategory7()
	return false
end

function M:subName()
	local plyType = nil
	if self.m_look_model == 2 then
		if self.tj_hero_data  then
			local name_path = string.split(self.tj_hero_data.prefab,"/")
			plyType = name_path[1]
		end
	else	
		if self.herocfg then
			local name_path = string.split(self.herocfg.prefab,"/")
			plyType = name_path[1]
		end
	end
	return plyType
end

function M:checkRedPoint()
	if self.herocfg then
		return UserDataManager.hero_data:checkHeroCollectPoint(self.herocfg.id)
	elseif self.tj_id then
		return UserDataManager.hero_data:checkHeroCollectPoint(self.tj_id)
	else
		return false
	end
end

--当前阶段经脉数据
function M:getCurMeridianData()
	local mer_tab = ConfigManager:getCfgByName("equip_heroes")
	local cur_hero_data = nil
	if self.tj_cfg then
		cur_hero_data = mer_tab[self.tj_cfg.equip_heroes_id]	
	elseif 	self.herocfg then
		cur_hero_data = mer_tab[self.herocfg.equip_heroes_id]	
	end
	if cur_hero_data == nil then
		cur_hero_data = mer_tab[101]	
	end
	return cur_hero_data
end

--根据个位index获取穴位数据
function M:getPassNameByIndex(index)
	local id = (self.sig_data.stage - 1) * 10 + index
	return self.sig_cfg.level_up[id]
end

--根据获取当前进度
function M:getPassNumByIndex()
	local index = self.sig_lv + 1 --self.sig_lv - ((self.sig_data.stage - 1) * 10)
	if index <= 10 then
		return index
	end
	local str = tostring(index) 
	local index_1 = string.len(str)
	local last_num = string.sub(str, index_1, index_1)
	return tonumber(last_num) 
end

function M:getMeridianAttrs()
	local next_attr = nil
	if self.sig_lv < #self.sig_cfg.level_up then
		next_attr = self.sig_cfg.level_up[self.sig_lv + 1]["attr"]
	end
	return self.sig_data.attr, next_attr
end

--是否达到最大等级
function M:checkMaxSig()
	local max_num = #self.sig_cfg.level_up
	if self.sig_lv >= #self.sig_cfg.level_up then
		return true
	end
	return false
end

--是否显示页签逸闻
function M:checkMeridian()
	if self.m_look_model == 1 then --查看其他玩家
		return false
	elseif self.m_look_model == 2 then --查看图鉴
		return true
	elseif self.m_look_model == 3 then --专属装备强化列表进入
		return true
	else --英雄列表进入
		return true
	end	
end

function M:getBaseInfoCellByIndex(index)
	if index == 1 then
		if self.tj_hero_data then
			return "anecdote_sex", self.tj_hero_data.sex
		elseif self.herocfg then
			return "anecdote_sex", self.herocfg.sex
		end
	elseif index == 2 then
		if self.tj_hero_data then
			return "anecdote_height", self.tj_hero_data.height
		elseif self.herocfg then
			return "anecdote_height", self.herocfg.height
		end	
	elseif index == 3 then
		if self.tj_hero_data then
			return "anecdote_age", self.tj_hero_data.age
		elseif self.herocfg then
			return "anecdote_age", self.herocfg.age
		end	
	elseif index == 4 then
		if self.tj_hero_data then
			return "anecdote_birthday", self.tj_hero_data.birthday
		elseif self.herocfg then
			return "anecdote_birthday", self.herocfg.birthday
		end	
	elseif index == 5 then
		if self.tj_hero_data then
			return "anecdote_potential", self.tj_hero_data.potential
		elseif self.herocfg then
			return "anecdote_potential", self.herocfg.potential
		end	
	elseif index == 6 then
		if self.tj_hero_data then
			return "anecdote_nature", self.tj_hero_data.nature
		elseif self.herocfg then
			return "anecdote_nature", self.herocfg.nature
		end	
	elseif index == 7 then
		if self.tj_hero_data then
			return "anecdote_like", self.tj_hero_data.like
		elseif self.herocfg then
			return "anecdote_like", self.herocfg.like
		end	
	elseif index == 8 then
		if self.tj_hero_data then
			return "anecdote_hate", self.tj_hero_data.hate
		elseif self.herocfg then
			return "anecdote_hate", self.herocfg.hate
		end	
	elseif index == 9 then
		if self.tj_hero_data then
			return "anecdote_interest", self.tj_hero_data.interest
		elseif self.herocfg then
			return "anecdote_interest", self.herocfg.interest
		end	
	elseif index == 10 then
		if self.tj_hero_data then
			return "anecdote_characteristic", self.tj_hero_data.characteristic
		elseif self.herocfg then
			return "anecdote_characteristic", self.herocfg.characteristic
		end	
	end
end

--检测传记开启条件
function M:checkAncedoteOpenByIndex(index)
	if self.m_herodata then
		local cfg_hero = UserDataManager:getCfgHero()
		local evo = self.m_herodata.evo
		if cfg_hero[tostring(self.herocfg.id)] ~= nil then
			evo = cfg_hero[tostring(self.herocfg.id)]["max_evo"] or evo
		end
		if evo >= self.herocfg.evo + index then
			return true
		else
			return false	
		end
	else
		return false	
	end
end

function M:getEvoName(index)
	local evo  = 0
	if self.herocfg then
		evo = self.herocfg.evo + index 
	elseif self.tj_hero_data then
		evo = self.tj_hero_data.evo + index 
	end
	local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	return Language:getTextByKey(hero_evolution[evo].evo_name) 
end

function M:getAncedoteDescByIndex(index)
	return Language:getTextByKey(self.herocfg["legend"][index])
end

function M:getAncedoteSkillByIndex(index)
	return self.herocfg["legend_skill"][index]
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
	return skill_lv
end

function M:getHeroImgName()
	local name_string = ""
	if self.herocfg then
		name_string = self.herocfg.icon
	elseif self.tj_hero_data then
		name_string = self.tj_hero_data.icon
	end
	if #name_string > 0 then
		local res = string.split(name_string, "_")
		return "a_ui_"..res[2]
	else
		return "a_ui_shenji"	
	end
end

function M:getPoetry()
	if self.herocfg then
		local poetry = string.gsub(Language:getTextByKey(self.herocfg.poetry), "\\n", "\n")
		local poe =  string.split(poetry,"\n")
		return poe
	end	
	return ""
end

function M:getAttrByBaseOn(data)
	
end

function M:getHeroDesA()
	local c_text = "\u{3000}\u{3000}"..Language:getTextByKey(self.herocfg["life"])
	for i = 1, 5 do
		local legend = "legend"..i
		c_text = c_text .. "\n \n".."\u{3000}\u{3000}"..Language:getTextByKey(self.herocfg[legend])
	end
	return c_text
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

function M:getSKillImprove()
	return UserDataManager.skillImprove_data.m_skillImprove[self.herocfg.id]
end

return M
