--月寒宫每次暴击后，都会生成一把飞剑，飞剑最多同时存在5把，每把飞剑会为月寒宫提供10%的攻速和攻击力加成
--lv4 战斗一开始时月寒宫便会携带3把飞剑
---@class W_YueHG_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YueHG_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 5 do
        self.buffEffectTab[i] = self:getParam(i) -- 飞剑特效
    end
    self.buffId6 = self:getParam(6) -- 飞剑实际效果
    self.startNums = self:getParam(7) --初始携带数量
    self.maxNums = 5 --最大数量
    self.curNums = 0 --当前数量
end

function M:spawn()
    M.super.spawn(self)
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    for i = 1, self.startNums do
        self:addFeiJianBuff(true)
    end
end

function M:addFeiJianBuff(isSpawn)
    if not self:hasMaxFeiJianBuff() then
        self.player.bufMgr:addBufById(self.buffId6, self.player, self.skill)
        self:updateFeiJianEffect()
        self.curNums = self.curNums + 1
    end
end

function M:removeFeiJianBuff(remove_nums)
    if remove_nums <= self.curNums then
        for i = 1, remove_nums do
            self.player.bufMgr:removeBufById(self.buffId6, true, true)
        end
        self:updateFeiJianEffect()
        self.curNums = self.curNums - remove_nums
        return true
    else
        return false
    end
end

function M:updateFeiJianEffect()
    local buff_list = self.player.bufMgr:findBufByTag("W_YueHG_skill2_1")
    local buff_nums = #buff_list
    if self.buffEffectTab[buff_nums] then
        if self.curNums ~= buff_nums then
            self.player.bufMgr:removeBufByTag("W_YueHG_skill2_1_effect", true)
            self.player.bufMgr:addBufById(self.buffEffectTab[buff_nums], self.player, self.skill)
        end
    else
        self.player.bufMgr:removeBufByTag("W_YueHG_skill2_1_effect", true) 
    end
end

function M:hasMaxFeiJianBuff()
    return self.curNums >= self.maxNums
end

function M:getFeiJianBuffNums()
    return self.curNums
end

--攻击结束处理,如果暴击加个飞剑
---@param afterAttackData Battle_HandleData_Attack
function M:killerAfterAttack(afterAttackData)
    if afterAttackData.isCrit then
        self:addFeiJianBuff()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M