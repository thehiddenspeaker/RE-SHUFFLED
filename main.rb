require 'rmagick'
include Magick
require_relative "Card"


TEMPLATE_PATH = "Images/Templates/mtg_colorless_frame.png"
puts "Welcome to Re-Shuffled\n A project that creates a trading card automatically or based on user inputs\n Include your card details: "
puts "Enter card name:"
name = gets

puts "Enter mana cost:"
manacost = gets
puts "Enter type:"
type = gets
puts "Enter subtype:"
subType = gets
puts "Enter rarity:"
rarity = gets
puts "Enter rules:"
rules = gets
puts "Enter flavor:"
flavor = gets
puts "Enter power/toughness:"
stats = gets
puts "Enter art filepath:"
artFilepath = gets.chomp

stats = Card.new(name, manacost, type, subType, rarity, rules, flavor, stats, artFilepath)
stats.displayCard


if (!stats.stats.chomp.empty?)
TEMPLATE_PATH = "Images/Templates/mtg_colorless_frame_creature.png"
else
TEMPLATE_PATH = "Images/Templates/mtg_colorless_frame.png"
end

card = Image.read(TEMPLATE_PATH).first

draw = Draw.new
draw.fill = "black"
draw.font = "Fonts/Beleren2016-Bold.ttf"

def wrap_text(text, max_chars)
  text.split("\n").flat_map do |line|
    line.scan(/.{1,#{max_chars}}(?:\s+|$)/).map(&:strip)
  end.join("\n")
end


# ---- Name bar ----
draw.pointsize = 52
draw.annotate(card, 0, 0, 90, 80, stats.name) do |ann|
  ann.gravity = NorthWestGravity
end

draw.pointsize = 52
draw.annotate(card, 1000, 100, 90, 80, stats.manaCost) do |ann|
  ann.gravity = EastGravity
end

# ---- Type line ----
draw.pointsize = 48
if (!stats.subType.chomp.empty?)
  typeString = stats.type.chomp + ' — ' + stats.subType
else
  typeString = stats.type
end
draw.annotate(card, 0, 0, 90, 810, typeString) do |ann|
  ann.gravity = NorthWestGravity
end

# ---- Stats box ----
if(!stats.stats.empty?)
    draw.pointsize = 52
    draw.annotate(card, 40, 20, 845, 1310, "#{stats.stats}") do |ann|
    ann.gravity = CenterGravity
    end
end

# ---- Description box ----
draw.pointsize = 46
draw.font = "Fonts/MPlantin-Regular.ttf"
wrapped_desc = wrap_text(stats.rules, 40)
draw.annotate(card, 0, 0, 95, 900, wrapped_desc) do |ann|
  ann.gravity = NorthWestGravity
end

draw.pointsize = 46
draw.font = "Fonts/MPlantin-Italic-Regular.ttf"
wrapped_desc = wrap_text(stats.flavor, 40)
draw.annotate(card, 0, 0, 95, 1090, wrapped_desc) do |ann|
  ann.gravity = NorthWestGravity
end


artImage = Image.read(artFilepath).first
artImage.change_geometry!('850x621!') { |cols, rows, img|
    img.resize!(cols, rows)
}
temp = Image.new(1005,1407) do |img|
  img.background_color = 'none'
end
temp.composite!(artImage, 77, 159, SrcOverCompositeOp)
card = temp.composite(card, 0, 0, SrcOverCompositeOp)

card.write("output_card.png")
