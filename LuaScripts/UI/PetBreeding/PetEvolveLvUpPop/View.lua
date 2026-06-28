---@class PetEvolveLvUpPopView: OOPopBase
---@field m_model PetEvolveLvUpPopModel
local M = class("PetEvolveLvUpPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetEvolveLvUpPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("cancel_text", "new_str_0007")
    self:setTextByLanKey("ok_text", "new_str_0006")
    self:setTextByLanKey("common_title_text", "new_str_0005")
    self:setTextByLanKey("msg_text", "pet_evo_lv_0036")
    self:setTextByLanKey("tips_text", "pet_evo_lv_0037")
    --self.m_big_close_btn = self:findButton("big_close_btn")
    --self.m_big_close_btn.enabled = false
    --self:setObjectVisible("close_btn", false)
    self:refreshUI()
end

function M:refreshUI()
    self:refreshCheckImg()
    self.m_model:updateResourceData()
    local need_coin, need_exp = self.m_model:getLevelUpNeedMoney()
    local cur_exp = self.m_model.data_exp.user_num
    local cur_coin = self.m_model.data_coin.user_num
    self:setText("money_text", GameUtil:formatValueToString(need_coin) .. "/" .. GameUtil:formatValueToString(cur_coin))
    self:setText("jingyan_text", GameUtil:formatValueToString(need_exp).. "/" .. GameUtil:formatValueToString(cur_exp))
    self:setImg(self.m_model.data_coin.icon_name, self.m_model.data_coin.atlas_name, "money_img")    --金币
    self:setImg(self.m_model.data_exp.icon_name, self.m_model.data_exp.atlas_name, "jingyan_img")    --经验
end

function M:refreshCheckImg()
    self:setObjectVisible("select_img", self.m_model.m_no_tips)
end

return M