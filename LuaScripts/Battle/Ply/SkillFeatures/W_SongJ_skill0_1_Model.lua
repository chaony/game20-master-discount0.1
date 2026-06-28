-- 战斗中，当雷霆标记首次被引爆时，宋江将获得20%的伤害提升，之后每额外引爆一次，还会额外获得5%的伤害提升，最多额外提升20%
---@class W_SongJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SongJ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData1 = self:getParam(1) -- 首次自身BUFF
    self.buffData2 = self:getParam(2) -- 额外自身BUFF
end

--销毁
function M:destroy()
    M.super.destroy(self)
end
return M