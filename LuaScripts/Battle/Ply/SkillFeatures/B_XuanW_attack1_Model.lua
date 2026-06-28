
--玄武boss attack
--近战范围内有敌人使用近战攻击，近战范围内没有敌人使用远程攻击
---@class B_XuanW_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_XuanW_attack1_Model", SkillFeatures_Model)

M.dis = nil
function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --最小距离
    self.dis = self:getParam(5)
end

--当前技能释放
function M:skillStart()
    M.super.skillStart(self)
    --获取到敌人
    local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
    for i = enemys.Count, 1, -1 do
        local enemy_player = enemys:get(i-1)
        local distance = GlobalTools:Distance(self.player.position, enemy_player.position)
        if distance <= self.dis then
            self.skill.extra_anim_name = "attack2"
            return;
        else
            self.skill.extra_anim_name = "attack1"
        end
    end
end

--出生
function M:spawn( ... )
    M.super.spawn(self,...)
    local bufData1 = self:getParam(1)
    self.player.bufMgr:addBufById(bufData1, self.player) --免疫hit

    local bufData2 = self:getParam(2)
    self.player.bufMgr:addBufById(bufData2, self.player) --免疫控制

    local bufData3 = self:getParam(3)
    self.player.bufMgr:addBufById(bufData3, self.player) --不死

    local bufData4 = self:getParam(4)
    self.player.bufMgr:addBufById(bufData4, self.player) --受击会怒降低70%
end



function M:destroy()
    M.super.destroy(self)
    
end

return M