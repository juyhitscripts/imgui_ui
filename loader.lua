local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local mouse = plr:GetMouse()
local clock = os.clock
local rgb = Color3.fromRGB
local v2 = Vector2.new

local MatchaLib = {}
MatchaLib.__index = MatchaLib

local BLACK = rgb(20, 20, 20)
local SURFACE = rgb(36, 36, 36)
local BORDER = rgb(41, 74, 122)
local WHITE = rgb(230, 230, 230)
local ACCENT = rgb(36, 36, 36)

function MatchaLib.new(title)
    local self = setmetatable({}, MatchaLib)

    self.Title = title or ""
    self.X, self.Y = 520, 190
    self.W, self.H = 410, 420
    self.Open = true
    self.Visible = true -- F2 toggle flag

    self.Tabs = {}
    self.CurrentTab = nil

    -- Drawings
    self.Drawings = {
        MainBase = Drawing.new("Square"),
        Crust = Drawing.new("Square"),
        Border = Drawing.new("Square"),
        Navbar = Drawing.new("Square"),
        Title = Drawing.new("Text"),
        TabBar = Drawing.new("Square")
    }

    self:Init()
    self:MakeDraggable()
    self:UpdateLoop()
    self:MakeResizable() -- new

    return self
end

function MatchaLib:Init()
    local d = self.Drawings
    d.MainBase.Filled = true
    d.MainBase.Color = SURFACE
    d.MainBase.Visible = true
    d.Crust.Filled = false
    d.Crust.Thickness = 1
    d.Crust.Color = BLACK
    d.Crust.Visible = true
    d.Border.Filled = false
    d.Border.Thickness = 1
    d.Border.Color = BORDER
    d.Border.Visible = false
    d.Navbar.Filled = true
    d.Navbar.Color = BORDER
    d.Navbar.Visible = true
    d.Title.Text = self.Title
    d.Title.Color = WHITE
    d.Title.Outline = true
    d.Title.Visible = true
    d.TabBar.Filled = true
    d.TabBar.Color = rgb(24, 23, 23)
    d.TabBar.Visible = true
    self.Resizer = Drawing.new("Square")
    self.Resizer.Filled = true
    self.Resizer.Color = rgb(64, 106, 158)
    self.Resizer.Visible = true
    self.Resizer.Size = v2(15, 15)
    d.Resizer = self.Resizer
    d.Resizer.Position = v2(self.X + self.W - 15, self.Y + self.H - 15)
    d.Resizer.Size = v2(15, 15)
    d.Resizer.Visible = self.Visible
end
function MatchaLib:MakeResizable()
    local resizing = false
    local dragOffset = v2()
    spawn(
        function()
            while true do
                local mx, my = mouse.X, mouse.Y
                local pos = v2(self.X + self.W - 15, self.Y + self.H - 15)
                local size = v2(15, 15)
                local hovering = mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y
                if hovering and iskeypressed(0x01) then
                    if not resizing then
                        resizing = true
                        dragOffset = v2(self.X + self.W, self.Y + self.H) - v2(mx, my)
                    end
                end
                if resizing then
                    if iskeypressed(0x01) then
                        self.W = math.max(200, mx + dragOffset.X - self.X)
                        self.H = math.max(150, my + dragOffset.Y - self.Y)
                    else
                        resizing = false
                    end
                end

                task.wait()
            end
        end
    )
end

function MatchaLib:MakeDraggable()
    local navbar = self.Drawings.Navbar
    local dragging = false
    local dragOffset = v2()

    spawn(
        function()
            while true do
                local mx, my = mouse.X, mouse.Y
                local mpos = v2(mx, my)
                local npos = navbar.Position
                local nsize = navbar.Size

                local hovering = mx >= npos.X and mx <= npos.X + nsize.X and my >= npos.Y and my <= npos.Y + nsize.Y

                if hovering and iskeypressed(0x01) then
                    if not dragging then
                        dragging = true
                        dragOffset = mpos - v2(self.X, self.Y)
                    end
                end

                if dragging then
                    if iskeypressed(0x01) then
                        self.X = mpos.X - dragOffset.X
                        self.Y = mpos.Y - dragOffset.Y
                    else
                        dragging = false
                    end
                end
                task.wait()
            end
        end
    )
end

function MatchaLib:AddTab(name)
    local tab = {}
    tab.Name = name
    tab.Draw = Drawing.new("Square")
    tab.Draw.Filled = true
    tab.Draw.Color = SURFACE
    tab.Draw.Visible = true
    tab.Draw.Corner = 8

    tab.Text = Drawing.new("Text")
    tab.Text.Text = name
    tab.Text.Color = WHITE
    tab.Text.Outline = true
    tab.Text.Visible = true

    tab.Buttons = {}

    table.insert(self.Tabs, tab)

    if not self.CurrentTab then
        self.CurrentTab = tab
    end

    spawn(
        function()
            while true do
                local mx, my = mouse.X, mouse.Y
                local pos = tab.Draw.Position
                local size = tab.Draw.Size

                local hovering = mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y
                if hovering and iskeypressed(0x01) then
                    self.CurrentTab = tab
                    task.wait(0.2)
                end
                task.wait()
            end
        end
    )

    return tab
end

function MatchaLib:CreateButton(tab, text, callback)
    local btn = {}

    btn.Index = #tab.Buttons + 1
    btn.BoxWidth = 60
    btn.BoxHeight = 26

    btn.Draw = Drawing.new("Square")
    btn.Draw.Filled = true
    btn.Draw.Color = rgb(41, 74, 122)
    btn.Draw.Visible = true
    btn.Draw.Corner = 8

    btn.Text = Drawing.new("Text")
    btn.Text.Text = text
    btn.Text.Color = WHITE
    btn.Text.Outline = true
    btn.Text.Size = 13
    btn.Text.Center = true
    btn.Text.Visible = true

    table.insert(tab.Buttons, btn)

    spawn(
        function()
            while true do
                if self.CurrentTab == tab and self.Visible then
                    local pos = btn.Draw.Position
                    local size = btn.Draw.Size

                    -- Always center text
                    btn.Text.Position =
                        v2(
                        pos.X + size.X / 2, -- horizontal center
                        pos.Y + size.Y / 2 -- vertical center
                    )

                    local mx, my = mouse.X, mouse.Y
                    local hovering = mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y

                    if hovering then
                        btn.Draw.Color = rgb(61, 133, 224)
                        if iskeypressed(0x01) then
                            callback()
                            task.wait(0.25)
                        end
                    else
                        btn.Draw.Color = rgb(41, 74, 122)
                    end
                end
                task.wait()
            end
        end
    )

    return btn
end

function MatchaLib:CreateToggle(tab, text, callback, options)
    options = options or {}
    local defaultBoxColor = rgb(41, 74, 122)
    local boxColor = options.BoxColor or defaultBoxColor
    local boxWidth = options.BoxWidth or 25
    local boxHeight = options.BoxHeight or 25
    local textColor = options.TextColor or WHITE

    local btn = {}

    btn.Draw = Drawing.new("Square")
    btn.Draw.Filled = true
    btn.Draw.Color = boxColor
    btn.Draw.Visible = true
    btn.Draw.Corner = 7

    btn.Text = Drawing.new("Text")
    btn.Text.Text = text
    btn.Text.Color = textColor
    btn.Text.Outline = true
    btn.Text.Size = 13
    btn.Text.Visible = true

    btn.Check = Drawing.new("Text")
    btn.Check.Text = ""
    btn.Check.Color = WHITE
    btn.Check.Outline = true
    btn.Check.Size = 15
    btn.Check.Visible = false

    btn.Toggled = false
    btn.Index = #tab.Buttons + 1
    btn.BoxWidth = boxWidth
    btn.BoxHeight = boxHeight
    table.insert(tab.Buttons, btn)

    spawn(
        function()
            while true do
                if self.CurrentTab == tab and self.Visible then
                    local mx, my = mouse.X, mouse.Y
                    local posX = self.X + 10
                    local posY = self.Y + 60 + (btn.Index - 1) * (btn.BoxHeight + 6)
                    local size = v2(btn.BoxWidth, btn.BoxHeight)
                    local hovering = mx >= posX and mx <= posX + size.X and my >= posY and my <= posY + size.Y
                    if hovering and iskeypressed(0x01) then
                        btn.Toggled = not btn.Toggled
                        btn.Check.Visible = btn.Toggled
                        callback(btn.Toggled)
                        task.wait(0.2)
                    end
                end
                task.wait()
            end
        end
    )

    return btn
end

function MatchaLib:CreateSlider(tab, text, min, max, default, callback)
    local slider = {}

    slider.Min = min
    slider.Max = max
    slider.Value = default or min
    slider.Index = #tab.Buttons + 1
    slider.BoxHeight = 10
    slider.BoxWidth = 150
    slider.Dragging = false

    slider.Bar = Drawing.new("Square")
    slider.Bar.Filled = true
    slider.Bar.Color = BORDER
    slider.Bar.Visible = true

    slider.Fill = Drawing.new("Square")
    slider.Fill.Filled = true
    slider.Fill.Color = rgb(61, 133, 224)
    slider.Fill.Visible = true

    slider.Text = Drawing.new("Text")
    slider.Text.Text = text .. ": " .. slider.Value
    slider.Text.Color = WHITE
    slider.Text.Outline = true
    slider.Text.Size = 13
    slider.Text.Visible = true

    table.insert(tab.Buttons, slider)

    spawn(
        function()
            while true do
                if self.CurrentTab == tab and self.Visible then
                    local mx, my = mouse.X, mouse.Y
                    local pos = slider.Bar.Position
                    local size = slider.Bar.Size

                    if mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y then
                        if iskeypressed(0x01) then
                            slider.Dragging = true
                        end
                    end

                    if slider.Dragging then
                        if iskeypressed(0x01) then
                            local pct = math.clamp((mx - pos.X) / size.X, 0, 1)
                            slider.Value = math.floor(slider.Min + (slider.Max - slider.Min) * pct)
                            slider.Text.Text = text .. ": " .. slider.Value -- update text
                            callback(slider.Value)
                        else
                            slider.Dragging = false
                        end
                    end
                end
                task.wait()
            end
        end
    )

    return slider
end

function MatchaLib:CreateRadio(tab, text, options, callback)
    local radio = {}
    radio.Options = options
    radio.Selected = nil
    radio.Index = #tab.Buttons + 1
    radio.BoxHeight = 20
    radio.BoxWidth = 20
    radio.Buttons = {}

    radio.Label = Drawing.new("Text")
    radio.Label.Text = text
    radio.Label.Color = WHITE
    radio.Label.Outline = true
    radio.Label.Size = 13
    radio.Label.Visible = true

    for i, opt in ipairs(options) do
        local box = Drawing.new("Square")
        box.Filled = true
        box.Color = BORDER
        box.Visible = true
        box.Corner = 8

        local txt = Drawing.new("Text")
        txt.Text = opt
        txt.Color = WHITE
        txt.Outline = true
        txt.Size = 13
        txt.Visible = true

        table.insert(radio.Buttons, {Box = box, Text = txt, Value = opt})
    end

    table.insert(tab.Buttons, radio)

    spawn(
        function()
            while true do
                if self.CurrentTab == tab and self.Visible then
                    local mx, my = mouse.X, mouse.Y
                    for _, btn in ipairs(radio.Buttons) do
                        local pos = btn.Box.Position
                        local size = btn.Box.Size
                        if mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y then
                            if iskeypressed(0x01) then
                                radio.Selected = btn.Value
                                callback(btn.Value)
                                task.wait(0.25)
                            end
                        end
                    end
                end
                task.wait()
            end
        end
    )

    return radio
end

function MatchaLib:CreateDropdown(tab, text, options, callback)
    local dd = {}

    dd.Options = options
    dd.Selected = options[1]
    dd.Opened = false
    dd.Index = #tab.Buttons + 1
    dd.BoxWidth = 150
    dd.BoxHeight = 22

    dd.Box = Drawing.new("Square")
    dd.Box.Filled = true
    dd.Box.Color = BORDER
    dd.Box.Visible = true
    dd.Box.Corner = 8
    dd.Text = Drawing.new("Text")
    dd.Text.Text = text
    dd.Text.Color = WHITE
    dd.Text.Outline = true
    dd.Text.Size = 13
    dd.Text.Visible = true
    dd.ValueText = Drawing.new("Text")
    dd.ValueText.Text = dd.Selected
    dd.ValueText.Color = WHITE
    dd.ValueText.Outline = true
    dd.ValueText.Size = 13
    dd.ValueText.Center = false
    dd.ValueText.Visible = true
    dd.OptionTexts = {}
    for _, opt in ipairs(options) do
        local t = Drawing.new("Text")
        t.Text = opt
        t.Color = WHITE
        t.Outline = true
        t.Size = 13
        t.Visible = false
        table.insert(dd.OptionTexts, t)
    end

    table.insert(tab.Buttons, dd)

    spawn(
        function()
            while true do
                if self.CurrentTab == tab and self.Visible then
                    local mx, my = mouse.X, mouse.Y
                    local pos = dd.Box.Position
                    local size = dd.Box.Size

                    if mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y then
                        if iskeypressed(0x01) then
                            dd.Opened = not dd.Opened
                            task.wait(0.25)
                        end
                    end

                    if dd.Opened then
                        for i, optText in ipairs(dd.OptionTexts) do
                            local opY = pos.Y + dd.BoxHeight + (i - 1) * dd.BoxHeight
                            if mx >= pos.X and mx <= pos.X + size.X and my >= opY and my <= opY + dd.BoxHeight then
                                if iskeypressed(0x01) then
                                    dd.Selected = optText.Text
                                    dd.ValueText.Text = dd.Selected
                                    dd.Opened = false
                                    callback(dd.Selected)
                                    task.wait(0.25)
                                    task.wait(0.25)
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
        end
    )
    return dd
end

function MatchaLib:Update()
    local d = self.Drawings
    local pos = v2(self.X, self.Y)
    local size = v2(self.W, self.H)
    for _, draw in pairs(d) do
        draw.Visible = self.Visible
    end
    d.MainBase.Position = pos
    d.MainBase.Size = size
    d.MainBase.Corner = 15
    d.Crust.Position = pos
    d.Crust.Size = size
    d.Crust.Corner = 15
    d.Border.Position = pos + v2(1, 1)
    d.Border.Size = size - v2(2, 2)
    d.Border.Corner = 15
    d.Border.Visible = false
    d.Navbar.Position = pos + v2(5, 3)
    d.Navbar.Size = v2(self.W - 10, 24)
    d.Navbar.Corner = 15
    d.Title.Position = pos + v2(12, 9.2)
    d.TabBar.Position = pos + v2(3, 29)
    d.TabBar.Size = v2(self.W - 6, self.H - 32)
    d.TabBar.Corner = 10
    local tabX = pos.X + 10
    for _, tab in ipairs(self.Tabs) do
        tab.Draw.Position = v2(tabX, pos.Y + 33)
        tab.Draw.Size = v2(80, 24)
        tab.Text.Center = true
        tab.Text.Position = v2(tabX + (79 / 2), pos.Y + 46)
        tab.Draw.Color = (self.CurrentTab == tab) and rgb(61, 133, 224) or SURFACE
        tab.Draw.Visible = self.Visible
        tab.Text.Visible = self.Visible
        tabX = tabX + 84
    end
    for _, tab in ipairs(self.Tabs) do
        if self.CurrentTab == tab then
            local offsetY = pos.Y + 60
            local spacing = 6
            for _, elem in ipairs(tab.Buttons) do
                local elemH = elem.BoxHeight or 22
                local elemW = elem.BoxWidth or math.min(150, self.W - 20)
                if elem.Draw and elem.Text and not elem.Bar and not elem.OptionTexts then
                    elem.Draw.Position = v2(pos.X + 10, offsetY)
                    elem.Draw.Size = v2(elemW, elemH)
                    elem.Draw.Visible = self.Visible
                    if elem.Toggled then
                        elem.Draw.Color = rgb(61, 133, 224)
                    else
                        elem.Draw.Color = rgb(41, 74, 122)
                    end
                    elem.Text.Position = v2(pos.X + 10 + elemW + 8, offsetY + (elemH - 16) / 2)
                    elem.Text.Visible = self.Visible
                    if elem.Check then
                        elem.Check.Position = v2(pos.X + 10 + (elemW / 2 - 4), offsetY + (elemH / 2 - 8))
                        elem.Check.Visible = self.Visible and elem.Toggled
                    end
                    offsetY = offsetY + elemH + spacing
                elseif elem.Bar and elem.Fill then
                    elem.Text.Position = v2(pos.X + 10, offsetY)
                    elem.Text.Visible = self.Visible
                    offsetY = offsetY + 14
                    elem.Bar.Position = v2(pos.X + 10, offsetY)
                    elem.Bar.Size = v2(math.min(150, self.W - 20), 8)
                    elem.Bar.Visible = self.Visible
                    elem.Fill.Position = elem.Bar.Position
                    elem.Fill.Size = v2(((elem.Value - elem.Min) / (elem.Max - elem.Min)) * elem.Bar.Size.X, 8)
                    elem.Fill.Visible = self.Visible
                    offsetY = offsetY + 8 + spacing
                elseif elem.Buttons and elem.Label then
                    elem.Label.Position = v2(pos.X + 10, offsetY)
                    elem.Label.Visible = self.Visible
                    offsetY = offsetY + 16
                    for _, btn in ipairs(elem.Buttons) do
                        btn.Box.Position = v2(pos.X + 10, offsetY)
                        btn.Box.Size = v2(18, 18)
                        btn.Text.Position = v2(pos.X + 32, offsetY + 1)
                        if elem.Selected == btn.Value then
                            btn.Box.Color = rgb(61, 133, 224)
                        else
                            btn.Box.Color = BORDER
                        end
                        btn.Box.Visible = self.Visible
                        btn.Text.Visible = self.Visible
                        offsetY = offsetY + 22
                    end
                    offsetY = offsetY + spacing
                elseif elem.Box and elem.OptionTexts then
                    elem.Text.Position = v2(pos.X + 10, offsetY)
                    elem.Text.Visible = self.Visible
                    offsetY = offsetY + 16
                    elem.Box.Position = v2(pos.X + 10, offsetY)
                    elem.Box.Size = v2(math.min(elem.BoxWidth, self.W - 20), elem.BoxHeight)
                    elem.Box.Visible = self.Visible
                    if elem.Opened then
                        elem.Box.Color = rgb(61, 133, 224)
                    else
                        elem.Box.Color = rgb(41, 74, 122)
                    end
                    elem.ValueText.Position =
                        v2(elem.Box.Position.X + 8, elem.Box.Position.Y + (elem.BoxHeight / 2) - 7)
                    elem.ValueText.Visible = self.Visible
                    offsetY = offsetY + elem.BoxHeight
                    for i, optText in ipairs(elem.OptionTexts) do
                        optText.Position = v2(pos.X + 14, offsetY + (i - 1) * elem.BoxHeight + 3)
                        optText.Visible = self.Visible and elem.Opened
                    end
                    if elem.Opened then
                        offsetY = offsetY + (#elem.OptionTexts * elem.BoxHeight)
                    end
                    offsetY = offsetY + spacing
                end
            end
        else
            for _, elem in ipairs(tab.Buttons) do
                if elem.Draw then
                    elem.Draw.Visible = false
                end
                if elem.Text then
                    elem.Text.Visible = false
                end
                if elem.Check then
                    elem.Check.Visible = false
                end
                if elem.Bar then
                    elem.Bar.Visible = false
                end
                if elem.Fill then
                    elem.Fill.Visible = false
                end
                if elem.Label then
                    elem.Label.Visible = false
                end
                if elem.Box then
                    elem.Box.Visible = false
                end
                if elem.ValueText then
                    elem.ValueText.Visible = false
                end
                if elem.OptionTexts then
                    for _, t in ipairs(elem.OptionTexts) do
                        t.Visible = false
                    end
                end
                if elem.Buttons then
                    for _, b in ipairs(elem.Buttons) do
                        b.Box.Visible = false
                        b.Text.Visible = false
                    end
                end
            end
        end
    end
    if self.Resizer then
        self.Resizer.Position = v2(self.X + self.W - 15, self.Y + self.H - 15)
        self.Resizer.Size = v2(15, 15)
        self.Resizer.Visible = self.Visible
    end
end
function MatchaLib:UpdateLoop()
    spawn(
        function()
            while true do
                self:Update()
                task.wait()
            end
        end
    )
end
