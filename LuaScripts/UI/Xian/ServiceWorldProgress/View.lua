local M = class("ServiceWorldProgressView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceWorldProgress"
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self.m_current_check_box = 0
    self.m_current_check_data = {}
    self.current_complet = 0 --当前选中
    self:refreshUI()
    if self.m_loop_scroll_view ~= nil then
        local center_pos = self.current_complet - 1
        self.m_loop_scroll_view:moveToCellIndex(center_pos)
    end
end

function M:refreshUI()
    self.current_complet = self.m_model:setCompletIndex()
    self.current_subscript = self.m_model:setCurrentIndex()
    self:updateLoopScroll()
    
end

--创建列表
function M:updateLoopScroll()
    local data = self.m_model:getDataListData()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if  click_name == "choice_Img" then --砥砺前行状态
                    self:updateMsg("mask_Img", {id = index, cell_data = cell_data, tip_word = 2})
                elseif click_name == "mask_Img" then --一马平川状态
                    self:updateMsg("mask_Img",{id = index, cell_data = cell_data, tip_word = 1})
                elseif click_name == "lock_Img" then --前人未至状态
                    self:updateMsg("mask_Img",{id = index, cell_data = cell_data, tip_word = 0})
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end


--[436]={
--["name"]="zhangjie1",
--["unlock"]=1,
--["image"]="a_ax_beijingtu1",
--["reward"]={
--{
--     107,
--     0,
--     100,
--},
--},
--},
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    --固定文字
    self:setTextByLanKey("progress_text","new_str_0829")
   
    local data = cell_data.cfg
    UIUtil.setTextByLanKey(transform,"name_text",data.name) --设置名称
    local Img_bg = luaBehaviour:FindGameObject("Img_bg")
    GameUtil:updateResourcesImg(Img_bg,"Texture/worldProgress/"..data.image)
    
    
    --设置进度条
    local slider = luaBehaviour:FindSlider("progress_slider")
    local sliderValue = self.m_model.serverOpenTime/data.unlock
    slider.value = sliderValue

    --遮罩状态显示
    local mask_Img_Show = false
    local mask_Img_hui_show = false
    
    if index <= self.m_model.lastCompletIndex then
        mask_Img_Show = true
        --self.current_complet = index
    else
        local molecule = self.m_model.serverOpenTime - self.m_model:lastUnlock(cell_data.stage_id) --分子
        local denominator = data.unlock - self.m_model:lastUnlock(cell_data.stage_id)--分母
        local sliderTime = (molecule/denominator)*0.5
        --local pass_count = self.m_model:getPassCount(cell_data.stage_id)
        local pass_count = self.m_model.m_data.pass_count
        local sliderPlayer = 0
        if pass_count ~= nil then
            --sliderPlayer = (self.m_model:getPassCount(cell_data.stage_id)/data.unlock_player)*0.5
            sliderPlayer = (pass_count/data.unlock_player)*0.5
        end
        --slider.value = molecule/denominator
        if sliderTime > 1 then
            sliderTime = 0.5
        elseif sliderPlayer > 1 then
            sliderPlayer = 0.5
        end
        slider.value = sliderTime+sliderPlayer
        mask_Img_hui_show = true
    end

    --设置进度条文本内容
    local slider_text = math.modf(slider.value*100).."%"
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_slider_text", slider_text)

    --进度条显示
    local progress = luaBehaviour:FindGameObject("progress")
    if index <= self.m_model.lastCompletIndex+1 then
        progress.gameObject:SetActive(true)
    else
        progress.gameObject:SetActive(false)
    end

    --设置当前关卡角标
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "subscript_Img", false)
    if self.current_subscript == index then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "subscript_Img", true)
    end

    --选中框显示、遮罩不显示
    if index == self.current_complet then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "choice_Img", true)
        LuaBehaviourUtil.setImg(luaBehaviour,"name_Img","a_wlxxz_xuanzhong_di","active_ui")
        mask_Img_Show = false
        mask_Img_hui_show = false
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "choice_Img", false)
        LuaBehaviourUtil.setImg(luaBehaviour,"name_Img","a_wlxxz_weixuanzhong_di","active_ui")
    end

    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_Img", mask_Img_Show)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_Img", mask_Img_hui_show)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "rpg_scroll_3")
    local mask_bg_Img = luaBehaviour:FindImage("mask_bg_Img")
    local lock_Img = luaBehaviour:FindImage("lock_Img")
    local Img_bg = luaBehaviour:FindImage("Img_bg")
    local Image_left = luaBehaviour:FindImage("Image_left")
    local Image_right = luaBehaviour:FindImage("Image_right")
    local name_Img = luaBehaviour:FindImage("name_Img")

    
    if mask_Img_hui_show then --设置置灰状态
        mask_bg_Img.material = lock_Img.material
        Img_bg.material = lock_Img.material
        Image_left.material = lock_Img.material
        Image_right.material = lock_Img.material
        name_Img.material = lock_Img.material
    else
        mask_bg_Img.material = nil
        Img_bg.material = nil
        Image_left.material = nil
        Image_right.material = nil
        name_Img.material = nil
    end
    
    
    --宝箱领取状态
    local red_point = luaBehaviour:FindGameObject("red_point")
    local red_point_show = false
    if index <= self.m_model.lastCompletIndex then --可领取
        if self.m_model:hasReward(cell_data.stage_id) then --已领取
        else --未领取
            red_point_show = true
        end
    else --不可领取
        
    end
    red_point.gameObject:SetActive(red_point_show)
    
    --未解锁隐藏
    if index <= self.current_subscript then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_text", false)
    else

        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_text", true)
    end
end


return M