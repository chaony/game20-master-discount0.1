--- 阵型
local M = class("PlayerThreeFormationNode",LikeOO.OOUIbase)

M.m_uiName = "Pops/PlayerInfo/PlayerThreeFormationNode"

function M:onEnter()
	-- self:setTextByLanKey("title_text", "new_str_0118")
	if self.m_model.m_look_model == 5 then
		self:setTextByLanKey("formation_title_text", "peak_str_0047")
	else
		self:setTextByLanKey("formation_title_text", "new_str_0275")
	end

	self:setTextByLanKey("guild_title_text", "gonghui_text")
	self:setTextByLanKey("title_server_text", "new_str_0893")
	self:setTextByLanKey("name_title_text", "new_str_0489")
	local rank = self.m_model.m_rank or self.m_model.m_data.rank
	local score = self.m_model.m_score or 0
	self.m_team_node = self:findGameObject("team_node")
	if self.m_model.m_look_model == 6 or self.m_model.m_look_model == 7 then
		self:setTextByLanKey("title_dw_text", "new_str_0864")
		self:setTextByLanKey("score_title_text", "new_str_0566")
		self:setTextByLanKey("dw_text", Language:getTextByKey(tostring(rank or "new_str_0076")))
		self:setTextByLanKey("score_text", tostring(score))
		self:setTextByLanKey("score_hour_text", "")
		self:setTextByLanKey("score_increase_hour_text", "")
		self:setTextByLanKey("score_increase_title_text", "")
		self:setTextByLanKey("score_increase_text", "")
	else
		self:setTextByLanKey("title_dw_text", "new_str_0892")
		self:setTextByLanKey("score_title_text", "new_str_0302")
		local cfg = ConfigManager:getHighArenaCfgByRank(rank or 0)
		if self.m_model.m_look_model == 8 then
			cfg = ConfigManager:getHuaShanCfgByRankAndVsn(rank or 0, self.m_model.m_version)
			--self:setTextByLanKey("score_title_text", "huashan_sword_text0006")
			self:setTextByLanKey("score_increase_hour_text", "")
			self:setTextByLanKey("score_increase_title_text", "")
			self:setTextByLanKey("score_increase_text", "")
			self:setTextByLanKey("score_text", cfg.high_coin or 0)
			self:setTextByLanKey("dw_text", Language:getTextByKey(tostring(cfg.division_name or "new_str_0076")))
			self:setTextByLanKey("score_hour_text", "new_str_0288")
		elseif self.m_model.m_look_model == 10 then
			self:setTextByLanKey("title_dw_text", "")
			self:setTextByLanKey("score_hour_text", "")
			self:setTextByLanKey("dw_text", "")
			self:setTextByLanKey("score_text", "")
			self:setTextByLanKey("score_title_text", "")
			self:setTextByLanKey("score_increase_hour_text", "")
			self:setTextByLanKey("score_increase_title_text", "")
			self:setTextByLanKey("score_increase_text", "")
		else
			self:setTextByLanKey("score_increase_text", cfg.high_point or 0)
			self:setTextByLanKey("score_increase_title_text", "new_str_0286")
			self:setTextByLanKey("score_increase_hour_text", "new_str_0288")
			self:setTextByLanKey("score_text", cfg.high_coin or 0)
			self:setTextByLanKey("dw_text", Language:getTextByKey(tostring(cfg.division_name or "new_str_0076")))
			self:setTextByLanKey("score_hour_text", "new_str_0288")
		end
	end
    self:refreshUI()
end

function M:refreshUI()
	local data = self.m_model:getDataByIndex(self.m_params.index)
	local user = data.user or {}
	local gender_cfg_item = GlobalConfig.GENDER_CFG[user.gender]
	if gender_cfg_item then
		self:setTextByLanKey("gender_text", gender_cfg_item.name)
		self:setImg(gender_cfg_item.icon, gender_cfg_item.atlas, "gender_img")
		self:setObjectVisible("gender_text", false) --暂时屏蔽性别
		self:setObjectVisible("gender_img", false)
	else
		self:setObjectVisible("gender_text", false)
		self:setObjectVisible("gender_img", false)
	end
    local head_node = self:findGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
	local name = user.name or ""
	local uid = user.uid
	if name == "" then
		self:setText("name_text", uid)
	else
		self:setText("name_text", name)
	end
	self:setText("level_text", tostring(user.level))
	local guild_name = user.guild_name or ""
	if guild_name == "" then
		self:setTextByLanKey("guild_text", "new_str_0092")
	else
		self:setText("guild_text", tostring(user.guild_name))
	end
	local server_name = UserDataManager.server_data:getServerNameById(user.server)
	self:setTextByLanKey("server_text", server_name)
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getMultTeamShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	if index == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", string.cutTextForString(Language:getTextByKey("arena_str_0012")) )
	elseif index == 2 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", string.cutTextForString(Language:getTextByKey("arena_str_0013")))
	elseif index == 3 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", string.cutTextForString(Language:getTextByKey("arena_str_0027")) )	
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "")	
	end
	
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_combat_text", "friend_str_0041")
	local team_node = luaBehaviour:FindGameObject("team_node")
	local team_node_rt = UIUtil.findRectTransform(team_node)
	local show_heros = cell_data.team_heros_data
	local total_combat = cell_data.total_combat
    local function lookHero(item_object, item_data)
		if self.m_model.m_look_model == 5 then
			self:updateMsg("look_hero", {oid = item_data.card_id, data = self.m_model.m_data,sig = true})
		else
			self:updateMsg("look_hero", {oid = item_data.card_id, data = self.m_model.m_data})
		end
    end
	self:createHeros(team_node_rt, show_heros, false, false, lookHero)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_text", tostring(total_combat))
end

function M:createHeros(team_node, rewards, is_show_num, is_show_detail, callback)
    local rewards = rewards or {}
	if not self.m_model.show_battle_array then
		local new_rewards = {}
		for i = 1, #rewards do
			local show_data = {
				atlas_name = rewards[i].atlas_name,
				hero_data = rewards[i].hero_data,
				icon_name = "TX_Temp",
				is_piece = rewards[i].is_piece,
				item_cfg = rewards[i].item_cfg,
				quality = rewards[i].quality,
				card_id = rewards[i].card_id,
				data_id = rewards[i].data_id,
				data_num = rewards[i].data_num,
				data_type = rewards[i].data_type,
				money_guide_cfg = rewards[i].money_guide_cfg,
				race = rewards[i].race,
			}
			table.insert(new_rewards,show_data)
		end
		rewards = new_rewards
	end
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
		local item_data = rewards[i]
		if item_data and _G.next(item_data) and item_data.item_cfg then  --如果那个位置没有上阵侠客，由于上面新增了代码，导致原来的判断会通过，而数据并不完全，会导致报错
		 	GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false, callback)
			local item_hero_luaBehaviour = UIUtil.findLuaBehaviour(hero_node.transform)
			local camp_img = item_hero_luaBehaviour:FindGameObject("camp_img")
			camp_img:SetActive(self.m_model.show_battle_array)
			local item_btn = item_hero_luaBehaviour:FindButton("hero_node_"..i)
			item_btn.interactable = self.m_model.show_battle_array
		else
			local ui_element = GameUtil:updateItemElementNoData(hero_node)
			ui_element.add_img.gameObject:SetActive(false)
		end
	end
end

return M