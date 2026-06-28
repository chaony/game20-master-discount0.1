--场景事件
---@class SceneEvent @
local M = class("SceneEvent")

M.eventMgr = nil

M.id = nil

M.chapter = nil

M.type = nil

M.param = nil 

M.start_event = nil

M.destroy_event = nil

M.priority = nil

M.story = nil

M.replay = nil

M.showList = nil

M.hideList = nil

M.waitCount = 0

--事件是否完成
M.isFinish = nil

--初始化事件
function M:init(id, data, mgr, grid_data)
	self.eventMgr = mgr
	self.id = id
	self.grid_data = grid_data;
	self.chapter = data["chapter"]
	self.type = data["type"]
	self.param = data["num"] or 0
	self.start_event = data["start_event"] or 0
	self.destroy_event = data["destroy_event"] or 0
	self.priority = data["priority"] or 0
	self.story = data["event"] or 0
	self.replay = data["replay"] == 1
	self.ending_event = data["ending_event"]
	self.ending_event_flag = data["ending_event"] ~= 0
	self.choise = data["choise"] or {}
	self.choise_id = data["choise_id"] or {}
	--触发事件出现物体 的 ids
	self.display_object = data["display_object"] or {}
	--触发事件销毁物体
	self.destroy_object = data["destroy_object"] or {}
	self.heirloom_reward = data["heirloom_reward"] or {}
	self.isFinish = false
	self.waitCount = 0

	--物体表
    self.object_data = ConfigManager:getCfgByName("roleplaying_object")
end

-- 9 敌人
-- 10 遗物
-- 11 兵营
-- 12 泉水
-- 13 复活
-- 14 宝箱
--事件触发
function M:start( eventOver )
	Logger.log("事件开始：".. self.id)
	self.eventOverHandler = eventOver
	if self.grid_data ~= nil then
		self.grid_data.open_flag = true;
		self.grid_data.callback = 
		function()
			if self.eventOverHandler ~= nil then
				self.eventOverHandler()
			end
		end
	end
	
	if self.type == 9 then
		--打开战斗界面
		static_rootControl:updateMsg("open_detail",self.grid_data,"Shiguang")
	elseif self.type == 10 then
		--打开遗物口
		static_rootControl:updateMsg("open_yiwu",self.grid_data,"Shiguang")
	elseif self.type == 11 then
		--打开兵营
		static_rootControl:updateMsg("open_yongbing",self.grid_data,"Shiguang")
	elseif self.type == 12 then
		self.grid_data.type = 12;
		--打开泉水
		static_rootControl:updateMsg("open_quanshui",self.grid_data,"Shiguang")
	elseif self.type == 13 then
		self.grid_data.type = 13;
		--打开复活
		static_rootControl:updateMsg("open_fuhuo",self.grid_data,"Shiguang")
	elseif self.type == 14 then
		--打开宝箱
		static_rootControl:updateMsg("rpgClickObj",self.grid_data,"Shiguang")
	else
		--TODO 剧情触发
		if self.story ~= 0 then
			local data = {}
			data.talk_id = self.story
			data.choise = self.choise
			data.choise_id = self.choise_id
			data.heirloom_reward = self.heirloom_reward
			data.callback = 
			function( event_data )
				if event_data ~= nil then
					SceneManager.eventMgr:addEvent(event_data.id, self.grid_data);
					local data = {}
					data.chapter_id = SceneManager.curScene.map_id;
					data.event_id = self.id
					data.option_id = event_data.index;
					static_rootControl:updateMsg("rpg_chioce_option",data,"Shiguang")
				end
				EventDispatcher:dipatchEvent("eventToView", {param = "storyEnd"})
				self:storyEnd()
			end
			static_rootControl:updateMsg("talk", data, "Shiguang")
		else
			self:storyEnd()
		end
	end

	--事件触发要销毁的物体
	-- self:check_objects(false);
	--事件触发要显示的物体
	-- self:check_objects(true);

end


function M:check_objects( display )
	local data = self.display_object;
	if display == false then
		data = self.destroy_object;
	end

	--事件触发要销毁的物体
	if next( data ) ~= nil then
		--获取本地缓存数据
		for i,v in pairs( data ) do
			local obj_data = SceneManager.curScene.shiguangmap.object_data[SceneManager.curScene.map_id][v];
			if obj_data ~= nil then
				local pos_x = obj_data.position[1];
				local pos_y = obj_data.position[2];
				local grid = SceneManager.curScene.shiguangmap.aStar.sceneData.data[pos_x][pos_y]
				if grid ~= nil then
					if display then 
						if grid.obj_model ~= nil then
							grid.obj_model:SetActive(false);
							grid:setValue(0)
						end
						local oid = v;
						if grid.data == nil then
							grid.data = obj_data
							grid.data.chapter_id = SceneManager.curScene.map_id
							grid.data.block_id = SceneManager.curScene.shiguangmap:infoToID(pos_x,pos_y,SceneManager.curScene.map_id);
						end
						grid.data.model_name = obj_data.model_name;
						grid.data.type = obj_data.type;
						grid.data.event_id = obj_data.event_id;
						local obj = SceneManager.curScene:instanceGameObject(obj_data.model_name, SceneManager.curScene.obj)
						obj.transform.position = grid.worldPosition;
						obj.transform.localScale = Vector3(1,1,1)
						grid.obj_model = obj;
						grid:setValue(1)
					else
						if grid.obj_model ~= nil then
							grid.obj_model:SetActive(false)
						end
						grid:setValue(0)
					end	
				end
			end
		end
	end
end


--剧情结束
function M:storyEnd()
	--TODO 通知物体事件触发成功
	if self.waitCount <= 0 then
		self:finish()
	end
end

function M:tryFinish()
	self.waitCount = self.waitCount - 1
	if self.waitCount <= 0 then
		self:finish()
	end
end

--事件完成
function M:finish()
	Logger.log("事件结束：".. self.id)

	--发送退出当前副本
	if self.ending_event_flag == true then
		SceneManager.eventMgr:clear();
		SceneManager:clear("shiguang_block_net_data");
		EventDispatcher:dipatchEvent("eventToView", {param = "over", ending_event = self.ending_event})
	end

	if self.eventOverHandler ~= nil then
		self.eventOverHandler()
	end

	if SceneManager.curScene.shiguangmap ~= nil then
		SceneManager.curScene.shiguangmap:RefreshGridData();
	end

	if self.destroy_event ~= 0 then
		
	end
end

--关闭事件
function M:close()
	self.isFinish = true
end

return M