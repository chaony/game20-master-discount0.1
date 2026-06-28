local M = class("PetFactoryAddFoodPopView",LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetFactoryAddFoodPop"
M.m_size_type = 2

M.m_gray_img = nil

function M:onEnter()
    self:setTextByLanKey("common_title_text", "pet_factory_text_0017")
    self:setTextByLanKey("tips_text", "pet_factory_text_0018", self.m_model:getMaxNum())
    self:setTextByLanKey("ok_text", "pet_factory_text_0020")
    
    self.m_item_node = self:findGameObject("item_node")
    self.find_input = self:findInputField("user_input_field")
    UIUtil.addInputFieldListener(self:findGameObject("user_input_field").transform, handler(self,self.inputChanged))

    self.m_gray_img = self:findImage("gray_img")
    
    self:refreshUI()
end

function M:refreshUI()
    self:updateUseNum()

    local confirmBtnImg = self:findImage("ok_btn")
    confirmBtnImg.material = nil
    -- 未派遣宠物时以及道具数量为0时，按钮置灰 
    if self.m_model.m_idle_end_time <= 0 or self.m_model.m_num <= 0 then
        confirmBtnImg.material = self.m_gray_img.material
    end
end

function M:updateUseNum()
    local reward_data = RewardUtil:getProcessRewardData(self.m_model:getUseItem())
    GameUtil:updateItemElementByData(self.m_item_node, reward_data, true, true)
    self:setSearchText(self.m_model.m_num)

    local time = self.m_model:getNum() * self.m_model.m_doubleTime
    self:setTextByLanKey("double_effect_text", "pet_factory_text_0019", time)
end

function M:getSearchText()
    return self.find_input.text
end

function M:setSearchText(num)
    self.find_input.text = num
end

function M:inputChanged()
    local num = self:getSearchText()
    if num and num ~= "" and type(tonumber(num)) == "number" then
        if tonumber(num) > tonumber(self.m_model.m_max_num) then
            self:setSearchText(tonumber(self.m_model.m_max_num))
        end
        self.m_model.m_num = math.min(tonumber(self.m_model.m_max_num), tonumber(num))
    else
        self.m_model.m_num = 0
    end
    
    self:refreshUI()
end

return M