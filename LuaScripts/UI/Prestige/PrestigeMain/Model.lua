---@class PrestigeMainModel : OODataBase
local M = class("PrestigeMainModel", LikeOO.OODataBase)

local tab_item1 = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_item2 = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币

function M:onCreate()
	M.super.onCreate(self)
	self:getData("prestige_index")
end

function M:onEnter()
	PrestigeUtil:initBoardData(UserDataManager:getPrestigeBoard())
	self.m_pieces_score = 0
	self.m_fetter_score = 0
	self.is_from_editor = self.m_params.is_from_editor
	self.is_just_complete = self.m_params.is_just_complete
	self.hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	self.board_cfg = ConfigManager:getCfgByName("prestige_checkerboard")
	self.upgrade_cfg = ConfigManager:getCfgByName("prestige_checkerboard_upgrade")
end

function M:getUpgradeCost()
	local board_type = PrestigeUtil.cur_board_type
	local board_level = PrestigeUtil:getBoardLevel(board_type)
	local upgrade_recipe = self.board_cfg[board_type].upgrade_recipe
	local max_level = #self.upgrade_cfg[upgrade_recipe]
	local upgrade_data = self.upgrade_cfg[upgrade_recipe][board_level]
	local cost_item1 = RewardUtil:getProcessRewardData(upgrade_data.cost[1])
	local cost_item2 = RewardUtil:getProcessRewardData(upgrade_data.cost[2])
	local attr = upgrade_data.attr
	local score = upgrade_data.score
	return cost_item1, cost_item2,attr,score,max_level
end

function M:getBoardTitle(board_type)
	return self.board_cfg[board_type].checkerboard_name
end

function M:getRaceID(board_type)
	return self.board_cfg[board_type].race
end

function M:getCurCostItemNum(item_type)
	return 99  -- todo
end

function M:getHeroSkinID(board_type)
	return self.board_cfg[board_type].checkerboard_hero_id
end

function M:getHeroCfg(board_type)
	local hero_id =  self.board_cfg[board_type].checkerboard_hero_id[1]
	return UserDataManager.hero_data:getHeroConfigByCid(hero_id)
end

function M:getPrestigeAttr()
	self.m_pieces_score = 0
	self.m_fetter_score = 0
	local cur_type =  PrestigeUtil.cur_board_type
	local prestige_board = UserDataManager:getPrestigeBoard()
	local prestige_pieces = PrestigeUtil:getBlockDataForBoard(cur_type)
	local prestige_board_cfg = ConfigManager:getCfgByName("prestige_checkerboard_upgrade") or {}
	local prestige_pieces_cfg = ConfigManager:getCfgByName("prestige_piece_affix") or {}
	local board_cfg = ConfigManager:getCfgByName("prestige_checkerboard") or {}  --用upgrade_recipe  去 restige_board_cfg取
	local board_fetter_cfg = ConfigManager:getCfgByName("prestige_checkerboard_fetter") or {}  --羁绊的属性配置

	local attrs = {}
	--棋盘属性
	local cur_board = prestige_board[tostring(cur_type)]
	local upgrade_recipe = board_cfg[cur_type].upgrade_recipe
	local level = cur_board.level
	if prestige_board_cfg[upgrade_recipe][level] then
		local attr = prestige_board_cfg[upgrade_recipe][level].attr
		for k1,v1 in ipairs(attr) do
			table.insert(attrs,v1)
		end
	else
		Logger.log("棋盘等级与配置对不上" .. "棋盘" ..upgrade_recipe )
	end

	--羁绊属性
	local coordinate_data = cur_board.coordinate
	local pieces = {} --棋子id
	local cur_board_fetter_cfg = {}
	for id,id_cfg in ipairs(board_fetter_cfg) do
		if id_cfg.checkerboard == tonumber(cur_type) then
			table.insert(cur_board_fetter_cfg,id_cfg)
		end
	end

	for pos,id in pairs(coordinate_data) do
		local have = false
		for key,piece_id in pairs(pieces) do
			if id == piece_id then
				have = true
				break
			end
		end
		if not have then
			table.insert(pieces,id)
		end
	end
	--棋子属性
	for k1,v1 in pairs(pieces) do
		local pieces_data =  prestige_pieces[v1]
		if pieces_data then
			if pieces_data.status ~= 0 then
				--Logger.log("已经装备" ..v1)
				local affix = pieces_data.affix
				for groupid,idgroup in pairs(affix) do
					for key,id in ipairs(idgroup) do
						if prestige_pieces_cfg[id] then
							local piece_attr = prestige_pieces_cfg[id].attr
							--local final_attr = GameUtil:countAttr(piece_attr)
							table.insert(attrs, piece_attr)
							self.m_pieces_score = self.m_pieces_score + prestige_pieces_cfg[id].affix_score
						else
							Logger.log("异常id" .. id)
						end
					end
				end
			end
		--else
		--	Logger.log("异常棋子id" .. id)
		end
	end
	
	local hero_ids = {}  --英雄id
	for key,piece_id in pairs(pieces) do
		if prestige_pieces[piece_id] then
			local hero = prestige_pieces[piece_id].hero
			table.insert(hero_ids,hero)
		end
	end

	for key1,key1_cfg in ipairs(cur_board_fetter_cfg) do
		local fetter_cfg = key1_cfg.hero_fetter
		local nums = 0
		for key2,fetter_id in ipairs(fetter_cfg) do
			for key3,hero_id in ipairs(hero_ids) do
				if fetter_id == hero_id then
					nums = nums +1
				end
			end
		end
		local effect = key1_cfg.effect
		local buff = key1_cfg.buff
		local fetter_score = key1_cfg.score
		local level = 0
		for key4,condition in ipairs(effect) do
			if nums >= condition then
				level = key4
			end
		end
		local hero_fetter_attr = buff[level]
		if hero_fetter_attr then
			--local final_attr = GameUtil:countAttr(hero_fetter_attr)
			table.insert(attrs, hero_fetter_attr)
			self.m_fetter_score = self.m_fetter_score + fetter_score[level]
		end
	end
	--local base_attrs = {}
	local add_cfg_attrs = {} -- {id:value}
	UserDataManager:appendCfgAttrs(attrs, add_cfg_attrs)
	--local all_attrs = UserDataManager:getAllHeroAttrs(add_cfg_attrs, base_attrs)
	return add_cfg_attrs
end

return M