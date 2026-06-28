local M = class("ServiceJiangHuPopView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceJiangHuPop"
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

--格子的大小
local _CELL_HEIGHT =
{
    [1] = 85,
    [2] = 85,
    [3] = 85,
    [4] = 56,
}

function M:onEnter()
    --设置固定文本
    self:setTextByLanKey("common_title_text",self.m_model.current_data.cfg.name) --标题
    self:setTextByLanKey("name_text_left",self.m_model.current_data.cfg.name) --标题
    self:setTextByLanKey("title_txt","new_str_0830") --开拓排名
    self:setTextByLanKey("common_no_have_text","new_str_0831") --完成上一阶段解锁
    self:setTextByLanKey("text_box","new_str_0080") --已领取
    self:setTextByLanKey("openSever_txt","new_str_0832") --服务器时间
    self:setTextByLanKey("openSever_complete_txt","new_str_0832") --服务器时间
    self:setTextByLanKey("player_info_txt","new_str_0833") --砥砺前行人数
    self:setTextByLanKey("player_info_complete_txt","new_str_0833") --砥砺前行人数
    
    self.server_level = self.m_model.server_level --排名数据
    self.current_data = self.m_model.current_data --配置数据
    self.tip_word = self.m_model.tip_word --提示语
    self:refreshUI()
end

function M:refreshUI()

    --设置左侧位置显示状态
    local commonTipsNods = self:findGameObject("CommonTipsNode")
    local hasInfo = self:findGameObject("hasInfo")
    local commonTipsNods_show = false
    local hasInfo_show = false
    local openSever_complete_txt = self:findGameObject("openSever_complete_txt")
    local player_info_complete_txt = self:findGameObject("player_info_complete_txt")
    local openSever_complete_txt_show = false
    local player_info_complete_txt_show = false
    
    local serverOpenTime_text = 0 --服务器天数比
    local player_Num_text = 0 --前行人数
    local tip_text = 0 --提示语
    --关卡数
    local current_level = self.current_data.stage_id
    --local show_tip_text = 0 --显示的字
    
    --宝箱显示
    local box_Btn = self:findGameObject("box_Btn") --宝箱
    local box_Btn_hui = self:findGameObject("box_Btn_hui") --灰箱
    local box_text = self:findGameObject("text_box") --宝箱来领取文字
    local box_text_bg = self:findGameObject("box_text_bg") --提示背景
    local box_text_bg_show = false
    local box_Btn_hui_show = self.m_model:hasReward(self.current_data.stage_id)
    local box_text_show = self.m_model:hasReward(self.current_data.stage_id)
    local tip_word = Language:getTextByKey(show_tip_text,stage_str) --提示文本
    
    if self.tip_word == 0 then --前人未至
        commonTipsNods_show = true
    elseif self.tip_word == 1 then --一马平川
        hasInfo_show = true
        --serverOpenTime_text = Language:getTextByKey("new_str_0836",self.current_data.cfg.unlock,self.current_data.cfg.unlock) --服务器时间
        serverOpenTime_text = Language:getTextByKey("new_str_0928",self.current_data.cfg.unlock) --服务器时间
        --player_Num_text = Language:getTextByKey("new_str_0839",self.current_data.cfg.unlock_player,self.current_data.cfg.unlock_player ) --闯关人数
        player_Num_text = Language:getTextByKey("new_str_0929",self.current_data.cfg.unlock_player ) --闯关人数
        openSever_complete_txt_show = true
        player_info_complete_txt_show = true
        --show_tip_text = "江湖已经恢复平静%s之前关卡敌人难度正常"
        local stage_str = self:getStageStr(current_level)
        tip_word =  Language:getTextByKey("new_str_0827",stage_str)
        self:setTextByLanKey("text_box","new_str_0080") --以领取
    elseif self.tip_word == 2 then --砥砺前行
        hasInfo_show = true
        --serverOpenTime_text = Language:getTextByKey("new_str_0836",self.m_model.serverOpenTime,self.current_data.cfg.unlock) --服务器时间
        serverOpenTime_text = Language:getTextByKey("new_str_0928",self.current_data.cfg.unlock) --服务器时间
        --player_Num_text = Language:getTextByKey("new_str_0839",self.server_level.pass_count,self.current_data.cfg.unlock_player) --闯关人数
        player_Num_text = Language:getTextByKey("new_str_0929",self.current_data.cfg.unlock_player) --闯关人数
        local stage_str = self:getStageStr(current_level)
        local last_level = self.m_model:getLastLevel(self.current_data.stage_id)
        --Logger.logError(last_level,"上一个id")
        local last_stage_str = self:getStageStr(last_level)
        tip_word =  Language:getTextByKey("new_str_0828",last_stage_str,self.current_data.cfg.unlock,stage_str,self.current_data.cfg.unlock_player) --%s之后敌人难度提升\n服务器开启%s天\n通关%s大侠人数达到%s\n将进入下一阶段
        box_Btn_hui_show = true
        self:setTextByLanKey("text_box","new_str_0837") --完成以上条件可以领取
        box_text_show = true
        box_text_bg_show = true
        if self.m_model.serverOpenTime >= self.current_data.cfg.unlock  then
            openSever_complete_txt_show = true
            player_info_complete_txt_show = true
        end
        if self.server_level.pass_count >= self.current_data.cfg.unlock_player then
            player_info_complete_txt_show = true
        end
    end

    self:setTextByLanKey("desc_info_txt",tip_word)
    
    self:setTextByLanKey("openSever_num_txt",serverOpenTime_text)
    --self:setTextByLanKey("openSever_complete_num_txt",serverOpenTime_text)
    self:setTextByLanKey("openSever_num_txt_lv",self.current_data.cfg.unlock)
    self:setTextByLanKey("openSever_num_txt_red",self.m_model.serverOpenTime)
    
    self:setTextByLanKey("player_num_txt",player_Num_text)
    --self:setTextByLanKey("player_num_complete_txt",player_Num_text)
    self:setTextByLanKey("player_num_txt_lv",self.current_data.cfg.unlock_player)
    self:setTextByLanKey("player_num_txt_red",self.server_level.pass_count)
    local player_info_text = self:findGameObject("player_info_txt")
    if self.current_data.cfg.unlock_player == 0 then --配置通关人数为0时不显示人数
        player_info_text.gameObject:SetActive(false)
    else
        player_info_text.gameObject:SetActive(true)
    end
    
    --设置排行表
    self:updateLoopScroll()

    commonTipsNods.gameObject:SetActive(commonTipsNods_show)
    hasInfo.gameObject:SetActive(hasInfo_show)
    box_Btn_hui.gameObject:SetActive(box_Btn_hui_show)
    box_Btn.gameObject:SetActive(not box_Btn_hui_show)
    --openSever_complete_txt.gameObject:SetActive(openSever_complete_txt_show)
    --player_info_complete_txt.gameObject:SetActive(player_info_complete_txt_show)
    box_text.gameObject:SetActive(box_text_show)
    box_text_bg.gameObject:SetActive(box_text_bg_show)
    
    local openSever_num_txt_lv = self:findGameObject("openSever_num_txt_lv")
    local openSever_num_txt_red = self:findGameObject("openSever_num_txt_red")
    openSever_num_txt_lv.gameObject:SetActive(openSever_complete_txt_show)
    openSever_num_txt_red.gameObject:SetActive(not openSever_complete_txt_show)

    local player_num_txt_lv = self:findGameObject("player_num_txt_lv")
    local player_num_txt_red = self:findGameObject("player_num_txt_red")
    player_num_txt_lv.gameObject:SetActive(player_info_complete_txt_show)
    player_num_txt_red.gameObject:SetActive(not player_info_complete_txt_show)
    
end

--排行榜设置
function M:updateLoopScroll()
    local data = self.m_model:setServerData()
    
    local all_cell_size = {}
    for i,v in ipairs(data) do
        local team_count = i
        if i >= 4 then
            team_count = 4
        end
        all_cell_size[i] = Vector2(560, _CELL_HEIGHT[team_count])
    end
    
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            all_cell_size = all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local luaBehaviour = UIUtil.findLuaBehaviour(transform)
                local bg_Obj = luaBehaviour:FindGameObject("content_bg");
                local bg_rect = bg_Obj.transform:GetComponent('RectTransform')
                local size_value = bg_rect.sizeDelta;
                if self.m_loop_scroll_view ~= nil then
                    all_cell_size = self.m_loop_scroll_view.m_all_cell_size
                end
                size_value.x = all_cell_size[index].x;
                size_value.y = all_cell_size[index].y;
                bg_rect.sizeDelta = size_value;
                transform.sizeDelta = size_value
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("hero_info", {cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

--排名设置回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", index) --排名ID
    local hero_head_show = false
    local top_three_rank_img_show = false
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Gang_text", "bang_hui_n_tex") --名称
    if self.server_level.ranks[index] ~= nil then
        --if index <= 3then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", true) --头像框
            local name_ordinary_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_ordinary_text", cell_data.user.name) --名称
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Gang_ordinary_text", cell_data.user.guild_name) --帮会名称
            local head_node = luaBehaviour:FindGameObject("head_node")
            GameUtil:setUserAvatar(head_node, cell_data.user, false, false,{show_flag = true, scale = 1})

            local title_id = cell_data.user.title
            if title_id and title_id ~= 0 then
                name_ordinary_text.transform.anchoredPosition = Vector3.New(-34, -8, 0)
            else
                name_ordinary_text.transform.anchoredPosition = Vector3.New(-34, 0, 0)
            end
            --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_ordinary_text", "") --4-10名名称
            --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Gang_ordinary_text", "") --4-10名帮会
            hero_head_show = true
        --else
        --    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_ordinary_text", cell_data.user.name) --4-10名名称
        --    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Gang_ordinary_text", cell_data.user.guild_name) --4-10名帮会
        --end
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", false) --头像框
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Gang_text", false) --帮会字
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_ordinary_text", "") --名称
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Gang_ordinary_text", "") --帮会名称
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_ordinary_text", "new_str_0835") --4-10名名称
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Gang_ordinary_text", "") --4-10名帮会
    end
    --设置1,2,3排位图片
    if index == 1 then
        LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img","a_phb_icon_1", "common_ui")
        top_three_rank_img_show = true
    elseif index == 2 then
        LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img","a_phb_icon_2", "common_ui")
        top_three_rank_img_show = true
    elseif index == 3 then
        LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img","a_phb_icon_3", "common_ui")
        top_three_rank_img_show = true
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", false) --头像框
    end


   
    
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tx_mask", hero_head_show)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_rank_img_show)
end

--关卡数获取设置
function M:getStageStr(stage_id)
    local big = math.floor(stage_id/100);
    local small = stage_id - big * 100;
    local stage_str = big.."-"..small;
    return stage_str
end

return M