local M = class("RacconGiftView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconGift"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 13})
    --RedPointUtil:saveLocalRedPointFreshTime("GuJianQiTanGiftRedDot")
    self.m_gray_image = self:findImage("hui")
    self.m_scroll_stay_flag = true
    self.m_week_box_reward_slider = self:findSlider("active_point_slider")
    self.m_box_node = self:findGameObject("box_node")
    self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
    --self:setSpine()
    self:setTextByLanKey("close_title_text", "raccon_text_0005")
    self:setTextByLanKey("hot_value_des_text", "raccon_text_0009")
    self:setTextByLanKey("day_des_text", "raccon_text_0010")
    self:setTextByLanKey("tab_btn2_text", "raccon_text_0006")
    self:setTextByLanKey("tab_btn1_text", "raccon_text_0011")
    self:refreshUI()
end

function M:refreshUI()
    self:updateBtnStatus()
    self:refreshRedPoint()
    --self:updateLoopScroll()
    --self:updateHeroSkinShop()
end

function M:showClickTx()
    if self.m_show_tx then
        return
    end
    self.m_show_tx = true
    self:setObjectVisible("UI_Raccon_ReLiBao_001", true)
    self.m_control:setOnceTimer(1,function()
        self.m_show_tx = false
        self:setObjectVisible("UI_Raccon_ReLiBao_001", false)
    end)
end

function M:numberChange(num1, num2)
    local sequence = Tweening.DOTween.Sequence()
    sequence:SetAutoKill(false)
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        self:setText("hot_value_text", GameUtil:formatValueToString(temp))
    end, num1, num2, 0.5))
    sequence:AppendInterval(0.2)
    sequence:OnComplete(function ()

    end)
    return sequence
end

function M:refreshRedPoint()
    self:setObjectVisible("tab_btn_red_point_img1", RedPointUtil:hasRedPointById(345))
    self:setObjectVisible("tab_btn_red_point_img2", RedPointUtil:hasRedPointById(348))
end

function M:setSpine()
    local hero_skin_cfg = self.m_model:getHeroSkinCfg()
    local reward_data = RewardUtil:getProcessRewardData(hero_skin_cfg.reward[1])
    local skin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, reward_data.item_cfg)

    GameUtil:updateSpineLoadSet(self:findGameObject("hero_spine"), "RoleSpine/".. skin_data_cfg.hero_spine, "idle", 0, true)
    if reward_data then
        self:setText("hero_name2", "")
        self:setTextByLanKey("hero_name", string.cutTextForString(Language:getTextByKey(reward_data.item_cfg.name)))
        local race =  GlobalConfig.TYPE_HERO_RACE[reward_data.item_cfg.race]
        self:setImg(race.race_icon, ResourceUtil:getLanAtlas(), "hero_race")
        self:setObjectVisible("hero_name_con", true)
    else
        self:setObjectVisible("hero_name_con", false)
    end
end
function M:updateHeroSkinShop()
    local hero_skin_cfg = self.m_model:getHeroSkinCfg()
    if hero_skin_cfg then
        self:setTextByLanKey("right_btn_text2", GameUtil:getMoneyTypeNum(hero_skin_cfg.price_old))
        self:setTextByLanKey("per_text", hero_skin_cfg.return_per)
        local buy_img = self:findImage("buy_skip_btn")
        local pre_img = self:findImage("pre_img")
        if self.m_model:checkHeroSkinTimesLimited() == false then
            self:setTextByLanKey("buy_skip_btn_text", "lantern_text_0014", GameUtil:switchMoneyType(hero_skin_cfg.price_new))
            buy_img.material = nil
            pre_img.material = nil
            self:setObjectVisible("buy_skip_btn_text", true)
            self:setObjectVisible("buy_skip_get_text", false)
        else
            buy_img.material = self.m_gray_image.material
            pre_img.material = self.m_gray_image.material
            self:setTextByLanKey("buy_skip_btn_text", "gf_str_0048")
            self:setObjectVisible("buy_skip_btn_text", false)
            self:setObjectVisible("buy_skip_get_text", true)
        end
    end
end

function M:updateBtnStatus()
    local img1 =  self:setImg(self.m_model.m_cur_tab_index == 1 and "a_hxlb_xuanzhong" or "a_hxlb_weixuanzhong", "mystic_ui",  "tab_btn" .. 1)
    img1:SetNativeSize()
    local img2 = self:setImg(self.m_model.m_cur_tab_index == 2 and "a_hxlb_xuanzhong" or "a_hxlb_weixuanzhong", "mystic_ui",  "tab_btn" .. 2)
    img2:SetNativeSize()
    self:setTextColor("tab_btn1_text1", self.m_model.m_cur_tab_index == 1 and Color( 143/255, 62/255, 36/255) or Color( 31/255, 34/255, 45/255))
    self:setTextColor("tab_btn2_text1", self.m_model.m_cur_tab_index == 2 and Color( 143/255, 62/255, 36/255) or Color( 31/255, 34/255, 45/255))

    self:setObjectVisible("tab_btn1_text1", self.m_model.m_cur_tab_index == 1)
    self:setObjectVisible("tab_btn2_text1", self.m_model.m_cur_tab_index == 2)
    self:setObjectVisible("daily_node", self.m_model.m_cur_tab_index == 1)
    self:setObjectVisible("hot_node", self.m_model.m_cur_tab_index == 2)
    self:setObjectVisible("hero_info", self.m_model.m_cur_tab_index == 1)
   
    if self.m_model.m_cur_tab_index == 1 then
        self:updateLoopScroll()
        self:setSpine()
        self:updateHeroSkinShop()
    else
        self:updateHotLoopScroll()
        self:refreshHotValue()
        self:updateRewardBox()
    end
end

function M:refreshHotValue()
    local hot_value, hot_recv = self.m_model:getHotData()
    if self.m_cur_hot_nums and hot_value > self.m_cur_hot_nums then
        self:showClickTx()
        self:numberChange(self.m_cur_hot_nums, hot_value)
    else
        self:setTextByLanKey("hot_value_text", GameUtil:formatValueToString(hot_value))
    end
    self.m_cur_hot_nums = hot_value
end

--左下，宝箱
function M:updateRewardBox()
    local box_trans = self.m_box_node.transform
    UIUtil.destroyAllChild(box_trans)
    local show_data = self.m_model:getHotShowData()
    local cur_num, _ = self.m_model:getHotData()
    local width = self.m_box_node_rt.rect.width
    local max_num = 0
    local box_num = #show_data
    if show_data[box_num] then
        max_num = show_data[box_num].score
    end
    max_num = max_num > 0 and max_num or 100
    self.m_week_box_reward_slider.value = cur_num/max_num
    for i=1,box_num do
        local data = show_data[i]
        local cfg = data
        local task_box = GameUtil:createPrefab("EvilShadow/EvilShadowRewardBox", box_trans)
        local transform = task_box.transform
        UIUtil.setLocalScale(transform, 0.7, 0.7, 1.0)
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        UIUtil.setLocalPosition(task_box, width*cfg.score/max_num - width*0.5, 0)
        local function btns(trans,params)
            if data.status == 2 then -- 可领取
                self:updateMsg("box_reward", {click_transform = trans, data = data})
            else
                self:updateMsg("box_click", {click_transform = trans, data = data})
            end
        end
        UIUtil.setButtonClick(transform, btns, i)
        local score_text = UIUtil.setText(transform, tostring(cfg.score), "score_text")
        local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
        score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
        local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
        local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
        local box_img = luaBehaviour:FindImage("box_img")
        if data.status == 0 then --未开启
            GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_weijiesuobaoxiang")
        elseif data.status == 2 then --可领取
            GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_kelingqubaoxiang")
        elseif data.status == -1 then --已领取
            GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_yilingqubaoxiang")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",true)
        end
        box_img:SetNativeSize()
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
        if box_effect ~= nil then
            box_effect.gameObject:SetActive(false)
        end
        if box_effect2 ~= nil then
            box_effect2.gameObject:SetActive(false)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", data.status == 2)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 2)
        if data.status == 2 then
            --self.m_control:setOnceTimer(0.1, function()
            --	if not IsNull(task_box) then
            --		luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
            --	end
            --end)
            if box_effect ~= nil then
                box_effect.gameObject:SetActive(true)
            end
            if box_effect2 ~= nil then
                box_effect2.gameObject:SetActive(true)
            end
        end
    end
end

function M:updateLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:getGiftData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("btns_loopscroll")
        local params ={
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                --self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data then
                    self:updateMsg("buy_gift", cell_data)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
        --self.m_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_scroll_view:reloadData(data, self.m_scroll_stay_flag)
        self.m_scroll_stay_flag = true
    end
    --self:updateJianTou()
end

function M:updateCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.cfg
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("title_text")
        name_text.text = Language:getTextByKey(cfg.gift_name)
        local buy_btn_text = luaBehaviour:FindText("buy_text")

        local sort = cfg.price_type or 1
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_node", sort == 1)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_text", sort == 2 )
        if sort == 1 then -- 元宝
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cost_num_text", tostring(cfg.price))
        elseif sort == 2 then -- 充值金额
            if cfg.price == 0 then
                buy_btn_text.text = Language:getTextByKey("new_str_0278")
            else
                buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
            end
        else
            Logger.logError(sort, "ship_gift sort is error ")
        end


        local return_per_text = luaBehaviour:FindText("return_per_text")
        if return_per_text then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100) .. "%"
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", true)
        local parent = luaBehaviour:FindGameObject("reward_node")
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true, nil, 0.65)
        -- isCanBuy 展示上一礼包
        local bg_img = luaBehaviour:FindGameObject("cell_bg_image")
        if not (data.status == 1) then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", false)
            for k,v in pairs(rewards) do
                local reward_luaBehaviour = UIUtil.findLuaBehaviour(v)
                if reward_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(reward_luaBehaviour, "duigoudi_img", true)
                end
            end
            GameUtil:updateResourcesImg(bg_img, "Texture/moon_shadow/a_yycs_yilinqulibaochendi")
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", false)
            GameUtil:updateResourcesImg(bg_img, "Texture/gujianqitan/a_gjqt_lbcd")
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0105")
        else
            local residueCount = (cfg.time_limit - data.times)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", residueCount)
        end

        --置灰
        local buy_img = luaBehaviour:FindImage("bg_img")
        buy_img.material = data.status_paper == 0 and self.m_gray_image.material or nil
        --self:updateJianTou()
        --local color = data.status_paper == 0 and Color(100/255, 100/255, 100/255) or Color(125/255, 40/255, 22/255)
        --LuaBehaviourUtil.setTextColor(luaBehaviour, "buy_btn_text", color)

    end
end

function M:updateHotLoopScroll()
    --self.m_gift_tab = {}
    local data = self.m_model:getGiftData()
    if self.m_hot_scroll_view == nil then
        local loopscroll = self:findGameObject("hot_loopscroll")
        local params ={
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                --self.m_gift_tab[index] = cell_obj
                self:updateHotCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data then
                    self:updateMsg("buy_gift", cell_data)
                end
            end
        }
        self.m_hot_scroll_view = LoopScrollViewUtil.new(params)
        --self.m_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_hot_scroll_view:reloadData(data, self.m_scroll_stay_flag)
        self.m_scroll_stay_flag = true
    end
    --self:updateJianTou()
end

function M:updateHotCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.cfg
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("title_text")
        name_text.text = Language:getTextByKey(cfg.gift_name)
        local buy_btn_text = luaBehaviour:FindText("buy_text")
        

        local sort = cfg.price_type or 1
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_node", sort == 1)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_text", sort == 2 )
        if sort == 1 then -- 元宝
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cost_num_text", tostring(cfg.price))
        elseif sort == 2 then -- 充值金额
            if cfg.price == 0 then
                buy_btn_text.text = Language:getTextByKey("new_str_0278")
            else
                buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
            end
        else
            Logger.logError(sort, "ship_gift sort is error ")
        end

        local return_per_text = luaBehaviour:FindText("return_per_text")
        if return_per_text then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100) .. "%"
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", true)
        local parent = luaBehaviour:FindGameObject("reward_node")
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true, nil, 0.8)
        -- isCanBuy 展示上一礼包
        local bg_img = luaBehaviour:FindGameObject("cell_bg_image")
        if not (data.status == 1) then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", false)
            for k,v in pairs(rewards) do
                local reward_luaBehaviour = UIUtil.findLuaBehaviour(v)
                if reward_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(reward_luaBehaviour, "duigoudi_img", true)
                end
            end
            GameUtil:updateResourcesImg(bg_img, "Texture/moon_shadow/a_yycs_yilinqulibaochendi")
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", false)
            GameUtil:updateResourcesImg(bg_img, "Texture/gujianqitan/a_gjqt_lbcd")
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0105")
        else
            local residueCount = (cfg.time_limit - data.times)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", residueCount)
        end

        --置灰
        local buy_img = luaBehaviour:FindImage("bg_img")
        buy_img.material = data.status_paper == 0 and self.m_gray_image.material or nil
        --self:updateJianTou()
        --local color = data.status_paper == 0 and Color(100/255, 100/255, 100/255) or Color(125/255, 40/255, 22/255)
        --LuaBehaviourUtil.setTextColor(luaBehaviour, "buy_btn_text", color)

    end
end
--function M:onValueChanged(pos)
--    self:updateJianTou()
--end



--function M:updateJianTou()
--    local loop_view = self.m_scroll_view
--    local loop_view_num = 2
--    if loop_view and loop_view.m_line_count > loop_view_num then
--        if loop_view:getVerticalNormalizedPosition() < 0.1 then
--            self:setObjectVisible("jiantou_bottom_img", false)
--        else
--            self:setObjectVisible("jiantou_bottom_img", true)
--        end
--        if loop_view:getVerticalNormalizedPosition() > 0.9 then
--            --self:setObjectVisible("jiantou_top_img", false)
--        else
--            --self:setObjectVisible("jiantou_top_img", true)
--        end
--    else
--        --local show_data = self.m_model:getShowData()
--        --if #show_data < 5 then
--        --    self:setObjectVisible("jiantou_bottom_img", true)
--        --else
--        --end
--        self:setObjectVisible("jiantou_bottom_img", false)
--        --self:setObjectVisible("jiantou_top_img", false)
--    end
--end

function M:updateActivityTimer()
    --local end_ts = self.m_model:getTimeEnd()
    --local down_time = end_ts - UserDataManager:getServerTime()
    --if down_time >= 0 then
    --    local text = GameUtil:formatTimeBySecond(down_time, 999)
    --    self:setTextByLanKey("text_timer", text)
    --elseif down_time == 0 then
    --    self:updateMsg("refresh_data")
    --end
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M