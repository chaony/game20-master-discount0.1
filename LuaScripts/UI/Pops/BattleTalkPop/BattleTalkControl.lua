local M = class("BattleTalkControl")

M.cdTime = GlobalTools.base10
--注册对话列表
function M:registerBattleTalk(mode, talks)
    if self.talk_data == nil then
        self:initCfgData()
    end
    self.cur_talk_list = {}
    for k,v in pairs(talks) do
        if self.talk_data[v] ~= nil then
            if self.talk_data[v].mode == mode then
                self.cur_talk_list[self.talk_data[v].condition] = self.cur_talk_list[self.talk_data[v].condition] or {}
                self.cur_talk_list[self.talk_data[v].condition][v] = {finish = false, data = self.talk_data[v]}
            end
        end
    end
    self.is_open = false
    self.inCdTime = false
    self.stack = LikeOO.OOStack.new()
end

--初始化对话数据
function M:initCfgData()
    self.battle_talk_table = ConfigManager:getCfgByName("legend_random_talk")
    self.talk_data = {}
    for group_id,group_cfg in pairs(self.battle_talk_table) do
        self.talk_data[group_id] = {}
        for id, talk_cfg in pairs(group_cfg) do
            if talk_cfg.before == 0 then
                self.talk_data[group_id].start = id
                self.talk_data[group_id].condition = talk_cfg.condition
                self.talk_data[group_id].condition_param = talk_cfg.param
                self.talk_data[group_id].mode = talk_cfg.battle_type
                self.talk_data[group_id].groups = group_cfg
                self.talk_data[group_id].index = {}
                break
            end
        end
        for id, talk_cfg in pairs(group_cfg) do
            if talk_cfg.before ~= 0 then
                self.talk_data[group_id].index[talk_cfg.before] = id
            end
        end
    end
end

--检测是否满足对话条件
--条件0：战斗开始触发
--条件1：单次技能击杀数量达到条件
--条件2：累计击杀数量达到条件
--条件3：战斗持续时长达到条件
--条件4：布阵界面触发
function M:checkBattleTalk(condition, param)
    local hasTalk = false
    if self.cur_talk_list ~= nil and self.cur_talk_list[condition] ~= nil then
        if condition == 0 or condition == 4 then
            local canRepeat = condition == 0
            for k,v in pairs(self.cur_talk_list[condition]) do
                self:tryStartTalk(v.data, canRepeat)
                hasTalk = true
                break
            end
        else
            if self.inCdTime == false then
                local talks = {}
                for k,v in pairs(self.cur_talk_list[condition]) do
                    if v.finish == false and v.data.condition_param <= param then
                        table.insert(talks, v)
                        --类型1可以反复触发
                        if condition ~= 1 then
                            v.finish = true
                        end
                    end
                end
                if #talks ~= 0 then
                    local id = math.random(1, #talks + 1)
                    local talk = talks[id]
                    if talk then
                        self:tryStartTalk(talk.data, false)
                    end
                    hasTalk = true
                    self.inCdTime = true
                end
            end
        end
    end
    return hasTalk
end

--尝试开启战斗内对话界面
function M:tryStartTalk(cfg, isRepeat)
    local function callBack()
        self.is_open = false
    end
    if self.is_open == false then
        self.is_open = true
        static_rootControl:openView("Pops.BattleTalkPop", {cfg = cfg, isRepeat = isRepeat, callBack = callBack})
    else
        static_rootControl:updateMsg("add_talk", {cfg = cfg, isRepeat = isRepeat, callBack = callBack}, "Pops.BattleTalkPop")
    end
end

function M:pause()
    static_rootControl:updateMsg("pause", {}, "Pops.BattleTalkPop")
end

function M:play()
    static_rootControl:updateMsg("play", {}, "Pops.BattleTalkPop")
end

function M:lastTalkFinish()
    if self.inCdTime == true then
        TimeTools:delayTime(self.cdTime, function()
            self.inCdTime = false
        end)
    end
end

--退出战斗时关闭对话
function M:closeTalk()
    self.is_open = false
    static_rootControl:closeView("Pops.BattleTalkPop")
end

return M
