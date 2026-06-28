local M = class("DestinyStarControl",LikeOO.OOControlBase)

function M:onEnter()
    --audio:SendEvtUI("Amb_2D_GuanXingLou")
    audio:SendEvtUI("Amb_2D_ChuangWangBZ_Entry")
    audio:SendEvtBGM("Set_State_GuanXingLou")
end


function M:onHandle(msg,data)
    if msg == 99999 then
        if self.m_model.select_hero_oid == 1 then
            self:updateMsg("common_refresh", nil, "HeroBag") 
        end
        self:closeView()
    elseif msg == "close_btn" then
        self:closeView()
    elseif msg == "destiny_btn" then --切换天命
        self:changeMode(1)
    elseif msg == "chemical_star_btn" then --切换化星
        self:changeMode(2)
    elseif msg == "master_btn" then --切换宗师
        self:changeMode(3)
    elseif msg == "derstand_btn" then --领悟天命
        if self.m_model.state == 0 then
            self:completeUnderstand()
        else
            GameUtil:lookInfoTips(self, { msg = "destinyStar_text_0016", delay_close = 2})
        end
    elseif msg == "select_hero" then --切换英雄
        audio:SendEvtUI("UI_Tab_N7")
        self:changeHero(data)
    elseif msg == "star" then --化星详情
        local fate_data = self.m_model:getStarData(data.star_id)
        if fate_data ~= nil and fate_data.heros ~= nil then
            self:openView("DestinyStar.StarDetails", { star_data = data,fates = self.m_model:getStarData(data.star_id) })
        else
            GameUtil:lookInfoTips(self, { msg = "destinyStar_text_0015", delay_close = 2})
        end
    elseif msg == "fate_build_btn" then
        local function netCallback(response)
            GameUtil:lookInfoTips(self, { msg = "fate_building_text_0014", delay_close = 2})
            UserDataManager:updateFateBuilding(response)
            self.m_view:refreshUI()
        end
        local params = {
            add_lv = 1,
        }
        self.m_model:getNetData("hero_fate_upgrade_building_lv", params, netCallback)
    elseif msg == "help_btn" then
        local params = {}
        params.title = "destinyStar_text_0001"
        params.content = "tid#FateStarRule_1"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "fate_help_btn" then
        local params = {}
        params.title = "fate_building_text_0003"
        params.content = "tid#FateStarRule_2"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "unlock_master_btn" then
        if data then
            if data.reward_data.user_num >= data.reward_data.data_num then
                local function netCallback(response)
                    UserDataManager:updateFateMaster(response)
                    self.m_view:refreshUI()
                end
                local params = {
                    master_id = data.master_id,
                }
                self.m_model:getNetData("hero_fate_enable_master", params, netCallback)
            else
                GameUtil:lookInfoTips(self, { msg = "compass_str_002", delay_close = 2})
            end
        end
    elseif msg == "add_master" then
        local params = {}
        params.open_type = "master"
        params.master_id = data.index
        params.hero_id = data.hero_id
        self:openView("DestinyStar.MasterSelectHeroPop", params)
    elseif msg == "add_slaves" then
        local params = {}
        params.open_type = "slaves"
        params.master_id = data.index
        params.slaves_pos = data.slaves_pos
        params.hero_id = data.hero_id
        self:openView("DestinyStar.MasterSelectHeroPop", params)
    elseif msg == "refreshUi" then
        self.m_view:refreshUI()
    end
end


--切换模式
function M:changeMode(index)
    if self.m_model.current_mode ~= index then
        self.m_model.current_mode = index
        self.m_view:switchTabNode(index)
        self.m_view:refreshUI()
        self.m_view:switchModel()
    end
end


--领悟天命
function M:completeUnderstand()
    local function netCallback(response)
        if response.reward ~= nil then
            RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
        end
        self.m_view:setDerstand()
        self.m_view:setMaskImg(true)
        --self.m_model.hero_table = self.m_model:getHeroData() --刷新列表，不确定是否需要
    end
    local material_data = {}
    for i=1,2 do
        local material = self.m_model.material[i]
        if material then
            table.insert(material_data,material.data.oid)
        else -- 道具补齐
            table.insert(material_data,"")
        end
    end
    --if self.m_model.material ~= nil then
    --    material_data = {self.m_model.material[1].data.oid,self.m_model.material[2].data.oid}
    --end
    local params = {
        hero_oid = self.m_model.current_hero_data.oid,
        material = material_data
    }
    self.m_model:getNetData("hero_enable_fate", params, netCallback)
end

function M:getHeroEnable()
    self.m_view:refreshUI()
    self.m_view:setMaskImg(false)
end

--切换英雄
function M:changeHero(data)
    if self.m_model.select_hero_id ~= 0 then
        self.m_model.select_hero_id = 0
    end
    self.m_model.currentHeroIndex = data.index
    self.m_model:updateCurrentHeroData(data) --刷新选中英雄信息
    self.m_view:refreshUI()
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    audio:SendEvtBGM("Set_State_ShiWu01")
    M.super.destroy(self)
end

return M;
	