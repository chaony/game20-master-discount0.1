--李白喝下杯中美酒，为自身增加100点内力，并为自身施加2层“酒气”状态，每层“酒气”状态会使自身攻速增加10%，最多叠加10层
--lv2 当“酒气”叠加至5层时，回内效果提升至200点
--lv3 战斗开始时，李白会立即获得3层“酒气”
--lv4 当酒气叠加至10层时，恢复的内力提升至400点
---@class W_LiB_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiB_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 10 do
        self.buffEffectTab[i] = self:getParam(i) -- 诗气特效
    end
    self.buffId = self:getParam(11) --攻速buf
    self.triggerNums = self:getParam(12)--叠加至5层时
    self.buffId2 = self:getParam(13) --5层的回内buf
    self.startNums = self:getParam(14)--战斗开始获得层数
    self.triggerNums2 = self:getParam(15)--酒气叠加至10层
    self.buffId3 = self:getParam(16) --10层的回内buf
    self.curEffectNums = 0
    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.startNums > 0 then
        for i = 1, self.startNums do
            self:addJiuqiBuff()
        end
    end
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.triggerNums > 0 then
        local buff_list = self.player.bufMgr:findBufByTag("W_LiB_skill2")
        local buff_nums = #buff_list
        if self.triggerNums2 > 0 and buff_nums >= self.triggerNums2 then
            self.player.bufMgr:addBufById(self.buffId3, self.player)
        elseif buff_nums >= self.triggerNums then
            self.player.bufMgr:addBufById(self.buffId2, self.player)
        end
    end
end

function M:addJiuqiBuff()
    self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
end

function M:updateEffect()
    local buff_list = self.player.bufMgr:findBufByTag("W_LiB_skill2")
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
            if v == "W_LiB_skill2" then
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