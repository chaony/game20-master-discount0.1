--南宫skill1
--南宫向上跃起狠砸地面，对范围的敌人造成伤害并击倒
--该技能每击倒1个敌人，南宫便获得一层60%的攻击力的护盾持续5秒
---@class W_NanG_skill1_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_NanG_skill1_3_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
   M.super.init(self, ply, skill,className)
   self.bufID = self:getParam(1)--护盾
   self.shile_value = self:getParam(2)--每次加的护盾值
   self.count = 0
end

--技能释放
function M:skillStart()
  self.count = 0 
end

--作为攻击者的属性零时调整
function M:killerAfterAttack( data )
    local isCrit = data["isCrit"]
    local ply = data["player"]
    local victim = data["victim"]
    if ply ~= nil and ply:equal(self.player) then
        if self.skill.anim_name == "skill1" then
            if victim ~= nil and victim:isLive()  then
                self.count = self.count + 1 
                return data["damage"]
            end
            
        end
    end
    return data["damage"]
end


function M:skillEnd( ... )
    local buf = self.player.bufMgr:addBufById(self.bufID, self.player) --护盾buf
    if buf ~= nil and buf.type == "Shield" and self.player: equal(buf.source) then
        if buf.bufWork ~= nil then
            local atk_value = GlobalTools:Mul(self.player.data.atk:getValue(), self.shile_value);
            local count_value = GlobalTools:Mul(self.count, atk_value);
            buf.bufWork.value = buf.bufWork.value + count_value
        end
    end
    self.count = 0 
end


function M:destroy()
    M.super.destroy(self)
end

   

return M