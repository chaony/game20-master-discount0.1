local M = class("WorldMemoryMainView",LikeOO.OOPopBase)

M.m_uiName = "WorldMapNew/WorldMapOldMemory/WorldMemoryMain"
M.m_iphoneXAdapter = true
M.m_size_type = 2
function M:onEnter()
	self:setTextByLanKey("close_title_text", "world_str_015")
	self.big_stage_img = self:findImage("stage_img")
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("share_node", false)
	self:createLoopScroll()
	self:refreshStageInfo()
end

function M:refreshStageInfo()
	local taskList = self.m_model:getTasksCfgListByGroup(self.m_model.m_sel_chapter)
	for i = 1, 9 do
		local obj = self:findGameObject("imgNode"..i)
		local luaBehaviour = UIUtil.findLuaBehaviour(obj)
		local task = taskList[i]
		local taskId = task.id
		local taskCfg = task.cfg
		local state = self.m_model:checkStageIsOpen(taskId)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_mask", state~=2)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Img_lock", state~=1)
		local tag_tips = luaBehaviour:FindText("tag_tips")
		local lock_tips = luaBehaviour:FindText("lock_tips")
		tag_tips.text = ""
		lock_tips.text = ""
		if state == 1 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_mask", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Img_lock", false)
			tag_tips.text = Language:getTextByKey("world_memory_str_001")
		elseif state == 0 then
			lock_tips.text = Language:getTextByKey("worldMap_str_004")
		end
		if i == self.m_model.m_sel_stage_index then
			self.select_stage_obj = obj
			self.m_model.m_sel_stage = taskId
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Img_sel", i == self.m_model.m_sel_stage_index)
		local btn_pic = luaBehaviour:FindGameObject("btn_pic")
		UIUtil.setButtonClick(
				btn_pic.transform,
				function()
					self:updateMsg("click_stage", {index = i, taskId = taskId, cfg = taskCfg, obj = obj})
				end)
	end
	
	local taskCfg = self.m_model:getChapterCfgById(self.m_model.m_sel_chapter)
	if taskCfg then
		local icon_name_big = tostring(taskCfg.pic) .. "_m"
		if self.big_stage_img then
			GameUtil:updateResourcesImg(self.big_stage_img, "Texture/worldMemory/"..icon_name_big)
		end
	end
end

function M:switchStageNode(cell_object, taskId)
	if not IsNull(cell_object) then
		if not IsNull(self.select_stage_obj) then
			local luaBehaviour = UIUtil.findLuaBehaviour(self.select_stage_obj)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Img_sel", false)
		end
		self.select_stage_obj = cell_object
		self.m_model.m_sel_stage = taskId
		local luaBehaviour = UIUtil.findLuaBehaviour(self.select_stage_obj)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Img_sel", true)
	end
end

--[[
    创建页签列表
]]
function M:createLoopScroll()
	self.select_cell_obj = nil
	self.select_cell_index = 0
	local groupList = self.m_model:getGroupIdList()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("tab_loopscroll")
		local params = {
			show_data = groupList,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:update_tag(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if self.m_model.m_sel_tab_index ~= index then
					self.m_model.m_sel_stage_index = 1
					self:updateMsg("switch_tab", { index =  index,cell_object =cell_object, cell_data = cell_data})
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(groupList, true, nil, true)
	end
end

function M:update_tag(index, obj, chapterId)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local tag_name = luaBehaviour:FindText("tag_name_text")
	local tag_tips = luaBehaviour:FindText("tag_tips")
	if index == self.m_model.m_sel_tab_index then
		self.select_cell_obj = obj
		self.select_cell_index = index
		self.m_model.m_sel_chapter = chapterId
	end
	local taskCfg = self.m_model:getChapterCfgById(chapterId)
	local state = self.m_model:checkChapterIsOpen(chapterId)
	tag_name.text = Language:getTextByKey(taskCfg.name_m)
	tag_tips.text = Language:getTextByKey("new_str_0563")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_bg", state == 0)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_tips", state == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", index == self.m_model.m_sel_tab_index)
	local bg_img = luaBehaviour:FindImage("tag_icon")
	local icon_name = tostring(taskCfg.pic) .. "_s"
	GameUtil:updateResourcesImg(bg_img, "Texture/worldMemory/"..icon_name)
end

function M:switchTabNode(index, cell_object, chapter_id)
	if not IsNull(cell_object) then
		if not IsNull(self.select_cell_obj) then
			local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
		end
		self.select_cell_obj = cell_object
		self.select_cell_index = index
		self.m_model.m_sel_chapter = chapter_id
		local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", true)
		local taskCfg = self.m_model:getChapterCfgById(chapter_id)
		if taskCfg then
			local icon_name_big = tostring(taskCfg.pic) .. "_m"
			if self.big_stage_img then
				GameUtil:updateResourcesImg(self.big_stage_img, "Texture/worldMemory/"..icon_name_big)
			end
		end
	end
end


function M:destroy()
	M.super.destroy(self)
end

return M