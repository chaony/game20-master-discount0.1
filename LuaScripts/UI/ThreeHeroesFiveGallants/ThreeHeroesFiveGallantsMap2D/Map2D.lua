local M = class("Map2D",LikeOO.OOUIbase)

M.content = nil

function M:ctor(control, params)
    self.map_id = params.map_id or 101;
    self.isFirst = params.is_first
    self.enter_callback = params.callback
    self.Map2DControl = params.Map2DControl
    self.m_uiName = "ThreeHeroesFiveGallantsMap/Map".. self.map_id;
    self.super.ctor(self, control, params)
end

function M:onCreate()
    self.content = {}
    self.allTask = {}

    self.task_table = ConfigManager:getCfgByName("active_plot_task")
    self.task_team_table = ConfigManager:getCfgByName("active_plot_taskteam")

    self.npc_table = ConfigManager:getCfgByName("active_plot_npc")
    self.map_table = ConfigManager:getCfgByName("active_plot_map")

    --互动物品表
    self.article_table = ConfigManager:getCfgByName("active_plot_article")
    self.article_opt_table = ConfigManager:getCfgByName("active_plot_option")

    self.motherMapId = self:getMotherMapId(self.map_id)

    local tab_cls = CustomRequire("UI.ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMap2D.MapNode")
    self.m_cur_node = tab_cls.new(self.m_control, {Map2DControl = self.Map2DControl, parent = self.m_rootView, map = self})

    self.npcNode = self:setObjectVisible("npc", false)
    self.loopscroll = self:findGameObject("npc_loopscroll")

    if self.m_rt ~= nil then
        
        local map_root = self:findRectTransform("map")
        local npc_root = self:findRectTransform("npc")
        --互动物品根节点
        local article_root = self:findRectTransform("article")
        local scene_bg = self:findRectTransform("scene_bg")

        article_root:SetParent(scene_bg)
        article_root.offsetMin = Vector2.New(0,0)
        article_root.offsetMax = Vector2.New(0,0)
        --local bg_scale = self.m_control.m_view.m_bg_scale or 1
        --UIUtil.setLocalScale(article_root, bg_scale, bg_scale)
        --场景入口刷新名称后先隐藏
        if map_root ~= nil then
            for i = 1, map_root.childCount do
                local child = map_root:GetChild(i - 1)
                local map_id = tonumber(string.split(child.name,"_")[2])
                if self.map_table[map_id] ~= nil then
                    UIUtil.setText(child:GetChild(0), self.map_table[map_id]["name"], "map_text")
                end
                child.gameObject:SetActive(false)
                self.content[child.name] = child.gameObject
            end
        end
        --互动物品直接隐藏
        if article_root ~= nil then
            for i = 1, article_root.childCount do
                local child = article_root:GetChild(i - 1)
                child.gameObject:SetActive(false)
                self.content[child.name] = child.gameObject
            end
        end
    end
    
    --获取当前场景总任务数
    self.eventCount = self.map_table[self.motherMapId].quantity

    self.tasks = {}

    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateHandler})
end

function M:onEnter()
    local article = self:findGameObject("scene_bg")
    GameUtil:updateResourcesImg(article, "Texture/map_plot/"..self.map_table[self.map_id].map_resource)
    self:refreshUI()
end

--服务端消息回调，刷新场景
function M:callback(data)
    self.tasks = {}
    
    self:clearArtTips()
    self.arts = {}
    --self.task_npc = {}
    local scrollData = {}
    
    if data ~= nil then
        local articles_data = data[tostring(self.map_id)]
        if articles_data ~= nil then
            --接任务的npc
            local allTask = articles_data["2"]
            if allTask ~= nil then
                for k,v in pairs(allTask) do
                    if v ~= nil and v["status"] == 1 then
                        if self.tasks[tonumber(k)] == nil then
                            table.insert(scrollData, tonumber(k))
                        end
                        self.tasks[tonumber(k)] = {task_list = v.task_list or {}}
                    end
                end
            end

            allTask = articles_data["4"]
            if allTask ~= nil then
                for k,v in pairs(allTask) do
                    if v ~= nil and v["status"] == 1 then
                        if self.tasks[tonumber(k)] == nil then
                            table.insert(scrollData, tonumber(k))
                        end
                        self.tasks[tonumber(k)] = {art_type = 4, status = 1, article_id = v["cid"], choice = v.choice or {}}
                        if v["choice"] ~= nil then
                            table.sort(self.tasks[tonumber(k)].choice, function(a, b) return a< b end)
                        end
                    end
                end
            end

            allTask = articles_data["5"]
            if allTask ~= nil then
                for k,v in pairs(allTask) do
                    if v ~= nil and v["status"] == 1 then
                        self.arts[tonumber(k)] = {team_id = v.team_id, status = v["status"], art_type = 5, choice = v["choice"], interacted = v["interacted"]}
                        if v["choice"] ~= nil then
                            table.sort(self.arts[tonumber(k)].choice, function(a, b) return a< b end)
                        end
                    end
                end
            end

            allTask = articles_data["3"]
            if allTask ~= nil then
                for k,v in pairs(allTask) do
                    if v ~= nil and v["status"] == 1 then
                        self.arts[tonumber(k)] = {team_id = v.team_id, status = v["status"], art_type = 3, choice = v["choice"], interacted = v["interacted"]}
                        if v["choice"] ~= nil then
                            table.sort(self.arts[tonumber(k)].choice, function(a, b) return a< b end)
                        end
                    end
                end
            end

            --遍历场景内所有资源，刷新状态
            for k,v in pairs(self.content) do
                if IsNull(v) == false then
                    if string.match(k, "map") ~= nil then --所有都弹
                        local map_id = string.split(k,"_")[2]
                        local show = false
                        if data[tostring(self.map_id)]["1"] ~= nil then
                            local map_data = articles_data["1"][map_id]
                            if map_data ~= nil and map_data["status"] == 1  then
                                show = true
                            end
                        end
                        v:SetActive(show)
                    elseif string.match(k, "article") ~= nil then  --2弹tips 
                        local art_id = tonumber(string.split(k,"_")[2])
                        if self.arts[art_id] ~= nil then
                            v:SetActive(true)
                            local art_data = self.article_table[art_id]
                            local tip = UIUtil.findTrans(v.transform, "tip")
                            if IsNull(tip) == false then
                                local tips_node = ResourceUtil:GetUIItem("Map/art_tips_node", tip.gameObject, "ui_prefabs")
                                self.arts[art_id].tips_node = tips_node
                                local luaBehaviour = tips_node:GetComponent("LuaBehaviour")
                                local rect = tips_node:GetComponent("RectTransform")
                                rect.anchoredPosition3D = Vector3.New(0,0,0)
                                rect.localEulerAngles = Vector3.New(0,0,0)
                                
                                local effectTran = UIUtil.findTrans(v.transform, "effect")
                                if self.arts[art_id].interacted == true or effectTran == nil then
                                    UIUtil.setObjectVisible(v.transform, false, "effect")
                                    if self.arts[art_id].interacted == true and art_data.Narrator_name ~= nil and art_data.Narrator_name ~= "" then
                                        UIUtil.setObjectVisible(tips_node.transform, false, "handle")
                                        if self.article_table[art_id].display_type == 0 or self.article_table[art_id].display_type == 1 then
                                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "map", false)
                                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tips_bg", true)
                                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tips_text", art_data.Narrator_name)
                                        elseif self.article_table[art_id].display_type == 2 then
                                            local map = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "map", true)
                                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tips_bg", false)
                                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "map_text", art_data.Narrator_name)
                                            local fitter = map:GetComponent("ContentImmediate")
                                            fitter:ForceRefreshSize()
                                        end
                                    elseif art_data.Narrator_id ~= "" and art_data.Narrator_id ~= 0 then
                                        UIUtil.setObjectVisible(tips_node.transform, false, "handle")
                                        if self.article_table[art_id].display_type == 0 or self.article_table[art_id].display_type == 1 then
                                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "map", false)
                                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tips_bg", true)
                                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tips_text", art_data.Narrator_id)
                                        elseif self.article_table[art_id].display_type == 2 then
                                            local map = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "map", true)
                                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tips_bg", false)
                                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "map_text", art_data.Narrator_id)
                                            local fitter = map:GetComponent("ContentImmediate")
                                            fitter:ForceRefreshSize()
                                        end
                                    else
                                        UIUtil.setObjectVisible(tips_node.transform, true, "handle")
                                        UIUtil.setObjectVisible(tips_node.transform, false, "tips_bg")
                                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "map", false)
                                    end
                                else
                                    UIUtil.setObjectVisible(v.transform, true, "effect")
                                    UIUtil.setObjectVisible(tips_node.transform, false, "handle")
                                    UIUtil.setObjectVisible(tips_node.transform, false, "tips_bg")
                                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "map", false)
                                end
                            end
                        else
                            v:SetActive(false)
                        end
                    end
                end
            end
        end 
    end
    --处理所有任务
    --allTask = articles_data["999"]
    self.allTask = table.copy(UserDataManager:getTasksActivityData())
    
    if self.allTask ~= nil then
        for k,v in pairs(self.allTask) do
            local task = self.task_table[tonumber(k)]
            if task ~= nil and task.chapter == self.map_id then
                --状态1显示，状态2进行中，状态3待选择显示对应npc和互动物品
                if v ~= nil and (v["status"] == 1 or v["status"] == 2 or (v["status"] == 3 and v["choice"] ~= nil)) then
                    --缓存会显示的任务npc（不同任务对应相同npc时会被覆盖）
                    if self.tasks[task.npc_number] ~= nil then
                        self.tasks[task.npc_number] = {team_id = v["team_id"], art_id = tonumber(k), status = v["status"], choice = v["choice"] }
                        if v["choice"] ~= nil then
                            table.sort(self.tasks[task.npc_number].choice, function(a, b) return a< b end)
                        end
                    end
                end
            end
        end
    end

    table.sort(scrollData, function(a,b) return a < b end)
    if self.m_cur_node then
        self.m_cur_node:updateNpcLoopScroll(scrollData)
    end
end

function M:lookTips( )
    if self.new_Article ~= nil and #self.new_Article > 0  then

        local msg_value = ""
        local article_data ={}
        for k,v in pairs(self.new_Article) do
            local data = self.article_table[v]
            if data.resource_type == 1  then
                if msg_value ~= "" then
                    msg_value = msg_value .. "、"
                end
                msg_value = msg_value .. self.map_table[data.resource_param]["name"]

            elseif data.resource_type == 3 then
                if data.display_type == 2 then
                    if msg_value ~= "" then
                        msg_value = msg_value .. "、"
                    end
                    msg_value = msg_value..data.Narrator_id
                end
            end
        end
        if msg_value ~= "" then
            
            GameUtil:lookInfoTips(static_rootControl, {msg = " <color=#F3A200>"..msg_value.."</color>" ..Language:getTextByKey("worldMap_scene_open"), delay_close = 2})
        end
        
    end
end

function M:newArticle( new_article )
    if new_article ~= nil and #new_article > 0 then
        local article_data =UserDataManager.local_data:getUserDataByKey("bigMap_newArticle_activity", {})
        for k,v in pairs(new_article) do
            local data = self.article_table[v]
            local obj_name = ""
            if data.resource_type == 1  then
                obj_name = "map_"..data.resource_param
            elseif data.resource_type == 3 then
                if data.display_type == 2 then
                    if data.map_id ~= self.map_id then
                        if article_data[tostring(data.map_id)] == nil then
                            article_data[tostring(data.map_id)] = {}
                        end
                        table.insert(article_data[tostring(data.map_id)], data.resource_param)
                        
                    end
                    obj_name = "article_"..data.resource_param
                end
            end
            local obj = self.content[obj_name]
            if IsNull(obj) == false then
                obj.transform.localScale = Vector3(0.8,0.8,0.8)
                local sequence = Tweening.DOTween.Sequence()
                sequence:Append(obj.transform:DOScale(1.2, 0.35))
                sequence:Append(obj.transform:DOScale(1.0, 0.35))
                sequence:SetAutoKill(true)
            end
        end
        
        UserDataManager.local_data:setUserDataByKey("bigMap_newArticle_activity", article_data)
    end
end

function M:onButtonClick(obj, name)
    --进入下级场景
    local index = string.find(name,"map")
    if index ~= nil and index > 0 then
        local jumpto_id = tonumber( string.split(name,"_")[2] )
        self.Map2DControl:openMap2D(jumpto_id)
    end
    
    local function netCallback(response)
        if response then
            self:callback(UserDataManager:getArticlesActivityData())
            if response.cur_done_task ~= nil then
                for k,v in ipairs(response.cur_done_task) do
                    local task = self.task_table[v]
                    if task.type == 3 or task.type == 4 then
                        if task.ending_map ~= 0 then
                            self.Map2DControl:openMap2D(task.ending_map)
                        end
                        --后端自动接跳转选项进入下一步，此处使用选项
                        if task.option_switch == 0 and #task.option_id == 1 then
                            self:optionFinish(v, {id = task.option_id, index = 1}, function()  end)
                        end
                    end
                end
            end
            if response.reward ~= nil then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.new_Article = table.copy(response.new_article)
            self:newArticle(response.new_article)
            --self:lookTips()
        end
    end
    
    --点击npc
    local npcIndex = string.find(name, "npc")
    if npcIndex ~= nil and npcIndex > 0 then
        self.m_control:updateMsg("guide_1")
        local npc_id = tonumber( string.split(name,"_")[2] )
        --任务组id
        local team_id = self.tasks[npc_id]["team_id"]
        local art_id = self.tasks[npc_id]["art_id"]
        local task_list = self.tasks[npc_id]["task_list"]

        if team_id ~= nil then
            local eventCallback = function(event_data)
                --当前任务数据
                local task =  self.task_table[art_id]
                if self.tasks[npc_id] == nil then
                    Logger.logError("npc " .. npc_id .. " not found!!!!!")
                    return
                end
                --对话类型的任务
                if task.type == 1 then
                    --状态为2的发送完成任务消息
                    self.m_control:updateMsg("check_guide")
                    if self.tasks[npc_id].status == 2 then
                        self.m_model:getNetData("chivalrous_finish_task", {map_id = self.map_id, task_id = art_id}, function(response)
                            if response ~= nil then
                                local response_data = UserDataManager:getTasksActivityData()
                                if response_data[art_id ..""] ~= nil then
                                    local task_data = response_data[art_id ..""]
                                    task_data.art_id = art_id
                                    self:refreshChoice(task_data)

                                    netCallback(response)
                                else
                                    self:refreshChoice(nil)

                                    netCallback(response)
                                    -- self:newArticle(self.new_Article)
                                    self:lookTips()
                                    self.new_Article = nil
                                    
                                end
                                if task.ending_event == 1 then
                                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("renwu_wancheng_tex") , delay_close = 2})
                                    -- if self.m_cur_node then
                                    --     self.m_cur_node:taskFinish(true)
                                    -- end
                                end
                                if task["ending_map"] ~= 0 then
                                    self.Map2DControl:openMap2D(task["ending_map"])
                                end
                            end
                        end ,nil,true,GlobalConfig.POST)
                        --状态为3的直接更新选项
                    elseif self.tasks[npc_id].status == 3 then
                        local task_data = self.tasks[npc_id]
                        self:refreshChoice(task_data)
                    end
                    --发送选择结果
                    if event_data ~= nil and event_data["index"] ~= nil and event_data["id"] ~= 0 then
                        self:optionFinish(art_id, event_data, function(choice_id)
                            self.m_model:getNetData("chivalrous_select_task", { map_id = self.map_id, task_id = art_id, choice_id = self.allTask[tostring(art_id)].choice[event_data.index]}, function(response)
                                netCallback(response)
                                --local option = self.article_opt_table[event_data.id]
                                --if self.task_table[option.start_event].npc_number == npc_id then
                                --    self:onButtonClick(obj, name)
                                --end
                            end,nil,true,GlobalConfig.POST)
                        end)
                    end
                else
                    local task_data = self.tasks[npc_id]
                    self:refreshChoice(task_data)
                end
            end

            --显示对话
            self:playPlot(art_id, "task_plot", eventCallback)

            --状态为1的发送任务开始消息
            if self.tasks[npc_id]["status"] == 1 then
                self.m_model:getNetData("chivalrous_start_task", {map_id = self.map_id, npc_id = npc_id, team_id = team_id }, netCallback,nil,true,GlobalConfig.POST)
            end
        --开始互动npc对话
        else
            if task_list == nil then
                self:playPlot(npc_id, "npc_plot", function(event_data)
                    if event_data == nil then
                        self.m_model:getNetData("chivalrous_interact", {map_id = self.map_id, art_type = self.tasks[npc_id]["art_type"], article_id = npc_id, choice_id = nil}, netCallback,nil,true,GlobalConfig.POST)
                    else
                        self:optionFinish(npc_id, event_data, function(choice_id)
                            self.m_model:getNetData("chivalrous_interact", {map_id = self.map_id, art_type = self.tasks[npc_id]["art_type"], article_id = npc_id, choice_id = choice_id}, netCallback,nil,true,GlobalConfig.POST)
                        end)
                    end
                end)
            else
                self:playPlot(npc_id, "npc_task_plot", function(event_data)
                    if event_data ~= nil then
                        if event_data.id ~= 0 then
                            self:optionFinish(npc_id, event_data, function(choice_id)
                                self.m_model:getNetData("chivalrous_start_task", {map_id = self.map_id, npc_id = npc_id, team_id = event_data.id}, function(response)
                                    if response ~= nil then
                                        netCallback(response)
                                        self:lookTips()
                                        self.new_Article = nil
                                        local npc_id = tonumber( string.split(name,"_")[2] )

                                        local option = self.article_opt_table[event_data.id]
                                        if self.newArticle ~= nil then
                                            TimeTools:delayTimeUnity(1,
                                            function()
                                                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("worldMap_regional_accept_task")..Language:getTextByKey(self.task_table[option.start_event].event_name), delay_close = 2})
                                            end)
                                        else
                                            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("worldMap_regional_accept_task")..Language:getTextByKey(self.task_table[option.start_event].event_name), delay_close = 2})
                                        end
                                        
                                    end
                                end ,nil,true,GlobalConfig.POST)
                            end)
                        end
                    end
                end)
            end
        end
        audio:SendEvtUI("UI_NPC")
    end

    --点击互动物品，显示进度条，读条1秒后发送互动消息
    local artIndex = string.find(name, "article")
    if artIndex ~= nil and artIndex > 0 and self.m_cur_node and self.m_cur_node.loadingId == nil then
        self.m_control:updateMsg("item_click") -- 引导用
        local art_id = tonumber( string.split(name,"_")[2] )
        local m_model = self.m_model
        self:interact(art_id, obj, function(choice_id)
            m_model:getNetData("chivalrous_interact", {map_id = self.map_id, art_type = self.article_table[art_id].resource_type, article_id = art_id, choice_id = choice_id}, 
                function(response) 
                    netCallback(response)
                    self:lookTips()
                    self.new_Article = nil
                end       
            ,nil,true,GlobalConfig.POST)
        end)
    end
    
    local full_btn_name = self.m_uiName .. "/" .. name
    GameUtil:playBtnSound(full_btn_name)
end

function M:interact(art_id, obj, finish)
    local art_data = self.article_table[art_id]
    
    if art_data ~= nil then
        local callback = function(event_data)
            if event_data == nil or event_data.id ~= 0 then
                if event_data == nil then
                    finish(nil)
                else
                    local data = { map_id = self.map_id, art_id = art_id}

                    self:optionFinish(art_id, event_data, finish)
                end
            end
        end
        if art_data.Article_story ~= 0 or #art_data.option_id <= 0 then
            self:playPlot(art_id, "art_plot", callback)
        else
            callback({id = art_data.option_id[1], index = 1})
        end
    else
        finish(nil)
    end
end

function M:optionFinish(art_id, event_data, finish)
    local opt_data = self.article_opt_table[event_data.id]
    if opt_data ~= nil then
        local finishCallback = function()
            if opt_data.voice_open ~= "" and opt_data.voice_open ~= 0 then
                audio:SendEvtUI(opt_data.voice_open)
            end
            if opt_data.animation_open == 1 then
                self.Map2DControl:cameraShake(2, 0.3)
            end
            if opt_data.map_id ~= 0 then
                self.Map2DControl:openMap2D(opt_data.map_id)
            end
            
            self:lookTips()
            self.new_Article = nil
            static_rootControl:updateMsg("check_guide", nil, "WorldMap.WorldMapMain")
        end
        local callBack = function()
            if opt_data.event_battle ~= 0 then
               
            else
                if finish ~= nil then
                    finish(event_data.id)
                end
                finishCallback()
            end
        end

        if opt_data.event_team_id ~= nil and opt_data.event_team_id ~= 0 then
            self:playPlot(event_data.id, "option_plot", callBack)
        else
            callBack()
        end
    end
end

function M:playPlot(id, type, finishCallback)
    local event = require("UI.ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMap2D.ThreeHeroesFiveGallantsMapEvent").new()
    local event_data = nil
    --选项触发互动剧情
    if type == "option_plot" then
        event_data = self:getEventChoiceData(self.article_opt_table[id].event_team_id, {}, nil, nil, true)
    --任务剧情
    elseif type == "task_plot" then
        event_data = self:getEventChoiceData(self.task_table[id].event_before, {}, nil, nil, true)
        event.waitForChoise = self:taskHasChoice(self.task_table[id])
        --npc闲置剧情
    elseif type == "npc_plot" then
        event_data = self:getEventChoiceData(tonumber(self.npc_table[id].event_story), self.article_table[self.tasks[id].article_id].option_id, nil, self.tasks[id].choice, true)
        event_data.isArticle = true
        --npc接取任务
    elseif type == "npc_task_plot" then
        local options = {}
        local languages = {}
        for k,v in pairs(self.tasks[id].task_list) do
            if v == 0 or v == 1 or v == 2 then
                local task_id = tonumber(k)
                table.insert(options, task_id)
                table.insert(languages, Language:getTextByKey(self.article_opt_table[task_id].option_txt))
            end
        end
        event_data = self:getEventChoiceData(tonumber(self.npc_table[id].event_story), options, languages, nil, true)
        event_data.isArticle = true
        --互动物品剧情
    elseif type == "art_plot" then
        local art_data = self.article_table[id]
        event_data = self:getEventChoiceData(art_data.Article_story, art_data.option_id, nil, self.arts[id].choice, true)
        event_data.isArticle = true
    elseif type == "battle_plot" or type == "enter_map_plot_activity" or type == "no_choise_plot" then
        event_data = self:getEventChoiceData(id, {}, nil, nil, false)
    end
    if self.m_cur_node ~= nil then
        self.m_cur_node:ShowUI(false)
    end
    event:init(event_data, GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT, self.Map2DControl)
    event:start(0, 0, function(event_data)
        if self.m_cur_node ~= nil then
            self.m_cur_node:ShowUI(true)
        end
        if finishCallback ~= nil then
            finishCallback(event_data)
        end
    end)
end

--生成剧情数据，整合选项内容（自动添加离开选项）
--eventStoryId：剧情组id
--options：选项表id的数组
--canChoice：服务器返回的可选项，nil表示都可以选择
function M:getEventChoiceData(eventStoryId, options, languages, canChoice, hasExit)
    local event_data = {event_before = eventStoryId}
    if languages ~= nil then
        event_data.choise = table.copy(languages)
        event_data.no_choise_tips = {}
    else
        event_data.choise = {}
        event_data.no_choise_tips = {}
    end
    event_data.choise_id = {}
    event_data.can_choise = {}
    local closeOptionData = UserDataManager:getCloseOptionActivityData()

    for k,v in ipairs(options) do
        local closeOption = false
        if closeOptionData ~= nil then
            local closeOpt = closeOptionData[tostring(self.motherMapId)]
            if closeOpt ~= nil and table.indexof(closeOpt, v) ~= false then
                closeOption = true
            end
        end

        if closeOption == false then
            local can_choise = true
            --选项列表存在时，列表里没有则不能选
            if canChoice ~= nil and table.indexof(canChoice, v) == false then
                can_choise = false
            end
            if can_choise == true or (languages == nil and self.article_opt_table[v].option_hide == 1) then
                table.insert(event_data.choise_id, v)
                if languages == nil then
                    table.insert(event_data.choise, Language:getTextByKey(self.article_opt_table[v].option_txt))
                end
                table.insert(event_data.can_choise, can_choise)
                if languages == nil then
                    table.insert(event_data.no_choise_tips, self.article_opt_table[v].Conditional_hints)
                end
            end
        end
    end
    if hasExit == true then
        table.insert(event_data.choise_id, 0)
        table.insert(event_data.choise, Language:getTextByKey("worldMap_regional_leave"))
        table.insert(event_data.can_choise, true)
        table.insert(event_data.no_choise_tips, 0)
    end
    return event_data
end

function M:refreshChoice(task_data)
    if task_data ~= nil and task_data.choice ~= nil then
        local task = self.task_table[task_data.art_id]
        local canChoice = {}
        for k,v in pairs(task_data.choice) do
            table.insert(canChoice, task.option_id[v])
        end
        local event_data = self:getEventChoiceData(task.event_before, task.option_id, nil, canChoice, true)

        self.m_control:updateMsg("refresh_choise",event_data,"ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsStoreDrama")
    else
        self.m_control:updateMsg("refresh_choise",{choise = nil, choise_id = nil},"ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsStoreDrama")
    end

end

--检测是否有任务选项
function M:taskHasChoice(task)
    if task ~= nil and task.option_switch == 1 then
        if task.option_id ~= nil  then
            return true
        else
            return false
        end
    end
    return false
end

--获取任务根场景id
function M:getMotherMapId(id)
    local mother_map_id = self.map_table[id].mother_map_id
    if mother_map_id > 0 then
        return self:getMotherMapId(mother_map_id)
    end
    return id
end


function M:clearArtTips()
    if self.arts ~= nil then
        for k,v in pairs(self.arts) do
            if IsNull(v.tips_node) == false then
                ResourceUtil:ReturnItem(v.tips_node)
                v.tips_node = nil
            end
        end
    end
end

function M:refreshUI()
    --local firstMap = self.Map2DControl.curMap2D == nil
    local firstMap = self.isFirst
    --进入新场景
    local function netCallback(response)
        if response then
            if response["scene_lines"] ~= nil then
                self.scene_lines = response["scene_lines"]
            end
            if firstMap then
                UserDataManager:setArticlesActivityData(response["articles"])
                self:callback(response["articles"])
            else
                self:callback(UserDataManager:getArticlesActivityData())
            end
            if self.enter_callback then
                self.enter_callback()
            end
            self:newArticle(response.new_article)


            local bigMap_newArticle =  UserDataManager.local_data:getUserDataByKey("bigMap_newArticle_activity",{})
            self:newArticle(bigMap_newArticle[tostring(self.map_id)])

            UserDataManager.local_data:setUserDataByKey("bigMap_newArticle_activity",{})

            local enter_map_plot = UserDataManager.local_data:getUserDataByKey("enter_map_plot_activity", {})
            for k,v in pairs(self.allTask) do
                local task_id = tonumber(k)
                local task = self.task_table[task_id]
                if task.map_event ~= nil and #task.map_event > 0 then
                    for k1, v1 in ipairs(task.map_event) do
                        if v1[1] == self.map_id and enter_map_plot[task_id.."_"..self.map_id] == nil then
                            self:playPlot(v1[2], "enter_map_plot_activity", nil)
                            enter_map_plot[task_id.."_"..self.map_id] = 1
                            UserDataManager.local_data:setUserDataByKey("enter_map_plot_activity", enter_map_plot)
                            break
                        end
                    end
                end
            end
        end
    end
    if firstMap then
        if self.map_id == self.motherMapId then
            self.m_model:getNetData("chivalrous_enter_scene", {map_id = self.map_id, map_pos = { 0,0 }}, netCallback,nil,true,GlobalConfig.POST)
        else
            local function callback(response)
                if response then
                    firstMap = false
                    UserDataManager:setArticlesActivityData(response["articles"])
                    self.m_model:getNetData("chivalrous_enter_child_scene", {map_id = self.map_id}, netCallback,nil,true,GlobalConfig.POST)
                end
            end
            self.m_model:getNetData("chivalrous_enter_scene", {map_id = self.motherMapId, map_pos = { 0,0 }}, callback,nil,true,GlobalConfig.POST)
        end
    else
        self.m_model:getNetData("chivalrous_enter_child_scene", {map_id = self.map_id}, netCallback,nil,true,GlobalConfig.POST)
    end
end

function M:dataUpdateHandler(eventName, data)
    local track_task = UserDataManager.local_data:getUserDataByKey("track_task_activity", { })
    self.newTasks = {}
    if data.event == "tasks_activity_update" then
        local tasks_data = data.data
        local remove_data = tasks_data.remove or {}
        for k, v in pairs(remove_data) do
            local task_team_id = self.task_table[v].tasks_types
            local task_team = self.task_team_table[task_team_id]
            track_task[tostring(task_team.map_id)] = nil
        end
        local update_data = tasks_data.update or {}
        for k, v in pairs(update_data) do
            local task_id = tonumber(k)
            local task_team_id = self.task_table[task_id].tasks_types
            local task_team = self.task_team_table[task_team_id]
            track_task[tostring(task_team.map_id)] = task_id

            if self.allTask ~= nil and self.allTask[k] == nil then
                table.insert(self.newTasks, task_id)
            end
        end
        UserDataManager.local_data:setUserDataByKey("track_task_activity", track_task)

        if self.m_cur_node ~= nil and IsNull(self.m_cur_node.m_luaBehaviour) == false then
            self.m_cur_node:refreshTaskInfo()
        end
        
        audio:SendEvtUI("UI_Quest_Refresh")
    end
end

function M:getCurTaskMaps()
    local maps = {}
    local tasks = UserDataManager:getTasksActivityData()
    for k,v in pairs(tasks) do
        local task = self.task_table[tonumber(k)]
        local task_team_id = task.tasks_types
        if self.task_team_table[task_team_id].map_id == self.motherMapId then
            if task.type == 1 or task.type == 2 then
                maps[task.chapter] = 1
            elseif task.type == 3 then
                for k,v in pairs(task.article_id) do
                    local article = self.article_table[v]
                    maps[article.map_id] = 1

                end
            elseif task.type == 4 then
                for k,v in pairs(task.target) do
                    local article = self.article_table[v]
                    maps[article.map_id] = 1
                end
            end
        end
    end
    return maps
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateHandler})
    self.m_cur_node:destroy()
    self.m_cur_node = nil;
    self:clearArtTips()
    M.super.destroy(self)
end

return M;
