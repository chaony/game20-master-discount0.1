local M = class("StoryGroup")

M.id = nil

M.data = nil

M.story = nil

M.obj = nil

M.curEventListId = "";

M.events = nil

M.optionEvents = nil

M.noWait = false

function M:init(id, data, storyParagraph)
	self.id = id
	self.data = data
	
	self.story = storyParagraph

	self.obj = ResourceUtil:LoadUIGameObject("Story/StoryGroup", Vector3.zero, self.story.view.content_node)
	local rect = self.obj:GetComponent("RectTransform")
	local offsetMin = rect.offsetMin
	offsetMin.x = 0
	offsetMin.y = 0
	rect.offsetMin = offsetMin

	local offsetMax = rect.offsetMax
	offsetMax.x = 0
	offsetMax.y = 0
	rect.offsetMax = offsetMax
	
	self.obj.name = "StoryGroup"..self.id
	self.events = {}
	self.optionEvents = {}
	for k,v in pairs(self.data) do
		local event = require("UI.Story.StoryEvent"..v.type).new()
		event:init(k, v, self)
		
		--self.events[k] = event
	end
end

function M:play(eventsId)
	--self:groupShow(true, step)
	self.noWait = true
	
	local list = self.events
	if eventsId == "" then
		for k,v in pairs(self.events) do
			v:reset()
		end

		for k1,v1 in pairs(self.optionEvents) do
			for k2,v2 in pairs(v1) do
				v2:reset()
			end
		end
	else
		list = self.optionEvents[eventsId]
	end

	if table.nums(list) > 0 then
		for i = 0, table.nums(list) - 1 do
			local storyEvent = list[i .. ""]
			if storyEvent.hasObj then
				storyEvent.obj:SetActive(true)
			end
			storyEvent:play()
			if storyEvent.needFinish then
				self.noWait = false
				break
			end
		end
		
		if self.noWait then
			local key = self.curEventListId
			if key ~= "" then
				key = string.gsub(key, "_%d+$", "")
				local newKey, count = string.gsub(key, ".%d+$", "")
				if count > 0 then
					self.curEventListId = newKey
					local str = string.split(newKey, '.')
					self:toNextEvent(newKey, tonumber(str[#str.count]))
				else
					self.curEventListId = ""
					self:toNextEvent("", tonumber(key))
				end
			else
				self.curEventListId = ""
				self.story:tryFinish(self.id)
			end
		end
	else
		local key = self.curEventListId
		if key ~= "" then
			key = string.gsub(key, "_%d+$", "")
			local newKey, count = string.gsub(key, ".%d+$", "")
			if count > 0 then
				self.curEventListId = newKey
				local str = string.split(newKey, '.')
				self:toNextEvent(newKey, tonumber(str[#str.count]))
			else
				self.curEventListId = ""
				self:toNextEvent("", tonumber(key))
			end
		else
			self.curEventListId = ""
			self.story:tryFinish(self.id)
		end
	end
end

function M:reset()
	for k,v in pairs(self.events) do
		v:reset()
	end
end

function M:tryFinish(storyEvent)
	if self.noWait then
		self:toNextEvent(self.curEventListId, storyEvent.id)
	else
		if storyEvent.needFinish then
			self.noWait = true
			self:toNextEvent(self.curEventListId, storyEvent.id)
		end
	end
end

function M:toNextEvent(key, eventId)
	self.noWait = true
	local list = self.events
	if key ~= "" then
		list = self.optionEvents[key]
	end

	if eventId + 1 < table.nums(list) then
		for i = eventId + 1, table.nums(list) - 1 do
			local storyEvent = list[i .. ""]
			if storyEvent.hasObj then
				storyEvent.obj:SetActive(true)
			end
			storyEvent:play()
			if storyEvent.needFinish then
				self.noWait = false
				break
			end
		end

		if self.noWait then
			local key = self.curEventListId
			if key ~= "" then
				key = string.gsub(key, "_%d+$", "")
				local newKey, count = string.gsub(key, ".%d+$", "")
				if count > 0 then
					self.curEventListId = newKey
					local str = string.split(newKey, '.')
					self:toNextEvent(newKey, tonumber(str[#str.count]))
				else
					self.curEventListId = ""
					self:toNextEvent("", tonumber(key))
				end
			else
				self.curEventListId = ""
				self.story:tryFinish(self.id)
			end
		end
	else
		local key = self.curEventListId
		if key ~= "" then
			key = string.gsub(key, "_%d+$", "")
			local newKey, count = string.gsub(key, ".%d+$", "")
			if count > 0 then
				self.curEventListId = newKey
				local str = string.split(newKey, '.')
				self:toNextEvent(newKey, tonumber(str[#str.count]))
			else
				self.curEventListId = ""
				self:toNextEvent("", tonumber(key))
			end
		else
			self.curEventListId = ""
			self.story:tryFinish(self.id)
		end
	end
end

function M:groupShow(show, step)
	--for k,v in pairs(self.events) do
	--	if v.hasObj and (step == 0 or step == v.eventStep) then
	--		v.obj:SetActive(show)
	--	end
	--end
end

function M:destroy()
	ResourceUtil:ReturnItem(self.obj)
	for k,v in pairs(self.events) do
		v:destroy()
	end
	self.events = {}
end

return M