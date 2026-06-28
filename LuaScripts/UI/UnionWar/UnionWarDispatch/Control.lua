local M = class("UnionWarDispatchControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "dispatch_btn" or msg == "set_team" then
        self:goFormation(data)
    end
end

function M:goFormation(data)
    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.UNIONWAR_ATTACK, formation_index = data.index})
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "gvg_teams_update" then
        self.m_view:refreshUI()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M