local M = class("HeroEchoControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then
        self:closeView()
    elseif msg == "select_hero" then
        self.m_model:setHero(data)
        self.m_view:refreshUI()
    elseif msg == "upgrade_btn" then
        if self.m_model.m_is_can_echo then
            self:startEcho()
            --self:requestUpgradeEcho()
        else
            GameUtil:lookInfoTips(self, { msg = "echo_text_009", delay_close = 2})
        end
    elseif msg == "total_btn" then
        local total_attrs = self.m_model:getEchoTotalAttrs()
        if total_attrs then
            self:openView("Pops.Pro_Pop", {attrs = total_attrs, title_text = "echo_text_010", des_text = "echo_text_011"} )
        else
            GameUtil:lookInfoTips(self, { msg = "echo_text_012", delay_close = 2})
        end
    elseif msg == "skill_detail" then
        --self:skillDetail(data)
    end
end

function M:startEcho()
    self.m_view:playEffect()
    self:setOnceTimer(
            2,
            self:requestUpgradeEcho()
    )
end

function M:requestUpgradeEcho()
    local function setCallback(response)
        --self.m_model.m_heroes = self.m_model:filtrateHero()
        self.m_model:updateTotalLevel()
        self.m_model:setHero(self.m_model.m_hero_oid)
        self.m_view:refreshEcho()
        GameUtil:lookInfoTips(self, { msg = "echo_text_014", delay_close = 2})
    end
    local params = {}
    params.hero_oid = self.m_model.m_hero_oid
    params.item_data = self.m_model:getEchoCostData()
    self.m_model:getNetData("hero_resonance_level_up", params, setCallback)
end

--[[function M:skillDetail(param)
    local skills = self.m_model:getHeroSkill(true)
    local hero_lv = self.m_model:getHero_lv()
    local click_obj = param.click_obj
    local cur_skill = self.m_model:getCurSKill()
    local hero_id =self.m_model:getHeroid()
    local ordinary_skill = table.nums(cur_skill) > 0 and 3 or 0
    local select_id = param.skill_idx
    self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = skills[select_id], index = 4, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0.5,1)})
end]]--

function M:destroy()
    M.super.destroy(self)
end

return M