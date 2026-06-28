---@class SubscribeNode:OOUIbase
---@field m_model OperateActivityModel
local M = class("SubscribeNode",LikeOO.OOUIbase)
--订阅
M.m_uiName = "OperateActivity/SubscribeNode"

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:updateTime()
    local data = self.m_model:get_subscribe_cfg()
    for i = 1,3 do
        local cell_obj = self:findGameObject("item_data_"..i)
        local cell_data = data[i]
        self:updateCell(cell_obj, i, cell_data)
    end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "title_btn" then
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                    if luaBehaviour then
                        local m_data = {top = true}
                        local title_obj = luaBehaviour:FindGameObject("title_btn")
                        m_data.click_transform = title_obj.transform
                        m_data.msg = cell_data.des
                        GameUtil:lookInfoTips(self.m_control, m_data)
                    end
                elseif click_name == "get_reward_btn" then
                    if cell_data.sort == 1 then
                        self:updateMsg("buy_bounty_auto")   
                    else
                        if index == 2 then
                            local data = UserDataManager.m_subscribe.gacha_auto_etime or 0
                            if data == 0  then
                                --未激活   
                                self:updateMsg("go_to", 10007)    
                            else
                                if UserDataManager:subRewardReceived(2) == false then
                                    self:updateMsg("get_gacha_auto")
                                end
                            end
                        else
                            self:updateMsg("buy_subscribe", cell_data.charge_id)   
                        end
                    end
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data)
    end 
end

function M:updateCell(obj, index, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local data = 0
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_img", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "first_active_img", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", true)  
        if index == 1 then
            data = UserDataManager.m_subscribe.bounty_auto_etime or 0
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tips_text", "gf_str_0083")
        elseif index == 2 then
            data = UserDataManager.m_subscribe.gacha_auto_etime or 0
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tips_text", "gf_str_0083")
        elseif index == 3 then
            data = UserDataManager.m_subscribe.idle_auto_etime or 0     
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tips_text", "gf_str_0084")  
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "original_num", GameUtil:getMoneyTypeNum(cfg.price))
            if UserDataManager.m_subscribe.first_idle_auto == nil or UserDataManager.m_subscribe.first_idle_auto == 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "discount_img", true) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "original_img", true) 
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "discount_img", false) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "original_img", false)  
            end
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_img_"..index, true)
        local end_time =  data - UserDataManager:getServerTime()
        if data == -1 or data > 0 and end_time > 0  then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"show_time_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"get_reward_btn", false)
            if data == -1 then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "show_time_text", "gf_str_0082") 
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "show_time_text", GameUtil:formatTimeBySecond(end_time)) 
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"show_time_text", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"get_reward_btn", true)    
        end
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", cfg.name2)
        local rewardNode = luaBehaviour:FindGameObject("rewardNode")
        UIUtil.destroyAllChild(rewardNode.transform)
        local reward_nodes = {}
        for i = 1, #cfg.first_reward do
            local itemNode = GameUtil:createItemElement(cfg.first_reward[i], true, true)
            itemNode.transform:SetParent(rewardNode.transform, false)
            local itemLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
            if itemLuaBehaviour then
                if data == -1 or data > 0 and end_time > 0   then
                    if index == 2 then
                        LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", UserDataManager:subRewardReceived(2) == true)
                    else
                        LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", true)
                    end
                else
                    LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", false)    
                end
            end
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "money_icon", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "money_num", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn_text", false)
        if cfg.sort == 1 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "money_icon", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "money_num", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "money_num", cfg.price)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn_text", true)
            if index == 3 then
                if UserDataManager.m_subscribe.first_idle_auto == nil or UserDataManager.m_subscribe.first_idle_auto == 0 then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", GameUtil:getMoneyTypeNum(cfg.price_first))
                else    
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", GameUtil:getMoneyTypeNum(cfg.price))  
                end
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", GameUtil:getMoneyTypeNum(cfg.price))    
            end
        end
        if cfg.effective_days == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", "gf_str_0083")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", "gf_str_0084")  
        end
        if index == 2 then
            if data == -1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"show_time_text", UserDataManager:subRewardReceived(2) == true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"get_reward_btn", UserDataManager:subRewardReceived(2) == false)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "new_str_0056")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "show_time_text", "gf_str_0082")
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "gf_str_0101")  
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "first_active_img", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", false)  
            end
        end
        local function callback(obj, name)
            if name == "title_btn" then
                local m_data = {top = true}
                m_data.click_transform = obj.transform
                m_data.msg = cfg.des
                GameUtil:lookInfoTips(self.m_control, m_data)
            elseif name == "get_reward_btn" then
                if cfg.sort == 1 then
                    self:updateMsg("buy_bounty_auto")   
                else
                    if index == 2 then
                        data = UserDataManager.m_subscribe.gacha_auto_etime or 0
                        if data == 0  then
                            --未激活   
                            self:updateMsg("go_to", 10007)    
                        else
                            if UserDataManager:subRewardReceived(2) == false then
                                self:updateMsg("get_gacha_auto")
                            end
                        end
                    else
                        if UserDataManager.m_subscribe.first_idle_auto == nil or UserDataManager.m_subscribe.first_idle_auto == 0 then
                            self:updateMsg("buy_subscribe", cfg.charge_id_first)   
                        else
                            self:updateMsg("buy_subscribe", cfg.charge_id)       
                        end
                        
                    end
                end
            end
        end
        luaBehaviour:RegistButtonClick(callback)
    end
end

function M:destroy()
    M.super.destroy(self)
end



function M:updateTime()
    --self:createLoopScroll()
end

return M