local M = class("ShareLvUpgradePopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()
    elseif msg == "yes_btn" then
	    local params = {}
        params.pos = self.m_model.m_pos
        params.hero_oid = self.m_model.m_select
        if type(self.m_model.m_callfunc) == "function" then
            self.m_model.m_callfunc(params)
        end
        self:closeView()
    end
end

return M;
