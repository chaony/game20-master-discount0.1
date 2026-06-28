local M = class("StoryParagraph")

StoryEvent = require("UI.Story.StoryEvent")

M.data = nil

M.storyId = nil

M.storyName = nil

M.curGroupId = 0

M.curGroupFinish = false

M.groups = nil

M.view = nil

--初始化
function M:init(data, view)
	self.view = view
	self.data = data
	
	self.storyId = tonumber(data.story_id)
	self.storyName = data.story_name
	
	self.groups = {}

	for k,v in pairs(data.events) do
		local group = require("UI.Story.StoryGroup").new()
		group:init(tonumber(k), v, self)
		self.groups[tonumber(k)] = group
	end
	
	self:play(0)
end

function M:play(groupId)
	for k,v in pairs(self.groups) do
		if v.id >= groupId then
			v:reset()
		end
		v:groupShow(false, 0)
	end
	
	local storyGroup = self.groups[groupId]

	if storyGroup ~= nil then
		self.curGroupFinish = false
		self.curGroupId = groupId
		storyGroup:play("")
	end
end

function M:tryFinish(groupId)
	self.curGroupFinish = true
	self.view:tryFinish()
end

function M:checkFinish()
	if self.curGroupFinish then
		for k,v in pairs(self.groups) do
			if self.curGroupId == v.id then
				if k < table.nums(self.groups) - 1 then
					self.curGroupFinish = false
					self.curGroupId = self.groups[k + 1].id
					self.groups[k + 1]:play()
				else
					self.view.m_control:closeView()
				end
			end
		end
	end
end


function M:destroy()
	for k,v in ipairs(self.groups) do
		v:destroy()
	end
	self.groups = {}
end

return M