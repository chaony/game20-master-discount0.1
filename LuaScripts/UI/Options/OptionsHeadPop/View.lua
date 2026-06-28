local M = class("OptionsHeadPopView",LikeOO.OOPopBase)

M.m_uiName = "Options/OptionsHeadPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {"head_toggle","border_toggle","title_toggle"}
local __TAB_BTN_TEXT = {"head_toggle_text","border_toggle_text","title_toggle_text"}
function M:onEnter()	
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v)
		local tog_btn_text = __TAB_BTN_TEXT[i]
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data)
				self:setTextColor(tog_btn_text, GlobalConfig.COMMON_COLLOR.COMMON_25)
			else
				self:setTextColor(tog_btn_text, GlobalConfig.COMMON_COLLOR.COMMON_24)
			end 
		end, i, self.m_uiName)
	end
	self:setTextByLanKey("head_toggle_text", string.cutTextForString(Language:getTextByKey("head_tex")))
	self:setTextByLanKey("border_toggle_text", string.cutTextForString(Language:getTextByKey("border_tex")))
	self:setTextByLanKey("title_toggle_text", string.cutTextForString(Language:getTextByKey("title_tex")))

	self:setTextByLanKey("head_name_text", "options_str_0020")
	self.gray_img = self:findImage("gray_img")
	self:setTextByLanKey("common_title_text", "options_str_0026")
	self:setTextByLanKey("scene_text_1", "options_str_0030")
	self.attrs_pro = self:findGameObject("attrs_pro")
	self.attrs_pro_fitter = self.attrs_pro:GetComponent("ContentImmediate")
	self.m_attr_node = self:findGameObject("attr_node")
	self.m_collect_attrs_node = self:findGameObject("collect_attrs_node")
	self.m_wear_attrs_node = self:findGameObject("wear_attrs_node")
	self:setTextByLanKey("text_collect_title", "title_text_0001")
	self:setTextByLanKey("text_wear_title", "title_text_0002")
	self.head_title_img2 = self:findGameObject("head_title_img2")
	self.head_title_img3 = self:findGameObject("head_title_img3")
	self:setTextByLanKey("ok_text", "options_str_0041")
	self:setTextByLanKey("upgrade_btn_text", "options_str_0038")
	self:setTab()
	-- 设置称号图片
	local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
	self:setTitleImage(title_id)
	self.m_title_detail_item = self:findGameObject("title_detail_item")
	self.m_content_panel = self:findGameObject("content_node")
end

function M:refreshUI(refreshFlag)
	local data = self.m_model.m_head[self.m_model.m_head_index]
	local cfg = ConfigManager:getPlayerPictureCfg(data)
	local head_node = self:findGameObject("HeadNode")
	local spine = cfg.hero_spine or "hero_0001_SkeletonData"
	
	-- 设置称号图片
	self:setTitleImage(self.m_model.m_sel_title_id)
	
	if self.m_model.m_tab == 1 then
		local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
		GameUtil:setUserAvatar(head_node, {avatar = data, frame = frame}, false)
	elseif self.m_model.m_tab == 2 then
		local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
		local cur_player_picture_cfg = ConfigManager:getPlayerPictureCfg(avatar)
		spine = cur_player_picture_cfg.hero_spine or "hero_0001_SkeletonData"
		local border_data = self.m_model.m_border[self.m_model.m_border_index] or {}
		GameUtil:setUserAvatar(head_node, {avatar = avatar, frame = border_data.id}, false)
	else
		local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
		local cur_player_picture_cfg = ConfigManager:getPlayerPictureCfg(avatar)
		spine = cur_player_picture_cfg.hero_spine or "hero_0001_SkeletonData"
		local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
		GameUtil:setUserAvatar(head_node, {avatar = avatar, frame = frame}, false)
		self:updateTitleList(refreshFlag)
	end
	
	--local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
	--self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	--local FRAME_QUA = GlobalConfig.QUALITY_FRAME[cfg.max_evo]
	--self:setImg(FRAME_QUA.line_frame_name, "common_ui", "hero_evo")
	--self:setTextByLanKey("hero_name", Language:getTextByKey(cfg.name).."·".. Language:getTextByKey(cfg.class))
	self:setTextByLanKey("hero_name", string.cutTextForString(Language:getTextByKey(cfg.name)))
	local hero_sk = self:findGameObject("hero_sk")

	GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/"..spine, "idle", 0, true)
	--GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/"..spine, "pose", 0, false)
	if cfg.unlock == 1 then
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(data)
		if hero_cfg.evo > 3 then
			local player_picture_cfg_item = ConfigManager:getPlayerPictureCfg(data)
			local evo_name = GlobalConfig.QUALITY_FRAME[player_picture_cfg_item.unlock_evo].evo_name
			self:setTextByLanKey("scene_title_text", "options_str_0036",Language:getTextByKey(evo_name))
		else
			self:setTextByLanKey("scene_title_text", "options_str_0029")
		end
	elseif cfg.unlock == 2 then
		self:setTextByLanKey("scene_title_text", "options_str_0028")
	elseif cfg.unlock == 3 then
		self:setTextByLanKey("scene_title_text", "options_str_0032")
	end
	-- 头像框
	local border_data = self.m_model.m_border[self.m_model.m_border_index]
	if border_data then
		self:setTextByLanKey("head_name_text", string.cutTextForString(tostring(border_data.cfg.name)))
		self:setTextByLanKey("head_des_text", tostring(border_data.cfg.des))
	else
		self:setTextByLanKey("head_name_text", "options_str_0020")
		self:setTextByLanKey("head_des_text", "")
	end
	
	self:refreshRedPoint()
end

function M:setTab()
	self:setObjectVisible("head_scroll", self.m_model.m_tab == 1)
	self:setObjectVisible("border_scroll", self.m_model.m_tab == 2)
	self:setObjectVisible("title_scroll", self.m_model.m_tab == 3)
	self:setObjectVisible("hero_obj", self.m_model.m_tab == 1)
	self:setObjectVisible("head_obj", self.m_model.m_tab == 2)
	self:setObjectVisible("title_obj", self.m_model.m_tab == 3)
	self:setObjectVisible("head_name_img", self.m_model.m_tab ~= 3)
	self:setObjectVisible("head_name_img_title", self.m_model.m_tab == 3)
	self:setObjectVisible("hero_name_title", self.m_model.m_tab == 3)
	self.m_model.m_sel_title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
	if self.m_model.m_tab == 1 then
		self:updateHeadList()
	elseif self.m_model.m_tab == 2 then
		self:updateBorderList()
	elseif self.m_model.m_tab == 3 then
		self:updateTitleList()
	end
	self:refreshUI()
	self:setTitleAttrBtnState()
end

function M:setTitleAttrBtnState()
	local isShowTitleAttrBtn = false
	if self.m_model.m_tab == 3 then
		local titlesData = self.m_model:getTitleData()
		for _, itemData in pairs(titlesData) do
			if itemData.owner ~= 0 then
				isShowTitleAttrBtn = true
				break
			end
		end
	end
	self:setObjectVisible("btn_attribute", (self.m_model.m_tab == 3) and (isShowTitleAttrBtn))
end

-- 设置称号图片
function M:setTitleImage(title_id)
	if title_id and title_id ~= 0 then
		self.head_title_img2:SetActive(true)
		self:setObjectVisible("title_obj", self.m_model.m_tab == 3)
		local name_img = self.head_title_img2:GetComponent("Image")
		local cfg = self.m_model:getTitleCfgById(title_id)
		UIUtil.destroyAllChild(name_img.gameObject.transform)
		if cfg.title_effect and cfg.title_effect ~= "" then
			name_img.enabled = false
			ResourceUtil:GetUIEffectItem("Headtitle/"..cfg.title_effect, self.head_title_img2)
		else
			name_img.enabled = true
			GameUtil:setTextureLoadTitleLanImgText(self.head_title_img2, cfg.icon) -- 设置称号图片
			name_img:SetNativeSize()
		end
		if self.m_model.m_tab == 3 then
			self.head_title_img3:SetActive(true)
			self.head_title_img2:SetActive(false)
			local name_img3 = self.head_title_img3:GetComponent("Image")
			UIUtil.destroyAllChild(name_img3.gameObject.transform)
			if cfg.title_effect and cfg.title_effect ~= "" then
				name_img3.enabled = false
				ResourceUtil:GetUIEffectItem("Headtitle/"..cfg.title_effect, self.head_title_img3)
			else
				name_img3.enabled = true
				GameUtil:setTextureLoadTitleLanImgText(self.head_title_img3, cfg.icon) -- 设置称号图片
				name_img3:SetNativeSize()
			end
		end
	else
		self.head_title_img3:SetActive(false)
		self.head_title_img2:SetActive(false)
		self:setObjectVisible("title_obj", false)
	end
end

function M:updateHeadList()
	self.m_select_head_obj = nil
	local data = self.m_model.m_head
	if self.m_head_scroll == nil then
		local list_scroll = self:findGameObject("head_scroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:headHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if not IsNull(self.m_select_head_obj) then 
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_head_obj)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", false)
				end
				self.m_select_head_obj = cell_object
				local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_head_obj)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", true)
				self:updateMsg("click_head", index)
			end,
			ui_name = self.m_uiName
		}
		self.m_head_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_head_scroll:reloadData(data,true)
	end
end

function M:updateBorderList()
	self.m_select_border_obj = nil
	local data = self.m_model.m_border
	if self.m_border_scroll == nil then
		local list_scroll = self:findGameObject("border_scroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:borderHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if not IsNull(self.m_select_border_obj) then
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_border_obj)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", false)
				end
				self.m_select_border_obj = cell_object
				local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_border_obj)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", true)
				self:updateMsg("click_border", {index = index, cell_data = cell_data})
			end,
			ui_name = self.m_uiName
		}
		self.m_border_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_border_scroll:reloadData(data,true)
	end
end

function M:updateTitleList(refreshFlag)
	local cfg = self.m_model:getTitleCfgById(self.m_model.m_sel_title_id)
	self:setTextByLanKey("item_des_text", Language:getTextByKey(cfg.lock_des))

	local collect_cfg_attrs = self.m_model:getTitleCollectAttrById(self.m_model.m_sel_title_id)
	local collect_attrs = UserDataManager:newAppendAttrs(collect_cfg_attrs)
	self:setObjectVisible("text_collect_title", table.nums(collect_attrs)>0)
	self:updateLoopScroll(collect_attrs, self.m_collect_attrs_node, self.m_attr_node ) -- 收集属性展示

	local wear_cfg_attrs = self.m_model:getTitleWearAttrById(self.m_model.m_sel_title_id)
	local wear_attrs = UserDataManager:newAppendAttrs(wear_cfg_attrs)
	self:updateLoopScroll(wear_attrs, self.m_wear_attrs_node, self.m_attr_node , true) -- 佩戴属性展示

	--称号升级按钮
	self.m_model.m_upgrade_btn_status = 1
	local titleIds = UserDataManager.title_data:getTitlesId()
	local upgrade_limited = self.m_model:titleUpgradeLimited(cfg.group) --不能升级的称号
	local material_flag = self.m_model:canTitleUpgrade(cfg) --是否有升级材料
	local owner_flag = table.indexof(titleIds, tostring(self.m_model.m_sel_title_id))
	local up_top_flag = cfg.next_id and cfg.next_id == 0 -- 满级
	local can_exchange = up_top_flag == true and material_flag == true -- 满级且可以兑换元宝
	local upgrade_btn_img = self:findImage("upgrade_btn")
	self:setTextByLanKey("upgrade_btn_text", "options_str_0038")
	upgrade_btn_img.material = nil
	if owner_flag == false or material_flag == false then
		upgrade_btn_img.material = self.gray_img.material	--	尚未拥有此称号时，或者没有升级材料时，升级按钮置灰
	end
	if up_top_flag == true then
		self:setTextByLanKey("upgrade_btn_text", "options_str_0039")
	end
	if can_exchange == true then
		self:setTextByLanKey("upgrade_btn_text", "options_str_0040")
		self.m_model.m_upgrade_btn_status = 2
	end
	local upgrade_btn_flag = owner_flag ~= false --可以升级的称号，拥有称号就展示，可以升级，可以已满级，可以兑换元宝
	if upgrade_limited == true and owner_flag ~= false then --不可升级的称号，只有可兑换元宝的时候才展示
		upgrade_btn_flag = can_exchange
	end
	upgrade_btn_flag = upgrade_btn_flag and cfg.exp and cfg.exp > 0 --有exp表示此称号配置了升级和兑换，没配置就不允许升级和兑换
	if cfg and cfg.id and upgrade_btn_flag then 
		self:setObjectVisible("upgrade_btn", true)
	else
		self:setObjectVisible("upgrade_btn", false)
	end
	self:setObjectVisible("upgrade_title_red_point_img", owner_flag ~= false and material_flag == true and upgrade_btn_flag == true)--升级或兑换元宝按钮的红点
	
	--预览按钮
	if cfg and cfg.id and (owner_flag ~= false and upgrade_limited == false) then --拥有，且可以升级
		self:setObjectVisible("title_preview_btn", true)
	else
		self:setObjectVisible("title_preview_btn", false)
	end
	
	--详情按钮
	if cfg and cfg.id and upgrade_btn_flag == true then
		local detail_title_cfg = self.m_model:getDetailTitleData(cfg.group)
		if cfg.order then
			self.m_title_detail_item:SetActive(true)
			UIUtil.destroyAllChild(self.m_title_detail_item.transform)
			local itemNode = GameUtil:createItemElement({142, cfg.order, 1}, false, true)
			--UIUtil.setScale(itemNode.transform, 0.9, 0.9)
			itemNode.transform:SetParent(self.m_title_detail_item.transform, false)
			local item_node_luaBehaviour = UIUtil.findLuaBehaviour(itemNode.transform)
			LuaBehaviourUtil.setObjectVisible(item_node_luaBehaviour, "no_panel", material_flag == false)
			LuaBehaviourUtil.setObjectVisible(item_node_luaBehaviour, "no_quality_up_img", false)
		end
	else
		self.m_title_detail_item:SetActive(false)
	end
	
	--左侧称号名和背景
	if cfg and cfg.id then
		self:setObjectVisible("head_name_img_title", true)
		self:setObjectVisible("hero_name_title", true)
	else
		self:setObjectVisible("head_name_img_title", false)
		self:setObjectVisible("hero_name_title", false)
	end
	self:setTextByLanKey("hero_name_title", Language:getTextByKey(cfg.name))
	
	--触发刷新自适应大小
	if self.attrs_pro_fitter then
		self.attrs_pro_fitter:ForceRefreshSize()
	end
	if refreshFlag ~= false then
		self:updateTitleRightList()
	end
end

function M:headHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local head_img = luaBehaviour:FindImage("head_img")
	local select_img = luaBehaviour:FindGameObject("select_img")
	local use_img = luaBehaviour:FindGameObject("use_img")
	select_img:SetActive(self.m_model.m_head_index == id)
	use_img:SetActive(self.m_model.m_avatar == data)
	if self.m_model.m_head_index == id then
		self.m_select_head_obj = obj
	end
	local cfg = ConfigManager:getPlayerPictureCfg(data)
    if cfg then
    	LuaBehaviourUtil.setImg(luaBehaviour,  "head_img", cfg.icon, "hero_head_ui")
    else
    	LuaBehaviourUtil.setImg(luaBehaviour,  "head_img", "item_icon_wenhao", "item_icon")
    end

	-- if head_img.material.name ~= "Shader/UI/UIGray" then
	--  local mat = ResourceUtil:createMaterial("Shader/UI/UIGray")
	-- 	head_img.material = self.gray_img.material
	-- end
	-- local material = head_img.material
	local activation_state = self.m_model:playerPictureIsActivationState(data)
	if activation_state then
		-- material:SetFloat("_Gray",1)
		head_img.material = nil
	else
		-- material:SetFloat("_Gray",0)
		head_img.material = self.gray_img.material
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "border_img", false)
end

function M:borderHandle(obj, id, cell_data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local select_img = luaBehaviour:FindGameObject("select_img")
	select_img:SetActive(self.m_model.m_border_index == id)
	if self.m_model.m_border_index == id then
		self.m_select_border_obj = obj
	end
	local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
	local cfg = ConfigManager:getPlayerPictureCfg(avatar)
	local head_img = nil
	if cfg then
		head_img = LuaBehaviourUtil.setImg(luaBehaviour,  "head_img", cfg.icon, "hero_head_ui")
	else
		head_img = LuaBehaviourUtil.setImg(luaBehaviour,  "head_img", "item_icon_wenhao", "item_icon")
	end
	local frame_icon = cell_data.cfg.icon
	local border_img = LuaBehaviourUtil.setImg(luaBehaviour, "border_img", tostring(frame_icon), "hero_head_ui")
	border_img.gameObject:SetActive(true)
	UIUtil.destroyAllChild(head_img.transform)
	UIUtil.destroyAllChild(border_img.transform)
	local activation_state = self.m_model:playerFrameIsActivationState(cell_data.id)
	if activation_state then
		border_img.material = nil
		if cell_data.cfg.UI_effect1 and cell_data.cfg.UI_effect2 then
			ResourceUtil:GetUIEffectItem("Common/" .. cell_data.cfg.UI_effect1, border_img.gameObject)
			ResourceUtil:GetUIEffectItem("Common/" .. cell_data.cfg.UI_effect2, head_img.gameObject)
		end
	else
		border_img.material = self.gray_img.material
	end
	local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "use_img", frame == cell_data.id)
end

--[[function M:getAttrXlsxNameByUserKey(user_key)
	local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
	for k, v in pairs(hero_enumeration) do
		if v.user_key == value then
			return Language:getTextByKey(v.name)
		end
	end
	return "" 
end]]

--[[	
	属性列表
]]
function M:updateLoopScroll(attrs, parentNode, itemNode, wearAttrsFlag)
	local data = {}
	local levelId = 999999
	if not wearAttrsFlag then
		local title_cfg = self.m_model:getTitleCfgById(self.m_model.m_sel_title_id)
		local level_up = title_cfg.level_up
		if level_up and level_up > 0 then
			data[1] = {levelId, level_up}
		end
	end
	for i, v in pairs(attrs) do
		table.insert(data, {i, v})
	end
	parentNode:SetActive(false)
	UIUtil.destroyAllChild(parentNode.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(itemNode, parentNode.transform)
		cell_object:SetActive(true)
		local transform = cell_object.transform
		local attr_name_text = nil
		local attr_value_text = nil
		if cell_data[1] == levelId then
			attr_name_text = UIUtil.setText(transform, Language:getTextByKey("title_text_0010"), "attr_name_text")
			attr_value_text = UIUtil.setText(transform, tostring(cell_data[2]), "attr_value_text")
		else
			local cp = UserDataManager:getNewAttrsNameByAttrId(cell_data[1])
			attr_name_text = UIUtil.setText(transform, cp, "attr_name_text")
			-- 四舍五入保留小数点后一位
			local attr_value = cell_data[2] or 0
			attr_value = math.floor(attr_value * 10 + 0.5)/10
			if GameUtil:newAttrTransition(cell_data[1]) == true then
				attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value).."%", "attr_value_text")
			else
				attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value), "attr_value_text")
			end
		end
		
		local titleIds = UserDataManager.title_data:getTitlesId()
		local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
		local ownerFlag = table.indexof(titleIds, tostring(self.m_model.m_sel_title_id))
		if ownerFlag and wearAttrsFlag and self.m_model.m_sel_title_id == title_id and self.m_model.m_sel_title_id ~= 0 then
			UIUtil.setTextColor(transform, Color( 58/255, 72/255, 94/255), "attr_name_text")
			UIUtil.setTextColor(transform, Color( 58/255, 72/255, 94/255), "attr_value_text")
		elseif ownerFlag and not wearAttrsFlag then
			UIUtil.setTextColor(transform, Color( 58/255, 72/255, 94/255), "attr_name_text")
			UIUtil.setTextColor(transform, Color( 58/255, 72/255, 94/255), "attr_value_text")
		elseif ownerFlag and wearAttrsFlag and self.m_model.m_sel_title_id ~= title_id then
			UIUtil.setTextColor(transform, Color( 145/255, 145/255, 145/255), "attr_name_text")
			UIUtil.setTextColor(transform, Color( 145/255, 145/255, 145/255), "attr_value_text")
		elseif not ownerFlag then
			UIUtil.setTextColor(transform, Color( 145/255, 145/255, 145/255), "attr_name_text")
			UIUtil.setTextColor(transform, Color( 145/255, 145/255, 145/255), "attr_value_text")
		end

		local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
		UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
	end
	parentNode:SetActive(true)
end

-- 刷新title右侧列表
function M:updateTitleRightList()
	self.m_select_title_obj = nil
	local data = self.m_model:getTitleData()
	if self.m_title_scroll == nil then
		local list_scroll = self:findGameObject("title_scroll")
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:titleHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if not IsNull(self.m_select_title_obj) then
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_title_obj)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", false)
				end
				self.m_select_title_obj = cell_object
				local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_title_obj)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", true)
				self:updateMsg("click_title", {index = index, cell_data = cell_data})
			end,
		}
		self.m_title_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_title_scroll:reloadData(data,true)
	end
end

-- title item创建
function M:titleHandle(obj, index, cell_data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local select_img = luaBehaviour:FindGameObject("select_img")
	local use_img = luaBehaviour:FindGameObject("use_img")
	local title_name_img = luaBehaviour:FindGameObject("title_name_img")
	local name_img = title_name_img:GetComponent("Image")
	local red_point_img = luaBehaviour:FindGameObject("red_point_img")
	select_img:SetActive(self.m_model.m_sel_title_id == cell_data.id)
	if self.m_model.m_sel_title_id == cell_data.id then
		self.m_select_title_obj = obj
	end
	if cell_data.owner == 0 then
		name_img.material = self.gray_img.material
	else
		name_img.material = nil
	end
	local titleIds = UserDataManager.title_data:getTitlesId()
	UIUtil.destroyAllChild(title_name_img.gameObject.transform)
	if cell_data.title_effect and cell_data.title_effect ~= "" and table.indexof(titleIds,tostring(cell_data.id)) then
		ResourceUtil:GetUIEffectItem("Headtitle/"..cell_data.title_effect, title_name_img)
		name_img.enabled = false
	else
		name_img.enabled = true
		GameUtil:setTextureLoadTitleLanImgText(name_img, cell_data.icon) -- 设置称号图片
		name_img:SetNativeSize()
	end
	local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
	if title_id ==  cell_data.id then
		use_img:SetActive(true)
	else
		use_img:SetActive(false)
	end
	local material_flag = self.m_model:canTitleUpgrade(cell_data) --是否有升级材料
	local owner_flag = table.indexof(titleIds, tostring(cell_data.id))
	local up_or_exchange_flag = material_flag == true and owner_flag ~= false and cell_data.exp and cell_data.exp > 0 	--拥有此称号，且有材料，那就可以升级或者兑换元宝
	if up_or_exchange_flag then																							--有exp表示此称号配置了升级和兑换，没配置就不允许升级和兑换
		red_point_img:SetActive(true)
	else
		red_point_img:SetActive(false)
	end
end

--称号预览
function M:createTitlePreviewNode()
	self:updateTitlePreviewList()
	self:setObjectVisible("title_preview_node", true)
end
 
function M:closeTitlePreviewNode()
	self:setObjectVisible("title_preview_node", false)
end

-- 刷新称号预览列表
function M:updateTitlePreviewList()
	local title_cfg = self.m_model:getTitleCfgById(self.m_model.m_sel_title_id)
	local data = self.m_model:getTitlePreviewData(title_cfg.group)
	if self.title_preview_scroll == nil then
		local list_scroll = self:findGameObject("title_preview_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTitlePreviewListCell(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.TITLE, cell_data.id, 1})
				self.m_control:openView("Title.TitleDetail", {show_data = data, display = true})
			end,
		}
		self.title_preview_scroll = LoopScrollViewUtil.new(params)
	else
		self.title_preview_scroll:reloadData(data,true)
	end
end

function M:updateTitlePreviewListCell(obj, index, cell_data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local select_img = luaBehaviour:FindGameObject("select_img")
	local use_img = luaBehaviour:FindGameObject("use_img")
	local title_name_img = luaBehaviour:FindGameObject("title_name_img")
	local name_img = title_name_img:GetComponent("Image")
	local jian_t_img = luaBehaviour:FindGameObject("jian_t")
	select_img:SetActive(true)
	
	local titleIds = UserDataManager.title_data:getTitlesId()
	UIUtil.destroyAllChild(title_name_img.gameObject.transform)
	if cell_data.title_effect and cell_data.title_effect ~= ""then
		ResourceUtil:GetUIEffectItem("Headtitle/"..cell_data.title_effect, title_name_img)
		name_img.enabled = false
	else
		name_img.enabled = true
		GameUtil:setTextureLoadTitleLanImgText(name_img, cell_data.icon) -- 设置称号图片
		name_img:SetNativeSize()
	end
	
	--local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
	--if title_id ==  cell_data.id then
	--	use_img:SetActive(true)
	--else
	--	use_img:SetActive(false)
	--end
	use_img:SetActive(false)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_name_text", cell_data.name)
	if index == 1 then
		jian_t_img:SetActive(false)
	else
		jian_t_img:SetActive(true)
	end
end

function M:refreshRedPoint()
	local red_flag = self.m_model:getTitleMaterialStatus() --只要有材料，或者可以升级，或者可以兑换元宝
	self:setObjectVisible("title_toggle_red_point_img", red_flag)
end

return M