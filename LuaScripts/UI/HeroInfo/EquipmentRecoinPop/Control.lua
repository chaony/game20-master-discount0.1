local M = class("EquipmentRecoinPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.can_close = false
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.can_close == false then
            self:closeView()
        end
    elseif msg == "recoin_btn" then
        self:netRecoin()
    elseif msg == "ok_btn" then
        self.m_view:setOkBtn(false)
        self.m_view:setRecoinBtn(true)
        self.m_model.m_race_tab = self.m_model:getRaces()
        self.m_view:refreshUI()
    elseif msg == "cancle_btn" then
        self:netCancelRecoin()
    end
end

function M:recoinEqp()
    self.can_close = true
    self.cur_Tim = self:setTimer(0.05, handler(self,self.showTurn))
end

function M:showTurn()
    self.m_model:turnNum()
    self.m_view:setLightImg()
    if self.m_model:canStop() == true then
        self:removeTimer(self.cur_Tim)
        self.m_view:updataEqp()
        self.m_view:setOkBtn(true)
        self.can_close = false
        self:updateMsg("update_equip", nil, "HeroInfo") 
        self:updateMsg("update_equip", nil, "HeroInfo.EquipmentPop")
    end
end

function M:netRecoin()
    local function callfunc()
        self:recoinEqp()
        self:updateMsg("update_equip", nil, "HeroInfo") 
        self:updateMsg("update_equip", nil, "HeroInfo.EquipmentPop")
        self.m_view:setRecoinBtn(false)
    end
    self.m_model:getNetData("eqp_recast",{ hero_oid = self.m_model.hero_id, pos = self.m_model.m_pos }, callfunc)	
end

function M:netCancelRecoin()
    local function callfunc()
        self:updateMsg("update_equip", nil, "HeroInfo")
        self:updateMsg("update_equip", nil, "HeroInfo.EquipmentPop")
        self.m_view:updataEqp()
        self.m_view:setOkBtn(false)
        self.m_view:setRecoinBtn(true)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("cancel_recast_recast",{ hero_oid = self.m_model.hero_id, pos = self.m_model.m_pos }, callfunc)	
end

return M
