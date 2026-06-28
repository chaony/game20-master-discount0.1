---@class PetArenaFeedPopView: OOPopBase
---@field m_model PetArenaFeedPopModel
local M = class("PetArenaFeedPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetArenaFeedPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

M.E_Color = Color(255 / 255, 255 / 255, 255 / 255)
M.U_Color = Color(241 / 255, 67 / 255, 31 / 255)

function M:onEnter()
    self:bindUI()
    self:refreshUI()
end

function M:bindUI()
    self:setTextByLanKey("common_title_text", "pet_arena_text_0008")
    self:setTextByLanKey("ok_btn_text", "new_str_0006")
    self:setTextByLanKey("cancel_btn_text", "new_str_0007")
    self:setTextByLanKey("feed_tips_text", "pet_arena_text_0010")
    self:setTextByLanKey("title_text", "pet_arena_text_0009")
end

function M:refreshUI()
    self:showPetList()
    self:refreshCostItem()
end

function M:showPetList()
    local pet_list = self.m_model:getPetsList()
    for i = 1, 3 do
        local pet_go = self:findGameObject("pet_cell" .. i)
        if i <= #pet_list and pet_list[i] ~= "" then
            GameUtil:updatePetElement(pet_go, { oid = pet_list[i] }, true, true)
            pet_go:SetActive(true)
        else
            pet_go:SetActive(false)
        end
    end
end

function M:refreshCostItem()
    local itemNode = self:findGameObject("ItemNode")
    local needData = self.m_model:getNeedItemData()
    local item_data = RewardUtil:getProcessRewardData(needData)
    local own_num = item_data.user_num
    GameUtil:updateItemElement(itemNode, needData, true, true)
    local text_tran = self:findRectTransform("count_text")
    if own_num < item_data.data_num then
        UIUtil.setTextColor(text_tran, self.U_Color)
    else
        UIUtil.setTextColor(text_tran, self.E_Color)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M