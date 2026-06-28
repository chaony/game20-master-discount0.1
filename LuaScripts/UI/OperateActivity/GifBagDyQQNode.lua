local M = class("GifBagDyQQNode", LikeOO.OOUIbase)
--双倍收益
M.m_uiName = "GiftBag/GifBagDouyinQQNode"

function M:onEnter()
    self:setObjectVisible("get_red_point", false)
    self:createRewardList()

end

function M:switchUI()
    self:refreshUI()
end

function M:createRewardList()
    local tiktok_onekey_cfg = ConfigManager:getCfgByName("tiktok")
    local reward = tiktok_onekey_cfg[1].reward or {}
    --local reward_node = UIUtil.findRectTransform(transform,"reward_node")
    local reward_node = self:findGameObject("pos_dy")
    GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 1)

    local reward2 = tiktok_onekey_cfg[2].reward or {}
    local reward_node_qq = self:findGameObject("pos_qq")
    GameUtil:createRewards(reward_node_qq.transform, reward2, true, true, nil, 1)
end

function M:refreshUI()

    self:setObjectVisible("img_follow_dy_1", false)
    local tiktok_onekey_cfg = ConfigManager:getCfgByName("tiktok")

    if self.m_model.m_tiktok_data then
        local btnDy = self:findGameObject("btn_follow_dy")
        if self.m_model.m_tiktok_data["1"] then
            self:setObjectVisible("img_follow_dy_1", true)
            local btn = btnDy:GetComponent("Button")
            btn.onClick:RemoveAllListeners()
        else
            SDKUtil:setCallback(
                "open_scheme_url_callbac",
                function(param)
                    if param.is_success then
                        local function data_cb(data)
                            if data then
                                self.m_model.m_tiktok_data["1"] = data.tiktok_record["1"]
                                self:refreshUI()
                            end
                        end

                        self.m_model:getNetData("tiktok_req_reward", {config_id = 1}, data_cb)
                    else
                        local params = {
                            no_close_btn = true,
                            tow_close_btn = false,
                            ok_text = Language:getTextByKey("sdk_txt_005"),
                            text = Language:getTextByKey("sdk_txt_getdy"),
                            title = Language:getTextByKey("sdk_txt_002")
                        }
                        static_rootControl:openView("Pops.CommonPop", params)
                    end
                end
            )

            UIUtil.setButtonClick(
                btnDy.transform,
                function()
                    local url = tiktok_onekey_cfg[1].url
                    SDKUtil:handleGameEvent(
                        "openSchemeUrl",
                        {
                            scheme_url = url
                        }
                    )
                end
            )
        end

        local btnQQ = self:findGameObject("btn_qqgroup")
        if self.m_model.m_tiktok_data["2"] then
            self:setObjectVisible("img_qqgroup_1", true)

            local btn = btnQQ:GetComponent("Button")
            btn.onClick:RemoveAllListeners()
        else
            self:setObjectVisible("img_qqgroup_1", false)
            UIUtil.setButtonClick(
                btnQQ.transform,
                function()
                    local url = tiktok_onekey_cfg[2].url

                    local urls = string.split(url, ";")
                    if type(urls) == "table" then
                
                        local num = #urls
                        local idx = math.random(1, num)
                        url = urls[idx]
                    end
                    -- SDKUtil:openUrl(url)

                    CS.UnityEngine.Application.OpenURL(url)

                    local function data_cb(data)
                        if data then
                            self.m_model.m_tiktok_data["2"] = data.tiktok_record["2"]
                            self:refreshUI()
                        end
                    end

                    self.m_model:getNetData("tiktok_req_reward", {config_id = 2}, data_cb)
                end
            )
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
