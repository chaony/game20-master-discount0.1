local M = class("PetVariationPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetVariationPop"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:setTextByLanKey("desc_text", self.m_model:getDesc())
    self:setTextByLanKey("title_text", "pet_bag_text_0018")
end


return M
