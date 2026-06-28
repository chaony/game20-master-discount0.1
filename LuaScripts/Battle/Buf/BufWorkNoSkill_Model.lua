--技能禁止
---@class BufWorkNoSkill : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkNoSkill", BufWork_Model)

function M:initFinish()
    
    --"1"可以释放，"0"不可以释放
    self.attack1 = self.playerBuf:checkParam("attack1", 1) == 1
    self.skill0 = self.playerBuf:checkParam("skill0", 1) == 1
    self.skill1 = self.playerBuf:checkParam("skill1", 1) == 1
    self.skill2 = self.playerBuf:checkParam("skill2", 1) == 1
    self.skill3 = self.playerBuf:checkParam("skill3", 1) == 1
    self.skill4 = self.playerBuf:checkParam("skill4", 1) == 1
    self.skill5 = self.playerBuf:checkParam("skill5", 1) == 1
    self.skill0_plus = self.playerBuf:checkParam("skill0_plus", 1) == 1
    self.skill1_plus = self.playerBuf:checkParam("skill1_plus", 1) == 1
    self.skill2_plus = self.playerBuf:checkParam("skill2_plus", 1) == 1
    self.skill3_plus = self.playerBuf:checkParam("skill3_plus", 1) == 1
    self.xiezhanattack1 = self.playerBuf:checkParam("xiezhanattack1", 1) == 1
    self.xiezhanskill1 = self.playerBuf:checkParam("xiezhanskill1", 1) == 1
end

return M