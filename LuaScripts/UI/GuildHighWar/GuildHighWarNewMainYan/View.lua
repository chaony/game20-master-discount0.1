local M = class("GuildHighWarNewMainYanView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarNewMainYan"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local PLAYOFF_TYPE = {
    [1] = {name = "guild_high_war_new_007"},
    [2] = {name = "guild_high_war_new_008"},
    [3] = {name = "guild_high_war_new_009"},
    [4] = {name = "guild_high_war_new_0010"},
    [5] = {name = "guild_high_war_new_0016"},
}
local GHW_STAGW = {
    [1] = {name = "guild_high_war_new_0022"},
    [2] = {name = "guild_high_war_new_0023"},
    [3] = {name = "guild_high_war_new_0024"},
    [4] = {name = "guild_high_war_new_0025"},
    [5] = {name = "guild_high_war_new_0026"},
    [6] = {name = "guild_high_war_new_0024"},
    [7] = {name = "guild_high_war_new_0027"},
    [8] = {name = "guild_high_war_new_0022"},
    [9] = {name = "guild_high_war_new_0023"},
}
local REWARD_TYPE = {
    [2] = {name = "guild_high_war_new_0019"},
    [4] = {name = "guild_high_war_new_007"},
    [6] = {name = "guild_high_war_new_008"},
    [8] = {name = "guild_high_war_new_009"},
    [10] = {name = "guild_high_war_new_0010"},
}
local BIG_STAGE = {
    [1] = {name = "guild_high_war_text_00111"},
    [2] = {name = "guild_high_war_text_00109"},
    [3] = {name = "guild_high_war_text_00110"},
}
function M:onEnter()
    --self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
    self.grayImage = self:findImage("grayImage")
    self:setTextByLanKey("close_title_text", "guild_high_war_new_001")
    self:setTextByLanKey("array_btn_text", "guild_high_war_new_0037") --商店
    self:setTextByLanKey("report_btn_text", "guild_high_war_new_005")
    self:setTextByLanKey("guess_btn_text", "guild_high_war_new_004")
    self:setTextByLanKey("rank_btn_text", "guild_high_war_new_0030")
    self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_006")
    self:setTextByLanKey("reward_preview_text", "guild_high_war_text_00108")
    self:setTextByLanKey("title_txt1", "guild_high_war_yan_text_0034")
    self:setTextByLanKey("title_txt2", "guild_high_war_yan_text_0035")
    self:setTextByLanKey("title_txt3", "guild_high_war_yan_text_0036")
    self:setTextByLanKey("title_txt4", "guild_high_war_yan_text_0037")
    self:setTextByLanKey("title_txt5", "guild_high_war_yan_text_0038")
    self:setTextByLanKey("title_txt6", "guild_high_war_yan_text_0039")
    self:setTextByLanKey("vedio_btn_text", "guild_high_war_yan_text_0040")
    self:checkAndPlayVideo(false)
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
    self:updateLoopScroll()
    self:updateActivityTimer()
    self:UpdateShareView()
end

function M:refreshRedPoint()
    self:setObjectVisible("guess_red_point", self.m_model:checkGuessRedPoint())
end
--HuashanSwordTop3 a_hslj_pmzs_1
function M:setBottomUI()
    if self.m_model:checkOpenType() == false or self.m_model:checkHasData() == false then
        self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0046"))
        self:setTextByLanKey("down_time_des_text", Language:getTextByKey("peak_str_0060"))
    elseif self.m_model.m_data.week and self.m_model.m_data.week > 7 then
        self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0065"))
        self:setTextByLanKey("down_time_des_text", self.m_model:getSeasonTime())
    else
        self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0011")..self.m_model:getCurBattleStatus())
        self:setTextByLanKey("down_time_des_text", self.m_model:getSeasonTime())
    end
    self:setTextByLanKey("last_des_text", Language:getTextByKey("peak_str_0012")..self.m_model:getPreRank())
    self:setTextByLanKey("history_des_text", Language:getTextByKey("peak_str_0013")..self.m_model:getBestRank())
end




--------------------左侧按钮
-------------------巅峰帮会奖励
function M:updateListTopScroll()
    local data = self.m_model:getRewardData(self.m_model.m_reward_type)
    if self.m_top_list_scroll == nil then
        local list_scroll = self:findGameObject("top_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:listHandle(cell_object, index, cell_data, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, cell_data)
            end
        }
        self.m_top_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_top_list_scroll:reloadData(data)
    end
end

function M:listHandle(obj, id, data, is_top)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_text", data.rank)
    if #data.rank == 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_txt", data.rank[1])
    elseif #data.rank >= 2 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_txt", data.rank[1].." - "..data.rank[2])
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_txt", "0")
    end
    local reward_node = luaBehaviour:FindGameObject("reward_node")
    GameUtil:createRewards(reward_node.transform, data.reward, true, true)
end

function M:updateActivityTimer()
    --, 1:报名, 2:常规赛, 3:季后赛, 4:展示期
    self:setObjectVisible("Image2",false)
    self:setObjectVisible("Image1",false)
    if self.m_model.big_stage == 1 then
        self:setTextByLanKey("title_txt_1","guild_high_war_new_0011")
        self:setObjectVisible("Image2",true)
    elseif self.m_model.big_stage == 2 then
        self:setObjectVisible("Image2",true)
        --self:setObjectVisible("Image2",true)
        local end_ts = self.m_model:getEndTs()
        self:setTextByLanKey("title_txt_1","guild_high_war_new_0012",self.m_model.cycle)
        self:setTextByLanKey("title_txt_2","guild_high_war_new_0013",self.m_model.round_id.."/"..self.m_model.all_round_id)
        self:setTextByLanKey("title_txt_3",GHW_STAGW[self.m_model.ghw_stage].name,GameUtil:formatTimeBySecond2(end_ts))
    elseif self.m_model.big_stage == 3 then
        self:setObjectVisible("Image2",true)
        --self:setObjectVisible("Image2",true)
        local end_ts = self.m_model:getEndTs()
        if self.m_model.playoff_type == 0 then
            self:setTextByLanKey("title_txt_1","guild_high_war_new_0045")
        elseif self.m_model.playoff_type > 0 then
            self:setTextByLanKey("title_txt_1",Language:getTextByKey(PLAYOFF_TYPE[self.m_model.playoff_type].name)..string.format(Language:getTextByKey("guild_high_war_new_0015"),self.m_model.cycle))
        end
        self:setTextByLanKey("title_txt_2","guild_high_war_new_0013",self.m_model.round_id.."/"..self.m_model.all_round_id)
        self:setTextByLanKey("title_txt_3",GHW_STAGW[self.m_model.ghw_stage].name,GameUtil:formatTimeBySecond2(end_ts))
    elseif self.m_model.big_stage== 4 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
        self:updateMsg(99999)
        self:updateMsg("new_close_btn",nil,"UnionWar")
        return
    end
    self:setTextByLanKey("scroll_title_text1", "guild_high_war_new_002",Language:getTextByKey(REWARD_TYPE[self.m_model.m_reward_type].name))
    self:setTextByLanKey("title_txt_4",Language:getTextByKey(REWARD_TYPE[self.m_model.m_reward_type].name))

    if self.m_model.ghw_stage == GlobalConfig.SERVER_GHW_STAGE.AFTER_BATTLE then --战斗结束阶段 把门干掉
        self:setObjectVisible("UI_GuildHighWar_Men_Loop",false)
    else
        self:setObjectVisible("UI_GuildHighWar_Men_Loop",true)
    end
    --状态切换
    local end_ts = self.m_model:getCycleEndTs()
    if end_ts <=0  then --战斗阶段
        if self.m_model.is_can_updata == false then
            self.m_model.is_can_updata = true
            self:updateMsg("update_stage",nil,"GuildHighWar.GuildHighWarNewMainYan")
        end
    else
        local cycle_ts = self.m_model:getEndTs()
        if cycle_ts <= 0 and (self.m_model.big_stage ==2 or self.m_model.big_stage ==3) then
            if self.m_model.is_can_updata == false then
                self.m_model.is_can_updata = true
                self:updateMsg("update_stage",nil,"GuildHighWar.GuildHighWarNewMainYan")
            end
        end
    end
    self:updateProgressNewSlider()
    self:updateButtonstage()
end

function M:updateButtonstage()
    if self.m_model.is_sign_up == 0 then --未报名
        self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0017")
        self:setObjectVisible("UI_GuildHighWar_Men_Loop",false)
        self:setObjectVisible("peak_game_btn",true)
    else --已经报名
        local buy_img = self:findImage("peak_game_btn")
        buy_img.material = nil
        if self.m_model.is_condition == 0 or self.m_model.big_stage == 1 then
            self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0018")
            buy_img.material = self.grayImage.material
            self:setObjectVisible("UI_GuildHighWar_Men_Loop",false)
            self:setObjectVisible("peak_game_btn",true)
        elseif self.m_model.big_stage == 2 then
            --self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0020",Language:getTextByKey("guild_high_war_new_0019"))
            self:setObjectVisible("UI_GuildHighWar_Men_Loop",true)
            self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0038")
            self:setObjectVisible("peak_game_btn",false)
        elseif self.m_model.big_stage == 3 then
            --self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0020",Language:getTextByKey(PLAYOFF_TYPE[self.m_model.playoff_type].name))
            self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0038")
            self:setObjectVisible("UI_GuildHighWar_Men_Loop",true)
            self:setObjectVisible("peak_game_btn",false)
        end
    end
end


--里程碑
function M:updateProgressSlider()
    local box_node = self:findGameObject("progress_box_node")
    local progress_slider = self:findSlider("progress_slider")
    local box_node_rtrans = UIUtil.findRectTransform(box_node)
    local box_node_trans = box_node.transform
    UIUtil.destroyAllChild(box_node_trans)
    
    local show_data, cur_num = self.m_model:getProgressData()
    local width = box_node_rtrans.rect.width
    local max_num = 0
    local box_num = #show_data
    if show_data[box_num] then
        max_num = show_data[box_num].score
    end
    max_num = max_num > 0 and max_num or 100
    progress_slider.value = cur_num / max_num
    for i = 1, box_num do
        local data = show_data[i]
        local task_box = GameUtil:createPrefab("GuJianQiTan/GuJianQiTanDrawBox", box_node_trans)
        local transform = task_box.transform
        --UIUtil.setLocalScale(transform, 0.7, 0.7, 1.0)
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        UIUtil.setLocalPosition(task_box, width * data.score / max_num - width * 0.5, 0)
        local function btns(trans,params)
            if data.status == 1 then 
                self:updateMsg("box_reward", {click_transform = trans, data = data}) -- 可领取
            else
                self:updateMsg("box_click", {click_transform = trans, data = data}) -- 展示
            end
        end
        UIUtil.setButtonClick(transform, btns, i)
        UIUtil.setText(transform, tostring(data.score), "score_text")
        UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
        
        local reward_cfg = RewardUtil:getProcessRewardData(data.reward)
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[reward_cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        LuaBehaviourUtil.setImg(luaBehaviour, "box_bg", quality_item.frame_name, "equip_icon")
        LuaBehaviourUtil.setImg(luaBehaviour, "box_img", reward_cfg.icon_name, reward_cfg.atlas_name)
        --local box_img = luaBehaviour:FindImage("box_img")
        --box_img:SetNativeSize()
        --local box_bg = luaBehaviour:FindImage("box_bg")
        --box_bg:SetNativeSize()
        
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",data.status == 2)
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", data.status == 1)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 1)
    end
end

--里程碑
function M:updateProgressNewSlider()
    if self.m_model.big_stage == 1 then
        self:setObjectVisible("progress_node",false)
        self:setObjectVisible("Image2",false)
        return
    else
        self:setObjectVisible("Image2",true)
    end
    self:setObjectVisible("progress_node",true)
    local index = 1
    for k,v in ipairs(self.m_model.big_stage_list) do
        if v.type == self.m_model.big_stage and v.cycle == self.m_model.cycle then
            index = v.curIndex
            self:setImg("a_dfbhz_wenzidida", "maze_stage_ui", "progress_mage" .. k)
        else
            self:setImg("a_dfbhz_wenzidixiao", "maze_stage_ui", "progress_mage" .. k)
        end
        local title_img = self:findImage("progress_mage" .. k)
        title_img:SetNativeSize()
        self:setTextByLanKey("progress_mage_text"..k,BIG_STAGE[v.type].name)
        self:setTextByLanKey("progress_mage_text"..k..k,"guild_high_war_text_00112", v.cycle)
    end
    local cur_num = self.m_model:getCycleEndTs()
    local max_num = self.m_model:getCycleAllTs()
    local progress_slider = self:findSlider("progress_slider")
    --Logger.logError("cur:   "..cur_num.."     ".."all:   "..max_num.."  ".."fen:   "..(max_num-cur_num) / max_num)
    progress_slider.value = ((max_num-cur_num)/max_num + (index-1)) / #self.m_model.big_stage_list
end
--[[
	奖励显示
]]
function M:updateLoopScroll()
    self.m_click_cell_object = nil
    local data = self.m_model.m_new_reward_data
    self:setObjectVisible("CommonTipsNode", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("reward_preview_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            one_line_count = 2, -- 行或列的数量
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --local status = cell_data.status
                --if status ~= -1 then
                --    self:updateMsg(status == 2 and "main_reward" or "goto_btn", cell_data)
                --    self.m_click_cell_object = cell_object
                --end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    if cell_data.hero == 1 then
        --大奖
        local lua_behaviour = cell_object:GetComponent("LuaBehaviour")
        if lua_behaviour ~= nil then
            LuaBehaviourUtil.setObjectVisible(lua_behaviour,"UI_Reward_LingQu_003",true)
        end
    end
    GameUtil:updateItemElement(cell_object, cell_data, true, true)
end
function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end
--创建门特效
function M:CreateMenEnd()
    local nodeObj = self:findGameObject("men_spine_end")
    UIUtil.destroyAllChild(nodeObj.transform)
    local eqp_effect2 = ResourceUtil:GetUIEffectItem("GuildHighWar/UI_GuildHighWar_Men_End", nodeObj)
end
--删除门特效
function M:ClearMenEnd()
    local nodeObj = self:findGameObject("men_spine_end")
    UIUtil.destroyAllChild(nodeObj.transform)
end

function M:UpdateShareView()
    self:setObjectVisible("get_day_btn",false)
    --self:setObjectVisible("get_day_btn",self.m_model.is_share == 0)
    self:setObjectVisible("vedio_btn",self.m_model.is_share ~= 0)
end

function M:UpdateShareBg(flag)
    self:setObjectVisible("CommonFullBg",flag)
    self:setObjectVisible("big_bg_img",flag)
    self:setObjectVisible("content_node",flag)
    self:setObjectVisible("big_bg_fenxiang",flag == false)
end

--检测播放视频
function M:checkAndPlayVideo(flag)
    local isCompareSwordVideoPlay = UserDataManager.local_data:getLocalDataByKey("GuildHighWarNewMainPlay")
    if isCompareSwordVideoPlay == 1 and flag == false then
       return
    end
    self:playerVideo()
end

function M:playerVideo()
    self:lockTouch()
    audio:PauseMusicBusVol()
    --self.sound_id = audio:SendEvtUI("")
    local model = self.m_model
    self.m_control:openView("Pops.VedioPlayerPop", {
        callback = function()
            if self.sound_id then
                --audio:StopPlayingID(self.sound_id)
            end
            audio:ResumeMusicBusVol()
            UserDataManager.local_data:setLocalDataByKey("GuildHighWarNewMainPlay" , 1)
            self:unlockTouch()
        end, vedio_name = "guild_high_war.mp4" , no_close_btn = false, close_btn_type = 1	--todo:视频名称
    })
end

return M


