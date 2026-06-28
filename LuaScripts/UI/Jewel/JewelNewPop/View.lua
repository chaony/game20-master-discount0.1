local M = class("JewelNewPopView",LikeOO.OOPopBase)

M.m_uiName = "Jewel/JewelNewPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	local detail_tab = ConfigManager:getCfgByName("jewel_detail")
	local cfg = detail_tab[self.m_model.m_jewel_id]
	local icon_img = self:findImage("equip_icon")
	GameUtil:updateResourcesImg(icon_img, "Texture/jewelIcon/" .. cfg.icon)
	self:setTextByLanKey("name_text", Language:getTextByKey(cfg.name))
end

return M