---@class HalfAnniversaryGroupingPopControl: OOControlBase
---@field m_model HalfAnniversaryGroupingPopModel
---@field m_view HalfAnniversaryGroupingPopView
local M = class("HalfAnniversaryGroupingPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then
        -- 返回
        self:closeView()
    elseif msg == "create_btn" then
        --发起拼团
        self:createGroup(data)
    end
end

function M:createGroup(gift_id)
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gift_group_text_0032"), delay_close = 2 })
        static_rootControl:updateMsg("create_group", response, "HalfAnniversary.HalfAnniversaryGrouping")
        self:closeView()
        
    end
    local params = { vsn = self.m_model:getVersion(), gift_id = gift_id }
    self.m_model:getNetData("gift_create_group", params, callback)
end

function M:activityOverExamine(response)
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gf_str_0085"), delay_close = 2 })
        self:closeAllViewPop()
        return true
    end
    return false
end

function M:destroy()
    M.super.destroy(self)
end

return M
