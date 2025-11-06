require "rmagick"
include Magick

MAX_WIDTH = 830

#testFrame = Image.read("Images/Templates/mtg_black_frame.png")[0]

#inputMana = "(1)(B)"

#inputText = "At the beginning of combat on your turn, exile up to one target card from a graveyard.
#(1)(B): Adapt 2.
#Whenever one or more +1/+1 counters are put on this creature, put a creature card exiled with this creature onto the battlefield under your control with a finality counter on it. It gains haste. Sacrifice it at the beginning of the next end step."

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

$rarities = {
    "common" => "Images/Templates/Rarities/C.svg",
    "uncommon" => "Images/Templates/Rarities/U.svg",
    "rare" => "Images/Templates/Rarities/R.svg",
    "mythic" => "Images/Templates/Rarities/M.svg"
}

$frames = {
    "B" => ["Images/Templates/mtg_black_frame.png", "Images/Templates/mtg_black_frame_creature.png"],
    "BG" => ["Images/Templates/mtg_bg_frame.png", "Images/Templates/mtg_bg_frame_creature.png"],
    "BR" => ["Images/Templates/mtg_br_frame.png", "Images/Templates/mtg_br_frame_creature.png"],
    "BU" => ["Images/Templates/mtg_ub_frame.png", "Images/Templates/mtg_ub_frame_creature.png"],
    "BW" => ["Images/Templates/mtg_wb_frame.png", "Images/Templates/mtg_wb_frame_creature.png"],
    "G" => ["Images/Templates/mtg_green_frame.png", "Images/Templates/mtg_green_frame_creature.png"],
    "GR" => ["Images/Templates/mtg_rg_frame.png", "Images/Templates/mtg_rg_frame_creature.png"],
    "GU" => ["Images/Templates/mtg_ug_frame.png", "Images/Templates/mtg_ug_frame_creature.png"],
    "GW" => ["Images/Templates/mtg_wg_frame.png", "Images/Templates/mtg_wg_frame_creature.png"],
    "R" => ["Images/Templates/mtg_red_frame.png", "Images/Templates/mtg_red_frame_creature.png"],
    "RW" => ["Images/Templates/mtg_wr_frame.png", "Images/Templates/mtg_wr_frame_creature.png"],
    "RU" => ["Images/Templates/mtg_ur_frame.png", "Images/Templates/mtg_ur_frame_creature.png"],
    "U" => ["Images/Templates/mtg_blue_frame.png", "Images/Templates/mtg_blue_frame_creature.png"],
    "UW" => ["Images/Templates/mtg_wu_frame.png", "Images/Templates/mtg_wu_frame_creature.png"],
    "W" => ["Images/Templates/mtg_white_frame.png", "Images/Templates/mtg_white_frame_creature.png"],
    "C" => ["Images/Templates/mtg_colorless_frame.png", "Images/Templates/mtg_colorless_frame_creature.png"],
    "M" => ["Images/Templates/mtg_multicolor_frame.png", "Images/Templates/mtg_multicolor_frame_creature.png"]
}

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
                        newY += pSize * 48/46
                        newX = 0
                        draw.annotate(frame, 0, 0, 85 + newX, 900 + newY, word) { |ann| ann.gravity = NorthWestGravity }
                        newX += width
                    end
                end
            end
        end
    end
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
end

def detectFrame(text)
    colorID = ""
    mana = text.split(/(\(\w\)|\(\w\w\))/).reject {|elem| elem.empty?}
    mana.each do |m|
        c = m.upcase.match(/[WUBRG]/).to_s
        if !colorID.include?(c) then
            colorID += c
        end
    end
    if colorID == "" then colorID = "C" end
    if colorID.length > 2 then colorID = "M" end
    colorID.chars.sort.join
    return $frames[colorID]
end

def addRarity(text, draw, frame)
    rarityIcon = $rarities.fetch(text.downcase) { nil }
    if !rarityIcon.nil? then
        icon = Image.read(rarityIcon) { |img|
            img.format = 'SVG'
            img.background_color = 'transparent' }.first
        icon.change_geometry!("60x60!") { |cols, rows, icon_img| icon_img.resize!(cols, rows) }
        frame.composite!(icon, 865, 800, OverCompositeOp)
    end
end

if __FILE__ == $0 then
    pointsize = 36

    draw = Draw.new
    draw.fill = "black"
    draw.pointsize = pointsize
    draw.font = "Fonts/MPlantin-Regular.ttf"

    #newImage = addManaText(inputText, draw, testFrame, pointsize)
    #newImage = addManaCost(inputMana, draw, newImage)

    #newImage.write("testImage.png")

    detectFrame("(B)(B)(W)")
end