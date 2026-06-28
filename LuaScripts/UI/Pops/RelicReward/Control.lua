local M = class("RelicRewardControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        local cache_nodes = self.m_view:getRelicCacheNodes()
        self:updateMsg("reward_maze_heirloom_anim", {cache_nodes = cache_nodes, close_call = function()
            self:closeView()
        end}, "MazeStage")
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
