--周瑜召唤火鸟攻击敌人，火鸟会在敌人之间随机弹射1次，对命中的敌人造成200%攻击力的伤害，
--若命中的敌人身上已有“引燃”或者“焚烬”状态，则火鸟在命中敌人时还会造成1次爆炸，对范围内的敌人额外造成1次伤害（不会施加引燃）
--弹射次数增加至2次
--冷却时间降低2秒
--弹射次数增加至4次
---@class W_ZhouY_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhouY_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.bombBuff = self:getParam(1)--额外爆炸buff
end


function M:bulletHit(data)
    local bullet = data.bullet
    if bullet.sourceSkill ~= nil and bullet.sourceSkill.anim_name == "skill2" then
        for i = 1,bullet.hitList.Count, 1 do
            local ply = bullet.hitList:get(i-1)
            if ply ~= nil and ply:isLive() then
                local hasYinRan = ply.bufMgr:hasBufByTag("W_ZhouY_YinRan")
                local hasFenJin = ply.bufMgr:hasBufByTag("W_ZhouY_FenJin")
                if hasYinRan or hasFenJin then
                    ply.bufMgr:addBufById(self.bombBuff, self.player)
                end
            end
        end

    end
end

function M:destroy()
    M.super.destroy(self)
end

return M