local M = class("UnionWarDispatchView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarDispatch"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "union_str_0062")
    self:setTextByLanKey("sel_combat_num_title_text", "new_str_0490")
    self.m_gray_image = self:findImage("gray_image")
    self:refreshUI()
end

function M:refreshUI()
    self:updateFormationLoopScroll()
end

--[[
	创建列表
]]
function M:updateFormationLoopScroll()
    local data = self.m_model:getShowTeams()
    self:setObjectVisible("CommonTipsNode", false)
    if self.m_formation_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("formation_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if not self.m_model:teamIsLock() then
                    self:updateMsg(click_name, {index = index , cell_data = cell_data})
                end
            end
        }
        self.m_formation_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_formation_loop_scroll_view:reloadData(data, true)
    end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_state_text", false )
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "new_str_0555")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "dispatch_edit_btn_text", "new_str_0289")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_state_text", "UnionWar_str_079")
    local teamIsLock = self.m_model:teamIsLock()
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "dispatch_btn", not teamIsLock)
    local no_hero = GameUtil:teamNoHero(cell_data.team)
    local name_str = nil
    if no_hero then
        name_str = Language:getTextByKey("new_str_0551") .. tostring(index)
    else
        if cell_data.name then
            name_str = cell_data.name
        else
            name_str = Language:getTextByKey("new_str_0551") .. tostring(index)
        end
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", tostring(name_str))
    local team_node = luaBehaviour:FindGameObject("team_node")
    local team_heros_data, combat = self.m_model:getHerosDataByTeam(cell_data.team)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_title_text", "new_str_0490")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", GameUtil:formatValueToString(combat))
    for i = 1, 5 do
        local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
        local item_data = team_heros_data[i]
        if item_data and _G.next(item_data) then
            GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false)
        else
            GameUtil:updateItemElementNoData(hero_node)
            if teamIsLock then
                local hero_luaBehaviour = UIUtil.findLuaBehaviour(hero_node)
                LuaBehaviourUtil.setObjectVisible(hero_luaBehaviour, "add_img", false)
            end
        end
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_rename_btn_text", "upper_num_str_000"..index)
    local user_flag, star = self.m_model:teamIsUseById(index)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_state_text", teamIsLock and user_flag)
    for i = 1, 3 do
        local star_img = luaBehaviour:FindImage('star_img_' .. i)
        if i > star then
            star_img.material = self.m_gray_image.material
        else
            star_img.material = nil
        end
        star_img.gameObject:SetActive(teamIsLock and user_flag)
    end
    
end

return M