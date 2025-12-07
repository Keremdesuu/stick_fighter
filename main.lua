-- Stick Fight Game
-- Love2D Çöp Adam Dövüş Oyunu

function love.load()
    love.window.setTitle("Stick Fight")
    
    -- Sabit oyun çözünürlüğü
    GAME_WIDTH = 1200
    GAME_HEIGHT = 700
    
    -- Pencere ayarları
    love.window.setMode(GAME_WIDTH, GAME_HEIGHT, {
        resizable = false,
        vsync = true,
        minwidth = GAME_WIDTH,
        minheight = GAME_HEIGHT
    })
    
    -- Ölçekleme için canvas
    gameCanvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)
    
    -- Modülleri önce yükle
    require("animation")
    require("player")
    require("weapon")
    require("weaponGenerator")
    require("menu")
    require("ai")
    
    -- Menü oluştur
    menu = Menu.new()
    
    -- Oyun durumu başlangıçta nil
    world = nil
    gameState = nil
    isPaused = false
end

function startGame()
    -- Fizik dünyası
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)
    
    -- Oyun durumu
    gameState = {
        players = {},
        weapons = {},
        weaponGenerators = {},
        ground = {}
    }
    
    -- Zemin oluştur
    createGround()
    
    -- Silah generator'lerini oluştur
    createWeaponGenerators()
    
    -- Oyuncu ve AI rakip oluştur
    local player = Player.new(200, 300, 1)
    local aiPlayer = Player.new(1000, 300, 2)
    aiPlayer.isAI = true  -- AI olarak işaretle
    
    table.insert(gameState.players, player)
    table.insert(gameState.players, aiPlayer)
    
    -- AI oluştur
    gameState.ai = AI.new(aiPlayer, player)
end

function love.update(dt)
    if menu.state == "game" and world and not isPaused then
        world:update(dt)
        
        -- Oyuncuları güncelle
        for _, player in ipairs(gameState.players) do
            player:update(dt)
        end
        
        -- AI'yı güncelle
        if gameState.ai then
            gameState.ai:update(dt)
        end
        
        -- Silah generator'lerini güncelle
        for _, gen in ipairs(gameState.weaponGenerators) do
            gen:update(dt)
        end
        
        -- Silahları güncelle
        for i = #gameState.weapons, 1, -1 do
            local weapon = gameState.weapons[i]
            weapon:update(dt)
            
            -- Oyuncular silahı alabilir mi kontrol et
            for _, player in ipairs(gameState.players) do
                if weapon:canPickup(player) and player.pickupKey then
                    player:equipWeapon(weapon)
                    table.remove(gameState.weapons, i)
                    break
                end
            end
        end
    elseif menu.state ~= "game" then
        menu:update(dt)
    end
end

function love.draw()
    -- Canvas'a çiz
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    
    if menu.state == "game" and gameState then
        -- Zemini çiz
        love.graphics.setColor(0.3, 0.3, 0.3)
        for _, ground in ipairs(gameState.ground) do
            love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
        end
        
        -- Silah generator'lerini çiz
        for _, gen in ipairs(gameState.weaponGenerators) do
            gen:draw()
        end
        
        -- Silahları çiz
        for _, weapon in ipairs(gameState.weapons) do
            weapon:draw()
        end
        
        -- Oyuncuları çiz
        for _, player in ipairs(gameState.players) do
            player:draw()
        end
        
        -- UI çiz
        drawUI()
        
        -- Duraklatma menüsü
        if isPaused then
            drawPauseMenu()
        end
        
        -- ESC için ipucu
        if not isPaused then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.print("ESC: Duraklat", 10, 10)
        end
    else
        menu:draw()
    end
    
    -- Canvas'ı ekrana çiz
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scaleX = windowWidth / GAME_WIDTH
    local scaleY = windowHeight / GAME_HEIGHT
    local scale = math.min(scaleX, scaleY)
    
    local offsetX = (windowWidth - GAME_WIDTH * scale) / 2
    local offsetY = (windowHeight - GAME_HEIGHT * scale) / 2
    
    love.graphics.draw(gameCanvas, offsetX, offsetY, 0, scale, scale)
end

function love.keypressed(key)
    if menu.state ~= "game" then
        menu:keypressed(key)
    else
        -- Oyun içinde ESC ile duraklatma
        if key == "escape" then
            isPaused = not isPaused
            if isPaused then
                menu.pauseSelectedOption = 1
            end
        end
        
        -- Duraklatma menüsü kontrolleri
        if isPaused then
            if key == "up" or key == "w" then
                menu.pauseSelectedOption = menu.pauseSelectedOption - 1
                if menu.pauseSelectedOption < 1 then
                    menu.pauseSelectedOption = 3
                end
            elseif key == "down" or key == "s" then
                menu.pauseSelectedOption = menu.pauseSelectedOption + 1
                if menu.pauseSelectedOption > 3 then
                    menu.pauseSelectedOption = 1
                end
            elseif key == "return" or key == "space" then
                if menu.pauseSelectedOption == 1 then
                    isPaused = false
                elseif menu.pauseSelectedOption == 2 then
                    isPaused = false
                    menu.state = "main"
                    menu.selectedOption = 1
                elseif menu.pauseSelectedOption == 3 then
                    love.event.quit()
                end
            end
        end
    end
end

function createGround()
    -- Ana zemin
    local ground = {}
    ground.body = love.physics.newBody(world, 600, 680, "static")
    ground.shape = love.physics.newRectangleShape(1200, 40)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    table.insert(gameState.ground, ground)
    
    -- Platformlar
    local platforms = {
        {x = 200, y = 500, w = 150, h = 20},
        {x = 600, y = 400, w = 200, h = 20},
        {x = 1000, y = 500, w = 150, h = 20}
    }
    
    for _, p in ipairs(platforms) do
        local platform = {}
        platform.body = love.physics.newBody(world, p.x, p.y, "static")
        platform.shape = love.physics.newRectangleShape(p.w, p.h)
        platform.fixture = love.physics.newFixture(platform.body, platform.shape)
        table.insert(gameState.ground, platform)
    end
end

function createWeaponGenerators()
    -- 3 silah generator'ı oluştur
    local positions = {
        {x = 300, y = 450},
        {x = 600, y = 350},
        {x = 900, y = 450}
    }
    
    for _, pos in ipairs(positions) do
        table.insert(gameState.weaponGenerators, WeaponGenerator.new(pos.x, pos.y))
    end
end

function drawUI()
    -- Oyuncu 1 sağlık barı
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 20, 20, 300, 30)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 20, 20, 300 * (gameState.players[1].health / 100), 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Player 1", 20, 55)
    
    -- Oyuncu 2 sağlık barı (AI)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 880, 20, 300, 30)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 880, 20, 300 * (gameState.players[2].health / 100), 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("AI Rakip", 1120, 55)
    
    -- Combo göstergesi
    for i, player in ipairs(gameState.players) do
        if #player.comboSequence > 0 then
            local x = i == 1 and 20 or 880
            love.graphics.print("Combo: " .. table.concat(player.comboSequence, "-"), x, 75)
        end
    end
end

function drawPauseMenu()
    -- Yarı saydam arka plan
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    
    -- Başlık
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("DURAKLATILDI", 0, 200, GAME_WIDTH, "center")
    
    -- Menü seçenekleri
    local options = {"DEVAM ET", "ANA MENÜ", "ÇIKIŞ"}
    local startY = 300
    local spacing = 60
    
    for i, option in ipairs(options) do
        local y = startY + (i - 1) * spacing
        
        if i == menu.pauseSelectedOption then
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.rectangle("fill", 450, y - 5, 300, 50)
            love.graphics.setColor(0.1, 0.1, 0.15)
            love.graphics.printf("> " .. option .. " <", 0, y + 5, GAME_WIDTH, "center")
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.printf(option, 0, y + 5, GAME_WIDTH, "center")
        end
    end
    
    -- Kontrol ipuçları
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("W/S veya ↑/↓: Seç | Enter: Onayla | ESC: Devam Et", 0, 550, GAME_WIDTH, "center")
end
