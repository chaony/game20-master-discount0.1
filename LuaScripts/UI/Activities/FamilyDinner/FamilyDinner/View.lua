---@class FamilyDinnerView:OOPopBase
local M = class("FamilyDinnerView", LikeOO.OOPopBase)

M.m_uiName = "Activities/FamilyDinner/FamilyDinner"
M.m_iphoneXAdapter = true
M.m_axian_actions = 
{
    "taibangle",
    "talk_xushu",
    "shy",
    "talk_think",
    "talk_tanshou",
    "talk_beishou",
    "baibai",
    "baishoufouding",
    "chayao",
}

function M:onEnter()
    self.m_player_talk_isShow = false
    self.isCreateAXian = false;
    self.action_cache = {}
    self.GameObject3D = self:findGameObject("GameObject3D")
    self.GameObject3D.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.GameObject3D.transform,1,1,1)
    self.role_parent = self:findGameObject("role_3d")
    --新年模式/普通模式
    self.current_mode = self.m_model:getCurrentActiveMode()
    self:setObjectVisible("newyear",self.current_mode == 1)
    self:setObjectVisible("bg_img_new_year",self.current_mode == 1)
    self:setObjectVisible("ordinary",self.current_mode == 0)
    --阿闲的弹字框
    self.m_player_talk = self:findGameObject("player_talk")
    self.m_player_talk_anim = self.m_player_talk:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    if self.m_model.m_active_name ~= "" then
        self:setTextByLanKey("close_title_text", self.m_model.m_active_name)
    else
        self:setTextByLanKey("close_title_text", "family_dinner_text002")
    end
    self.team_score_text = self.current_mode == 0 and self:findText("team_score_text") or self:findText("team_score_text_new_year")
    self.hero_obj = {}
    for i = 1, 5 do
        local hero_item_obj = self:findGameObject("hero_0"..i);
        table.insert(self.hero_obj, hero_item_obj);
    end
    self.hui = self:findImage("hui");
    self.gift_views = {}
    for i = 1, 3 do
        local gift_view = {}
        gift_view.mainObj = self:findGameObject("gift_item"..i);
        gift_view.buy_btn_text = self:findText("buy_btn_text"..i);
        gift_view.score_text = self:findText("score_text"..i);
        gift_view.title_text = self:findText("title_text"..i);
        gift_view.caiIcon = self:findImage("caiIcon"..i);
        gift_view.buy_btn = self:findButton("buy_btn"..i);
        gift_view.buy_btn_img = self:findImage("buy_btn"..i);
        gift_view.itemNodes = {}
        for j = 1, 3 do
            local itemNode = self:findGameObject("ItemNode"..i..j);
            table.insert(gift_view.itemNodes, itemNode);
        end
        table.insert(self.gift_views, gift_view);
    end
    local mode_ = self.m_model.is_token ==true and 20 or 1
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = mode_})
end

-- 刷新UI
function M:refreshUI( data )
    local des = self.m_model.m_value_des == "" and "family_dinner_text003" or self.m_model.m_value_des
    if data == nil then
        self.team_score_text.text = Language:getTextByKey(des) .. 0;
        --说明没有工会
        self:hideHeroObjs(-1, false)
    else
        self.team_score_text.text = Language:getTextByKey(des) .. self.m_model.m_guild_score;
        self:hideHeroObjs(-1, false)
        --for i, v in ipairs(data.ranks) do
        --    self:hideHeroObjs(i, true, v)
        --end
    end
    if self.m_model.m_key and self.m_model.m_key > 0 then
        self:setTextByLanKey("key_num_text", "new_str_0295",self.m_model.m_key) 
        self:setObjectVisible("key_num_img", true)
    else
        self:setObjectVisible("key_num_img", false)    
    end
    self:setObjectVisible("key_num_img", false)
    self:setObjectVisible("prepare_food_btn", self.m_model.m_actives.open_status == 1)
    self:setObjectVisible("prepare_food_btn_new_year", self.m_model.m_actives.open_status == 1)
    self:updateRewardUI()
    self:refreshRedPoint()
end

--刷新礼包视图
function M:refreshGiftView( index, data )
    if data ~= nil then
        --礼包id
        local gift_id = data.gift_id;
        if index == 3 then gift_id = 2 end
        --次数
        local times = data.times;
        local dinner_gift = ConfigManager:getCfgByName("dinner_gift")
        local version_gift = dinner_gift[self.m_model.version];
        local gift_item = nil;
        if version_gift ~= nil then
            local day_gift = version_gift[self.m_model.day];
            if day_gift ~= nil then
                local index_gift = day_gift[index];
                if index_gift ~= nil then
                    gift_item = index_gift[gift_id];
                end
            end
        end
        if gift_item == nil then
            self:hideGiftView(index)
        else
            self:refreshGiftViewByConfig(index,times,gift_item)
        end
    else
        for i = 1, 3 do
            self:hideGiftView(i)
        end
    end
end

--通过配置数据刷新gift 视图 
function M:refreshGiftViewByConfig(index, times, data)
    local gift_view = self.gift_views[index];
    if not IsNull(gift_view.score_text) then
        gift_view.score_text.text = Language:getTextByKey("new_str_1082", data.score);
    end
    if not IsNull(gift_view.title_text) then
        gift_view.title_text.text = data.name;
    end
    if not IsNull(gift_view.buy_btn_text) then
        if data.price == 0 then
            gift_view.buy_btn_text.text = Language:getTextByKey("doubleFestival_text_0027");
        else
            if data.sort == 1 then
                gift_view.buy_btn_text.text = data.price..Language:getTextByKey("jubaoShan_str_017");
            else
                gift_view.buy_btn_text.text = GameUtil:getMoneyTypeNum(data.price);
            end
         
        end
    end
    if not IsNull(gift_view.buy_btn) then
        if data.time_limit > 0 then
            gift_view.buy_btn.interactable = (data.time_limit - times) > 0
        else
            gift_view.buy_btn.interactable = true
        end
    end
    if not IsNull(gift_view.buy_btn_img) then
        if data.time_limit > 0 then
            if (data.time_limit - times) > 0 then
                gift_view.buy_btn_img.material = nil;
            else
                gift_view.buy_btn_img.material = self.hui.material;
            end
        else
            gift_view.buy_btn_img.material = nil;
        end
    end
    if not IsNull(gift_view.caiIcon) then
        gift_view.caiIcon.sprite = ResourceUtil:GetSprite(data.background,"item_icon");
    end
    gift_view.caiIcon:SetNativeSize()
    --UIUtil.setLocalScale(gift_view.caiIcon.transform, 1.5, 1.5)
    for i, v in ipairs(data.reward) do
        local itemNode = gift_view.itemNodes[i];
        if not IsNull(itemNode) then
            GameUtil:updateItemElement(itemNode, v,true, true);
        end
    end
end


--隐藏gift视图
function M:hideGiftView( index )
    local gift_view = self.gift_views[index];
    if not IsNull(gift_view.mainObj) then
        gift_view.mainObj:SetActive(false);
    end
end


function M:hideHeroObjs( index, bl, data )
    --隐藏所有
    if index == -1 then
        for i, v in ipairs(self.hero_obj) do
            v:SetActive(bl);
        end
    else
        if index < #self.hero_obj then
            self.hero_obj[index]:SetActive(bl);
            self:refreshHeroObj(index, data)
        else
            Logger.logError(" 无效的 index "..index );
        end
    end
end

-- 刷新英雄数据
function M:refreshHeroObj( index, data )
    local jifen_txt = self:findText("jifen_0"..index)
    local player_name_txt = self:findText("player_name_0"..index)
    jifen_txt.text = Language:getTextByKey("new_str_1082", data.score);
    player_name_txt.text = data.user.name;
end

-- 切换界面
-- 0 是聚会
-- 1 是备菜
function M:switchPanel( mode )
    local bl = mode == 1;
    self:setObjectVisible("selectRewards", bl)
    self:setObjectVisible("herosPanel", not bl)
end

-- 进入播放语音
function M:talk( id )
    local dinner_voice = ConfigManager:getCfgByName("dinner_voice");
    local item = dinner_voice[id];
    if item ~= nil then
        self:talkView(item)
    end
end

-- 显示talk
function M:showTalk()
    if self.m_player_talk_isShow == false then
        self.m_player_talk_isShow = true;
        self.m_player_talk_anim.duration = 0.5;
        self.m_player_talk_anim.endValueFloat = 1
        self.m_player_talk_anim.easeType = CS.DG.Tweening.Ease.OutBack;
        self.m_player_talk_anim:CreateTween();
        self.m_player_talk_anim.tween:Play();
    end
end

-- 隐藏talk
function M:hideTalk()
    if self.m_player_talk_isShow == true then
        self.m_player_talk_isShow = false
        self.m_player_talk_anim.duration = 0.5;
        self.m_player_talk_anim.endValueFloat = 0
        self.m_player_talk_anim.easeType = CS.DG.Tweening.Ease.InBack;
        self.m_player_talk_anim:CreateTween();
        self.m_player_talk_anim.tween:Play();
    end
end

-- 阿闲说话
function M:talkView(cfg)
    if cfg.words ~= "" then
        self:showTalk();
        self:setTextByLanKey("talk_text", cfg.words)
        self.m_control:setOnceTimer(3, handler(self,self.hideTalk))
    end

    if cfg.bank ~= "" and cfg.vo ~= "" then
        --播放声音
        self.bank = cfg.bank
        ResourceUtil:LoadRoleSound(cfg.bank)
        audio:StopPlayingID(self.cur_cv)
        self.cur_cv = audio:SendEvtUI(cfg.vo)
    end

    --随机播放一个动作
    --local action_index = math.random(1,#self.m_axian_actions)
    --local action_name = self.m_axian_actions[action_index]
    --self:setAnim(action_name)
end

-- 创建阿闲
function M:creatRole3D()
    --if self.isCreateAXian == false then
    --    ResourceUtil:LoadRole3dAsync("A_Xian/A_Xian", self.role_parent, function(obj)
    --        self.anim = obj:GetComponent("Animator")
    --        self.xian_con = obj:GetComponent(typeof(CS.XianControll))
    --        obj.transform:SetParent(self.role_parent.transform, false)
    --        obj.transform.localPosition = Vector3(0,0,0);
    --        obj.transform.localRotation = Quaternion.Euler(0,0,0);
    --        obj.transform.localScale = Vector3(1, 1, 1);
    --        if self.action_cache[1] ~= nil then
    --            self:setAnim(self.action_cache[1])
    --            self.action_cache[1] = nil;
    --        end
    --    end, true)
    --    self.isCreateAXian = true;
    --end
end

-- 设定阿闲动画
function M:setAnim(name)
    if self.xian_con then
        self.xian_con:CrossFadeInFixedTime(name,0.1)
    else
        self.action_cache[1] = name;
    end
end

--刷新档位奖励
function M:updateRewardUI()
    local reward_cfg, need_score = self.m_model:getGradeRewards()
    local reward_node = self.current_mode == 0 and self:findGameObject("reward_node") or self:findGameObject("reward_node_new_year")
    local reward_tip_txt = self.current_mode == 0 and "reward_tip_txt" or "reward_tip_txt_new_year"
    if reward_cfg then
        GameUtil:createRewards(reward_node.transform, reward_cfg.data.reward, true, true,nil,0.8)
    end
    if need_score then
        self:setTextByLanKey(reward_tip_txt, "new_year_str_002", need_score)
        if need_score > 0 then
            self:setObjectVisible("reward_tip", true)
        else
            self:setObjectVisible("reward_tip", false)
        end
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    local time_text = self.current_mode == 0 and "time_text" or "time_text_new_year"
    if down_time >= 0 then
        local text = GameUtil:formatTimeBySecond(down_time)
        self:setTextByLanKey(time_text,"new_year_str_004", text)
    else
        self:setObjectVisible("time_img",false)
        local end_ts = self.m_model:getActiveEndTs()
        local down_time = end_ts - UserDataManager:getServerTime()
        if down_time >= 0 then
            self:updateMsg("update_end_ts")
        else
            self:updateMsg(99999)
        end
    end
end

function M:refreshRedPoint()
    self:setObjectVisible("jifen_red_point", self.m_model:getMilestoneDinner() == true)
    self:setObjectVisible("jifen_red_point_new_year", self.m_model:getMilestoneDinner() == true)
    self:setObjectVisible("prepare_food_red_point", self.m_model:getFreeDinner() == true or self.m_model:getDiamondDinner() == true)
    self:setObjectVisible("prepare_food_red_point_new_year", self.m_model:getFreeDinner() == true or self.m_model:getDiamondDinner() == true)
end


function M:destroy()
    if self.isCreateAXian then
        local a_xian_ab = "role3d_a_xian"
        ResourceUtil:UnLoadBundle(a_xian_ab, false)
        self.isCreateAXian = false
    end
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = nil
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M