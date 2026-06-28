---@class DeliciousFeastRankView: OOPopBase
local M = class("NationalBeautifulHeroesListView", LikeOO.OOPopBase)

M.m_uiName = "NationalBeautiful/NationalBeautifulHeroesList"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.grade_img = self:findImage("grade_img_slider")
    self.avtive_data = self.m_model:getActiveData()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
    self:bindUI()
    self:refreshUI()
    local items = self.m_model:getAllItem()
    for k, v in pairs(items) do
        if v.show_name then
            local show_name_text = self.m_model:getActiveName()
            self:setTextByLanKey(v.btn_name .. "_text", show_name_text)
        else
            local show_active_data = self.m_model:getActiveData(v.open_id)
            if show_active_data then
                self:setTextByLanKey(v.btn_name .. "_text", show_active_data.name)
            end
        end
    end
    self:showDialogue()
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
    self:refreshLv()
    self:createLoopScroll()
    self:setObjectVisible("peak_game_red_point_img",self.m_model.send_gift_num > 0 and  self.m_model.is_show~=2)
    self:setObjectVisible("item_1_btn_red_point_img",self.m_model:dailyRewardIsRed() and self.m_model.is_show~=2)
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
            local rewards = cell_data.rank_reward
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

--刷新等级显示,经验值显示
function M:refreshLv()
    self:setTextByLanKey("grade_txt",self.m_model.m_data.lv) --好感度等级
    local forve_lv_max = self.m_model:getLevelnum()
    local show_lv_num_text = self.m_model.m_data.exp.."/"..forve_lv_max
    self:setTextByLanKey("grade_sloder_text",show_lv_num_text)
    self.grade_img.fillAmount = self.m_model.m_data.exp/forve_lv_max
end

--设置本地化
function M:bindUI()
    self:setTextByLanKey("peak_game_btn_text", "flower_text_0057")
    self:setTextByLanKey("reward_btn_text", "new_str_0373")
    self:setTextByLanKey("rank_btn_text", "new_str_0235")
    self:setTextByLanKey("scroll_title_text1", "new_str_0235")
    self:setTextByLanKey("scroll_title_text2", "fylt_str_0027")
    self:setTextByLanKey("scroll_title_text3", "national_beautiful_text_0004")
end

--好感度列表显示
function M:updateSendGift(bl, first)
    --if self.gift_status_changing == false then
        self.gift_status_changing = true
        local left_bottom = self:findGameObject("favor")
        local send_gift = self:findGameObject("send_gift")
        if first and first == true then
            self:setObjectVisible("send_gift", false)
            self:setObjectVisible("songli_btn", true)
            self:setObjectVisible("send_mask", false)
            UIUtil.setLocalPosition(left_bottom.transform, 0,-260.2,0)
            UIUtil.setLocalPosition(send_gift.transform, 0,-412,0)
        end
        if bl == true then
            self:setObjectVisible("send_mask", true)
            self:setObjectVisible("songli_btn", false)
            self:setObjectVisible("send_gift", true)
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(left_bottom.transform:DOLocalMoveY(-167.8, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:Insert(0, send_gift.transform:DOLocalMoveY(-298.5, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:OnComplete(function ()
                self.gift_status_changing = false
            end)
            sequence:SetAutoKill(true)
        else
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(left_bottom.transform:DOLocalMoveY(-288.4, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:Insert(0, send_gift.transform:DOLocalMoveY(-412, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:OnComplete(function ()
                self:setObjectVisible("send_gift", false)
                self:setObjectVisible("songli_btn", true)
                self:setObjectVisible("send_mask", false)
                self.gift_status_changing = false
            end)
            sequence:SetAutoKill(true)
        end
    --end
end

--好感度道具
function M:createLoopScroll()
    local data = self.m_model:getItems()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local item_data = UserDataManager.item_data:getItemDataById(cell_data)
                self.m_model.send_gift_num = item_data.num
                local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, cell_data, item_data.num})
                GameUtil:updateItemElementByData(cell_obj, data, true, false, function ()
                    self:updateMsg("send_reward", cell_data)
                end)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

--显示对话
function M:showDialogue()
    local dialogue_id = 0
    local dialogue_text = ""
    if self.m_model.show_dialogue_id == 1 then --开场对话
        dialogue_id = self.m_model:getOpenDialogue()
    elseif self.m_model.show_dialogue_id == 2 then --赠送对话
        dialogue_id = self.m_model:getDialogue()
    elseif self.m_model.show_dialogue_id == 3 then --点击对话
        dialogue_id = self.m_model:getClickDialogue()
    end
    dialogue_text = self.m_model:getDialogueContent(dialogue_id)
    self:setObjectVisible("talk_bg_1",self.m_model.show_dialogue_id == 1)
    self:setObjectVisible("talk_bg_2",self.m_model.show_dialogue_id == 2 or self.m_model.show_dialogue_id == 3)
    self:setTextByLanKey("talk_txt_1",dialogue_text)
    self:setTextByLanKey("talk_txt_2",dialogue_text)
    if self.m_model.show_dialogue_id == 2 or self.m_model.show_dialogue_id == 3 then
        table.insert(self.m_model.is_once_timer,#self.m_model.is_once_timer + 1)
        self.m_control:setOnceTimer(10,function()
            table.remove(self.m_model.is_once_timer,#self.m_model.is_once_timer)
            if #self.m_model.is_once_timer == 0 then
                self:setObjectVisible("talk_bg_2",false)
            end
        end)
    end
end

--展示spine、名称
function M:showSpine()
    local hero_cfg = self.m_model:getSkinData()
    local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --设置排行榜名称
    local show_data = self.m_model:getShowDate()
    local name_img = self:findImage("list_name_img")
    if show_data.favor_name ~= "" then
        GameUtil:updateResourcesImg(name_img,"Texture/zh_cn/" .. show_data.favor_name)
    end
    name_img:SetNativeSize()
end

function M:destroy()
    M.super.destroy(self)
end

return M
