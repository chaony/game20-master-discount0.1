local M = class("HeavenEarthView",LikeOO.OOPopBase)

M.m_uiName = "HeavenEarth/HeavenEarth"
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setObjectVisible("guide_btn", false) --快速导航
    local btn_data = BtnOpenUtil:getBtnCfg(338)
    self:setTextByLanKey("close_title_text", btn_data.name)
    self:setTextByLanKey("upgrade_btn_text", "heavenEarth_text_010")
    self:setTextByLanKey("lv_max_text", "heavenEarth_text_011")
    --self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 56})
    self:refreshUI()
end

function M:refreshUI()
    self:updateLeftScroll()
    local team = self.m_model.m_teams[1]
    self:refreshRight(team, true)
    self:updateMsg("set_cell", team)
end

function M:updateLeftScroll()
    local data = self.m_model.m_teams
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("scroll_list")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
                self:listHandle(cell_object, index, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_select_obj ~= nil then
                    local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_obj)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img",false)
                end
                self.m_select_obj = cell_object
                local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_obj)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img",true)
                self:updateMsg("click_cell", cell_data)
			end,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
end

function M:listHandle(obj, index, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_mask", cell_data.state == 0) -- 遮罩
    local icon_big_name = cell_data.icon or "a_tdzz_cylfz"
    local cell_icon = luaBehaviour:FindImage("cell_icon")
    local cell_mask = luaBehaviour:FindImage("cell_mask")
    GameUtil:updateResourcesImg(cell_icon,"Texture/heaven_earth/"..icon_big_name) --设置背景
    GameUtil:updateResourcesImg(cell_mask,"Texture/heaven_earth/"..icon_big_name) --设置背景
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", cell_data.name)
    if index == 1 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", true) -- 亮光
        self.m_select_obj = obj
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", false) -- 亮光
    end
    local level = self.m_model:getTeamLV(cell_data.id)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", level)
end

function M:refreshSelectTeamLv(team_id)
    local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_obj)
    local level = self.m_model:getTeamLV(team_id)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", level)
end

function M:refreshRight(team, is_refresh_heroes)
    local level = self.m_model:getTeamLV(team.id)
    self:setTextByLanKey("team_name_text", "heavenEarth_text_005", team.name, level)
    if is_refresh_heroes then
        self:refreshHeroes(team.cond_array)
    end
    local cost_array = self.m_model:getUpgradeCost(team.id, level + 1)
    if cost_array == nil then --满级
        self:setObjectVisible("upgrade_node", false)
        self:setObjectVisible("effect_max_node", true)
        self:setTextByLanKey("effect_max_title_text", "heavenEarth_text_003", level)
        self:updateEffectMaxScroll(team, level)
    else
        self:setObjectVisible("effect_max_node", false)
        self:setObjectVisible("upgrade_node", true)
        self:setTextByLanKey("effect_title_text", "heavenEarth_text_003", level)
        self:setTextByLanKey("effect_title_text2", "heavenEarth_text_003", level + 1)
        self:updateEffectScroll(team, level)
        --升级消耗
        local length = 3
        for i = 1, length do
            local index = length - i + 1
            if cost_array[index] == nil then
                self:setObjectVisible("cost_" .. i, false)
            else
                self:setObjectVisible("cost_" .. i, true)
                local cost = RewardUtil:getProcessRewardData(cost_array[index])
                local cost_value = cost.data_num
                local cur_value = cost.user_num --UserDataManager.user_data:getUserStatusDataByKey("coin")
                if cur_value < cost_value then
                    self:setText("cost_text_" .. i, "<color=#AE5441>" .. GameUtil:formatValueToString(cur_value) .. "</color>/" .. GameUtil:formatValueToString(cost_value))
                else
                    self:setText("cost_text_" .. i, GameUtil:formatValueToString(cur_value) .. "/" .. GameUtil:formatValueToString(cost_value))
                end
                self:setImg(cost.icon_name, cost.atlas_name or "item_icon", "cost_img_" .. i)
            end
        end
    end
end

function M:refreshHeroes(cond_array)
    for i = 1, 6 do
        local cond = cond_array[i]
        local obj = self:findGameObject("hero_cell_" .. i)
        if cond == nil then
            obj:SetActive(false)
        else
            obj:SetActive(true)
            local luaBehaviour = UIUtil.findLuaBehaviour(obj)
            LuaBehaviourUtil.setImg(luaBehaviour, "item_img", "TX_Temp", "hero_head_ui")
            LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", "a_ui_currency_ws_lan_small", "hero_head_ui")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sp_img", false)
            if cond[1] == 1 then
                local sex = cond[3]
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "type_img", sex == 1 and "a_tdzz_nanjiaobiao" or "a_tdzz_nvjiaobiao", ResourceUtil:getLanAtlas())
            elseif cond[1] == 2 then
                local job_type = cond[3]
                local job_cfg = GlobalConfig.CLASS_MERIDIAN[job_type] or GlobalConfig.CLASS_MERIDIAN[1]
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "type_img", job_cfg.pro_icon, ResourceUtil:getLanAtlas())
            elseif cond[1] == 3 then
                local hero_id = cond[2]
                local hero_quality = cond[3]
                local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
                local frame_name = quality_item.hero_item_frame
                LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
                local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
                if hero_cfg ~= nil then
                    LuaBehaviourUtil.setImg(luaBehaviour,"item_img", hero_cfg.icon, "hero_head_ui")
                end
            elseif cond[1] == 4 then
                local sp_type = cond[2]
                local hero_quality = cond[3]
                local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
                local frame_name = quality_item.hero_item_frame
                LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
                local sp_cfg = GlobalConfig.SP_TYPE_SETTING[sp_type]
                if sp_cfg ~= nil then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sp_img", true)
                    LuaBehaviourUtil.setImg(luaBehaviour,"sp_img", sp_cfg.icon,"hero_ui")
                end
            end
        end
    end
end

function M:updateEffectScroll(team, level)
    local data = team.array
    self.m_team_lv = level
    local all_cell_size = {}
    for i,v in ipairs(data or {}) do
        local height = self:getEffectContentHeight(v, level)
        all_cell_size[i] = Vector2(550, height)
    end
	if self.m_effect_scroll == nil then
		local list_scroll = self:findGameObject("effect_list")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = list_scroll,
            all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
                self:effectListHandle(cell_object, index, cell_data)
			end,
            --click_func = function(index, cell_object, cell_data, click_object, click_name)
			--end,
		}
		self.m_effect_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_effect_scroll:reloadData(data, false, all_cell_size)
	end
end

function M:updateEffectMaxScroll(team, level)
    local data = team.array
    self.m_team_lv = level
    local all_cell_size = {}
    for i,v in ipairs(data or {}) do
        local height = self:getEffectContentHeight(v, level)
        all_cell_size[i] = Vector2(550, height)
    end
    if self.m_effect_max_scroll == nil then
        local list_scroll = self:findGameObject("effect_max_list")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = list_scroll,
            all_cell_size = all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                self:effectListHandle(cell_object, index, cell_data)
            end,
            --click_func = function(index, cell_object, cell_data, click_object, click_name)
            --end,
        }
        self.m_effect_max_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_effect_max_scroll:reloadData(data, false, all_cell_size)
    end
end

function M:effectListHandle(obj, index, cell_data)
    local array = self.m_model:getArray(cell_data)
    --local cond_array = self.m_model:formatCond(array.activate_array)
    --local cond_num = #cond_array
    local cur_desc = self.m_model:getEffectText(cell_data, self.m_team_lv)
    local next_desc = self.m_model:getEffectText(cell_data, self.m_team_lv + 1)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name", array.activate_desc)
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name", "heavenEarth_text_012", cond_num)
    if next_desc == nil then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"effect_text3", cur_desc)
        local text = luaBehaviour:FindText("effect_text3")
        local height = text.preferredHeight
        local one_rect = luaBehaviour:FindGameObject("one"):GetComponent("RectTransform")
        one_rect.sizeDelta = Vector2(550, height + 16)
        local bg_rect = luaBehaviour:FindGameObject("cell_bg"):GetComponent("RectTransform")
        bg_rect.sizeDelta = Vector2(550, height + 16 + 46)
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"effect_text1", cur_desc)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"effect_text2", next_desc)
        local text = luaBehaviour:FindText("effect_text2")
        local height = text.preferredHeight
        local two_rect = luaBehaviour:FindGameObject("two"):GetComponent("RectTransform")
        two_rect.sizeDelta = Vector2(550, height + 16)
        local bg_rect = luaBehaviour:FindGameObject("cell_bg"):GetComponent("RectTransform")
        bg_rect.sizeDelta = Vector2(550, height + 16 + 46)
    end
end

function M:getEffectContentHeight(id, team_lv)
    local cur_desc = self.m_model:getEffectText(id, team_lv)
    local next_desc = self.m_model:getEffectText(id, team_lv + 1)
    if next_desc == nil then
        self:setTextByLanKey("check_effect_text3", cur_desc)
        local text = self:findText("check_effect_text3")
        local height = text.preferredHeight + 16 + 46--36是标题高度
        return height
    else
        self:setTextByLanKey("check_effect_text1", cur_desc)
        self:setTextByLanKey("check_effect_text2", next_desc)
        local text = self:findText("check_effect_text2")
        local height = text.preferredHeight + 16 + 46--36是标题高度
        return height
    end
end

function M:destroy()
    M.super.destroy(self)
    --if self.m_attr_node then
    --    self.m_attr_node:destroy()
    --    self.m_attr_node = nil
    --end
end

return M