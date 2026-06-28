local M = class("HuntTreasuresGuildTXServerControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "head_btn" then
        if data then
            self:openView("Pops.PlayerInfo", {uid = data, look_model = 1})
        end
    end
end

function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    M.super.destroy(self)
end

return M
