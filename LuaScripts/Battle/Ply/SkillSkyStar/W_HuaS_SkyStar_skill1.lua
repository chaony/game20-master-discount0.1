---
--- 增加惊鸿照影的攻击范围，且该技能造成伤害的50%会转化为自身恢复效果
---
local M = class("W_HuaS_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --增加攻击范围
    self.addRange = self:getParam(1)
    --恢复血量百分比
    self.restoreRate = self:getParam(2)
end

--游戏开始的时候
function M:gameStart()
    self.totalDamage = 0
    self.skill_ok = false
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
        --转换血量
        if self.totalDamage > 0 then
            -- 造成伤害装换血量
            local restoreHp = GlobalTools:Mul(self.totalDamage, self.restoreRate)
            -- 增加血量
            self.player:cure("fix", self.player, restoreHp)
        end
    end
end

---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
    if self.skill_ok then
        --增加的攻击范围
        data = table.copy(data)
        data.count.areaRadius = data.count.areaRadius + self.addRange
    end
    return data
end

--攻击结束
function M:attackOver(ply, killer, wantdata)
    if self.skill_ok then
        --在大招期间的总伤害 
        self.totalDamage = self.totalDamage + wantdata.damage;
    end
end


return M;