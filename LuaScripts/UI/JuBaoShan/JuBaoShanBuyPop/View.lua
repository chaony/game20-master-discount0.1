local M = class("JuBaoShanBuyPopView",LikeOO.OOPopBase)

M.m_uiName = "JuBaoShan/JuBaoShanBuyPop"
M.m_size_type = 2

function M:onEnter()
	self.grup_img = self:findImage("grup_img");
	self.ok_btn_img = self:findImage("ok_btn");
	self.add_btn_img = self:findImage("add_btn");
	self.reduce_btn_img = self:findImage("reduce_btn");
	self.min_btn_img = self:findImage("min_btn")
	self.max_btn_img = self:findImage("max_btn")

	self.ok_btn = self:findButton("ok_btn");
	self.add_btn = self:findButton("add_btn");
	self.reduce_btn = self:findButton("reduce_btn");
	self.min_btn = self:findButton("min_btn")
	self.max_btn = self:findButton("max_btn")
	self:refreshUI()
end

function M:refreshUI()
	--显示标题
	self:setTextByLanKey("common_title_text", self.m_model:getTitleName())
	--内容
	self:setTextByLanKey("msg_txt",self.m_model.m_msg);
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

		self.min_btn_img.material = self.grup_img.material
		self.min_btn.interactable = false

		self.max_btn_img.material = self.grup_img.material
		self.max_btn.interactable = false
	else
		self.ok_btn_img.material = nil
		self.ok_btn.interactable = true;

		self.add_btn_img.material = nil
		self.add_btn.interactable = true;

		self.reduce_btn_img.material = nil
		self.reduce_btn.interactable = true;

		self.min_btn_img.material = nil
		self.min_btn.interactable = true

		self.max_btn_img.material = nil
		self.max_btn.interactable = true
	end
	--消耗图片
	local img = self:findGameObject("money_icon");
	UIUtil.setImg(img,self.m_model.m_cost_data.icon_name,self.m_model.m_cost_data.atlas_name)
end


return M