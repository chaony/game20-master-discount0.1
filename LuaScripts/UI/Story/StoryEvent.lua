local M = class("StoryEvent")

M.data = nil

M.id = nil

M.parentId = nil

M.group = nil

M.hasObj = true

M.needFinish = false

M.type = nil

M.obj = nil

M.parentName = nil

--初始化
function M:init(fullId, data, group)
	self.data = data
	self.group = group
	self.id = tonumber(data.id)
	local parentId, count = string.gsub(fullId, ".%d+$", "")
	if count > 0 then
		self.parentId = string.gsub(fullId, ".%d+$", "")
		if self.group.optionEvents[self.parentId] == nil then
			self.group.optionEvents[self.parentId] = {}
		end
		self.group.optionEvents[self.parentId][data.id] = self
	else
		self.parentId = ""
		self.group.events[data.id] = self
	end
	self.type = data.type
	
	self:createObj()
end

function M:createObj()
	if self.hasObj then
		local parent = GlobalTools:FindTransform(self.group.obj.transform, self.parentName)
		self.obj = ResourceUtil:LoadUIGameObject("Story/Story"..self.type, Vector3.zero, parent.gameObject)
		self.obj.transform.localPosition = Vector3.New(0,0,0);
		local name = self.id .. ":Story" .. self.type;
		if self.parentId ~= "" then
			name = self.parentId .. "." .. name
		end
		self.obj.name = name
	end
end

function M:reset()
	if self.hasObj then
		self.obj:SetActive(false)
	end
end

function M:play()
	self:finish()
end

function M:finish()
	if self.needFinish then
		self.group:tryFinish(self)
	end
end

function M:loadSprite(image, path)
	if path == "" then
		return
	end
	local imagePath = path
	if string.find(imagePath, "Resources") then
		local img_msg = string.split(imagePath, "Resources/")[2]
		img_msg = string.split(img_msg, ".")[1]
		local abPath = string.gsub(imagePath, "/", "_")
		local ab_name = string.split(abPath, "Resources_")[2]
		ab_name = string.split(ab_name, ".")[1]

		image.sprite = ResourceUtil:LoadSprite(img_msg, ab_name)
	else
		local str = string.split(imagePath, "/")
		local img_msg = string.split(str[#str], ".")[1]
		
		GameUtil:updateBgImg(image, img_msg)
	end
end

function M:getVector2(x, y)
	local pos = CS.UnityEngine.Vector2.zero
	pos.x = x
	pos.y = y
	return pos
end

function M:destroy()
	ResourceUtil:ReturnItem(self.obj)
end

return M