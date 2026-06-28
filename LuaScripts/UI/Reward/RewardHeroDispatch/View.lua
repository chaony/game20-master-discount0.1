local M = class("RewardHeroDispatchView", LikeOO.OOPopBase)

M.m_uiName = "Reward/RewardHeroDispatchPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local SEND_LIST = {} --槽位缓存 {key = k, obj = hero_item}
local RACE_LIST = {} --需要种族类型缓存 { race = v, iden = false, obj = race_item}

function M:onEnter()
    self.cacheSpineName = ""
    self.m_camp_type = 1
    self.ok_yes = false
    self:setTextByLanKey("common_no_have_text", "当前无满足派遣条件的任务")
    self:createLoopScroll()
end

function M:btnSetActive(dispatchActive, one_keydispatchActive)
    -- self.dispatch:SetActive(dispatchActive)
    -- self.one_keydispatch:SetActive(one_keydispatchActive)
end

function M:refreshUI()
    self:createLoopScroll()
end

function M:updateHeroElement(obj, data, show_add)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local item_img = luaBehaviour:FindGameObject("item_img")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local add_img = luaBehaviour:FindGameObject("add_img")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    item_img:SetActive(false)
    --if is_quality_img == nil then
    local quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", "a_ui_currency_ws_kong", "hero_head_ui")
    -- quality_img.color = Color.New(1,1,1,0.7)
    -- end
    if show_add then
        add_img:SetActive(true)
    else
        add_img:SetActive(false)
    end
    luaBehaviour:RegistButtonClick() -- 重置事件
end

function M:setTaskCell(task, obj)
    self:setTextByLanKey("reward_name", Language:getTextByKey(self.m_model.m_params.cell_data.cfg.name))
    local desc = "悬赏任务描述:"
    desc = desc .. Language:getTextByKey(self.m_model.m_params.cell_data.cfg.text)
    self:setTextByLanKey("reward_desc", desc)
    self:setTextByLanKey("life_time", self.m_model.m_params.lifetime)
    local drop = task.data.reward or {}
    local data = RewardUtil:getProcessRewardData(drop[1])
    --LuaBehaviourUtil.setImg(luaBehaviour, "item_img", data.icon_name, data.atlas_name)
end

--打开英雄列表
function M:openHeroList()
    self:createLoopScroll()
end

--下阵
function M:setSEND_LIST(data_index)
    -- CommonUIUtil:updateHeroElementAdd(SEND_LIST[data_index].obj, nil, true)
    self:updateHeroElement(SEND_LIST[data_index].obj, nil, true)
    local luaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[data_index].obj.transform)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
    RACE_LIST[data_index].iden = false
    self:checkCondition()
    self:createLoopScroll()
end

function M:runAnim()
    self:setObjectVisible("bottom_bg", true)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(self.bottom_obj.transform:DOLocalMoveY(-258, 0.3))
    sequence:SetAutoKill(true)
    local sequence2 = Tweening.DOTween.Sequence()
    sequence2:Append(self.lang_bg.transform:DOLocalMoveY(-138, 0.3))
    sequence2:SetAutoKill(true)
end

--刷新槽位
function M:updateSendList(mask, race_data, send_list)
    for k, v in pairs(send_list) do
        local luaBehaviour = UIUtil.findLuaBehaviour(v.obj.transform)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
    end

    for k, v in pairs(race_data) do
        local data = self.m_model:getSendSlot()
        if data[k] ~= nil then
            local luaBehaviour = UIUtil.findLuaBehaviour(send_list[k].obj.transform)
            local function btns()
                self:updateMsg("check_send_btn", send_list[k].key)
            end
            luaBehaviour:RegistButtonClick(btns)
            local cur_hero_data = UserDataManager.hero_data:getHeroDataById(data[k])
            local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cur_hero_data.id)
            local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cur_hero_data.id, 1, cur_hero_data.oid})
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
            local camp_ = GlobalConfig.TYPE_HERO_RACE[cur_hero_cfg.race]
            local camp_img = LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", camp_.race_icon,  ResourceUtil:getLanAtlas())
            v.iden = true
            self:checkCondition(mask)
        else
            -- CommonUIUtil:updateHeroElementAdd(SEND_LIST[k].obj, nil, false)
            self:updateHeroElement(send_list[k].obj, nil, false)
            v.iden = false
        end
    end
    -- self:createLoopScroll()
end

--检查任务条件是否满足
function M:checkCondition(mask)
    local num = self.m_model:getCurEvoNum(mask) .. "/" .. self.m_model:getNeedEvoNum(mask)
    self:setText("need_num", num)
 --当前需要的特定等级英雄数量
end

function M:switchTeamTabByProCell(is_on, update_key)
    if is_on then
        self:createLoopScroll2(update_key)
    end
end

--英雄列表
function M:createLoopScroll()
    local data = self.m_model.m_quest_list
    if table.nums(data) == 0 then
        self:setObjectVisible("CommonTipsNode", true)
    else
        self:setObjectVisible("CommonTipsNode", false)
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateHeroContent(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "duigou_node" then
                    self:updateMsg("ok_btn", {cell_data = cell_data, obj = cell_object})
                end
            end,
            ui_name = self.m_uiName,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

function M:ok_Handler(data)
    local luaBehaviour = UIUtil.findLuaBehaviour(data.obj)
    local yes = luaBehaviour:FindGameObject("yes")
    local ok_yes = self.m_model:checkQuestState(data.cell_data)
     --任务名字
    if ok_yes == true then
        yes:SetActive(false)
    else
        yes:SetActive(true)
    end
end

--刷新英雄数据
function M:updateHeroContent(obj, cell_data)
    if obj == nil then
        Logger.log("GameUtil fun updateHeroContent obj error！！！")
        return
    end
    local cfg = self.m_model:getBountyCfg(cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local name = luaBehaviour:FindText("offer_name_text")
     --任务名字
    name.text = Language:getTextByKey(cfg.name)
    local ItemNode = luaBehaviour:FindGameObject("ItemNode")
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img_pj")
    local type_img = luaBehaviour:FindGameObject("type_img_reward")
    local value_text = luaBehaviour:FindText("value_text")
    local rw_time_text = luaBehaviour:FindText("rw_time_text")
    quality_up_img:SetActive(false)
    type_img:SetActive(false)
    local drop = cfg.reward or {}
    local data = RewardUtil:getProcessRewardData(drop[1])
    GameUtil:updateItemElementByData(ItemNode, data, true, true)
    LuaBehaviourUtil.setImg(luaBehaviour, "item_img_reward", data.icon_name, data.atlas_name)
    if drop[1][1] == 301 then
        LuaBehaviourUtil.setImg(luaBehaviour, "item_img", "DJ_tongqian", "item_icon")
    end
    local count_text = luaBehaviour:FindText("num_text")
    count_text.text = drop[1][3]
    if cfg.type == 2 then
        LuaBehaviourUtil.setImg(luaBehaviour, "type_img_reward", "a_xuansahng_paiqian_bangpai", "common_ui")
        type_img:SetActive(true)
    elseif cfg.type == 3 or cfg.type == 4 then
        LuaBehaviourUtil.setImg(luaBehaviour, "type_img_reward", "a_xuanshang_paiqian_shitu", "common_ui")
        type_img:SetActive(true)
    end
    local tim = GameUtil:formatTimeBySecond(cfg.duration_time * 60)
    value_text.gameObject:SetActive(true)
    rw_time_text.gameObject:SetActive(true)
    value_text.text = tim
    rw_time_text.text = Language:getTextByKey("new_str_0123")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_bg", true)
    local evo_condition = cfg.evo_condition -- [品质，数量]
    local evo_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo_condition[1]]
    local type_img = self:findImage("type_img")
    if type_img then
        LuaBehaviourUtil.setImg(luaBehaviour, "type_img", evo_data.hero_half_bg, "common_ui")
        LuaBehaviourUtil.setText(luaBehaviour, "need_num", table.nums(cfg.race_condition) .. "/" .. table.nums(cfg.race_condition))
    end
    local ok_yes = self.m_model:checkQuestState(cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "yes", ok_yes == true)
    local star_tab = {}
    local st = luaBehaviour:FindGameObject("star_1")
    st:SetActive(false)
    for i = 1, 6 do
        local st = luaBehaviour:FindGameObject("star_" .. i)
        st:SetActive(false)
        table.insert(star_tab, st)
    end
    for k, v in pairs(star_tab) do
        if cfg.rank >= k then
            local st = luaBehaviour:FindGameObject("str_obj")
            st:SetActive(true)
            v:SetActive(true)
        end
    end
    local dis_data = self.m_model:getBountyData(cell_data)
    local hero_node = luaBehaviour:FindGameObject("hero_node")
    UIUtil.destroyAllChild(hero_node.transform)
    for k, v in pairs(dis_data.self_hero) do
        -- local item = self:createObj(hero_node)
        local data, cfg = self.m_model:getHero(v)
        local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
        -- self:alterData(item, itemData)
        local item = GameUtil:createItemElementByData(itemData)
        item.transform:SetParent(hero_node.transform, false)
    end
    for k, v in pairs(dis_data.team_hero) do
        -- local item = self:createObj(hero_node)
        local data, cfg = self.m_model:getOtherHero(cell_data, v)
        local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
        if itemData.quality == 0 then
            itemData.quality = data.evo
            itemData.oid = nil
        end
        -- self:alterData(item, itemData)
        local item = GameUtil:createItemElementByData(itemData)
        item.transform:SetParent(hero_node.transform, false)
    end
    for k, v in pairs(dis_data.master_hero) do
        -- local item = self:createObj(hero_node)
        local data, cfg = self.m_model:getOtherHero(cell_data, v)
        local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
        itemData.quality = data.evo
        -- self:alterData(item, itemData)
        local item = GameUtil:createItemElementByData(itemData)
        item.transform:SetParent(hero_node.transform, false)
    end
    local grid_race = luaBehaviour:FindGameObject("grid_race")
    RACE_LIST = {}
    UIUtil.destroyAllChild(grid_race.transform)
    for k, v in pairs(cfg.race_condition) do
        local race_item = self:createObj2("BountyMissions/race_item", grid_race)
        local race_data = GlobalConfig.TYPE_HERO_RACE[v]
        UIUtil.setImg(race_item.transform, race_data.big_race_icon,  ResourceUtil:getLanAtlas(), "race_img")
        UIUtil.setScale(race_item.transform, 0.65, 0.65)
        UIUtil.setObjectVisible(race_item.transform, false, "yes")
        table.insert(RACE_LIST, k, {race = v, iden = false, obj = race_item})
    end
end

function M:createObj(parent)
    local obj = ResourceUtil:LoadUIGameObject("BountyMissions/bounty_item", Vector3.zero, parent)
    obj.transform:SetParent(parent.transform, false)
    return obj
end

function M:createObj2(name, parent)
    local obj = ResourceUtil:LoadUIGameObject(name, Vector3.zero, parent)
    obj.transform:SetParent(parent.transform, false)
    return obj
end

function M:alterData(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local item = luaBehaviour:FindGameObject("item_img")
     --任务名字
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour, "item_img", data.icon_name, data.atlas_name or "item_icon")
    item:SetActive(true)
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
    quality_up_img:SetActive(frame.is_add == true)
    if frame.is_add == true then
        LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", frame.add_img, "hero_head_ui")
    end
    LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame.hero_item_frame, "hero_head_ui")
    local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
    end
end

return M
