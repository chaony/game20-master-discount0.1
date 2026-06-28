---@class MysticChipConvertControl:OOControlBase
---@field m_view MysticChipConvertView
---@field m_model MysticChipConvertModel
local M = class("MysticChipConvertControl",LikeOO.OOControlBase)
function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg=="convert_btn" then
        if self.m_model:getMaxNum()<=0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_00122"), delay_close = 2})
        else
            if self.m_model:returnGetNum()<=0 then
                return
            else
                local function putCallback(response)
                    self.m_model.callback()
                    self:closeView()
                end
                self.m_model:getNetData("mystic_chip_convert", {to_chip_id= self.m_model.chipId,num=self.m_model:returnGetNum()}, putCallback)
            end
        end

    elseif msg=="add_one_btn" then
        self:addUseNum(1)
    elseif msg=="minus_one_btn" then
        self:addUseNum(-1)
    elseif msg == "max_btn" then
        self:addUseNum(self.m_model:getMaxNum())
    end
end

function M:addUseNum(value)
    local use_num=self.m_model.lackNum+value
    use_num = math.min(math.max(1,use_num),self.m_model:getMaxNum())

    self.m_model.lackNum=use_num
    self.m_view:UpdateUseNum(use_num)

end

function M:setGetNum(getNum)
    self.m_model.getNum=getNum
end


return M