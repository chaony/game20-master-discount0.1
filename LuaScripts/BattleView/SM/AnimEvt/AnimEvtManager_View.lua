--人物动画关键帧事件管理器
--类似是挂在动画上的关键帧的管理
--用于实现各种人物的技能
---@class AnimEvtManager_View @
local M = class("AnimEvtManager_View")

--美术配置数据
M.ms_data = nil
--策划配置数据
M.ch_data = nil
--程序配置数据
M.cx_data = nil
--动作数据
M.actions = nil
--我的事件所有者
M.player = nil

--根据动画名称， 加载帧表
function M:init( player )
	self.player = player;
	--通过 数据找视图
	self.modelToView = {}
	--监听 事件帧创建完成
	self.player:addEventListener_Local(Battle.EventType.MV_AnimEvtFrameModelCreateFinish,{self, self.AnimEvtFrameModelCreateFinish});
end

--事件帧 数据创建完成
function M:AnimEvtFrameModelCreateFinish(eventName, data) 
	local animEvtFrameModel = data;
	local animData = animEvtFrameModel:get_data();
	local animAction = animEvtFrameModel:get_action();
	local animEvtFrameView = require("BattleView.SM.AnimEvt.AnimEvtFrame_View").new()
	self.modelToView[animEvtFrameModel] = animEvtFrameView;
	SceneManager.MV_EventMgr:register( animEvtFrameView, animEvtFrameModel);
	animEvtFrameView:load( animData, self.player, animAction )
end


function M:destroy()
	self.modelToView = {}
end

return M