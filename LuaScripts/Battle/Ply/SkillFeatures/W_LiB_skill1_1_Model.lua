--李白挥笔书写诗文，使自身受到的伤害减伤80%，持续2秒，并为自身施加2层“诗气”状态，
--每层诗意状态会使自身暴击率和暴击伤害提升5%，最多叠加10层
--lv2 当“诗气”叠加至5层时，减伤效果提升至99%持续2秒
--lv3 战斗开始时，李白会立即获得3层“诗气”
--lv4 当诗气叠加至10层时，每次释放该技能李白会无敌并免疫控制2秒
---@class W_LiB_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiB_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 10 do
        self.buffEffectTab[i] = self:getParam(i) -- 诗气特效
    end
    self.buffId = self:getParam(11) --暴击buf
    self.triggerNums = self:getParam(12)--叠加至5层时
    self.buffId2 = self:getParam(13) --减伤buf
    self.startNums = self:getParam(14)--战斗开始获得层数
    self.triggerNums2 = self:getParam(15)--诗气叠加至10层
    self.buffId3 = self:getParam(16)--无敌并免疫控制buff
    self.curEffectNums = 0
    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.startNums > 0 then
        for i = 1, self.startNums do
            self:addShiqiBuff()
        end
    end
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.triggerNums > 0 then
        local buff_list = self.player.bufMgr:findBufByTag("W_LiB_skill1")
        local buff_nums = #buff_list
        if buff_nums >= self.triggerNums then
            self.player.bufMgr:addBufById(self.buffId2, self.player)
        end
        if self.triggerNums2 > 0 and buff_nums >= self.triggerNums2 then
            self.player.bufMgr:addBufById(self.buffId3, self.player)
        end
    end
end

function M:addShiqiBuff()
    self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
end

function M:updateEffect()
    local buff_list = self.player.bufMgr:findBufByTag("W_LiB_skill1")
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
            if v == "W_LiB_skill1" then
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