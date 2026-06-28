---@class TXRankListPopView:OOPopBase
---@field m_model TXRankListPopModel
local M = class("TXRankListPopView",LikeOO.OOPopBase)

M.m_uiName = "TianXiaZhengBa/TXRankListPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true
local __rank_title_key = {"new_str_0374", "new_str_0403", "new_str_0375"}
    
function M:onEnter()
    self.m_scroll_tab = {}
    for i = 1, 3 do
        self:setTextByLanKey("rank_title_text" .. i, __rank_title_key[i])
    end
    self.m_show_spine_id = 506
    self:refreshUI()
   
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI(is_change_sort)
    self:setTextByLanKey("close_title_text", "total_world_rank_" .. self.m_model.m_cur_rank_sort)
    local listName = (self.m_model.m_cur_rank_sort == 1) and "new_str_0019" or "new_str_0370"
    self:setTextByLanKey("rank_title_text2", listName)
    self:setObjectVisible("left_btn", self.m_model:getNextSort(-1))
    self:setObjectVisible("right_btn", self.m_model:getNextSort(1))
    local isShowRank = self.m_model.m_isShowRank
    local titleName = "total_world_rank_title_" .. self.m_model.m_cur_rank_sort
    if (self.m_model.m_cur_rank_sort == 1) then
        titleName = isShowRank and "total_world_rank_text_03" or titleName
    end
    self:setTextByLanKey("rank_title_text3",titleName)
    self:setSpine()
    self:refreshSelfNode()
    self:refreshTop3Node()
    self:updateLoopScroll()
    if is_change_sort and self.m_loop_scroll_view then
        self.m_loop_scroll_view:moveToCellIndex(1)
    end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getCurOtherRankData()
    self:setObjectVisible("common_tips_node", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            pull_refresh = function() -- 下拉刷新
                self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
                self:updateMsg("load_rank")
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("item_click", {id = index, cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
        if self.m_control.m_mail_load == true then
            self:pullRefreshListOffset()
        end
    end
end

function M:pullRefreshListOffset()
    self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    --local position = self.m_list_scroll:getVerticalNormalizedPosition()
    local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_control.m_mail_load = false
end

function M:refreshTop3Node()
    local top3_rank_data = self.m_model:getCurTop3RankData()
    for i = 1, 3 do
        --local player_name_text = self:findGameObject("player_name_text" .. i)
        --local server_name_text = self:findGameObject("server_name_text" .. i)
        --local star_num_text = self:findGameObject("star_num_text" .. i)
        --local like_num_text = self:findGameObject("like_num_text" .. i)
        --local head_node = self:findGameObject("HeadNode" .. i)
        local rank_data = top3_rank_data[i] and top3_rank_data[i] or nil
        self:setObjectVisible("player_name_text" .. i, rank_data and true or false)
        self:setObjectVisible("server_name_text" .. i, rank_data and true or false)
        self:setObjectVisible("star_num_text" .. i, rank_data and true or false)
        self:setObjectVisible("like_num_text" .. i, rank_data and rank_data.like and true or false)
        self:setObjectVisible("rank_img" .. i, rank_data and true or false)
        self:setObjectVisible("star_img" .. i, (rank_data ~= nil) and (not self.m_model.m_isShowRank))
        self:setObjectVisible("like_bg_img" .. i, (rank_data and rank_data.like) and true or false)
        self:setObjectVisible("star_bg_img" .. i, rank_data and true or false)
        self:setObjectVisible("like_img" .. i, (rank_data and rank_data.like) and true or false)
        self:setObjectVisible("icon_image" .. i, false)
        local head_node = self:setObjectVisible("HeadNode" .. i,  false)
        self:setObjectVisible("no_people_text" .. i, true)
       
        if rank_data then
            self:setObjectVisible("no_people_text" .. i, false)
            local server_name = UserDataManager.server_data:getServerNameById(rank_data.user.server)
            self:setText("player_name_text" .. i, rank_data.user.name)
            self:setText("server_name_text" .. i, server_name)
            self:setText("star_num_text" .. i, GameUtil:formatValueToString(rank_data.score) )
            self:setText("like_num_text" .. i, rank_data.like and GameUtil:formatValueToString(rank_data.like) or "0")

            if self.m_model.m_cur_rank_sort == 1 then
                local flag_cfg = ConfigManager:getCfgByName("guild_flag")[rank_data.user.flag]
                if flag_cfg then
                    local union_icon_img = self:findImage("icon_image" .. i)
                    GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
                end
                self:setObjectVisible("icon_image" .. i,  true)
                self:setObjectVisible("HeadNode" .. i,  false)
            else
                self:setObjectVisible("HeadNode" .. i,  true)
            end
            GameUtil:setUserAvatar(head_node, rank_data.user, false,nil,{show_flag = true, scale = 1})
        end
    end
end

function M:refreshSelfNode()
    local self_node = self:findGameObject("self_node")
    local self_rank_data = self.m_model:getCurMyRankData()
    local user = UserDataManager.user_data.user_status
    if (user.guild_id ~= 0 and self.m_model.m_cur_rank_sort == 1) or self.m_model.m_cur_rank_sort ~= 1 then
        self:setObjectVisible("self_node",  true)
        self:updateScrollViewCell(0, self_node, self_rank_data)
    else
        self:setObjectVisible("self_node",  false)
    end
   
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local user = data.user or {}
    if index == 0 then
        user = UserDataManager.user_data.user_status
        user.name = UserDataManager.user_data:getUserStatusDataByKey("name")
    end
    local rank = data.rank or 0
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
   
    if rank < 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
    end
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", GameUtil:formatValueToString(user.full_combat))
    local score = data.score or 0
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_score_text", GameUtil:formatValueToString(score))
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_text", "" )
    local name_text = nil
    local server_name_text = nil
    if user.name == nil or user.name == "" then
        name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
    else
        local server_name = UserDataManager.server_data:getServerName()
        if index ~= 0 then
            server_name = UserDataManager.server_data:getServerNameById(data.user.server) or ""
        end 
        if server_name ~= "" then
            server_name = "[" .. server_name .. "]"
        end
        server_name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_text", server_name )
        local isSelfTeam = (self.m_model.m_cur_rank_sort == 1) and (index == 0)
        local teamName = isSelfTeam and tostring(user.guild_name) or tostring(user.name)
        name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", teamName)
    end
  
    local head_node = luaBehaviour:FindGameObject("head_node")
    if self.m_model.m_cur_rank_sort == 1 then
        local flag_id = user.flag
        if index == 0 then
            flag_id = self.m_model.m_data.flag
        end
        local flag_cfg = ConfigManager:getCfgByName("guild_flag")[flag_id]
        if flag_cfg then
            local union_icon_img = luaBehaviour:FindImage("icon_image")
            GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_image", true)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", false)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_image", false)
        GameUtil:setUserAvatar(head_node, user, false,nil,{show_flag = true, scale = 1})
        local title_id = user.title
        if title_id and title_id ~= 0 then
            name_text.transform.anchoredPosition = Vector3.New(42, 4, 0)
            if server_name_text then
                server_name_text.transform.anchoredPosition = Vector3.New(42, -23, 0)
            end
        else
            name_text.transform.anchoredPosition = Vector3.New(42, 14, 0)
            if server_name_text then
                server_name_text.transform.anchoredPosition = Vector3.New(42, -13, 0)
            end
        end
    end

    local isShowRank = self.m_model.m_isShowRank
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img", isShowRank == false)
end

function M:setSpine()
    local hk_obj = self:findGameObject("hero_sk")
    local c_id = 506
    if next(self.m_model:getCurTop3RankData()) and self.m_model.m_cur_rank_sort ~= 1 then
        c_id = self.m_model:getCurTop3RankData()[1].user.avatar
    end
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(c_id))
    if hero_cfg == nil then
        hero_cfg = ConfigManager:getHeroSkinCfg(tonumber(c_id))
    end
    if hero_cfg == nil then
        hero_cfg = ConfigManager:getHeroSkinCfg(506)
    end
    local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
    GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
    self.m_show_spine_id = c_id
    
end

return M