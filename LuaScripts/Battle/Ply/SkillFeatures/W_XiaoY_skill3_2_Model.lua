--释放“鲲鹏击”时，会附加“逍遥游”持续期间所造成伤害量30%的额外伤害
local W_XiaoY_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_XiaoY_skill3_1_Model")
---@class W_XiaoY_skill3_2_Model : W_XiaoY_skill3_1_Model @
---@field super W_XiaoY_skill3_1_Model @W_XiaoY_skill3_1_Model
local M = class("W_XiaoY_skill3_2_Model", W_XiaoY_skill3_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dmg = self:getParam(2)
    self.total_dmg = 0
end

function M:spawn()
    M.super.spawn(self)
    self.total_dmg = 0
end

function M:setState(state)
    M.super.setState(self, state)
    if state == 2 then
        self.total_dmg = 0
    end
end

---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    local skill = data.attackData["skillConfig"]
    if killer ~= nil and killer:equal(self.player) then
        if self.state == 2 then
            if skill == nil or skill.anim_name ~= "skill3" then
                self.total_dmg = self.total_dmg + dmg
            end
        elseif self.state == 1 then
            if skill ~= nil and skill.anim_name == "skill3" then
                local total_dmg_preent = GlobalTools:Mul(self.total_dmg, self.dmg);
                data.damage = data.damage + total_dmg_preent

                --鲲鹏击对布甲类侠客造成额外20%的伤害。
                if self.player.skyStar ~= nil then
                    self.player.skyStar:triggerStart(data)
                end
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M