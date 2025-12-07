-- Animation (Animasyon) Sistemi

Animation = {}
Animation.__index = Animation

function Animation.new(frames, frameDuration)
    local self = setmetatable({}, Animation)
    
    self.frames = frames or {}
    self.frameDuration = frameDuration or 0.1
    self.currentFrame = 1
    self.timer = 0
    self.isPlaying = true
    self.loop = true
    
    return self
end

function Animation:update(dt)
    if not self.isPlaying then return end
    
    self.timer = self.timer + dt
    
    if self.timer >= self.frameDuration then
        self.timer = 0
        self.currentFrame = self.currentFrame + 1
        
        if self.currentFrame > #self.frames then
            if self.loop then
                self.currentFrame = 1
            else
                self.currentFrame = #self.frames
                self.isPlaying = false
            end
        end
    end
end

function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end

function Animation:reset()
    self.currentFrame = 1
    self.timer = 0
    self.isPlaying = true
end

function Animation:stop()
    self.isPlaying = false
end

function Animation:play()
    self.isPlaying = true
end

-- Stick Figure Animator
StickAnimator = {}
StickAnimator.__index = StickAnimator

function StickAnimator.new()
    local self = setmetatable({}, StickAnimator)
    
    self.state = "idle"  -- idle, walk, jump, attack, hurt
    self.timer = 0
    
    -- Animasyon parametreleri
    self.walkCycle = 0
    self.jumpOffset = 0
    self.attackAngle = 0
    self.hurtShake = 0
    
    return self
end

function StickAnimator:update(dt, player)
    self.timer = self.timer + dt
    
    -- Duruma göre animasyon seç
    if player.isAttacking then
        self.state = "attack"
        self.attackAngle = math.sin(player.attackTimer * 20) * 0.8
    elseif not player.isGrounded then
        self.state = "jump"
        self.jumpOffset = math.sin(self.timer * 10) * 5
    elseif math.abs(player.velocityX) > 10 then
        self.state = "walk"
        self.walkCycle = self.walkCycle + dt * 10
    else
        self.state = "idle"
        self.walkCycle = 0
    end
end

function StickAnimator:draw(player)
    local x, y = player.body:getPosition()
    
    -- Renk (oyuncuya göre)
    if player.playerNum == 1 then
        love.graphics.setColor(0.3, 0.8, 1)  -- Mavi
    else
        love.graphics.setColor(1, 0.3, 0.3)  -- Kırmızı
    end
    
    -- Hasar aldıysa titret
    if player.health < player.lastHealth then
        x = x + math.random(-2, 2)
        y = y + math.random(-2, 2)
    end
    player.lastHealth = player.health
    
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Yöne göre çevir
    if not player.facingRight then
        love.graphics.scale(-1, 1)
    end
    
    if self.state == "idle" then
        self:drawIdle()
    elseif self.state == "walk" then
        self:drawWalk()
    elseif self.state == "jump" then
        self:drawJump()
    elseif self.state == "attack" then
        self:drawAttack(player)
    end
    
    love.graphics.pop()
    
    -- Silah çiz
    if player.weapon then
        self:drawWeapon(player)
    end
end

function StickAnimator:drawIdle()
    -- Hafif nefes alma animasyonu
    local breathe = math.sin(self.timer * 2) * 2
    
    -- Baş
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", 0, -30 + breathe, 10)
    
    -- Gövde
    love.graphics.line(0, -20 + breathe, 0, 20)
    
    -- Kollar
    love.graphics.line(0, -10 + breathe, 15, 5 + breathe)
    love.graphics.line(0, -10 + breathe, -10, 5 + breathe)
    
    -- Bacaklar
    love.graphics.line(0, 20, -8, 40)
    love.graphics.line(0, 20, 8, 40)
    
    love.graphics.setLineWidth(1)
end

function StickAnimator:drawWalk()
    -- Yürüyüş animasyonu
    local legAngle = math.sin(self.walkCycle)
    local armAngle = math.sin(self.walkCycle + math.pi)
    
    -- Baş
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", 0, -28, 10)
    
    -- Gövde (hafif sallanma)
    local sway = math.sin(self.walkCycle * 2) * 2
    love.graphics.line(sway, -18, sway, 20)
    
    -- Kollar (zıt hareket)
    love.graphics.line(sway, -10, 15 + armAngle * 5, 5 + armAngle * 8)
    love.graphics.line(sway, -10, -10 - armAngle * 5, 5 - armAngle * 8)
    
    -- Bacaklar (yürüyüş)
    love.graphics.line(sway, 20, -8 + legAngle * 10, 40 - math.abs(legAngle) * 5)
    love.graphics.line(sway, 20, 8 - legAngle * 10, 40 - math.abs(legAngle) * 5)
    
    love.graphics.setLineWidth(1)
end

function StickAnimator:drawJump()
    -- Zıplama animasyonu
    -- Baş
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", 0, -32, 10)
    
    -- Gövde
    love.graphics.line(0, -22, 0, 18)
    
    -- Kollar (yukarı)
    love.graphics.line(0, -12, 12, -18)
    love.graphics.line(0, -12, -12, -18)
    
    -- Bacaklar (toplanmış)
    love.graphics.line(0, 18, -12, 32)
    love.graphics.line(0, 18, 12, 32)
    
    love.graphics.setLineWidth(1)
end

function StickAnimator:drawAttack(player)
    -- Saldırı animasyonu
    local angle = self.attackAngle
    
    -- Baş
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", 0, -30, 10)
    
    -- Gövde (hafif öne eğik)
    love.graphics.line(0, -20, 3, 20)
    
    -- Kollar (saldırı hareketi)
    love.graphics.line(3, -10, 25 + angle * 15, 0 + angle * 10)
    love.graphics.line(3, -10, -8, 5)
    
    -- Bacaklar (sağlam duruş)
    love.graphics.line(3, 20, -8, 40)
    love.graphics.line(3, 20, 12, 40)
    
    -- Yumruk efekti
    if player.isAttacking then
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.circle("fill", 25 + angle * 15, 0 + angle * 10, 8)
    end
    
    love.graphics.setLineWidth(1)
end

function StickAnimator:drawWeapon(player)
    local x, y = player.body:getPosition()
    local weaponColor = player.weapon.color
    
    love.graphics.setColor(weaponColor)
    
    local offsetX = player.facingRight and 20 or -20
    local weaponX = x + offsetX
    local weaponY = y - 5
    
    -- Basit silah görüntüsü
    if player.weapon.type == "sword" then
        love.graphics.rectangle("fill", weaponX - 3, weaponY - 15, 6, 30)
    elseif player.weapon.type == "axe" then
        love.graphics.polygon("fill", weaponX, weaponY - 15, weaponX + 10, weaponY - 10, weaponX, weaponY)
    else
        love.graphics.rectangle("fill", weaponX - 2, weaponY - 10, 4, 20)
    end
end
