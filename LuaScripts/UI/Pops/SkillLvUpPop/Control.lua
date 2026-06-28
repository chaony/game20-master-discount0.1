local M = class("SkillLvUpPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        if self.m_model.m_close_callback then
            self.m_model.m_close_callback()
        end
        self:closeView()
    elseif msg == "cancle_btn" then
        if self.m_model.m_close_callback then
            self.m_model.m_close_callback()
        end
        self:closeView()
    elseif msg == "ok_btn" then  
        local bl, str = self.m_model:checkConsumeNum() 
        if bl == false then
            local params =
            {
                no_close_btn = true,
                text = str,
            }
            self:openView("Pops.CommonPop", params)
            if self.m_model.m_close_callback then
                self.m_model.m_close_callback()
            end
            self:closeView()
            return
        end
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_view.isnew_skill, self.m_view.new_skill) 
        end
        if self.m_model.m_close_callback then
            self.m_model.m_close_callback()
        end
        self:closeView()
    end
end

return M;
