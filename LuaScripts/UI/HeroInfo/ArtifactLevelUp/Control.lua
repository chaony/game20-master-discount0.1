local M = class("ArtifactLevelUpControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "closeNode_btn" then
        self:updateMsg(99999)    
    elseif msg == "levelup_btn" then
        self:levelUp()
    elseif msg == "chuanshuo_btn" then
        self:openView("HeroInfo.ArtifactDescPop",{desc = self.m_model.m_art_cfg.artifact_story or self.m_model.m_art_cfg.level_up[0].artifact_event})    
    end
end

function M:levelUp()
    local function callfunc()
        -- 升阶成功
        self:updateMsg("update_equip", nil, "HeroBag")
        self:updateMsg(99999)   
        self:openView("ExclusiveWeapons.ExclusiveWeaponsLvUpPop", {mode = 1, hero_oid = self.m_model.m_heroid})
        self.m_model:refreshData()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("artifact_lvlup",{ hero_oid = self.m_model.m_heroid }, callfunc)
end

return M
