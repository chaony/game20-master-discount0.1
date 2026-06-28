local M = class("CustomMadePopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        -- self:setCustomGiftPos(function ()
        --     self:closeView()
        -- end)
        self:closeView()
    elseif msg == "select" then
        audio:SendEvtUI("UI_Click_N3")
        self.m_model.m_select_index = data
        self.m_view:updateSelect()
    elseif msg == "select_reward" then
        self.m_model:setSoltReward(data)
        self.m_view:updateSelect()
    elseif msg == "next_btn" then
        if self.m_model:checkFull() == true then
            self:setCustomGiftPos(function ()
                self:closeView()
            end)
        else
            self.m_model:setNextPos()
        end
        if self.m_view then
            self.m_view:updateSelect()
        end 
    end
end

function M:setCustomGiftPos(callback)
    if self.m_model:checkCanSave() == false then
        if callback then
            callback()
        end
        return 
    end
    local function receivetCallback(response)
        self:updateMsg("updateCustomData", response,"TopUpGiftBag")
        if callback then
            callback()
        end
    end
    local params = {
        gift_id = self.m_model.m_gift_id,
        version = self.m_model.m_gift_version,
        positions = self.m_model:getSlot()
    }
    self.m_model:getNetData("set_custom_gift_gift_pos", params, receivetCallback)
end


return M
