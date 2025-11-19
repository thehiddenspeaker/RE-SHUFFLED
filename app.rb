# app.rb
require "sinatra"
require "sinatra/cross_origin"
require "json"
require "open-uri"
require "fileutils"
require_relative "./lib/Card"
require_relative "./lib/card_generator"

configure do
  enable :cross_origin
  set :public_folder, "public"
  set :port, 3001
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end
after do
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'

end

options "*" do
  200
end


# Card Generation Endpoint
post "/generate_card" do
  content_type :json

  begin
    # --- Parse inputs ---
    name       = params[:name]
    manaCost   = params[:manaCost]
    type       = params[:type]
    subType    = params[:subType]
    rarity     = params[:rarity]
    rules      = params[:rules]
    flavor     = params[:flavor]
    stats      = params[:stats]

    # --- Directories handling ---
    FileUtils.mkdir_p("Images/Art")
    FileUtils.mkdir_p("public/output")

    # --- Art input handling ---
    if params[:imageUrl] && !params[:imageUrl].empty?

      begin
        image_url = params[:imageUrl]

        ext = File.extname(URI.parse(image_url).path)
        ext = ".jpg" if ext.empty?

        filename = "url_#{Time.now.to_i}#{ext}"
        art_path = "Images/Art/#{filename}"

        # Download the image
        URI.open(image_url) do |image|
          File.open(art_path, "wb") do |file|
            file.write(image.read)
          end
        end

      rescue => e
        return {
          success: false,
          error: "Failed to download image from URL: #{e. message}"
        }.to_json
      end

    elsif params[:art]
      art_file   = params[:art][:tempfile]
      filename = params[:art][:filename]
      art_path = "Images/Art/#{filename}"

      File.open(art_path, "wb") {|f| f.write(art_file.read)}

    else
      return {
        success: false,
        error: "Please upload a file or provide an image URL."
      }.to_json
    end


    # # --- Save art file locally ---
    # Dir.mkdir("Images") unless Dir.exist?("Images")
    # Dir.mkdir("Images/Art") unless Dir.exist?("Images/Art")
    # filename = "#{params[:art][:filename]}"
    # art_path = "Images/Art/#{filename}"

    # File.open(art_path, "wb") { |f| f.write(art_file.read) }


    # --- Create Card instance ---
    card = Card.new(name, manaCost, type, subType, rarity, rules, flavor, stats, art_path)

    # --- Generate final image ---
    output_url = CardGenerator.generate(card)

    # --- Temp art file cleanup ---
    if File.exist?(art_path)
      File.delete(art_path)
    end

    # --- Respond with JSON ---
    host = request.base_url
    { success: true, image_path: "#{host}#{output_url}" }.to_json
  
  rescue => e
    puts "Error generating card: #{e.message}"
    puts e.backtrace

    {
      success: false,
      error: "Failed to generate card: #{e.message}"
    }.to_json
  end
end 

get "/output/:filename" do
    filename = params[:filename]
    filepath ="public/output/#{filename}"

    if File.exist?(filepath)
      send_file filepath,
        filename: filename,
        type: 'application/octet-stream',
        disposition: 'attachment'
    else
      status 404
      "File not found"
    end
end

# --- Format Conversion & Download Endpoint ---
get "/download/:filename/:format" do
  content_type :json

  filename = params[:filename]
  format = params[:format].downcase

  original_image_path = "public/output/#{filename}"

  unless File.exist?(original_image_path)
    return {
      success: false,
      error: "File not found: #{filename}"
    }.to_json
  end

  begin
    require 'mini_magick'

    base_name = File.basename(filename, ".*")
    original_ext = File.extname(filename).downcase.delete('.')
    output_filename = "#{base_name}.#{format}"
    output_path = "public/output/#{output_filename}"

    if  original_ext == format
      return {
        success: true,
        download_path: "/output/#{filename}"
      }.to_json
    end

    image = MiniMagick::Image.open(original_image_path)

    case format 
    when 'jpg', 'jpeg'
      image.format 'jpg'
      image.quality 95
      image.combine_options do |c|
        c.background 'white'
        c.alpha 'remove'
      end
    when 'png'
      image.format 'png'
    end

    image.write(output_path)

    {
      success: true,
      download_path: "/output/#{output_filename}"
    }.to_json

  rescue LoadError
    {
      success: false,
      error: "MiniMagick not installed"
    }.to_json 
  rescue => e
    puts "Conversion error: #{e.message}"
    puts e.backtrace
    {
      success: false, error: "Conversion failed: #{e.message}"
  }.to_json
  end
end

get "/" do
  content_type :json
  {
    status: "ok", message: "Re:Shuffled API is running", port: settings.port
  }.to_json
end