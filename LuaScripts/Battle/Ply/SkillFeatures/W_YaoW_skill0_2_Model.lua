--当治疗效果溢出时，溢出部分的50%转化为护盾
local W_YaoW_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_YaoW_skill0_1_Model")

---@class W_YaoW_skill0_2_Model : W_YaoW_skill0_1_Model @
---@field super W_YaoW_skill0_1_Model @W_YaoW_skill0_1_Model
local M = class("W_YaoW_skill0_2_Model", W_YaoW_skill0_1_Model)

M.buffId1 = nil

M.convert = nil

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.convert = self:getParam(2)--转化比例
    self.buffId1 = self:getParam(3)--护盾buff
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("cureOverflow", {self,self.cureOverflowHandler})
end

function M:cureOverflowHandler(eventName, data)
    local source = data["source"]
    local player = data["player"]
    local overflow = data["overflow"]
    if self.player:equal(source) then
        local buffData = table.copy(self.player.bufMgr.bufData[self.buffId1])
        local guard_value = GlobalTools:Mul(overflow, self.convert)
        if buffData ~= nil then
            
             local W_YaoW_skill0 = player.bufMgr:findBufByTag("W_YaoW_skill0")

            if table.nums(W_YaoW_skill0) > 0 then
                for i,v in ipairs(W_YaoW_skill0) do
                    if v.bufWork ~= nil then
                        v.bufWork.value = v.bufWork.value + guard_value
                    end
                end
            else
                for k,v in ipairs(buffData.param[1]) do
                    if v[1] == "shieldParam" then
                        buffData.param[1][k][2] = guard_value
                    elseif v[1] == "type" then
                        buffData.param[1][k][2] = 3
                    end
                end

                player.bufMgr:addBufByData(buffData, self.player)
                
            end   
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("cureOverflow", {self,self.cureOverflowHandler})
    M.super.destroy(self)
end

return M