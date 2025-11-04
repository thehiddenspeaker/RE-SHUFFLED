require "rmagick"
include Magick

MAX_WIDTH = 800

testFrame = Image.read("Images/Templates/mtg_colorless_frame.png")[0]

inputText = "Vigilance, trample, haste
(W)(U)(B)(R)(G): You may play target Elemental card from your graveyard without paying its mana cost."

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

def addManaText(text, draw, frame, x, y)
    newX = 0
    newY = 0
    splitText = text.split(/(\(.\))/).reject!(&:empty?)
    puts splitText.inspect

    splitText.each do |item|
        if (item.match(/(\(.\))/)) then
            iconFile = $icons[item.upcase]
            icon = Image.read(iconFile) { |img|
                img.format = 'SVG'
                img.background_color = 'transparent' }.first
            icon.change_geometry!('38x38!') { |cols, rows, icon_img| icon_img.resize!(cols, rows) }
            if (newX > MAX_WIDTH) then
                newY += 55
                newX = 0
            end
            frame.composite!(icon, x + newX, y + newY + 2, OverCompositeOp)
            newX += 42
        else
            item.split("\n").each do |line|
                line.split.each do |word|
                    width = draw.get_type_metrics(frame, word + " ").width
                    if (newX + width < MAX_WIDTH) then
                        draw.annotate(frame, 0, 0, x + newX, y + newY, word + " ") { |ann| ann.gravity = NorthWestGravity }
                        newX += width
                    else
                        newY += 55
                        newX = 0
                        draw.annotate(frame, 0, 0, x + newX, y + newY, word + " ") { |ann| ann.gravity = NorthWestGravity }
                        newX += width
                    end
                end
                newY += 65
                newX = 0
            end
        end
    end

    return frame
end

draw = Draw.new
draw.fill = "black"
draw.pointsize = 46
draw.font = "Fonts/MPlantin-Regular.ttf"

newImage = addManaText(inputText, draw, testFrame, 95, 900)

newImage.write("testImage.png")