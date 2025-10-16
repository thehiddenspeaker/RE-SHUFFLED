require "rmagick"

class Card
    def initialize(name = '', manaCost = '', type = '', subType = '', rarity = '', rules = '', flavor = '', stats = '', art = '')
        @name = name
        @manaCost = manaCost
        @type = type
        @subType = subType
        @rarity = rarity
        @rules = rules
        @flavor = flavor
        @stats = stats
        @art = art
    end

    def displayCard
        puts "Name: #{@name}\n"\
             "Mana Cost: #{@manaCost}\n"\
             "Type: #{@type}\n"\
             "Subtype: #{@subType}\n"\
             "Rarity: #{@rarity}\n"\
             "Rules Text: #{@rules}\n"\
             "Flavor Text: #{@flavor}\n"\
             "Stats: #{@stats}"
    end
end

if __FILE__ == $0
    card = Card.new('Sol Ring', '(1)', 'Artifact', '', 'Uncommon', '(T): Add (C)(C).', '"All creation in a single point, the point of all creation in all." -Sunstar loop-mantra', '')

    card.displayCard

    test = Magick::ImageList.new("Images/Sol_Ring.webp")
    tempFile = "Images/tempfile.webp"
    test.write(tempFile)
    system("start #{tempFile}")
end