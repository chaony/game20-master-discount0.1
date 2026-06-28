--- 主线
local M = class("TaskRewardMainNode", LikeOO.OOUIbase)

M.m_uiName = "WorldMapNew/WorldMapTaskReward/TaskRewardMainNode"
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_task_node = self:findGameObject("task_node")
    self:refreshUI()
end

function M:refreshUI()
    UIUtil.destroyAllChild(self.m_task_node.transform)
    self.item = nil
    self.itemsOpen = false
    local data = self.m_model:getCurMainTask()
	local item = self:creatItem()
	self.item = item
	self:updateItem(item, data)
end

function M:creatItem()
    local item = ResourceUtil:LoadUIGameObject("WorldMapNew/WorldMapTaskReward/WorldMapTaskRewardCell", Vector3.zero, nil)
    item.transform:SetParent(self.m_task_node.transform, false)
    return item
end

function M:updateItem(obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
	if LuaBehaviour then
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_text", data.task_title)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_img", self.m_model:checkMainCom())
        local task_img = self.m_model:getImgByTasks_types(data.map_id)
        local cell_bg = LuaBehaviour:FindImage("cell_bg")
        GameUtil:updateResourcesImg(cell_bg, "Texture/world_map/" .. tostring(task_img))
        self:clickCell(obj, data)
        LuaBehaviour:RegistButtonClick(function (obj, name)
            self:clickCell(obj, data)
        end)
    end
end

function M:clickCell(obj, data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local branch_obj = LuaBehaviour:FindGameObject("branch_obj")
        if self.itemsOpen == false then
			self.itemsOpen = true
            for i = 1, table.nums(data.task_id) do
                local cell_b = self:creatItem2(branch_obj)
                self:updateItems(cell_b, i, data.task_id[i])
            end
        else
            UIUtil.destroyAllChild(branch_obj.transform)
            self.itemsOpen = false
		end
	end
	local contentImmediate = obj:GetComponent("ContentImmediate")
	if contentImmediate then
		contentImmediate:ForceRefreshSize()
	end
end

function M:creatItem2(parent)
    local item = ResourceUtil:LoadUIGameObject("WorldMapNew/WorldMapTaskReward/WorldMapTaskRewardCell2", Vector3.zero, nil)
    item.transform:SetParent(parent.transform, false)
    return item
end

function M:updateItems(obj, index, celldata)
    local data, cfg = self.m_model:getMainTaskData(celldata)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
	if LuaBehaviour then
		local aa = index%2
        if aa == 0 then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "left_img", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "right_img", false)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "left_img", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "right_img", true)
        end
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "title_name", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "title_name2", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "title_name3", false)
        local str = Language:getTextByKey(cfg.event_mission)
        str = string.gsub(str, "【", "︻")
        str = string.gsub(str, "】", "︼")
        if string.len(str) > 39 then
            local str_1 = string.sub(str, 1, 39)
            local str_2 = string.sub(str, 40, string.len(str))
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_name2", str_1)
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_name3", str_2)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "title_name2", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "title_name3", true)
        else
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_name", str)    
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "title_name", true)
        end
	
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigou", data == true)
    end
end

return M
