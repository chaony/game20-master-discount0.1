local M = class("UnionUpgradeControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then   -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
    	self:closeView()
    elseif msg == "ok_btn" then
    	if self.m_model:isCanUpgrade() then
	    	self:upgradeRequest()
	    else
	    	local params =
	        {
	            on_ok_call = function(msg)
	                
	            end,
	            no_close_btn = true,
	            text = Language:getTextByKey("union_str_0042")
	        }
	        static_rootControl:openView("Pops.CommonPop", params)
	    end
    end
end

function M:upgradeRequest()
	local function upgradeCall(response)
        self:updateMsg("update_data",response, "Union.UnionHall")
        self:updateMsg("update_data",response, "Union.UnionMain")
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0413"), delay_close = 2})
        self:closeView()
    end
    self.m_model:getNetData("guild_levelup", {}, upgradeCall)
end

return M;
