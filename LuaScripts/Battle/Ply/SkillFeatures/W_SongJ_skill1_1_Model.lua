-- 宋江对当前目标释放闪电链，对其造成200%攻击力的伤害，闪电链命中目标后会弹射一次，对目标周围的另一名敌人造成同等伤害
--lv3 若命中的目标身上有“雷霆”标记，则闪电链会额外弹射两名敌人
---@class W_SongJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SongJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.flag = self:getParam(1) -- 是否额外弹射多个人
end

function M:skillStart(data)
    if self.player.enemy and self.player.enemy:isLive() then
        local buffs = self.player.enemy.bufMgr:findBufByTag("W_SongJ_skill2")
        if self.flag == 1 and buffs and #buffs > 0 then
            self.skill.extra_anim_name = "skill1_2"
        else
            self.skill.extra_anim_name = "skill1"
        end
    else
        self.skill.extra_anim_name = "skill1"
    end
    M.super.skillStart(self, data)
end

--销毁
function M:destroy()
    M.super.destroy(self)
end
return M