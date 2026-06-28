local M = class("TopUpRebatePopView",LikeOO.OOPopBase)

M.m_uiName = "TopUpGiftBag/TopUpRebatePop"
M.m_size_type = 2

function M:onEnter()
    self:activeBtn(true)
    self:setTextByLanKey("topUp_text", (self.m_model:getCents() / 100))
    self:setTextByLanKey("tebate_text",self.m_model:getVoucher())
    self:setTextByLanKey("content_text","tid#rebateDes001")
    --self:setTextByLanKey("content_text","limited_hero_006")
    self:setTextByLanKey("getReward_txt","limited_hero_004")
    self:setTextByLanKey("getReward_txt_gray","limited_hero_005")
    self:setImg("icon_daijinquan","item_icon","card_sprite")
end

function M:refreshUI()
    self:activeBtn(false)
    local getReward_image = self:findGameObject("getReward_btn")
    GameUtil:updateResourcesImg(getReward_image, "Texture/a_rebate1_btn")
end

function M:activeBtn(b)
    self:setObjectVisible("getReward_txt",b)
    self:setObjectVisible("getReward_txt_gray",not b)
end

return M