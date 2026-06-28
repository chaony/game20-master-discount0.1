local M = class("IdlePopControl",LikeOO.OOControlBase)

function M:onEnter()
    if CS.LuaGameLaunch.Instance.PauseGame then
        CS.LuaGameLaunch.Instance:PauseGame()
    end
    audio:PauseAllAudio()
    self:setTimer(1, self.updateTime)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    end
end

function M:updateTime()
    self.m_view:updateTimeText()
end

function M:destroy()
    if CS.LuaGameLaunch.Instance.ResumeGame then
        CS.LuaGameLaunch.Instance:ResumeGame()
    end
    audio:ResumeAllAudio()
    M.super.destroy(self)
end

return M;
