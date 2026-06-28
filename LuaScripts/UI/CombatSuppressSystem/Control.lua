local M = class("CombatSuppressSystemControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self.m_view:runBackAnim(handler(self,self.AnimEnd))
    end
end

function M:AnimEnd()
    self:updateMsg("refreshCombatSuppressTips" ,nil ,"Formation")
    self:closeView()
end

function M:destroy()
    M.super.destroy(self)
end

return M;
