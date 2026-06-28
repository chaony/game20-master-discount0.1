--- 师门
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/MasterApprenticePanel"

function M:onCreate()
	
end

function M:onEnter()  
    self.stage_team_team = {}
    self.stage_team = self:findGameObject("stage_team")
    local num = self.stage_team.transform.childCount
  
    for i=1, num do
        local hero_cell = self.stage_team.transform:GetChild(i-1)
        hero_cell.gameObject:SetActive(false)
        table.insert(self.stage_team_team, hero_cell.gameObject)
    end
    self:setObjectVisible("tim_bg",false)
    self:setObjectVisible("no_right_btn", false)
    self:setTextByLanKey ("no_text", "master_apprentice_str_0015")
    self:setTextByLanKey ("master_team", "new_str_0091")
    self:setText("times","")
    for i = 1,3 do
        self:setText("mercenary"..i.."_name_text", "空闲中")
        self:setObjectVisible("role_bg_"..i, true)
    end
    self.hero_3d_parent = {}
    for i = 1,3 do
        self.hero_3d_parent[i] = self:findGameObject("rol_" .. i)
    end
end


function M:refreshUI()
    self:updateLeftMaster()
    self:updateRightMaster()
end

--更新左侧师傅信息
function M:updateLeftMaster()
    local is_master = self.m_model:isMaster()
    if is_master == false then
        if self.m_model.m_mastet_data and next(self.m_model.m_mastet_data) ~= nil then
            self:setObjectVisible("no_btn", false)
            self:setObjectVisible("master_info", true)
            self:setMasterInfo(self.m_model.m_mastet_data)
        else    
            self:setObjectVisible("no_btn", true)
            self:setObjectVisible("master_info", false)
        end
    elseif is_master == true then
        self:setMyMasterInfo()
        self:setObjectVisible("no_btn", false)
        self:setObjectVisible("master_info", true)
    end
end

function M:setMasterInfo(data)
    self:setObjectVisible("my_master_img", true)
    self:setText("master_name", data.name)
    self:setText("master_lv", data.level)
    self:setText("master_combat", data.full_combat)
    local stage_data = self.m_model:getStageName(data.stage)
    if stage_data then
        local stage_name = Language:getTextByKey(stage_data.map_point_name)
        self:setTextByLanKey("master_stage", "master_apprentice_str_0001", stage_name)  
    end
    local show_tim = Language:getTextByKey("master_apprentice_str_0016")..self.m_model:figureTim(data.last_active_time)
    self:setTextByLanKey("master_time", show_tim)  
    for k,v in pairs(data.stage_team) do
        local item = self.stage_team_team[k]
        if v ~= "" then
            item:SetActive(true) 
            local hero_data, hero_cfg = self.m_model:getHeroByStageHeros(v)
            local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, quality = hero_data.evo})
            GameUtil:updateItemElementByData(item, itemData)
            GameUtil:updateHeroLvByData(item, hero_data)
        else

        end
    end
end

function M:setMyMasterInfo()
    local data = UserDataManager.user_data.user_status
    self:setObjectVisible("my_master_img", false)
    self:setText("master_name", data.name)
    self:setText("master_lv", data.level)
    self:setText("master_combat", data.full_combat)
    local stage_data = self.m_model:getStageName(UserDataManager.stage_id)
    if stage_data then
        local stage_name = Language:getTextByKey(stage_data.map_point_name)
        self:setTextByLanKey("master_stage", "master_apprentice_str_0001", stage_name)  
    end
    local show_tim = Language:getTextByKey("mail_str_0006")
    self:setTextByLanKey("master_time", show_tim)  
    local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
    for k,v in pairs(stage_team) do
        local item = self.stage_team_team[k]
        if v ~= "" then
            item:SetActive(true) 
            local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
            local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, nil, hero_data.oid})
            GameUtil:updateItemElementByData(item, itemData)
            GameUtil:updateHeroLvByData(item, hero_data)
        else

        end
    end
end

--更新右侧信息
function M:updateRightMaster()
    local is_master = self.m_model:isMaster()
    self:setObjectVisible("apprentice_obj", not is_master)
    self:setObjectVisible("master_obj", is_master)
    self:setTextByLanKey ("no_right_btn_text", "master_apprentice_str_0029")
    self:setTextByLanKey ("con_text", "master_apprentice_str_0032", self.m_model:getShowStageName())
    if is_master == true and self.m_model.apprenttices then -- 我是师傅并且有徒弟
        self:updateApprenticeList()
    elseif is_master == false then
        self:updateBorrowHeroList()    
        self:updateProgress()
        if self.m_model.m_mastet_data == nil or next(self.m_model.m_mastet_data) == nil then
            self:setObjectVisible("no_right_btn", true)
            self:setObjectVisible("reward_node", false)
        else
            self:setObjectVisible("no_right_btn", false)
            self:setObjectVisible("reward_node", true)
            local num_1, num_2 = self.m_model:getRewardAdd()
            self:setTextByLanKey("exp_num", num_1.." / "..Language:getTextByKey("new_str_0121"))
            self:setTextByLanKey("hero_exp_num", num_2.." / "..Language:getTextByKey("new_str_0121"))
        end
    end
end

--更新徒弟列表（身份为师傅时）
function M:updateApprenticeList()
    local data = self.m_model.apprenttices
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("loop_scroll")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", cell_data.name)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_lv", cell_data.level)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_gold", "master_apprentice_str_0035",cell_data.bounty)
                    local stage_data = self.m_model:getStageName(cell_data.stage)
                    if stage_data then
                        local tim = Language:getTextByKey(stage_data.map_point_name)
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_stage", "master_apprentice_str_0001", tim)        
                    end
                    if cell_data.is_online == 1 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_tim", "mail_str_0006")
                    else
                        local show_tim = Language:getTextByKey("master_apprentice_str_0016")..self.m_model:figureTim(cell_data.last_active_time)
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_tim", show_tim)  
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --local function callfunc()
                --    self:playerInfo_callback(cell_data)
                --end
                local params = {
                    uid = cell_data.uid,
                    look_model = 4,
                    parent_view = "Friend" ,
                    status = self.m_model.m_master_status,
                    etime = self.m_model:checkRelivevData(cell_data.uid)
                }
                self.m_control:openView("Pops.PlayerInfo", params)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

--更新借用英雄列表（身份为徒弟时）
function M:updateBorrowHeroList()
    for k,v in pairs(self.hero_3d_parent) do
        local cell_parent =  self.hero_3d_parent[k]
        local sub_num = cell_parent.transform.childCount
        if sub_num > 0 then
            UIUtil.destroyAllChild(cell_parent.transform)
        end
    end

    local hero_list = {}
    for k,v in pairs(self.m_model.m_appostle) do
        table.insert( hero_list, k)
    end
    for k,v in pairs(hero_list) do
        local hero_data, hero_cfg = self.m_model:getAppostleHeroById(v)
        local prefab_name = hero_cfg["prefab"]
        local name_path = string.split(prefab_name,"/")
        local obj = ResourceUtil:LoadRole3d(prefab_name)
        --local helper = obj:GetComponent("LuaTransformHelper")
        --helper:SetAnimator(true);
        local panel = self.hero_3d_parent[k]
        obj.transform:SetParent(panel.transform, false)	
        obj.transform.localPosition = Vector3(0,0,0);
        obj.transform.localRotation = Quaternion.Euler(0,0,0);
        obj.transform.localScale = Vector3(1,1,1);
        local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_data.evo]
        if quality_item and quality_item.hero_3d_base then
            local evo_effect = ResourceUtil:LoadCommonEffect(quality_item.hero_3d_base, nil)
            evo_effect.transform:SetParent(panel.transform, false)
            evo_effect.transform.localScale = Vector3.New(1, 1, 1)
        end
        self:setTextByLanKey("mercenary"..k.."_name_text", hero_cfg.name)
        self:setObjectVisible("role_bg_"..k, false)
    end
    local function tick(dt)
		local down_time = self.m_model:getCoundTime()
		if down_time >= 0 then
            local text = GameUtil:formatTimeBySecond(down_time)
            self:setText("times", text..Language:getTextByKey("master_apprentice_str_0024"))
        else
			self:updateMsg("fresh_data")
		end
    end
    if #hero_list > 0 then
        self.tick_id = self.m_control:setTimer(1, tick)
        tick()
        self:setObjectVisible("tim_bg", true)
    end
end

function M:onButtonClick(obj, name)
    if name == "no_btn" or name == "no_right_btn" then
        self.m_control:openView("Friend.MasterApprenticeFindPop", {index = 2})
    elseif name == "reward_btn" then
        self.m_control:openView("Friend.MasterApprenticeRewardPop",{status = self.m_model.m_master_status, master = self.m_model.m_mastet_data})  
    elseif name == "money_btn" then
        self.m_control:openView("Friend.MasterApprenticeRedPacketPop",{red_packet = self.m_model.m_red_packet})  
    elseif name == "undergo_btn" then
        self.m_control:openView("Friend.MasterApprenticeUndergoPop")  
    elseif name == "desc_btn" then
        self.m_control:openView("Friend.MasterApprenticeFindPop", {index = 1})  
    elseif name == "mercenary_hero_1_btn" then
        self:selectHero(1)
    elseif name == "mercenary_hero_2_btn" then
        self:selectHero(2)
    elseif name == "mercenary_hero_3_btn" then
        self:selectHero(3)
    elseif name == "master_btn" then
        --local function callfunc()
        --    self:playerInfo_callback(self.m_model.m_mastet_data)
        --end
        local params = {
            uid = self.m_model.m_mastet_data.uid,
            look_model = 4,
            parent_view = "Friend" ,
            status = self.m_model.m_master_status,
            etime = self.m_model:checkRelivevData(self.m_model.m_mastet_data.uid)
        }
        self.m_control:openView("Pops.PlayerInfo", params)
    end
end

function M:selectHero(index)
    local hero_list = {}
    for k,v in pairs(self.m_model.m_appostle) do
        table.insert( hero_list, k)
    end
    local params = {
        heros = self.m_model.m_mastet_data.heros,
        callback = handler(self,self.callbackGetId),
        apostle_heros = hero_list or {}
    }
    self.m_control:openView("Pops.HireMasterHeroPop", params)  
end

function  M:callbackGetId(ids)
    self.m_control:requestMasterApostle(ids)
end

--进度
function M:updateProgress()
    local cur_slider = self:findSlider("Slider")
    cur_slider.value = self.m_model:progressToRate()
    self:setText("num_text", self.m_model:progressToText())
end

function M:playerInfo_callback(data)
    local params =
	{  
        no_close_btn = true,  
		text = Language:getTextByKey("master_apprentice_str_0018", data.name)
	}
    self.m_control:openView("Pops.CommonPop", params)
end

function M:destroy( )
    if self.tick_id  then
        self.m_control:removeTimer(self.tick_id)
    end
    M.super.destroy(self)
end

return M