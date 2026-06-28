--战斗中，御竞堂每过15秒会获得一个护盾，当护盾存在时，若御竞堂受到了控制效果，则会免疫该控制并无敌1秒
--lv4 现在受到任意伤害都会触发无敌效果
local W_YuJT_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_YuJT_skill2_1_Model")
---@class W_YuJT_skill2_4_Model : W_YuJT_skill2_4_Model @
---@field super W_YuJT_skill2_1_Model @W_YuJT_skill2_1_Model
local M = class("W_YuJT_skill2_4_Model", W_YuJT_skill2_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    if self.player:equal(data.victim) then -- 自己受到攻击
        local buffs = self.player.bufMgr:findBufByTag("W_YuJT_skill2") -- 护盾TAG
        if #buffs>0 then
            data.wantdata.damage = 0
            self.player.bufMgr:removeBufById(self.buffId1, true)
            self.player.bufMgr:addBufById(self.buffId2, self.player)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M