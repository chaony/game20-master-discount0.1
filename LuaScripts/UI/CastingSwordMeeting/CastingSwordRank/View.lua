---@class CastingSwordRankView: OOPopBase
local M = class("CastingSwordRankView", LikeOO.OOPopBase)

M.m_uiName = "CastingSwordMeeting/CastingSwordHeroesList"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.avtive_data = self.m_model:getActiveData()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
    self:bindUI()
    local image_name = self:findImage("Image_bg")
    --GameUtil:updateResourcesImg(image_name,"Texture/zh_cn/tmhx_start/a_tmhx_icon_jiaomujiao")
    GameUtil:updateResourcesImg( image_name, "Texture/"..self.m_model.m_data.img_bg)
    self:refreshUI()
    --[[
    local items = self.m_model:getAllItem()
    for k, v in pairs(items) do
        if v.active_id > 0 then
			self:setObjectVisible(v.btn_name,true)
            self:setTextByLanKey(v.btn_txt_name, v.item_value)
        else
			self:setObjectVisible(v.btn_name,false)
        end
    end
    ]]--
    self:showSpine()
end

function M:refreshUI(is_refresh)
    self:setObjectVisible("myInfoNode",self.m_model.current_show_tab_num == 1)
    self:setObjectVisible("myInfoImage",self.m_model.current_show_tab_num == 1)
    self:setObjectVisible("scroll_title_text1",self.m_model.current_show_tab_num == 1)
    self:setObjectVisible("scroll_title_text2",self.m_model.current_show_tab_num == 1)
    self:setObjectVisible("scroll_title_text3",self.m_model.current_show_tab_num == 1)
    self:refreshList(is_refresh)
    self:refreshMyInfoNode()
    self:updateTime()
end

function M:updateTime()
    local end_ts = self.m_model.m_data.end_ts
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 0 then
        local text = GameUtil:formatTimeBySecond(down_time)
        self:setTextByLanKey("time_text", Language:getTextByKey("new_str_0919").."\r\n                    <color=#00FF00>"..text .. "</color>")
    else
        self:updateMsg(99999)
    end
end

--刷新排行榜list
function M:refreshList(is_refresh)
    local data = self.m_model.current_show_tab_num == 1 and self.m_model.roleRankData or self.m_model.rank_rewards
    if self then
        
    end
    if self.m_roleScroll_view == nil then
        local loopscroll = self:findGameObject("top_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshItem(cell_obj, cell_data, index)
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            pull_refresh = function() -- 下拉刷新
                self:updateMsg("load_rank")
            end,
        }
        self.m_roleScroll_view = LoopScrollViewUtil.new(params)
    else
        local refresh_list = false
        if is_refresh then
            refresh_list = true
        end
        self.m_roleScroll_view:reloadData(data,refresh_list)
    end
end

--刷新活动数据显示
function M:refreshItem(cell_obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        if self.m_model.current_show_tab_num == 1 then 
            LuaBehaviourUtil.setText(luaBehaviour, "index_text", cell_data.rank )
            local userInfo = cell_data.user
            local server_data = UserDataManager.server_data:getServerDataById(userInfo.server)
            LuaBehaviourUtil.setText(luaBehaviour, "text_name", userInfo.name )
            LuaBehaviourUtil.setText(luaBehaviour, "text_server", server_data and server_data.server_name or "")
            LuaBehaviourUtil.setText(luaBehaviour, "score_text", cell_data.score )
            local head_node = luaBehaviour:FindGameObject("head_node")
            GameUtil:setUserAvatar(head_node, userInfo,false,false,false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_image",index < 4)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"score_Image",index > 3)
            if index < 4 then
                local icon_name = "a_xwyj_phb_yi"
                if index == 2 then
                    icon_name = "a_xwyj_phb_er"
                elseif index == 3 then
                    icon_name = "a_xwyj_phb_san"
                end
                LuaBehaviourUtil.setImg(luaBehaviour, "icon_image", icon_name, "pub_ui")
            end
        else
            local rewards = cell_data.reward
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_image",#cell_data.rank == 1)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"score_Image",#cell_data.rank ~= 1)
            local reward_node = luaBehaviour:FindGameObject("reward_node")
            GameUtil:createRewards(reward_node.transform, rewards, true, true)
            if #cell_data.rank > 1 then
                local rank_str = cell_data.id
                local last_rank_1,last_rank_2 = cell_data.rank[1],cell_data.rank[2]
                if index == #self.m_model.rank_rewards then
                    rank_str = last_rank_1..Language:getTextByKey("world_boss_str_0031")
                else
                    rank_str = last_rank_1.."-"..last_rank_2
                end
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"index_text",rank_str)
            else --前三名
                local icon_name = "a_xwyj_phb_yi"
                if cell_data.rank[1] == 2 then
                    icon_name = "a_xwyj_phb_er"
                elseif cell_data.rank[1] == 3 then
                    icon_name = "a_xwyj_phb_san"
                end
                LuaBehaviourUtil.setImg(luaBehaviour, "icon_image", icon_name, "pub_ui")
            end
        end
       LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_node",self.m_model.current_show_tab_num == 2)
       LuaBehaviourUtil.setObjectVisible(luaBehaviour,"iconNode",self.m_model.current_show_tab_num == 1)
       LuaBehaviourUtil.setObjectVisible(luaBehaviour,"score_text",self.m_model.current_show_tab_num == 1)
       LuaBehaviourUtil.setObjectVisible(luaBehaviour,"text_name",self.m_model.current_show_tab_num == 1)
       LuaBehaviourUtil.setObjectVisible(luaBehaviour,"text_server",self.m_model.current_show_tab_num == 1)
    end
end

--显示我的排名
function M:refreshMyInfoNode()
    local cell_obj = self:findGameObject("myInfoNode")
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local myInfoData = self.m_model.myInfoData
        local rankIndex = myInfoData.rank > 0 and myInfoData.rank or Language:getTextByKey("new_str_0076")
        LuaBehaviourUtil.setText(luaBehaviour, "index_text", rankIndex )
        local name = UserDataManager.user_data:getUserStatusDataByKey("name")
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", name )
        local server_name = UserDataManager.server_data:getServerName()
        LuaBehaviourUtil.setText(luaBehaviour, "text_server", server_name )
        LuaBehaviourUtil.setText(luaBehaviour, "score_text", myInfoData.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
        local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
        GameUtil:setUserAvatar(head_node, {avatar = avatar, frame = frame}, false)
    end
end

--设置本地化
function M:bindUI()
    self:setTextByLanKey("reward_btn_text", "new_str_0373")
    self:setTextByLanKey("rank_btn_text", "new_str_0235")
    self:setTextByLanKey("scroll_title_text1", "new_str_0235")
    self:setTextByLanKey("scroll_title_text2", "fylt_str_0027")
    self:setTextByLanKey("scroll_title_text3", "new_str_0375")
end

--展示spine、名称
function M:showSpine()
    local hero_cfg = self.m_model:getSkinData()
    local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --设置排行榜名称
	self:setTextByLanKey("active_title_text", self.m_model:getRankTittle())
end

function M:destroy()
    M.super.destroy(self)
end

return M