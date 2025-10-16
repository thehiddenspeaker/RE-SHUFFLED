require 'rmagick'
include Magick
require_relative "Card"


TEMPLATE_PATH = "Images/Templates/mtg_colorless_frame.png"
puts "Enter Name"
name = gets
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
power = gets.chomp



stats = Card.new(name, manacost, type, subType, rarity, rules, flavor, power, "")
stats.displayCard


if (!stats.stats.empty?)
TEMPLATE_PATH = "Images/Templates/mtg_colorless_frame_creature.png"
end

card = Image.read(TEMPLATE_PATH).first

draw = Draw.new
draw.fill = "black"

def wrap_text(text, max_chars)
  text.split("\n").flat_map do |line|
    line.scan(/.{1,#{max_chars}}(?:\s+|$)/).map(&:strip)
  end.join("\n")
end


# ---- Name bar ----
draw.pointsize = 52
draw.annotate(card, 0, 0, 90, 70, stats.name) do |ann|
  ann.gravity = NorthWestGravity
end

draw.pointsize = 52
draw.annotate(card, 0, 0, 850, 70, stats.manaCost) do |ann|
  ann.gravity = NorthWestGravity
end

# ---- Type line ----
draw.pointsize = 48
draw.annotate(card, 0, 0, 90, 800, stats.type) do |ann|
  ann.gravity = NorthWestGravity
end

# ---- Description box ----
draw.pointsize = 46
wrapped_desc = wrap_text(stats.rules, 40)
draw.annotate(card, 0, 0, 95, 880, wrapped_desc) do |ann|
  ann.gravity = NorthWestGravity
end

draw.pointsize = 46
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


card.write("output_card.png")
