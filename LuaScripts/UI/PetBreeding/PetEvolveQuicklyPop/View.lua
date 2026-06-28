---@class PetEvolveQuicklyPopView: OOPopBase
---@field m_model PetEvolveQuicklyPopModel
local M = class("PetEvolveQuicklyPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetEvolveQuicklyPop"
M.m_size_type = 2

function M:onEnter()
    self:bindUI()
    self:refreshUI()
    self:updateTime()
end

function M:bindUI()
    self:setTextByLanKey("common_title_text", "pet_bag_text_0030")
    self:setTextByLanKey("ok_text", "new_str_0048")
    self:setTextByLanKey("max_btn_text", "new_str_0643")
    self:setTextByLanKey("min_btn_text", "new_str_1100")
    self.m_item_node = self:findGameObject("item_node")
    self.find_input = self:findInputField("user_input_field")
    local gray_img = self:findImage("gray_img")
    self.m_gray_material = gray_img.material
    UIUtil.addInputFieldListener(self:findGameObject("user_input_field").transform, handler(self, self.inputChanged))
end

function M:refreshUI()
    self:updateUseNum()
    if not self.m_model:checkCanUse() then
        local use_img = self:findImage("ok_btn")
        use_img.material = self.m_gray_material
    end
end

function M:updateUseNum()
    local reward_data = RewardUtil:getProcessRewardData(self.m_model:getUseItem())
    self:setTextByLanKey("msg_text", "pet_bag_text_0034", self.m_model:getNum())
    GameUtil:updateItemElementByData(self.m_item_node, reward_data, true, true)
    self:setSearchText(self.m_model:getNum())
end

function M:getSearchText()
    return self.find_input.text
end

function M:setSearchText(num)
    self.find_input.text = num
end

function M:inputChanged()
    local num = self:getSearchText()
    local max_num = self.m_model:getMaxNum()
    max_num = max_num > 0 and max_num or 1  --道具不足默认显示1
    if num and num ~= "" and type(tonumber(num)) == "number" then
		num = tonumber(num)
        if num < 1 then
			self:setSearchText(1)
            num = 1
        end
        if num > max_num then
            self:setSearchText(max_num)
            num = max_num
        end
        self.m_model.m_num = num
    end
end

function M:updateTime()
    local curTime = UserDataManager:getServerTime()
    local endTime = self.m_model:getEndTime()
    local diffTime = endTime - curTime
    if diffTime > 0 then
    	local time_str = GameUtil:formatTimeBySecond(diffTime, 999)
    	self:setTextByLanKey("time_text", "pet_bag_text_0035", time_str)
    else
    	self:updateMsg(99999)
    end
end

return M