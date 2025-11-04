require "rmagick"
include Magick

MAX_WIDTH = 700

testFrame = Image.read("Images/Templates/mtg_colorless_frame.png")[0]

inputText = "(X)(U) This is some hella text. Add (R) or something."

def addManaText(text, draw, frame, x, y)
    iconPositions = []
    icon = Image.read("Images/Templates/Icons/R.svg") { |img|
        img.format = 'SVG'
        img.background_color = 'transparent' }.first
    icon.change_geometry!('40x40!') { |cols, rows, icon_img| icon_img.resize!(cols, rows) }
    newX = 0
    newY = 0
    splitText = text.split(/(\(.\))/).reject!(&:empty?)

    splitText.each do |item|
        if (item.match(/(\(.\))/)) then
            if (newX < MAX_WIDTH) then
                iconPositions.push([newX, newY])
                newX += 50
            else
                newY += 55
                newX = 0
                iconPositions.push([newX, newY])
                newX += 50
            end
        else
            if (newX < MAX_WIDTH) then
                draw.annotate(frame, 0, 0, x + newX, y + newY, item) { |ann| ann.gravity = NorthWestGravity }
                newX += draw.get_type_metrics(frame, item).width
            else
                newY += 55
                newX = 0
                draw.annotate(frame, 0, 0, x + newX, y + newY, item) { |ann| ann.gravity = NorthWestGravity }
                newX += draw.get_type_metrics(frame, item).width
            end
        end
    end

    iconPositions.each do |pos|
        frame.composite!(icon, x + pos[0], y + pos[1] + 1, OverCompositeOp)
    end
    return frame
end

draw = Draw.new
draw.fill = "black"
draw.pointsize = 46
draw.font = "Fonts/MPlantin-Regular.ttf"

newImage = addManaText(inputText, draw, testFrame, 95, 900)

newImage.write("testImage.png")