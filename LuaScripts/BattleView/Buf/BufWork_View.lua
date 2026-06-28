---@class BufWork_View : ViewBase @buf实际作用
---@field playerBuf PlayerBuf_View
local M = class("BufWork_View",Battle.ViewBase)

--buf数据
M.playerBuf = nil;

--初始化
---@param buf PlayerBuf_View
---@param model PlayerBuf_Model
function M:init( buf, model )
    self.playerBuf = buf;
    self.model = model;
    self.playerBuf_model = model:get_playerBuf();
    --发送事件通知视图层，BufWork的Model创建完成
    self:addEventListener_Local(Battle.EventType.MV_BufWorkModelWork, {self, self.MV_BufWorkModelWork});
    --buf停止生效
    self:addEventListener_Local(Battle.EventType.MV_BufWorkModelStop, {self, self.MV_BufWorkModelStop});
    --buf重新起作用
    self:addEventListener_Local(Battle.EventType.MV_BufWorkModelReset, {self, self.MV_BufWorkModelReset})
    --bufWork更新
    self:addEventListener_Local(Battle.EventType.MV_BufWorkModelUpdate, {self, self.MV_BufWorkModelUpdate})
    --显示buf icon
    self:addEventListener_Local(Battle.EventType.MV_BufWorkModelShowBufIcon, {self, self.MV_BufWorkModelShowBufIcon})
end


function M:MV_BufWorkModelShowBufIcon(eventName, data)
    if self.playerBuf.buffIcon ~= nil and # self.playerBuf.buffIcon > 0 then
        for k,v in ipairs(self.playerBuf.buffIcon) do
            if data.show == true then
                self.playerBuf.mgr:addBuffIcon(v, self.playerBuf.is_bufficon_count[k] == 1)
            else
                self.playerBuf.mgr:removeBuffIcon(v, data.count)
            end
        end
    end
end

--buf生效类更新
function M:MV_BufWorkModelUpdate(eventName, data)
    self:update(data.dt)
end

--buf生效
function M:MV_BufWorkModelWork(eventName, data)
    self:work();
end

--buf停止
function M:MV_BufWorkModelStop(eventName, data) 
    self:stop();
end

--buf重新设置
function M:MV_BufWorkModelReset(eventName, data)
    self:reset();
end


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  子类重写  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--更新
function M:update(dt) end
--生效
function M:work(dt) end
--停止
function M:stop(dt) end
--重新设定
function M:reset(dt) end
--特效加载完成
function M:effectLoadFinish()

end
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  子类重写  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

return M