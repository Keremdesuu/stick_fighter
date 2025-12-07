-- AI (Yapay Zeka) Sınıfı

AI = {}
AI.__index = AI

function AI.new(player, opponent)
    local self = setmetatable({}, AI)
    
    self.player = player
    self.opponent = opponent
    
    -- AI davranış parametreleri
    self.updateTimer = 0
    self.updateInterval = 0.1  -- Her 0.1 saniyede karar ver
    self.difficulty = "normal"  -- easy, normal, hard
    
    -- Karar değişkenleri
    self.targetX = 0
    self.shouldJump = false
    self.shouldAttack = false
    self.shouldPickup = false
    
    -- Agresiflik ve savunma
    self.aggressionLevel = 0.7
    self.retreatDistance = 100
    self.attackDistance = 60
    self.weaponSeekDistance = 200
    
    return self
end

function AI:update(dt)
    self.updateTimer = self.updateTimer + dt
    
    if self.updateTimer >= self.updateInterval then
        self.updateTimer = 0
        self:makeDecision()
    end
    
    -- Kararları uygula
    self:executeActions()
end

function AI:makeDecision()
    local px, py = self.player.body:getPosition()
    local ox, oy = self.opponent.body:getPosition()
    local distance = math.abs(ox - px)
    local verticalDistance = oy - py
    
    -- Sağlık durumuna göre strateji
    local healthRatio = self.player.health / self.player.maxHealth
    
    -- 1. Silah ara (eğer yoksa ve yakında silah varsa)
    if not self.player.weapon then
        local nearestWeapon = self:findNearestWeapon()
        if nearestWeapon and self:getDistance(px, py, nearestWeapon.x, nearestWeapon.y) < self.weaponSeekDistance then
            self:moveToTarget(nearestWeapon.x, nearestWeapon.y)
            self.shouldPickup = true
            return
        end
    end
    
    self.shouldPickup = false
    
    -- 2. Sağlık düşükse geri çekil
    if healthRatio < 0.3 and distance < self.retreatDistance then
        -- Rakipten uzaklaş
        if ox > px then
            self.targetX = px - 200
        else
            self.targetX = px + 200
        end
        self.shouldAttack = false
        return
    end
    
    -- 3. Saldırı mesafesindeyse saldır
    if distance < self.attackDistance and math.abs(verticalDistance) < 50 then
        self.targetX = ox
        self.shouldAttack = math.random() < self.aggressionLevel
        
        -- Rakiple aynı seviyede değilse hafif hareket et
        if not self:isOnSameLevel(py, oy) and self.player.isGrounded then
            self.shouldJump = math.random() < 0.2
        end
    else
        -- 4. Rakibe yaklaş (platform algılama ile)
        self:moveToTarget(ox, oy)
        self.shouldAttack = false
    end
end

function AI:moveToTarget(targetX, targetY)
    local px, py = self.player.body:getPosition()
    
    self.targetX = targetX
    
    -- Hedef yukarıdaysa ve mesafe varsa zıpla
    if targetY < py - 80 and self.player.isGrounded then
        -- Hedefin altındayız, yukarı çıkmalıyız
        local horizontalDist = math.abs(targetX - px)
        
        -- Hedefe yeterince yakınsak zıpla
        if horizontalDist < 100 then
            self.shouldJump = true
        end
    end
    
    -- Hedef aşağıdaysa ve platform kenarındaysak zıpla
    if targetY > py + 100 and self.player.isGrounded then
        local horizontalDist = math.abs(targetX - px)
        if horizontalDist < 50 then
            -- Düşmek için platforma yaklaş
            self.shouldJump = false
        end
    end
end

function AI:isOnSameLevel(y1, y2)
    return math.abs(y1 - y2) < 40
end

function AI:executeActions()
    local px, py = self.player.body:getPosition()
    
    -- Hareket simülasyonu
    if math.abs(self.targetX - px) > 15 then
        if self.targetX > px then
            -- Sağa git
            self.player.velocityX = self.player.speed
            self.player.facingRight = true
        else
            -- Sola git
            self.player.velocityX = -self.player.speed
            self.player.facingRight = false
        end
    else
        self.player.velocityX = 0
    end
    
    -- Zıplama
    if self.shouldJump and self.player.isGrounded then
        self.player.body:applyLinearImpulse(0, self.player.jumpForce)
        self.shouldJump = false
    end
    
    -- Saldırı
    if self.shouldAttack and not self.player.isAttacking and self.player.attackCooldown <= 0 then
        self.player:attack()
        self.shouldAttack = false
    end
    
    -- Silah al
    self.player.pickupKey = self.shouldPickup
end

function AI:findNearestWeapon()
    if not gameState or not gameState.weapons then return nil end
    
    local px, py = self.player.body:getPosition()
    local nearest = nil
    local minDist = math.huge
    
    for _, weapon in ipairs(gameState.weapons) do
        if not weapon.owner then
            local dist = self:getDistance(px, py, weapon.x, weapon.y)
            if dist < minDist then
                minDist = dist
                nearest = weapon
            end
        end
    end
    
    return nearest
end

function AI:getDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function AI:setDifficulty(difficulty)
    self.difficulty = difficulty
    
    if difficulty == "easy" then
        self.aggressionLevel = 0.4
        self.updateInterval = 0.2
        self.attackDistance = 50
    elseif difficulty == "hard" then
        self.aggressionLevel = 0.9
        self.updateInterval = 0.05
        self.attackDistance = 70
    else  -- normal
        self.aggressionLevel = 0.7
        self.updateInterval = 0.1
        self.attackDistance = 60
    end
end
