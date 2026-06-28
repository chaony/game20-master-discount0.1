local M = class("MultiFormationView",LikeOO.OOPopBase)

M.m_uiName = "Formation/MultiFormation"
M.m_size_type = 1

function M:onEnter()
	self:updateMsg("set_click", false, "Formation")
	self:setTextByLanKey("common_title_text", "new_str_0134")
	self.m_model.m_multi_formation_changed_flag = false
	self:setTextByLanKey("sel_combat_num_title_text", "new_str_0490")
	self.m_gray_image = self:findImage("gray_image")
	if self.m_model.m_show_status == 1 then
		self:showFormationList()
	else
		self:showTeamEdit()
	end

	self.m_race_toggle_bg = self:findGameObject("race_toggle_bg")
	for i,v in ipairs(GlobalConfig.RACE_TOGGLE_TAB_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local lan_text = "new_str_0065"
		if i > 1 then
			lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
		end
		self:setTextByLanKey(v.name, lan_text)
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				local lan_text = data > 1 and GlobalConfig.TYPE_HERO_RACE[i-1].name or "new_str_0065"
				self:setTextByLanKey("race_toggle_btn_text", lan_text)
				self.m_model.m_sel_screen = i
				self:updateHeroLoopScroll()
			end
		end, i, self.m_uiName)
	end
	self:setToggleActive(false)
end

function M:refreshUI()
	if self.m_model.m_show_status == 1 then
		self:updateFormationLoopScroll()
	else
		local formation_data =  UserDataManager.hero_data:getFormation()
		local formation_data_item = formation_data[tostring(self.m_model.m_sel_formation_index)] or {}
		local team = self.m_model.m_main_team or formation_data_item.team
		team = team or {}
		local no_hero = GameUtil:teamNoHero(team)
		local name_str = nil
		if no_hero then
			name_str = Language:getTextByKey("new_str_0551") .. tostring(self.m_model.m_sel_formation_index)
		else
			if formation_data_item.name then
				name_str = formation_data_item.name
			else
				name_str = Language:getTextByKey("new_str_0551") .. tostring(self.m_model.m_sel_formation_index)
			end
		end
		self:setTextByLanKey("sel_formation_name_text", tostring(name_str))
		local team_heros_data, combat = self.m_model:getHerosDataByTeam(team)
		local sel_team_node = self:findGameObject("sel_team_node")
		for i = 1, 5 do
			local hero_node = UIUtil.findTrans(sel_team_node.transform, "hero_node_" .. i)
			local remove_img = UIUtil.findTrans(sel_team_node.transform, "remove_img_" .. i)
			local item_data = team_heros_data[i]
			if item_data and _G.next(item_data) then
				-- CommonUIUtil:updateHeroElementByData(hero_node, item_data, function()
				--     self:updateMsg("goDownBattle", { heroid = item_data.hero_data.oid})
				--     self.m_model.m_multi_formation_changed_flag = true
				-- end)
				GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false,function ()
					self:updateMsg("goDownBattle", { heroid = item_data.hero_data.oid})
					self.m_model.m_multi_formation_changed_flag = true
				end)
				--CommonUIUtil:updateHeroLvByData(hero_node, item_data.hero_data)
				remove_img.gameObject:SetActive(false)
			else
				--CommonUIUtil:updateHeroElementAdd(hero_node)
				GameUtil:updateItemElementNoData(hero_node)
				remove_img.gameObject:SetActive(false)
			end
		end
		self:setTextByLanKey("sel_combat_num_text", GameUtil:formatValueToString(combat))
		self:updateHeroLoopScroll()
	end
end

--[[
	创建列表
]]
function M:updateFormationLoopScroll()
	local data = {}
	local formation_data =  UserDataManager.hero_data:getFormation()
	local index = GlobalConfig.MULTI_FORMATION_MAX
	for i=1,GlobalConfig.MULTI_FORMATION_MAX do
		local item_data = formation_data[tostring(i)] or {}
		local flag = GameUtil:teamNoHero(item_data.team)
		if flag then
			index = i
			break
		end
	end
	--local real_index = math.ceil(index/2)*2
	local real_index = index
	for i=1,real_index do
		local item_data = formation_data[tostring(i)] or {}
		table.insert(data, item_data)
	end
	--if #data < (GlobalConfig.MULTI_FORMATION_MAX - 1) then
	--    for i=1,2 do
	--        table.insert(data, {lock = true})
	--    end
	--end

	if self.m_formation_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("formation_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local info_node = luaBehaviour:FindGameObject("info_node")
				local canvas_group = info_node:GetComponent("CanvasGroup")
				canvas_group.alpha = cell_data.lock == true and 0.6 or 1
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_node", cell_data.lock == true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "new_str_0555")
				local name_str = nil
				if cell_data.name and cell_data.name ~= "" then
					name_str = cell_data.name
				else
					name_str = Language:getTextByKey("new_str_0551") .. tostring(index)
				end
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", tostring(name_str))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "new_str_0289")
				local team_node = luaBehaviour:FindGameObject("team_node")
				local team_heros_data, combat = self.m_model:getHerosDataByTeam(cell_data.team)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_title_text", "new_str_0490")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", GameUtil:formatValueToString(combat))
				local team_lock = self.m_model:checkMultRace(team_heros_data)
				for i = 1, 5 do
					local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
					local item_data = team_heros_data[i]
					if item_data and _G.next(item_data) then
						GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false,function ()
							self:updateMsg("goDownBattle", { heroid = item_data.hero_data.oid})
							self.m_model.m_multi_formation_changed_flag = true
						end)
						local hero_luaBehaviour = UIUtil.findLuaBehaviour(hero_node)
						if hero_luaBehaviour then
							LuaBehaviourUtil.setObjectVisible(hero_luaBehaviour, "lock_image", team_lock == false)
						end
					else
						GameUtil:updateItemElementNoData(hero_node, nil, nil, function()
							self:updateMsg("formation_edit_btn", {index = index , cell_data = cell_data})
						end)
					end
				end
				-- local btn_img_name = GlobalConfig.MULTI_FORMATION_ICON[index] or GlobalConfig.MULTI_FORMATION_ICON[#GlobalConfig.MULTI_FORMATION_ICON]
				-- LuaBehaviourUtil.setImg(luaBehaviour, "formation_rename_btn", btn_img_name, "battle_ui")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_rename_btn_text", "upper_num_str_000"..index)

			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if not cell_data.lock then
					local flag = GameUtil:teamNoHero(cell_data.team)
					local team_lock = self.m_model:checkMultRace2(cell_data.team)
					if team_lock == false then
						GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0703"), delay_close = 2})
						return
					end
					if click_name == "set_team" then
						if not flag then
							self:updateMsg(click_name, {index = index , cell_data = cell_data})
						end
					else
						self:updateMsg(click_name, {index = index , cell_data = cell_data})
					end
				end
			end
		}
		self.m_formation_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_formation_loop_scroll_view:reloadData(data, true)
	end
end

--[[
	创建列表
]]
function M:updateHeroLoopScroll()
	self.m_sel_cell_index = nil
	self.m_hero_is_big = false
	local sel_screen = self.m_model.m_sel_screen or 1
	local data = nil
	if sel_screen == 1 then
		data = UserDataManager.hero_data:getHerosId()
	else
		local sel_race = sel_screen - 1
		local function filterFunc(data, cfg)
			return cfg.race == sel_race
		end
		data = UserDataManager.hero_data:getHerosIdByFilterFunc(filterFunc)
	end
	self:setObjectVisible("CommonTipsNode", #data == 0)
	if self.m_hero_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("hero_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("click_card", {heroid = cell_data})
				self.m_model.m_multi_formation_changed_flag = true
			end
		}
		self.m_hero_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_hero_loop_scroll_view:reloadData(data)
	end
end

--刷新英雄数据
function M:updateHeroContent(obj, heroOid)
	local hero_data,hero_cfg = self.m_model:getHero(heroOid)
	CommonUIUtil:updateHeroElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1}, self.m_hero_is_big)
	CommonUIUtil:updateHeroLvByData(obj, hero_data, self.m_hero_is_big)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	if luaBehaviour then
		local yishangzhen = luaBehaviour:FindGameObject("battle_img") --已上阵
		local duigoudi_img = luaBehaviour:FindGameObject("duigou_img") --对勾
		local lock_image = luaBehaviour:FindGameObject("lock_img") --锁
		local mask_img = luaBehaviour:FindGameObject("mask_img") --
		local recommend_img = luaBehaviour:FindGameObject("recommend_img") -- 推荐
		recommend_img:SetActive(self.m_model:isAdditionRace(hero_cfg.race))
		local in_team_flag = self.m_model:checkInTeams(heroOid)
		duigoudi_img:SetActive(in_team_flag)
		yishangzhen:SetActive(in_team_flag)
		lock_image:SetActive(self.m_model:inquireApostleTimes(heroOid) or (not in_team_flag and (self.m_model:checkIsInTeam(heroOid) or self.m_model:inquireApostleInTeam(heroOid))) )
		if in_team_flag == false then
			mask_img:SetActive(self.m_model:inquireApostleTimes(heroOid) or (not in_team_flag and (self.m_model:checkIsInTeam(heroOid) or self.m_model:inquireApostleInTeam(heroOid))) )
		end
		local is_die, hero_dyns = self.m_model:heroIsDie(heroOid)
		local cardIcon_img = luaBehaviour:FindImage("item_img")
		if is_die then
			cardIcon_img.material = self.m_gray_image.material
		elseif self.m_model:inquireApostleTimes(heroOid) == true or (not in_team_flag and (self.m_model:checkIsInTeam(heroOid) == true or self.m_model:inquireApostleInTeam(heroOid))) == true then
			cardIcon_img.material = self.m_gray_image.material
		else
			cardIcon_img.material = nil
		end
		local assist_img = luaBehaviour:FindGameObject("assist_img")
		assist_img:SetActive(hero_data.assist_flg == true)
		local apostle_img = luaBehaviour:FindGameObject("apostle_applay_img")
		apostle_img:SetActive(hero_data.apostle_flag == true)
		local master_img = luaBehaviour:FindGameObject("master_img")
		master_img:SetActive(false)
		if self.m_hero_is_big then
			local hp_pct = hero_dyns.hp_pct or 10000 -- 血量万分比
			local mp_pct = hero_dyns.mp_pct or 0 -- 怒气万分比
			CommonUIUtil:updateHeroHpSlider(obj, hp_pct/10000, mp_pct/10000)
		end
	end
	self:setParticleRenderOrder(obj)
end

function M:showFormationList()
	self.m_model.m_show_status = 1
	self:setObjectVisible("multi_formation_list_node", true)
	self:setObjectVisible("team_edit_node", false)
	self:refreshUI()
end

function M:showTeamEdit(index, main_team)
	self.m_model.m_show_status = 2
	self.m_model.m_sel_formation_index = index or self.m_model.m_sel_formation_index
	self.m_model.m_main_team = main_team or self.m_model.m_main_team
	self:setObjectVisible("multi_formation_list_node", false)
	self:setObjectVisible("team_edit_node", true)
	self:refreshUI()
end

function M:setToggleActive(flag)
	self.m_race_toggle_flag = flag
	self.m_race_toggle_bg:SetActive(flag)
end

function M:destroy()
	self:updateMsg("set_click", true, "Formation")
	M.super.destroy(self)
end

return M