require "rmagick"

class Card
    def initialize(name = '', manaCost = '', type = '', subType = '', rarity = '', rules = '', flavor = '', stats = '', art = '')
        @name = name                     # String, ex: 'Krark, the Thumbless'
        @manaCost = manaCost             # String of mana values, ex: '(1)(R)' for 1 generic mana and one red mana
        @type = type                     # String, most typically one of the following: 'Creature', 'Sorcery', 'Instant', 'Enchantment', 'Artifact'
        @subType = subType               # String, often left blank, used most often with creatures, enchantments, and artifacts, ex: 'Goblin Warrior'
        @rarity = rarity                 # String, only one of the following: 'Common', 'Uncommon', 'Rare', 'Mythic'
        @rules = rules                   # String, ex: 'Whenever you cast an instant or sorcery spell, flip a coin. If you lose the flip, return that spell to its owner’s hand. If you win the flip, copy that spell, and you may choose new targets for the copy.'
        @flavor = flavor                 # String, ex: 'Double or nothing.'
        @stats = stats                   # String of the format power/toughness, ex: '2/2'
        @art = art                       # String, relative filepath of art to be used
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