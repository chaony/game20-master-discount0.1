---@class DepositoryPopView:OOPopBase
---@field m_model DepositoryPopModel
local M = class("DepositoryPopView",LikeOO.OOPopBase)

M.m_uiName = "SutraDepository/MysticDepositoryPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local mystic_type = {"mystic_str_0024", "mystic_str_0025","mystic_str_0026", "mystic_str_0027"}

function M:onEnter()
	self.m_gray_image = self:findImage("gray_image")
	self:setObjectVisible("remove_btn", self.m_model.m_pos ~= nil)
	self:setObjectVisible("replace_btn", self.m_model.m_pos ~= nil)
	self:setObjectVisible("promote_btn", self.m_model.m_look_model ~= 3 and  self.m_model.m_look_model ~= 2 and self.m_model.m_mode == 1)
	self:setObjectVisible("cost_node", self.m_model.m_look_model == 3 )
	local is_can_inset = UserDataManager.mystic_data:checkMysticInset(self.m_model.m_id)
	self:setObjectVisible("inset_btn", is_can_inset and self.m_model.m_mode ~= 3 and self.m_model.m_other == false)
	self:setObjectVisible("inset_attr_title", is_can_inset)
	self:setObjectVisible("inset_skill_attr_title", is_can_inset)
	self.eqp_content = self:findGameObject("eqp_content")
	self.eqp_content_fitter = self.eqp_content:GetComponent("ContentImmediate")

	self:setTextByLanKey("shuxing_text", "mystic_str_0045")
	self:setTextByLanKey("Innate_shuxing_text", "mystic_str_00100")
	self:setTextByLanKey("text_jingmai_title", "mystic_str_0046")
	self:setTextByLanKey("jineng_title_text", "mystic_str_0068")
	self:setTextByLanKey("des_title_text", "mystic_str_0043")
	self:setTextByLanKey("pingfen_text", "mystic_str_0084")
	self:setTextByLanKey("inset_btn_text", "mystic_str_0090")
	self:setTextByLanKey("text_inset_title", "mystic_str_0091")
	self:setTextByLanKey("text_inset_skill_title", "mystic_str_0092")
	self:setTextByLanKey("buy_btn_text", "new_str_0037")
	self:setTextByLanKey("replace_btn_text", "new_str_0885")
	self:setTextByLanKey("remove_btn_text", "mystic_str_0005")
	self:setTextByLanKey("promote_btn_text", "mystic_str_00117")

	self.m_attr_node = self:findGameObject("attr_node") -- 基础属性的node
	self.m_innate_attrs_node = self:findGameObject("innate_attrs_node") -- 基础属性的node
	self.m_attrs_node = self:findGameObject("attrs_node") -- 基础属性总节点
	self.m_sig_attr_node = self:findGameObject("sig_attr_node") -- 经脉的node
	self.m_cw_propey_node = self:findGameObject("cw_propey") -- 经脉属性总节点
	
	self.today = self.m_model.m_today_btn_value
	self:setTextByLanKey("today_text", self.m_model.m_today_text)
	self:setObjectVisible("today_btn", self.m_model.m_isToday)
	
	self.vocation_detail_text = self:findText("vocation_detail_text")
	if self.m_model.m_isToday then
		self:todayIsActive()
	end
	self:refreshUI()
	if self.eqp_content_fitter  then
		--触发刷新自适应大小
		self.eqp_content_fitter:ForceRefreshSize()
	end
end

function M:refreshUI()
	self:setObjectVisible("channel_attr_node", false)
	local cur_cfg = self.m_model:getMysticData()
	if cur_cfg then
		local common_title_text = Language:getTextByKey(cur_cfg.name)
		self:setTextByLanKey("common_title_text", common_title_text) -- 秘籍名字
		self:setTextByLanKey("mystic_name", cur_cfg.name) -- 秘籍名字
		self:setTextByLanKey("des_text", cur_cfg.des) -- 秘籍详情
		local mystic_star_cfg=self.m_model:getMystic_Star_Cfg()
		self:setTextByLanKey("pingfen_num", mystic_star_cfg.mystic_score) -- 秘籍详情
		
		self:setTextByLanKey("mystic_type_name", Language:getTextByKey(GlobalConfig.TYPE_MERIDIAN[cur_cfg.type].name)) -- 秘籍类型
		self:setTextByLanKey("zhuangbei_text", Language:getTextByKey("new_str_0641")) -- 类型
		local reward_data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(self.m_model.m_id), cur_cfg.quality, oid = self.m_model.m_id })
		self:updateBooksByData(reward_data,cur_cfg) -- 秘籍icon
		self:updateBaseAttrLoopScroll() -- 基础属性
		self:updateChannelAttrLoopScroll() -- 经脉属性
		self:updateInnateAttrLoopScroll()--秘籍效果，先天属性
		self:creatSkillIcon(cur_cfg) -- 创建技能图标
		--local is_can_inset = UserDataManager.mystic_data:checkMysticInset(self.m_model.m_oid)
		--if is_can_inset then
		--	self:updateInsetAttrLoopScroll() -- 镶嵌属性
		--	self:updateInsetSkillAttrLoopScroll() -- 奥义解放
		--end
	end

	-- 商店购买处理
	if self.m_model.m_look_model ==3 then
		if self.m_model.m_cost then
			local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
			local cost_num = GameUtil:formatValueToString(data.data_num)
			local user_num = GameUtil:formatValueToString(data.user_num)
			local cost_num_text = self:setTextByLanKey("cost_num_text", cost_num)
			cost_num_text.color = GlobalConfig.COMMON_COLLOR.COMMON_10
			self:setImg(data.icon_name, "item_icon", "cost_icon")
		end
	end
	if self.m_model.m_other == true then
		self:setObjectVisible("remove_btn", false)
		self:setObjectVisible("replace_btn", false)
		self:setObjectVisible("promote_btn", false)
		self:setObjectVisible("cost_node", false)
	end
end

-- 创建技能图标
function M:creatSkillIcon(cfg)
	if self.m_model.m_id then
		local buff_group_cfg = self.m_model:getMysticBuffGroupById(self.m_model.m_id)
		if buff_group_cfg and table.nums(buff_group_cfg) > 0 then
			self:setObjectVisible("zh_desc",true)
			self:setObjectVisible("jineng_title",true)
			local group_skill_title_text = self:findText("aomi_name")
			local mysticCfg = buff_group_cfg[1] or {} -- 先默认选第一个，未来可能要展示一本秘籍的多个技能(目前界面不允许这样显示)
			group_skill_title_text.text = Language:getTextByKey(mysticCfg.name)
			self:setImg( mysticCfg.icon,"skill_icon","group_skill_img")
			self:setTextByLanKey("skill_detail_text", mysticCfg.des)
			self:setTextByLanKey("vocation_detail_text", mysticCfg.des_class)
			if self.m_model.m_heroid then
				local hero_data,hero_cfg = self.m_model:getHeroDatabyHeroId()
				if hero_cfg and hero_cfg.role_type == cfg.role_type then
					--self.vocation_detail_text.color = Color( 64/255, 188/255, 17/255) --绿色
					--self.vocation_detail_text.color = Color( 85/255, 125/255, 162/255) --浅蓝色
					self.vocation_detail_text.color = Color( 207/255, 105/255, 49/255) --橙色
				end
			end
		else
			self:setObjectVisible("zh_desc",false)
			self:setObjectVisible("jineng_title",false)
		end
	end
end

-- 秘籍的图标展示
function M:updateBooksByData( data, cfg, mystic_data)
	local object = self:findGameObject("MysicItem")
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", data.data_num)
    local title_node = luaBehaviour:FindGameObject("title_node")
    local title_text = luaBehaviour:FindText("title_text")
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local lv_text = luaBehaviour:FindGameObject("lv_text")
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local stars = luaBehaviour:FindGameObject("stars")
    local tips_img = luaBehaviour:FindGameObject("tips_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local ex_we_bg = luaBehaviour:FindGameObject("ex_we_bg")
    local ex_di_bg = luaBehaviour:FindGameObject("ex_di_bg")

	local type_meridian = GlobalConfig.TYPE_MERIDIAN[cfg.type]
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "type_name", type_meridian.short_name)
	LuaBehaviourUtil.setTextColor(luaBehaviour,"type_name",type_meridian.name_color)
	if mystic_data and mystic_data.wear and mystic_data.wear ~= "" then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeadNode",true)
		local cur_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(mystic_data.wear)
		if cur_skin_cfg then
			LuaBehaviourUtil.setImg(luaBehaviour, "tx_img", cur_skin_cfg.icon, "hero_head_ui")
		end
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeadNode",false)
	end
	local atlas_name =  ResourceUtil:getLanAtlas()
	LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", type_meridian.pro_icon,  ResourceUtil:getLanAtlas())
	local class_meridian = GlobalConfig.CLASS_MERIDIAN[cfg.role_type or 0] or 0
	if class_meridian == 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",false)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",true)
		LuaBehaviourUtil.setImg(luaBehaviour, "vocation_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
	end
	GameUtil:creatEffectForEquip(object, { quality = cfg.quality, data_type= RewardUtil.REWARD_TYPE_KEYS.MYSTIC})
    red_point_img:SetActive(false)
    have_panel:SetActive(true)
    no_panel:SetActive(false)
    up_image:SetActive(false)
    ex_we_bg:SetActive(false)
    lock_image:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    tips_img:SetActive(false)
    lv_bg_img:SetActive(false)
    ex_di_bg:SetActive(false)
	stars:SetActive(false)
    count_text_bg_img:SetActive(false)
    count_text.gameObject:SetActive(false)
    local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.frame_name, "equip_icon")
	
end

--[[	
	基础属性列表
]]
function M:updateBaseAttrLoopScroll()
	local data = self.m_model:getFormatMysticBaseAttr() -- 获取基础属性
	UIUtil.destroyAllChild(self.m_attrs_node.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(self.m_attr_node, self.m_attrs_node.transform)
		cell_object:SetActive(true)
		local transform = cell_object.transform
		for i = 1, 2 do
			if cell_data[i] then
				local attr = cell_data[i]
				local cp = GameUtil:getAttrsName(attr[1]) .. ":"
				local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text"..i)
				-- 四舍五入保留小数点后一位
				local attr_value = attr[2] or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				local attr_value_text = nil
				if GameUtil:attrTransition(attr[1]) == true then
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "attr_value_text"..i)
				else
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "attr_value_text"..i)
				end

				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
			else
				UIUtil.setText(transform, "", "attr_name_text"..i)
				UIUtil.setText(transform, "", "attr_value_text"..i)
			end
		end
	end
end

--先天秘籍效果
function M:updateInnateAttrLoopScroll()
	if self.m_model:isInnateMystic() then
		self:setObjectVisible("innate_title",true)
		self:setObjectVisible("innate_attrs_node",true)

		local data = self.m_model:getFormatMysticInnateAttr() -- 获取基础属性
		UIUtil.destroyAllChild(self.m_innate_attrs_node.transform)
		local cell_object = GameUtil:instanceObject(self.m_attr_node, self.m_innate_attrs_node.transform)
		cell_object:SetActive(true)
		local transform = cell_object.transform
		local index=0
		for k,cell_data in ipairs(data) do
			index=index+1
			if cell_data[1]~=nil then

				local attr = cell_data[1]
				local cp = GameUtil:getAttrsName(nil,attr) .. ":"
				local attr_cfg = GameUtil:getAttrCfg(attr)
				local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text"..index)
				local attr_value_text = nil

				--attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(cell_data[2]*100).."%", "attr_value_text"..index)
				attr_value_text = UIUtil.setText(transform, "+"..(attr_cfg.is_percent == 1 and tostring(cell_data[2]*100) .. "%" or tostring(cell_data[2])), "attr_value_text"..index)
				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
			else
				UIUtil.setText(transform, "", "attr_name_text"..index)
				UIUtil.setText(transform, "", "attr_value_text"..index)
			end

			--for i = 1, 2 do
			--	if cell_data[i] then
			--		local attr = cell_data[i]
			--		local cp = GameUtil:getAttrsName(nil,attr) .. ":"
			--		local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text"..i)
			--		-- 四舍五入保留小数点后一位
			--		local attr_value = attr[2] or 0
			--		attr_value = math.floor(attr_value * 10 + 0.5)/10
			--		local attr_value_text = nil
			--		--if GameUtil:attrTransition(attr[1]) == true then
			--		--	attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "attr_value_text"..i)
			--		--else
			--		--	attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "attr_value_text"..i)
			--		--end
			--
			--		attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "attr_value_text"..i)
			--
			--		local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
			--		UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
			--	else
			--		UIUtil.setText(transform, "", "attr_name_text"..i)
			--		UIUtil.setText(transform, "", "attr_value_text"..i)
			--	end
			--end
		end
	else
		self:setObjectVisible("innate_title",false)
		self:setObjectVisible("innate_attrs_node",false)
	end

end

-- 经脉属性
function M:updateChannelAttrLoopScroll()
	local data = self.m_model:getChannelAttr()
	self:setObjectVisible("jingmai_title", #data>0)
	if #data>0 then
		self:setObjectVisible("channel_attr_node", true)
	end
	
	if self.m_channel_attrs_scroll_view == nil then
		local loopscroll = self:findGameObject("channel_attrs_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local attr = cell_data.attr
				local transform = cell_object.transform
				local attr_cfg = GameUtil:getAttrCfg(attr[1])
				UIUtil.setTextByLanKey(transform, "type_text", Language:getTextByKey(attr_cfg.name) .. ":")
				local value = "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2]))
				if cell_data.open then
					UIUtil.setTextByLanKey(transform, "vein_desc", value)
				else
					local global_cfg = GlobalConfig.TYPE_MERIDIAN_OLD[cell_data.meridian_type]
					UIUtil.setTextByLanKey(transform, "vein_desc", "mystic_str_0047", value, Language:getTextByKey(global_cfg.name), cell_data.channel_lv,cell_data.lv)
					UIUtil.setTextColor(transform, Color( 0.68, 0.35, 0.18), "vein_desc")
					UIUtil.setTextColor(transform, Color( 0.68, 0.35, 0.18), "type_text")
				end

			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_channel_attrs_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_channel_attrs_scroll_view:reloadData(data)
	end
end

-- 镶嵌属性
function M:updateInsetAttrLoopScroll()
	local data = self.m_model:getInsetAttr()
	if next(data) == nil then
		self:setObjectVisible("inset_attr_title", false)
	else
		self:setObjectVisible("inset_attr_title", true)
		self:setObjectVisible("channel_attr_node", true)
	end
	if self.m_Inset_attrs_scroll_view == nil then
		local loopscroll = self:findGameObject("inset_attrs_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
				local attr = cell_data.attr
				local num = cell_data.num
				local attr_cfg = GameUtil:getAttrCfg(attr[1])
				local type_str = Language:getTextByKey(attr_cfg.name) .. ":"
				local count = math.floor(num/cell_data.condition[2])
				local value = attr_cfg.is_percent == 1 and tostring(attr[2]*count*100) .. "%" or tostring(attr[2])
				local quality_cfg = GlobalConfig.QUALITY_COMMON_SETTING[cell_data.condition[3]]
				local condition_str = "???"
				if cell_data.condition[1] == 1 then
					condition_str = Language:getTextByKey(quality_cfg.name) .. Language:getTextByKey("shareLv_str_0023")
				elseif cell_data.condition[1] == 2 then
					condition_str = Language:getTextByKey(quality_cfg.name) .. Language:getTextByKey("shareLv_str_0023")
					if cell_data.type == 1 then -- 先天
						condition_str = condition_str .. Language:getTextByKey("mystic_str_0056")
					elseif cell_data.type == 2 then -- 绝技
						condition_str = condition_str .. Language:getTextByKey("mystic_str_0057")
					elseif cell_data.type == 3 then -- 神技
						condition_str = condition_str .. Language:getTextByKey("mystic_str_0085")
					end
				elseif cell_data.condition[1] == 3 then
					condition_str = Language:getTextByKey(cell_data.name)
				end
				local add_value = attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])
				local str = type_str .. "+" .. value .. Language:getTextByKey("mystic_str_0088",cell_data.condition[2], condition_str, add_value)
				if num >= cell_data.condition[2] then
					LuaBehaviourUtil.setText(luaBehaviour, "vein_desc", str)
					LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 64/255, 118/255, 17/255, 1))
				else
					LuaBehaviourUtil.setText(luaBehaviour, "vein_desc", str)
					LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 0.68, 0.35, 0.18))
				end
			end,
		}
		self.m_Inset_attrs_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_Inset_attrs_scroll_view:reloadData(data)
	end
end

-- 奥义解放
function M:updateInsetSkillAttrLoopScroll()
	local data = self.m_model:getInsetSkillAttr()
	if next(data) == nil then
		self:setObjectVisible("inset_skill_attr_title", false)
	else
		self:setObjectVisible("inset_skill_attr_title", true)
	end
	if self.m_Inset_skill_attrs_scroll_view == nil then
		local loopscroll = self:findGameObject("inset_skill_attrs_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
				local num = cell_data.num
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "vein_desc", cell_data.des)
				if num >= cell_data.condition[2] then
					LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color(  64/255, 118/255, 17/255, 1))
				else
					LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 0.68, 0.35, 0.18))
				end
			end,
		}
		self.m_Inset_skill_attrs_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_Inset_skill_attrs_scroll_view:reloadData(data)
	end
end

function M:showEffect( data)
    local object = self:findGameObject("MysicItem")
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
	
	local cur_data = self.m_model:getMysticData()
	local star_anim = self:findGameObject("UI_MysticDepository_xing_02")
    if cur_data ~= nil then
		star_anim:SetActive(true)
		self:setObjectVisible("UI_MysticDepository_Miji_03", true)
        for i = 1, cur_data.star do
            local star_imm = luaBehaviour:FindGameObject("star_" .. i)
            if star_imm then
				UIUtil.setImgAlpha(star_imm, 1)
                star_imm:SetActive(true)
            end
			if i == cur_data.star then
				CommonUIUtil:setObjectPosByTarget(star_anim, star_imm)
			end
        end
    end
	
	self.m_control:setOnceTimer(0.5, function()
		local jc_UI_Myastic_ShuXing = self:findGameObject("jc_UI_Myastic_ShuXing")
		if not IsNull(jc_UI_Myastic_ShuXing) then
			jc_UI_Myastic_ShuXing:SetActive(true)
		end
		self.m_control:setOnceTimer(0.5, function()
			if not IsNull(jc_UI_Myastic_ShuXing) then
				jc_UI_Myastic_ShuXing:SetActive(false)
			end
		end)
	end)
	self.m_control:setOnceTimer(0.8, function()
		local UI_Myastic_ShuXing = self:findGameObject("UI_Myastic_ShuXing")
		if not IsNull(UI_Myastic_ShuXing) then
			UI_Myastic_ShuXing:SetActive(true)
		end
		self.m_control:setOnceTimer(0.5, function()
			self:refreshUI()
			if  not IsNull(UI_Myastic_ShuXing) then
				UI_Myastic_ShuXing:SetActive(false)
			end
		end)
		if not IsNull(star_anim) then
			star_anim:SetActive(false)
		end
		self:setObjectVisible("UI_MysticDepository_Miji_03", false)
	end)
end

function M:todayIsActive(...)
	if self.today then
		self:setObjectVisible("yes", true)
		self.today_callback = true
		self.cur_server_ts = UserDataManager:getServerTime()
	else
		self:setObjectVisible("yes", false)
		self.today_callback = false
		self.cur_server_ts = nil
	end
end

function M:destroy()
    M.super.destroy(self)
end

return M