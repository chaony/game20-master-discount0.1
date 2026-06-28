local M = class("Restraint_PopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/Restraint_Pop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	self:setTextByLanKey("title_text","restr_str_0001")
	self:setTextByLanKey("count_text","restr_str_0002")
	-- self:setTextByLanKey("bottom_name_text","restr_str_0003")
	-- self:setTextByLanKey("bottom_count_text","restr_str_0004")
	for i = 1 , 6 do
		local img_name = "race_"..i
		local text_name = "race_text_"..i
		local cfg = GlobalConfig.TYPE_HERO_RACE[i]
		self:setImg( cfg.race_icon,  ResourceUtil:getLanAtlas(), img_name)
		self:setTextByLanKey(text_name, cfg.name)
	end
end

return M