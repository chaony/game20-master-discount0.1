local M = class("CommonTimesPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonTimesPop"
M.m_size_type = 2

function M:onEnter()
	self.grup_img = self:findImage("grup_img");
	self.ok_btn_img = self:findImage("ok_btn");
	self.add_btn_img = self:findImage("add_btn");
	self.reduce_btn_img = self:findImage("reduce_btn");
	self.min_btn_img = self:findImage("min_btn")
	self.max_btn_img = self:findImage("max_btn")

	--显示标题
	self:setTextByLanKey("common_title_text", self.m_model.m_title)
	--内容
	self:setTextByLanKey("msg_txt", self.m_model.m_msg);
	
	self:refreshUI()
end

function M:refreshUI()
	--购买数量
	self:setTextByLanKey("bug_num_txt", self.m_model.m_buyNum);
	--购买花费
	self:setTextByLanKey("money_num_txt", self.m_model.m_cost * self.m_model.m_buyNum);
	-- -10
	if self.m_model.m_buyNum > 10 then
		self.min_btn_img.material = nil
	else
		self.min_btn_img.material = self.grup_img.material
	end
	-- -1
	if self.m_model.m_buyNum > 1 then
		self.reduce_btn_img.material = nil
	else
		self.reduce_btn_img.material = self.grup_img.material
	end
	-- +1
	if self.m_model.m_cost * (self.m_model.m_buyNum + 1) <= self.m_model.m_yuanbao_count and self.m_model.m_buyNum + 1 <= self.m_model.m_limit_num then
		self.add_btn_img.material = nil
	else
		self.add_btn_img.material = self.grup_img.material
	end
	-- +10
	if self.m_model.m_cost * (self.m_model.m_buyNum + 10) <= self.m_model.m_yuanbao_count and self.m_model.m_buyNum + 10 <= self.m_model.m_limit_num then
		self.max_btn_img.material = nil
	else
		self.max_btn_img.material = self.grup_img.material
	end
	-- +ok
	if self.m_model.m_cost * self.m_model.m_buyNum <= self.m_model.m_yuanbao_count then
		self.ok_btn_img.material = nil
	else
		self.ok_btn_img.material = self.grup_img.material
	end
end


return M