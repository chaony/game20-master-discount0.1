--持续回血时长增加2秒，进入状态后，下次释放额外增加2秒
---@class P_Cat_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Cat_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData2 = self:getParam(1) -- 未进入状态回血buff2
    self.buffData3 = self:getParam(2) -- 进入状态回血buff3
    self.buffData4 = self:getParam(3) -- 未进入状态且气势胜出buff4
    self.buffData5 = self:getParam(4) -- 进入状态气势胜出buff5
end

function M:destroy()
    M.super.destroy(self)
end

return M