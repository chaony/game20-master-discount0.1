
--绝情 skill3 控制飞刀攻击敌方“绝杀印”最多的英雄，造成300%的攻击力的伤害并给对方施加一层绝杀印
--当释放目标有3层以上的绝杀印时还会使敌人沉默3秒 当释放目标有5层绝杀印时，清除敌人的绝杀印并使本技能的伤害提升300%

-- 改动  所有绝杀印记换破甲，绝杀印记的特效也替换成破甲特效
--控制飞刀攻击破甲层数最多的武神，造成300%攻击力的外功伤害并为对方施加一层破甲，
--    当释放目标有3层以上破甲时还会使敌人沉默3s；当释放目标有5层破甲时，使本次造成的伤害翻倍

---@class W_JueQ_skill3 : SkillFeatures_Model
local M = class("W_JueQ_skill3", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.count = self:getParam(1)
    self.bufid = self:getParam(2)
    self.max_count = self:getParam(3)
    self.buf_5_value = self:getParam(4)
end


--查找敌人
---@param data Battle_List
function M:findPlayer(data)
    local enemys =  {}
    if self.player.curSkillConfig ~= nil and self.player.curSkillConfig.anim_name == "skill3" then
        local ply_list = Battle.List.new()
        for i = 1, data.Count do
            local ply = data:get(i - 1)
            local marks = ply.bufMgr:findBufByTag("pojia")
            table.insert(enemys, {
                count = #marks,
                ply = ply,
            })
        end
        table.sort(enemys, function(a,b) return a.count > b.count  end)
        if #enemys > 0 then
            local maxCount = enemys[1].count
            local maxCountEnemys = {}
            for i, info in ipairs(enemys) do
                if info.count == maxCount then
                    table.insert(maxCountEnemys, info.ply)
                end
            end

            local random = WRandom:randomNum(1, #maxCountEnemys, true)
            ply_list:add(maxCountEnemys[random])
            data:clear()
            return ply_list
        end
    end
    return data
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]
    local skillConfig = data["attackData"]["skillConfig"]
    local dmg = 0
    if killer ~= nil and killer:equal(self.player) then
        if victim ~= nil then
            if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
                local marks = victim.bufMgr:findBufByTag("pojia")
                if #marks >= self.count then
                    victim.bufMgr:addBufById(self.bufid, self.player)
                end
                if #marks >= self.max_count then
                    local buf_value = GlobalTools:Mul(data.damage, self.buf_5_value);
                    data.damage = data.damage + buf_value
                    return data.damage
                end
            end
        end
    end
    return data.damage
end


function M:destroy()
    M.super.destroy(self)
end

return M