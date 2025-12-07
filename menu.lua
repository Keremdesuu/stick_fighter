-- Menu System

Menu = {}
Menu.__index = Menu

function Menu.new()
    local self = setmetatable({}, Menu)
    
    self.state = "main" -- main, settings, controls, game
    self.selectedOption = 1
    self.pauseSelectedOption = 1
    self.options = {
        main = {
            {text = "OYNA", action = "startGame"},
            {text = "AYARLAR", action = "settings"},
            {text = "KONTROLLER", action = "controls"},
            {text = "ÇIKIŞ", action = "quit"}
        },
        settings = {
            {text = "Ses: AÇIK", action = "toggleSound", value = true},
            {text = "GERİ", action = "back"}
        },
        controls = {
            {text = "OYUNCU 1 KONTROLLERİ"},
            {text = "  Sağa/Sola: A/D"},
            {text = "  Zıplama: W"},
            {text = "  Saldırı: F"},
            {text = "  Silah Al: E"},
            {text = ""},
            {text = "OYUNCU 2 KONTROLLERİ"},
            {text = "  Sağa/Sola: ←/→"},
            {text = "  Zıplama: ↑"},
            {text = "  Saldırı: Sağ Ctrl"},
            {text = "  Silah Al: Sağ Shift"},
            {text = ""},
            {text = "GERİ", action = "back"}
        }
    }
    
    self.title = "STICK FIGHT"
    self.titleAnimTimer = 0
    
    -- Ayarlar
    self.soundEnabled = true
    self.fullscreen = false
    
    return self
end

function Menu:update(dt)
    self.titleAnimTimer = self.titleAnimTimer + dt
end

function Menu:keypressed(key)
    local currentOptions = self.options[self.state]
    
    if key == "up" or key == "w" then
        self.selectedOption = self.selectedOption - 1
        if self.selectedOption < 1 then
            self.selectedOption = #currentOptions
        end
    elseif key == "down" or key == "s" then
        self.selectedOption = self.selectedOption + 1
        if self.selectedOption > #currentOptions then
            self.selectedOption = 1
        end
    elseif key == "return" or key == "space" then
        self:selectOption()
    elseif key == "escape" then
        if self.state == "settings" or self.state == "controls" then
            self.state = "main"
            self.selectedOption = 1
        end
    end
end

function Menu:selectOption()
    local currentOptions = self.options[self.state]
    local selected = currentOptions[self.selectedOption]
    
    if not selected or not selected.action then return end
    
    if selected.action == "startGame" then
        self.state = "game"
        startGame()
    elseif selected.action == "settings" then
        self.state = "settings"
        self.selectedOption = 1
    elseif selected.action == "controls" then
        self.state = "controls"
        self.selectedOption = 1
    elseif selected.action == "quit" then
        love.event.quit()
    elseif selected.action == "back" then
        self.state = "main"
        self.selectedOption = 1
    elseif selected.action == "toggleSound" then
        self.soundEnabled = not self.soundEnabled
        self.options.settings[1].text = "Ses: " .. (self.soundEnabled and "AÇIK" or "KAPALI")
        self.options.settings[1].value = self.soundEnabled
    elseif selected.action == "toggleFullscreen" then
        -- Tam ekran özelliğini devre dışı bırak (sorunlu)
        -- self.fullscreen = not self.fullscreen
        -- Bilgilendirme: Şu an devre dışı
    end
end

function Menu:draw()
    if self.state == "main" then
        self:drawMainMenu()
    elseif self.state == "settings" then
        self:drawSettingsMenu()
    elseif self.state == "controls" then
        self:drawControlsMenu()
    end
end

function Menu:drawMainMenu()
    -- Arka plan
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Başlık animasyonu
    local titleY = 150 + math.sin(self.titleAnimTimer * 2) * 10
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.title, 0, titleY, love.graphics.getWidth(), "center")
    
    -- Alt başlık
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Çöp Adam Dövüş Oyunu", 0, titleY + 40, love.graphics.getWidth(), "center")
    
    -- Menü seçenekleri
    local startY = 300
    local spacing = 60
    
    for i, option in ipairs(self.options.main) do
        local y = startY + (i - 1) * spacing
        
        if i == self.selectedOption then
            -- Seçili seçenek
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.rectangle("fill", 450, y - 5, 300, 50)
            love.graphics.setColor(0.1, 0.1, 0.15)
            love.graphics.printf("> " .. option.text .. " <", 0, y + 5, love.graphics.getWidth(), "center")
        else
            -- Normal seçenek
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.printf(option.text, 0, y + 5, love.graphics.getWidth(), "center")
        end
    end
    
    -- Kontrol ipuçları
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("W/S veya ↑/↓: Seç | Enter/Space: Onayla", 0, 600, love.graphics.getWidth(), "center")
    
    -- Çöp adamlar çiz (dekorasyon)
    self:drawStickFigure(200, 500, false)
    self:drawStickFigure(1000, 500, true)
end

function Menu:drawSettingsMenu()
    -- Arka plan
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Başlık
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("AYARLAR", 0, 150, love.graphics.getWidth(), "center")
    
    -- Ayar seçenekleri
    local startY = 300
    local spacing = 60
    
    for i, option in ipairs(self.options.settings) do
        local y = startY + (i - 1) * spacing
        
        if i == self.selectedOption then
            -- Seçili seçenek
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.rectangle("fill", 400, y - 5, 400, 50)
            love.graphics.setColor(0.1, 0.1, 0.15)
            love.graphics.printf("> " .. option.text .. " <", 0, y + 5, love.graphics.getWidth(), "center")
        else
            -- Normal seçenek
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.printf(option.text, 0, y + 5, love.graphics.getWidth(), "center")
        end
    end
    
    -- Kontrol ipuçları
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("W/S veya ↑/↓: Seç | Enter: Değiştir | ESC: Geri", 0, 600, love.graphics.getWidth(), "center")
end

function Menu:drawControlsMenu()
    -- Arka plan
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Başlık
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("KONTROLLER", 0, 80, love.graphics.getWidth(), "center")
    
    -- Kontrol seçenekleri
    local startY = 150
    local spacing = 35
    
    for i, option in ipairs(self.options.controls) do
        local y = startY + (i - 1) * spacing
        
        if option.action == "back" and i == self.selectedOption then
            -- Geri butonu seçili
            love.graphics.setColor(1, 0.8, 0.2)
            love.graphics.rectangle("fill", 500, y - 5, 200, 40)
            love.graphics.setColor(0.1, 0.1, 0.15)
            love.graphics.printf("> " .. option.text .. " <", 0, y + 5, love.graphics.getWidth(), "center")
        elseif option.action == "back" then
            -- Geri butonu normal
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.printf(option.text, 0, y + 5, love.graphics.getWidth(), "center")
        else
            -- Bilgi satırları
            if option.text:sub(1, 2) == "  " then
                love.graphics.setColor(0.7, 0.7, 0.7)
            else
                love.graphics.setColor(1, 1, 0.5)
            end
            love.graphics.printf(option.text, 0, y, love.graphics.getWidth(), "center")
        end
    end
    
    -- Kontrol ipuçları
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Enter: Ana Menü | ESC: Geri", 0, 650, love.graphics.getWidth(), "center")
end

function Menu:drawStickFigure(x, y, facingRight)
    love.graphics.setColor(1, 1, 1, 0.3)
    
    -- Baş
    love.graphics.circle("line", x, y - 30, 10)
    
    -- Gövde
    love.graphics.line(x, y - 20, x, y + 20)
    
    -- Kollar
    if facingRight then
        love.graphics.line(x, y - 10, x + 15, y + 5)
        love.graphics.line(x, y - 10, x - 10, y + 5)
    else
        love.graphics.line(x, y - 10, x - 15, y + 5)
        love.graphics.line(x, y - 10, x + 10, y + 5)
    end
    
    -- Bacaklar
    love.graphics.line(x, y + 20, x - 10, y + 40)
    love.graphics.line(x, y + 20, x + 10, y + 40)
end
