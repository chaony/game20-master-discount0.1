--- 阵型
local M = class("PlayerFormationNode",LikeOO.OOUIbase)

M.m_uiName = "Pops/PlayerInfo/PlayerFormationNode"

function M:onEnter()
	-- self:setTextByLanKey("title_text", "new_str_0118")
	self:setTextByLanKey("formation_title_text", "new_str_0119")
	self:setTextByLanKey("guild_title_text", "new_str_0444")
	self:setTextByLanKey("combat_num_title_text", "advanced_str_0005")
	self.m_team_node = self:findGameObject("team_node")
	local options_heros = self:findGameObject("options_heros")
	self.m_options_heros = options_heros
	options_heros.transform.parent = self.m_control.m_view.m_rootView.transform
	options_heros.transform.localScale = Vector3.one
    self:refreshUI()
end

function M:refreshUI()
	local data = self.m_model:getDataByIndex(self.m_params.index)
	local user = data.user or {}
	local gender_cfg_item = GlobalConfig.GENDER_CFG[user.gender]
	if gender_cfg_item then
		self:setTextByLanKey("gender_text", gender_cfg_item.name)
		self:setImg(gender_cfg_item.icon, gender_cfg_item.atlas, "gender_img")
		-- self:setObjectVisible("gender_text", true)
		self:setObjectVisible("gender_img", false)
	else
		-- self:setObjectVisible("gender_text", false)
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
	self:setText("combat_num_text", tostring(data.combat))
	local guild_name = user.guild_name or ""
	if guild_name == "" then
		self:setTextByLanKey("guild_text", "new_str_0092")
	else
		self:setText("guild_text", tostring(user.guild_name))
	end
	local show_heros = self.m_model:getAtkHeros(data)
    local team_node = UIUtil.findRectTransform(self.m_team_node)
    local function lookHero(click_object, click_name, idx, cell_data)
    	self:updateMsg("look_hero", {oid = cell_data.card_id, data = self.m_model:getLookHerosData(data)})
    end
    self:createHeros(team_node, show_heros, false, false, lookHero)
    self:createFormationHeros(data)
end

function M:createHeros(team_node, rewards, is_show_num, is_show_detail, callback)
    local rewards = rewards or {}
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node" .. i)
		local item_data = rewards[i]
		if item_data and _G.next(item_data) then
			local ui_element = CommonUIUtil:updateHeroElementByData(hero_node, item_data, callback)
			CommonUIUtil:updateHeroLvByData(hero_node, item_data.hero_data)
		else
			CommonUIUtil:updateHeroElementAdd(hero_node)
		end
	end
end

-- TODO 需要改成3D模型展示
function M:createFormationHeros(data)
	local atk_team = data.team or {}
	local atk_heros = data.heros or {}
	local deployment = data.deployment or 1
	for i=1,5 do
		local formation_pos = self:findGameObject("formation_pos_" .. i)
		local team_node_tran = UIUtil.findRectTransform(formation_pos)
		UIUtil.destroyAllChild(team_node_tran)
		local hero_id = atk_team[i] or ""
		if hero_id ~= "" then
			local prefab = GameUtil:createPrefab("Pops/PlayerInfo/PlayerInfoHeroItem", team_node_tran)
			local hero_data = atk_heros[hero_id] or {}
			local transform = prefab.transform
			local lv = hero_data.lv
			if hero_data.clv and hero_data.clv > 0 then
				lv = hero_data.clv
			end
			UIUtil.setTextByLanKey(transform, "lv_text", "new_str_0075", lv)
			-- local hero_spine = transform:Find("hero_spine")
			-- hero_spine.gameObject:SetActive(false)
			-- GameUtil:setHeroSpineAnim(hero_spine, hero_data.id)
			local race_img = UIUtil.findTrans(transform, "race_img")
			GameUtil:setHeroRace(race_img, hero_data.id)
			
			local luaBehaviour = UIUtil.findLuaBehaviour(transform)
			local deployment_cfg = ConfigManager:getCfgByName("deployment")
			local deployment_cfg_item = deployment_cfg[deployment] or {}
			local key_pos = deployment_cfg_item.key_pos or 0 -- 阵眼序号
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "flag_img", key_pos == i)
			
			local rol = self:findGameObject("rol_" .. i)
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
			local hero_skin_cfg = Battle.BattleConfigManager:getHeroCurSkinCfgByData_Battle(hero_data, hero_cfg)
			local prefab_name = hero_cfg["prefab"]

			if hero_skin_cfg then
				prefab_name = hero_skin_cfg.prefab or hero_cfg.prefab
			end
			local obj = ResourceUtil:LoadRole3d(prefab_name)
			if not IsNull(obj) then
				local luaViewHelper = obj:GetComponent("LuaViewHelper")
				if luaViewHelper then
					luaViewHelper.enabled = false
				end
				obj.transform:SetParent(rol.transform, false)
				obj.transform.localPosition = Vector3(0,0,0);
				obj.transform.localRotation = Quaternion.Euler(0,0,0);
				obj.transform.localScale = Vector3(1,1,1);
				--local helper = obj:GetComponent("LuaTransformHelper")
				--helper:SetAnimator(true);
				GlobalTools:CloseShadow(obj.transform)
			else
				Logger.logError(prefab_name,"LoadRole3d failed : ")
			end

			local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_cfg.evo]
			if quality_item and quality_item.hero_3d_base then
				local evo_effect = ResourceUtil:LoadCommonEffect(quality_item.hero_3d_base, nil)
				evo_effect.transform:SetParent(rol.transform, false)
				evo_effect.transform.localScale = Vector3.New(1.5, 1.5, 1.5)
			end
		end
	end
end

function M:destroy()
	if self.m_options_heros then
		local camera_obj = self:findGameObject("Camera")
		CommonUIUtil:setCameraTargetNull(camera_obj)
		U3DUtil:Destroy(self.m_options_heros)
		self.m_options_heros = nil
	end
    M.super.destroy(self)
end

return M