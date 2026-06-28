local M = class("GuJianQiTanMazeShopControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.m_cell_data.status == 0 then

            -- if param == nil then
            --     self:updateMsg("maze_give_up")
            -- else
            --     self:updateMsg("maze_buy", {pos = param})
            -- end
            --self:updateMsg("maze_goto", {data = self.m_model.m_cell_data}, "MazeStage")
        else
        	--self:updateMsg("maze_give_up", nil, "MazeStage")
        end
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        local cell_data = self.m_model.m_cell_data;
        local moveFinish = {
            callback = function()
                self:openView("Shop",{shop_type = 4})
            end
        }
        if self.m_model.m_callBack ~= nil then
            self.m_model.m_callBack( moveFinish )
        end
        self:closeView()
    elseif msg == "cell_click" then
        self:shopDetailPop(data.data)
    elseif msg == "update_data" then
        self.m_model:updateData(data)
        self.m_view:refreshUI()
    end
end

function M:shopDetailPop(data)
    local remain = data.remain or 0
    if remain < 1 then
        return
    end
    local item = data.item
    local sell = data.sell
    local show_data = RewardUtil:getProcessRewardData(item)
    local function okCallFunc()
        local cell_data = RewardUtil:getProcessRewardData(sell)
        if cell_data.user_num < cell_data.data_num then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", cell_data.name), delay_close = 2})
            return
        end
        if self.m_model.m_cell_data.status ~= 3 then
            self:updateMsg("maze_buy", {pos = data.index, data = self.m_model.m_cell_data}, "GuJianQiTan.GuJianQiTanMaze")
            --self:updateMsg("maze_goto", {data = self.m_model.m_cell_data, param = data.index}, "MazeStage")
        else
            self:updateMsg("maze_buy", {pos = data.index, data = self.m_model.m_cell_data}, "GuJianQiTan.GuJianQiTanMaze")
        end
    end
    if show_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
        self:openView("HeroInfo.EquipmentPop", {equip_cfg_id = show_data.data_id, cost = sell, ok_call_func = okCallFunc, look_model = 2, hero_ids = data.hero_ids, show_buy_btn = self.m_model.m_open_flag})
    else
        self:openView("Item.ItemDetail", {show_data = show_data, cost = sell, ok_call_func = okCallFunc, show_buy_btn = self.m_model.m_open_flag})
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
