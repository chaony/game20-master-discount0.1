local M = class("MysticSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        --if self.m_model.m_select then
        local params = {}
        params.slot_id = self.m_model.m_pos - 1
        params.mystic_oid = data
        self:updateMsg("put_mystic", params, "Mystic")
        --end
        self:closeView()
	elseif msg == "select_mystic" then
		self.m_model:setSelectHero(data)
		self.m_view:refreshUI()
    end
end

return M;
