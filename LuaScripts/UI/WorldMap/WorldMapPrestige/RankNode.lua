--- 排行
local M = class("RankNode",LikeOO.OOUIbase)

M.m_uiName = "WorldMap/RankNode"
M.m_iphoneXAdapter = true

function M:onEnter()
    self:refreshUI()    
end

function M:refreshUI()
    self:updateLoopScroll()
end

--[[
    掉落列表
]]
function M:updateLoopScroll()
    self.m_cell_tab = {}   
    local data = self.m_model:mapAreaTab()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tog_loopscroll")
        local params ={
			show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_cell_tab[cell_obj] = cell_data
                self:TogItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				self:updateMsg("select_area", index)
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end 
end

function M:TogItem(index, obj, cell_data)
    local LuaBehaviour  = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "light_img", index == self.m_model.m_area_map)
        local name_text = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "name", cell_data.cfg.name)
        if index == self.m_model.m_area_map then
            self.m_model:InitNetData(cell_data.id, handler(self, self.updateHeroList))
            name_text.color = GlobalConfig.COMMON_COLLOR.COMMON_6
        else
            name_text.color = GlobalConfig.COMMON_COLLOR.COMMON_7
        end
   
    end   
end

function M:updateHeroList()
    self:updateHeroLoopScroll()
end

--[[
    掉落列表
]]
function M:updateHeroLoopScroll()
    self.m_cell_tab = {}   
    local data = self.m_model.m_ranks or {}
    if self.m_scroll_view2 == nil then
        local loopscroll = self:findGameObject("list_loopscroll")
        local params ={
			show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_cell_tab[cell_obj] = cell_data
                self:updatePlayerItem(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				self:updateMsg("select_area", index)
			end
        }
        self.m_scroll_view2 = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view2:reloadData(data, true)
    end 
end

function M:updatePlayerItem(obj, data)
    local LuaBehaviour  = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local headNode = LuaBehaviour:FindGameObject("headNode")
        GameUtil:setUserAvatar(headNode, data.user, nil, nil,{show_flag = true, scale = 1})
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "name_text", data.user.name)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "lv_text", "new_str_0075", data.user.level)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "prestige_text", data.score)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "rank_text", data.rank)
        if data.rank <= 3 then
            LuaBehaviourUtil.setImg(LuaBehaviour, "rank_img", "a_phb_icon_"..data.rank, "common_ui")
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rank_img", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rank_text", false)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rank_img", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "rank_text", true)
        end
    end   
end


return M