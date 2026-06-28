local M = class("NewYearMiNiGameView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/CelebrateNewYear/NewYearMiNiGame"
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
    self.action_cache = {}
    self.role_parent = self:findGameObject("role_3d")
    local open_data = self.m_model:getActiveCfgByOpenId(267)
    if open_data then
        self:setTextByLanKey("close_title_text", open_data.name)
    else
        self:setTextByLanKey("close_title_text", "闲侠庙会")    
    end
	self:refreshUI()
	self:creatRole3D()
    self:talk( 999 )
end

function M:refreshUI()
    self:updateListScroll()
    self:refreshRedPoint()
end

-- 进入播放语音
function M:talk( id )
    local dinner_voice = ConfigManager:getCfgByName("dinner_voice");
    local item = dinner_voice[id];
    if item ~= nil then
        self:talkView(item)
    end
end


-- 阿闲说话
function M:talkView(cfg)
    if cfg.bank ~= "" and cfg.vo ~= "" then
        --播放声音
        self.bank = cfg.bank
        ResourceUtil:LoadRoleSound("Vo_AXian")
        self.cur_cv = audio:SendEvtUI("Vo_First_AXian_01")
    end

    --随机播放一个动作
    local action_index = math.random(1,#self.m_axian_actions)
    local action_name = self.m_axian_actions[action_index]
    self:setAnim(action_name)
end

function M:updateListScroll()
	local data = self.m_model.m_change_tab
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("jump", cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local cell_game_cfg = self.m_model:getMiniGameCfg(data)
    local cell_game_active = self.m_model:getMiniGameActives(data)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "game_name_text", cell_game_cfg.game_name1 or "")
    local red_bl = self.m_model:checkCanGetReward(data) == true or self.m_model:checkFirstLogin(data) == true
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_img", red_bl == true)
    if cell_game_active then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "go_to_btn", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_text", false)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "go_to_btn", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_text", true)
    end
end

function M:creatRole3D()
    ResourceUtil:LoadRole3dAsync("A_Xian/A_Xian", self.role_parent, function(obj)
        self.anim = obj:GetComponent("Animator")
        self.xian_con = obj:GetComponent(typeof(CS.XianControll))
        obj.transform:SetParent(self.role_parent.transform, false)	
        obj.transform.localPosition = Vector3(0,0,0);
        obj.transform.localRotation = Quaternion.Euler(0,0,0);
        obj.transform.localScale = Vector3(1, 1, 1);
        if self.action_cache[1] ~= nil then
            self:setAnim(self.action_cache[1])
            self.action_cache[1] = nil;
        end
	end, true)
end

function M:setAnim(name)
    if self.xian_con then
        self.xian_con:CrossFadeInFixedTime(name,0.1)
    else
        self.action_cache[1] = name;
    end
end

function M:refreshRedPoint()
    
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 0 then
        local text = GameUtil:formatTimeBySecond(down_time)
        self:setTextByLanKey("time_text","new_str_1028", text)
        --self.down_time_text.text = Language:getTextByKey("time_text", text)
    else
        self:setTextByLanKey("time_text","new_str_0558")
    end
end


function M:destroy()
    local a_xian_ab = "role3d_a_xian"
    ResourceUtil:UnLoadBundle(a_xian_ab, false)
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = nil
    M.super.destroy(self)
end

return M