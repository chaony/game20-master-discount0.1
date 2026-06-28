local M = class("HotelHallControl", LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    self.m_guide_file_name = "UI.Hotel.HotelHall.Guide"
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_new_btn" then -- 关闭
        if self.m_view.m_cur_node ~= nil then
            self.m_view:closeNode()
            return
        end
        self:closeView()
    elseif msg == "help_btn" then
        local desc = Language:getTextByKey("tid#RestaurantDescription_101")
        local params = {title = "lakes_love_text_006", content = desc}
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "room_btn_1" then
        self:openRoomDetail(1)
    elseif msg == "room_btn_2" then
        self:openRoomDetail(2)
    elseif msg == "room_btn_3" then
        self:openRoomDetail(3)
    elseif msg == "run_btn" then
        self:requestRun()
    elseif msg == "quest_btn" then
        self:requestQuestSubmit()
    elseif msg == "open_upgrade_btn" then
        local room_id = self.m_model.m_select_room
        local cur_cfg, next_cfg = self.m_model:isCanRoomUpgrade(room_id)
        if next_cfg == nil then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_020"), delay_close = 2})
            return
        end
        self.m_view:openNode(1)
    elseif msg == "upgrade_btn" then
        self:requestRoomUpgrade(self.m_model.m_select_room)
    elseif msg == "open_hero_btn" then
        self.m_view:openNode(2)
    elseif msg == "down_hero" then --撤下房间里的侠客
        self.m_up_hero_index = 0
        local heroes = self.m_model.m_select_room_heroes
        heroes[data.index] = ""
        self:requestRoomDispatch(self.m_model.m_select_room, heroes)
    elseif msg == "up_hero" then --放入侠客至房间
        local isUnique = self.m_model:isUniqueHeroInRoom(self.m_model.m_select_room, data.oid)
        if isUnique == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_035"), delay_close = 2})
            return
        end
        local heroes = self.m_model.m_select_room_heroes
        for i = 1, #heroes do
            if heroes[i] == "" then
                heroes[i] = data.oid
                self:requestRoomDispatch(self.m_model.m_select_room, heroes)
                self.m_up_hero_index = i
                return
            end
        end
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_023", 3), delay_close = 2})
    elseif msg == "check_flag" then --选择已经放入房间的侠客
        --判断是否重复
        local isUnique = self.m_model:isUniqueHeroInRoom(self.m_model.m_select_room, data.oid)
        if isUnique == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_035"), delay_close = 2})
            return
        end
        --判断是否满了
        local is_full = true
        local heroes = self.m_model.m_select_room_heroes
        for i = 1, #heroes do
            if heroes[i] == "" then
                is_full = false
                self.m_up_hero_index = i
                break
            end
        end
        if is_full == true then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_023", 3), delay_close = 2})
            return
        end
        --二次确认
        local old_room, old_room_id = self.m_model:heroInRoom(data.oid)
        local new_room = self.m_model:getSelectRoom()
        local params = {
            text = Language:getTextByKey("hotel_text_036", old_room.name, new_room.name),
            tow_close_btn = true,
            on_ok_call = function ()
                self:requestRoomReplace(old_room_id, self.m_model.m_select_room, data.oid)
            end
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "play_gain" then --播放经营获得效果
        self.m_view:playGain(data)
    end
end

--显示房间详情
function M:openRoomDetail(room_id)
    if self.m_model.m_select_room == room_id then
        return
    end
    local room = self.m_model.m_rooms[room_id]
    --未解锁不能选中
    if room.unlock_run_num > self.m_model.m_his_run_times then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_034"), delay_close = 2})
        return
    end
    self.m_model:setSelectRoom(room_id)
    self.m_view:refreshRoomDetail(room_id, true)
    --self.m_view:playRoomUpgrade(room_id)
end

--经营协议
function M:requestRun()
    local params = {}
    self.m_model:getNetData("hotel_run", params, function(response)
        if response then
            self.m_model:updateRun(response)
            local unlock_room, unlock_room_id = self.m_model:getUnLockRoom() --获得解锁房间
            local unlock_room_name = unlock_room and unlock_room.name or nil
            self:openView("Hotel.HotelRunGain", {hotel_level = self.m_model.m_hotel_level, outputs = response.outputs, spine_res = self.m_model.m_spine_res, unlock = unlock_room_name})
            self.m_view:refreshUI() --刷新经营次数、房间的解锁、任务的进度
            self:updateMsg("update_times", {times = response.lave_daily_run_num, his_coin = response.his_coin, his_run_times = response.his_run_num}, "Hotel")--刷新首页酒楼运营次数和历史累计获得
            if unlock_room ~= nil then --房间解锁时也得检查抽卡是否开启
                self:updateMsg("update_room_lv", {room_id = unlock_room_id, room_lv = 1}, "Hotel") --向主页同步房间等级，为抽卡入口解锁
            end
        end
    end, nil, nil, nil)
end

--交任务
function M:requestQuestSubmit()
    local params = {quest = self.m_model.m_quest.id}
    self.m_model:getNetData("hotel_submit_quest", params, function(response)
        if response then
            if response.reward ~= nil then
                local reward = RewardUtil:mergeRewardAndFormat(response.reward)
                RewardUtil:rewardTipsByRewards(reward)
            end
            self:setOnceTimer(1.0, function ()
                self.m_model:updateQuest(response.quests)
                self.m_view:refreshQuest()
            end)
        end
    end, nil, nil, nil)
end

--升级
function M:requestRoomUpgrade(id)
    local params = {room = id}
    self.m_model:getNetData("hotel_room_level_up", params, function(response)
        if response then
            self.m_model:updateRoomUpgrade(response.room, response.level) --同步房间等级，并根据三个房间的最低等级决定酒楼等级
            self:updateMsg("update_room_lv", {room_id = response.room, room_lv = response.level}, "Hotel") --向主页同步房间等级，为抽卡入口解锁
            if response.quests ~= nil then
                self.m_model:updateQuest(response.quests) --同步任务
            end
            self:updateMsg("close_new_btn") --关闭升级node
            self:setOnceTimer(0.5, function ()
                --飘字
                local room = self.m_model:getSelectRoom()
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_028", room.name, response.level), delay_close = 2})
                --升级效果顺序展示
                --1、大厅左侧等级评级变更效果
                --2、右侧属性光标移动
                --3、如果酒楼等级提升且背景变更，关闭大厅界面，播放酒楼升级效果
                self.m_view:playRoomUpgrade(response.room) --播放某个房间等级提升特效
                --self.m_view:refreshUI() --刷新任务、房间的评级、房间的属性、背景
            end)
            self:setOnceTimer(3, function ()
                self:updateMsg("update_level", self.m_model.m_hotel_level, "Hotel") --刷新首页酒楼等级，并根据酒楼等级确定场景是否更换
            end)
        end
    end, nil, nil, nil)
end

--更替房间侠客
function M:requestRoomDispatch(id, heroes, callfunc)
    local params = {room = id, h_oid = heroes}
    self.m_model:getNetData("hotel_room_dispatch", params, function(response)
        if response then
            if callfunc then
                callfunc()
            else
                self.m_select_room_heroes = response.h_oid
                self.m_model:updateRoomHero(response.room, response.h_oid)
                self.m_view:playRoomHeroDispatch(self.m_up_hero_index) --播放侠客放入房间特效
                self.m_view:refreshNode() --刷新列表
                self.m_view:refreshUI() --刷新房间的评级
            end
        end
    end, nil, nil, nil)
end

--其他房间的侠客放入新房间
function M:requestRoomReplace(old_room_id, new_room_id, oid)
    --侠客从老房间下来后，再放入新的房间
    local function callback()
        local new_room = self.m_model.m_rooms[new_room_id]
        local heroes = new_room.heroes
        for i = 1, #heroes do
            if heroes[i] == "" then
                heroes[i] = oid
                self:requestRoomDispatch(self.m_model.m_select_room, heroes)
                break
            end
        end
    end
    --先从老房间下来
    local old_room = self.m_model.m_rooms[old_room_id]
    local heroes = old_room.heroes
    for i = 1, #heroes do
        if heroes[i] == oid then
            heroes[i] = ""
            self:requestRoomDispatch(old_room_id, heroes, callback)
            break
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M