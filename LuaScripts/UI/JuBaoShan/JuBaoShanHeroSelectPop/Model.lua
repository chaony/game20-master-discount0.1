local M = class("JuBaoShanHeroSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end


function M:clearSoltPlayers()
	for i, v in ipairs(self.solt_players) do
		if v ~= "" then
			self:removeBuildPlayer(v);
		end
		self.solt_players[i] = "";
		self.start_solt_players[i] = ""
	end
end


function M:onEnter()
	--加载配置
	self.dice_cell_type_config = ConfigManager:getCfgByName("dice_cell_type");
	--在所有在建筑中的人物
	self.buildingPlayers = self.m_params.buildingPlayers
	--格子数据
	self.cell_data = self.m_params.cell_data
	--奖励
	self.lv_gift = self.m_params.lv_gift
	--配置文件
	self.cell_config = self.dice_cell_type_config[self.cell_data.mapid][self.cell_data.cell_type][self.cell_data.id]
	--格子类型，这里只会传 2:钱庄，4:建筑
	self.m_cell_type = self.cell_data.cell_type;
	--种族
	self.m_races = {};
	--奖励
	self.m_reward_data = { }
	--额外的奖励
	self.m_bonus_data = { }
	--累计奖励
	self.m_leiji_data = {}
	--通过格子类型来判断
	if self.m_cell_type == 4 then
		--最大等级
		self.m_max_lv = #self.cell_config.param.reward;
		--展示奖励
		self.m_reward = self.lv_gift
		table.insert(self.m_races, 0);
		--需要的条件
		self.m_need = self.cell_config.param.need
		for i, v in ipairs(self.m_need) do
			table.insert(self.m_races, v);
		end
		--品质要求
		self.evo_condition = {}
		self.slotNum = 0;
		for i, v in pairs(self.cell_config.slot) do
			self.slotNum = self.slotNum + 1;
			self.evo_condition[i] = v;
		end

		--获取槽位
		self.max_solt_num = 0;
		for i = 1, self.slotNum do
			local need_lv = self.evo_condition[i][1]
			if self.cell_data.lv >= need_lv then
				self.max_solt_num = i;
			end
		end

		--额外的奖励
		self.m_bonus = self.cell_config.bonus[self.max_solt_num]
		--如果没有取到说明没有品质的要求

		if self.m_reward ~= nil and #self.m_reward > 0 then
			table.insert(self.m_reward_data, self.lv_gift[1]);
			table.insert(self.m_reward_data, self.lv_gift[2]);
			table.insert(self.m_reward_data, self.lv_gift[3]);
		end

		if self.m_bonus ~= nil then
			if #self.m_bonus > 0 then
				table.insert(self.m_bonus_data, self.m_bonus[2]);
				table.insert(self.m_bonus_data, self.m_bonus[3]);
				table.insert(self.m_bonus_data, self.m_bonus[4]);
			end
		end
		
		--累计奖励
		if self.cell_data.gift ~= nil and _G.next(self.cell_data.gift) ~= nil then
			self.m_leiji_data = self.cell_data.gift
		end
	else
		if self.cell_data.team ~= nil and next(self.cell_data.team) ~= nil then
			local evo = 0
			for i, v in ipairs(self.cell_data.team) do
				local hero_data, hero_cfg = self:getHero(v)
				evo = hero_data.evo;
				break;
			end
			self.m_reward = self.cell_config.param.reward[evo-2]
			table.insert(self.m_reward_data, self.m_reward[2]);
		else
			self.m_reward = {}
		end
		self.m_max_lv = 0;
		--没有种族限制
		table.insert(self.m_races, -1);
		self.evo_condition = {}
		if _G.next(self.evo_condition) == nil then
			self.slotNum = 1;
			table.insert(self.evo_condition,{
				[1] = -1,
				[2] = 1,
			})
		else
			self.slotNum = 0;
			for i, v in pairs(self.cell_config.slot) do
				self.slotNum = self.slotNum + 1;
				self.evo_condition[i] = v;
			end
		end
		self.slotNum = 1;
	end

	--Logger.logError(self.m_reward_data," ~~~~~~~~~~~~ m_reward_data ")
	--Logger.logError(self.cell_data," ~~~~~~~~~~~~ cell_data ")
	--Logger.logError(self.cell_config," ~~~~~~~~~~~~ 格子配置文件 ")
	--Logger.logError(self.evo_condition," ~~~~~~~~~~~~ 品质条件 ")
	--Logger.logError(self.m_reward_data," ~~~~~~~~~~~~ 奖励 ")
	--Logger.logError(self.m_races," ~~~~~~~~~~~~ 种族 ")
	--Logger.logError(self.buildingPlayers," ~~~~~~~~~~~~~~~ 所有已经在建筑中的英雄 ")

	self.max_solt_num = 0;
	for i = 1, self.slotNum do
		local need_lv = self.evo_condition[i][1]
		if self.cell_data.lv >= need_lv then
			self.max_solt_num = i;
		end
	end

	--Logger.logError(self.max_solt_num," ~~~~~~~~~~~~ 最大的槽位 ")
	--槽位玩家
	self.solt_players = {}
	self.start_solt_players = {}
	--已经雇佣的人
	if self.cell_data.team ~= nil then
		for i, v in ipairs(self.cell_data.team) do
			self.solt_players[i] = v;
			self.start_solt_players[i] = v;
		end
	end
	
	--1 表示建筑派遣  2 表示钱庄派遣
	self.m_type = self.m_params.type;
	--当前的种族
	self.m_cur_race = 0
	--当前派遣的人物数量
	self.select_send_index = 0
	self.selectType_index = 1

	--刚进入界面的时候去决定 是 派遣还是撤回
	if self:checkSortFull() == true then
		--模式 2 就是撤回
		self.mode = 2;
	else
		--模式 1 就是派遣
		self.mode = 1;
	end
	--派遣的英雄列表 
	--槽位中的玩家
	self.hero_list = self:getAllHero()
end


function M:updateCellData( data )
	if data ~= nil then
		if data.max_award ~= nil then
			self.cell_data.max_award = data.max_award
		end
		if data.award ~= nil then
			self.cell_data.award = data.award
		end
	end
end



function M:updateRewardData()
	self.m_reward_data = {}
	if self.m_cell_type == 4 then
		self.m_reward = self.lv_gift;
		if self.m_reward ~= nil and #self.m_reward > 0 then
			table.insert(self.m_reward_data, self.m_reward[1]);
			table.insert(self.m_reward_data, self.m_reward[2]);
			table.insert(self.m_reward_data, self.m_reward[3]);
		end
	else
		local hero = 0;
		for i, v in pairs(self.solt_players) do
			if v ~= "" then
				hero = hero + 1;
			end
		end
		if hero > 0 then
			local evo = 0
			for i, v in ipairs(self.solt_players) do
				local hero_data, hero_cfg = self:getHero(v)
				evo = hero_data.evo;
				break;
			end
			self.m_reward = self.cell_config.param.reward[evo-2]
			table.insert(self.m_reward_data, self.m_reward[2]);
		else
			table.insert(self.m_reward_data, 0);
		end
	end
end


function M:getRewardData()
	if self.m_cell_type == 4 then
		local lv = self.cell_data.lv;
		local reward = self.cell_config.param.reward[lv];
		if reward == nil then
			reward = self.cell_config.param.reward[#self.cell_data.cell_config.param.reward]
		end
		return reward;
	end
end


function M:isChangeHeroList()
	local cur_num = 0
	for i, v in ipairs(self.solt_players) do
		if v ~= "" and v ~= nil then
			cur_num = cur_num + 1;
		end
	end
	local start_num = 0
	for i, v in ipairs(self.start_solt_players) do
		if v ~= "" and v ~= nil then
			start_num = start_num + 1;
		end
	end
	if cur_num == 0 and start_num == 0 then
		return true;
	end
	if cur_num == start_num then
		for i, v in ipairs(self.solt_players) do
			if v ~= "" and v ~= nil then
				local statr_ply = self.start_solt_players[i]
				if statr_ply ~= v then
					return true;
				end
			end
		end
		return false;
	end
	return true;
end

--切换英雄列表
function M:switchHeroList(race)
	self.m_cur_race = race
	local hero_list = {}
	--if self:checkSortFull() == false then
		hero_list = self:filtrateHero(race)
	--end
	return hero_list
end


--是否在 building 中
function M:isInBuilding( heroid )
	for i, v in pairs(self.buildingPlayers) do
		if heroid == v then
			return true;
		end
	end
	return false;
end


--删除在建筑中的玩家
function M:removeBuildPlayer( heroid )
	if self.buildingPlayers ~= nil and next(self.buildingPlayers) ~= nil then
		for k,v in pairs(self.buildingPlayers) do
			if v == heroid then
				self.buildingPlayers[k] = nil;	
			end
		end
	end
end

--筛选出已上阵的英雄
function M:getAllHero()
	--得到我的所有英雄
	local heros = table.copy(UserDataManager.hero_data:getHerosId())
	local allHeros = {}
	for i, v in pairs(heros) do
		local c_d = v
		local hero_data,hero_cfg = self:getHero(c_d);
		if self:hasRace(hero_cfg.race) and self:checkIsSelfHero(c_d) == false then
			table.insert(allHeros, c_d)
		end
	end
	return allHeros
end

--检测已经雇佣的人物
function M:checkIsSelfHero(id)
	if self.buildingPlayers ~= nil and next(self.buildingPlayers) ~= nil then
		for k,v in pairs(self.buildingPlayers) do
			if id == v then
				return true
			end
		end
	end
	return false
end

--根据种族筛选英雄
function M:getHeroByRace( race )
	if self:checkSortFull() == false then
		self:getMyHeroByRace(race)
	end
end

--获取某个种族的英雄
function M:getMyHeroByRace(race)
	--如果 race == 0 表示没有种族限制
	if race == 0 then
		return self.hero_list
	end
	local heros = {}
	for k,v in pairs(self.hero_list) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if l_hero_cfg ~= nil then
			if l_hero_cfg.race == race then
				table.insert(heros, v)
			end
		end
	end
	UserDataManager.hero_data:heroIdsSort(heros,"default")
	return heros
end

--过滤 全部英雄列表
function M:filtrateHero(race_id)
	--获取全部英雄列表
	local hero_list = self:getAllHero()
	--如果种族是 0 表示 不筛选
	if race_id == 0 then
		return hero_list
	end
	local heros = {}
	for k,v in pairs(hero_list) do
		--获取英雄配置
		local l_hero_data, l_hero_cfg = self:getHero(v)
		--如果种族一致就加入到列表中
		if race_id == l_hero_cfg.race then
			table.insert(heros, v)
		end
	end
	--根据等级排序
	UserDataManager.hero_data:heroIdsSort(heros, "lv")
	return heros
end

function M:getHeros()
	if self.m_cur_race and self.m_cur_race > 0 then
		return self:switchHeroList(self.m_cur_race)
	end
	local data = {}
	for k,v in pairs(self.hero_list) do
		table.insert(data, v)
	end
	return data
end

--根据id获得英雄数据
function M:getHero(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

--根据id获得英雄本地数据
function M:getHeroCfg(id)
	return UserDataManager.hero_data:getHeroConfigByCid(id)
end

--需要的种族
function M:getNeedRace()
	return self.m_races
end

--槽位的英雄是否满了
function M:checkSortFull()
	local cur_num = 0
	for i, v in ipairs(self.solt_players) do
		if v ~= "" and v ~= nil then
			cur_num = cur_num + 1;
		end
	end
	if cur_num == self.max_solt_num then
		return true
	else
		return false
	end
end

--获取槽位上现在有的 英雄数量
function M:getSlotHeroNumNow()
	local num = 0;
	for i = 1,self.max_solt_num do
		--找到 空的槽位
		if self.solt_players[i] == nil or self.solt_players[i] == "" then
			break;
		end
		num = num + 1;
	end
	return num;
end

--获取槽位上的英雄列表
function M:getSendSlot()
	return self.solt_players
end

--向槽位中添加一个英雄
function M:addHeroInSendSlot( id )
	local hero_cfg = self:getHero(id);
	local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_cfg.id)
	--由于槽位和种族是对应的
	--槽位中的最后一个对象，表明了
	if self:checkSortFull() == false then
		--从 1 ~ 最大值 遍历
		for i = 1,self.max_solt_num do
			--找到 空的槽位
			if self.solt_players[i] == nil or self.solt_players[i] == "" then
				--id 是 instanceId
				--种族 == 0 表示任意种族
				if self:hasRace(cur_hero_cfg.race) then
					if hero_cfg.evo >= self:getNeedEvo(i) then
						self.solt_players[i] = id
						return 0
					else
						--品质不符合 
						return 1
					end
				end
			end
		end
		--种族不符合
		return 2;
	end
	--人员已经满了
	return 3;
end


--是否有种族
function M:hasRace( race )
	if race == 7 then
		return true
	end
	for i, v in pairs(self.m_races) do
		if v == -1 then
			return true;
		end
		if race == v then
			return true;
		end
	end
	return false;
end


--从槽位中移除一个英雄
function M:removeHeroInSendSlot(id)
	local index = 1
	for k,v in pairs(self.solt_players) do
		if v == id then
			index = k
		end
	end
	self.solt_players[index] = "";
end

--检查该英雄是否在列表中
function M:isInSlot(id)
	for k,v in pairs(self.solt_players) do
		if v == id then
			return true
		end
	end
	return false
end

--检查某个槽位是不是有英雄
function M:isHaveHero(index)
	if self.solt_players[index] == nil or self.solt_players[index] == "" then
		return false
	else
		return true
	end
end

--移除槽位中的某个英雄
function M:removeByIndex(index)
	if self.solt_players[index] ~= nil then
		self.solt_players[index] = nil
	end
end

--从槽位中获取英雄配置
function M:getHeroByIndex(index)
	if self.solt_players[index] ~=nil and self.solt_players[index] ~= "" then
		return self:getHero(self.solt_players[index])
	end
	return nil
end


function M:getHeroSlotByIndex(index)
	if self.solt_players[index] ~=nil and self.solt_players[index] ~= "" then
		return self.solt_players[index]
	end
	return nil
end

--是否有空位
function M:isHaveNull()
	if #self.solt_players >= self.slotNum then
		for i = 1, #self.solt_players do
			if self.solt_players[i] == nil or self.solt_players[i] == "" then
				return true
			end
		end
		return false
	else
		return true
	end
end


function M:hasEvoCondition()
	return self.evo_condition ~= nil;
end


--品质要求
--slotindex 槽位index
function M:getNeedEvo( slotindex )
	if self.evo_condition ~= nil then
		return self.evo_condition[slotindex][2];
	end
	return 0
end

--需要对应品质英雄的数量
function M:getNeedEvoNum()
	return 1
end

--当前对应品质的数量
function M:getCurEvoNum()
	local num = 0;
	for k,v in pairs(self.solt_players) do
		if v ~= "" then
			local data,cfg = self:getHero(v)
			if data.evo >= self:getNeedEvo(k) then
				num = num +1
			end
		end
	end
	return num
end

--数量条件是否完成
function M:checkNumCondition()
	return self:getCurEvoNum() >= self:getNeedEvoNum()
end

--一键上阵
--自动配置
function M:auto_viewData(data)
	--清空槽内英雄
	self.solt_players = {}
	--服务器传来的队伍
	local team = data.team;
	--循环队伍
	for i, v in ipairs(team) do
		--获取英雄配置
		self.solt_players[i] = v
	end
end

--检测种族是否在槽内
function M:checkRaceInSlot(race)
	for k,v in pairs(self.solt_players) do
		if v ~= "" then
			local data, cfg = self:getHero(v)
			if race == cfg.race then
				return true
			end
		end
	end
	return false
end

--格子数量
function M:getHeroGrideNum()
    local num = 100 + UserDataManager.extra_hero_grid
    return num
end


function M:getHeroBigAnim(o_id)
	local data,cfg = self:getHero(o_id)
	if cfg then
		return cfg.hero_spine
	else
		return "hero_0003_SkeletonData"	
	end
end


function M:getSpinePos(o_id)
	local data,cfg = self:getHero(o_id)
	local id = data.id
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	return data_pos
end


return M
