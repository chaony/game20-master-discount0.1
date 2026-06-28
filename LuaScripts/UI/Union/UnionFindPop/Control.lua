local M = class("UnionFindPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "find_btn" then
        self:findRequest()
    elseif msg == "cell_btn" then
        self.m_model:setSelectIndex(data)
        self.m_view:refreshUI()
    elseif msg == "fresh_btn" then
        self:freshUnionList()
    end
end

function M:freshUnionList()
    local function createCallback(response)
        self.m_model:updateListData(response.summary)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("guild_recommend", nil, createCallback)
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

return M;
