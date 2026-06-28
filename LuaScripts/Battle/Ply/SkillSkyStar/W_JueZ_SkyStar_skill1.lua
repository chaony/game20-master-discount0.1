---
--- 穿心连珠的攻击次数提升为6次，并可触发飞燕流火效果
---
local M = class("W_JueZ_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
end

function M:gameStart()
    self.skill_ok = false;
end

-- 技能开始
function M:skillStart( ply, skill )
    if skill.anim_name == "skill3" then
        self.skill_ok = true;
    end
end

-- 技能结束
function M:skillEnd( ply, skill )
    if skill.anim_name == "skill3" then
        self.skill_ok = false;
    end
end

-- 再发一颗子弹
---@param evtFrame AnimEvtFrame_Model
function M:shootFrame( evtFrame, data )
    if self.skill_ok == true then
        TimeTools:delayTime(GlobalTools.base0_1, function()
            evtFrame:shootBullet(data)
        end)
    end
end


return M;