local M = class("ExclusiveWeaponsControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "activate_btn" then
        self:activateExcWeap()
    elseif msg == "intensify_btn" then
        self:intensifyExcWeap()
	end
end

function M:activateExcWeap()
    if self.m_model:checkhaveCfg() == false then
        local params =
        {   
            text = "当前英雄没有专属数据"
        }
        self:openView("Pops.CommonPop",params)
        return
    end
    local function callfunc()
        -- 激活成功
        self:updateMsg("update_equip", nil, "HeroInfo")
        self:updateMsg(99999)
    end
    self.m_model:getNetData("sig_enable",{ hero_oid = self.m_model.m_heroid}, callfunc)
end

function M:intensifyExcWeap()
    local function callfunc()
        -- 强化成功
        self:updateMsg("update_equip", nil, "HeroInfo")
        self:updateMsg(99999)
        self:openView("ExclusiveWeapons.ExclusiveWeaponsLvUpPop", {mode = 2, hero_oid = self.m_model.m_heroid})
    end
    self.m_model:getNetData("sig_lvlup",{ hero_oid = self.m_model.m_heroid}, callfunc)
end

return M
