local M = class("UnionHallView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionHall"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "new_str_0403")
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1})	
	self:refreshUI()
end

function M:refreshUI()
	self:refreshRedPoint()
end

function M:refreshRedPoint()
	for k, v in pairs({ { "union_boss_red_point_img", 53 } ,{"union_manage_red_point_img",54} ,{"union_manage_red_point_img",55} }) do
		local red_flag = RedPointUtil:isFuncRedPointById(v[2])
		self:setObjectVisible(v[1], red_flag == true)
	end	
	for k, v in pairs({ { "union_shenlu_red_point_img", 3301 } }) do
		local red_flag = RedPointUtil:hasRedPointById(v[2])
		self:setObjectVisible(v[1], red_flag == true)
	end	
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M