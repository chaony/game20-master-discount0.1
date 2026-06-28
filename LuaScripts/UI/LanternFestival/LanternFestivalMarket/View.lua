local M = class("LanternFestivalMarketView",LikeOO.OOPopBase)

M.m_uiName = "LanternFestival/LanternFestivalMarket"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self.m_version = self.m_model.m_data.version
    self:refreshUI()
    self:setTextByLanKey("close_title_text", "lantern_festival_text_0004")
end

function M:destroy()
    M.super.destroy(self)
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    local data = self.m_model:get_eat_exchange_limit_cfg(self.m_version)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("task_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if UserDataManager:getServerTime() > self.m_model.m_data.end_ts then  --活动结束提示
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    return
                end
                local satisfy_bl = false --满足要求
                for k,v in pairs(cell_data.need_reward) do
                    local need_data = RewardUtil:getProcessRewardData(v)
                    if need_data.data_num > need_data.user_num then--道具不足 
                        satisfy_bl = true --不满足要求
                    end
                end

                local need_data = RewardUtil:getProcessRewardData(cell_data.need_reward[1])
                local data = self.m_model:getEatExchangeData(self.m_version, cell_data.id)
                local num = cell_data.times - data --剩余兑换次数
                if cell_data.times > 0 and num <= 0 then --无剩余兑换次数
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0761"), delay_close = 2})
                    return
                end
                if satisfy_bl == true then--道具不足
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
                    return
                end
                local out_data = RewardUtil:getProcessRewardData(cell_data.out_reward[1])
                local params = {
                    text = Language:getTextByKey("gf_str_0138", out_data.name).."?",
                    on_ok_call = function ()
                        self:updateMsg("eat_exchange",{id = cell_data.id, version = self.m_version})
                    end
                }
                self.m_control:openView("Pops.CommonPop", params)

            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateRewardItem(obj, cfg)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local left_node = LuaBehaviour:FindGameObject("awardNode1")
        local right_node = LuaBehaviour:FindGameObject("awardNode2")
        local reward_btn = LuaBehaviour:FindImage("btn_canGotBtn")
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "text_canGotBtnText", "new_str_0907")
        local data = self.m_model:getEatExchangeData(self.m_version, cfg.id)
        local can_change = true
        local num = cfg.times - data
        self:createRewards(left_node.transform, cfg.need_reward, true)
        self:createRewards(right_node.transform, cfg.out_reward, false)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "text_residueText", Language:getTextByKey("union_str_0014")..num)
        if cfg.times == 0 then
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "text_residueText", Language:getTextByKey("gf_str_0105"))
        else
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "text_residueText", Language:getTextByKey("union_str_0014")..num)
        end
        for k,v in ipairs(cfg.need_reward) do
            local need_data = RewardUtil:getProcessRewardData(v)
            if need_data.data_num > need_data.user_num then--道具不足
                can_change = false
            else
                if cfg.times > 0 and num <= 0 then
                    can_change = false
                end
            end
        end
        if can_change == false then
            reward_btn.material = self.m_gray_image.material
        else
            reward_btn.material = nil
        end
        if cfg.times > 0 and num <= 0 then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "maxk_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "maxk_img", false)
        end
    end
end

function M:createRewards(reward_node, rewards, show_bl)
    UIUtil.destroyAllChild(reward_node)
    for k, v in pairs(rewards) do
        local item = GameUtil:createItemElement(v,true, true)
        item.transform:SetParent(reward_node, false)
        local LuaBehaviour = UIUtil.findLuaBehaviour(item)
        local data = RewardUtil:getProcessRewardData(v)
        local num_text = LuaBehaviour:FindText("count_text")
        if show_bl == true then
            if data.data_num > data.user_num then
                num_text.text = "<color=#F33535>".. data.user_num.."</color>/<color=#FFFFFF>"..data.data_num.."</color>"
            else
                num_text.text = "<color=#FFFFFF>".. data.user_num.."/"..data.data_num.."</color>"
            end
        end
    end
end

function M:refreshUI()
    self:createLoopScroll()
    self:setSpine()
end

function M:setSpine()
    local hero_id = "501"--self.m_model:getHeroInReward()
    local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = "10802"})
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
    if shin_data_cfg and next(shin_data_cfg) ~= nil then
        local icon = shin_data_cfg.hero_spine
        if self.cacheSpineName == icon then
            return
        else
            self.cacheSpineName = icon
        end
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
    elseif cfg then
        local icon = cfg.hero_spine
        if self.cacheSpineName == icon then
            return
        else
            self.cacheSpineName = icon
        end
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
    else
        self.cacheSpineName = "hero_0602_SkeletonData"
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
    end
end


function M:refreshRedPoint()
end

return M