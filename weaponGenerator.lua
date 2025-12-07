-- WeaponGenerator (Silah Üreteci) Sınıfı

WeaponGenerator = {}
WeaponGenerator.__index = WeaponGenerator

function WeaponGenerator.new(x, y)
    local self = setmetatable({}, WeaponGenerator)
    
    self.x = x
    self.y = y
    self.spawnTimer = 0
    self.spawnInterval = math.random(5, 10) -- 5-10 saniye arası rastgele
    self.currentWeapon = nil
    self.active = true
    self.animTimer = 0
    
    return self
end

function WeaponGenerator:update(dt)
    if not self.active then return end
    
    self.animTimer = self.animTimer + dt
    
    -- Eğer silah yoksa, yeni silah oluştur
    if not self.currentWeapon then
        self.spawnTimer = self.spawnTimer + dt
        
        if self.spawnTimer >= self.spawnInterval then
            self:spawnWeapon()
            self.spawnTimer = 0
            self.spawnInterval = math.random(5, 10)
        end
    else
        -- Silah alındıysa kontrol et
        if self.currentWeapon.owner then
            self.currentWeapon = nil
        end
    end
end

function WeaponGenerator:spawnWeapon()
    local weaponType = Weapon.getRandomType()
    local weapon = Weapon.new(self.x, self.y - 30, weaponType)
    self.currentWeapon = weapon
    table.insert(gameState.weapons, weapon)
end

function WeaponGenerator:draw()
    -- Generator platformu
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", self.x - 40, self.y - 10, 80, 20)
    
    -- Animasyonlu çerçeve
    local pulseSize = 5 + math.sin(self.animTimer * 3) * 3
    love.graphics.setColor(0.3, 0.5, 0.7, 0.5)
    love.graphics.rectangle("line", self.x - 40 - pulseSize, self.y - 10 - pulseSize, 
                           80 + pulseSize * 2, 20 + pulseSize * 2)
    
    -- Progress bar
    if not self.currentWeapon then
        local progress = self.spawnTimer / self.spawnInterval
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.rectangle("fill", self.x - 35, self.y - 5, 70 * progress, 10)
        
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("line", self.x - 35, self.y - 5, 70, 10)
    end
    
    -- İkon
    love.graphics.setColor(1, 1, 1)
    if self.currentWeapon then
        love.graphics.print("✓", self.x - 5, self.y - 30)
    else
        love.graphics.print("?", self.x - 5, self.y - 30)
    end
end
