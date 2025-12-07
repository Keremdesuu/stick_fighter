-- Weapon (Silah) Sınıfı

Weapon = {}
Weapon.__index = Weapon

-- Silah tipleri
Weapon.types = {
    sword = {name = "Kılıç", damage = 15, color = {0.7, 0.7, 0.9}},
    axe = {name = "Balta", damage = 20, color = {0.6, 0.3, 0.1}},
    bat = {name = "Sopa", damage = 12, color = {0.5, 0.3, 0.1}},
    hammer = {name = "Çekiç", damage = 18, color = {0.5, 0.5, 0.5}},
    spear = {name = "Mızrak", damage = 16, color = {0.8, 0.8, 0.3}},
    nunchucks = {name = "Nunçaku", damage = 14, color = {0.3, 0.2, 0.1}}
}

function Weapon.new(x, y, weaponType)
    local self = setmetatable({}, Weapon)
    
    self.x = x
    self.y = y
    self.type = weaponType or "sword"
    self.info = Weapon.types[self.type]
    self.damage = self.info.damage
    self.color = self.info.color
    self.owner = nil
    self.pickupRadius = 40
    
    -- Fizik (opsiyonel, yerde duran silahlar için)
    self.rotation = 0
    self.bobTimer = 0
    
    return self
end

function Weapon.getRandomType()
    local types = {"sword", "axe", "bat", "hammer", "spear", "nunchucks"}
    return types[math.random(#types)]
end

function Weapon:update(dt)
    -- Yüzen animasyon efekti
    self.bobTimer = self.bobTimer + dt * 2
    self.rotation = math.sin(self.bobTimer) * 0.2
end

function Weapon:canPickup(player)
    if self.owner then return false end
    
    local px, py = player.body:getPosition()
    local distance = math.sqrt((self.x - px)^2 + (self.y - py)^2)
    
    return distance <= self.pickupRadius
end

function Weapon:draw()
    if self.owner then return end
    
    love.graphics.push()
    love.graphics.translate(self.x, self.y + math.sin(self.bobTimer) * 5)
    love.graphics.rotate(self.rotation)
    
    -- Silah çiz
    love.graphics.setColor(self.color)
    
    if self.type == "sword" then
        love.graphics.rectangle("fill", -5, -20, 10, 40)
        love.graphics.rectangle("fill", -8, -5, 16, 10)
    elseif self.type == "axe" then
        love.graphics.rectangle("fill", -3, -20, 6, 40)
        love.graphics.polygon("fill", -15, -20, 15, -20, 0, -5)
    elseif self.type == "bat" then
        love.graphics.circle("fill", 0, -18, 6)
        love.graphics.rectangle("fill", -3, -15, 6, 35)
    elseif self.type == "hammer" then
        love.graphics.rectangle("fill", -12, -22, 24, 12)
        love.graphics.rectangle("fill", -3, -10, 6, 30)
    elseif self.type == "spear" then
        love.graphics.polygon("fill", 0, -25, -5, -15, 5, -15)
        love.graphics.rectangle("fill", -2, -15, 4, 40)
    elseif self.type == "nunchucks" then
        love.graphics.rectangle("fill", -3, -20, 6, 15)
        love.graphics.rectangle("fill", -3, 5, 6, 15)
        love.graphics.line(0, -5, 0, 5)
    end
    
    -- Pickup göstergesi
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.circle("line", 0, 0, self.pickupRadius)
    
    -- İsim
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.info.name, -20, 25)
    
    love.graphics.pop()
end
