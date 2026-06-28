--指挥猎鹰飞向敌方密集区域并向下方发射翎羽，对范围内的敌人造成攻击力250%的内功伤害并附加一层破甲。
--该技能在命中敌人后，有概率额外释放一次，敌人的等级越低，则额外释放的概率越高（破甲：防御力降低10%，持续5秒，最多可叠加5层）

---@class W_TianY_skill3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianY_skill3_Model", SkillFeatures_Model)

M.players = nil

M.isExtra = false

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.players = {}
    self.isExtra = false

    self.level1 = self:getParam(1)
    self.rate1 = self:getParam(2)
    self.level2 = self:getParam(3)
    self.rate2 = self:getParam(4)
    self.level3 = self:getParam(5)
    self.rate3 = self:getParam(6)
    self.level4 = self:getParam(7)
    self.rate4 = self:getParam(8)
    self.level5 = self:getParam(9)
    self.rate5 = self:getParam(10)
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local attackData = data["attackData"]
    if ply ~= nil and ply:equal(self.player) and attackData.skillConfig ~= nil and attackData.skillConfig.anim_name == "skill3" then
        if self.isExtra == false then
            table.insert(self.players, victim)
        end
    end
end

--技能释放
function M:skill3Start(data)
    if self.isExtra == false then
        self.players = {}
    end
end

--技能结束
function M:skill3Finish(data)
    if self.isExtra == false then
        local totalLevel = 0
        for k,v in ipairs(self.players) do
            totalLevel = totalLevel + v.data.level
        end

        totalLevel = GlobalTools:ToFix(totalLevel);
        local averageLevel = GlobalTools:Div( totalLevel, GlobalTools:ToFix(#self.players) )
        local rate = 0
        for i = 1, 5 do
            if averageLevel <= self["level"..i] then
                rate = self["rate"..i]
                break
            end
        end
        if WRandom:randomNum(0,100 ) <= GlobalTools:Mul(rate, GlobalTools.base100) then
            self.isExtra = true
            self.player.canBlackScreen = false
            TimeTools:delayTime(GlobalTools.base0_0_1, function()
                --如果人物销毁这里会报错
                if self.player.animator ~= nil then
                    self.player.animator:changeState("skill3")
                end
            end)
        end
    else
        self.isExtra = false
    end
end

--技能结束
function M:skillEnd(data)
    self.player.canBlackScreen = true
end

function M:skillDispatch(data)
    if data.eventName == "skill3Start" then
        self:skill3Start(data)
    elseif data.eventName == "skill3Finish" then
        self:skill3Finish(data)
    elseif data.eventName == "TianY_Extra_Hit" then --天命化星额外射击
        if self.player.skyStar then
            self.player.skyStar:triggerStart(self)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M