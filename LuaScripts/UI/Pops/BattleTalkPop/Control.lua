local M = class("BattleTalkControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "add_talk" then
        if data.isRepeat == false then
            self.m_model:addTalk(data.cfg)
        else
            self.m_model.repeat_talk = data.cfg
        end
        self.m_view:refreshUISingle()
    elseif msg == "pause" then
        if self.m_view.timer ~= nil then
            self.callback = self.m_timerList[self.m_view.timer].callFunc
            self.timer = self.m_timerList[self.m_view.timer].inter - self.m_timerList[self.m_view.timer].time
            self:removeTimer(self.m_view.timer)
        end
    elseif msg == "play" then
        if self.callback ~= nil and self.timer ~= nil then
            self.m_view.timer = self:setOnceTimer(self.timer, self.callback)
            self.timer = nil
            self.callback = nil
        end
    end
end

function M:destroy()
    local callBack = self.m_model.callBack
    local talk_cfg = self.m_model.talk_cfg
    local cur_id = self.m_model.cur_id
    M.super.destroy(self)
    if callBack ~= nil then
        callBack(talk_cfg, cur_id)
    end
end

return M;
