require "rmagick"
require_relative "Card"

class CardDisplay

end

testFrame = Magick::Image.read("Images/Templates/mtg_colorless_frame.png")[0]
testArt = Magick::Image.read("Images/Sol_Ring.webp")[0]
testArt.change_geometry!('1005x1407') { |cols, rows, img|
    img.resize!(cols, rows)
}

testImage = testFrame.composite(testArt, 0, 100, Magick::SrcOverCompositeOp)
testImage = testImage.composite(testFrame, 0, 0, Magick::SrcOverCompositeOp)

testImage.write('Images/tempFile.png')