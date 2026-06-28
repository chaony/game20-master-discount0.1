--悬赏列表
local M = class("BountyMissionsHelpPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "select_hero" then
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_parent_index, data)
        end
        self:closeView()    
    end
	
end


return M;
