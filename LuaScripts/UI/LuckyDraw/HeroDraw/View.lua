local M = class("HeroDrawView", LikeOO.OOPopBase)

M.m_uiName = "LuckyDraw/HeroDraw"
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    local open_data = self.m_model:getActiveCfgByOpenId(self.m_model.open_id)
	if open_data and open_data.name then
		self:setTextByLanKey("close_title_text", (Language:getTextByKey(open_data.name)))
    else
        self:setTextByLanKey("close_title_text", "luckyDraw_str_0001")    
	end
    self:setTextByLanKey("one_cont_text", "heroDraw_str_0001")
    self:setTextByLanKey("ten_btn_text",  "heroDraw_str_0002")
    --设置背景和spine
    --if self.m_model.active_datas then
    --    self:setTextByLanKey("once_btn_text", self.m_model.active_datas.gacha_des)
    --    self:setTextByLanKey("ten_btn_text", self.m_model.active_datas.gacha_des1)
    --end
    
    self.m_big_reward_node = self:findGameObject("big_reward_node")
    self.itemNodes = {}
    for i = 1, 3 do
        local node = self:findGameObject("ItemNode"..i);
        table.insert(self.itemNodes, node);
    end
    self.costItemNodes = {}
    for i = 1, 5 do
        local node = self:findGameObject("CostItemNode"..i);
        table.insert(self.costItemNodes, node);
    end


    local gacha_active_id = self.m_model:getGacheActiveID()
    self:setObjectVisible("change_btn", gacha_active_id ~= 0)
    
    self:refreshUI();
    self:refreshBigUI()
    self:updateTime()
    self:refreshStar()
    self:setTextByLanKey("pool_num_text", "tid#TianXiangReport_1")
    self:setTextByLanKey("change_btn_text", "new_str_0907")
end

-- 刷新奖励
function M:refreshReward( reward )
    for i, v in ipairs(reward) do
        GameUtil:updateItemElement(self.itemNodes[i], v,true, true);
    end
end

-- 刷新UI
function M:refreshUI()
    local reward_items = {}
    for i, v in ipairs(self.m_model.rewards) do
        table.insert(reward_items, v.reward[1])
    end

    local one_cost = self.m_model:getOneCost()

    local satisfy = true
    local satisfy10 = true
    for i, v in ipairs(one_cost) do
        local one_cost_data = RewardUtil:getProcessRewardData(v)
        GameUtil:updateItemElement(self.costItemNodes[i], v,true, true);
        local itemLuaBehaviour = UIUtil.findLuaBehaviour(self.costItemNodes[i])
        local icoImg = itemLuaBehaviour:FindImage("item_img")
        local qualityImg = itemLuaBehaviour:FindImage("quality_img")
        if one_cost_data.user_num  < one_cost_data.data_num * 10 then
            satisfy10 = satisfy10 and false
        end
        if one_cost_data.user_num < one_cost_data.data_num then
            satisfy = satisfy and false
            icoImg.material = self.m_gray_img.material
            qualityImg.material = self.m_gray_img.material
        else
            icoImg.material = nil
            qualityImg.material = nil
        end
    end
    self:setObjectVisible("once_btn_red_point", satisfy)
    self:setObjectVisible("ten_btn_red_point", satisfy10)


    local gacha_active_id = self.m_model:getGacheActiveID()
    self:setObjectVisible("change_btn", gacha_active_id ~= 0)
    
    self:refreshLeftCountUI()
    self:refreshReward( reward_items );
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    local red_bl = RedPointUtil:localRedPointJudge("TongYongGachaGift")
    self:setObjectVisible("gift_btn_red_point", red_bl == true)
end

function M:refreshLeftCountUI()
    self:setTextByLanKey("left_count", self.m_model:getBigRewardStr())
end

-- 刷新大奖UI
function M:refreshBigUI()
    local reward_data = self.m_model.m_big_reward[self.m_model.big_reward_index]
    if reward_data and reward_data.reward and next(reward_data.reward) ~= nil then
        UIUtil.destroyAllChild(self.m_big_reward_node.transform)
        local itemObj = GameUtil:createItemElement(reward_data.reward[1], true, true)
        itemObj.transform:SetParent(self.m_big_reward_node.transform, false)
    end
end
function M:refreshStar()
    local start_data = self.m_model:getStarInfo()
    for i, v in ipairs(start_data) do
        local text_name = "star_name_"..v.star_id
        self:setTextByLanKey(text_name, v.cfg.star_name)--设置星辰名称obj, name

        --local text_number_name = "star_number_"..v.star_id
        local number = self.m_model:getStarLightNumber(v.star_id) --点亮数量
        local max_number = #v.cfg.hero_group --最大点亮数量
        local number_text =  Language:getTextByKey("new_str_0410",number,max_number)
        --self:setTextByLanKey(text_number_name, number_text)--设置点亮星辰比例

        local Img_name = "star_"..v.star_id
        --local img_icon_start = "a_tmhx_ziweixingyuandian" --紫微星icon  初始icon
        --local img_icon = "a_tmhx_ziweixingyuandian" --紫微星icon        点亮后icon
        local img_icon_start = "a_tmhx_huaxingyuandoam_0007" --紫微星icon  初始icon
        local img_icon = "a_tmhx_yuandoam_0004" --紫微星icon        点亮后icon
        local light_name = "UI_DestinyStar_GlowB_001" --特效名称
        if v.cfg.color == 1 then --紫色
            img_icon_start = "a_tmhx_huaxingyuandoam_0005"
            img_icon = "a_tmhx_yuandoam_0001"
            light_name = "UI_DestinyStar_GlowG_001"
        elseif v.cfg.color == 2 then --绿色
            img_icon_start = "a_tmhx_huaxingyuandoam_0004"
            img_icon = "a_tmhx_yuandoam_0002"
            light_name = "UI_DestinyStar_GlowB_001"
        elseif v.cfg.color == 3 then --黄色
            img_icon_start = "a_tmhx_huaxingyuandoam_0006"
            img_icon = "a_tmhx_yuandoam_0003"
            light_name = "UI_DestinyStar_GlowY_001"
        elseif v.cfg.color == 4 then --蓝色
            img_icon_start = "a_tmhx_huaxingyuandoam_0007"
            img_icon = "a_tmhx_yuandoam_0004"
            light_name = "UI_DestinyStar_GlowB_001"
        end
        --特效内容获取
        local light_object = self:findGameObject("light_"..v.star_id)
        local transform = light_object.transform
        UIUtil.setObjectVisible(transform, true, light_name)
        if number == 0 then
            self:setImg(img_icon_start, "active_ui", Img_name) --设置初始图标
        else
            self:setImg(img_icon, "active_ui", Img_name) --设置点亮后图标
            UIUtil.setObjectVisible(transform, true, "UI_DestinyStar_JiHuo_003")
        end
        --local btnName = "star_btn_" .. v.star_id
        --local btn = self:findButton(btnName)
        --UIUtil.setButtonClick(
        --        btn,
        --        function()
        --            audio:SendEvtUI("UI_TMStar")
        --            self:updateMsg("star",v)
        --        end
        --)
    end
end

function M:updateTime()
    local end_ts = self.m_model:getEndTs()
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
		local text = GameUtil:formatTimeBySecond(down_time)
		self:setTextByLanKey("time_text", Language:getTextByKey("new_str_0919")..text)
	else
		self:updateMsg(99999)
	end
end

function M:destroy()
    --if self.m_attr_node then
    --    self.m_attr_node:destroy()
    --    self.m_attr_node = nil
    --end
    M.super.destroy(self)
end


return M