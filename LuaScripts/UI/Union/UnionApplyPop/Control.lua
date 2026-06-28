local M = class("UnionApplyPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:updateMsg("refreshRedPoint" ,nil ,"Union.UnionMain")
        self:closeView()
    elseif msg == "back_btn" then
    	self:closeView()
    elseif msg == "agree_btn" then
 		self:handleApply(1, data.uid)
    elseif msg == "ignore_btn" then
    	self:handleApply(2, data.uid)
    elseif msg == "all_agree_btn" then
    	self:handleApply(3)
    elseif msg == "all_ignore_btn" then
    	self:handleApply(4)
    end
end

function M:handleApply(sort, uid)
	local function applyRequest(response)
        if response.players then
        	self:updateMsg("update_data", {players = response.players}, "Union.UnionMain")
            self.m_model.m_member_num = #response.players
        end
        self.m_model:updateListData(response.apply_list)
        self.m_view:refreshUI()
    end
    local params = {}
    params.sort = sort
    params.apply_uid = uid
    self.m_model:getNetData("guild_apply_handler", params, applyRequest)
end

return M;
