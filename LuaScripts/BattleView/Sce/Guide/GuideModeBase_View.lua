--场景向导
--主要用于指引玩家去移动
--尤其是多人组队
---@class GuideModeBase_View @
local M = class("GuideModeBase_View")
function M:init( obj, scene, mode )
	--模式
	-- 1 无线循环 
	-- 2 固定站位
	self.mode = mode;
	self.obj = obj;
	self.scene = scene;
	--获取到组件
	self.luaViewHelper = self.obj:GetComponent("LuaViewHelper")
	--初始化内存管理器
	self.playerHelperArr = LuaCSharpArr.New(10)
	local CSharpAccess = self.playerHelperArr:GetCSharpAccess()
	self.luaViewHelper:PinTable(CSharpAccess)

	--给人物设置了20个预留位置
	--1~3人物位置信息
	--4~6人物旋转信息
	--7 人物移动速度
	--8 是否直接设置位置
	--9 人物旋转速度
	--10 是否直接设置旋转

	self.playerHelperArr[7] = self.maxSpeed;
	self.playerHelperArr[9] = 15;

	self.scene:addEventListener_Local(Battle.EventType.MV_SceneGuideModelSyncPosition, {self, self.SceneGuideModelSyncPosition})
	self.scene:addEventListener_Local(Battle.EventType.MV_SceneGuideModelDestory, {self, self.SceneGuideModelDestory})
end

--场景向导销毁
function M:SceneGuideModelDestory(eventName, data)
	--销毁
	self:destroy();
end

--向导同步位置
function M:SceneGuideModelSyncPosition(eventName, data)
	local guideMode = data;
	local x,y,z = data:get_position();
	self:refreshUnityPosition(x,y,z,false)
end

--刷新Unity层的位置
function M:refreshUnityPosition( x, y, z ,isForce )
	if self.playerHelperArr ~= nil then
		if isForce ~= nil and isForce == true then
			self.playerHelperArr[8] = 1;
		else
			self.playerHelperArr[8] = 0;
		end
		self.playerHelperArr[1] = x;
		self.playerHelperArr[2] = y;
		self.playerHelperArr[3] = z;
	end
end

--销毁
function M:destroy()
	self.sceneGuide = nil
	--导航组件上面的Transform组件
	self.sceneGuideTran = nil;
	self.playerHelperArr = nil;
	self.luaViewHelper:PinTable(nil)
end

return M