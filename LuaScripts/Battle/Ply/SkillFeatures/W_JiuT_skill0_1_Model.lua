--为我方每个阵营随机一名侠客施加护盾，为其抵挡200%攻击力的伤害，若上阵的是阳阵营侠客，则该侠客可视为同时视为金木水火四个阵营(6阵营随机,阳单独:阳不随机全都有)
---@class W_JiuT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuT_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shieldBuff = self:getParam(1) -- 护盾buff
end

--当前技能释放
function M:skillStart()
    M.super.skillStart(self)
    self:addShieldBuff(self.shieldBuff) -- 加护盾buff
end

-- 加护盾buff
function M:addShieldBuff(shieldBuff)
    --获取到友方英雄
    local raceTab = {1,2,3,4,6}
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    local heroTab = {{},{},{},{},{},{},{}}
    for i = friends.Count, 1, -1 do
        local player = friends:get(i-1)
        if player.master == nil and table.indexof(raceTab, player.plyData.race) and player:equal(self.player) == false then
            if heroTab[player.plyData.race] then
                table.insert(heroTab[player.plyData.race], player)
            end
        elseif player.master == nil and (player.plyData.race == 5 or player.plyData.race == 7) and player:equal(self.player) == false then
            player.bufMgr:addBufById(shieldBuff, self.player)
        end
    end
    for i = 1, #heroTab do
        local raceHeroTab = heroTab[i]
        if #raceHeroTab > 0 then
            local randomIndex = WRandom:randomNum(1, #raceHeroTab, true)
            if raceHeroTab[randomIndex] then
                raceHeroTab[randomIndex].bufMgr:addBufById(shieldBuff, self.player)
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M