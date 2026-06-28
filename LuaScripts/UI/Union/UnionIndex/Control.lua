local M = class("UnionIndexControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Union.UnionIndex.Guide"
    audio:SendEvtUI("Amb_2D_indoor_fire")
end

function M:startGuide()
    self:triggerGuide()
end

function M:triggerGuide()
    local id = ConfigManager:getCommonValueById(302)
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(id, 2)
    if have_guide then
        self.m_guide:checkGuide()
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "create_btn" then
        self:createUnion()
    elseif msg == "join_btn" then
        self:openView("Union", self.m_model.m_data)
        self:closeView()
    elseif msg == "artifact_btn" then
        self:openView("Union.UnionArtifactPop")
        self:closeView()
    end
end

function M:createUnion()
    local params =
    {
        on_ok_call = function(msg)
            self:createResquest(msg)
        end,
    }
    if self.m_model:checkCanCreatTeam() == false and self.m_model:checkDayLock() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0061", self.m_model.creat_limit,self.m_model.creat_day), delay_close = 2})
        return 
    end
    self:openView("Union.UnionCreatePop", params)
end

function M:createResquest(msg)
    if msg == nil or msg.name == nil or msg.name == "" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0007"), delay_close = 2})
        return
    end
    local function createCallback(response)
        UserDataManager.guild_lv = response.guild.level
        self:closeView()
        self:updateMsg("openUnion", nil, "parent")
    end

    self.m_model:getNetData("guild_create_guild", msg, createCallback)
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    M.super.destroy(self)
end

return M;
