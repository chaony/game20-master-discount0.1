--战斗中，当探花受到攻击时，会免疫该次伤害并从暂时从战场上消失，探花再次出现时，
--会出现在己方后场的安全位置，该技能会有10秒的冷却时间
---@class W_TanH_skill0_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TanH_skill0_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffid = self:getParam(1)
    self.timer = GlobalTools.base0;
    self.dodge = false;
end


function M:skillDispatch(data)
    if data.eventName == "move" then
        self:moveHandle(data)
    end
end


function M:canUse()
    return self.dodge
end


--攻击开始处理
function M:beforeAttack(attackData, killer)
    if self.player:get_curSkillConfig() == nil or self.player:get_curSkillConfig().anim_name ~= "skill3" then
        self.dodge = true
        if self.skill:canUse() then
            attackData.mustDodge = true
            if self.player.aiEngine ~= nil then
                self.player.aiEngine.skillConfig = self.skill
                self.player.aiEngine:changeState("attack")
            end
            
        end
        self.dodge = false
    end
end


function M:moveHandle(data)
    local frame = data.frame
    if frame.player:equal(self.player) then
        local center = SelectTargetTool:findFixPoint(self.player, "sceneCenter")
        local selfBackCenter = SelectTargetTool:findFixPoint(self.player, "selfBackCenter")
        local pos = self.player.position:Clone()
        if self.player.camp == 1 then
            pos.x = selfBackCenter.x - GlobalTools.base9
        else
            pos.x = selfBackCenter.x + GlobalTools.base9
        end
        local r = WRandom:randomNum(GlobalTools.base0_5, GlobalTools.base0_7, true)
        local r_fix = r;
        local r_pos = FixVector3.New(0,0, 0)
        r_pos.z = r_fix;
        if self.player.position.z > center.z then
            pos = pos - r_pos;
        else
            pos = pos + r_pos
        end
        pos = SceneManager.curScene:getAreaPosition(pos)
        if self.player.camp == 1 then
            pos.x = pos.x + GlobalTools.base1
        else
            pos.x = pos.x - GlobalTools.base1
        end
        self.player:setPos(pos)
        self.player.bufMgr:addBufById(self.buffid,self.player)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M