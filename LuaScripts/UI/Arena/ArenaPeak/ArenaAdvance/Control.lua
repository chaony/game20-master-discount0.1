---@class ArenaAdvanceControl:OOControlBase
---@field m_view ArenaAdvanceView
local M=class("ArenaAdvanceControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
        --self:updateMsg(99999,nil,"Arena.ArenaPeak.ArenaPeak")
    --放弃晋级
    elseif msg=="abadon_btn" then
        self.m_model:getNetData("rise_arena_decide_promote",{op_typ=0}, function()
            self.m_view:retain()
            self:setOnceTimer(3, function()
                self:updateMsg(99999)
                self:updateMsg(99999,nil,"Arena.ArenaSelectMain")
                self:openView("Arena.ArenaPeak.ArenaPeak")
            end)
        end)
    --晋级
    elseif msg=="advance_btn" then
        self.m_model:getNetData("rise_arena_decide_promote",{op_typ=1},function()
            self.m_view:promote(self.m_model.match_type+1)
            self:setOnceTimer(3, function()
                self:updateMsg(99999)
                self:updateMsg(99999,nil,"Arena.ArenaSelectMain")
                self:openView("Arena.ArenaPeak.ArenaPeak")
            end)
        end)
    --以后决定
    elseif msg=="later_btn" then
        self:closeView()
        --self:updateMsg(99999,nil,"Arena.ArenaPeak.ArenaPeak")
        --self:openView("Arena.ArenaSelectMain")
    elseif msg=="fulu_icon" then

    elseif msg=="new_limit_icon" then

    end
end


return M