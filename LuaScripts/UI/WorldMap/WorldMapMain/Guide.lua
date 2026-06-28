local guide = class("WorldMapMain", LikeOO.OOGuideBase)

-- open特定剧情界面
function guide:excuteGuideFunc1(info)
	local target = info.target
    --LikeOO.Map2DControl:openMap2D(101)
    
    self.m_model:getNetData("big_map_enter_scene", {map_id = target[1], map_pos = { 0,0 }}, function(response)
        UserDataManager:setArticlesData(response["articles"])
    end,nil,true,GlobalConfig.POST)
    LikeOO.Map2DControl:openMap2D(target[2], function()
        if info.key == "WorldMapMain" and info.action == 1 then
            self:doNextGuide()
        end
    end)
end

-- 点击npc头像
function guide:excuteGuideFunc2(info)
    local id = info.target[1]
    if LikeOO.Map2DControl.curMap2D == nil or LikeOO.Map2DControl.curMap2D.m_cur_node == nil or LikeOO.Map2DControl.curMap2D.m_cur_node.m_npc_loop_scroll_view == nil then
        return
    end
    local list_data = LikeOO.Map2DControl.curMap2D.m_cur_node.m_npc_loop_scroll_view.m_show_data
    local index = nil
    for i,v in ipairs(list_data or {}) do
        if id == v then
            index = i
        end
    end
    if index then
        local cell = LikeOO.Map2DControl.curMap2D.m_cur_node.m_npc_loop_scroll_view.m_cache_cells[index]
        if cell then
            local luaBehaviour = cell:GetComponent("LuaBehaviour")
            local node = luaBehaviour:FindGameObject("npc_bg")
            if node then
                self.m_listener = {
                    key = "guide_1",
                }
                self:guideTargetNode(node.transform, 1, 1)
            end
        end
    end
    
end

-- 点击小场景返回
function guide:excuteGuideFunc3(info)
    local node = LikeOO.Map2DControl.curMap2D.m_cur_node:findGameObject("close_btn")
    if node then
        self.m_listener = {
            key = "guide_close_mapNode",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击任务
function guide:excuteGuideFunc4(info)
    local id = info.target[1]
    local list_data = self.m_view.m_loop_scroll_view.m_show_data
    local index = nil
    for i, v in ipairs(list_data) do
        if v == id then
            index = i
        end
    end
    if index then
        local cell = self.m_view.m_loop_scroll_view.m_cache_cells[index]
        if cell then
            LikeOO.Map2DControl:back()
            if LikeOO.Map2DControl.curMap2D then
                LikeOO.Map2DControl.curMap2D:destroy()
                LikeOO.Map2DControl.curMap2D = nil;
            end
            
            local luaBehaviour = cell:GetComponent("LuaBehaviour")
            local node = luaBehaviour:FindGameObject("task_cell_btn")
            if node then
                self.m_listener = {
                    key = "task_cell_btn",
                }
                self:guideTargetNode(node.transform, 1, 1)
            end
        end
    end
end

-- 点击江湖上的按钮
function guide:excuteGuideFunc5(info)
    local target = info.target[1]
    local areaBars
    if SceneManager:getCurSceneModel().areaBarsImg ~= nil then
        areaBars = SceneManager:getCurSceneModel().areaBarsImg[target]
    end
    if areaBars then
        local luaBehaviour = areaBars:GetComponent("LuaBehaviour")
        local node = luaBehaviour:FindGameObject("brand_btn")
        if node then
            self.m_listener = {
                key = "brand_btn",
            }
            local worldPos = node.transform.position
            local position = SceneManager:getCurSceneModel().ui_camera:WorldToScreenPoint(worldPos);
            -- position.z = 0
            position = static_ui_camera:ScreenToWorldPoint(position)
            self:guideTargetNode(node.transform, 1, 1, nil, nil, nil, nil, position)
            --self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

-- 点击场景中的物品
function guide:excuteGuideFunc6(info)
    local target = info.target[1]
    local node = LikeOO.Map2DControl.curMap2D.content["article_" .. target]
    if node and node.activeSelf then
        self.m_listener = {
            key = "item_click",
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

-- 点击右上小地图
function guide:excuteGuideFunc7(info)
    if LikeOO.Map2DControl.curMap2D then
        local node = LikeOO.Map2DControl.curMap2D.m_cur_node:findGameObject("path_btn")
        if node then
            self.m_listener = {
                key = "path_btn",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
end

-- 点击返回挂机界面按钮
function guide:excuteGuideFunc99(info)
    local node = LikeOO.Map2DControl.curMap2D.m_cur_node:findGameObject("back_hangup_btn")
    if node then
        self.m_listener = {
            key = "guide_close_mapNode",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
