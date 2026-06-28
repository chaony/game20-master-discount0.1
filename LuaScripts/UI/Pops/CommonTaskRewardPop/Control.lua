local M = class("CommonTaskRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_chapter_btn" then
    	if type(self.m_model.m_callback) == "function" then
            self.m_model.m_callback()
        end
        self:closeView()
    elseif msg == "next_chapter_btn" then
        if type(self.m_model.m_callbackNext) == "function" then
            self.m_model.m_callbackNext()
        end
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M;
