local M = class("TopUpRebatePopModel",LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
    self:getData("sea_rebate_index")
end

function M:onEnter()

end

function M:getCents()
    return self.m_data.cents
end

function M:getVoucher()
    return self.m_data.voucher
end

return M