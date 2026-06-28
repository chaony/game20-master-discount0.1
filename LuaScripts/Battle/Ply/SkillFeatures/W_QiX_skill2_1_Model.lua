-- 七秀skill2 每隔10秒 当七秀受到伤害时，会免疫伤害并瞬移到随机友军身后
---@class W_QiX_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiX_skill2_1_Model", SkillFeatures_Model)
local friendData = require("Battle.Ply.SkillFeaturesData.W_QiX_skill2_3_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dodge = false;
end


function M:spawn()
    M.super.spawn(self)
    self.dodge = false;
end


function M:skillStart()
    M.super.skillStart(self)
    self.target = self:get_enemyPos_target(friendData,self.player)
    self:skill2_Move(self.player,friendData)
    if self.target ~= nil and self.target:isLive() then
        self.target.bufMgr:addBufById(self.buffId, self.player)
    end
end


function M:beforeAttack(attackData, killer)
    if self.player:get_curSkillConfig() == nil or self.player:get_curSkillConfig().anim_name ~= "skill3" then
        self.dodge = true;
        if self.skill:canUse() then
            attackData.mustDodge = true
            if self.player.aiEngine ~= nil  then
                self.player.aiEngine.skillConfig = self.skill
                self.player.aiEngine:changeState("attack")
            end
        end
        self.dodge = false
    end
end



function M:get_enemyPos_target(data,player)
    local count = data["count"]
    local target = nil
    local enemys = SelectTargetTool:findPlayerByType(count,player)
    if enemys ~= nil and enemys:get(0) ~= nil then
        target = enemys:get(0)
        return target
    end
    return nil
end



function M:skill2_Move(player,data)
    --local type = data["moveType"]
    --if type == nil or type == "nil" then
    --    type = "MoveGeneral"
    --end
    --if player ~= nil then
    --    self:moveInit(type, player , data)
    --end
    self.player.evtMgr:commonEventWork("AttackMove", 1)
end


function M:canUse()
    return self.dodge
end


--位移初始化
function M:moveInit(type, player, data)
    local move = require("Battle.Ply.Fuc.Move").new()
    if player ~= nil then
        --将move加入到move管理器
        player.moveMgr:addFrame(move)
        move:init(type,player,data)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M
