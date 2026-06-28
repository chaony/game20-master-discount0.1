local M = class("UnionArtifactPopView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionArtifactPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TRIPOD_TAB = {
	{name = "", big_icon = "a_bh_icon_tanke_da"},
	{name = "", big_icon = "a_bh_fu_da"},
	{name = "", big_icon = "a_bh_icon_waigong_da"},
	{name = "", big_icon = "a_bh_gong_da"},
	{name = "", big_icon = "a_bh_icon_mushi_da"},
	{name = "", big_icon = "a_bh_icon_neigong_da"},
}
function M:onEnter()
	self:setTextByLanKey("close_title_text", "new_str_0404")
	self:setTextByLanKey("hero_title_text", "new_str_0406")
	self:setTextByLanKey("attr_title_text", "union_str_0066")
	self:setTextByLanKey("lv_btn_text", "new_str_0407")
	self:setTextByLanKey("give_btn_text", "new_str_0408")
	self:setTextByLanKey("none_hero_tips_text", "union_str_0021")
	self:setTextByLanKey("none_attrs_tips_text", "union_str_0022")
	self:setTextByLanKey("reset_btn_text", "new_str_0432")
	self.m_gray_img = self:findImage("gray_img")
	UserDataManager:removeRedDotByKey("tripod_once")
	RedPointUtil:saveLocalRedPointFreshTime("tripod_day_once")
	self:refreshUI()
end

function M:refreshUI()
	-- 和帮会等级一致
	local artifact_lv = self.m_model.m_guild_lv or 0
	if artifact_lv > 0 then
		self:setTextByLanKey("artifact_lv_ext", "new_str_0405", artifact_lv)
		self:setObjectVisible("lv_btn", true)
		self:setObjectVisible("reset_btn", true)
		self:setObjectVisible("upgrade_btn", false)
		--self:setObjectVisible("cost_bg_img", true)
	else
		self:setTextByLanKey("artifact_lv_ext", "union_str_0047")
		self:setObjectVisible("lv_btn", false)
		self:setObjectVisible("reset_btn", false)
		self:setObjectVisible("upgrade_btn", false)
		--self:setObjectVisible("cost_bg_img", false)
	end

	for k,v in pairs(self.m_model.m_guild_tripod_types) do
		local cfg = self.m_model:getTripodCfgByType(v.guild_tripod_type, 2)
		local lv = cfg.layer or 0
		local name = Language:getTextByKey(v.name)
		self:setTextByLanKey("type_" .. k .. "_lv_text", "new_str_0075", lv)
		self:setTextByLanKey("add_type_level_Text", "new_str_0409", name)
	end
	self:selectBtn(self.m_model.m_select_index)
end

function M:selectBtn(index)
	for i = 1,6 do
		local type_bg_btn = self:findButton("type_bg_btn_" .. i)
		type_bg_btn.interactable = i ~= index
		local type_btn = self:findButton("type_btn_" .. i)
		type_btn.interactable = i ~= index
		self:setObjectVisible("type_btn_" .. i .. "_sel", i == index)
		local gripid_tab = __TRIPOD_TAB[i]
		self:setImg(gripid_tab.big_icon, "maze_stage_ui" ,"type_btn_" .. i)
	end
	local data = self.m_model:getSelectGuildTripod()
	local cfg, lv = self.m_model:getTripodCfgByType(data.guild_tripod_type, 2)
	Logger.log(lv,"tripod_type lv ====")
	local up_attrs = self.m_model:computerUpAttrsValue(data.guild_tripod_type)
	self.m_curAttrPoint = 0
	for i=1, 6 do
		local attr_img = self:findImage("attr_img_" .. i)
		local luaBehaviour = UIUtil.findLuaBehaviour(self:findGameObject("attr_bg_img_" .. i))
		--local effect = luaBehaviour:FindGameObject("Fx_UnionArtifactPop_Loop_001")
		local attr_up_text = luaBehaviour:FindText("attr_up_text")
		local attr_up_bg = luaBehaviour:FindImage("attr_up_bg")
		local order = cfg.order and cfg.order%7 or 0
		if order + 1 == i then
			--effect:SetActive(true)
			self.m_curAttrPoint = i
		else
			--effect:SetActive(false)
		end
		
		if i > order then
			attr_img.material = self.m_gray_img.material
			attr_up_bg.material = self.m_gray_img.material
			attr_up_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
		else
			attr_img.material = nil
			attr_up_bg.material = nil
			attr_up_text.color = GlobalConfig.COMMON_COLLOR.COMMON_18
		end
		local attr_cfg = GameUtil:getAttrCfg(up_attrs[i][1])
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_up_text",Language:getTextByKey(attr_cfg.name) .. "+" .. (attr_cfg.is_percent == 1 and tostring(up_attrs[i][2]*100) .. "%" or tostring(up_attrs[i][2])))
	end
	self:selectInfo()
end

function M:playLvEffect()
	self.m_control:setOnceTimer(0.6, function()
		U3DUtil:Destroy(lizi_01)
	end)
end

function M:selectInfo()
	local guild_tripod = self.m_model:getSelectGuildTripod()
	local cfg = self.m_model:getTripodCfgByType(guild_tripod.guild_tripod_type)
	local name = Language:getTextByKey(cfg.name or guild_tripod.name)
	self:setTextByLanKey("add_type_level_Text", "new_str_0409", name)
	self:updateHeroLoopScroll(cfg.heroes_list or {})
	self:updateAttrLoopScroll(cfg.attr or {})
	
	local lvUpCost, next_cfg = self.m_model:getGuildTripodLvUpCost()
	
	local tripod_coin = UserDataManager.user_data:getUserStatusDataByKey("tripod_coin")
	local user_num = GameUtil:formatValueToString(tripod_coin)
	if next(lvUpCost) ~= nil then
		--self:setObjectVisible("cost_bg_img", true)
		self:setObjectVisible("upgrade_btn", false)
		local cost_data = RewardUtil:getProcessRewardData(lvUpCost)
		local data_num = GameUtil:formatValueToString(lvUpCost[3])
		self:setTextByLanKey("cost_text", data_num)
		self:setTextByLanKey("lv_btn_text", "union_str_1040")
		self:setImg(cost_data.icon_name, cost_data.atlas_name, "lv_btn_cost_img")
	else
		--self:setObjectVisible("cost_bg_img", false)
		self:setObjectVisible("upgrade_btn", true)
		self:setTextByLanKey("upgrade_btn_text", "new_str_0407")
	end

	local guild_lv = self.m_model.m_guild_lv or 0
	local condition_lv = next_cfg.condition_lv or 0
	if guild_lv > 0 then
		if condition_lv > guild_lv then
			--self:setObjectVisible("cost_bg_img", false)
			self:setObjectVisible("upgrade_btn", false)
			self:setObjectVisible("artifact_lv_ext", true)
			self:setTextByLanKey("artifact_lv_ext", "union_str_0050", condition_lv)
		else
			self:setObjectVisible("artifact_lv_ext", false)
		end
	end
	self:setText("coin_num_text", user_num)
	local tripod_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.TRIPOD_COIN,0,user_num})
	self:setImg(tripod_data.icon_name, tripod_data.atlas_name, "coin_img")
	local gripid_tab = __TRIPOD_TAB[guild_tripod.guild_tripod_type]
	self:setImg(gripid_tab.big_icon, "maze_stage_ui", "select_big_img")
end

--[[
	创建列表
]]
function M:updateHeroLoopScroll(hero_list)
	local data = self.m_model:getHerosList(hero_list)
	self:setObjectVisible("none_hero_tips_text", #data == 0)
	if self.m_hero_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("hero_scroll")
		local params = {
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				 GameUtil:updateHeroContentByRewardData(cell_object,data.item_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_UnionArtifactPop_JiaCheng_01", false)
				local hero_img = luaBehaviour:FindImage("hero_img")
				if data.activation_flag == 0 then
					hero_img.material = self.m_gray_img.material
				else
					hero_img.material = nil
				end
				luaBehaviour:InjectionFunc()
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end,
			ui_name = self.m_uiName
		}
		self.m_hero_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_hero_loop_scroll_view:reloadData(data)
	end
end

--[[
	创建列表
]]
function M:updateAttrLoopScroll(data)
	self:setObjectVisible("none_attrs_tips_text", #data == 0)
	if self.m_attr_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("attr_scroll")
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local attr_cfg = GameUtil:getAttrCfg(data[1])
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text",attr_cfg.name)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"add_value_text","+" .. (attr_cfg.is_percent == 1 and tostring(data[2]*100) .. "%" or tostring(data[2])))
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end,
			ui_name = self.m_uiName
		}
		self.m_attr_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_attr_loop_scroll_view:reloadData(data)
	end
end

function M:creatLevelUpEffect(attr_id)
	if attr_id == nil then
		return
	end
	if self.lup_effect then
		if not IsNull(self.lup_effect) then
			self.lup_effect:SetActive(false)
		end
	end
	if self.lup_hou_effect then
		if not IsNull(self.lup_hou_effect) then
			self.lup_hou_effect:SetActive(false)
		end
	end
	if self.attr_effect then
		if not IsNull(self.attr_effect) then
			self.attr_effect:SetActive(false)
		end
	end

	for k,v in pairs(self.m_hero_loop_scroll_view.m_cache_cells) do
		local luaBehaviour = UIUtil.findLuaBehaviour(v)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_UnionArtifactPop_JiaCheng_01", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_UnionArtifactPop_JiaCheng_01", true)
	end

	if attr_id == 0 then
		self.lup_effect = self:findGameObject("UI_Union_xtb_QIAN_center")
	else
		local attr_img = self:findGameObject("attr_bg_img_" .. attr_id)
		local luaBehaviour = UIUtil.findLuaBehaviour(attr_img)
		self.lup_effect = luaBehaviour:FindGameObject("UI_Union_xtb_QIAN")
		self.lup_hou_effect = luaBehaviour:FindGameObject("UI_Union_xtb_HOU_" .. attr_id)
	end

	self.attr_effect = nil
	local attr_node = self.m_attr_loop_scroll_view.m_cache_cells[attr_id]
	if attr_node then
		local luaBehaviour = UIUtil.findLuaBehaviour(attr_node)
		self.attr_effect = luaBehaviour:FindGameObject("UI_UnionArtifactPop_JingYan_01")
		self.attr_effect:SetActive(true)
	end
	
	self.lup_effect:SetActive(true)

	if self.lup_hou_effect then
		if not IsNull(self.lup_hou_effect) then
			self.lup_hou_effect:SetActive(true)
		end
	end
	local function laterTime()
		if self.lup_effect then
			if not IsNull(self.lup_effect) then
				self.lup_effect:SetActive(false)
			end
		end

		if self.attr_effect then
			if not IsNull(self.attr_effect) then
				self.attr_effect:SetActive(false)
			end
		end
		for k,v in pairs(self.m_hero_loop_scroll_view.m_cache_cells) do
			local luaBehaviour = UIUtil.findLuaBehaviour(v)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_UnionArtifactPop_JiaCheng_01", false)
		end
		self.lup_hou_effect = nil
	end
	self.m_control:setOnceTimer(0.8, laterTime)
end

return M