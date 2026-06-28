local M = class("EverydayRechargePopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Recharge/EverydayRechargePop"

function M:onEnter()
    self:setTextByLanKey("goto_btn_text","new_str_0768")
    self:setTextByLanKey("receive_btn_text","new_str_0056")
    self:setTextByLanKey("get_btn_text","new_str_0058")
    self:refreshUI()
end

function M:refreshUI()
    self:updatebtn()
end

--设置
function M:updatebtn()
    local data,price = self.m_model:getRechargeData()
    
    --获取GameObject
    local unGet_btn = self:findButton("unGet_btn")
    local goto_btn = self:findButton("goto_btn")
    local get_btn = self:findGameObject("get_btn")
    local goto_btn_text = self:findGameObject("goto_btn_text")
    local receive_btn_text = self:findGameObject("receive_btn_text")
    local get_btn_text = self:findGameObject("get_btn_text")
    local Img_title = self:findGameObject("Img_title")
    --初始化GameObject
    local unGet_btn_show = false
    local goto_btn_show = false
    local get_btn_show = false
    local goto_btn_text_show = false
    local receive_btn_text_show = false
    local get_btn_text_show = false
    local Img_title_show = true

    --奖励
    local reward_node = self:findGameObject("reward_node")
    self.reward = data or {}
    GameUtil:createRewards(reward_node.transform, self.reward,true, true, true, nil,1)
    
    local m_price = self.m_model.m_price --获取到的已经领取的奖励
    --设置价格
    self.surplus_price = price- m_price
    --状态设置
    if m_price < price then --前往
        goto_btn_show = true
        goto_btn_text_show = true
        self:setTextByLanKey("title_price_text",math.modf(self.surplus_price))
        self:setTextByLanKey("recharge_text","new_str_0767")
        Img_title_show = true
    else --可领取
        self:setTextByLanKey("title_price_text","0")
        self:setTextByLanKey("recharge_text","new_str_0774")
        --Img_title_show = false
        if self.m_model.m_status == 1 then  --领取
            get_btn_show = true
            receive_btn_text_show = true
        elseif self.m_model.m_status == 2 then --已领取
            unGet_btn_show = false
            get_btn_text_show = true
        end
    end
    --GameObject状态设置
    goto_btn.gameObject:SetActive(goto_btn_show)
    get_btn.gameObject:SetActive(get_btn_show)
    goto_btn_text.gameObject:SetActive(goto_btn_text_show)
    receive_btn_text.gameObject:SetActive(receive_btn_text_show)
    get_btn_text.gameObject:SetActive(get_btn_text_show)
    unGet_btn.gameObject:SetActive(unGet_btn_show)
    Img_title.gameObject:SetActive(Img_title_show)

end


function M:destroy()
    M.super.destroy(self)
end

return M