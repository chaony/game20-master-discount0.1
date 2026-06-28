--李白挥舞宝剑，先前方释放出一道剑气，对范围内的敌人造成300%攻击力的伤害，并为自身施加2层“剑气”状态，
--每次“剑气”状态会使自身攻击力增加5%，最多叠加10层
--lv2 当“剑气”叠加至5层时，剑气的攻击范围会大幅度提升
--lv3 战斗开始时，李白会立即获得3层“剑气”
--lv4 当剑气叠加至10层时，该技能会连续释放出两道剑气
---@class W_LiB_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiB_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 10 do
        self.buffEffectTab[i] = self:getParam(i) -- 飞剑特效
    end
    self.buffId = self:getParam(11) --攻击力buf
    self.triggerNums = self:getParam(12)--叠加至5层时
    self.startNums = self:getParam(13)--战斗开始获得层数
    self.triggerNums2 = self:getParam(14)--剑气叠加至10层
    self.curEffectNums = 0
    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.startNums > 0 then
        for i = 1, self.startNums do
            self:addJianBuff()
        end
    end
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.triggerNums > 0 then
        local buff_list = self.player.bufMgr:findBufByTag("W_LiB_skill0")
        local buff_nums = #buff_list
        if self.triggerNums2 > 0 and buff_nums >= self.triggerNums2 then
            self.skill.extra_anim_name = "skill0_2"
        elseif buff_nums >= self.triggerNums then
            self.skill.extra_anim_name = "skill0_1"
        else
            self.skill.extra_anim_name = "skill0"
        end
    end
end

function M:addJianBuff()
    self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
end

function M:updateEffect()
    local buff_list = self.player.bufMgr:findBufByTag("W_LiB_skill0")
    local buff_nums = #buff_list
    if self.buffEffectTab[buff_nums] then
        self.player.bufMgr:removeBufByTag("W_LiB_skill_effect", true)
        self.player.bufMgr:addBufById(self.buffEffectTab[buff_nums], self.player)
    else
        self.player.bufMgr:removeBufByTag("W_LiB_skill_effect", true)
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source)  then
        for k,v in ipairs(buff.tag) do
            if v == "W_LiB_skill0" then
                self:updateEffect()
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M