local M = class("ServiceGoodFeelPopView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceGoodFeelPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:setTextByLanKey("common_title_text", "xian_str_0002")
    self:setTextByLanKey("get_text","new_str_0037")
    self:setTextByLanKey("lv_num", self.m_model.m_vip)
    self:setTextByLanKey("Text (2)", "xian_str_0022")
    --if self.m_model.m_vip >= 10 then
    --    self:setObjectVisible("haogan_img", false)
    --    self:setObjectVisible("haogan_img_1", true)
    --    self:setObjectVisible("haogan_img_2", true)
    --    local tens = math.floor(self.m_model.m_vip/10) 
    --    local unit = self.m_model.m_vip - (tens*10)
    --    self:setImg(tens, "active_ui", "haogan_img_1")
    --    self:setImg(unit, "active_ui", "haogan_img_2")
    --else
    --    self:setObjectVisible("haogan_img", true)
    --    self:setObjectVisible("haogan_img_1", false)
    --    self:setObjectVisible("haogan_img_2", false)
    --    self:setImg(self.m_model.m_vip, "active_ui", "haogan_img")    
    --end

    UserDataManager:removeRedDotByKey("vip_bag_once")
    UIUtil:registerDragEvent(self.m_ui_obj, handler(self,self.fingerSliding))
    self:refreshUI()
end

function M:refreshUI()
    local cur_num,max_num= self.m_model:getVipProgress()
    local slider_ = self:findSlider("slider_img")
    self:setTextByLanKey("jindu_text", cur_num.."/"..max_num)
    local need = max_num - cur_num
    if self.m_model.m_vip == self.m_model.m_max_vip then
        self:setTextByLanKey("haogandu_need", "xian_str_0006")
    else
        self:setTextByLanKey("haogandu_need", "xian_str_0003", need, self.m_model:getNextVip())
    end
   
    slider_.value = cur_num/max_num
    self:refreshListUI()
    self:createLoopScroll()
    local vip_tab = ConfigManager:getCfgByName("vip")
    if self.m_model.select_index == 0 then
        self:setObjectVisible("left_btn", false)
        self:setObjectVisible("right_btn", true)
    elseif self.m_model.select_index == self.m_model.m_max_vip then
        self:setObjectVisible("left_btn", true)
        self:setObjectVisible("right_btn", false)
    else
        self:setObjectVisible("left_btn", true)
        self:setObjectVisible("right_btn", true)
    end
    self:setObjectVisible("left_red_point", self.m_model:checkBtnCanGet(1))
    self:setObjectVisible("right_red_point", self.m_model:checkBtnCanGet(0))

end

function M:refreshListUI()
    local cfg = self.m_model:getVipCfg(self.m_model.select_index)
    local reward_node = self:findGameObject("reward_node")
    UIUtil.destroyAllChild(reward_node.transform)
    self:setTextByLanKey("bottom_title", self.m_model.select_index..Language:getTextByKey("xian_hgdjl_text"))
    self:setTextByLanKey("haogan_title", self.m_model.select_index..Language:getTextByKey("xian_hgd_text"))
    self:setTextByLanKey("get_reward_text", "new_str_0080")
    self:setObjectVisible("get_reward", false)
    self:setObjectVisible("get_reward_text", false)
    self:setObjectVisible("price_Img", false)
    
    --设置价格
    local new_price,old_price = self.m_model:getPrice(self.m_model.select_index)
    self:setTextByLanKey("old_price_text",old_price)
    self:setTextByLanKey("new_price_text",new_price)
    if cfg then
        if table.nums(cfg.reward) > 0 then
            local num = table.nums(cfg.reward)
            local reward_status = self.m_model:checkCanGet(self.m_model.select_index)
            if reward_status == 1 then
                self:setObjectVisible("get_reward", true)
                self:setObjectVisible("price_Img", true)
            elseif reward_status == 2 then
                self:setObjectVisible("get_reward_text", true)
            end
            for i = 1, num do
                local data = cfg.reward[i]
                local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
                local item = GameUtil:createItemElement(data, showNum, true)
                UIUtil.setScale(item.transform, 0.9)
                item.transform:SetParent(reward_node.transform, false)
            end
        end 
    end
end

function M:createLoopScroll()
    local data = self.m_model:getFuliList()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateCellItem(cell_obj, cell_data)
            end,
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateCellItem(obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local show_text = ""
        local show_new = self.m_model:checkIsNew(cell_data.sort)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "new_img", show_new == true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_new_text", show_new == true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "dian_img", show_new == false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_text", show_new == false)
        if show_new == true then
            if cell_data.data[2] then
                show_text = Language:getTextByKey(cell_data.data[1]).." "..cell_data.data[2]
            else
                show_text = Language:getTextByKey(cell_data.data[1])
            end
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_new_text", show_text)
        else
            if cell_data.data[2] then
                show_text = Language:getTextByKey(cell_data.data[1]).." <color=#9A4425>"..cell_data.data[2].."</color>"
            else
                show_text = Language:getTextByKey(cell_data.data[1])
            end
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_text", show_text)    
        end
    end
end

function M:fingerSliding(locat)
	if locat then
        self:updateMsg("Sliding_left")
	else
        self:updateMsg("Sliding_right")
	end
end

return M