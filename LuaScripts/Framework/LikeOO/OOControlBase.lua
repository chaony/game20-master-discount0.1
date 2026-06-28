---@class OOControlBase
---@field m_view OOViewBase
---@field m_model OODataBase
---@field m_guide OOGuideBase
local M = class("OOControlBase", nil)

-- message data list
M.m_msg = nil		
-- run loop with message data
M.m_update_key = nil
-- map with chiled controller
M.m_chilrenList = nil
-- model for this control
M.m_model = nil
-- view with self
M.m_view = nil
-- mind perant control
M.m_parent = nil
-- need save data for goBack
M.m_needBack = true
-- timer list
M.m_timerList = nil
M.m_timer_remove = nil

M.m_open_sound_effect = nil

M.m_close_sound_effect = nil

-- player guide control
M.m_guide = nil

M.m_closing = nil

-- static var with root control
static_rootControl = nil
-- static var that with histroy page list
static_pageList = LikeOO.OOStack:new()
-- home name
static_homeName = ""

-- static root node
static_root_node = nil
-- static front pop layer
static_topLayer = nil
-- static front layer
static_frontLayer = nil
-- static normal layer
static_normalLayer = nil
-- ghost pop
static_ghostChildren = nil

static_ui_camera = nil

-- 
function M:create()
	self.m_msg = LikeOO.OOMsgList:new()
	self.m_chilrenList = {}
	self.m_timerList = {}
	self.m_timer_remove = {}
	self.m_closing = false
	self.m_controls = {}
	self:onCreate()

	local tempname = "UI." .. self.m_model:getName() .. ".View"
	local tempCls
	if GameVersionConfig.LUA_RELOAD_DEBUG then
		tempCls = LuaReload(tempname)
	else
		tempCls = require(tempname)
	end

	self.m_view = tempCls.new()
	self.m_view.m_control = self
	self.m_view.m_model = self.m_model
	self:createView()
end

function M:createGuide()
	if self.m_guide_file_name then
	    local __guide = require(self.m_guide_file_name)
	    self.m_guide = __guide.new(self)
	    self.m_guide:preset()
	end
end

function M:startGuide()
	if self.m_guide then
		self.m_guide:start()
	end
end

function M:onDestroy()
end

function M:destroy()
	local name = self.m_model and self.m_model:getName()
	name = tostring(name)
	Logger.log("--------- destroy control --------" .. name)
	self:onDestroy()	
	if self.m_guide then
		self.m_guide:destroy()
	end
	if self.m_update_key then
    	GameMain.removeUpdate(self.m_update_key)
	end
    -- message data list
    if(self.m_msg)then
    	self.m_msg:cleanAll()
	end
	self.m_msg = nil		
	-- run loop with message data
	self.m_update_key = nil
	-- map with chiled controller
	for k,v in pairs(self.m_chilrenList) do
		if(not isClassOrObject(v))then
			for k,v in pairs(v) do
				v:closeView()
			end
		else
			v:closeView()
		end
	end
	if(self.m_view)then
		self.m_view:destroy()
	end

	if(self.m_model)then
		self.m_model:destroy()
	end

	-- mind perant control
	if(self.m_parent ~= nil)then
		local tempChiled = self.m_parent.m_chilrenList[self.m_model:getName()]
		if tempChiled and (not isClassOrObject(tempChiled))then
			self.m_parent.m_chilrenList[self.m_model:getName()][self.m_model:getAlias()] = nil
			if(table.nums(self.m_parent.m_chilrenList[self.m_model:getName()])<=0)then
				self.m_parent.m_chilrenList[self.m_model:getName()] = nil
			end
		else
			self.m_parent.m_chilrenList[self.m_model:getName()] = nil
		end
		self.m_parent = nil
	end
	-- model for this control
	self.m_model = nil
	-- view with self
	self.m_view = nil
	self.m_closing = nil
	self.m_controls = nil;
	for k,v in pairs(self.m_timerList) do
		self.m_timerList[k] = nil
	end
	if static_ghostChildren and name and static_ghostChildren[name] then
		static_ghostChildren[name] = nil
	end
	EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW,{name = name})
end

-- 构造view用
function M:createView()
	local tempVT = self.m_view:getType()
	--这行代码的作用是区分不同类型的UI界面：
	--当 tempVT == 1：处理全屏主界面的创建逻辑
	--当 tempVT == 2：处理弹窗界面的创建逻辑（就是你选中的这行代码所对应的分支）
	if(tempVT == 1)then
		local name = self.m_model and self.m_model:getName()
		-- changed scene
		if(static_rootControl)then-- 如果当前已有根控制器（旧页面存在）
			if(self.m_model.m_type == 1)then	-- if data type is a first flag -- 新页面的 type == 1：普通前进跳转
				if(static_rootControl.m_needBack)then-- 旧页面支持返回
					static_rootControl.m_model.m_type = 2-- 标记旧页面模型为"历史页"
					static_pageList:addData(static_rootControl.m_model)-- 旧页面入栈，支持goBack
				end

			elseif(self.m_model.m_type == 2)then	-- if data type is a histroy flag-- 新页面的 type == 2：历史回退跳转
				static_rootControl.m_model:destroy() -- 旧页面模型直接销毁（不入栈）
			end
			static_rootControl:destroy()-- 最终都销毁旧根控制器
		else
			self:init_oo() -- 没有旧页面，初始化OO框架
		end
		self.m_parent = nil
		self.m_view:create()
		static_rootControl = self
	elseif(tempVT == 2)then
		--下面这段代码实现了弹窗控件的分层管理机制，
		--区分了普通弹窗和特殊弹窗，
		--并支持通过别名来管理多个同名但不同实例的控件。
		self.m_view:create()
		-- add pop in the control
		local normalFlag = self.m_view.m_normal
		-- 非弹窗界面处理
		--幽灵弹窗是一种独立于页面层级的弹窗，它不跟随页面销毁而销毁，生命周期由全局
		--static_ghostChildren 管理。典型场景如：系统提示框、网络断线提示、
		--强制更新弹窗等——无论当前在哪个页面，这类弹窗都需要能独立弹出和关闭。
		if(not normalFlag)then
			self.m_parent = nil-- 幽灵弹窗不挂载父控制器，设为 nil
			if(not static_ghostChildren)then
				static_ghostChildren = {}
			end
			local tempName = self.m_model:getName() -- 获取当前控制器的名称
			if(static_ghostChildren[tempName]~=nil)then
				static_ghostChildren[tempName]:closeView() -- 如果同名幽灵弹窗已存在，先关闭旧的
			end
			static_ghostChildren[tempName] = self-- 将当前控制器注册为新的幽灵弹窗
		else
			if(static_rootControl)then
				self.m_parent = static_rootControl
				if(static_rootControl.m_chilrenList[self.m_model:getName()]~=nil)then
					local tempName = self.m_model:getName()
					local tempAlias = self.m_model:getAlias()
					local tempC = static_rootControl.m_chilrenList[tempName]
					if(not isClassOrObject(tempC))then
						if(tempAlias == nil)then
							local tempAl = #tempC+1
							tempC[tempAl] = self
							self.m_model.m_alias = tempAl
						else
							tempC[tempAlias] = self
						end
					else
						static_rootControl.m_chilrenList[tempName] = {}
						local alias = tempC.m_model:getAlias()

						if(alias == nil)then
							static_rootControl.m_chilrenList[tempName][1] = tempC
							tempC.m_model.m_alias = 1
						else
							static_rootControl.m_chilrenList[tempName][alias] = tempC
						end

						local tempCR = static_rootControl.m_chilrenList[tempName]
						if(tempAlias == nil)then
							local tempAl = #tempCR+1
							tempCR[tempAl] = self
							self.m_model.m_alias = tempAl
						else
							tempCR[tempAlias] = self
						end
					end
				else
					static_rootControl.m_chilrenList[self.m_model:getName()] = self
				end
			end
		end
	end
	self:addControlUpdate()
	--self:onUpdate()
	self.m_view:onEnter()
	-- 音效
	if self.m_open_sound_effect then
		-- pop开启音效
		audio:SendEvtUI(self.m_open_sound_effect)
	end
	self:onEnter()
	self:createGuide()
	-- 延时关闭低于当前全屏界面order的ui界面
	self:openTransition()
	
	if(self.m_model:getName() == static_homeName)then
		static_pageList:cleanAll()
	end
end

-- 延时关闭低于当前全屏界面order的ui界面
function M:openTransition()
	self.m_view:openTransition(function()
		self:retainVisibleView()
		self:startGuide()
		EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW,{name = self.m_model:getName()})
		if self.m_view then
			self.m_view:openTransitionEnd()
		end
	end)
end

function M:addControlUpdate()
	local function tick(dt)
		for tk,tv in pairs(self.m_timerList) do
			tv.time = tv.time+dt
			if(tv.inter<=0)then
				tv.callFunc(self, tv.time)
				tv.time = 0
			elseif(tv.time>=tv.inter)then
				tv.callFunc(self, tv.inter)
				tv.time = tv.time-tv.inter
			end
		end

		for k,v in pairs(self.m_timer_remove) do
			self.m_timerList[k] = nil
			self.m_timer_remove[k] = nil
		end
		local tempMsg = self.m_msg and self.m_msg:pop()
		if(tempMsg~=nil)then
			if(tempMsg.m_msg == "oo_update")then
				if(static_rootControl~=nil)then
					static_rootControl:onUpdate()
					for k,v in pairs(static_rootControl.m_chilrenList) do
						if(not isClassOrObject(v))then
							for kc,vc in pairs(v) do
								vc:onUpdate()
							end
						else
							v:onUpdate()
						end
					end
				end
			else
				self:onHandle(tempMsg.m_msg, tempMsg.m_model)
			end
		end
	end
	self.m_update_key = self.m_model:getName() .. "_control_update_" .. tostring(tick)
	GameMain.addUpdate(self.m_update_key, tick)
end

--[[
	打开指定名字的窗口

]]
function M:openView(name, params, alias, ismulity)
	--todo 如果是model状态则只能打开一个。多余的会关掉。
	if ismulity == nil or ismulity == false then
		local result = self:hasChild(name,alias)
		if result == true then
			Logger.logWarning("--------------no  openView : " .. tostring(name))
			return
		end
	end

	local tempname = "UI." .. name .. ".Model"
	Logger.logAlways("-------------- openView : " .. tempname )

	local tempCls
	if GameVersionConfig.LUA_RELOAD_DEBUG then 
		tempCls = LuaReload(tempname)
	else
		tempCls = require(tempname)
	end
	---@type OODataBase
	local tempModel = tempCls:new()
	tempModel:create(name, params, alias)
end

function M:closeAllViewPop(not_close_tab)
	if static_rootControl == nil then
		return false
	end
	local chilrenList = static_rootControl.m_chilrenList or {}
	not_close_tab = not_close_tab or {}
	for k,v in pairs(chilrenList) do
		if(not isClassOrObject(v))then
			for kc,vc in pairs(v) do
				local name = vc.m_model:getName()
				if not not_close_tab[name] then
					vc:closeView()
				end
			end
		else
			local name = v.m_model:getName()
			if not not_close_tab[name] then
				v:closeView()
			end
		end
	end
	if static_ghostChildren then
		for kc,vc in pairs(static_ghostChildren) do
			local name = vc.m_model:getName()
			if not not_close_tab[name] then
				vc:closeView()
			end
		end
	end
end

function M:closeView(name, alias, close_anim_flag)
	self:realCloseView(name, alias, close_anim_flag)
end

function M:realCloseView(name, alias, close_anim_flag)
	-- 音效
	if self.m_close_sound_effect then
		-- pop开启音效
		audio:SendEvtUI(self.m_close_sound_effect)
	end

	if(name)then
		local tempChiled = static_rootControl.m_chilrenList[name]
		if(tempChiled)then
			if(not isClassOrObject(tempChiled))then
				if(alias)then
					local tempAliasC = tempChiled[alias]
					if(tempAliasC)then
						tempAliasC:closeView(nil,nil,close_anim_flag)
						if static_rootControl.m_chilrenList[name] then
							static_rootControl.m_chilrenList[name][alias] = nil
							if(table.nums(static_rootControl.m_chilrenList[name])<=0)then
								static_rootControl.m_chilrenList[name] = nil
							end
						end
					end
				else
					for k,v in pairs(tempChiled) do
						v:closeView(nil,nil,close_anim_flag)
					end
					static_rootControl.m_chilrenList[name] = nil
				end
			else
				tempChiled:closeView(nil,nil,close_anim_flag)
				static_rootControl.m_chilrenList[name] = nil
			end
		elseif(static_ghostChildren~=nil and static_ghostChildren[name]~=nil)then
			static_ghostChildren[name]:closeView(nil,nil,close_anim_flag)
		end
	else
		if self.m_view and self.m_closing == false then
			self.m_closing = true
			self:releaseVisibleView()
			if close_anim_flag == false then
				self:destroy()
			else
				self.m_view:closeTransition(function()
					self:destroy()
				end)
			end
		end
	end
end

--[[
更新一个消息到消息队列中
msg :消息标记
data:为消息数据
flag:为数据传递标志
	 'this'   当前control消息
	 'parent' 父control消息
	 '其他'   指定名字control消息
]]
function M:updateMsg(msg, data, flag, alias)
	local temp = { m_msg = msg, m_model = data }

	if(flag == 'this' or flag == nil)then
		if self.m_msg then
			self.m_msg:addMsg(temp)
		end
	elseif(flag == 'parent')then
		if(self.m_parent)then
			self.m_parent:updateMsg(msg, data, 'this')
		elseif(static_rootControl)then
			static_rootControl:updateMsg(msg, data, 'this')
		else
			self.m_msg:addMsg(temp)
		end
	else
		if(static_rootControl.m_chilrenList[flag] ~= nil)then
			Logger.log("---------- yock chilren " .. flag)
			local tempChilren = static_rootControl.m_chilrenList[flag]
			if(not isClassOrObject(tempChilren))then
				if(alias)then
					if(tempChilren[alias] ~= nil)then
						tempChilren[alias]:updateMsg(msg, data, 'this')
					else
						for k,v in pairs(tempChilren) do
							Logger.log(k)
						end
						Logger.log("---------- yock no chilren " .. flag .. "alias=" .. alias)
					end
				else
					Logger.log("----------- updateMsg all chiled " .. flag)
					for k,v in pairs(tempChilren) do
						v:updateMsg(msg, data, 'this')	
					end
				end
			else
				static_rootControl.m_chilrenList[flag]:updateMsg(msg, data, 'this')
			end
		elseif(static_ghostChildren~=nil and static_ghostChildren[flag]~=nil)then
			static_ghostChildren[flag]:updateMsg(msg, data, 'this')
		else

			for k,v in pairs(static_rootControl.m_chilrenList) do
				Logger.log(k)
			end
			Logger.log("---------- yock no chilren " .. flag)
		end
	end

end

--[[
	发出一个更新全族消息
]]
function M:updateView()
	if(static_rootControl~=nil)then
		static_rootControl:updateMsg("oo_updata")
	end
end

--[[
	检查是否可以回退
	返回值：true   可以返回
		   false  不可以返回
]]

function M:canBack()
	if(static_pageList:hasData())then
		return true
	else
		return false
	end
end

--[[
	返回上一个页面
	从历史数据里取得最后一个压栈数据
	还原视图
	duress: 强制重新拿数据，从onCreate开始 true
]]
function M:goBack(duress)
	if(not self:canBack())then
		self:enterMainPage()
		return
	end
	local tempModel = static_pageList:pop()
	if(tempModel.m_name == static_homeName)then
		static_pageList:cleanAll()
	end
	if tempModel.m_name == "main_page.main_page" then 
		self:enterMainPage()		
	else 
		local goBack = function ()
			tempModel.m_type = 2
			if(duress == nil or duress == false)then
				tempModel:callBack(tempModel.m_data)
			else
				tempModel.m_data = nil
				tempModel:onCreate()
			end
		end
		goBack()
	end
end

--[[
	返回当前页面的根节点
	还原视图
	duress: 强制重新拿数据，从onCreate开始 true
]]
function M:goCurrent(duress)
	local control = self.m_parent or static_rootControl
	local model = control.m_model

	if model.m_name == "main_page.main_page" then 
		self:enterMainPage()
	else 
		model.m_type = 2
		if(duress == nil or duress == false)then
			model:callBack(model.m_model)
		else
			model.m_model = nil
			model:onCreate()
		end
	end
end

--[[
	设置返回重点页面
]]
function M:setHomeName(homeName)
	static_homeName = homeName
end


--[[
	获得根窗口
	根窗口为静态变量
]]
function M:getRootWin()
	local tempRC = self:getRootControl()
	if(tempRC ~= nil)then
		return tempRC.m_view:getRootView()
	else
		return nil
	end
end

--[[
	得到根控制器（control）
]]
function M:getRootControl()
	return static_rootControl
end


--[[
	注册timer回调函数
]]
function M:setTimer(interval,onTimer)
	local tempTimer = { time = 0, inter = interval, callFunc = onTimer }
	local id = #self.m_timerList+1
	self.m_timerList[id] = tempTimer
	return id
end

--[[
	移出timer回调
]]
function M:removeTimer(id)
	if id then
		self.m_timer_remove[id] = true
	end
end

--- 创建一个只执行一次的回调函数
function M:setOnceTimer(time, onTimer)
	local id
	local func = function (...)
		self:removeTimer(id)
		if type(onTimer) == "function" then
			onTimer(...)
		end
	end
	id = self:setTimer(time, func)
	return id
end


--[[
	检查是否有指定子窗口
]]
function M:hasChild(name, alias)
	--如果是空的话则还没有常见view。所以肯定没有子窗口
	if static_rootControl == nil then
		return false
	end

	local tempChilren = static_rootControl.m_chilrenList[name]
	if(tempChilren ~= nil)then
		if(alias == nil)then
			return true
		else
			if(not isClassOrObject(tempChilren))then
				if(tempChilren[alias] ~= nil)then
					return true
				else
					return false
				end
			else
				if tempChilren.m_model and tempChilren.m_model.m_alias == alias then
					return true
				end
				return false
			end
		end
	elseif(static_ghostChildren~=nil and static_ghostChildren[name]~=nil)then
		return true
	end
	return false
end

--[[
	检查是否有有子窗口
]]
function M:checkHasChild()
	--如果是空的话则还没有常见view。所以肯定没有子窗口
	if static_rootControl == nil then
		return false
	end
	local chilrenList = static_rootControl.m_chilrenList or {}
	local ghostChildren = static_ghostChildren or {}
	return _G.next(chilrenList) ~= nil or _G.next(ghostChildren) ~= nil
end

-- 获取正常ui数量
function M:getChildCount()
	local count = 0
	for k,v in pairs(static_rootControl.m_chilrenList or {}) do
		if(not isClassOrObject(v))then
			for kc,vc in pairs(v) do
				count = count + 1
			end
		else
			count = count + 1
		end
	end
	return count
end
--[[
	隐藏界面计数++
]]
function M:retainVisibleView()
	--如果是空的话则还没有常见view。所以肯定没有子窗口
	if static_rootControl == nil then
		return
	end
	local size_type = self.m_view.m_size_type or 1
	local tempVT = self.m_view:getType()
	if size_type ~= 1 or tempVT == 1 then
		return
	end
	--Logger.log(self.m_model:getName(), "self.m_model:getName()-----retainVisibleView---->")
	local cur_sort_order = self.m_view.m_sortOrder
	for k,v in pairs(static_rootControl.m_chilrenList) do
		if(not isClassOrObject(v))then
			for kc,vc in pairs(v) do
				if vc.m_model:getName() ~= self.m_model:getName() then
					if vc.m_view:getType() == 2 and vc.m_view.m_normal and vc.m_view.m_sortOrder < cur_sort_order then
						vc.m_view:retainVisibleView()
					end
				end
			end
		else
			if v.m_model:getName() ~= self.m_model:getName() then
				if v.m_view:getType() == 2 and v.m_view.m_normal and v.m_view.m_sortOrder < cur_sort_order then
					v.m_view:retainVisibleView()
				end
			end
		end
	end
	static_rootControl.m_view:retainVisibleView()
end

--[[
	隐藏界面计数--
]]
function M:releaseVisibleView()
	--如果是空的话则还没有常见view。所以肯定没有子窗口
	if static_rootControl == nil or self.m_view == nil then
		return
	end
	local size_type = self.m_view.m_size_type or 1
	local tempVT = self.m_view:getType()
	if size_type ~= 1 or tempVT == 1 then
		return
	end
	--Logger.log(self.m_model:getName(), "self.m_model:getName()-----releaseVisibleView---->")
	local cur_sort_order = self.m_view.m_sortOrder
	for k,v in pairs(static_rootControl.m_chilrenList) do
		if(not isClassOrObject(v))then
			for kc,vc in pairs(v) do
				if vc.m_model:getName() ~= self.m_model:getName() then
					if vc.m_view:getType() == 2 and vc.m_view.m_normal and vc.m_view.m_sortOrder < cur_sort_order then
						vc.m_view:releaseVisibleView()
					end
				end
			end
		else
			if v.m_model:getName() ~= self.m_model:getName() then
				if v.m_view:getType() == 2 and v.m_view.m_normal and v.m_view.m_sortOrder < cur_sort_order then
					v.m_view:releaseVisibleView()
				end
			end
		end
	end
	static_rootControl.m_view:releaseVisibleView()
end

-- ================================= a cut of line =================================

-- 构造结束后调用

function M:onCreate()
	-- Logger.log("------------- control onCreate " .. self.m_model:getName())
end

-- 构造结束后调用
function M:onEnter()
	-- Logger.log("------------- control onEnter " .. self.m_model:getName())
end

-- 消息循环重载后使用
function M:onHandle(msg, data)
	
end

function M:onUpdate()
	
end

--[[
	释放内存
]]
function M:freeMemory()
	-- TODO :
end

function M:freeAllMemory()

end

function M:init_oo()
	local ui_root = U3DUtil:GameObject_Find("UIRoot")
	static_root_node = ui_root
	local camera_obj = U3DUtil:GameObject_Find("UIRoot/UICamera")
	if not IsNull(camera_obj) then
		static_ui_camera = UIUtil.findComponent(camera_obj.transform, typeof(U3DUtil:Get_Camera()))
	end
end


function M:enterMainPage()
	static_rootControl:openView("main")
end

--[[
	获取最大的ui层级
]]
function M:getMaxViewSortOrder()
	local sort_order  = 0
	if static_rootControl == nil or self.m_view == nil then
		return sort_order
	end
	for k,v in pairs(static_rootControl.m_chilrenList) do
		if(not isClassOrObject(v))then
			for kc,vc in pairs(v) do
				if vc.m_view.m_sortOrderChange then
					sort_order = math.max(sort_order, vc.m_view.m_sortOrder)
				end
			end
		else
			if v.m_view.m_sortOrderChange then
				sort_order = math.max(sort_order, v.m_view.m_sortOrder)
			end
		end
	end
	return sort_order
end

--[[
	是否能点击3d场景
]]
function M:can3DTouchByViewName(view_name)
	local can_touch  = true
	if static_rootControl == nil or self.m_view == nil then
		return can_touch
	end

	
	local isGuiding = UserDataManager.guide_data:isGuiding()
	if isGuiding then
		local guide_info = UserDataManager.guide_data:getCurGuideInfo()
		if guide_info and guide_info.key == "Formation" then
			if guide_info.action == 4 then
				return can_touch
			end
		end
	end

	local cur_sort_order = 999999999

	for i = #self.m_controls, 1, -1 do
		self.m_controls[i] = nil
	end
	
	for k,v in pairs(static_rootControl.m_chilrenList) do
		if(not isClassOrObject(v))then
			for kc,vc in pairs(v) do
				if vc.m_model:getName() ~= view_name then
					table.insert(self.m_controls,vc)
				else
					cur_sort_order = vc.m_view.m_sortOrder
				end
			end
		else
			if v.m_model:getName() ~= view_name then
				table.insert(self.m_controls,v)
			else
				cur_sort_order = v.m_view.m_sortOrder
			end
		end
	end
	for i, v in pairs(self.m_controls) do
		if v.m_view.m_sortOrder > cur_sort_order then
			can_touch = false
			break
		end
	end
	return can_touch
end

return M