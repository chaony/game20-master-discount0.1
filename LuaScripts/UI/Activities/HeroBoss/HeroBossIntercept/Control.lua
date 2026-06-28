local M = class("HeroBossInterceptControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "refresh_btn" then
        self:requestRefresh()
    elseif msg == "btn" then
        self:requestIntercept(data.cell_data.user.uid)
    end
end

function M:requestIntercept(uid)
    local function callback(response)
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.HERO_BOSS_PVP,
                                   def_data = response,
                                   defend_uid = uid,
        })
        self:closeView()
    end
    local params = {rival_uid = uid}
    self.m_model:getNetData("hero_boss_rival_defends", params, callback)
end

function M:requestRefresh()
    local function callback(response)
        self.m_model.m_data = response
        self.m_view:refreshUI()
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hero_boss_text_018"), delay_close = 2})
    end
    local params = {refresh = 1}
    self.m_model:getNetData("hero_boss_loot_rivals", params, callback)
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    --EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M