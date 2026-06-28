--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-30 15:30:44
]]
---@class PlayerAnimator_View @
local M = class("PlayerAnimator_View")

function M:init( player )
	--表示 玩家的视图层
	self.player = player;
	--所有动画状态
	self.states = {}
	--动画列表
	self.animList = Battle.List.new()
	--设定初始的动画速度
	self.animSpeed = 1;
	--unity的动画名称
	self.unityAnimName = "idle";
	--动画状态机切换状态
	self.player:addEventListener_Local(Battle.EventType.MV_PlayerAnimatorChangeState,{self, self.PlayerAnimatorChangeState});
	--设定动画模式
	self.player:addEventListener_Local(Battle.EventType.MV_PlayerAnimatorSetMode,{self, self.PlayerAnimatorSetMode});
	--动画退出状态
	self.player:addEventListener_Local(Battle.EventType.MV_PlayerAnimatorStateExit,{self, self.PlayerAnimatorStateExit});
	--设定动画速度
	self.player:addEventListener_Local(Battle.EventType.MV_PlayerAnimatorSetAnimSpeed,{self,self.PlayerAnimatorSetAnimSpeed})
end

--设定动画速度
function M:set_animSpeed( animSpeed )
	self.animSpeed = GlobalTools:ToFloat( animSpeed );
	self.player:setAnimSpeed(self.animSpeed);
end

--获取动画速度
function M:get_animSpeed()
	return self.animSpeed or 1
end

--监听事件，设定动画速度
function M:PlayerAnimatorSetAnimSpeed(eventName,data )
	self:set_animSpeed(data.animSpeed)
end

--玩家加载完成
function M:player_loadFinish()
	--Unity的动画状态机
	if self.player ~= nil and self.player.luaViewHelper ~= nil then
		self.anim = self.player.luaViewHelper.m_animator;
		self:reset()
		--如果玩家加载完成了
		self:CrossFadeInFixedTime( self.unityAnimName )
	end
end

--数据层 - 状态切换 - 通知 - 视图层
function M:PlayerAnimatorChangeState(eventName, data)
	local stateName = data.stateName;
	local clearList = data.clearList;
	local offset = data.offset;
	self:changeState(stateName, clearList, offset)
end

--数据层 - 设定动画模式 - 通知 - 视图层
function M:PlayerAnimatorSetMode(eventName, data)
	local mode = data.mode;
	self:setAnimUnscale(mode)
end

--数据层 - 状态结束 - 通知 - 视图层
function M:PlayerAnimatorStateExit(eventName, data)
	local stateName = data.stateName;
	self:stateExit(stateName)
end

--重新设置
function M:reset()
	if self.anim ~= nil then
		self.anim:reset();
	end
end

-- Normal = 0,
-- AnimatePhysics = 1,
-- UnscaledTime = 2
-- 设定动画模式
function M:setAnimUnscale( mode )
	if self.anim ~= nil then
		self.anim.mode = mode;
	end
end

--某个动作播放完成之后才执行切换
function M:stateExit( name )
	self:CrossFadeInFixedTime( name )
end


--强制切换状态,不管上一个装填目前到什么程度额，直接切换
function  M:changeState( name, clearList, offset )
	--Unity切换动作
	self:CrossFadeInFixedTime( name, offset )
end

-- 切换 Unity 动画
function M:CrossFadeInFixedTime( name, offset )
	offset = offset or 0;
	self.unityAnimName = name;
	if IsNull(self.anim) == false then
		self.anim:CrossFadeInFixedTime(name, offset)
	end
end


--销毁
function M:destroy()
	self.anim = nil
	self.player = nil
end


return M