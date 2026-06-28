local M = class("GuildHighWarMachineMainControl",LikeOO.OOControlBase)

function M:onEnter()
   self.m_timer_id = self:setTimer(0.2, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_view" then    -- 返回
        self:closeView()
    elseif msg == "refresh_data" then
        self.m_model:InitData(data.user_data_page_3)
        self.m_view:refreshUI()
    elseif msg == "recvert_btn" then
        local params = {
            left_name = "talisman_text_0024",
            right_name = "talisman_text_0025",
            tips_text = "guild_high_war_yan_text_0029",
            right_callback= function()
                local function receivetCallback(response)
                    self.m_model:InitData(response.user_data_page_3)
                    self.m_view:refreshUI()
                    self:updateMsg("refresh_data",response,"GuildHighWar.GuildHighWarMachineMain")
                    --self:updateMsg("refresh_data",response,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff"..self.m_model.page_id)
                end
                local params = {}
                params.page_id = self.m_model.page_id
                params.page_type = self.m_model.page_id == 1 and 1 or 2
                self.m_model:getNetData("guild_high_war_reset_all_point", params, receivetCallback)
            end,
        }
        self:openView("Pops.CommonTipsPop", params)
    elseif msg == "level_spine" then
        self.m_view:updateLevelSpine(data)
    else
        self:clickBtn(msg)
    end
end

function M:clickBtn(msg)
    if msg == "attr_icon_1" then return end
    local numText = string.sub(msg,10,string.len(msg))
    local data = self.m_model:getCurDataByPointId(tonumber(numText))
    self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineLevelPop",{data = data,page_id = 3,talent_point= self.m_model.talent_point})
    
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

function M:updateTime()
    self.m_model.m_cur = (self.m_model.m_cur + 1)%self.m_model.m_max
    self.m_model.m_alpha = (self.m_model.m_cur+1)/self.m_model.m_max
    self.m_view:updateAlpha()
end

return M
