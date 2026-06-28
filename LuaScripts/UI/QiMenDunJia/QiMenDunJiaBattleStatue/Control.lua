local M = class("QiMenDunJiaBattleStatueControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "statue_close_btn" then
        self:updateMsg("main_refresh_red_point", nil, "QiMenDunJia.QiMenDunJiaMain")
        self:closeView()
    elseif msg == "statue_battle_btn" then 
        audio:SendEvtUI("UI_JBai")
        self:questForJiBai()
    end
end

function M:questForJiBai()
    local function netCallback(response)
        self.m_model:updateStrengthData(response.health)
        self.m_model:updateAllBuffData(response.effect_buff)
        self.m_model:updateExploreData(response.explore_value)
        self.m_view:refreshUI()
        self:updateMsg("main_refresh_strength", nil, "QiMenDunJia.QiMenDunJiaMain")
        self:updateMsg("main_refresh_all_buff", nil, "QiMenDunJia.QiMenDunJiaMain")
        self:updateMsg("main_refresh_explore", nil, "QiMenDunJia.QiMenDunJiaMain")
    end
    local params = {
        ver = self.m_model:getVersion(),
        cell_id = self.m_model:getCellID()
    }
    self.m_model:getNetData("gve_recv_buff", params, netCallback)
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
