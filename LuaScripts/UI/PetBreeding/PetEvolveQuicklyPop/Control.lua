---@class PetEvolveQuicklyPopControl: OOControlBase
---@field m_model PetEvolveQuicklyPopModel
---@field m_view PetEvolveQuicklyPopView
local M = class("PetEvolveQuicklyPopControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:closeView()
    elseif msg == "close_btn" then
        self:updateMsg(99999)
    elseif msg == "ok_btn" then
        -- 使用道具
        self:useItem()
    elseif msg == "minus_one_btn" then
        if self.m_model:checkCanUse() then
            self.m_model:addUseNum(-1)
            self.m_view:updateUseNum()
        end
    elseif msg == "add_one_btn" then
        if self.m_model:checkCanUse() then
            self.m_model:addUseNum(1)
            self.m_view:updateUseNum()
        end
    elseif msg == "min_btn" then
        if self.m_model:checkCanUse() then
            self.m_model:setMinNum()
            self.m_view:updateUseNum()
        end
    elseif msg == "max_btn" then
        if self.m_model:checkCanUse() then
            self.m_model:setMaxNum()
            self.m_view:updateUseNum()
        end

    end
end

function M:useItem()
    if not self.m_model:checkCanUse() then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0067"), delay_close = 2 })
        return
    end
    local num = self.m_model:getNum()
    local inputNum = self.m_view:getSearchText()
    if inputNum == "" or inputNum == "-" then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0546"), delay_close = 2 })
        return
    end
    if num <= 0 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0546"), delay_close = 2 })
        return
    end
    local diff, real_num = self.m_model:checkMaxNum()
    if diff > 0 then
        num = real_num
    end
    local function netCallback(response)
        if diff > 0 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0037", num), delay_close = 2 })
        end
        self:updateMsg(99999)
        if response.reward.egg_ok and self.m_model.m_source == 1 then
            local data, cfg = UserDataManager.pet_data:getPetDataById(self.m_model.m_pet_oid)
            if not data.egg_ets then
                self:updateMsg("quickly_pet_egg_success", response.reward.egg_ok[1], "PetBreeding.PetBag")
            end
        end
        
    end
    local params = { item_id = self.m_model.m_item_id, item_num = num or 1, material = { self.m_model.m_pet_oid } }
    self.m_model:getNetData("item_use_item", params, netCallback)
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    self:removeTimer(self.m_timer)
    M.super.destroy(self)
end

return M
