require 'rmagick'
include Magick
require_relative "Card"


TEMPLATE_PATH = "Images/Templates/mtg_colorless_frame.png"
puts "Enter Name"
name = gets

if name.include? "test"
  name = 'Sol Ring'
  manacost = '(1)'
  type = 'Artifact'
  rules = '(T): Add (C)(C).'
  flavor = "Lost to time is the artificer’s art of trapping light from a distant star in a ring of purest gold."
  artFilepath = "Images/Sol_Ring.webp"
  stats = ''
  subType = ''
  rarity = ''
else
  puts "Enter mana cost"
  manacost = gets
  puts "Enter type"
  type = gets
  puts "Enter subtype"
  subType = gets
  puts "Enter rarity"
  rarity = gets
  puts "Enter rules"
  rules = gets
  puts "Enter flavor"
  flavor = gets
  puts "Enter power/toughness"
  stats = gets
  puts "Enter art filepath"
  artFilepath = gets.chomp
end


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
draw.font = "Beleren2016-Bold"

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
draw.annotate(card, 0, 0, 850, 80, stats.manaCost) do |ann|
  ann.gravity = NorthWestGravity
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

# ---- Description box ----
draw.pointsize = 46
draw.font = "MPlantin"
wrapped_desc = wrap_text(stats.rules, 40)
draw.annotate(card, 0, 0, 95, 900, wrapped_desc) do |ann|
  ann.gravity = NorthWestGravity
end

draw.pointsize = 46
draw.font = "MPlantin-Italic"
wrapped_desc = wrap_text(stats.flavor, 40)
draw.annotate(card, 0, 0, 95, 1090, wrapped_desc) do |ann|
  ann.gravity = NorthWestGravity
end

if(!stats.stats.empty?)
    draw.pointsize = 46
    draw.annotate(card, 0, 0, 830, 1260, "#{stats.stats}") do |ann|
    ann.gravity = NorthWestGravity
    end
end

artImage = Image.read(artFilepath).first
finalCard = Image.read(TEMPLATE_PATH).first
artImage.change_geometry!('1005x1407') { |cols, rows, img|
    img.resize!(cols, rows)
}

finalCard.composite!(artImage, 0, 100, Magick::SrcOverCompositeOp)
finalCard.composite!(card, 0, 0, Magick::SrcOverCompositeOp)

finalCard.write("output_card.png")
