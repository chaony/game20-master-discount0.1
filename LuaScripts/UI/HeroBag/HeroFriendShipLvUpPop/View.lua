local M = class("HeroFriendShipLvUpPopView",LikeOO.OOPopBase)
--英雄好感升级
M.m_uiName = "HeroBag/HeroFriendShipLvUpPop"
M.m_size_type = 2

function M:onEnter()
    self.reward_grid = self:findGameObject("reward_node")
    self:setTextByLanKey("reward_text", "heroFriendShipLvUp_reward_text")
    self:setTextByLanKey("combat_str_text", "new_str_0309")
    self:setTextByLanKey("reward_text (1)", "new_str_0243")
    self:refreshUI()
end

function M:refreshUI()
    local order_data = self.m_model:getOrderFetterLv()
    local new_data = self.m_model:getNewFetterLv()
    if new_data == nil then
        return
    end
    self:refreshCombat()
    --if self.m_model.order_data.lv == 0 then
        --self:setObjectVisible("dadao_text", true)
        --self:setObjectVisible("jian_img", false)
        --self:setObjectVisible("head_ord_text", false)
    --else
        --self:setObjectVisible("dadao_text", false)
        --self:setObjectVisible("jian_img", true)
        --self:setObjectVisible("head_ord_text", true)    
    --end
    --if order_data then
    --    self:setTextByLanKey("head_ord_text", order_data.name)
    --end
    --self:setTextByLanKey("head_cur_text", new_data.name)
    local rewards = self.m_model:getRewards()
    local unlock_des, is_legend = self.m_model:unlockFunc()
    if #unlock_des > 0 then
        self:setTextByLanKey("lock_text", Language:getTextByKey("hero_ui_str_0032")..unlock_des)
        self:setTextByLanKey("go_legend_btn_text", Language:getTextByKey("new_str_1067"))
        self:setObjectVisible("lock_text", true)
        self:setObjectVisible("lock_lines", true)
        self:setObjectVisible("go_legend_btn", is_legend)
    else
        self:setObjectVisible("lock_text", false)
        self:setObjectVisible("lock_lines", false)
        self:setObjectVisible("go_legend_btn", false)
    end
    if next(rewards) == nil then
        self:setObjectVisible("reward_text", false)
    else
        self:setObjectVisible("reward_text", true)    
    end
    local dubbingText = self.m_model:getDubbingText()
    self:setObjectVisible("dubbingNode", dubbingText ~= nil)
    if dubbingText ~= nil then
        self:setTextByLanKey("content", dubbingText)
    end
    
    GameUtil:createRewards(self.reward_grid.transform, rewards,true, true)
    self:updateScroll()
    self:setSpine()
    self:refreshLikeImgs()
    local vo_cfg = self.m_model:unlockDialogue()
    if vo_cfg then
        ResourceUtil:LoadRoleSound(vo_cfg.bank)
        self.cur_cv = audio:SendEvtUI(vo_cfg.se_id)
        audio:PauseMusicBusVol()
    end
end

function M:refreshCombat()
    if self.m_model.m_last_combat and self.m_model.m_last_combat > 0 then
        self:setObjectVisible("combat_up_node", true) 
        self:setText("old_combat_text", GameUtil:formatValueToString(self.m_model.m_last_combat ))
        self:setText("new_combat_text", GameUtil:formatValueToString(self.m_model.m_cur_combat ))
    end
end

function M:refreshLikeImgs()
    for i = 1, 2 do
        local likeLevel = (i == 1) and self.m_model.order_data.lv or self.m_model.new_data.lv
        if likeLevel >= 10 then
            local num_1 = math.floor(likeLevel/10)
            local num_2 = likeLevel-(num_1*10)
            self:setImg(num_1,"active_ui","youqing"..i.."_lv_img_1")
            self:setImg(num_2,"active_ui","youqing"..i.."_lv_img_2")
            self:setObjectVisible("youqing"..i.."_lv_img_2", true)
            self:setObjectVisible("youqing"..i.."_lv_img_1", true)
            self:setObjectVisible("youqing"..i.."_lv_img", false)
        else
            self:setObjectVisible("youqing"..i.."_lv_img_2", false)
            self:setObjectVisible("youqing"..i.."_lv_img_1", false)
            self:setObjectVisible("youqing"..i.."_lv_img", true)
            self:setImg(likeLevel,"active_ui","youqing"..i.."_lv_img")
        end
    end
end

function M:getOrdNum(order_data, id)
    if order_data == nil then
        return 0
    else
        for k,v in pairs(order_data.Meridian_attr) do
            if id == v[1] then
                return v[2]
            end
        end    
    end
    return 0
end


function M:updateScroll()
    local attrsData = self.m_model:getLevelUpAttrDataByLevel()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = attrsData,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
               self:updateItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(attrsData, true)
    end
end

function M:updateItem(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour and cell_data then
        LuaBehaviourUtil.setText(luaBehaviour, "cell_name", cell_data.attrsName)
        LuaBehaviourUtil.setText(luaBehaviour, "attr_1", cell_data.curNum)
        local text_newValue = luaBehaviour:FindText("attr_2")
        text_newValue.text = Language:getTextByKey(cell_data.lastNum)
        text_newValue.color = cell_data.isNotChange and Color.New(229/255, 233/ 255, 240/ 255, 1) or
                Color.New(107/255, 243/ 255, 48/ 255, 1)
    else
        local a = 1
    end
end


function M:setSpine()
    local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS,self.m_model.hero_id,0})
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
            local icon = cfg.hero_spine
            if self.cacheSpineName == icon then
                return
            else
                self.cacheSpineName = icon
            end
            if self.m_model.m_hero_skin_data and self.m_model.m_hero_skin_data ~= "" then
                self.cacheSpineName = self.m_model.m_hero_skin_data
            end
            local play_img = self:findGameObject("hero_sk")
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
        end
    else	
		local hero_sk = self:findGameObject("hero_sk")
		GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/hero_0105_SkeletonData", "idle", 0, true)
	end
end

function M:destroy()
    if self.cur_cv then
        audio:StopPlayingID(self.cur_cv)
        self.cur_cv = nil
    end
    local vo_cfg = self.m_model:unlockDialogue()
    if vo_cfg then
        ResourceUtil:UnLoadRoleSound(vo_cfg.bank)
    end
    audio:ResumeMusicBusVol()
    M.super.destroy(self)
end

return M