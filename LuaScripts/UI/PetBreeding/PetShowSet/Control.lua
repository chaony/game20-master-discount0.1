---@class PetShowSetControl: OOControlBase
---@field m_model PetShowSetModel
---@field m_view PetShowSetView
local M = class("PetShowSetControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then
        self:requestSetShow()
    elseif msg == "click_cell" then
        audio:SendEvtUI("Ui_Click_N3")
        self:setShow(data)
    elseif msg == "set_down" then
        self.m_model:setDownPet(data)
        self.m_view:refreshUI()
    end
end

function M:setShow(data)
    local set_state = self.m_model:setShow(data)
    self.m_view:refreshUI()
end

function M:requestSetShow()
    if self.m_model:checkNeedSetData() then
        local function netCallback(response)
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("pet_bag_text_0106"), delay_close = 2})
            self:updateMsg("update_data", response, "PetBreeding.PetBreedingMain")
            self:closeView()
        end
        local params = {}
        params.pet_oids = self.m_model:getPetSetData()
        self.m_model:getNetData("pet_set_show", params, netCallback)
    else
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
