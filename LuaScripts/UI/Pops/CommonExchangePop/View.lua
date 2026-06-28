local M = class("CommonExchangePopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonExchangePop"
M.m_size_type = 2

function M:onEnter()
	self.grup_img = self:findImage("grup_img");
	self.ok_btn_img = self:findImage("ok_btn");
	self.add_btn_img = self:findImage("add_btn");
	self.reduce_btn_img = self:findImage("reduce_btn");

	self.ok_btn = self:findButton("ok_btn");
	self.add_btn = self:findButton("add_btn");
	self.reduce_btn = self:findButton("reduce_btn");
	if self.m_model.m_className and self.m_model.m_className == "HuntTreasures" then
		self:setObjectVisible("add_btn", false)
		self:setObjectVisible("reduce_btn", false)
	end
	self:refreshUI()
end

function M:refreshUI()
	--显示标题
	self:setTextByLanKey("common_title_text", self.m_model:getTitleName())
	--内容
	self:setTextByLanKey("msg_txt",self.m_model.m_msg);
	self:setTextByLanKey("item_show_txt", self.m_model.m_item_msg)
	--购买数量
	self:setTextByLanKey("bug_num_txt",self.m_model.m_buyNum);
	--购买数量
	self:setTextByLanKey("money_num_txt",self.m_model.m_cost);
	--self:setTextByLanKey("money_num_txt",self.m_model.m_cost_data.data_num);
	--如果购买最大数量
	if self.m_model.m_max_buyNum == 0 then
		self.ok_btn_img.material = self.grup_img.material
		self.ok_btn.interactable = false;

		self.add_btn_img.material = self.grup_img.material
		self.add_btn.interactable = false;

		self.reduce_btn_img.material = self.grup_img.material
		self.reduce_btn.interactable = false;
	else
		self.ok_btn_img.material = nil
		self.ok_btn.interactable = true;

		self.add_btn_img.material = nil
		self.add_btn.interactable = true;

		self.reduce_btn_img.material = nil
		self.reduce_btn.interactable = true;
	end
end


return M