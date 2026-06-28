local M = class("WorldMapGuideModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_pop_from_func_id = self.m_params.pop_from_func_id
	self.m_sence_func_tab = { --跳转时被视作同一场景
		{24, 36, 37}, --论剑山庄
		{32, 86}, --天机楼
		{87, 78, 88, 29}, --试炼遗迹
		{18, 38}, --闯王宝藏
	}
	self.m_func_view_tab = {
		[33] = "WorldMap.WorldMapMain",
		[9] = "Pub",
		[12] = "Shop",
		[7] = "Advanced",
		[21] = "ShareLv",
		[22] = "Rank.RankMain",
		[71] = "Predestined",
		[16] = "Reward",
		[32] = "Budo",
		[86] = "Budo.BudoSelectPop",
		[77] = "Taoist",
		[41] = "JuBaoShan",
		[37] = "Arena.ArenaSelectMain",
		[24] = "Arena.ArenaNormal.ArenaNormal",
		[36] = "Arena.ArenaRace.ArenaRace",
		[18] = "MazeStage",
		[38] = "MazeStage.MazeStageChoice",
		[29] = "Activities.WorldBoss",
		[78] = "Activities.WorldBoss.HeroBossTrainPop",
		[88] = "Legend",
		[87] = "Activities.WorldBoss.HeroBossSelectMain",
		[83] = "FivelinesNew",
		[85] = "HuntTreasures",
	}
	
	local function netCallback(response)
		self.m_data_arena = response or {}
	end
	self:getNetData("arena_index", nil, netCallback)
end

function M:getNpcGuideTab()
	local new_tab = {}
	local open_condition = ConfigManager:getCfgByName("open_condition")
	local jump = ConfigManager:getCfgByName("jump")
	local npc_guide_tab = table.copy(ConfigManager:getCfgByName("quick_jump"))
	for k, v in pairs(npc_guide_tab) do
		local c_cfg = npc_guide_tab[k]
		if c_cfg.sort == 1 or c_cfg.sort == 2 then
			c_cfg.index = k
			if c_cfg.go_type and c_cfg.go_type then
				local open_condition_id = jump[c_cfg.go_type]
				if open_condition_id then
					local open_condition_item = open_condition[open_condition_id.open_condition_id]
					if open_condition_item then
						c_cfg.icon = open_condition_item.quick_icon
					end
					local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id.open_condition_id)
					if open_flag == true then
						c_cfg.open_flag = true
					else
						c_cfg.open_flag = false
					end
				end
				table.insert(new_tab, c_cfg)
			end
		end
	end
	local function sortFunc(cfg_1, cfg_2)
		if cfg_1.sort == cfg_2.sort then
			if cfg_1.guide_stage == cfg_2.guide_stage then
				return cfg_1.index < cfg_2.index
			else
				return cfg_1.guide_stage < cfg_2.guide_stage
			end
		else
			return cfg_1.sort < cfg_2.sort
		end
    end
	table.sort(new_tab,sortFunc)
	self:formatCellData(new_tab)
	
	return new_tab
end

--class_type, 1 事务, 2 侠义
function M:formatCellData(tab)
	local count = 0
	local left = 0
	--处理事务数据
	count = self:getItemCountWithType(tab, 1)
	left = count % 3
	if left == 1 then
		self:handleDataInsertFakeData(tab, 1, 1)
	end
	--处理侠义数据
	count = table.nums(tab)
	left = count % 3
	if left == 1 then
		self:handleDataInsertFakeData(tab, 2, 1)
	end
end

function M:handleDataInsertFakeData(tab, class_type, count)
	if class_type == 1 then
		for k, v in pairs(tab) do
			if v.sort == 2 then
				for i = 1, count do
					table.insert(tab, k,{})
				end
				break
			end
		end
	elseif class_type == 2 then
		for i = 1, count do
			table.insert(tab, table.nums(tab) + 1,{})
		end
	end
end

function M:getItemCountWithType(tab, class_type)
	local count = 0
	for i, v in ipairs(tab) do
		if v and v.sort == class_type then
			count = count + 1
		end
	end
	return count
end

function M:getViewName(func_id)
	return self.m_func_view_tab[func_id]
end

function M:isInSceneNow(go_type)
	if self.m_pop_from_func_id ~= nil and go_type ~= nil then
		if self.m_pop_from_func_id == go_type then
			return true
		else
			for i, valTab in ipairs(self.m_sence_func_tab) do
				for j, val_1 in ipairs(valTab) do
					if go_type == val_1 then
						for m, val_2 in ipairs(valTab) do
							if self.m_pop_from_func_id == val_2 then
								return true
							end
						end
						return false
					end
				end
			end
		end
	end
	return false
end

function M:checkLunJianShanZhuangSubOpen()
	if self.m_data_arena then
		local race_arena = self.m_data_arena["race_arena"]
		if race_arena and  race_arena.match_type and race_arena.match_type == 0 then
			return true
		end
	end
	return false
end

function M:checkTianJiLouSubOpen()
	local day = math.floor((UserDataManager:getServerTime() + UserDataManager:getTimeZone())/86400)
	local yu_day = (UserDataManager:getServerTime() + UserDataManager:getTimeZone())%86400
	if yu_day >  0 then
		day = day + 1
	end
	local open_race = (day-1)%4 + 1
	if open_race == 1 or open_race == 2 or open_race == 3 or open_race == 4 then
		return true
	end
	return false
end

return M
