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

    def background
      @background ||= Magick::Image.read(background_url).first
    end

    def generate_image
      background.resize_to_fill!(options[:width], options[:height])
      background.format = options[:format]
      add_texts
      background.write(output_path)
    end

    def add_texts
      auto_texts, normal_texts = texts.partition { |t| t[:gravity].to_s == 'auto' }

      draw_auto_centered_texts(auto_texts) unless auto_texts.empty?

      normal_texts.each do |text|
        draw_text(background, text[:text], **text_options(text))
      end
    end

    def draw_auto_centered_texts(text_items)
      metrics_list = []

      text_items.each do |text|
        opts = text_options(text)
        draw = Magick::Draw.new
        draw.font = opts[:font]
        draw.pointsize = opts[:font_size]
        draw.font_weight = opts[:font_weight]
        draw.font_style = opts[:font_style]

        wrapped_text = wrap_text(text[:text], opts[:wrapped_width] || background.columns, opts)
        lines = wrapped_text.split("\n")
        line_metrics = lines.map { |line| draw.get_type_metrics(background, line) }
        metrics_list << [lines, opts, line_metrics]
      end

      total_height = metrics_list.sum { |_, _, ms| ms.sum(&:height) }
      y_start = (background.rows - total_height) / 2.0

      y = y_start
      metrics_list.each do |lines, opts, metrics|
        lines.zip(metrics).each do |line, metric|
          draw = Magick::Draw.new
          draw.font = opts[:font]
          draw.pointsize = opts[:font_size]
          draw.fill = opts[:color]
          draw.font_weight = opts[:font_weight]
          draw.font_style = opts[:font_style]

          x = (background.columns - metric.width) / 2.0
          draw.annotate(background, 0, 0, x, y + metric.ascent, line)
          y += metric.height
        end
      end
    end

    def wrap_text(text, max_width, opts)
      draw = Magick::Draw.new
      draw.font = opts[:font]
      draw.pointsize = opts[:font_size]
      draw.font_weight = opts[:font_weight]
      draw.font_style = opts[:font_style]

      if contains_cjk?(text)
        # 🇯🇵 CJK text → wrap by character
        chars = text.scan(/.{1}/m)
        lines = []
        line = ''

        chars.each do |char|
          test_line = line + char
          width = draw.get_type_metrics(background, test_line).width
          if width <= max_width
            line = test_line
          else
            lines << line unless line.empty?
            line = char
          end
        end

        lines << line unless line.empty?
        lines.join("\n")
      else
        # 🌍 Non-CJK text → wrap by word
        words = text.split(/\s+/)
        lines = []
        line = ''

        words.each do |word|
          test_line = line.empty? ? word : "#{line} #{word}"
          width = draw.get_type_metrics(background, test_line).width
          if width <= max_width
            line = test_line
          else
            lines << line unless line.empty?
            line = word
          end
        end

        lines << line unless line.empty?
        lines.join("\n")
      end
    end

    def contains_cjk?(text)
      # Checks for any CJK character (Japanese, Chinese, Korean)
      !!(text =~ /[\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]/)
    end

    def text_options(text)
      font_family = text[:font] || 'PublicSans-Regular'
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

    def wrapped_width(width)
      width || background.columns
    end

    def font(font_family)
      base = File.expand_path('../../fonts', __dir__)
      File.join(base, "#{font_family}.ttf")
    end

    def font_weight(font_family)
      font_family.downcase.include?('bold') ? Magick::BolderWeight : Magick::NormalWeight
    end

    def font_style(font_family)
      font_family.downcase.include?('italic') ? Magick::ItalicStyle : Magick::NormalStyle
    end

    def gravity(str)
      return nil if str.to_s == 'auto'

      {
        'northwest' => Magick::NorthWestGravity,
        'north' => Magick::NorthGravity,
        'northeast' => Magick::NorthEastGravity,
        'west' => Magick::WestGravity,
        'east' => Magick::EastGravity,
        'southwest' => Magick::SouthWestGravity,
        'south' => Magick::SouthGravity,
        'southeast' => Magick::SouthEastGravity,
        'center' => Magick::CenterGravity
      }[str] || Magick::CenterGravity
    end
  end
end
