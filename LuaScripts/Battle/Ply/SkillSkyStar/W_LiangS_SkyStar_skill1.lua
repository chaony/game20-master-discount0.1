--"阎罗王：
--增加梁山“力拔山”技能的攻击范围。"

---@class W_LiangS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LiangS_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.addRange = self:getParam(1, 0)     -- Fix[0-1] 增加攻击范围
    
    self.isRunning = false      -- 是否是力拔山技能中
end

-- 技能开始
function M:skillStart(ply, skill )
    if skill.anim_name == "skill3" then
        self.isRunning = true;
    end
end

-- 技能结束
function M:skillEnd( ply, skill )
    if skill.anim_name == "skill3" then
        self.isRunning = false;
    end
end

---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
    if self.isRunning then
        data = table.copy(data)
        --增加的攻击范围
        data.count.areaRadius = data.count.areaRadius + self.addRange
    end
    return data
end

return M;