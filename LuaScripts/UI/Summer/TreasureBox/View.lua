local M = class("TreasureBoxView", LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Summer/TreasureBox"

function M:onEnter()
    self.m_mane = self.m_model.m_tab_info.name_text
    self:setTextByLanKey("title_text", self.m_mane)
    self.remain_ts = self.m_model.active_time.remain_ts

    if self.remain_ts < 0 then
        self:setObjectVisible("info_root_item", false)
    end
    self:setObjectVisible("time_out_text", false)
    local remain_day, hour = GameUtil:getTimeLayoutBySecond(self.remain_ts)
    local time_text = Language:getTextByKey("new_str_0790", remain_day, hour)
    self:setTextByLanKey("time_text", time_text)
    self:setTextByLanKey("over_text", "new_str_0793")
    self:setTextByLanKey("rewardTips_text", "new_str_0792")
    self:setTextByLanKey("rewardTitle_text", "new_str_0724")
    self:setTextByLanKey("exchange_text", "new_str_0814")
    self:setTextByLanKey("openBox_text_one", "new_str_0815")

    self:setTextByLanKey("txt_draw", "summer_text_drawGift")

    self.m_current_check_box = 0
    -- self.m_current_check_data = {}
    self:refreshUI()
    self:updateRightList()
    self:setScore()

    for i = 1, 5 do
        local gameObj = self:findGameObject("BoxItem_" .. i)
        local luaBehaviour = UIUtil.findLuaBehaviour(gameObj)
        local btnObj = luaBehaviour:FindGameObject("btn_box")

        UIUtil.setButtonClick(
            btnObj,
            function()
                audio:SendEvtUI("UI_Click_N1")
                self.m_current_check_box = i
                self:refreshUI()
                self:updateTime()
            end
        )
    end
    self:updateTime()
    self.m_timer_id = self.m_control:setTimer(0.35, handler(self, self.updateTime))
end

function M:getSelectBox()
    if self.m_current_check_box == 0 then
        return {}
    else
        -- local data = self.m_model:getDrawListData()
        local data = self.m_model.m_draw_box

        local rst = data[self.m_current_check_box]
        if rst == nil then
            return {}
        end

        return rst
    end
end

--刷新
function M:refreshUI()
    -- self.rightList = {}
    self:updateBottomLoopScroll()
    self:updateBox()
    self:setScore()
    self:setTextByLanKey("draw_times_text", Language:getTextByKey("summer_text_001") .. self.m_model.m_draw_times)
    self:setTextByLanKey("bao_di_text", Language:getTextByKey("new_str_1056"))
    local active_cfg = self.m_model:getActiveByOpenId()
    if active_cfg and active_cfg.hero_id and active_cfg.hero_id > 0 then
        self:setObjectVisible("to_active_obj", true)
        self:setTextByLanKey("active_btn_text", "gf_str_0078")
    else
        self:setObjectVisible("to_active_obj", false)    
    end
    if self.remain_ts < 0 then
        self:setObjectVisible("to_active_obj", false)
    end
end

--[[
	创建右边列表
]]
function M:updateRightList()
    -- self.m_leftclick_cell_object = nil
    local data = self.m_model:rightReward()

    if self.m_rightloop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll_node")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                -- self:updateLeftScrollViewCell(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local obj_parent = luaBehaviour:FindGameObject("cell_parent")-- cell_object.transform
                    GameUtil:createRewards(obj_parent.transform, cell_data.big_reward, true, true, nil, 1)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_reward_img", index == 1)
                    if cell_data.weight == 1 then
                        GameUtil:creatCommonItemEffect(obj_parent.transform, 7, 1)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --self:updateMsg()
            end
        }
        self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_rightloop_scroll_view:reloadData(data, true)
    end
end

--设置抽奖金币显示
function M:setScore()
    local transform = self:findGameObject("desk_Img").transform
    local luaBehaviour = self.luaBehaviour
    local chest = self.m_model:getChest()
    local version = self.m_model.m_params.draw_vsn
    local score = chest.score[1]
    self.itemData = RewardUtil:getProcessRewardData(score)

    if not self:getSelectBox().ts then --没有选中的
        local transform2 = self:findGameObject("info_root_item").transform

        UIUtil.setImg(transform2, self.itemData.icon_name, "item_icon", "draw_item_Img") --设置元宝图标
        local text_money = ""
        local curNum = self.itemData.user_num
        local needNum = self.itemData.data_num
        local isShowOpenBoxRedDot = false
        local curServerTime = UserDataManager:getServerTime()
        if curNum >= needNum then
            text_money = Language:getTextByKey("summer_text_drawDisPlay1", curNum, needNum)

            local data = self.m_model:getDrawListData()
            local getempty = false
            for k, v in pairs(data) do
                if v.ts == nil then
                    getempty = true
                end
            end
            if getempty then
                local show_start_ts = self.m_model.m_params.active_time.newShow_start_ts
                if (self.remain_ts > 0) and (show_start_ts > curServerTime) then
                    isShowOpenBoxRedDot = true
                end
            else
                isShowOpenBoxRedDot = false
            end
        else
            text_money = Language:getTextByKey("summer_text_drawDisPlay2", curNum, needNum)
            isShowOpenBoxRedDot = false
        end
        self:setObjectVisible("rp_openbox", isShowOpenBoxRedDot)

        self:setTextByLanKey("exchange_text", text_money) --设置元宝数量
        if self.remain_ts > 0 then
            self:setObjectVisible("info_root_item", true)
        end

        local btn_txt = Language:getTextByKey("summer_text_drawGift")

        self:setTextByLanKey("txt_draw", "<Color=#FFE2C4>" .. btn_txt .. "</Color>")

        if self.remain_ts < 0 then
            self:setObjectVisible("btn_exchange", false)
            self:setObjectVisible("btn_openBox_one", false)
        end

    else
        self:setObjectVisible("btn_exchange", true)
        self:setObjectVisible("btn_openBox_one", false)

        UIUtil.setImg(transform, "DJ_yuanbao", "item_icon", "btn_openBox/jinbi_Img") --设置元宝图标
        self:setObjectVisible("info_root_item", false)
        self:setTextByLanKey("txt_draw", "summer_text_drawGift")
    end
end

--设置宝箱状态
function M:updateBox()
    local openTime_show = false
    local open_text_show = false
    local btn_openBox_show = false
    local btn_exchange_show = false

    if self:getSelectBox().ts then --有选中的宝箱
        --self:setTextByLanKey("openTime_text",)
        openTime_show = true
        open_text_show = true
        btn_openBox_show = true
        --初始化桌面倒计时
        self:setOpenTime()
    else --没有选择的宝箱
        btn_exchange_show = true
    end
    --设置开启按钮状态
    local btn_exchange = self:findGameObject("btn_exchange")
    local btn_openBox = self:findGameObject("btn_openBox")
    local openTime_text = self:findGameObject("openTime_text")
    local open_text = self:findGameObject("open_text")
    btn_exchange.gameObject:SetActive(btn_exchange_show)
    btn_openBox.gameObject:SetActive(btn_openBox_show)
    openTime_text.gameObject:SetActive(openTime_show)
    open_text.gameObject:SetActive(open_text_show)
    self:setObjectVisible("btn_openBox_one",false)
end

function M:reSelectedFirstBox()
    local data = self.m_model:getDrawListData()

    for k, v in pairs(data) do
    end
end

--[[
	创建Bottom列表
]]
function M:updateBottomLoopScroll()
    self.m_click_cell_object = nil
    -- local data = self.m_model:getDrawListData()
    local data = self.m_model.m_draw_box
    for k = 1, 5 do
        local v = data[k]
        -- for k, v in pairs(data) do
        local gameObj = self:findGameObject("BoxItem_" .. k)
        local luaBehaviour = UIUtil.findLuaBehaviour(gameObj)
        local transform = gameObj.transform
        local box_btn = UIUtil.findButton(transform, "btn_box")
        local time_text = UIUtil.findText(transform, "time_text")
        local light_Img = self:findGameObject("Img_light")
        -- local list = {}
        -- list.cell_data = cell_data
        -- list.luaBehaviour = luaBehaviour
        -- list.item_Index = index

        --设置宝箱状态
        local plus_Img_show = false
        local box_Img_show = false
        local time_text_show = false
        if (not v) or (not v.ts) then
            -- if v.ts ~= nil then
            plus_Img_show = true
            box_Img_show = false
            time_text_show = false
        else
            plus_Img_show = false
            box_Img_show = true
            time_text_show = true
            --box_btn_show = true
            local time_text = GameUtil:formatTimeBySecond(v.ts - UserDataManager:getServerTime(), 999)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", time_text)
        end

        if self.m_current_check_box == k then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Img_light", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Img_light", false)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "plus_Img", plus_Img_show)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "box_Img", box_Img_show)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", time_text_show)
    end
end

--更新时间
function M:updateTime()
    local cur_tim = UserDataManager:getServerTime() --服务器时间
    if cur_tim >= self.m_model.m_params.active_time.end_ts or self.m_model.m_params.active_time.remain_ts == -1 then
        self:setObjectVisible("time_text", false)
        self:setObjectVisible("over_text", false)
        self:setObjectVisible("time_out_text", true)
    else
        local remain_tim = self.m_model.active_time.end_ts - cur_tim --剩余时间
        local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(remain_tim) --换算剩余时间
        local time_text = 1
        if remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 then --小于一分钟
            time_text = Language:getTextByKey("new_str_0842", remain_sec)
        elseif remain_day <= 0 and remain_hour <= 0 then --小于一小时
            time_text = Language:getTextByKey("new_str_0417", remain_min)
        elseif remain_day <= 0 then --小于一天
            time_text = Language:getTextByKey("new_str_0791", remain_hour)
        else
            time_text = Language:getTextByKey("gf_str_0016", remain_day)
        end
        self:setTextByLanKey("time_text", time_text) --重置剩余时间
        self:setObjectVisible("time_out_text", false)
    end

    if self.m_current_check_box ~= 0 then
        self:setOpenTime()
    end
    if self.m_model.m_draw_box ~= nil then
        self:setBox_time()
    end

    self:updateTimeBoxVis()
end

--设置桌面开启倒计时
function M:setOpenTime()
    local check = self:getSelectBox()

    if check.ts then
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(check.ts - UserDataManager:getServerTime())
        local time_text = GameUtil:formatTimeBySecond(check.ts - UserDataManager:getServerTime(), 999)
        self:setTextByLanKey("openTime_text", time_text)
        local diamond = self.m_model:getChest().diamond
        local money = 0
        if min > 0 or sec > 0 then
            hour = hour + 1
        end

        money = hour * diamond

        local transform = self:findGameObject("desk_Img").transform
        local txt_trans = self:findGameObject("openBox_text").transform
        local pos = txt_trans.localPosition

        if money > 0 then
            UIUtil.setObjectVisible(transform, true, "btn_openBox/jinbi_Img") --设置元宝图标
            self:setTextByLanKey("openBox_text", money .. Language:getTextByKey("summer_text_open"))

            pos.x = 20
        else
            UIUtil.setObjectVisible(transform, false, "btn_openBox/jinbi_Img") --设置元宝图标
            self:setTextByLanKey(
                "openBox_text",
                "<Color=#FFE2C4>" .. Language:getTextByKey("summer_text_openNow") .. "</Color>"
            )
            pos.x = 0
        end

        txt_trans.localPosition = pos
    end
end

-- 可领取
function M:setBox_time()
    for k = 1, 5 do
        local data = self.m_model.m_draw_box[k]
        -- for k, data in ipairs(self.m_model.m_draw_box) do
        local gameObj = self:findGameObject("BoxItem_" .. k)
        local luaBehaviour = UIUtil.findLuaBehaviour(gameObj)
        if data and data.ts ~= nil then
            local time_text = ""
            local delTime = data.ts - UserDataManager:getServerTime()
            if delTime > 0 then --宝箱倒计时不为0
                -- Language:getTextByKey("summer_text_drawDisPlay2", curNum, needNum)
                time_text = GameUtil:formatTimeBySecond(delTime, 999)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "boxfx_root", false)
            else
                self:setObjectVisible("btn_openBox_one",true)
                self:setObjectVisible("btn_exchange",false)
                self:setObjectVisible("btn_openBox",false)
                time_text = Language:getTextByKey("summer_text_readyReceive")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "boxfx_root", true)
            end

            LuaBehaviourUtil.setText(luaBehaviour, "time_text", time_text)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "boxfx_root", false)
        end
    end
end

function M:destroy()
    self:updateMsg("redPoint_update", nil, "Summer.SummerMain")
    M.super.destroy(self)
end

--open or close
function M:updateTimeBoxVis()
    if self.m_openBoxTime and self.m_openBoxTime > 0 then
        -- LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "img_boxEmpty_1", false)
        -- LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "img_boxEmpty_2", false)
        self.m_openBoxTime = self.m_openBoxTime - 0.3

        LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_close_Img", false)
        LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_open_Img", true)
        LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_di_Img", true)
    else
        if self:getSelectBox().ts then --有选中的宝箱
            -- LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "img_boxEmpty_1", false)
            -- LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "img_boxEmpty_2", false)
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_close_Img", true)
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_open_Img", false)
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_di_Img", true)
        else
            -- LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "img_boxEmpty_1", true)
            -- LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "img_boxEmpty_2", true)
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_close_Img", true)
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_open_Img", false)
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_di_Img", true)
        end
    end
end



return M
