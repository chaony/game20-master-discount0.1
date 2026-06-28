local M = class("ActivitiesPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh",nil,"parent")
        self:closeView()
    elseif msg == "cell_click" then
        local id = data.active_id
    	if id == 1 then
    		self:openView("Activities.Recruit")
		elseif id == 2 then
			self:openView("Activities.HeroGather")
		elseif id == 3 then
            self:openView("Activities.SevenDay")
        end
    elseif msg == "refresh_red_point" then
        self.m_view:refreshUI()
    elseif msg == "downtime" then
        self:updateData()
    end
end

function M:updateData()
    local function callback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_active_index", nil, callback)
end

return M;
