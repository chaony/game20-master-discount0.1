
--神王之眼 暴击时获得15%的攻速加成 持续3秒
---@class Artifact2_0 : Artifact @
---@field super Artifact @Artifact
local M = class("Artifact2_0", Artifact)

--攻速加成
M.speed = nil
--时长
M.time = nil
--buff参数
M.buffData = nil
--初始化
function M:init(player,data)
    M.super.init(self, player, data)
    self.speed = self:getValue(1)
    self.time = self:getValue(2)
end

--开始
function M:gameStart()
    M.super.gameStart(self)
    self.buffData = 
    {
        ["count"] = "one",
        ["camp"] = "self",
        ["campRace"] = "not",
        ["pos"] = "not",
        ["profession"] = "all",
        ["area"] = "all",
        ["areaWidth"] = "",
        ["areaHeight"] = "",
        ["areaAngle"] = "",
        ["areaRadius"] = "",
        ["forceSelect"] = false,
        ["buffType"] = "SpeedUp",
        ["buffDes"] = "",
        ["workRound"] = 1,
        ["lastTime"] = self.time,
        ["workTime"] = 0,
        ["delayTime"] = 0,
        ["buffParam"] =
        {
            ["speed"] = self.speed,
        },
        ["buffEffect"] =
        {
        },
        ["buffTags"] =
        {
        },
    }
    EventDispatcher:registerEvent("critCount", {self,self.critHandler})
end

--技能释放
function M:critHandler( eventName, data )
    local ply = data["ply"]
    if ply:equal(self.player) then
        self:addSkillBuf()
    end
end

function M:addSkillBuf()
    M.super.addSkillBuf(self)
    self.player.bufMgr:addBuf(self.buffData, self.player)
end

--结束
function M:gameover()
   M.super.gameover(self)
   EventDispatcher:unRegisterEvent("critCount", {self,self.critHandler})
end

function M:destroy()
 	M.super.destroy(self)
    EventDispatcher:unRegisterEvent("critCount", {self,self.critHandler})
end

return M