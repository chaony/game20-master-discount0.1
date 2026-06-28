--角色的专属装备
--恒山
--普通攻击命中敌人会随机为一名友军回复80%攻击力的生命值
---@class W_HengS_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_HengS_Trait0", PlayerTrait)


M.herotable = {}
function M:init()
    M.super.init(self)
    self.buff = self:getValue(1)
    self.herotable = 
    {
      ["count"] = "one",
      ["camp"] = "friendExceptSelf",
      ["posIndex"] = "all",
      ["priority"] = false,
      ["ignoreSummon"] = false,
      ["targetNoRepeat"] = false,
      ["campRace"] = "not",
      ["pos"] = "not",
      ["profession"] = "all",
      ["area"] = "all",
      ["areaWidth"] = "",
      ["areaHeight"] = "",
      ["areaAngle"] = "",
      ["areaRadius"] = "",
      ["forceSelect"] = false,
      ["selectLast"] = false,
      ["isFixPoint"] = false,
      ["fixpoint"] = "enemyBackCenter"
    }
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)

    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    local dmg = data["wantdata"]["damage"] or 0

    if ply ~= nil and ply:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
           local hero = self:returnHerodata(self.herotable)
           if hero ~= nil then
               hero.bufMgr:addBufById(self.buff, self.player)
           end
        end
    end
end

function M:returnHerodata(herodata)
    local heros = SelectTargetTool:findPlayerByType(herodata,self.player)
    if heros ~= nil and heros:get(0) ~= nil  then
        return heros:get(0)
    end
    return nil
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end
return M