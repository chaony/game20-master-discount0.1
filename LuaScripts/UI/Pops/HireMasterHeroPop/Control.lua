local M = class("HireMasterHeroPopControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "select_hero" then
        self:selectHero(data)
    elseif msg == "ok_btn" then
        self.m_model.m_callback(self.m_model.m_apostle_heros)
        self:closeView()
    end
end

function M:selectHero(data)
    if self.m_model:checkIsSelect(data) == true then
        self.m_model:removeHero(data)
    else    
        if self.m_model:checkVacancy() == true then
            self.m_model:addHero(data)
        else
            local params =
            {
                no_close_btn = true,
                text = Language:getTextByKey("没有空位") 
            }
            self:openView("Pops.CommonPop", params) 
        end
    end
    self.m_view:updateLoopScroll()
end

return M;
