local M = class("WakeUpFundPopView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/WakeUpFundPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "gf_str_0023")
	self.m_content_panel = self:findGameObject("parent_node")
	self:refreshUI()
end

function M:refreshUI()
	self:refreshJiantou()
	self:initNode()
end

function M:refreshPageNode(direction)
	self:refreshJiantou()
	self.m_page_node:playEnterAnim(direction)
end

function M:refreshJiantou()
	local page_nums = self.m_model:getPageNums()
	if page_nums > 1 then
		self:setObjectVisible("jiantou_right_btn", self.m_model.m_cur_index < page_nums)
		self:setObjectVisible("jiantou_left_btn", self.m_model.m_cur_index > 1)
	else
		self:setObjectVisible("jiantou_right_btn", false)
		self:setObjectVisible("jiantou_left_btn", false)
	end
end

function M:initNode()
	local tab_cls = CustomRequire("UI.OperateActivity.WakeUpFundPop.WakeUpFundNode")
	self.m_page_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	self.m_page_node:updateData(self.m_model.m_data)
end

function M:destroy()
	if self.m_page_node then
		self.m_page_node:destroy()
		self.m_page_node = nil
	end
	M.super.destroy(self)
end
return M