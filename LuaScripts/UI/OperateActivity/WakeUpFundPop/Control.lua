local M = class("WakeUpFundPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_btn2" then -- 关闭
        self:closeView()
    elseif msg == "buy_btn" then
        local params = {
            text = Language:getTextByKey("gf_str_0113"),
            tow_close_btn = true,
            on_ok_call = function ()
                if self.m_model.m_from_main then
                    local charge_id = self.m_model:getChargeId()
                    self:buyForSDK(charge_id)
                else
                    self:toBuy()
                end
            end
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "jiantou_right_btn" then
        local page_nums = self.m_model:getPageNums()
        self.m_model.m_cur_index = math.min(self.m_model.m_cur_index + 1, page_nums)
        self.m_view:refreshPageNode("left_to_right")
    elseif msg == "jiantou_left_btn" then
        self.m_model.m_cur_index = math.max(self.m_model.m_cur_index - 1, 1)
        self.m_view:refreshPageNode("right_to_left")
    end
end

function M:toBuy()
    local cur_page_type = self.m_model:getCurPageType()
    local charge_id = self.m_model:getChargeId()
    if cur_page_type == "sign_fund" then
        self:updateMsg("buy", charge_id, "OperateActivity")
    elseif cur_page_type == "war_order" then
        self:updateMsg("buy_high_token", charge_id, "OperateActivity")
    elseif cur_page_type == "grow_fund" then
        self:updateMsg("buy", charge_id, "OperateActivity")
    end
    self:closeView()
end

--调用sdk充值
function M:buyForSDK(charge_id, callback)
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        if callback then
            callback()
        end
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(8, function ()
        self.m_view:unlockTouch()
        if callback then
            callback()
        end
        self.timer_id = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.m_view then
            if self.timer_id then
                self:removeTimer(self.timer_id)
                self.timer_id = nil
            end
            self.m_view:unlockTouch()
            self:closeView()
        end
    end)
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
