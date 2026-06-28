local M = class("GifBagHeroCadeNode", LikeOO.OOUIbase)
--绿林集结
M.m_uiName = "GiftBag/GifBagHeroCadeNode"

function M:onEnter()
    self:setTextByLanKey("pub_btn_text", "new_str_0022")
    self:setTextByLanKey("advanced_btn_text", "new_str_0021")
    self:setTextByLanKey("shop_btn_text", "new_str_0033")
    self:setTextByLanKey("show_time", "new_str_0485")
    self:setTextByLanKey("get_tlet_text", "new_str_0554")
    self:showUI(false)
end

function M:switchInit(url, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.hero_gather_received == nil then
        return
    end
    self:showUI(true)
    --self:setObjectVisible("title_obj", true)
    self:setObjectVisible("btns", true)
    self:setObjectVisible("time_text", true)
    local cfg_data = ConfigManager:getCfgByName("hero_gather")
    for i, v in ipairs(cfg_data) do
        if UserDataManager.elite_hero_nums < v.num then
            self:setTextByLanKey("stage_text", "activities_str_0006", i)
            self:setTextByLanKey("msg_text", v.des1)
            break
        end
    end
    self:createLoopScroll()
    self.end_ts = self.m_model:getActiveEndTimeByOpenId(70)
    self:updateTime()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_hero_gather()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateHeroItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("hero_receive", cell_data.id)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateHeroItem(index, obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local item_parent = LuaBehaviour:FindGameObject("reward_content")
        UIUtil.destroyAllChild(item_parent.transform)
        local receive_btn = LuaBehaviour:FindGameObject("receive_btn")
        local no_btn_text = LuaBehaviour:FindGameObject("no_btn_text")
        local slider = LuaBehaviour:FindSlider("slider")
        local slider_value_text = LuaBehaviour:FindText("slider_value_text")
        local type = self.m_model:getHeroCadeStatus(data.id)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_text", data.des1)
        receive_btn:SetActive(type == 1)
        no_btn_text:SetActive(not (type == 1))
        local cur_num = UserDataManager.elite_hero_nums > data.num and data.num or UserDataManager.elite_hero_nums
        slider.value = cur_num / data.num
        slider_value_text.text = tostring(cur_num) .. "/" .. data.num
        if type == 0 then
            UIUtil.setTextByLanKey(receive_btn.transform, "receive_btn_text", "new_str_0057")
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "no_btn_text", "new_str_0057")
        elseif type == 1 then
            UIUtil.setTextByLanKey(receive_btn.transform, "receive_btn_text", "new_str_0056")
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "no_btn_text", "new_str_0056")
        elseif type == 2 then
            UIUtil.setTextByLanKey(receive_btn.transform, "receive_btn_text", "new_str_0080")
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "no_btn_text", "new_str_0080")
        elseif type == 3 then
            UIUtil.setTextByLanKey(receive_btn.transform, "receive_btn_text", "new_str_0063")
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "no_btn_text", "new_str_0063")
        end
        local reward_obj = GameUtil:createItemElement(data.reward[1], true, true)
        reward_obj.transform:SetParent(item_parent.transform, false)
        local reward_data = RewardUtil:getProcessRewardData(data.reward[1])
        if reward_data and reward_data.quality >= 5 then
            GameUtil:creatCommonActiveEffect(reward_obj, reward_data.quality)
        end
    end
end

function M:onButtonClick(obj, name)
    if name == "pub_btn" then
        local ck_open_flag, tips = BtnOpenUtil:isBtnOpen(13) --抽卡
        if ck_open_flag == false then
            GameUtil:lookInfoTips(self.m_control, {msg = tips, delay_close = 2})
            return
        end
        static_rootControl:closeAllViewPop()
   
        QuickOpenFuncUtil:openFunc(9, {sound_id = "UI_Go"})
    elseif name == "shop_btn" then
        local sd_open_flag, tips = BtnOpenUtil:isBtnOpen(15) --商店
        if sd_open_flag == false then
            GameUtil:lookInfoTips(self.m_control, {msg = tips, delay_close = 2})
            return
        end
        static_rootControl:closeAllViewPop()
        QuickOpenFuncUtil:openFunc(15, {sound_id = "UI_Go"})
    elseif name == "advanced_btn" then
        local cgd_open_flag, tips = BtnOpenUtil:isBtnOpen(9) --传功殿
        if cgd_open_flag == false then
            GameUtil:lookInfoTips(self.m_control, {msg = tips, delay_close = 2})
            return
        end
        static_rootControl:closeAllViewPop()
        QuickOpenFuncUtil:openFunc(7, {sound_id = "UI_Go"})
    elseif name == "help_btn" then
        local cfg_data = ConfigManager:getCfgByName("hero_gather")
        local params = {}
        params.title = "activities_str_0002"
        params.content = cfg_data[1].des
        self:openView("Pops.CommonHelpPop", params)
        audio:SendEvtUI("Play_UI_Info")
    else
        self:updateMsg(name)
    end
end

function M:updateTime()
    if self.end_ts and self.end_ts > 0 then
        local time_show = self.end_ts - UserDataManager:getServerTime() 
        if time_show > 0 then
            self:setText("time_text", GameUtil:formatTimeBySecond(time_show))
        else
            self:setTextByLanKey ("time_text", "new_str_0558")
        end
    else
        self:setTextByLanKey("time_text", "new_str_0558")
    end
end

function M:showUI(bl)
    self:setObjectVisible("show_time", bl)
    self:setObjectVisible("btns", bl)
    self:setObjectVisible("time_text", bl)
end

function M:destroy()
    M.super.destroy(self)
end

return M
