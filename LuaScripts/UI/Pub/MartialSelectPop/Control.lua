local M = class("MartialSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "1_btn" then
        self:openMartialHandle(1)
    elseif msg == "2_btn" then
        self:openMartialHandle(2)
    elseif msg == "3_btn" then
        self:openMartialHandle(3)
    elseif msg == "4_btn" then
        self:openMartialHandle(4)
    elseif msg == "time_end" then
        self.m_model:updateData(data)
        self.m_view:refreshUI()
    elseif msg == "yes_btn" then
        if self.m_model.m_cur_martial == self.m_model.m_select then
            if self.m_model.m_callback then
                self.m_model.m_callback()
            end
            self:closeView()
        else
            local function checkoutCallback(response)
                --self:updateMsg("update_data", response, "Pub")
                if self.m_model.m_callback then
                    self.m_model.m_callback(response)
                end
                self:closeView()
            end
            local params = {}
            params.target_race = self.m_model.m_select
            self.m_model:getNetData("gacha_checkout_cur_gacha_race", params, checkoutCallback)
        end
    end
end

function M:openMartialHandle(index)
    local martail = self.m_model.m_martial[index]
    for i,v in ipairs(self.m_model.m_open) do
        if v == martail then
            self.m_model:setSelect(index)
            self.m_view:refreshUI()
            --if self.m_model.m_cur_martial == self.m_model.m_select then
            --    self:updateMsg(99999)
            --else
                self:updateMsg("yes_btn")
            --end
            return
        end
    end

    local cast = ConfigManager:getCommonValueById(46)[1]
    local params =
    {
        on_ok_call = function(msg)
            self:openRequest(martail)
        end,
        cost = cast,
        text = string.format(Language:getTextByKey("Pub_str_0025"), cast[3]),
        show_own_flag = false
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

function M:openRequest(martail)
    local function openCallback(response)
        self:updateMsg("update_data", response, "Pub")
        self.m_model:updateOpen(response.today_can_get_race)
        self.m_view:refreshUI()
    end
    local params = {}
    params.open_race = martail
    self.m_model:getNetData("gacha_open_new_gacha_race", params, openCallback, false, false)
end

return M;
