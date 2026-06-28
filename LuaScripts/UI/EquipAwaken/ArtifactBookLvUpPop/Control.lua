local M = class("ArtifactBookLvUpPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        self:lvUp2ToNet()
    elseif msg == "cons_img_1" then
        local cons_data = self.m_model:getThronsConsByIndex()
        if cons_data and cons_data[1] then
            local cons_data1 = RewardUtil:getProcessRewardData(cons_data[1])
            self:showItemInfoView(cons_data1)
        end
    elseif msg == "cons_img_2" then
        local cons_data = self.m_model:getThronsConsByIndex()
        if cons_data and cons_data[2] then
            local cons_data2 = RewardUtil:getProcessRewardData(cons_data[2])
            self:showItemInfoView(cons_data2)
        end
	end
end

function M:showItemInfoView(data)
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
        local tempCfg = data.item_cfg
        if tempCfg and (tempCfg.sort == 1) and (tempCfg.type == 1) then
            --- 阵营白色武器随机箱奖励特殊处理
            local random_chest = ConfigManager:getCfgByName("random_chest") or {}
            local tempEftData = tempCfg.effect[1]
            local random_chest_item = random_chest[tempEftData[2]]
            if random_chest_item then
                local sort = random_chest_item.sort
                local configs = random_chest_item.configs or {}
                if sort == 2 then -- 赛季展示
                    local index, season = GameUtil:getCurSeasonRewardIndex(configs)
                    if configs[index] and configs[index].rewards then
                        tempCfg.content_show = configs[index].rewards
                    end
                end
            end
        end
        static_rootControl:closeView("Item.ItemDetail",nil, false)
        static_rootControl:openView("Item.ItemDetail", {show_data = data, display = true})
    end
end
    
--进阶
function M:lvUp2ToNet() 
    local function callfunc()
        self:updateMsg(99999)
        --GameUtil:lookInfoTips(self, {msg = "equip_awake_012", delay_close = 2})
        self:updateMsg("lvup_over",nil,"EquipAwaken.ArtifactBookPop")
    end
    self.m_model:getNetData("thrones_evolution", nil, callfunc)	
end

return M
