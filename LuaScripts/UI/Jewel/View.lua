local M = class("JewelView",LikeOO.OOPopBase)

M.m_uiName = "Jewel/Jewel"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
	{btn = "all_togglebtn", quality = 0},
	{btn = "togglebtn_4", quality = 4},
	{btn = "togglebtn_5", quality = 5},
	{btn = "togglebtn_6", quality = 6},
	{btn = "togglebtn_8", quality = 8},
}

function M:onEnter()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local obj = self:findGameObject(v.btn)
		if i == 1 then
			UIUtil.setToggleIsOn(obj.transform, true)
		end
		UIUtil.setObjectVisible(obj.transform, i == 1,"UI_ShareLv_Xuanze_01")
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("tab_btn", v.quality)
				UIUtil.setObjectVisible(obj.transform, true,"UI_ShareLv_Xuanze_01")
			else
				UIUtil.setObjectVisible(obj.transform, false,"UI_ShareLv_Xuanze_01")
			end 
		end, i, self.m_uiName)
		--右上角碎片点击事件
		if v.quality ~= 0 then
			local obj = self:findGameObject("num_node_" .. v.quality)
			local luaBehaviour = UIUtil.findLuaBehaviour(obj)
			local function button_click()
				self:updateMsg("chip_num_btn", {quality = v.quality, obj = obj})
			end
			luaBehaviour:RegistButtonClick(button_click)
		end
	end
	self:setTextByLanKey("gacha_btn_text", "jewel_text_002")
	self:setObjectVisible("guide_btn", true)--快速导航
	self:setObjectVisible("list_scroll", false)
	self.m_gray_img = self:findImage("gray_img")
	self.m_scroll_showed = false
	local function callback()
		self:refreshUI()
	end
	self.m_control:setOnceTimer(0.3, callback)
end

function M:refreshUI()
	self:setObjectVisible("list_scroll", true)
	if self.m_model.m_is_book == true then
		self:setObjectVisible("gacha_btn", false)
		self:setTextByLanKey("close_title_text", "jewel_text_016")
		self:updateBookScroll(0)
	else
		self:setObjectVisible("gacha_btn", true)
		self:setTextByLanKey("close_title_text", "jewel_text_001")
		self:updateListScroll(0)
	end
	self:refreshChipNum()
end

--图鉴列表
function M:updateBookScroll(quality)
	self.m_list_obj = {}
	local data = self.m_model:filterBooks(quality)
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local function callback()
					self:listHandle(cell_object, index, cell_data, true)
				end
				cell_object:SetActive(false)
				local length = 12
				if self.m_scroll_showed == false and index <= length then
					self.m_control:setOnceTimer(index <= length and  (0.033 * index) or 0, callback)
				else
					callback()
				end
				if index > length then
					self.m_scroll_showed = true
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_jewel", {jewel = cell_data, is_book = true})
			end,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, false)
	end
end

--秘宝列表
function M:updateListScroll(quality, is_keep_offset)
	self.m_list_obj = {}
	local data = self.m_model:filterList(quality)
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self.m_list_obj[cell_data.id] = cell_object --保存列表UI对象
				local function callback()
					self:listHandle(cell_object, index, cell_data, false)
				end
				cell_object:SetActive(false)
				local length = 12
				if self.m_scroll_showed == false and index <= length then
					self.m_control:setOnceTimer(index <= length and  (0.033 * index) or 0, callback)
				else
					callback()
				end
				if index > length then
					self.m_scroll_showed = true
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_jewel", {jewel = cell_data})
			end,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		local flag = is_keep_offset or false
		self.m_list_scroll:reloadData(data, flag)
	end
end

function M:listHandle(obj, index, cell_data, is_book)
	if obj == nil then
		return
	end
	local id = cell_data.id
	local cfg = UserDataManager.jewel_data:getDetailCfg(id) --宝物配置
	local jewel = UserDataManager.jewel_data:getJewel(id) --宝物实例
	obj:SetActive(true)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	--quality & icon & name
	LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", "card_quality" .. cfg.quality, "jewel_ui")
	local icon_obj = luaBehaviour:FindGameObject("icon_img")
	GameUtil:updateResourcesImg(icon_obj, "Texture/jewelIcon/" .. cfg.icon)
	local icon_img = luaBehaviour:FindImage("icon_img")
	if jewel == nil then
		icon_img.material = self.m_gray_img.material
	else
		icon_img.material = nil
	end
	--LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", cfg.icon, "jewel_ui")
	local name_text = LuaBehaviourUtil.setText(luaBehaviour,"name_text", Language:getTextByKey(cfg.name))
	local quality_cfg = GameUtil:getHeroQualityData(cfg.quality)
	name_text.color = quality_cfg.RGBA
	name_text.transform.localPosition = Vector3.New(0, -100, 0)
	--hero icon
	if cfg.hero_id and cfg.hero_id > 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_icon", true)
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
		LuaBehaviourUtil.setImg(luaBehaviour, "tx_img", hero_cfg.icon, "hero_head_ui")
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_icon", false)
	end
	--red point
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", false)
	--图鉴显示觉醒样子
	if is_book == true then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "awaken_img", true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "chip_slider", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "active_text", false)
		return
	end
	--not active
	if jewel == nil then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "awaken_img", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "chip_slider", true)
		local user_chip_num = cell_data.user_chip_num
		local need_chip_num = cell_data.need_chip_num
		LuaBehaviourUtil.setSliderValue(luaBehaviour, "chip_slider", user_chip_num / need_chip_num)
		LuaBehaviourUtil.setText(luaBehaviour,"chip_num", user_chip_num .. "/" .. need_chip_num)
		local is_active = user_chip_num >= need_chip_num
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "active_text", is_active == true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", is_active == true)--red point
		name_text.transform.localPosition = Vector3.New(0, -85, 0)
		return
	end
	--active
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "active_text", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "chip_slider", false)
	if jewel.awaken == 1 then --awakened
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "awaken_img", true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
	else --awaken
		self:refreshJewelStar(luaBehaviour, cfg.quality, jewel.evo)
	end
	local is_red_point = UserDataManager.jewel_data:isRedPoint(id)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", is_red_point == true)
end

--星级
function M:refreshJewelStar(luaBehaviour, quality, evo)
	local quality_cfg = GameUtil:getHeroQualityData(quality)
	local star = evo
	local star_max = 5
	for i = 1, 5 do
		local star_ui_name = "star_" .. i
		if i > star_max then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, star_ui_name, false)
		else
			if i <= star then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, star_ui_name, true)
				LuaBehaviourUtil.setImg(luaBehaviour, star_ui_name, quality_cfg.star_frame_name, "hero_head_ui")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, star_ui_name, false)
			end
		end
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "awaken_img", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", true)
end

--列表宝物更新，涉及星级、觉醒、激活
function M:refreshJewelElement(type, id)
	local obj = self.m_list_obj[id]
	if obj == nil then
		return
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if type == 1 then --激活
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "chip_slider", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "active_text", false)
		local jewel = UserDataManager.jewel_data:getJewel(id) --宝物实例
		local cfg = UserDataManager.jewel_data:getDetailCfg(id) --宝物配置
		self:refreshJewelStar(luaBehaviour, cfg.quality, jewel.evo)
	elseif type == 2 then --升星
		local jewel = UserDataManager.jewel_data:getJewel(id) --宝物实例
		local cfg = UserDataManager.jewel_data:getDetailCfg(id) --宝物配置
		self:refreshJewelStar(luaBehaviour, cfg.quality, jewel.evo)
		--公共chip，满星后转化为公共碎片
		if jewel.evo >= 5 then
			self:refreshChipNum()
		end
	elseif type == 3 then --觉醒
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "awaken_img", true)
	end
	--red point
	if type == 3 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", false)
		self:refreshRedPointForAwaken() --觉醒消耗公共碎片，需要刷新所有准备觉醒的宝物红点
	else
		local is_red_point = UserDataManager.jewel_data:isRedPoint(id)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", is_red_point == true)
	end
end

--因觉醒消耗公共碎片，所以要刷新所有红点
function M:refreshRedPointForAwaken()
	for k, v in pairs(self.m_list_obj) do
		local state = UserDataManager.jewel_data:getJewelTrainState(k)
		if state == 2 then --只刷新准备觉醒的控件
			local luaBehaviour = UIUtil.findLuaBehaviour(v)
			local is_red_point = UserDataManager.jewel_data:isRedPoint(k)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", is_red_point == true)
		end
	end
end

--宝物公共碎片数量
function M:refreshChipNum()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local quality = v.quality
		if quality > 0 then
			local cfg = UserDataManager.jewel_data:getChipCfg(quality)
			local item_data, item_cfg = UserDataManager.item_data:getItemDataById(cfg.evo_max_chip)
			self:setText("num_text_" .. quality, item_data.num)
		end
	end
end

return M