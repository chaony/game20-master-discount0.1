local M = class("StoryEventFlicker", StoryEvent)

M.hasObj = false
M.eventStep = 1

function M:play()
    self.waitTime = tonumber(self.data.waitTime)

    local function finish()
        self.group.story.view.m_control:removeTimer(self.shake)
        self:finish()
    end
    self.wait = self.group.story.view.m_control:setTimer(self.waitTime, finish)
end

return M