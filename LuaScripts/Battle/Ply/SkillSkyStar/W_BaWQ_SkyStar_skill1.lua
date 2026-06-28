--"舒卷狂云：
--霸王枪吸取50%风流才子造成伤害的生命值，且被风流才子击中的侠客，受到的治疗降低50%，持续6秒。"

---@class W_BaWQ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_BaWQ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.restoreRate = self:getParam(1, 0)     --Fix[0-1] 恢复血量百分比
    self.addBuff2 = self:getParam(2, 0)     --Buff[] 治疗降低buff

    self.isRunning = false      -- 是否是风流才子运行中
end

--游戏开始的时候
function M:gameStart()
    self.totalDamage = 0
    self.isRunning = false
end

-- 技能开始
function M:skillStart(ply, skill)
    if skill.anim_name == "skill2" then
        self.isRunning = true;
    end
end

-- 技能结束
function M:skillEnd(ply, skill)
    if skill.anim_name == "skill2" then
        self.isRunning = false;
        --转换血量
        if self.totalDamage > 0 then
            -- 造成伤害装换血量
            local restoreHp = GlobalTools:Mul(self.totalDamage, self.restoreRate)
            -- 增加血量
            self.player:cure("fix", self.player, restoreHp)
        end
    end
end

--攻击结束
---@param victim PlayerModel
function M:attackOver(victim, killer, wantdata)
    if self.isRunning then
        self.totalDamage = self.totalDamage + wantdata.damage;
        if victim then
            victim.bufMgr:addBufById(self.addBuff2, self.player)
        end
    end
end

return M;