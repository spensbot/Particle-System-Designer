local colorPalette = {}
colorPalette.__index = colorPalette

function newColorPalette(imagePath, x, y, label)
    local cp = {}
    cp.paletteImage = love.graphics.newImage(imagePath)
    cp.paletteImageData = love.image.newImageData(imagePath)
    cp.x = x
    cp.y = y
    cp.width = COLOR_PALETTE_WIDTH
    cp.height = cp.width
    cp.scaleFactor = cp.width/cp.paletteImage:getWidth()
    cp.circleX = cp.x + cp.width/2
    cp.circleY = cp.y + cp.width/2
    cp.r,cp.g,cp.b,cp.a = 1,1,1,1
    cp.previewX = cp.x - PADDING2
    cp.previewY = cp.y - PADDING2 -PADDING
    cp.previewWidth = cp.width + PADDING2*2
    cp.previewHeight = cp.width + PADDING2*2 + PADDING
    cp.label = label
    cp.slider = newSlider(cp.x + cp.width/2, cp.y - 40, cp.width, 1, 0, 1, function (v) cp.a = v end, sliderStyle, 'alpha')

    return setmetatable(cp, colorPalette)
end

function colorPalette:update()
    if mouseDown 
        and mouseX > self.x 
        and mouseX < self.x + self.width
        and mouseY > self.y
        and mouseY < self.y + self.height
        then 
        self.circleX = mouseX
        self.circleY = mouseY
        self.r, self.g, self.b= self.paletteImageData:getPixel(mouseX - self.x, mouseY - self.y)
    end
    self.slider:update()
    return self.r,self.g,self.b,self.a
end

function colorPalette:draw()
    love.graphics.setColor(self.r, self.g, self.b, self.a)
    love.graphics.rectangle('fill', self.previewX, self.previewY, self.previewWidth, self.previewHeight, 20,20)
    love.graphics.setColor(BLACK)
    love.graphics.printf(self.label, self.previewX, self.previewY, self.previewWidth, 'center')
    love.graphics.setColor(WHITE)
    love.graphics.setLineWidth(2)
    love.graphics.draw(self.paletteImage, self.x, self.y, 0, self.scaleFactor, self.scaleFactor)
    love.graphics.circle('line', self.circleX, self.circleY, 5)
    self.slider:draw()
end