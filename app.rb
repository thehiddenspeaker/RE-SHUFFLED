# app.rb
require "sinatra"
require "sinatra/cross_origin"
require "json"
require_relative "./lib/Card"
require_relative "./lib/card_generator"

configure do
  enable :cross_origin
  set :public_folder, "public"
end

options "*" do
  200
end


# Card Endpoint
post "/generate_card" do
  # --- Parse inputs ---
  name       = params[:name]
  manaCost   = params[:manaCost]
  type       = params[:type]
  subType    = params[:subType]
  rarity     = params[:rarity]
  rules      = params[:rules]
  flavor     = params[:flavor]
  stats      = params[:stats]
  art_file   = params[:art][:tempfile] if params[:art]

  # --- Save art file locally ---
  Dir.mkdir("Images") unless Dir.exist?("Images")
  Dir.mkdir("Images/Art") unless Dir.exist?("Images/Art")
  filename = "#{Time.now.to_i}_#{params[:art][:filename]}"
  art_path = "Images/Art/#{filename}"

  File.open(art_path, "wb") { |f| f.write(art_file.read) }

  # --- Create Card instance ---
  card = Card.new(name, manaCost, type, subType, rarity, rules, flavor, stats, art_path)

 # --- Generate final image ---
output_url = CardGenerator.generate(card)

# --- Respond with JSON ---
content_type :json
host = request.base_url
{ success: true, image_path: "#{host}#{output_url}" }.to_json

end
