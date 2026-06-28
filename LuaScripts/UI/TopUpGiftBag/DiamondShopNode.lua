local M = class("DiamondShopNode",LikeOO.OOUIbase)
--元宝商店
M.m_uiName = "OperateActivity/DiamondShopNode"

function M:onEnter()
    
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        self:createLoopScroll()
    end
    self.m_model:initData(url, callFunc)
end

function M:refreshUI()
    if self.m_model.m_charge_data == nil then
        return
    end
    self:createLoopScroll()
end

function M:switchUI()
    self:refreshUI()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_charge_cfg()
    

    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            one_line_count = 4,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("buy", cell_data.buy_id)
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data)
    end 
end

function M:updateCell(index, obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local data = self.m_model:getDiamondData(cfg.id)
        if data == true then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "double_img", false)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "double_img", true)    
        end
        LuaBehaviourUtil.setImg(luaBehaviour, "money_icon", cfg.icon, "active_ui")
        local count_text  = luaBehaviour:FindText("tiem_text")
        local price_text  = luaBehaviour:FindText("count_text")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "double_text", "gf_str_0086", cfg.gift_diamond[1][3])
        count_text.text = Language:getTextByKey(cfg.name) 
        price_text.text = GameUtil:getMoneyTypeNum(cfg.price)
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M