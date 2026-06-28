local M = class("ShiguangEventLogModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_event_done = self.m_params.event_done or {}
	self.m_chapter_id = self.m_params.chapter_id or -1
end

function M:getShowData()
	local show_data = {}
	local roleplaying_event = ConfigManager:getCfgByName("roleplaying_event")
	local roleplaying_event_item = roleplaying_event[self.m_chapter_id] or {}
	for i,v in ipairs(self.m_event_done) do
		local done_event_cfg = roleplaying_event_item[v]
		if done_event_cfg and done_event_cfg.no_count == 0 then
			table.insert(show_data,{id = v, cfg = done_event_cfg})
		end
	end
	return show_data
end

return M
