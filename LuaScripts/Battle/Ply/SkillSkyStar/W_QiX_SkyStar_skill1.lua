---
--- 翔鸾舞柳的持续时间提升至10秒
--- 释放大招后，全体友方侠客受治疗提升10%，持续5s
---
local M = class("W_QiX_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --大招持续时间
    self.cureEffectBuf = self:getParam(1)
end

function M:gameStart()
    
end

--触发开始
function M:skillStart( ply, skill )
    if skill.anim_name == "skill3" then
        TimeTools:delayTime(GlobalTools.base0_5, function()
            local allPlys = self:getTarget("self","all")
            for i = 1, allPlys.Count do
                local mFriend = allPlys:get(i-1)
                --获取到七秀的大招buf
                mFriend.bufMgr:addBufById(self.cureEffectBuf, self.player)
            end
        end)
    end
end

--触发结束
function M:triggerEnd( data )
    
end


return M;