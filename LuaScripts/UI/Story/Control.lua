local M = class("StoryControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        --self.m_view:tryFinish()
        self:closeView()
    end
end
return M
	