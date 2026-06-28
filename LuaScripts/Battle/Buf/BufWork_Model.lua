---@class BufWork_Model : ModelBase @buf实际作用
local M = class("BufWork_Model",Battle.ModelBase)


--初始化
---@param buf PlayerBuf_Model
---@param name string
function M:init( buf, name )
    self.playerBuf = buf;
    self.name = name;
    self.updateParam = {}
    self:initFinish()
    --发送事件通知视图层，BufWork的Model创建完成
    self.playerBuf:dispatchEvent_Local(Battle.EventType.MV_BufWorkModelCreateFinish, self);
	--Logger.log(nil, "buf开始")
    self:addBufIcon()
end

function M:get_name()
    return self.name;
end

function M:get_position()
    return nil;
end

function M:initFinish()
    
end

--显示buf图标，子类重写
function M:addBufIcon()
    self:showBufIcon(true)
end

--显示buf图标，子类重写
function M:removeBufIcon(count)
    self:showBufIcon(false, count)
end

--显示buf图标，子类重写
function M:showBufIcon(show, count)
    self:dispatchEvent_Local(Battle.EventType.MV_BufWorkModelShowBufIcon,{show = show, count = count})
end

-- 获取玩家的buf
function M:get_playerBuf()
    return self.playerBuf;
end

--重置
function M:reset(  )
	--Logger.log(nil, "buf重置")
    self:dispatchEvent_Local(Battle.EventType.MV_BufWorkModelWork);
end

--起作用的方法，子类重新写
function M:work()
    --buf生效, 作用人
    self:dispatchEvent_Local(Battle.EventType.MV_BufWorkModelWork);
end

--生效结束的方法，子类重新写
function M:workEnd(  )
    --Logger.log(self.playerBuf.player.plyType, "buf生效结束，作用人")
end

function M:update( time )
    self.updateParam.dt = time;
    self:dispatchEvent_Local(Battle.EventType.MV_BufWorkModelUpdate, self.updateParam);
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)
end

--作为受伤者的属性临时调整
function M:victimDataChangeTemp(killer)
end

--起作用的方法，子类重新写
function M:stop()
    self:removeBufIcon(1);
    self:dispatchEvent_Local(Battle.EventType.MV_BufWorkModelStop);
end

function M:upgrade(param)

end

return M