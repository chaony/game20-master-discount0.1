--战斗开始时，李白获得不可选中，持续8s，并获得不受叠加上限影响的“气”各3层。每当一种“气”叠加到10层，刷新该效果

---@class W_LiB_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LiB_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buff1 = self:getParam(1)
    self.buff2 = self:getParam(2)
    self.buffLayer10 = {}
    self.buff = self.buff1
    local hasSkill1Plus = self.player.plySkill:getSkillByName("skill1_plus") ~= nil
    if hasSkill1Plus then
        self.buff = self.buff2
    end
    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
end

function M:gameStart()
    self:addBuff()
end
function  M:addBuff()
    self.player.bufMgr:addBufById(self.buff, self.player)
end
---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source)  then
        for k,v in ipairs(buff.tag) do
            if v == "W_LiB_skill1" or v == "W_LiB_skill2" or v == "W_LiB_skill0" or v == "W_LiB_skill1_plus" then
                local buff_list = self.player.bufMgr:findBufByTag(v)
                local buff_nums = #buff_list
                if buff_nums >= 10 and self.buffLayer10[v] == nil then
                    self.buffLayer10[v] = 1
                    self:addBuff()
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M;