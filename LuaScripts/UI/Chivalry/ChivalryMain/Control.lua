local M = class("ChivalryMainControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, date)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "parent")
        self:updateMsg("common_refresh", nil, "parent")
        if self.m_model.m_is_token == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
        return
    elseif msg == "btn_1" then --长歌行
        local open_status = self.m_model:getActiveStatus(394)
        if open_status == 0 or open_status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            self:openView("Chivalry.ChivalryLoginReceive", {open_id = 394, is_token = self.m_model.m_is_token})
        end
    elseif msg == "btn_2" then --谪仙试炼
        local open_status = self.m_model:getActiveStatus(395)
        if open_status == 0 or open_status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            self:openView("Chivalry.ChivalryBattle",{open_id = 395})
        end
    elseif msg == "btn_3" then --诗书绘卷
        self:openView("Chivalry.ChivalryFill", {is_token = self.m_model.m_is_token})
    elseif msg == "btn_4" then --黄金屋
        local open_status = self.m_model:getActiveStatus(397)
        if open_status == 0 or open_status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            local active_version = self.m_model:getActVsn(397)
            local refreshRedPointCallback = function()
                self.m_view:refreshRedPoint()
            end
            self:openView("commonActive.commonGiftTwo",{open_id = 397,version = active_version,is_token = self.m_model.m_is_token,refresh_name = "Chivalry.ChivalryMain",callback = refreshRedPointCallback})
        end
    elseif msg == "btn_5" then --花落谁家
        local open_status = self.m_model:getActiveStatus(346)
        if open_status == 0 or open_status == 2then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            local active_version = self.m_model:getActVsn(346)
            local refreshRedPointCallback = function()
                self.m_view:refreshRedPoint()
            end
            self:openView("commonActive.commonLuckDraw",{open_id = 346,version = active_version,callback = refreshRedPointCallback})
        end
    elseif msg == "btn_6" then -- 翰林书院
        local open_status = self.m_model:getActiveStatus(398)
        if open_status == 0 or open_status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            local active_version = self.m_model:getActVsn(398)
            self:openView("Chivalry.ChivalryAcademy",{open_id = 398,version = active_version})
        end
    elseif msg == "help_btn" then --帮助
        local params = {}
        params.title = self.m_view.avtive_data.name
        params.content = "tid#ChivalryEvent_1"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_data" then  --刷新数据
        --self:refreshData()
    elseif msg == "refreshRedPoint" then --刷新红点
        self.m_view:refreshRedPoint()
    end
end


--刷新数据
function M:refreshData()
    local function netCallback(response)
        self.m_view:refreshUI()
        self.m_view:refreshRedPoint()
    end
    self.m_model:getNetData("chivalrous_index", {}, netCallback)
end


return M
