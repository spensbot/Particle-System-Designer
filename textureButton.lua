local TextureButton = {}
TextureButton.__index = TextureButton

function newTextureButton(imageName)
    local tb = {}
    tb.imageName = imageName
    tb.textureImage = love.graphics.newImage(TEXTURE_DIRECTORY..imageName)
    tb.x = 0
    tb.y = 0
    tb.imageWidth= tb.textureImage:getWidth()
    tb.scaleFactor = TEXTURE_BUTTON_WIDTH/tb.imageWidth

    return setmetatable(tb, TextureButton)
end

function TextureButton:update()
    if mouseDown
        and mouseX > self.x 
        and mouseX < self.x + TEXTURE_BUTTON_WIDTH
        and mouseY > self.y
        and mouseY < self.y + TEXTURE_BUTTON_WIDTH
        then 
        pSystem:setTexture(self.textureImage)
    end
end

function TextureButton:draw()
    love.graphics.setColor(.25,.25,.25,1)
    love.graphics.rectangle('line', self.x, self.y, TEXTURE_BUTTON_WIDTH, TEXTURE_BUTTON_WIDTH)
    love.graphics.draw(self.textureImage, self.x, self.y, 0, self.scaleFactor, self.scaleFactor)
    love.graphics.setColor(WHITE)
    love.graphics.printf(self.imageName, self.x, self.y, TEXTURE_BUTTON_WIDTH, 'center')
end

function TextureButton:setXY(x, y)
    self.x = x 
    self.y = y 
end