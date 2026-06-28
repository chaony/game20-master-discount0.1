---
---
local M = class("AwakeSystemResultPopControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
        self:updateMsg("common_refresh",nil,"parent")
    elseif msg == "skill1_img" then
        local select_id = self.m_model.m_select_id
        local hero_id =self.m_model:getHeroid(self.m_model.m_currentHeroIndex)
        local cur_cfg = self.m_model.m_awaken_cfg[hero_id]
        local cfg_awaken_skill = "awaken_skill"
        local cfg_replace_skill = "replace_skill"
        local select_pos = 1
        local cur_level = 1
        for i = 1,2 do
            local cur_awaken_skill_cfg = cur_cfg[cfg_awaken_skill .. i]
            local cur_replace_skill_pos = cur_cfg[cfg_replace_skill .. i]
            for k,v in pairs(cur_awaken_skill_cfg) do
                if select_id == v[1] then
                    select_pos = i
                    cur_level = k
                    break
                end
            end
        end
        local cur_awaken_skill_cfg = cur_cfg[cfg_awaken_skill .. select_pos]
        local cur_replace_skill_pos = cur_cfg[cfg_replace_skill .. select_pos]
        local show_skill = {}
        for k,v in ipairs(cur_awaken_skill_cfg) do
            if k <= cur_level then
                table.insert(show_skill,{v[1],1})
            else
                table.insert(show_skill,{v[1],v[3]})
            end
        end
        local click_obj = data
        local ordinary_skill = 3
        local hero_lv = 100
        self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = show_skill, index = 4, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0,1)})
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M