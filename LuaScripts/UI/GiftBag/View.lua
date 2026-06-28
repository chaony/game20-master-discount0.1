local M = class("GiftBagView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/GiftBag"
M.m_iphoneXAdapter = true
--
local __TAB_BTN_NODE = {
    {open_id = 72, red_key = 48, net_url = "active_seven_tour_index", url_name = "seven_tour", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifBagDay14Node"}, -- 14日登录
    {open_id = 75, red_key = 51, net_url = "sign_daily_index", tex = "a_flzx_bg", lua_name = "UI.GiftBag.GifBagDailyNode"}, -- 每日签到
    {open_id = 70, red_key = 46, net_url = "active_hero_gather_index", url_name = "hero_gather_received", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifBagHeroCadeNode"}, -- 绿林集结
    {open_id = 72, red_key = 52, net_url = "online_reward_index", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifBagOnTimeNode"}, -- 在线奖励
    {open_id = 77, lua_name = "UI.GiftBag.GifBagDoubleNode", tex = "a_flzx_beijing", text_key = "gf_str_0022"}, -- 双倍收益
    {open_id = 117, red_key = 90, net_url = "draw_index", url_name = "draw_index", tex = "a_ui_gq", lua_name = "UI.GiftBag.GifBagGuaNode"}, -- 卦签
    {open_id = 118, red_key = 91, net_url = "scroll_index", tex = "a_jnyz_bg", lua_name = "UI.GiftBag.GifAcePagNode"}, -- 锦囊玉轴
    {open_id = 131, red_key = 104, net_url = "treasure_index", url_name = "treasure_index", tex = "a_cbt_bg", lua_name = "UI.GiftBag.GifTreasureNode"}, -- 侠影绘卷
    {open_id = 132, red_key = 105, net_url = "hero_train_index", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifHeroTrainNode"}, -- 侠客试炼
    {open_id = 154, red_key = 124, net_url = "exchange_index",  url_name = "exchange_index", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifLimitExchangeNode"}, -- 限时兑换
    {open_id = 233, red_key = 233, net_url = "month_exchange_index",  url_name = "month_exchange_index", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifMonthExchangeNode"}, -- 满月兑换
    {open_id = 84, red_key = 60, net_url = "month_card", url_name = "month_card", tex = "a_qrhd_di", lua_name = "UI.GiftBag.MonthCardNode"}, -- 月卡
    {open_id = 176, red_key = 176, net_url = "tiktok_data", url_name = "tiktok_data", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifBagDyQQNode"}, --tiktok
    {open_id = 197, red_key = 197, net_url = "hero_rank_index", url_name = "hero_rank_index", tex = "a_xkzf_bg1", lua_name = "UI.GiftBag.OpenServerRank", lua_name2 = "UI.GiftBag.VersionDashRank"}, --侠客争锋  --赛季冲榜
    {open_id = 198, red_key = 198, net_url = "producer_index", url_name = "producer", tex = "a_qrhd_di", lua_name = "UI.GiftBag.ProducerGiftBag"}, --制作人赠礼
    {open_id = 217, red_key = 217, tex = "a_zfb_bg", lua_name = "UI.GiftBag.AlipayActivityNode"}, --支付宝红包活动
    {open_id = 216, red_key = 216, net_url = "bowl_index", url_name = "bowl_index", tex = "a_jbp_bg", lua_name = "UI.GiftBag.RechargeAndRebateNode"}, --聚宝盆
    {open_id = 231, red_key = 231, net_url = "wish_index",url_name = "wish_index", tex = "a_hyqf_bg", lua_name = "UI.GiftBag.KongMingLanternNode"}, -- 鸿运祈福 -- 夜放孔明灯
    {open_id = 242, red_key = 242, net_url = "active_hero_gather_active_index", url_name = "hero_gather_active_received", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifBagHeroCadeActiveNode"}, -- 侠影集结
    {open_id = 243, red_key = 243, net_url = "card_exchange_index", url_name = "card_exchange_index", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifHeroExchangeNode"}, -- 紫卡兑换
    {open_id = 251, red_key = 251, net_url = "eat_exchange_index",  url_name = "eat_exchange_index", tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifEatExchangeNode"}, -- 兑换2
    {open_id = 358, red_key = 358, net_url = "recharge_rebate",  url_name = "recharge_rebate",tex = "a_qrhd_di", lua_name = "UI.GiftBag.GifRechargeRebateNode"}, -- 充值返利
    {open_id = 400, red_key = 400, net_url = "weekend_sevent_index",  url_name = "weekend_sevent_index",tex = "HeavenBlessReward/a_tcqf_choujiang_BJ", lua_name = "UI.GiftBag.HeavenBlessRewardNode"}, -- 天赐祈福
    {open_id = 416, red_key = 416, net_url = "",  url_name = "",tex = "a_qrhd_di", lua_name = "UI.GiftBag.ChinaMobileActivityNode"}, -- 中国移动

}

function M:onEnter()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control)
    self.m_content_panel = self:findGameObject("parent_obj")
    if self.m_model.mode == 1 then
        self.Tab_Node = __TAB_BTN_NODE
    end
    -- self.cur_tab = self.m_model.tag_table
    self.cur_tab = {}
    for k,v in pairs(self.m_model.tag_table) do
        if self:getTagCfg(v.open_id) then
            table.insert(self.cur_tab, v)
        end
    end

    self:InitSelectIndex()
    self:createLoopScroll()
    self:switchTabNode(self.m_model.m_sel_tab_index)
    self:refreshUI()
    self:updateTogLight()
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(self.m_model.m_sel_tab_index)
    end
    local fl_cfg = UserDataManager:getActivesDataByOpenId(23)
    if fl_cfg then
        local tempActivityData = self.m_model:checkActiveById(fl_cfg.id)
        if tempActivityData then
            self:setTextByLanKey("close_title_text", tempActivityData.name)
        else
            self:setTextByLanKey("close_title_text", "gf_str_0037")
        end
    else
        self:setTextByLanKey("close_title_text", "gf_str_0037")
    end
end

function M: InitSelectIndex()
    local select_open_id = self.m_model.m_params.open_id or 0
    local select_active_id = self.m_model.m_params.active_id or 0
    if select_open_id > 0 then
        for k, v in pairs(self.cur_tab) do
            if v.open_id == select_open_id then
                self.m_model.m_sel_tab_index = k
            end
        end
    elseif select_active_id > 0 then
        for k, v in pairs(self.cur_tab) do
            if v.id == select_active_id then
                self.m_model.m_sel_tab_index = k
                break
            end
        end
    end
end

function M:refreshActiveEndUI()
    self.cur_tab = {}
    for k,v in pairs(self.m_model.tag_table) do
        if self:getTagCfg(v.open_id) then
            table.insert(self.cur_tab, v)
        end
    end
    self:createLoopScroll()
    self:switchTabNode(self.m_model.m_sel_tab_index)
    self:updateTogLight()
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(self.m_model.m_sel_tab_index)
    end
end

function M:refreshUI()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI()
    end
    self:createLoopScroll()
end

--[[
    创建页签列表
]]
function M:createLoopScroll()
    self.m_tag_tab = {}
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = self.cur_tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_tag_tab[index] = {data = cell_data, obj = cell_obj}
                self:update_tag(index, cell_obj, cell_data)
                self:updateTogLight()
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg(index)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(self.cur_tab, true)
    end
end

function M:updateTogLight()
    for k, v in pairs(self.m_tag_tab) do
        local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
        if luaBehaviour then
            local tag_name = luaBehaviour:FindText("tag_name_text")
            if self.m_model.m_sel_tab_index == k then
                tag_name.color = Color(175 / 255, 108 / 255, 64 / 255)
            else
                tag_name.color = Color(183 / 255, 168 / 255, 130 / 255)
            end
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", self.m_model.m_sel_tab_index == k)
        end
    end
end

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local tag_cfg = self:getTagCfg(data.open_id)
    local tag_name = luaBehaviour:FindText("tag_name_text")
    local act_cfg = self.m_model:getActiveByOpenId(data.open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    if data.id then
        act_cfg = active_tab[data.id]
        if act_cfg then
            tag_name.text = Language:getTextByKey(act_cfg.name)
        end
    else
        if act_cfg then
            tag_name.text = Language:getTextByKey(act_cfg.name)
        end
    end
    local red_point_img = luaBehaviour:FindGameObject("red_point")
    if tag_cfg and tag_cfg.red_key then
        local red_bl = false
        if tag_cfg.red_key == 48 and act_cfg.version ~= 1 and act_cfg then
            red_bl = RedPointUtil:checkExchangeLimit(act_cfg.version)
        elseif tag_cfg.red_key == 251 then
            local vsn_dot = UserDataManager.red_dot["eat_exchange"] or {}
            if vsn_dot and vsn_dot.eat_vsn then
                for k,v in pairs(vsn_dot.eat_vsn) do
                    if v == act_cfg.version then
                        red_bl = true
                    end
                end
            end
        elseif tag_cfg.red_key== 400 then --XXX：对天赐祈福活动红点刷新逻辑的特殊处理
            local RP_Flag = RedPointUtil:hasRedPointById(tag_cfg.red_key) 
            local localData_flag = self.m_model.m_heavenBless_data.LOCAL_RED_POINT_DATA
            red_bl = localData_flag or RP_Flag
        else
            red_bl = RedPointUtil:hasRedPointById(tag_cfg.red_key)
        end
        red_point_img:SetActive(red_bl == true)
    else
        red_point_img:SetActive(false)
    end
    local tog_btn = luaBehaviour:FindToggle("tag_btn")
    if tog_btn then
        UIUtil.addToggleListener(
            tog_btn,
            function(is_on)
                self:switchTabUpdate(is_on, index)
            end,
            nil,
            self.m_uiName
        )
    end
end

function M:getTagCfg(data)
    for k, v in pairs(self.Tab_Node) do
        if v.open_id == data then
            return v
        end
    end
end


function M:getBgName(btn_tab)
    local tempOpenId = 197
    if btn_tab.open_id ~= tempOpenId then
        return btn_tab.tex
    end
    -- 侠客争锋不同赛季，走策划配表
    local activityData = self.m_model:checkActiveDataByOpenId(tempOpenId)
    if not activityData then
        return btn_tab.tex
    end
    local version = activityData.version
    if version <= 1 then
        return btn_tab.tex
    end
    local rank_effectData = ConfigManager:getCfgByName("rank_effect")
    local versionRankAwardData = rank_effectData[version]
    for _, tempData in pairs(versionRankAwardData) do
        if tempData then
            for _, itemData in pairs(tempData) do
                -- 背景和排行榜类型有关
                return itemData.background
            end
        end
    end
    return btn_tab.tex
end

function M:switchTabNode(index, callback)
    local data = self.cur_tab[index]
    if data then
        local version = UserDataManager:getOpenActiveVersion(data.open_id)
        StatisticsUtil:doPointActive(data.open_id,version)
        local btn_tab = self:getTagCfg(data.open_id)
        local function NetOver(response)
            if callback then
                callback()
            end
        end
        if btn_tab then 
            self:updateTogLight()
            if self.m_cur_tab_node then
                self.m_cur_tab_node:destroy()
                self.m_cur_tab_node = nil
            end
            local node_bg = self:findImage("active_bg_img")
            if not IsNull(node_bg) then
                GameUtil:updateResourcesImg(node_bg, "Texture/"..self:getBgName(btn_tab))
                self:setObjectVisible("active_bg_img", true)
            else
                self:setObjectVisible("active_bg_img", false)
            end
            if btn_tab and #btn_tab.lua_name > 0 then
                local tempLua_Name = self:getLuaName(btn_tab)
                local tab_cls = CustomRequire(tempLua_Name)
                self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel, active_data = data})
                if btn_tab.net_url and self.m_cur_tab_node.switchUI then
                    self.m_model:refreshTabData(btn_tab.open_id, btn_tab.url_name)
                    self:lockTouch()
                    self.m_control:setOnceTimer(0.05, function()
                        self:unlockTouch()
                        if self.m_cur_tab_node then
                            self.m_cur_tab_node:switchUI(data.id)
                        end
                    end)
                    if data.open_id == 118 and self.m_attr_node then
                        self.m_attr_node:changeAttrsByMode(9)
                    elseif data.open_id == 400 and self.m_attr_node then
                        self.m_attr_node:changeAttrsByMode(1)
                    else
                        self.m_attr_node:changeAttrsByMode(1)
                    end
                end
                if btn_tab.open_id == 84 then
                    UserDataManager:removeRedDotByKey("month_card_alert")
                    RedPointUtil:saveLocalRedPointFreshTime("month_card_alert")
                    self:createLoopScroll()
                elseif btn_tab.open_id == 217 then   
                    RedPointUtil:saveLocalRedPointFreshTime("AlipayRedBagActivityRedDot")
                    self:createLoopScroll()
                end
              
                if btn_tab.open_id == 176 then
                    local luaBehaviour = UIUtil.findLuaBehaviour(self.m_tag_tab[index].obj)
                    local red_point_img = luaBehaviour:FindGameObject("red_point")
                    red_point_img:SetActive(false)
                    RedPointUtil.__key_170_data = 0
                end
            end
        else
            if callback then
                callback()
            end  
        end
    else
        if callback then
            callback()
        end
    end
end

function M:getLuaName(btn_tab)
    if btn_tab.open_id ~= 197 then
        return btn_tab.lua_name
    end
    --- 侠客争锋特殊处理
    local activityData = self.m_model:checkActiveDataByOpenId(197)
    if activityData then
        local curVersion = activityData.version
        if curVersion > 1 then
            return btn_tab.lua_name2
        end
    end
    return btn_tab.lua_name
end

--福利 切换页签前先发送请求
function M:sendActiveNet(url, callback)
    local function callFunc(data)
        if data then
            if data["end"] == 1 then
                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self.m_control:testRemoveCurTag()
                return
            else
                if callback then
                    callback(data)
                end
            end
        end
    end
    if url then
        self.m_model:initData2(url, callFunc)
    else
        if callback then
            callback()
        end
    end
end

function M:switchCallBack(data)
    if data and data["end"] == 1 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self.m_control:testRemoveCurTag()
    end
end

function M:updateTime()
    if self.m_cur_tab_node then
        if self.m_cur_tab_node.updateTime then
            self.m_cur_tab_node:updateTime()
        end
    end
end

function M:showUI(bl)
    self:setObjectVisible("btn_gotBtn", bl)
end

function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M
