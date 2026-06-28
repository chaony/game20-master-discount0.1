local M = class("NewFuncOpenView",LikeOO.OOPopBase)

M.m_uiName = "Pops/NewFuncOpen"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("ok_text", "new_str_0029")
	self:setTextByLanKey("continue_text", "new_str_1151")
	self:refreshUI()
end

function M:refreshUI()
	local cfg = self.m_model:getFirstOpenFuncCfg()
	if cfg then
		self:setTextByLanKey("func_text", cfg.name)
		self:setTextByLanKey("tips_text", cfg.open_des)
		local img = cfg.jump_icon or ""
		if  ResourceUtil:GetSprite(img,"main_ui") then
			self:setImg(img,"main_ui","func_img")
		else
			self:setImg(img,"main_ui2","func_img")
		end
	else
		self:updateMsg(99999)
	end
end


return M