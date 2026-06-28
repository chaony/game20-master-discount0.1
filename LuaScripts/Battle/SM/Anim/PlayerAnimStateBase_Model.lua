---@class PlayerAnimStateBase_Model @玩家动画状态机基类
---@field player PlayerModel
---@field runtime number 运行动画时间
---@field action AnimEvtAction_Model
---@field name string 动画名称
local M = class("PlayerAnimStateBase_Model")

--动画状态播放完成 后调用
M.onCompleteHandler = nil
--运行动画时间
M.runtime = 0
--运行开关
M.running = false
--状态的拥有者
M.player = nil
--当前状态的当前帧
M.action = nil
--是否是循环动画
M.isLooping = nil
--循环停止时长
M.loopEndTime = nil

M.name = nil

--初始化动画事件管理器
---@param player PlayerModel
function M:init( player, clipName )
	--动画名称
	self.name = clipName
	--玩家数据
	self.player = player
	--通过动画名称获取动作
	self.action = player.evtMgr:getAction(clipName)
	--能否切换动画
	self.canChangeAnim = false;
	--动画是否循环
	if self.action ~= nil then	
		--当前动画的时间长度
		self.animLength = self.action.animLength		-- common 动作没有时长
		if	self.action["isLoop"] == true then
			self.isLooping = true
		else
			self.isLooping = false
		end
	end
end

--进入当前状态
function M:enter()
	--初始运行时间
	self.runtime = GlobalTools.base0;
	self.running = true
	self.canChangeAnim = false;
	--是否能切换动画了
	if self.action ~= nil then
		self.action:start()
    end
end

--状态更新
function M:update( dt )
	if self.running then
		-- 动画速度
		local animSpeed = self.player.animator:get_animSpeed();
		-- 时间
		local time = GlobalTools:Mul( dt, animSpeed )
		-- 累加的更新时间
		-- 更新时间
		self.runtime = self.runtime + time
		 --根据时间更新
		if self.action ~= nil then
		 	self.action:update(self.runtime)
		end

		--是否循环
		if self.isLooping and 
			self.loopEndTime ~= nil and 
			self.loopEndTime <= TimeManager:time() and 
			self.loopEndTime >= GlobalTools.base0 then
			if self.player.animator:nextAnim() == false then
				self:exit()
			end
			return
		end
		
		--时间
		if self.runtime >= self.animLength then
			if self.isLooping then
				self.runtime = GlobalTools.base0
				if self.action ~= nil then
					self.action:start()
				end
			else
				if self.player.animator:nextAnim() == false then
					self:exit()
				end
			end
		end
	end
end


function M:update_unsdt( unsdt )
	if self.running then
		if self.player.animator.mode == 2 then
			-- 时间
			local animSpeed = self.player.animator:get_animSpeed();
			local time = GlobalTools:Mul( unsdt, animSpeed )
			self.runtime = self.runtime + time;
			if self.action ~= nil then
				self.action:update(self.runtime)
			end

			if self.runtime >= self.animLength then
				if self.isLooping then
					self.runtime = 0
					if self.action ~= nil then
						self.action:start()
					end
				else
					self:exit()
				end
			end
		end
	end
end

--退出当前状态
function M:exit()
	if self.onCompleteHandler ~= nil then
		local temp = self.onCompleteHandler
		self.onCompleteHandler = nil
		temp()
	end
	self.canChangeAnim = true;
	self.running = false
end

--动作是否完成
function M:finish()
	return self.running == false
end


return M