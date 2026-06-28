---@class PlayerRangeShow @范围显示
local M = class("PlayerRangeShow")

M.plyMgr = nil

M.friendRange = nil

M.enemyRange = nil
--同屏最大显示数量
M.maxRangeCount = 5
--显示时间间隔
M.showCd = 1
M.friendCd = 0
M.enemyCd = 0

---@param mgr PlayerManager_View
function M:init(mgr)
	self.plyMgr = mgr
	self.friendRange = Battle.List.new()
	self.enemyRange = Battle.List.new()
	self.maxRangeCount = ConfigManager:getBattleCommonValueById(161,5, true)
	self.showCd = GlobalTools:ToFloat(ConfigManager:getBattleCommonValueById(160,1, true))
	self.friendCd = 0
	self.enemyCd = 0
end

--添加检测
function M:addRange(player, data)
	local list = nil
	local curCd = 0
	if player.camp == 1 then
		list = self.friendRange
		curCd = self.friendCd
	else
		list = self.enemyRange
		curCd = self.enemyCd
	end

	if list.Count < self.maxRangeCount and curCd <= 0 then
		local rangeData = {}
		rangeData.curTime = GlobalTools:ToFloat(data.showTime)
		rangeData.player = player
		rangeData.center, rangeData.forward = self:getCenter(data.center, player, data.offset, data.areaRadius)
		if data.rangeType == "sector" then
			self:sector(rangeData, data)
		elseif data.rangeType == "rectangle" then
			self:rectangle(rangeData, data)
		end
		list:add(rangeData)
		
		--刷新cd
		if player.camp == 1 then
			self.friendCd = self.showCd
		else
			self.enemyCd = self.showCd
		end
	end
end

--移除一个检测
function M:removeRange(range)
	if range ~= nil then
		if range.player.camp == 1 then
			ResourceUtil:ReturnItem(range.obj)
			self.friendRange:remove(range)
		else
			ResourceUtil:ReturnItem(range.obj)
			self.enemyRange:remove(range)
		end
	end
end

function M:update(dt)
	if self.friendCd > 0 then
		self.friendCd = self.friendCd - dt
	end
	if self.enemyCd > 0 then
		self.enemyCd = self.enemyCd - dt
	end
	
	for i = self.friendRange.Count, 1, -1 do
		local range = self.friendRange:get(i - 1)
		range.curTime = range.curTime - dt
		if range.curTime <= 0 then
			self:removeRange(range)
		end
	end

	for i = self.enemyRange.Count, 1, -1 do
		local range = self.enemyRange:get(i - 1)
		range.curTime = range.curTime - dt
		if range.curTime <= 0 then
			self:removeRange(range)
		end
	end
end

--圆形范围
function M:sector(rangeData, data)
	local areaRadius = GlobalTools:ToFloat(data.areaRadius)
	local obj = ResourceUtil:LoadCommonEffect("SkillRange_sector",nil)
	obj.transform.position = rangeData.center
	local dir = rangeData.forward
	dir.z = 0
	obj.transform.forward = dir
	obj.transform.localScale = Vector3.one * areaRadius
	local child = obj.transform:GetChild(0)
	local meshRender = child:GetComponent("MeshRenderer")
	if meshRender ~= nil then
		local areaAngle = areaRadius 
		if data.areaAngle then -- 扇形区域应该用角度算，兼容一下，没有角度还有半径
			areaAngle = GlobalTools:ToFloat(data.areaAngle)
		end
		meshRender.material:SetFloat("_Angle",areaAngle/2);
	end
	rangeData.obj = obj
end


--矩形范围
function M:rectangle(rangeData, data)
	local obj = ResourceUtil:LoadCommonEffect("SkillRange_rectangle",nil)
	obj.transform.position = rangeData.center
	local dir = rangeData.forward
	dir.z = 0
	obj.transform.forward = dir
	
	local areaHeight = GlobalTools:ToFloat(data.areaHeight)
	local areaWidth = GlobalTools:ToFloat(data.areaWidth)

	obj.transform.localScale = Vector3.New(areaWidth * 2, 1, areaHeight)
	--local forward = obj.transform:Find("forward")
	--forward.localPosition = Vector3.New(0, 0, areaHeight)
	--forward.localScale = Vector3.New(areaWidth * 2, 1, 1)
	--
	--local back = obj.transform:Find("back")
	--back.localPosition = Vector3.New(0, 0, 0)
	--back.localScale = Vector3.New( areaWidth * 2, 1, 1)
	--
	--local left = obj.transform:Find("left")
	--left.localPosition = Vector3.New(-areaWidth, 0, areaHeight/2)
	--left.localScale = Vector3.New(areaHeight, 1, 1)
	--
	--local right = obj.transform:Find("right")
	--right.localPosition = Vector3.New(areaWidth, 0, areaHeight/2)
	--right.localScale = Vector3.New(areaHeight, 1, 1)
	rangeData.obj = obj
end

--player 是视图层
function M:getCenter(centerType, player, offset, radius)
	local pos = Vector3(0,0,0)
	if centerType == "player" then
		pos = player:get_position()
	elseif centerType == "Densearea" then
		local areaRadius = GlobalTools:ToFloat(radius)
		pos = SelectTargetTool:findFixPoint(player, "Densearea", areaRadius)
	end
	local forward = player:get_dir()
	local right = player:getRight()
	pos = pos + forward * offset.z + right * offset.x + Vector3.up * offset.y
	return pos, forward
end

function M:destroy()
	for i = 1, self.friendRange.Count do
		local range = self.friendRange:get(i - 1)
		ResourceUtil:ReturnItem(range.obj)
	end
	self.friendRange:clear()
	
	for i = 1, self.enemyRange.Count do
		local range = self.enemyRange:get(i - 1)
		ResourceUtil:ReturnItem(range.obj)
	end
	self.enemyRange:clear()
end

return M