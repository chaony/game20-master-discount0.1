---@class OperateActivityView:OOPopBase
---@field m_model OperateActivityModel
local M = class("OperateActivityView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/OperateActivity"

M.m_iphoneXAdapter = true

local _ACTIVE_RECHARGE_TAB = {
    {open_id = 80, net_url = "war_order_valor_index", tex = "a_hdzl_bg", lua_name = "UI.OperateActivity.ToKenNode", open = true}, -- 武林行侠令
    {open_id = 109, net_url = "war_order_index", tex = "a_hdzl_bg",lua_name = "UI.OperateActivity.ToKenNode", open = true}, -- 江湖行侠令
    {open_id = 84, net_url = "month_card", tex = "a_yk_bg",lua_name = "UI.OperateActivity.MonthCardNode", open = true}, -- 月卡
    {open_id = 137, net_url = "fund_index", tex = "a_qdjj_bg",lua_name = "UI.OperateActivity.SuperFundNode", open = true}, -- 签到基金
    {open_id = 85, net_url = "fund_index", tex = "a_czjj_bg",lua_name = "UI.OperateActivity.GifBagGrowUpFundNode", open = true}, -- 成长基金
    {open_id = 5000, net_url = "fund_index", tex = "a_czjj_bg",lua_name = "UI.OperateActivity.GifBagGrowUpFundInfinityNode", open = true}, -- 成长基金，无限版
    {open_id = 145, tex = "a_hdtq_bg",lua_name = "UI.OperateActivity.SubscribeNode", open = true}, -- 订阅
    {open_id = 75, net_url = "sign_daily_index", tex = "a_flzx_bg", lua_name = "UI.OperateActivity.GifBagDailyNode",open = true}, -- 每日签到
    {open_id = 176, net_url = "tiktok_data", tex = "a_qrhd_di", lua_name = "UI.OperateActivity.GifBagDyQQNode",open = true}, --tiktok
    {open_id = 452, net_url = "war_goal_common_index", tex = "a_hdzl_bg",lua_name = "UI.OperateActivity.ToKenNode", open = true} -- 侠客岛令
}

function M:onEnter()
    local attr_mode = 1
    if self.m_model.is_tokens == true then
        attr_mode = 20
    end
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
    self:setTextByLanKey("close_title_text", "gf_str_0036")
    self.m_content_panel = self:findGameObject("parent_obj")
    self.Main_Tab_Node = self:getAllTab() --一级页签
    self.cur_tab = {}
    for k,v in pairs(self.m_model.tag_table) do
        if self:getMainTagCfg(v) then
            table.insert(self.cur_tab, v)
        end
    end
    self:createLoopScroll(true)
    if self.m_scroll_view then
        self.m_scroll_view:moveToCellIndex(self.m_model.m_sel_tab_index)
        self:switchTabNode(self.m_model.m_sel_tab_index)
    else
        self:switchTabNode(1)
    end
end

function M:refreshActiveEndUI()
    self.Main_Tab_Node = self:getAllTab() --一级页签
    self.cur_tab = {}
    for k,v in pairs(self.m_model.tag_table) do
        if self:getMainTagCfg(v) then
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

function M:getAllTab()
    local activity_data = BtnOpenUtil:getBtnCfg(88)
    local new_tab = {}
    for i = 1, #activity_data.buttons do
        local _data = BtnOpenUtil:getBtnCfg(activity_data.buttons[i])
        _data.open_id = activity_data.buttons[i]
        table.insert(new_tab, _data)
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
    self.select_cell_obj = nil
    self.select_cell_index = 0
    self.m_tag_tab = {}
    self.m_obj_tab = {}
    self.first_into = first
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = self.cur_tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_obj_tab[cell_obj] = index
                self:update_tag(index, cell_obj, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if luaBehaviour then
                    if self.first_into and self.first_into == true then
                        luaBehaviour:RunAnim("OperateActivity_cell", nil, 1)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if self.m_model.m_sel_tab_index ~= index then
                    self.m_model.m_sel_tab_index2 = 1
                    self:updateMsg("switch_tab", { index =  index,cell_object =cell_object})
                end
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

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local tag_cfg = self:getMainTagCfg(data)
    local open_cfg = BtnOpenUtil:getBtnCfg(data)
    local tag_name = luaBehaviour:FindText("tag_name_text")
    tag_name.text = Language:getTextByKey(open_cfg.name)
    if index == self.m_model.m_sel_tab_index then
        self.select_cell_obj = obj
        self.select_cell_index = index
        tag_name.color =GlobalConfig.COMMON_COLLOR.COMMON_24
    else
        tag_name.color = GlobalConfig.COMMON_COLLOR.COMMON_24
    end
    local light = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", index == self.m_model.m_sel_tab_index)
    local red_flag = RedPointUtil:isFuncRedPointById(data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", red_flag == true)
    local icon_name = tag_cfg.icon.."xianzhi"
    if index == self.m_model.m_sel_tab_index then
        icon_name = tag_cfg.icon.."xuanzhong"
    end
    LuaBehaviourUtil.setImg(luaBehaviour, "tag_icon", icon_name, "active_ui")
end

function M:getMainTagCfg(data)
    for k, v in pairs(self.Main_Tab_Node) do
        if v.open_id == data then
            return v
        end
    end
end

function M:getSecondaryTagCfg(data)
    for k, v in pairs(_ACTIVE_RECHARGE_TAB) do
        if v.open_id == data or (data > 5000 and v.open_id == 5000) then
            return v
        end
    end
end

function M:switchTabNode(index, cell_object)
    local function callback()
        if not IsNull(cell_object) then
            --Logger.logErrorAlways(index.."Battle.Data.FuBen.1000")
            if not IsNull(self.select_cell_obj) then
                local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                local tag_name = luaBehaviour:FindText("tag_name_text")
                tag_name.color = GlobalConfig.COMMON_COLLOR.COMMON_24
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
                local open_id = self.cur_tab[self.select_cell_index]
                local tag_cfg = self:getMainTagCfg(open_id)
                local icon_name = tag_cfg.icon.."xianzhi"
                LuaBehaviourUtil.setImg(luaBehaviour, "tag_icon", icon_name, "active_ui")
            end
            self.select_cell_obj = cell_object
            self.select_cell_index = index
            local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", true)
            local tag_name = luaBehaviour:FindText("tag_name_text")
            tag_name.color = GlobalConfig.COMMON_COLLOR.COMMON_24
            local open_id = self.cur_tab[self.select_cell_index]
            local tag_cfg = self:getMainTagCfg(open_id)
            local icon_name = tag_cfg.icon.."xuanzhong"
            LuaBehaviourUtil.setImg(luaBehaviour, "tag_icon", icon_name, "active_ui")
        end
    end
    local data = self.cur_tab[index]
    local version = UserDataManager:getOpenActiveVersion(data)
    StatisticsUtil:doPointActive(data,version)
    self:openNodePalel(data, callback)
end

function M:updateNodeUrl()
    local data = self.cur_tab[self.m_model.m_sel_tab_index]
    local btn_tab = self:getSecondaryTagCfg(data)
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
                url_data = data
            end
            if self.m_cur_tab_node.switchInit then
                self.m_cur_tab_node:switchInit(btn_tab.net_url, url_data, btn_tab.id, handler(self, self.switchCallBack))
            end
        end
    end
end

function M:switchCallBack(data)
    if data and data["end"] == 1 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self.m_control:testRemoveCurTag()
    end
end

--打开子界面
function M:openNodePalel(open_id, callback)
    local btn_tab = self:getSecondaryTagCfg(open_id)
    self:changeSwitchTab(open_id, callback)
    local open_cfg = BtnOpenUtil:getBtnCfg(open_id)
    self:lockTouch()
    self.m_control:setOnceTimer(0.05, function()
        self:unlockTouch()
        if self.m_cur_tab_node and self.m_cur_tab_node.switchUI then
            self.m_cur_tab_node:switchUI(open_id)
        end
    end)
end

function M:changeSwitchTab(open_id, callback)
    if callback then
        callback()
    end
    local btn_tab = self:getSecondaryTagCfg(open_id)
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
    if btn_tab and btn_tab.open == true then
        local tab_cls = CustomRequire(btn_tab.lua_name)
        self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
        self.m_model:refreshTabData(btn_tab.open_id, btn_tab.net_url)
        self:updateTime()
        if btn_tab.open_id == 84 then
            UserDataManager:removeRedDotByKey("month_card_alert")
            RedPointUtil:saveLocalRedPointFreshTime("month_card_alert")
            self:createLoopScroll()
        end
    end
end

--活动 切换页签前先发送请求
function M:sendActiveNet(url,url_data, callback)
    -- local function callFunc(data)
    --     if data then
    --         if data["end"] == 1 then
    --             GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
    --             self.m_control:testRemoveCurTag()
    --             return
    --         else
    --             if callback then
    --                 callback(data)
    --             end
    --         end
    --     end     
    -- end
    -- self.m_model:initData(url, callFunc,url_data)
    if callback then
        callback()
    end
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
        if self.m_cur_tab_node.updateActiveEndTs then
            self.m_cur_tab_node:updateActiveEndTs()
        end
    end
end

function M:UpdateRedStatus()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:setRiversBtnRed()
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
