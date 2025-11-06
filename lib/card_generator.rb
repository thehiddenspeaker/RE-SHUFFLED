require_relative "addManaText.rb"

class CardGenerator
  def self.wrap_text(text, max_chars)
    text.split("\n").flat_map do |line|
      line.scan(/.{1,#{max_chars}}(?:\s+|$)/).map(&:strip)
    end.join("\n")
  end

  def self.generate(card)
    # pick template
    template_path = card.stats.strip.empty? ? 
      "Images/Templates/mtg_colorless_frame.png" :
      "Images/Templates/mtg_colorless_frame_creature.png"

    img = Magick::Image.read(template_path).first
    draw = Magick::Draw.new
    draw.fill = "black"
    draw.font = "Fonts/Beleren2016-Bold.ttf"

    # ---- Name bar ----
    draw.pointsize = 52
    draw.annotate(img, 0, 0, 90, 85, card.name) { |ann| ann.gravity = Magick::NorthWestGravity }
    img = addManaCost(card.manaCost, draw, img)

    # ---- Type line ----
    typeString = card.subType.strip.empty? ? card.type : "#{card.type} — #{card.subType}"
    draw.pointsize = 48
    draw.annotate(img, 0, 0, 90, 810, typeString) { |ann| ann.gravity = Magick::NorthWestGravity }

    # ---- Stats box ----
    unless card.stats.strip.empty?
      draw.pointsize = 52
      draw.annotate(img, 40, 20, 845, 1290, card.stats) { |ann| ann.gravity = Magick::CenterGravity }
    end

    # ---- Rules box ----
    draw.pointsize = 46
    draw.font = "Fonts/MPlantin-Regular.ttf"
    wrapped_rules = wrap_text(card.rules, 40)   
    draw.annotate(img, 0, 0, 95, 900, wrapped_rules) { |ann| ann.gravity = Magick::NorthWestGravity }

    # ---- Flavor text ----
    draw.font = "Fonts/MPlantin-Italic-Regular.ttf"
    wrapped_flavor = wrap_text(card.flavor, 40)
    draw.annotate(img, 0, 0, 95, 1090, wrapped_flavor) { |ann| ann.gravity = Magick::NorthWestGravity }

    # --- Art ---
    art = Magick::Image.read(card.art).first
    art.change_geometry!('850x621!') { |cols, rows, art_img| art_img.resize!(cols, rows) }
    final_card = img.composite(art, 77, 159, Magick::SrcOverCompositeOp)

    # --- Save output ---
    Dir.mkdir("public/output") unless Dir.exist?("public/output")
    output_filename = "#{card.name.strip.gsub(/\s+/, '_')}.png"
    output_path = "public/output/#{output_filename}"
    final_card.write(output_path)

# Return URL path
timestamp = Time.now.to_i
"/output/#{output_filename}?t=#{Time.now.to_i}"
  end
end
