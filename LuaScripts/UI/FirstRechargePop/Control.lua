local M = class("FirstRechargePopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "go_btn" then
    	
    elseif msg == "hero_btn" then
    	self:openView("HeroInfo", {tj_data = self.m_model.m_hero, look_model = 2})
    end
end

return M;
