---@class SetHeroAndBackControl: OOControlBase
local M = class("SetHeroAndBackControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("set_close", nil, "parent")
        self:closeView()
    elseif msg == "switch_btn" then
        self.m_view:switch()
    elseif msg == "select_hero" then
        self.m_model.m_hero_id = data.id
        self:updateMsg("set_select_hero", data.id, "parent")
    elseif msg == "hero_set_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("main_set_text_003"), delay_close = 2})
        UserDataManager.local_data:setUserDataByKey("main_set_hero", self.m_model.m_hero_id)
        self.m_view:refreshHeroCheck()
    elseif msg == "select_back" then
        self.m_model.m_back_img = data.img
        self:updateMsg("set_select_back", data.img, "parent")
    elseif msg == "back_set_btn" then
        if self.m_model.m_back_state ~= 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("main_set_text_005"), delay_close = 2})
            return
        end
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("main_set_text_004"), delay_close = 2})
        UserDataManager.local_data:setUserDataByKey("main_set_back", self.m_model.m_back_img)
        self.m_view:refreshBGCheck()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M