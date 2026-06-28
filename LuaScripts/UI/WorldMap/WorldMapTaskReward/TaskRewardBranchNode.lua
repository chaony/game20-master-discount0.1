--- 支线
local M = class("TaskRewardBranchNode", LikeOO.OOUIbase)

M.m_uiName = "WorldMap/WorldMapTaskReward/TaskRewardBranchNode"
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_task_node = self:findGameObject("task_node")
    self.panel = self:findGameObject("panel")
    self.task_team_tab = ConfigManager:getCfgByName("regional_task_team")
    self.map_tab = ConfigManager:getCfgByName("regional_map")
    self:refreshUI()
end

function M:refreshUI()
   --UIUtil.destroyAllChild(self.m_control.m_view.panel.transform)
    self.items = {}
    self.itemsOpen = {}
    local data = self.m_model:getCurBanchTask()
    for k = 1 , #data do
        local item = self:creatItem()
        self.items[k] = item
        self.itemsOpen[k] = {open = false, obj = nil}
        self:updateItem(item, k)
    end
end

function M:creatItem()
    local item = ResourceUtil:LoadUIGameObject("WorldMap/WorldMapTaskReward/WorldMapTaskRewardCell", Vector3.zero, nil)
    item.transform:SetParent(self.m_task_node.transform, false)
    return item
end

function M:updateItem(obj, k)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local data = self.m_model:getBanchByIndex(k)
        local cell_bg = LuaBehaviour:FindImage("cell_bg")
        --local task_img = self.m_model:getImgByTasks_types(data.id)
        --GameUtil:updateResourcesImg(cell_bg, "Texture/world_map/" .. tostring(task_img))
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_text", self.task_team_tab[data.id].task_title)
        self:clickCell(obj, k)
        LuaBehaviour:RegistButtonClick(function (obj, name)
            self:clickCell(obj, k)
        end)
    end
end

function M:clickCell(obj, k)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local branch_obj = LuaBehaviour:FindGameObject("branch_obj")
        local data = self.m_model:getBanchByIndex(k)
        if self.itemsOpen[k].open == false then
            self.itemsOpen[k].open = true
            if self.itemsOpen[k].obj == nil then
                local done = table.copy(data.data.done) or {}
                table.insert(done, tonumber(data.task_id))
                local task_team = self.task_team_tab[data.id]
                local map = self.map_tab[task_team.map_id]
                local cell_b = self:creatItem2(branch_obj.transform, done, map.map_resource)
                self.itemsOpen[k].obj = cell_b
            else
                self.itemsOpen[k].obj:SetActive(true)
            end
        else
            self.itemsOpen[k].obj:SetActive(false)
            self.itemsOpen[k].open = false
        end
        local contentImmediate = obj:GetComponent("ContentImmediate")
        if contentImmediate then
            contentImmediate:ForceRefreshSize()
        end
    end
end

function M:creatItem2(parent, data, map_bg)
    local item = ResourceUtil:LoadUIGameObject("WorldMap/WorldMapTaskReward/WorldMapTaskRewardCell2", Vector3.zero, nil)
    item.transform:SetParent(parent, false)
    local luaBehaviour = item:GetComponent("LuaBehaviour");
    local bg_img = luaBehaviour:FindGameObject("bg_img")
    GameUtil:updateResourcesImg(bg_img, "Texture/map_bg/"..map_bg)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cpd_text", "1".."/".."1")
    if self.m_loop_scroll_view == nil then
        local loopscroll = luaBehaviour:FindGameObject("list_Scroll_View")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateItems(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --self:updateMsg("select_map", {id = cell_data.mapId})
            end,
            ui_name = self.m_uiName,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
    
    return item
end

function M:updateItems(index, obj,  celldata)
    local data, cfg = self.m_model:getBranchTask(celldata)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local str = Language:getTextByKey(cfg.event_mission)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_name", str)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigou", data == true)
    end
end

return M
