---@class W_TianS_skill2_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_TianS_skill2_1_View", SkillFeatures_View)

----玩家模型加载完成
--function M:loadFinish(data)
--    if IsNull(self.player.tranformHelper) == false and IsNull(self.player.tran) == false then
--        self.Bip001 = self.player.tranformHelper:FindObj(self.player.tran, "Bip001").transform
--        self.head = self.player.tranformHelper:FindObj(self.player.tran, "head").transform
--        self.defaultHeadY = self.head.transform.localPosition.y
--        self:addEventListener_Local(Battle.SkillEventType.W_TianS_skill2_1_Model_ChangeState, {self,self.W_TianS_skill2_1_Model_ChangeState});
--    end
--end
--
--function M:W_TianS_skill2_1_Model_ChangeState(eventName, data)
--    local state = data.state
--
--    if state == true then
--        self.head.transform.localPosition = Vector3.New(0,self.defaultHeadY + self.Bip001.localPosition.y - 1,0)
--    elseif state == false then
--        self.head.transform.localPosition = Vector3.New(0,self.defaultHeadY,0)
--    end
--end


return M