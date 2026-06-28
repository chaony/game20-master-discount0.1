local M = class("KingsoftPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/Kingsoft/KingsoftPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true
local __left_btns = {
	{btn_key = "change_game", tips_id = 0, can_click = true, btn_img = "a_jsld_tb_dun", lua_name = "UI.Activities.Kingsoft.KingsoftSearchNode", btn_text = "kingsoft_text_0002"},
	{btn_key = "change_files", tips_id = 2, can_click = false, btn_img = "a_jsld_tb_jia", btn_text = "kingsoft_text_0003"},
	{btn_key = "capture", tips_id = 0, can_click = true, btn_img = "a_jsld_tb_xiangji", btn_text = "kingsoft_text_0004"},
	{btn_key = "game_help", tips_id = 3, can_click = true, btn_img = "a_jsld_tb_miji", lua_name = "UI.Activities.Kingsoft.KingsoftHistoryNode", btn_text = "kingsoft_text_0005", btn_atlas = "language_zh_cn"},
	{btn_key = "setting", tips_id = 4, can_click = false, btn_img = "a_jsld_tb_xiu", btn_text = "kingsoft_text_0006"},
	{btn_key = "game_box", tips_id = 5, can_click = false, btn_img = "a_jsld_tb_he", btn_text = "kingsoft_text_0007"},
	{btn_key = "help", tips_id = 0, can_click = true, btn_img = "a_jsld_tb_wen", lua_name = "UI.Activities.Kingsoft.KingsoftDesNode", btn_text = "kingsoft_text_0008"},
	{btn_key = "about_game", tips_id = 0, can_click = true, btn_img = "a_jsld_tb_xia", lua_name = "UI.Activities.Kingsoft.KingsoftDesNode", btn_text = "kingsoft_text_0009", btn_atlas = "language_zh_cn"},
}
function M:onEnter()
	self.m_gray_img = self:findImage("gray_img")
	self:setTextByLanKey("title_text", "kingsoft_text_0001")
	self.m_btn_img_tab = {}
	local tab_cls = CustomRequire(__left_btns[self.m_model.m_cur_index].lua_name)
	self.m_parent_node = self:findGameObject("parent_node")
	self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_parent_node})
	self.m_tips_image = self:findGameObject("tips_image")
	--self.m_tips_image.transform.localScale = Vector3(0.8,0.8,1)
	self:updateListScroll()
	self:showLogoAnim()
	self:refreshUi()
end

function M:changeBarValue(bar_name, is_add)
	if self.m_cur_tab_node and self.m_cur_tab_node.chageScrollBarValue then
		self.m_cur_tab_node:chageScrollBarValue(bar_name, is_add)
	end
end

function M:ShareShow(flag)
	
end

function M:changeNode()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	self:setObjectVisible("tips_image", false)
	local tab_cls = CustomRequire(__left_btns[self.m_model.m_cur_index].lua_name)
	self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_parent_node})
	self:refreshUi()
end

function M:showLogoAnim()
	local logo_img = self:findGameObject("logo_img")
	self.m_control:setOnceTimer(1, function()
		self.m_sequence = Tweening.DOTween.Sequence()
		self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findImage("logo_img"), 0, 1))
		self.m_sequence:OnComplete(function()
			self.m_model.m_is_show_logo = false
			self:setObjectVisible("logo_img", false)
			self:setObjectVisible("opt_bg_img", true)
		end)
		self.m_sequence:SetAutoKill(true)
	end)
end

function M:refreshUi()
	if self.m_cur_tab_node and self.m_cur_tab_node.refreshUi then
		self.m_cur_tab_node:refreshUi()
	end
end

function M:updateListScroll()
	local data = __left_btns
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("btn_list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				UIUtil.setTextByLanKey(transform, "btn_text", data.btn_text)
				local btn_img = LuaBehaviourUtil.setImg(luaBehaviour,"btn_img", data.btn_img, data.btn_atlas or "mystic_ui")
				if index == self.m_model.m_cur_index then
					btn_img.color = Color( 220/255, 220/255, 220/255)
				else
					btn_img.color = Color( 255/255, 255/255, 255/255)
				end
				if data.can_click then
					btn_img.material = nil
				else
					btn_img.material = self.m_gray_img.material
				end
				if not( self.m_btn_img_tab[btn_img]) then
					self.m_btn_img_tab[btn_img] = btn_img
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				audio:SendEvtUI("UI_JSYXia_Popup")
				if index ~= self.m_model.m_cur_index then
					if cell_data.can_click then
						self.m_model:setCurIndex(index)
						self:updateMsg(cell_data.btn_key)
						local transform = cell_object.transform
						local luaBehaviour = UIUtil.findLuaBehaviour(transform)
						for i, v in pairs(self.m_btn_img_tab) do
							v.color = Color( 255/255, 255/255, 255/255)
						end
						local btn_img = luaBehaviour:FindImage("btn_img")
						btn_img.color = Color( 220/255, 220/255, 220/255)
					else
						self:updateMsg("show_tips", {tips_id = cell_data.tips_id, index = index, cell_object = cell_object})
					end
				end
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:closeTips()
	if self.m_tips_sequence then
		self.m_tips_sequence:Kill()
		self.m_tips_sequence = nil
	end
	self:setObjectVisible("tips_image", false)
	self:setObjectVisible("close_tips_btn", false)
end

function M:showTips(target_obj, tips_id)
	if self.m_tips_sequence then
		self.m_tips_sequence:Kill()
		self.m_tips_sequence = nil
	end
	local tips_cfg = self.m_model:getTipsCfgById(tips_id)
	if tips_cfg then
		self:setTextByLanKey("tips_text", tips_cfg.des)
		--local head_img = self:setImg(tips_cfg.head, "main_ui", "head_img")
		--head_img:SetNativeSize()
		local src_obj = self.m_tips_image
		local target_obj_trans = target_obj.transform
		local src_trans = src_obj.transform
		local pos = target_obj_trans.parent:TransformPoint(target_obj_trans.localPosition) --世界坐标
		pos = src_trans.parent:InverseTransformPoint(pos) -- 相对坐标
		pos.y = math.max(-169, pos.y)
		src_obj.transform.localPosition = Vector3.New(src_trans.localPosition.x, pos.y, 0)
		self:setObjectVisible("tips_image", true)
		self:setObjectVisible("close_tips_btn", true)
		self.m_control:setOnceTimer(2, function()
			self:setObjectVisible("tips_image", false)
			self:setObjectVisible("close_tips_btn", false)
			--self.m_tips_sequence = Tweening.DOTween.Sequence()
			--self.m_tips_sequence:Append(DOTweenModuleUI.DOFade(self:findImage("tips_image"), 0, 1))
			--self.m_tips_sequence:OnComplete(function()
			--	self:setObjectVisible("tips_image", false)
			--end)
			--self.m_tips_sequence:SetAutoKill(true)
		end)
	end
	
end

function M:getMsg()
	if self.m_cur_tab_node and self.m_cur_tab_node.getMsg then
		return self.m_cur_tab_node:getMsg()
	end
end

function M:destroy()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	if self.m_sequence then
		self.m_sequence:Kill()
		self.m_sequence = nil
	end
	if self.m_tips_sequence then
		self.m_tips_sequence:Kill()
		self.m_tips_sequence = nil
	end
    M.super.destroy(self)
end

return M