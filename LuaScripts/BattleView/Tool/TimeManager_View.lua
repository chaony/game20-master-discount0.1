---@class TimeManager_View @
local M = class("TimeManager_View")

-- 设定基础更新时间
function M:set_baseUpdateDelaTime( value )
    value = GlobalTools:ToFloat(value)
    self.timeUpdateDelaTime = value
    CS.zmhx.TimeManager.Inst.TimeUpdateDelaTime = value;
end

-- 设定时间速度
function M:set_timeSpeed(value)
    value = GlobalTools:ToFloat(value)
    self.timeSpeed = value
    CS.zmhx.TimeManager.Inst.TimeSpeed = value;
end

-- 设定时间缩放值
function M:set_timeScale(value)
    value = GlobalTools:ToFloat(value)
    self.timeScale = value
    CS.zmhx.TimeManager.Inst.TimeScale = value;
end

function M:set_timePause(value)
    value = GlobalTools:ToFloat(value)
    self.timePause = value
    CS.zmhx.TimeManager.Inst.TimePause = value;
end

---重新设置特效动画的动画速度
---@param effect CS.zmhx.PlayerEffect
---@param prefab string
---@param player Player_View
function M:resetEffectSpeed(player, effect, prefab)
    if not IsNull(effect) and type(effect.UpdateSpeed) == "function" and TimeManager_View.timeSpeed then
        local rate = 1
        if player.model.animator.mode == 0 then
            rate = TimeManager_View.timeScale
        end
        local timeSpeed =  TimeManager_View.timeSpeed;
        local timePause =  TimeManager_View.timePause;
        local timeSpeed = timeSpeed * rate * timePause;
        effect:UpdateSpeed(timeSpeed)
    end
end

return M;