---@class ArenaRTALogDetailControl:OOControlBase
---@field m_view ArenaRTALogDetailView
---@field m_model ArenaRTALogDetailModel
local M=class("ArenaRTALogDetailControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
        --self:updateMsg(99999,nil,"Arena.ArenaPeak.ArenaPeak")
    elseif msg=="playback_btn" then

        self.m_model:getNetData("battle_replay",
                {battle_id = self.m_model.battle_id},
                function(data)
                    self:openView("GamePanel", {data = data, mode =data.battle.sort, replay = true, })
        end)

    end
end

return M