require 'simple-slider'
require 'colorPalette'
require 'textureButton'

--GUI Params
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080
PADDING = 20
PADDING2 = 5
SLIDER_LENGTH = 150
SLIDER_X = SLIDER_LENGTH/2 + PADDING
SLIDER_SPACING = 20
TEXTURE_BUTTON_WIDTH = 50
COLOR_PALETTE_WIDTH = 160
PALETTE_IMAGE_PATH = 'palette_160.png'

--System Params
MAX_PARTICLES = 20000
TEXTURE_DIRECTORY = 'textures/'
TEXTURE_IMAGE_FORMAT = '.png'

--Other Global Params
BLACK = {0,0,0,1}
WHITE = {1,1,1,1}


function love.load()
    --Setup the window
    love.window.setTitle('Particle Effect Generator')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=false, vsync=true, minwidth=400, minheight=300})

    --Setup effect sliders
    sliderStyle = {
        ['width'] = SLIDER_SPACING - 5,
        ['orientation'] = 'horizontal',
        ['track'] = 'line',
        ['knob'] = 'rectangle'
    }
    sliders = { --This table contains effect sliders and slider subgroup labels
        [1] = 'Spawn Parameters:',
        [2] = newSlider(0, 0, SLIDER_LENGTH, 1000, 0, 5000, function (v) pSystem:setEmissionRate(v) end, sliderStyle, 'Emission Rate'),
        [3] = newSlider(0, 0, SLIDER_LENGTH, 2, 0.1, 5, function (v) pSystem:setParticleLifetime(v*.5, v) end, sliderStyle, 'Lifetime'),
        [4] = newSlider(0, 0, SLIDER_LENGTH, 10, 0, 50, function (v) pSystem:setEmissionArea('normal', v, v) end, sliderStyle, 'Emission Area'),
        [5] = 'Velocity Parameters:',
        [6] = newSlider(0, 0, SLIDER_LENGTH, 250, 0, 1000, function (v) pSystem:setSpeed(v*.5, v) end, sliderStyle, 'Speed'),
        [7] = newSlider(0, 0, SLIDER_LENGTH, 20, 0, 1000, function (v) pSystem:setRadialAcceleration(v*.5, v) end, sliderStyle, 'Radial Acceleration Max'),
        [8] = newSlider(0, 0, SLIDER_LENGTH, 0, 0, 10, function (v) pSystem:setLinearDamping(v*.5, v) end, sliderStyle, 'Linear Damping'),
        [9] = 'Direction Parameters:',
        [10] = newSlider(0, 0, SLIDER_LENGTH, .73, 0, 6.28, function (v) pSystem:setDirection(-v) end, sliderStyle, 'Direction (Radians)'),
        [11] = newSlider(0, 0, SLIDER_LENGTH, 0, 0, 6.28, function (v) pSystem:setSpread(v) end, sliderStyle, 'Spread (Rads)'),
        [12] = 'Size Parameters:',
        [13] = newSlider(0, 0, SLIDER_LENGTH, 1, 0, 5, function (v) startSize = v end, sliderStyle, 'Start Size'),
        [14] = newSlider(0, 0, SLIDER_LENGTH, 3, 0, 5, function (v) midSize = v end, sliderStyle, 'Mid Size'),
        [15] = newSlider(0, 0, SLIDER_LENGTH, .1, 0, 5, function (v) endSize = v end, sliderStyle, 'End Size'),
        [16] = newSlider(0, 0, SLIDER_LENGTH, 0, 0, 1, function (v) pSystem:setSizeVariation(v) end, sliderStyle, 'Size Variation'),
        [17] = 'Rotation Parameters:',
        [18] = newSlider(0, 0, SLIDER_LENGTH, 1, 0, 20, function (v) pSystem:setSpin(v*.5, v) end, sliderStyle, 'Spin (Rads/sec)'),
        [19] = newSlider(0, 0, SLIDER_LENGTH, 0, -500, 500, function (v) pSystem:setTangentialAcceleration(v*.5, v) end, sliderStyle, 'Tangential Acceleration')
    }
    setSliderXY()

    --Setup the particle system and texture buttons
    texture = love.graphics.newImage('textures/cloud.png')
    pSystem = love.graphics.newParticleSystem(texture, MAX_PARTICLES)
    textureButtons = {}
    populateTextureButtons()
    setTextureXY()

    --Setup color palettes
    colorPalettes = {}
    populateColorPalettes()

    --Initialize globals
    r1,g1,b1,a1,r2,g2,b2,a2,r3,g3,b3,a3 = 1,1,1,1,1,1,1,1,1,1,1,1
    mouseDown = false
    mouseX = 0
    mouseY = 0
    startSize = 1
    endSize = 1
    thirdColor = true
end


function love.resize()
    WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
    setSliderXY()
    setTextureXY()
    populateColorPalettes()
end


function love.update(dt)
    --Update global mouse status variables
    mouseDown = love.mouse.isDown(1)
    mouseX, mouseY = love.mouse.getPosition()

    --Update sliders
    for i, slider in pairs(sliders) do
        if type(slider) ~= 'string' then 
            slider:update()
        end
    end

    --Update texture buttons
    for i, textureButton in pairs(textureButtons) do
        textureButton:update()
    end
    
    --Update color palettes
    r1,g1,b1,a1 = colorPalettes [1]:update()
    r2,g2,b2,a2 = colorPalettes [2]:update()
    r3,g3,b3,a3 = colorPalettes [3]:update()
    
    --Update pSystem
    if thirdColor then 
        pSystem:setColors(r1,g1,b1,a1,r2,g2,b2,a2,r3,g3,b3,a3)
    else
        pSystem:setColors(r1,g1,b1,a1,r2,g2,b2,a2)
    end
    pSystem:setSizes(startSize, midSize, endSize)
    pSystem:update(dt)
end

function love.draw()
    --Draw particle system
    love.graphics.clear()
    love.graphics.setColor(WHITE)
    love.graphics.draw(pSystem, WINDOW_WIDTH/2, WINDOW_HEIGHT*2/3)

    --Draw all sliders and Labels
    love.graphics.setLineWidth(4)
    love.graphics.setColor(.25,.75,.75,1)
    for i, slider in pairs(sliders) do
        if type(slider) == 'string' then 
            love.graphics.printf(slider, PADDING, SLIDER_SPACING*i - 6, WINDOW_WIDTH, 'left')
        else
            slider:draw()
        end
    end

    --Draw color palettes
    for i, colorPalette in pairs(colorPalettes) do
        if i == 3 then 
            if thirdColor then 
                colorPalette:draw()
            end
        else 
            colorPalette:draw()
        end
    end

    --Draw texture buttons
    for i, textureButton in pairs(textureButtons) do
        textureButton:draw()
    end
    love.graphics.printf("Available Textures:", 0, textureLabelY - 30, WINDOW_WIDTH, 'center')

    infoPrint()
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    end
end

--   *********** HELPER FUNCTIONS BELOW ***********

function infoPrint() --Print helpful info to screen top/center
    love.graphics.printf('Particle Count: '..string.format('%.2f',pSystem:getCount()), 0, 10, WINDOW_WIDTH, 'center')
    love.graphics.printf('Frames Per Second: '..string.format('%.2f', love.timer.getFPS()), 0, 30, WINDOW_WIDTH, 'center')
end

function setSliderXY()
    for i, slider in pairs(sliders) do
        if type(slider) ~= 'string' then
            slider:setXY(SLIDER_X, SLIDER_SPACING*i)
        end
    end
end

function populateTextureButtons() --Look for texutre files of specified type in the specified directory.
                                    --Add a textureButton to the table for each.
    local textureFiles = love.filesystem.getDirectoryItems( TEXTURE_DIRECTORY)
    for i, file in pairs(textureFiles) do
        if file:sub(-4,-1) == TEXTURE_IMAGE_FORMAT then 
            table.insert(textureButtons, newTextureButton(file)) 
        end
    end
end

function setTextureXY()
    local maxWidth = WINDOW_WIDTH - PADDING*4 - COLOR_PALETTE_WIDTH*2
    local totalWidth = #textureButtons * TEXTURE_BUTTON_WIDTH + (#textureButtons-1) * PADDING2
    local rowWidth
    if totalWidth > maxWidth then 
        rowWidth = maxWidth - maxWidth%(TEXTURE_BUTTON_WIDTH + PADDING2)
    else
        rowWidth = totalWidth
    end
    local rowStartX = WINDOW_WIDTH/2 - rowWidth/2
    local buttonY = WINDOW_HEIGHT - PADDING2 - TEXTURE_BUTTON_WIDTH
    local buttonX = rowStartX
    for i, textureButton in pairs(textureButtons) do
        textureButton:setXY(buttonX, buttonY)
        buttonX = buttonX + TEXTURE_BUTTON_WIDTH + PADDING2
        if buttonX + TEXTURE_BUTTON_WIDTH > rowStartX+rowWidth then 
            buttonX = rowStartX
            buttonY = buttonY - TEXTURE_BUTTON_WIDTH - PADDING2
        end
    end
    textureLabelY = buttonY
end

function populateColorPalettes()
    local cPY = WINDOW_HEIGHT - COLOR_PALETTE_WIDTH - PADDING
    local cP1X = PADDING
    local cP2X = WINDOW_WIDTH - COLOR_PALETTE_WIDTH - PADDING
    colorPalettes [1] = newColorPalette(PALETTE_IMAGE_PATH, cP1X, cPY, 'First Color')
    colorPalettes [2] = newColorPalette(PALETTE_IMAGE_PATH, cP2X, cPY, 'Second Color')
    colorPalettes [3] = newColorPalette(PALETTE_IMAGE_PATH, cP2X, cPY - COLOR_PALETTE_WIDTH -60 , 'Third Color')
end