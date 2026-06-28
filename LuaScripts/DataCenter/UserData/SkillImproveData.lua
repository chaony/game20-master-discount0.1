------------ SkillImproveData
local M = {
	m_skillImprove = {
        --[104] = 
        --{
        --    ["cur_id"] = 1042001,
        --    ["groups"] = {
        --        1042001,
        --        1042002
        --    }
        --}
    },
}

--[[--
    更新技能强化数据
]]
function M:updateSkillImproveData(data)
    for k1,v1 in pairs(data) do
        self.m_skillImprove[k1] = {}
        self.m_skillImprove[k1].cur_id = v1.cur_id
        self.m_skillImprove[k1].groups = {}
        for k2,v2 in pairs(v1.groups) do
            self.m_skillImprove[k1].groups[k2] = v2
        end
    end
end

function M:setCurId(hero_id, skill_id)
    if self.m_skillImprove[hero_id] ~= nil then
        self.m_skillImprove[hero_id].cur_id = skill_id
    end
end

return M