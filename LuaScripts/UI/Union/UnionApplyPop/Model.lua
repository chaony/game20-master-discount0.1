local M = class("UnionApplyPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_apply_info")
end

function M:onEnter()
	self.m_member_num = self.m_params.member or 1
	self:updateListData(self.m_data.apply_list)
end

function M:updateListData(data)
	self.m_list_data = data
end

function M:callBack(data)
	local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    if guild_id and guild_id > 0 then
    	M.super.callBack(self,data)
    else
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("union_str_0028"), delay_close = 2})
        static_rootControl:closeAllViewPop()
    end
end

return M
