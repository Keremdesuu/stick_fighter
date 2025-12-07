-- Player (Çöp Adam) Sınıfı

Player = {}
Player.__index = Player

function Player.new(x, y, playerNum)
    local self = setmetatable({}, Player)
    
    -- Fizik
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.body:setFixedRotation(true)
    self.shape = love.physics.newRectangleShape(30, 80)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({type = "player", player = self})
    
    -- Temel özellikler
    self.playerNum = playerNum
    self.health = 100
    self.maxHealth = 100
    self.speed = 300
    self.jumpForce = -180  -- Daha da azaltıldı
    self.isGrounded = false
    self.facingRight = playerNum == 1
    
    -- Hareket
    self.velocityX = 0
    
    -- Saldırı sistemi
    self.isAttacking = false
    self.attackTimer = 0
    self.attackDuration = 0.3
    self.attackCooldown = 0
    self.attackRange = 50
    self.comboSequence = {}
    self.comboTimer = 0
    self.comboWindow = 1.0
    self.lastAttackType = nil
    
    -- Silah sistemi
    self.weapon = nil
    self.pickupKey = false
    
    -- Kontroller
    self:setupControls(playerNum)
    
    -- AI kontrolü flag
    self.isAI = false
    
    -- Animatör
    self.animator = StickAnimator.new()
    self.lastHealth = self.health
    
    return self
end

function Player:setupControls(playerNum)
    if playerNum == 1 then
        self.controls = {
            left = "a",
            right = "d",
            jump = "w",
            attack = "f",
            pickup = "e"
        }
    else
        self.controls = {
            left = "left",
            right = "right",
            jump = "up",
            attack = "rctrl",
            pickup = "rshift"
        }
    end
end

function Player:update(dt)
    -- Zemin kontrolü
    self:checkGround()
    
    -- Hareket (AI için velocityX dışarıdan ayarlanabilir)
    if not self.isAI then
        self.velocityX = 0
        
        if love.keyboard.isDown(self.controls.left) then
            self.velocityX = -self.speed
            self.facingRight = false
        elseif love.keyboard.isDown(self.controls.right) then
            self.velocityX = self.speed
            self.facingRight = true
        end
    end
    
    local vx, vy = self.body:getLinearVelocity()
    self.body:setLinearVelocity(self.velocityX, vy)
    
    -- Zıplama
    if not self.isAI then
        if love.keyboard.isDown(self.controls.jump) and self.isGrounded then
            self.body:applyLinearImpulse(0, self.jumpForce)
        end
    end
    
    -- Pickup tuşu kontrolü
    if not self.isAI then
        self.pickupKey = love.keyboard.isDown(self.controls.pickup)
    end
    
    -- Saldırı
    if not self.isAI then
        if love.keyboard.isDown(self.controls.attack) and not self.isAttacking and self.attackCooldown <= 0 then
            self:attack()
        end
    end
    
    -- Saldırı timer'ları
    if self.isAttacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.isAttacking = false
            self.attackTimer = 0
        end
    end
    
    if self.attackCooldown > 0 then
        self.attackCooldown = self.attackCooldown - dt
    end
    
    -- Combo timer
    if #self.comboSequence > 0 then
        self.comboTimer = self.comboTimer + dt
        if self.comboTimer >= self.comboWindow then
            self.comboSequence = {}
            self.comboTimer = 0
        end
    end
    
    -- Animatörü güncelle
    self.animator:update(dt, self)
end

function Player:checkGround()
    local contacts = self.body:getContacts()
    self.isGrounded = false
    
    for _, contact in ipairs(contacts) do
        local x1, y1, x2, y2 = contact:getPositions()
        if y1 or y2 then
            local _, py = self.body:getPosition()
            if (y1 and y1 > py + 35) or (y2 and y2 > py + 35) then
                self.isGrounded = true
                break
            end
        end
    end
end

function Player:attack()
    self.isAttacking = true
    self.attackTimer = 0
    self.attackCooldown = 0.1
    self.comboTimer = 0
    
    -- Combo hesapla
    local attackType = self:calculateAttackType()
    table.insert(self.comboSequence, attackType)
    
    -- En fazla 5 combo
    if #self.comboSequence > 5 then
        table.remove(self.comboSequence, 1)
    end
    
    -- Hasarı hesapla
    local damage = self:calculateDamage(attackType)
    
    -- Menzildeki düşmana hasar ver
    self:dealDamageToEnemies(damage)
end

function Player:calculateAttackType()
    local comboLength = #self.comboSequence
    
    -- İlk 2 saldırı yumruk
    if comboLength < 2 then
        return "punch"
    end
    
    -- 3. saldırı tekme
    if comboLength == 2 then
        return "kick"
    end
    
    -- 4. saldırı uppercut
    if comboLength == 3 then
        return "uppercut"
    end
    
    -- 5. saldırı special
    return "special"
end

function Player:calculateDamage(attackType)
    local baseDamage = {
        punch = 5,
        kick = 10,
        uppercut = 15,
        special = 20
    }
    
    local damage = baseDamage[attackType] or 5
    
    -- Silah varsa ekstra hasar
    if self.weapon then
        damage = damage + self.weapon.damage
    end
    
    return damage
end

function Player:dealDamageToEnemies(damage)
    local px, py = self.body:getPosition()
    
    for _, otherPlayer in ipairs(gameState.players) do
        if otherPlayer ~= self then
            local ox, oy = otherPlayer.body:getPosition()
            local distance = math.sqrt((ox - px)^2 + (oy - py)^2)
            
            -- Menzil ve yön kontrolü
            if distance <= self.attackRange then
                local isInFrontOf = (self.facingRight and ox > px) or (not self.facingRight and ox < px)
                if isInFrontOf then
                    otherPlayer:takeDamage(damage)
                end
            end
        end
    end
end

function Player:takeDamage(damage)
    self.health = math.max(0, self.health - damage)
    
    if self.health <= 0 then
        self:die()
    end
end

function Player:die()
    -- Ölüm animasyonu veya yeniden başlatma
    self.health = self.maxHealth
    local x = self.playerNum == 1 and 200 or 1000
    self.body:setPosition(x, 300)
    self.body:setLinearVelocity(0, 0)
end

function Player:equipWeapon(weapon)
    self.weapon = weapon
    weapon.owner = self
end

function Player:draw()
    -- Animatörü kullan
    self.animator:draw(self)
end
