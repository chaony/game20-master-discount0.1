--剧情关角色或者物件
---@class PlayerStory @
local M = class("PlayerStory")


function M:init(id, data, parent, base, finish, callBack)
	self.m_callBack = callBack;
	self.base = base;
	self.parent = parent;
	--当前物件的id
	self.id = id;
	--归属剧情关
	self.scenario = data.scenario
	--序号
	self.order = data.order;
	--模型资源
	self.model = data.model;
	--是否完成当前任务
	self.isFinish = finish or false;
	--绝对位置
	self.start_position = Vector3( data.position[1], 0, data.position[2] );
	--附带效果
	--类型=1=随身特效
	--类型=2=气球对话
	--类型=3=图片表情
	self.effect = data.effect;
	if next(self.effect) ~= nil then
		self.effectType = self.effect[1]
		self.effectParam = self.effect[2]
	else
		self.effectType = 0
		self.effectParam = "";
	end
	--出现条件
	--类型=1 完成若干节点出现
	--类型=2 
	self.appear = data.appear;
	if next(self.appear) ~= nil then
		self.appearType = self.appear[1]
		self.appearCondition = {}
		local index = 0
		for k,v in ipairs(self.appear) do
			if index > 0 then
				self.appearCondition[k-1] = v;
			end
			index = index + 1;
		end
	else
		self.appearType = 0;
		self.appearCondition = {}
	end
	--消失条件
	--空=不消失
	--1=自己完成互动后自动消失
	self.disappear = data.disappear or 0;
	--互动方式
	self.interact = data.interact;
	--互动形式【1=战斗，2=对话，3=对话+战斗】
	if next(self.interact) ~= nil then
		self.interactMode = self.interact[1]
		self.interactData = {}
		if self.interactMode == 1 then
			--战斗id
			self.interactData.battleId = self.interact[2]
		elseif self.interactMode == 2 then
			--对话id
			self.interactData.dialogId = self.interact[2]
		else
			--同时又战斗id和对话id
			self.interactData.battleId = self.interact[3]
			self.interactData.dialogId = self.interact[2]
		end
	else
		self.interactMode = 0;
		self.interactData = {}
		--同时又战斗id和对话id
		self.interactData.battleId = 0
		self.interactData.dialogId = 0
	end

	self:LoadModel()
end

--根据条件更新显示
function M:UpdateAppearCondition( finishOrders )
	if next(self.appear) ~= nil then
		--有条件的先隐藏掉
		if self:CheckAppearCondition( finishOrders ) then
			if self.isFinish == false then
				self.obj:SetActive(true);
			end
		end
	else
		if self.isFinish == false then
			self.obj:SetActive(true);
		end
	end
end

--检测显示条件是否满足
function M:CheckAppearCondition( finishOrders )
	if next(self.appear) ~= nil then
		--有条件的先隐藏掉
		local ok_index = #self.appearCondition;
		for k,v in ipairs(self.appearCondition) do
			local order = v;
			if finishOrders[order] ~= nil then
				ok_index = ok_index - 1;
			end
		end
		if ok_index <= 0 then
			return true;
		end
		return false;
	end
	return true;
end

--加载模型
function M:LoadModel()
	self.clickHelper = ResourceUtil:LoadCommon("clickHelper", self.parent)
	self.clickHelper.transform.localPosition = self.start_position;
	self.clickHelper.name = "clickHelper_"..self.order;
	
	if string.find(self.model,"Role3d") then
		local role_path = string.split(self.model,"/")
		local role_load = role_path[2].."/"..role_path[3]
		ResourceUtil:LoadRole3dAsync(role_load, self.clickHelper, function(obj)
			self:LoadFinishObj(obj);
		end)
	else
		local obj = ResourceUtil:LoadCommonAsync(self.model, self.clickHelper,function(obj)
			self:LoadFinishObj(obj);
		end)
	end
end

--加载完成
function M:LoadFinishObj( obj )
	self.obj = obj;
	obj.transform.localPosition = Vector3(0,0,0);
	local helper = obj:GetComponent("PlayerLuaViewHelper");
	if helper ~= nil then
		if helper.m_anim ~= nil then
			helper.m_anim.enabled = true;
		end
		helper.enabled = false;
	end
	self.obj:SetActive(false);
	if self.m_callBack ~= nil then
		self.m_callBack()
	end
end

--开始逻辑运行
function M:running()
	--有互动方式
	if self.interactMode > 0 then
		if self.interactMode == 1 then
			--战斗
			self:enterBattle(self.interactData.battleId)
		elseif self.interactMode == 2 then
			--对话
			local data = {}
			data.talk_id = self.interactData.dialogId
			data.node_id = self.id
			data.callback = function( event_data )
				--对话结束
				self.isFinish = true;
				GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("聊天结束"), delay_close = 2})
				self.base:UpdateAppearCondition();
				self:disappearHandler();
			end
			static_rootControl:updateMsg("talk", data, "Formation")
		elseif self.interactMode == 3 then 
			--对话+战斗
			local data = {}
			data.talk_id = self.interactData.dialogId
			data.node_id = self.id
			data.callback = function( event_data )
				--对话结束
				self:enterBattle(self.interactData.battleId)
			end
			static_rootControl:updateMsg("talkBattle", data, "Formation")
		end
	end
end


function M:disappearHandler()
	if self.disappear == 1 then
		if self.obj ~= nil then
			self.obj:SetActive(false);	
		end
	end
end


function M:enterBattle( battleId )
	self.isFinish = true;
	GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("战斗结束"), delay_close = 2})
	self.base:UpdateAppearCondition();
	self:disappearHandler();
end


function M:update(dt)
	
end

function M:destroy()
	
end

return M