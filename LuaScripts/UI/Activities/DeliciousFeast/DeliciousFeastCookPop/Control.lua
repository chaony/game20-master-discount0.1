---@class DeliciousFeastCookPopControl: OOControlBase
---@field m_model DeliciousFeastCookPopModel
---@field m_view DeliciousFeastCookPopView
local M = class("DeliciousFeastCookPopControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:closeView()
    elseif msg == "cook_once_btn" and self:checkActivityOpen() then
        -- 制作一次
        if self.m_model:checkCanCook() then
            self:cookFood(1)
        else
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("feast_text_0013"), delay_close = 2 })
        end
    elseif msg == "cook_all_btn" and self:checkActivityOpen() then
        -- 全部制作
        if self.m_model:checkCanCook() then
            self:cookFood(self.m_model:getMaxCookNum())
        else
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("feast_text_0013"), delay_close = 2 })
        end
    end
end

function M:checkActivityOpen()
    if not self.m_model:checkActivityOpen() then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("flower_text_0021"), delay_close = 2 })
        static_rootControl:closeAllViewPop()
        return false
    end
    return true
end

function M:cookFood(num)
    local function callback(response)
        if response.reward then
            self:updateMsg("refreshNum", nil, "Activities.DeliciousFeast.DeliciousFeastCook")
            self:closeView()
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = { vsn = self.m_model:getVersion(), cook_id = self.m_model:getCookId(), times = num }
    self.m_model:getNetData("feast_taste", params, callback)
end

return M