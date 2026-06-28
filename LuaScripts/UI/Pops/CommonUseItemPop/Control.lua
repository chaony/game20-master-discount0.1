local M = class("CommonUseItemPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:updateMsg(99999)
    elseif msg == "ok_btn" then -- 使用道具
        self:useItem()
    elseif msg == "minus_one_btn" then
    	self.m_model:addUseNum(-1)
        self.m_view:updateUseNum()
    elseif msg == "add_one_btn" then
    	self.m_model:addUseNum(1)
        self.m_view:updateUseNum()
    end
end

--
function M:useItem()
    local num = self.m_model:getNum()
    local inputNum = self.m_view:getSearchText()
    if inputNum == "" or inputNum == "-" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0546"), delay_close = 2})
        return
    end
    if num <= 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0546"), delay_close = 2})
        return
    end
    local function netCallback(response)
        self:updateMsg(99999)
        RewardUtil:rewardTipsByData(response.reward)
        static_rootControl:updateMsg("oo_update")
    end
    local params = {item_id = self.m_model.m_item_id, item_num = num or 1}
    self.m_model:getNetData("item_use_item", params, netCallback)
end


return M
