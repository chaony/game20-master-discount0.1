local M = class("StoryEventShake", StoryEvent)

M.timer = 0.05

M.shakeDelta = 0.005

M.hasObj = false

function M:play()
    self.shakeTime = tonumber(self.data.shakeTime)
    self.shakeRange = tonumber(self.data.shakeRange)
    local function shakeUpdate()
        if self.shakeTime > 0  then
            self.shakeTime = self.shakeTime - self.timer
            if self.shakeTime <= 0 then
                local rect = static_ui_camera.rect
                rect.x = 0
                rect.y = 0
                static_ui_camera.rect = rect
                self.group.story.view.m_control:removeTimer(self.shake)
                self:finish()
            else
                local rect = static_ui_camera.rect
                rect.x = self.shakeDelta * (-1 + self.shakeRange * Mathf.Random())
                rect.y = self.shakeDelta * (-1 + self.shakeRange * Mathf.Random())
                static_ui_camera.rect = rect
            end
        end
    end
    self.shake = self.group.story.view.m_control:setTimer(self.timer, shakeUpdate)
end

return M