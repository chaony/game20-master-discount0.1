---@class PetArenaFeedPopControl: OOControlBase
---@field m_model PetArenaFeedPopModel
---@field m_view PetArenaFeedPopView
local M = class("PetArenaFeedPopControl", LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        -- 确定
        self:feedPets()
    elseif msg == "cancel_btn" then
        -- 取消
        self:updateMsg(99999)
    end
end

function M:feedPets()
    local function callback(response)
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_arena_text_0012"), delay_close = 2 })
        self:updateMsg("pet_mood_refresh", response, "PetBreeding.PetArenaMain")
        self:closeView()
    end
    if self.m_model:checkNeedItem() then
        local feedData = self.m_model:getFeedData()
        self.m_model:getNetData("pet_arena_feed", {pet_data = feedData}, callback)
    else
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_arena_text_0013"), delay_close = 2 })
    end
   
end

function M:destroy()
    M.super.destroy(self)
end

return M
