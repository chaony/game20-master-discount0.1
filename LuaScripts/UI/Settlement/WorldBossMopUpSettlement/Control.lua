local M = class("WorldBossMopUpSettlementControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Settlement.WorldBossMopUpSettlement.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        --audio:SendEvtBGM('play_hangup_bgm',true)
        self:closeView()
    end
end

return M