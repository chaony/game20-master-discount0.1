local M = class("JewelGachaWishPopView",LikeOO.OOPopBase)

M.m_uiName = "Jewel/JewelGachaWishPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "jewel_text_015")
	self.m_gray_img = self:findImage("gray_img")
	--self.m_time_text = self:findText("time_remain")
	--if self.m_model.m_time > 0 then
	--	GameUtil:remainingTimeUpdate(self.m_control, "wish_time_update", self.m_time_text, self.m_model.m_time, "wish_time_end", 1,"tid#wish4")
	--else
	--	self.m_time_text.text = ""
	--end
	for i, v in pairs(self.m_model.m_wishes) do
		local tog_btn = self:findToggle("wish_cell" .. i)
		local obj = self:findGameObject("wish_cell" .. i)
		if v.times == self.m_model.m_wish_times then
			UIUtil.setToggleIsOn(obj.transform, true)
			UIUtil.setObjectVisible(obj.transform, true,"checkmark")
		else
			UIUtil.setObjectVisible(obj.transform, false,"checkmark")
		end
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("select_wish", {times = v.times})
				UIUtil.setObjectVisible(obj.transform, true,"checkmark")
			else
				UIUtil.setObjectVisible(obj.transform, false,"checkmark")
			end
		end, i, self.m_uiName)
	end
	self:refreshUI()
end

function M:refreshUI()
	self:refreshWishes()
	self:updateListScroll(self.m_model.m_wish_times)
end

--英雄列表
function M:updateListScroll(wish_times)
	self.m_list_obj = {}
	local data = self.m_model:filterList(wish_times)
	if self.m_loop_scroll_view == nil then
		local loop_scroll = self:findGameObject("list_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = loop_scroll,
			update_cell = function(index, cell_object, cell_data)
				self.m_list_obj[cell_data] = cell_object --保存列表UI对象
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local is_wish = self.m_model:checkWish(cell_data)
				if is_wish == false then
					self:updateMsg("select_jewel", cell_data)
				else
					GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#wish3"), delay_close = 2})
				end
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--刷新英雄数据
function M:listHandle(obj, index, cell_data)
	if obj == nil then
		return
	end
	local id = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local cfg = UserDataManager.jewel_data:getDetailCfg(id)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name)
	LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", "card_quality" .. cfg.quality, "jewel_ui")
	local icon_obj = luaBehaviour:FindGameObject("icon_img")
	GameUtil:updateResourcesImg(icon_obj, "Texture/jewelIcon/" .. cfg.icon)
	--LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", cfg.icon, "jewel_ui")
	local is_active = UserDataManager.jewel_data:isActiveJewel(id)
	local icon_img = luaBehaviour:FindImage("icon_img")
	icon_img.material = is_active and nil or self.m_gray_img.material
	if cfg.hero_id and cfg.hero_id > 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_icon", true)
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
		LuaBehaviourUtil.setImg(luaBehaviour, "tx_img", hero_cfg.icon, "hero_head_ui")
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_icon", false)
	end
	local is_wish = self.m_model:checkWish(id)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check", is_wish == true)
end

function M:refreshListCheck(id, is_check)
	local obj = self.m_list_obj[id]
	self:refreshCheck(obj, is_check)
end

function M:refreshCheck(obj, is_check)
	if obj == nil then
		return
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check", is_check)
end

--刷新槽位
function M:refreshWishes()
	for i, v in pairs(self.m_model.m_wishes) do
		local obj = self:findGameObject("wish_cell" .. i)
		local luaBehaviour = UIUtil.findLuaBehaviour(obj)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "times_text", "jewel_text_020", v.times)
		if v.jewel and v.jewel > 0 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img", true)
			local cfg = UserDataManager.jewel_data:getDetailCfg(v.jewel)
			local icon_img = luaBehaviour:FindGameObject("icon_img")
			GameUtil:updateResourcesImg(icon_img, "Texture/jewelIcon/" .. cfg.icon)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img", false)
		end
	end
end

function M:destroy()
	--EventDispatcher:unRegisterEvent("wish_time_update")
	M.super.destroy(self)
end

return M