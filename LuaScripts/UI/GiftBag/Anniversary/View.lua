--==================================
-- file:  View.lua
-- brief:  小浣熊联动 赵云壮胆
-- author:  LiuMiao
-- date:  2022/7/19
--==================================
local M = class("AnniversaryView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/Anniversary"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
    self:UpdataTaskNodes()
    --self:UpdataTaskNumber()
    --self:UpdataTaskHero()
    self:updateActivityTimer()
    --self:updateActivityBg()
end

function M:updateActivityBg()
    local bg_path = TONGYONG_ZHAOYUN[self.m_model.is_open_type].image or "z_zyzd_txh"
    --local self_node_bg_img = self:findImage("ZhaoYunBg")
   -- GameUtil:updateResourcesImg(self_node_bg_img,"Texture/zhaoyun/"..bg_path)
    self:setObjectVisible("ZhaoYunBg",self.m_model.is_open_type == 1)
    self:setObjectVisible("ZhaoYunBg_TXH",self.m_model.is_open_type == 2)
end
--刷新3个节点
function M:UpdataTaskNodes()
    local data = self.m_model.m_task_data or {}
    for k,v in ipairs(data) do
        --第一种 刷新奖励
        local reward_node = self:findGameObject("ItemNode"..k)
        local reward = v.reward
        GameUtil:updateItemElement(reward_node, reward, true, true)
        --刷新按钮状态  0 未完成(领取灰) 1 领取 2 已领取
        if v.status == 0 then
            self:setImg("a_anniversary_gethui","maze_stage_ui","get_day_btn_"..k)
        elseif v.status == 1 then
            self:setImg("a_anniversary_get","maze_stage_ui","get_day_btn_"..k)
        elseif v.status == 2 then
            self:setImg("a_anniversary_yiget","maze_stage_ui","get_day_btn_"..k)
        end
        -- 设置按钮是否点击
        local btn = self:findButton("get_day_btn_"..k)
        btn.enabled = v.status == 1
        --设置红点
        self:setObjectVisible("red_point"..k,v.status == 1)
    end
    
end

--刷新 赵云数据
function M:UpdataTaskHero()
    local status = self.m_model.m_hero_stats or 0
    if status == 0 then
        self:setImg("z_zyzd_revice_gay_btn1","main_ui2","get_day_btn")
    elseif status == 1 then
        self:setImg("z_zyzd_revice_btn1","main_ui2","get_day_btn")
    elseif status == 2 then
        self:setImg("z_zyzd_received_btn1","main_ui2","get_day_btn")
    end
    local btn = self:findButton("get_day_btn")
    btn.enabled = status == 1
    --设置红点
    self:setObjectVisible("red_point_get",status == 1)
    
end

--刷新任务完成次数
function M:UpdataTaskNumber()
    self:setTextByLanKey("finish_text","new_str_0470") --完成
    self:setTextByLanKey("illustrate_text","new_str_0360") --任务
    local currentnum = self.m_model:GetCurrentTaskNum() or 0
    local allnum = self.m_model.m_all_num
    local text = currentnum .."/"..allnum
    self:setTextByLanKey("num_text",text)
end

--帅新活动时间
function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 0 then
        local text = ""
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(down_time)
        format = format or 0
        if day > 0 then
            text = string.format(Language:getTextByKey("new_str_0415"), day)
        else
            if hour > 0 then
                text = string.format("%02d:%02d:%02d", hour, min, sec)
            else
                if format == 1 then
                    if min > 0 then
                        text = string.format("%02d:%02d", min, sec)
                    else
                        text = string.format("%d", sec)
                    end
                else
                    text = string.format("%02d:%02d", min, sec)
                end
            end
        end
        self:setTextByLanKey("time_down","fukubukuroku_text_0006", text)
    else
        self:updateMsg(99999)
    end
end

function M:destroy()
--[[    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end]]
    M.super.destroy(self)
end
return M