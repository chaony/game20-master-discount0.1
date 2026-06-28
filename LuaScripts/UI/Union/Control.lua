local M = class("UnionPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Union.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "create_btn" then
        self:createUnion()
    elseif msg == "find_btn" then
        self:findRequest()
    elseif msg == "cell_btn" then
        self.m_model:setSelectIndex(data)
        self.m_view:refreshUI()
    elseif msg == "apply_btn" then
        local guild = self.m_model:getSelectUnionData()
        if not guild.is_apply then
            self:joinRequest(guild)
        end
    elseif msg == "one_apply_btn" then
        self:oneKeyJoinRequest()
    elseif msg == "fresh_btn" then
        self:freshUnionList()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "world_boss_str_0017"
        params.content = "tid#boss_rush1"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:freshUnionList()
    local function createCallback(response)
        self.m_model:updateListData(response.summary)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("guild_index", nil, createCallback)
end

function M:createUnion()
    local params =
    {
        on_ok_call = function(msg)
            self:createResquest(msg)
        end,
    }
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

function M:findRequest()
    local name = self.m_view:getFindUnionName()
    if name == nil or name == "" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0007"), delay_close = 2})
        return
    end

    local function findCallback(response, tag, status_code)
        if response then
            self.m_model:updateListData(response.search_guilds)
            self.m_view:refreshUI()
        else
            if status_code == GlobalConfig.SENSITIVE_WORDS_CODE then
                self.m_view:setFindUnionName("")
            end
        end
    end
    local params = {}
    params.name = name
    self.m_model:getNetData("guild_search_guild", params, findCallback, nil, true)
end

function M:joinRequest(data)
    local function joinCallback(response)
        local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
        if guild_id > 0 then
            UserDataManager.guild_lv = response.guild.level
            self:closeView()
            self:updateMsg("openUnion", nil, "parent")
        else
            self.m_model:setApplay(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.guild_id = data.id
    self.m_model:getNetData("guild_join_guild", params, joinCallback)
end

function M:oneKeyJoinRequest()
    local function joinCallback(response)
        local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
        if guild_id > 0 then
            UserDataManager.guild_lv = response.guild.level
            self:closeView()
            self:updateMsg("openUnion", nil, "parent")
        else
            self.m_model:setApplay(response)
            self.m_view:refreshUI()
        end
    end

    self.m_model:getNetData("guild_auto_join", nil, joinCallback)
end

return M;
