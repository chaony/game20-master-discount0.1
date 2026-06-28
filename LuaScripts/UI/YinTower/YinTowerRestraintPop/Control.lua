local M = class("YinTowerRestraintPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.YinTower.YinTowerRestraintPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("guide_check", nil, "YinTower")
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
