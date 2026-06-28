---@class HeroEvaluateView:OOPopBase
local M = class("HeroEvaluateView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroEvaluate"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn = "hot_togglebtn", lua_name = "", btn_text = "hot_btn_text"},
    {btn = "newest_togglebtn", lua_name = "", btn_text = "newest_btn_text"},
}

function M:onEnter()
    
    self:setTextByLanKey("common_title_text", "new_str_0677")
    self.input = self:findInputField('input')
    self.send_btn = self:findButton('send_btn')
    self.input_text = self:findGameObject("input_text")
    self:setTextByLanKey("input_placeholder", "new_str_0681")
    self:setTextByLanKey("hot_btn_text", "hot_btn_tex")
    self:setTextByLanKey("newest_btn_text", "newest_btn_tex")
    self:setTextByLanKey("send_btn_text", "pinglun_tex")
    self:refreshUI()
   

    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        if i == self.m_model.m_tab_index then
            tog_btn.isOn = true
        end
        UIUtil.addToggleListener(tog_btn, function(is_on, data) 
            if is_on then 
                self:updateMsg("tab_btn",data)
            end 
        end, i, self.m_uiName)
    end

end


function M:refreshUI()
    self.stars = {}
    local cell1 = self:findGameObject("cell1")
    
    --local data, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.hero_id)
    local cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.hero_id)
    if cfg then
        GameUtil:updateHeroContentByData(cell1,data,cfg)
        self:setTextByLanKey("hero_text", cfg.name)
        self:setTextByLanKey("hero_name_text", cfg.class)
    else
        local m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.hero_id)
        GameUtil:updateHeroContentByData(cell1,data,m_hero_cfg)
        self:setTextByLanKey("hero_text", m_hero_cfg.name)
        self:setTextByLanKey("hero_name_text", m_hero_cfg.class)
    end
    local slider_value = self.m_model.hero_score / 2
    for i=1,5 do
       local star = self:findImage("star_"..i)
       star.fillAmount  = 0
       self.stars[i] = star
    end

    local floor_value = math.floor(slider_value)

    for i=1,floor_value do
       local star = self:findImage("star_"..i)
       star.fillAmount  = 1
    end
    if self.stars[floor_value+1] ~= nil then
        self.stars[floor_value+1].fillAmount = slider_value-floor_value
    end

    self:setTextByLanKey("num_text", "new_str_0680",self.m_model.score_count)
    self:setText("min_text", self.m_model.hero_score)
    self:updateScroll()
     if self.m_list_scroll ~= nil then
        self.m_list_scroll:moveToCellIndex(1)
    end
    self:updateItemTime()
end
function M:updateItemTime()
    local function tick(dt)
        local down_time =   UserDataManager:getServerTime() - self.m_model.last_eva_ts
        if (300 - down_time) <= 0 then
            
            if self.input.isFocused == true then
                self.input.placeholder.text = ""
            else
                self:setTextByLanKey("input_placeholder", "new_str_0681")
            end
            self.input.interactable = true
            self.send_btn.interactable = true
        else
            self.send_btn.interactable = false
            self.input.interactable = false
            self.input.text = ""
            self:setTextByLanKey("input_placeholder", "new_str_0682",GameUtil:formatTimeBySecond(300 - down_time))
            
        end

    end
    self.m_control:setTimer(1,tick)
    tick()
  
end

--获得当前输入的文字
function M:getMsg()
    return self.input.text
end


function M:updateScroll()
    local data = self.m_model:getEvaluateData(self.m_model.m_tab_index)
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
           
            all_cell_size = all_cell_size,
            loop_scroll_object = list_scroll,
            pull_refresh = function() -- 下拉刷新
                self.last_offsety = self.m_list_scroll.m_scroll_rect.viewport.rect.height - self.m_list_scroll.m_scroll_rect.content.rect.height
                self:updateMsg("comments_by_range")
            end,
            update_cell = function(index, cell_object, cell_data)
                self:setCellHander(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "give_no_btn" then  
                    self:updateMsg("give_no_btn",{cell_data = cell_data,cell_object = cell_object})
                elseif click_name == "give_yes_btn" then
                    self:updateMsg("give_yes_btn",{cell_data = cell_data,cell_object = cell_object})
                end
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:setCellHander(obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local player_text = luaBehaviour:FindText("player_text") --玩家名称
    local year_text = luaBehaviour:FindText("year_text") --年月日
    local time_text = luaBehaviour:FindText("time_text") --时间
    local give_no_btn = luaBehaviour:FindGameObject("give_no_btn") --取消点赞
    local give_yes_btn = luaBehaviour:FindGameObject("give_yes_btn") --点赞成功
    local count_text = luaBehaviour:FindText("count_text") --点赞总数
    local desc_text = luaBehaviour:FindText("desc_text") --评论详情
    local text_list_scroll = UIUtil.findScrollRect(obj.transform, "cell_1/content/ply_desc/text_list_scroll")
    if text_list_scroll then
       text_list_scroll.enabled = false
        --local rect = desc_text.gameObject:GetComponent("RectTransform")
        --rect.anchoredPosition3D = Vector3.New(200,0,0)
    end
    
    give_no_btn:SetActive(cell_data.like_status == 0)
    give_yes_btn:SetActive(cell_data.like_status == 1)

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_text", cell_data.name)
    
    
    count_text.text = cell_data.like_count
    desc_text.text = cell_data.content
    if #desc_text.text > 90 then
        --text_list_scroll.enabled = true
    end

    local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(cell_data.ts)
    time_text.text = string.format("%02d:%02d:%02d", hour, min, sec)
    --GameUtil:formatTimeBySecond(cell_data.ts)
    local tm = TimeUtil.gmTime(cell_data.ts)
    year_text.text = string.format("%d/%02d/%02d ", tm.year, tm.month, tm.day)

    local scrollRectClick = desc_text.gameObject:GetComponent("ScrollRectClick")
    if scrollRectClick then
        scrollRectClick.index = index
        scrollRectClick:RegistClickCallBack(
            function(click_type, index)
                if click_type == 2 then
                    self:updateMsg("show_report", index)
                end
            end
        )
    end
end

return M