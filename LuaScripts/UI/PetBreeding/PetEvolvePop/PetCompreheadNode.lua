--- 突破
local M = class("PetCompreheadNode",LikeOO.OOUIbase)

M.m_uiName = "PetBreeding/PetCompreheadNode"

local pro_tab = {}

function M:onEnter()
    self:setTextByLanKey("cell_title", "变异概率 :")
    self:setTextByLanKey("show_text", "奇兽领悟可提升进化时的变异概率")
    self:setObjectVisible("btn_sort_close", false)
    self:setObjectVisible("sort_list", false)
    self:updateTagLoopScroll()
    self:refreshUI()
end


function M:refreshUI()
    self:updateLoopScroll()
    self:creatShowPets()
end

--[[	
	宠物品级列表
]]
function M:updateTagLoopScroll()
    local data = {0,1,2,3,4,5}
    if self.m_tog_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("tag_list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local str = "%s代"
                    local str2 = string.format( str, Language:getTextByKey("num_str_000"..cell_data))
                    if cell_data == 0 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "txt_sort_1" ,"new_str_0065")
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "txt_sort_1", str2)
                    end
                end   
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_comprehead_index", cell_data)
                self:setObjectVisible("btn_sort_close", false)
                self:setObjectVisible("sort_list", false)
            end
        }
        self.m_tog_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_tog_loop_scroll_view:reloadData(data,true)
    end
end


--左侧选中信息
function M:creatShowPets()
    if self.m_model.m_comprehead_id ~= "" then
        local ItemNode = self:findGameObject("pet_cell3")
        self:updatePetObj(ItemNode, self.m_model.m_comprehead_id)
        GameUtil:updatePetElement(ItemNode,{oid = self.m_model.m_comprehead_id}, true, true)
        local comprehead_num = self.m_model:getCompreheadNums()
        self:setTextByLanKey("tips_text1", "剩余领悟次数："..comprehead_num)
        local cur_rate,next_rate = self.m_model:getCompreheadRate()
        self:setTextByLanKey("cell_last_num", (cur_rate*100).."%")
        if comprehead_num == 0 then
            self:setTextByLanKey("cell_next_num", (cur_rate*100).."%")
        else
            self:setTextByLanKey("cell_next_num", (next_rate*100).."%")    
        end
        self:updateCons()
        self:setObjectVisible("target_pos", true)
        self:setObjectVisible("no_img", false)
        self:setObjectVisible("left_show", true)
    else
        self:setObjectVisible("target_pos", false)
        self:setObjectVisible("no_img", true)
        self:setObjectVisible("left_show", false)
    end
  
end

--刷新道具
function M:updateCons()
    local cons_coin, cons_exp= self.m_model:getCompreheadCons()
    self:setImg(cons_coin.icon_name, cons_coin.atlas_name, "money_iocn")
    if cons_coin.user_num < cons_coin.data_num then
        self:setTextByLanKey("cons_num_text" , "equip_str_033" ,GameUtil:formatValueToString(cons_coin.user_num), GameUtil:formatValueToString(cons_coin.data_num))
    else
        self:setTextByLanKey("cons_num_text" , GameUtil:formatValueToString(cons_coin.user_num).."/"..GameUtil:formatValueToString(cons_coin.data_num))
    end
    self:setImg(cons_exp.icon_name, cons_exp.atlas_name, "money_iocn2")
    if cons_exp.user_num < cons_exp.data_num then
        self:setTextByLanKey("cons_num_text2" , "equip_str_033" ,GameUtil:formatValueToString(cons_exp.user_num), GameUtil:formatValueToString(cons_exp.data_num))
    else
        self:setTextByLanKey("cons_num_text2" , GameUtil:formatValueToString(cons_exp.user_num).."/"..GameUtil:formatValueToString(cons_exp.data_num))
    end
end


--[[	
	宠物列表
]]
function M:updateLoopScroll()
    local data = self.m_model.m_comprehead_ids or {}
    if self.m_model.m_select_evo2 > 0 then
        data = self.m_model:getCompreheadListByEvo(self.m_model.m_comprehead_ids)
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 4,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateItem(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_cell2", cell_data)
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data,true)
    end
end


function M:updateItem(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(data)
        local gou_bl = self.m_model:checkInCompSlot(data)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", gou_bl == true)
        -- local pet_cell = luaBehaviour:FindGameObject("pet_cell")
        GameUtil:updatePetElement(obj,{oid = data}, true, true)
        local cur_rate_num = self.m_model:getCompreheadRateByOid(data)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "prod_text", (cur_rate_num*100).."%")
    end    
end


function M:updatePetObj(obj,oid)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(oid)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", "a_ui_currency_dj_lan", "equip_icon")
        local level = pet_data.lv
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", level)
        local generation_data  = GameUtil:getPetInfoByData(pet_data)
        LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",generation_data.evo_text)
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", pet_cfg.icon, "hero_head_ui")
    end  
end

function M:onButtonClick(obj, name)
    if name == "compre_btn" then
        self:updateMsg("compre_btn")
    elseif name == "quick_compre_btn" then
        self:updateMsg("quick_compre_btn")  
    elseif name == "btn_sort_close" then
        self:setObjectVisible("btn_sort_close", false)
        self:setObjectVisible("sort_list", false)
    elseif name == "img_sort_select" then
        self:setObjectVisible("btn_sort_close", true)
        self:setObjectVisible("sort_list", true)
    elseif name == "help_btn" then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("提示信息 --- "), delay_close = 2})
    else
        M.super.onButtonClick(self, obj, name)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M