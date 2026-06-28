---@class RedPacketPopControl: OOControlBase
---@field m_model RedPacketPopModel
---@field m_view RedPacketPopView
local M = class("RedPacketPopControl",LikeOO.OOControlBase)

function M:onEnter()
    if self.m_model.m_open then
        self:openRedPacket()
        return
    end
    self:setOnceTimer(3, function()
        if self.m_model.m_state == 1 then
            if self.m_model.m_auto then
                self:openRedPacket()
            else
                self.m_view:setSpineAnimation(2,true) 
            end
        end
    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPacketState" ,nil ,"Chat2")
        self:closeView()
    elseif msg == "close_state_img" then
        self:openRedPacket()
    end
end

function M:openRedPacket()
    self.m_view:setSpineAnimation(3,false)
    self.m_model.m_state = 2
    self.m_model:refreshData(handler(self,self.refreshUI))
end

function M:refreshUI()
    self:setOnceTimer(0.25, function()
        self.m_view:initUiByState()
        self.m_view:setImgAlpha()
    end)
end

function M:destroy()
    M.super.destroy(self)
end

return M;
