---@class RTAAdvanceControl:OOControlBase
---@field m_view RTAAdvanceView
local M=class("RTAAdvanceControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_ui",nil,"Arena.ArenaRTA.RTAMain")
        self:closeView()
    --放弃晋级
    elseif msg=="abadon_btn" then
        self.m_model:getNetData("rta_decide_promote",{op_typ=0}, function()
            self.m_view:retain()
            self:setOnceTimer(3, function()
                self:updateMsg(99999)
                --self:updateMsg("refresh_ui",nil,"Arena.ArenaRTA.RTAMain")
            end)
        end)
    --晋级
    elseif msg=="advance_btn" then
        self.m_model:getNetData("rta_decide_promote",{op_typ=1},function()
            self.m_view:promote(self.m_model.match_type+1)
            self:setOnceTimer(3, function()
                self:updateMsg(99999)
                --self:updateMsg("refresh_ui",nil,"Arena.ArenaRTA.RTAMain")
            end)
        end)
    --以后决定
    elseif msg=="later_btn" then
        self:closeView()
        self:updateMsg(99999,nil,"Arena.ArenaRTA.RTAMain")
        --self:openView("Arena.ArenaSelectMain")

    elseif msg=="new_limit_icon" then
        if self.m_model.m_limit_cfg then
            local param={
                click_transform = self.m_view.limit_icon_trans,
                title=Language:getTextByKey(self.m_model.m_limit_cfg.rule_name),
                msg=Language:getTextByKey(self.m_model.m_limit_cfg.rule_desc)
            }
            GameUtil:lookInfoTips(self.m_control, param)
        end

    end
end


return M