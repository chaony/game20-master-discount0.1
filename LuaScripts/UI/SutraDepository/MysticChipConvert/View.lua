---@class MysticChipConvertView:OOPopBase
---@field m_model MysticChipConvertModel
---@field m_control MysticChipConvertControl
local M=class("MysticChipConvertView",LikeOO.OOPopBase)
M.m_size_type = 2
M.m_uiName = "SutraDepository/MysticChipConvertPop"

function M:onEnter()
    self:setImg( self.m_model.m_mystic_cfg.icon or self.m_model.m_mystic_cfg.icon_name, "item_icon","specific_piece_icon")
    local go=self:findGameObject("common_item")
    GameUtil:updateItemElement(go,{103,self.m_model.common_chip_id,0},false,true)
    go=self:findGameObject("specific_item")
    GameUtil:updateItemElement(go,{103,self.m_model.chipId,0},false,true)

    self:setTextByLanKey("convert_text","mystic_str_00112")
    self:setTextByLanKey("common_piece_name_text","mystic_str_00113")
    self:setTextByLanKey("specific_piece_name_text",self.m_model.m_mystic_cfg.name)
    self:setTextByLanKey("common_title_text","mystic_str_00114")
    self:setTextByLanKey("conversion_ratio_text","mystic_str_00115",self.m_model.ratio)
    self.find_input = self:findInputField("user_input_field")
    UIUtil.addInputFieldListener(self.find_input.transform, handler(self,self.inputChanged))
    self:UpdateUseNum(self.m_model:getStartNum())
end

function M:inputChanged()
    local getNum=self.find_input.text
    if getNum~="" then
        getNum = tonumber(getNum)
        self:UpdateUseNum(getNum)
    else
        self:UpdateUseNum(0)
    end

    --if self.m_use_max and tonumber(num) >= self.m_use_max then
    --    num = self.m_use_max
    --    self.find_input.text =  self.m_use_max
    --end
    --self.m_use_num = tonumber(num)
end

function M:UpdateUseNum(value)

    --local consumeNum =nil
    local canGetNum =math.min(self.m_model:getMaxNum(), value)
    --local getNum =math.floor(consumeNum/self.m_model.ratio)
    local consumeNum =canGetNum*self.m_model.ratio
    self.m_control:setGetNum(canGetNum)
    self.find_input.text = tostring(canGetNum)

    self:setTextByLanKey("consume_num_text","mystic_str_00116", consumeNum)
end

return M