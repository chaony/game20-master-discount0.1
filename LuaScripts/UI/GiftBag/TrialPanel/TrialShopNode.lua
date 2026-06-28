local M = class("TrialShopNodeView",LikeOO.OOUIbase)

M.m_uiName = "GiftBag/TrialShopNode"

function M:onEnter()
    self.parent = self:findGameObject("itemParent")
    if self.m_model:checkPoint(self.m_model.m_sel_tab_index, 3) == true then
        RedPointUtil:recruitSetRedPoint(self.m_model.m_sel_tab_index)
        self:updateMsg("refreshRedPoint")
    end
    self:refreshUI()
end

function M:refreshUI()
    local cfg, bl = self.m_model:getTaskList()
    GameUtil:createRewards(self.parent.transform ,cfg.reward, true, true, nil)
    self:setTextByLanKey("originalPrice_num", cfg.price_old)
    self:setTextByLanKey("presentPrice_num", cfg.price_new)
    self:setObjectVisible("buy_btn", bl == false)
    self:setObjectVisible("get_btn", bl == true)
end

return M