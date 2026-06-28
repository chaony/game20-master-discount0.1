--"折梅：
--印记触发间隔减少至4秒，且引爆印记时，将眩晕目标1秒。"

---@class W_LingJ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LingJ_SkyStar_skill1", SkillSkyStar)

function M:init( player, param, level )
    M.super.init(self,player, param, level )
    self.perTime = self:getParam(1, GlobalTools.base1000)     -- Fix[]   -- 引爆印记间隔
    self.addBuff2 = self:getParam(2, 0)     -- Buff[]   -- 眩晕buff
end

function M:gameStart()
    local skill = self.player.plySkill:getSkillByName("skill0")
    ---@type W_LingJ_skill0_1_Model
    local feature = skill and skill.cur_skill_config and skill.cur_skill_config.feature
    if feature then
        if self.perTime > feature.perTime then
            Logger.logError("灵鹫化星的cd间隔反而更长了")
        end
        feature.perTime = self.perTime
    else
        Logger.logError("天命化星找不到灵鹫技能skill0")
    end
end

---@param victim PlayerModel
function M:triggerStart(victim)
    if victim then
        victim.bufMgr:addBufById(self.addBuff2, self.player)
    end
end

return M;