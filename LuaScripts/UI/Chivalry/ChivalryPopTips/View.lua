local M = class("ChivalryPopTipsView", LikeOO.OOPopBase)

M.m_uiName = "Chivalry/ChivalryPopTips"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", self.m_model.m_title)
    self:setObjectVisible("btn_node",self.m_model.is_show_btn == 0)
    self.show_data = self.m_model:getShowContent()
    if self.show_data then
        self:setTextByLanKey("content_text", self.show_data.story)
        --local data = RewardUtil:getProcessRewardData(self.show_data.reward_2[1])
        --local cost_num = GameUtil:formatValueToString(data.data_num)
        --self:setTextByLanKey("cost_num_text", cost_num)
        --self:setImg(data.icon_name, data.atlas_name or "item_icon", "cost_icon")
    end
    local bg_img = self:findGameObject("pop_bg_img")
    GameUtil:updateResourcesImg(bg_img,"Texture/chivalry/"..self.m_model.show_bg_img) --设置背景
    self:refreshUI()
end

function M:refreshUI()
    local cost_text = self.m_model.m_receive_stage == 0 and "new_str_0056" or "new_str_0058"
    self:setTextByLanKey("cost_text", cost_text)
end

return M
