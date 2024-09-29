# frozen_string_literal: true

require 'rmagick'
require 'thumb_gen/utils'

module ThumbGen
  class Generator
    include Utils

    attr_reader :output_path, :background_url, :texts, :options

    def initialize(output_path, background_url, texts, options)
      @output_path = output_path
      @background_url = background_url
      @texts = texts
      @options = options
    end

    def generate
      generate_image
    end

    private

    # Retrieves and caches the background image.
    def background
      @background ||= Magick::Image.read(background_url).first
    end

    # Handles the resizing, formatting, and text addition for the image.
    def generate_image
      background.resize_to_fill!(options[:width], options[:height])
      background.format = options[:format]
      add_texts
      background.write(output_path)
    end

    # Adds text overlays to the image based on provided text configurations.
    def add_texts
      texts.each do |text|
        draw_text(background, text[:text], **text_options(text))
      end
    end

    def text_options(text)
      font_family = text[:font] || 'PUblisSans-Regular'
      {
        wrapped_width: wrapped_width(text[:wrapped_width]),
        font: font(font_family),
        font_size: text[:font_size] || 64,
        font_weight: font_weight(font_family),
        font_style: font_style(font_family),
        color: text[:color] || '#000000',
        outline_color: text[:outline_color],
        outline_width: text[:outline_width] || 0,
        gravity: gravity(text[:gravity]),
        position_x: text[:position_x] || 0,
        position_y: text[:position_y] || 0
      }
    end

    # Determines the width within which text should be wrapped.
    def wrapped_width(width)
      width || background.columns
    end

    # Determines the font based on the style.
    def font(font_family)
      base = File.expand_path('../../fonts', __dir__)
      File.join(base, "#{font_family}.ttf")
    end

    # Determines the font weight based on the name.
    def font_weight(font_family)
      if font_family.downcase.include?('bold')
        Magick::BolderWeight
      else
        Magick::NormalWeight
      end
    end

    # Determines the font style based on the name.
    def font_style(font_family)
      if font_family.downcase.include?('italic')
        Magick::ItalicStyle
      else
        Magick::NormalStyle
      end
    end

    # Converts a string description to a Magick gravity constant using a hash map.
    def gravity(str)
      gravity_map = {
        'northwest' => Magick::NorthWestGravity,
        'north' => Magick::NorthGravity,
        'northeast' => Magick::NorthEastGravity,
        'west' => Magick::WestGravity,
        'east' => Magick::EastGravity,
        'southwest' => Magick::SouthWestGravity,
        'south' => Magick::SouthGravity,
        'southeast' => Magick::SouthEastGravity,
        'center' => Magick::CenterGravity
      }

      # Return the corresponding gravity value or default to CenterGravity if not found
      gravity_map[str] || Magick::CenterGravity
    end
  end
end
