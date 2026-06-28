local M = class("TopUpGiftBagView", LikeOO.OOPopBase)

M.m_uiName = "TopUpGiftBag/TopUpGiftBag"
M.m_iphoneXAdapter = true

local _ACTIVE_RECHARGE_TAB = {
    {open_id = 150, net_url = "user_payment_recommend_index", tex = "a_tj_bg1", lua_name = "UI.TopUpGiftBag.RecommendNode", open = true}, -- 推荐
    {open_id = 81, net_url = "gift_off_index", tex = "a_xsfl_bg", lua_name = "UI.TopUpGiftBag.SpecialOfferNode", open = true}, -- 特惠礼包
    {open_id = 82, net_url = "gift_new_index", tex = "a_xslb_bg", lua_name = "UI.TopUpGiftBag.NewComerGiftNode", open = true}, -- 新手礼包 
    {open_id = 114, net_url = "bright_bless_index", tex = "a_xsfl_bg",  lua_name = "UI.TopUpGiftBag.NewWelfareNode", open = true}, -- 新手福利
    {open_id = 83, net_url = "gift_supervalue_index", tex = "a_czhd_bg", lua_name = "UI.TopUpGiftBag.GeneraGiftBagNode", open = true}, -- 每日
    {open_id = 110, net_url = "gift_supervalue_index", tex = "a_czhd_bg", lua_name = "UI.TopUpGiftBag.GeneraGiftBagNode", open = true}, -- 每周
    {open_id = 111, net_url = "gift_supervalue_index", tex = "a_czhd_bg", lua_name = "UI.TopUpGiftBag.GeneraGiftBagNode", open = true}, -- 每月
    -- {open_id = 79, net_url = "continuous_index", tex = "a_czhd_bg", lua_name = "UI.TopUpGiftBag.TotllPayNode", open = true}, -- 连续充值
    {open_id = 175, net_url = "skin_gift_index", tex = "a_xshd_db", lua_name = "UI.TopUpGiftBag.SpecialDayNode", open = true}, -- 皮肤礼包
    {open_id = 116, net_url = "activity_limit_index", tex = "a_xshd_db", lua_name = "UI.TopUpGiftBag.LimitNode", open = true}, -- 限时礼包
    {open_id = 120, net_url = "custom_gift_index", tex = "a_srdz_bg", lua_name = "UI.TopUpGiftBag.CustomMadeNode", open = true}, -- 定制礼包
    {open_id = 128, net_url = "hero_gift_index", tex = "a_yxczlb_bg", lua_name = "UI.TopUpGiftBag.GrowUpNode", open = true, recharge_check_show_cfg = "hero_gift_show"}, -- 侠客成长礼包
    {open_id = 232, net_url = "equip_gift_index", tex = "a_yxczlb_bg", lua_name = "UI.TopUpGiftBag.GrowUpEquipNode", open = true}, -- 神兵成长礼包
    {open_id = 86, net_url = "pay_shop_index", tex = "a_ybsd_bg", lua_name = "UI.TopUpGiftBag.DiamondShopNode", open = true}, -- 元宝商店
    -- {open_id = 130, net_url = "cmlt_recharge_index", tex = "a_ybsd_bg", lua_name = "UI.TopUpGiftBag.TotalChargeNode", open = true}, -- 累计充值
    {open_id = 196, net_url = "gift_value_index", tex = "a_xsfl_bg", heroId = 109, lua_name = "UI.TopUpGiftBag.LadderGiftNode", open = true}, -- 阶梯礼包
    {open_id = 259, net_url = "gift_mould_index", tex = "a_xsfl_bg", heroId = 109, lua_name = "UI.TopUpGiftBag.LadderGiftNode", open = true}, -- 多期阶梯礼包
    {open_id = 200, net_url = "gift_value_daily_index", tex = "a_czhd_bg", heroId = 302, lua_name = "UI.TopUpGiftBag.EveryDayLadderGiftBagNode", open = true}, -- 每日阶梯礼包
    {open_id = 201, net_url = "gift_value_week_index", tex = "a_czhd_bg", heroId = 708,lua_name = "UI.TopUpGiftBag.EveryDayLadderGiftBagNode", open = true}, -- 每周阶梯礼包
    {open_id = 202, net_url = "gift_value_limit_index", tex = "a_xshd_db", heroId = 505,lua_name = "UI.TopUpGiftBag.LadderGiftNode", open = true}, -- 阶梯礼包2
    {open_id = 260, net_url = "growth_gift_index", tex = "a_tmhx_growup_bg", lua_name = "UI.TopUpGiftBag.GrowUpCommonNode", open = true}, -- 多期成长礼包(神兵，天命化星，英雄)
}

function M:onEnter()
    local attr_mode = 1
    if self.m_model.is_tokens == true then
        attr_mode = 20
    end
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
    self.m_content_panel = self:findGameObject("parent_obj")
    self.Tab_Node = _ACTIVE_RECHARGE_TAB
    self.cur_tab = {}
    for k,v in ipairs(self.m_model.tag_table) do
        local ui_data = self:getTagCfg(v.open_id)
        local is_show = true
        if ui_data.recharge_check_show_cfg then
            local actives_data = UserDataManager:getActivesRechargeDataByOpenId(v.open_id, v.id)
            local cur_vsn = actives_data and actives_data.version or 0
            if cur_vsn > 0 then
                is_show = self.m_model:checkRechargeActIsShow(ui_data.recharge_check_show_cfg, cur_vsn)
            end
        end
        if ui_data and is_show then
            table.insert(self.cur_tab, v)
        end
    end
    self:InitSelectIndex()
    self:createLoopScroll(true)
    self:switchTabNode(self.m_model.m_sel_tab_index)
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(self.m_model.m_sel_tab_index)
    end
    self:setTextByLanKey("close_title_text", "gf_str_0092")
end

function M: InitSelectIndex()
    local select_open_id = self.m_model.m_params.open_id or 0
    local select_active_id = self.m_model.m_params.active_id or 0
    local select_id = 0
    if select_open_id == 116 then
        select_id = self.m_model:getActiveRecharge26()
    end
    if select_open_id > 0 then
        for k, v in pairs(self.cur_tab) do
            if v.open_id == select_open_id then
                if select_id > 0 and v.id then
                    if select_id == v.id then
                        self.m_model.m_sel_tab_index = k
                    end
                else
                    self.m_model.m_sel_tab_index = k
                end
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
    for k,v in ipairs(self.m_model.tag_table) do
        local ui_data = self:getTagCfg(v.open_id)
        local is_show = true
        if ui_data.recharge_check_show_cfg then
            local actives_data = UserDataManager:getActivesRechargeDataByOpenId(v.open_id, v.id)
            local cur_vsn = actives_data and actives_data.version or 0
            if cur_vsn > 0 then
                is_show = self.m_model:checkRechargeActIsShow(ui_data.recharge_check_show_cfg, cur_vsn)
            end
        end
        if ui_data and is_show then
            table.insert(self.cur_tab, v)
        end
    end
    self:createLoopScroll(false)
    if self.m_scroll_view then
        self:switchTabNode(self.m_model.m_sel_tab_index)
    else
        self:switchTabNode(1)
    end
end

function M:getTagTable()
    local new_tab = {}
    for k,v in ipairs(self.m_model.tag_table) do
        local btn_tab = self:getTagCfg(v.open_id)
        if btn_tab then
            table.insert( new_tab, v)
        end         
    end
    return new_tab
end


function M:refreshUI()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI()
    end
    self:createLoopScroll(false)
end

--[[
    创建页签列表
]]
function M:createLoopScroll(first)
    self.first_into = first
    self.m_tag_tab = {}
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = self.cur_tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_tag_tab[cell_obj] = cell_data
                self:update_tag(index, cell_obj, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if luaBehaviour then
                    if self.first_into and self.first_into == true then
                        luaBehaviour:RunAnim("OperateActivity_cell", nil, 1)
                    end
                end
                self:updateTogBtn(cell_obj, cell_data.open_id, self.m_model.m_sel_tab_index == index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg(index, cell_data)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(self.cur_tab, true, nil, true)
        self:lockTouch()
        self.m_control:setOnceTimer(0.5, function ()
            self.m_scroll_view.m_do_tween_reload_play = false
            self:unlockTouch()
        end)
    end
    if first == true then
        self:lockTouch()
        self.m_control:setOnceTimer(0.5, function ()
            self.first_into = false
            self:unlockTouch()
        end)
    end
end

function M:switchTabNode(index, callback)
    local data = self.cur_tab[index]
    if data then
        local version = UserDataManager:getOpenActiveVersion(data.open_id)
        StatisticsUtil:doPointActive(data.open_id,version)
        local btn_tab = self:getTagCfg(data.open_id)
        if self.m_cur_tab_node then
            self.m_cur_tab_node:destroy()
            self.m_cur_tab_node = nil
        end
        local node_bg = self:findImage("active_bg_img")
        if not IsNull(node_bg) then
            GameUtil:updateResourcesImg(node_bg, "Texture/"..btn_tab.tex)
            self:setObjectVisible("active_bg_img", true)
        else
            self:setObjectVisible("active_bg_img", false)
        end
        
        local params = {}
        if btn_tab.open_id == 175 then -- 皮肤
            params.active_id = data.open_id
        elseif btn_tab.open_id == 83 then --日礼包
            params.type = 1
        elseif btn_tab.open_id == 110 then --周礼包    
            params.type = 2
        elseif btn_tab.open_id == 111 then -- 月礼包
            params.type = 3
        elseif (btn_tab.open_id == 116) or (btn_tab.open_id == 196) or (btn_tab.open_id == 200) or
                (btn_tab.open_id == 201) or (btn_tab.open_id == 202) or (btn_tab.open_id == 259) then -- 限时
            params.active_id = data.open_id
        end
       
        if btn_tab and #btn_tab.lua_name > 0 then
            self:setTextByLanKey("common_title_text", btn_tab.text_key)
            local tab_cls = CustomRequire(btn_tab.lua_name)
            self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
            local url_data = nil
            if btn_tab.open_id == 83 then --日礼包
                url_data = 1
            elseif btn_tab.open_id == 110 then --周礼包    
                url_data = 2
            elseif btn_tab.open_id == 111 then -- 月礼包
                url_data = 3
            else
                url_data = data.open_id
            end
            if self.m_cur_tab_node.initUi then
                self.m_cur_tab_node:initUi()
            end
            self:createLoopScroll(false)
            self.m_model:refreshTabData(btn_tab.open_id, btn_tab.net_url)
            self:lockTouch()
            self.m_control:setOnceTimer(0.05, function()
                self:unlockTouch()
                if self.m_cur_tab_node and self.m_cur_tab_node.switchUI then
                    self.m_cur_tab_node:switchUI(url_data, data.id)
                end
            end)
        end
    else
        if callback then
            callback()
        end
    end
end

--充值 切换页签前先发送请求
function M:sendActiveNet(url, url_data, callback)
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
    self.m_model:initData(url, callFunc, url_data)
end

function M:switchCallBack(data)
    if data and data["end"] == 1 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self.m_control:RefreshTagData()  
    end
    if data.update == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
    end
end

function M:updateTogLight()
    -- local data = self.cur_tab[self.m_model.m_sel_tab_index]
    -- for k,v in pairs(self.m_tag_tab) do
    --     self:updateTogBtn(k, v.open_id, false)
    -- end
    -- Logger.logError(self.m_tag_tab,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    -- for k,v in pairs(self.m_tag_tab) do
    --     local luaBehaviour = UIUtil.findLuaBehaviour(k)
    --     local tag_cfg = self:getOpenCfg(v.open_id)
    --     if data.open_id == v.open_id then
    --         if data.id then
    --             if v.id ==  data.id then
    --                 self:updateTogBtn(k, v.open_id, true)
    --                 Logger.logError(self.m_tag_tab,"选中======================================")
    --                 return
    --             else
    --                 self:updateTogBtn(k, v.open_id, false)
    --             end
    --         else
    --             self:updateTogBtn(k, v.open_id, true)
    --             Logger.logError(self.m_tag_tab,"选中2======================================")
    --             return
    --         end
    --     else
    --         self:updateTogBtn(k, v.open_id, false)
    --     end
    -- end
end

function M:updateTogBtn(obj, open_id, bl)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local tag_name = luaBehaviour:FindText("tag_name_text")
        local icon_name = ""
        local btn_tab = self:getOpenCfg(open_id)
        if bl == true then
            tag_name.color = Color(255 / 255, 240 / 255, 231 / 255)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", true)
            icon_name = btn_tab.icon.."xuanzhong"
        else
            tag_name.color = Color(232 / 255, 205 / 255, 175 / 255)
            --tag_name.color = Color(143 / 255, 147 / 255, 156 / 255)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
            icon_name = btn_tab.icon.."xianzhi"
        end
        LuaBehaviourUtil.setImg(luaBehaviour, "tag_icon", icon_name, "active_ui")
    end
end


function M:updateNodeUrl()
    local data = self.cur_tab[self.m_model.m_sel_tab_index]
    local btn_tab = self:getTagCfg(data.open_id)
    if self.m_cur_tab_node then
        if btn_tab and btn_tab.open == true then
            local url_data = nil
            if btn_tab.open_id == 83 then --日礼包
                url_data = 1
            elseif btn_tab.open_id == 110 then --周礼包    
                url_data = 2
            elseif btn_tab.open_id == 111 then -- 月礼包
                url_data = 3
            else
                url_data = data.open_id
            end
            if self.m_cur_tab_node.switchInit then
                self.m_cur_tab_node:switchInit(btn_tab.net_url, url_data, data.id, handler(self, self.switchCallBack), true)
            end
            if data.open_id == 81 then
                self:createLoopScroll(false)
            end
        end
    end
end

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local tag_cfg = self:getTagCfg(data.open_id)
    local tag_name = luaBehaviour:FindText("tag_name_text")
    local act_cfg = self.m_model:getActiveByOpenId(data.open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    if act_cfg then
        if data.id then
            act_cfg = active_tab[data.id] or {}
            tag_name.text = Language:getTextByKey(act_cfg.name)
        else
            tag_name.text = Language:getTextByKey(act_cfg.name)
        end
    else
        tag_name.text = Language:getTextByKey("new_str_0670")
    end
    if tag_cfg == nil then
        return
    end
    local open_cfg = self:getOpenCfg(tag_cfg.open_id)
    local icon_name = open_cfg.icon.."xianzhi"
    LuaBehaviourUtil.setImg(luaBehaviour, "tag_icon", icon_name, "active_ui")
    local red_point_img = luaBehaviour:FindGameObject("red_point")
    if tag_cfg and tag_cfg.open_id then
        local red_bl = RedPointUtil:isFuncRedPointById(tag_cfg.open_id)   
        if tag_cfg.open_id == 128 and data.id then
            red_bl = RedPointUtil:checkHeroGiftByVer(act_cfg.version)
        elseif  tag_cfg.open_id == 81 and data.id then 
            red_bl = RedPointUtil:checkGiftOffByVer(act_cfg.version)
        elseif  tag_cfg.open_id == 259 and data.id then
            red_bl = RedPointUtil:checkGiftMouldByVer(act_cfg.version)
        elseif  tag_cfg.open_id == 260 and data.id then
            red_bl = RedPointUtil:checkGrowUpGiftByVer(act_cfg.version)
        end
        red_point_img:SetActive(red_bl == true)
    else
        red_point_img:SetActive(false)
    end
end

function M:getTagCfg(data)
    for k, v in pairs(self.Tab_Node) do
        if v.open_id == data then
            return v
        end
    end
end

function M:getOpenCfg(open_id)
    return BtnOpenUtil:getBtnCfg(open_id)
end

function M:updateTime()
    if self.m_cur_tab_node then
        if self.m_cur_tab_node.updateTime then
            self.m_cur_tab_node:updateTime()
        else
            if self.m_cur_tab_node.m_end_ts and self.m_cur_tab_node.m_end_ts > 0 then
                local time_end = self.m_cur_tab_node.m_end_ts - UserDataManager:getServerTime()
                if not IsNull(self.m_cur_tab_node.time_down) then
                    if time_end > 0 then
                        self.m_cur_tab_node.time_down.text = GameUtil:formatTimeBySecond(time_end)
                    end
                else
                    if time_end > 0 then
                        self.m_cur_tab_node:setTextByLanKey("time_down", GameUtil:formatTimeBySecond(time_end))
                    end
                end
            end
        end
    end
end

--用于当前界面活动结束刷新
function M:updateActiveEndTs()
    if self.m_model.m_sel_tab_index > 1 and self.m_cur_tab_node and self.m_cur_tab_node.m_end_ts and self.m_cur_tab_node.m_end_ts > 0 then
        if UserDataManager:getServerTime() > self.m_cur_tab_node.m_end_ts then
            self:updateMsg("buy_sdk_update")
            self.m_cur_tab_node.m_end_ts = 0
        end
    elseif self.m_model.m_sel_tab_index == 1 and self.m_cur_tab_node and self.m_cur_tab_node.updateActiveEndTs then
        self.m_cur_tab_node:updateActiveEndTs()
    end
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
