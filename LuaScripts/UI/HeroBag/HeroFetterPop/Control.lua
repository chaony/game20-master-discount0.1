local M = class("HeroFetterPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回
        self.m_model.m_callback({rewards=self.m_model.new_reward})
        self:closeView()
    end
end

return M