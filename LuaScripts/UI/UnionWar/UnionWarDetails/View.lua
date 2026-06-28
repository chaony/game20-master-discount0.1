local M = class("UnionWarDetailsView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarDetails"
M.m_size_type = 2


function M:onEnter()
    local guild_war_map_cfg = ConfigManager:getCfgByName("guild_war_map")    
    self:setTextByLanKey("common_title_text", guild_war_map_cfg[self.m_model.m_index].name)
    --self:setTextByLanKey("team_num_des", "UnionWar_str_040", self.m_model.m_data.team_num)
    local guild_war_map_cfg =  ConfigManager:getCfgByName("guild_war_map")
    local buildingIndex = guild_war_map_cfg[self.m_model.m_index].building or nil
    if buildingIndex ~= nil then
        local guild_war_building_cfg = ConfigManager:getCfgByName("guild_war_building")
        local content = guild_war_building_cfg[buildingIndex].text
        self:setTextByLanKey("building_text", "UnionWar_str_003", content)
    end
    if  self.m_model.m_owner == "" then 
        self:setTextByLanKey("owner_text_des", "UnionWar_str_039")   
    else
        self:setTextByLanKey("owner_text_des", "UnionWar_str_003", self.m_model.m_owner)
    end
    
    self:refreshUI()
end

function M:refreshUI()
    self:updateLoopScroll()
end

function M:destroy()
    M.super.destroy(self)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getShowData()
    --local data = self.m_testData
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , team_id = cell_data.team_id, cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end

    self:setObjectVisible("CommonTipsNode", not (data.team_num > 0))
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0265", index)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recall_btn", false)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "recall_btn_text", "UnionWar_str_021")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_player_name_text", "UnionWar_str_003", data.user.name )
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_combat_text ", "UnionWar_str_022", data.total_combat)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recall_btn", data.showRecall)
    
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    GameUtil:setUserAvatar(HeadNode, data.user,nil,nil,{show_flag = true, scale = 1})
    
    local team_node = luaBehaviour:FindGameObject("team_node")
    local team_node_rt = UIUtil.findRectTransform(team_node)
    local show_heros = cell_data.team_heros_data
    local function lookHero(click_object, click_name, idx, cell_data)
        self:updateMsg("look_hero", {oid = cell_data.card_id, data = self.m_model.m_data})
    end
    self:createHeros(team_node_rt, show_heros, false, false, lookHero)
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_text", tostring(total_combat))
end

function M:createHeros(team_node, rewards, is_show_num, is_show_detail, callback)
    local rewards = rewards or {}
    for i = 1, 5 do
        local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
        local item_data = rewards[i]
        if item_data and _G.next(item_data) then
            GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false,function ()
                self:updateMsg("goDownBattle", { heroid = item_data.hero_data.oid})
                --self.m_model.m_multi_formation_changed_flag = true
            end)
            local hero_luaBehaviour = UIUtil.findLuaBehaviour(hero_node)
            if hero_luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(hero_luaBehaviour, "lock_image", false)
            end
        else
            GameUtil:updateItemElementNoData(hero_node)
        end
    end
end


return M