require "rmagick"
include Magick

MAX_WIDTH = 830

testFrame = Image.read("Images/Templates/mtg_black_frame.png")[0]

inputMana = "(1)(B)"

inputText = "At the beginning of combat on your turn, exile up to one target card from a graveyard.
(1)(B): Adapt 2.
Whenever one or more +1/+1 counters are put on this creature, put a creature card exiled with this creature onto the battlefield under your control with a finality counter on it. It gains haste. Sacrifice it at the beginning of the next end step."

$icons = {
    "(0)" => "Images/Templates/Icons/0.svg",
    "(1)" => "Images/Templates/Icons/1.svg",
    "(2)" => "Images/Templates/Icons/2.svg",
    "(3)" => "Images/Templates/Icons/3.svg",
    "(4)" => "Images/Templates/Icons/4.svg",
    "(5)" => "Images/Templates/Icons/5.svg",
    "(6)" => "Images/Templates/Icons/6.svg",
    "(7)" => "Images/Templates/Icons/7.svg",
    "(8)" => "Images/Templates/Icons/8.svg",
    "(9)" => "Images/Templates/Icons/9.svg",
    "(10)" => "Images/Templates/Icons/10.svg",
    "(11)" => "Images/Templates/Icons/11.svg",
    "(12)" => "Images/Templates/Icons/12.svg",
    "(13)" => "Images/Templates/Icons/13.svg",
    "(14)" => "Images/Templates/Icons/14.svg",
    "(15)" => "Images/Templates/Icons/15.svg",
    "(16)" => "Images/Templates/Icons/16.svg",
    "(17)" => "Images/Templates/Icons/17.svg",
    "(18)" => "Images/Templates/Icons/18.svg",
    "(19)" => "Images/Templates/Icons/19.svg",
    "(20)" => "Images/Templates/Icons/20.svg",
    "(B)" => "Images/Templates/Icons/B.svg",
    "(C)" => "Images/Templates/Icons/C.svg",
    "(G)" => "Images/Templates/Icons/G.svg",
    "(R)" => "Images/Templates/Icons/R.svg",
    "(T)" => "Images/Templates/Icons/T.svg",
    "(U)" => "Images/Templates/Icons/U.svg",
    "(W)" => "Images/Templates/Icons/W.svg",
    "(X)" => "Images/Templates/Icons/X.svg"
}

$pointsize = 36

def addManaText(text, draw, frame, pSize)
    newX = 0
    newY = 0
    splitText = text.split(/(\(\w\)|\(\w\w\))/).reject {|elem| elem.empty?}
    splitText ||= [text]

    splitText.each do |item|
        if (item.match(/(\(\w\)|\(\w\w\))/)) then
            iconFile = $icons.fetch(item.upcase) { nil }
            if !iconFile.nil? then
                icon = Image.read(iconFile) { |img|
                    img.format = 'SVG'
                    img.background_color = 'transparent' }.first
                iconDim = pSize * 38/46
                icon.change_geometry!("#{iconDim}x#{iconDim}!") { |cols, rows, icon_img| icon_img.resize!(cols, rows) }
                if (newX > MAX_WIDTH) then
                    newY += pSize * 55/46
                    newX = 0
                end
                frame.composite!(icon, 85 + newX, 900 + newY + 2, OverCompositeOp)
                newX += pSize * 42/46
            end
        else
            item.split(/(?<=\s)|(?=\s)/).each do |word|
                if word == "\n" then
                    newY += pSize * 65/46
                    newX = 0
                elsif word.match(/\s+/) then
                    newX += pSize * 10/46
                else
                    width = draw.get_type_metrics(frame, word).width
                    if (newX + width < MAX_WIDTH) then
                        draw.annotate(frame, 0, 0, 85 + newX, 900 + newY, word) { |ann| ann.gravity = NorthWestGravity }
                        newX += width
                    else
                        newY += pSize * 50/46
                        newX = 0
                        draw.annotate(frame, 0, 0, 85 + newX, 900 + newY, word) { |ann| ann.gravity = NorthWestGravity }
                        newX += width
                    end
                end
            end
        end
    end

    return frame
end

def addManaCost(text, draw, frame)
    x = 0
    splitText = text.split(/(\(\w\)|\(\w\w\))/).reject {|elem| elem.empty?}
    splitText.reverse_each do |item|
        if (item.match(/(\(\w\)|\(\w\w\))/)) then
            iconFile = $icons.fetch(item.upcase) { nil }
            if !iconFile.nil? then
                icon = Image.read(iconFile) { |img|
                    img.format = 'SVG'
                    img.background_color = 'transparent' }.first
                icon.change_geometry!("48x48!") { |cols, rows, icon_img| icon_img.resize!(cols, rows) }
                blackIcon = icon.modulate(0.1, 0, 1)
                frame.composite!(blackIcon, 878 - x, 84, OverCompositeOp)
                frame.composite!(icon, 880 - x, 80, OverCompositeOp)
                x += 55
            end
        end
    end
    return frame
end

if __FILE__ == $0 then
    draw = Draw.new
    draw.fill = "black"
    draw.pointsize = $pointsize
    draw.font = "Fonts/MPlantin-Regular.ttf"

    newImage = addManaText(inputText, draw, testFrame, $pointsize)
    newImage = addManaCost(inputMana, draw, newImage)

    newImage.write("testImage.png")
end