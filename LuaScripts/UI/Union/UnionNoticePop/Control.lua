local M = class("UnionNoticeControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
	    self:closeView()
    elseif msg == "ok_btn" then
		self:requestSetting()
    end
end

function M:requestSetting()
	local function setCallback(response)
		self:updateMsg("update_data", response, "Union.UnionMain")
        self:updateMsg("update_data", response, "Union.UnionHall")
        self:closeView()
    end
    local params = {}
    params.desc = self.m_view:getText()
    self.m_model:getNetData("guild_edit_guild", params, setCallback, nil, nil, GlobalConfig.POST)
end

return M;
