---@class MysticChipConvertModel:OODataBase
local M=class("MysticChipConvertModel",LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.chipId=self.m_params.chipId
    self.m_mystic_cfg=self.m_params.mystic_cfg
    self.callback=self.m_params.callback
    local common_cfg=ConfigManager:getCfgByName("common")
    self.common_chip_id=common_cfg[833].value

    self.ratio =common_cfg[834].value[self.m_mystic_cfg.quality]
    self.lackNum=self.m_params.lackNum

    local itemData=UserDataManager.item_data:getItemDataById(self.common_chip_id)
    self.canConvertNum =self:makeInt(itemData.num)

    self.getNum=0
end

function M:refreshData()
    local itemData=UserDataManager.item_data:getItemDataById(self.common_chip_id)
    self.canConvertNum =self:makeInt(itemData.num/self.ratio)
end

function M:getStartNum()
    if self.canConvertNum>=self.lackNum then
        return self.lackNum
    else
        return self.canConvertNum
    end
end

function M:getMaxNum()
    return self.canConvertNum
end

function M:setGetNum(getNum)
    self.getNum=getNum
end

function M:returnGetNum()
    return self.getNum
end

function M:makeInt(inputValue)
    local ret=inputValue/self.ratio
    --if (ret-math.floor(ret))>0 then
    --    ret=math.ceil(ret)
    --end
    ret=math.floor(ret)
    return ret
end

return M