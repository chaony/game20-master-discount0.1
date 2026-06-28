local M = class("WorldMapSelectControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "jianghu_btn" then
        self:openView("WorldMap.WorldMapMain")
        self:updateMsg(99999)
    elseif msg == "world_memory_btn" then
        self:openView("WorldMapNew.WorldMemoryMain")
        self:updateMsg(99999)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
