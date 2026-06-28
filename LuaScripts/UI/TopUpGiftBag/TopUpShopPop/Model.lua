local M = class("TopUpShopPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "up_to_down"
	self:getData("pay_shop_index")
end

function M:onEnter()
    self.is_tokens = self.m_params.is_tokens or false
end

function M:updateData(data)
    if data then
        self.m_data = data
    end
end

function M:getChargeSuccSoundId(goods_id)
    goods_id = tonumber(goods_id)
    if goods_id > 7 then
        return "UI_Pay_648"
    elseif goods_id > 6 then
        return "UI_Pay_328"
    else
        return "UI_Pay_6-198"
    end
end
--元宝商店
function M:get_charge_cfg()
    local charge_tab = ConfigManager:getCfgByName("charge")
    local data = {}
    for k, v in pairs(charge_tab) do
        if v.sort == 0 then
            v.id = k
            table.insert(data, v)
        end
    end
    return data
end

--是否还有双倍首充
function M:getDiamondData(id)
    for i,v in pairs(self.m_data.double_pay) do
        if id == v then
            return true
        end
    end
    return false
end

return M