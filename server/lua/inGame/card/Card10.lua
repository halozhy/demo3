--[[
    Card10.lua
    卡牌10
    描述：卡牌10的定义
    编写：李昊
    修订：周星宇
    检查：张昊煜
]]

local Bullet = require("inGame.bullet.Bullet")
local ZhongDu = require("inGame.state.enemyState.ZhongDu")

local Card10 = {
    x_ = nil,
    y_ = nil,
    x1_ = nil,
    y1_ = nil,
    id_ = nil,
    atk_ = nil,--攻击力
    atkEnhance_ = nil,--强化一级加的攻击力
    state_ = {},--buff数组
    cha_ = 5,--暴击率5%
    chr_ = 2,--暴击伤害200%
    fireCd_ = nil,
    player_ = nil,
    skillValue_ = nil,
    skillEnhance_ = nil,
    enhanceLevel_ = 0,-- 强化等级
    starLevel_ = 1,--合成等级
    time_ = nil,--攻击的时间
    size_ =  nil,
    pos_ = nil,
}

--[[
    new函数
    @param player
    @return card1
]]
function Card10:new(player,x,y,x1,y1,id,pos,starLevel)
    local card = {}
    self.__index = self
    setmetatable(card,self)
    card:init(player,x,y,x1,y1,id,pos,starLevel)
    return card
end

--[[
    init函数
    @param player
    @return none
]]
function Card10:init(player,x,y,x1,y1,id,pos,starLevel)
    self.x_ = x
    self.y_ = y
    self.x1_ = x1
    self.y1_ = y1
    self.id_ = id
    self.atk_ = 30
    self.atkEnhance_ = 10
    self.state_ = {}
    self.cha_ = 5
    self.chr_ = 2
    self.fireCd_ = 1.3
    self.player_ = player
    self.time_ = 0
    self.size_ = 10
    self.pos_ = pos
    self.enhanceLevel_ = self.player_.cardEnhanceLevel_[self.size_]
    self.starLevel_ = starLevel
    self:setStarLevel()
    for i = 1,self.enhanceLevel_ -1 do
        self:enhance()
    end
    self.skillValue_ = 50
    self.skillValueEnhance_ = 20
end

--[[
    强化
    @param none
    @return none
]]
function Card10:enhance()
    self.enhanceLevel_= self.enhanceLevel_ + 1
    self.atk_ = self.atk_ + self.atkEnhance_
    self.skillValue_ = self.skillValue_ + self.skillValueEnhance_
end

function Card10:setStarLevel()
    self.fireCd_ = self.fireCd_/self.starLevel_
end

--[[
    getX
]]
function Card10:getX()
    return self.x_
end

function Card10:getY()
    return self.y_
end

function Card10:getId()
    return self.id_
end

function Card10:getSize()
    return self.size_
end

function Card10:getEnhanceLevel()
    return self.enhanceLevel_
end

--[[
    attack攻击函数
]]
function Card10:attack()
    if #self.player_.enemy_ == 0 then
        return
    end

    local enemy

    -- 随机敌人
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    if self.player_.boss_ == nil then
        enemy = self.player_.enemy_[math.random(1, #self.player_.enemy_)]
    else
        enemy = self.player_.boss_
    end

    -- for k, v in pairs(self.player_.enemy_) do
    --     if enemy.time_ > self.player_.enemy_[k].time_ then
    --         enemy = self.player_.enemy_[k]
    --     end
    -- end

    local hurt = self.atk_
    local isCha = false
    if math.random(100) <= 5 then
        hurt = hurt*self.chr_
        isCha = true
    end

    -- 使被攻击目标得到“中毒”状态。中毒：每秒造成额外伤害。
    local zhongdu = ZhongDu:new(self.skillValue_)

    local bullet = Bullet:new(enemy,self.x_,self.y_,self.x1_,self.y1_,hurt,isCha,self.player_:getBulletId(),self.player_,10,zhongdu)
    table.insert(self.player_.bullet_,bullet)

end

--[[
    attack攻击函数
]]
function Card10:destroy()
    self.player_:removeCard(self)
    self.player_.cardPos_[self.pos_] = 0
end

--[[
    update
]]
function Card10:update(dt)
    
    self.time_ = self.time_ - dt
    if self.time_ <= 0 then
        self:attack()
        self.time_ = self.fireCd_*1000
    end

end

return Card10