local M = class("CommonRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Pops.CommonRewardPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        local function close_callback()
            if type(self.m_model.m_callback) == "function" then
                self.m_model.m_callback()
            end
            self:closeView()
        end
        if self.m_model.m_fly then
            self.m_view:PlayFly(function ()
                close_callback()
            end)
        else
            close_callback()
        end
    end
end



function M:destroy()
    M.super.destroy(self)
    
end

return M;
