local M = class("MysticDetailsPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "upgrade_btn" then
    	if self.m_model.m_look == 1 then
    		self:updateMsg("change_tab", {tab_index = 2, evoluation_oid = self.m_model.m_oid}, "Mystic")
    	else
    		self:openView("Mystic",{tab_index = 2, evoluation_oid = self.m_model.m_oid})
    	end
        self:closeView()
    elseif msg == "remove_btn" then
    	self:updateMsg("remove_solt", self.m_model.m_solt, "Mystic")
    	self:closeView()
    elseif msg == "replace_btn" then
    	self:openView("Mystic.MysticSelectPop", {slot_id = self.m_model.m_solt, oid = self.m_model.m_oid})
    	self:closeView()
    elseif msg == "help_btn" then
    	local cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_model.m_id)
    	self:openView("Mystic.MysticGroupDetailsPop",{id = cfg[self.m_model.m_evo].group, lv = cfg[self.m_model.m_evo].buff_lv})
    end
end

return M;
