local M = class("WakeUpFundNode",LikeOO.OOUIbase)

M.m_uiName = "OperateActivity/WakeUpFundNode"

function M:onEnter()  
    self.node_panel = self:findGameObject("node_panel")
    self.m_show_index = 0
    self.m_title_img = self:findImage("title_img")
    --GameUtil:updateResourcesImg(area_bg_img, "Texture/a_fl_BG")
    --area_bg_img:SetNativeSize()
    self:refreshUI()
end

function M:playEnterAnim(direction)
    if direction then
        self.m_transfer = direction
        self:runOpenAnim(self.node_panel)
    end
    self:refreshUI()
    self.m_scroll_view:moveToCellIndex(1)
end

function M:refreshTitleImg()
    local img_path = self.m_model:getCurTitlePath()
    GameUtil:updateResourcesImg(self.m_title_img, "Texture/zh_cn/".. img_path)
    self.m_title_img:SetNativeSize()
end

function M:updateData()
    self:refreshUI()
end

function M:refreshUI()
    self:refreshTitleImg()
    self:refreshPrice()
    self:refreshHeroSpine()
    self:createLoopScroll()
    local act_name = self.m_model:getUiCfg("title") or ""
    local act_des = self.m_model:getUiCfg("des") or ""
    self:setTextByLanKey("name_text", act_name)
    if self.m_model.m_from_main then
        local des = self.m_model:getUiCfg("des2") or ""
        self:setTextByLanKey("des_text1", des)
    else
        self:setTextByLanKey("des_text1", act_des, self.m_model:getDataDes())
    end
    self:setTextByLanKey("des_text2", "new_str_1090",act_name)
end

function M:refreshHeroSpine()
    local c_id = self.m_model:getUiCfg("hero_id") or ""
    local hk_obj = self:findGameObject("hero_sk1")
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(c_id))
    local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
    GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
end

function M:refreshPrice()
    local price = self.m_model:getPrice()
    self:setTextByLanKey("btn_text", GameUtil:getMoneyTypeNum(price))
end

function M:createLoopScroll()
    local data = self.m_model:getShowReward()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("reward_list_scroll")
        local params ={
            show_data = data,
            pos_center = true,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self:updateGift(cell_obj, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg(click_name, cell_data.id)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateGift(cell_obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local reward_data = RewardUtil:getProcessRewardData(cell_data)
        local ui_element = GameUtil:updateItemElementByData(cell_obj, reward_data, true, true)
        ui_element.red_point_img:SetActive(false)
    end
end

function M:onButtonClick(obj, name)
    M.super.onButtonClick(self, obj, name)
end

function M:destroy()
    M.super.destroy(self)
end

return M