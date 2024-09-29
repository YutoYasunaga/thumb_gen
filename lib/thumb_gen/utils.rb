# frozen_string_literal: true

module ThumbGen
  module Utils
    # Draws customized text on an image.
    def draw_text(image, text, **opts)
      draw = Magick::Draw.new
      draw.font = opts[:font]
      draw.font_weight = opts[:font_weight]
      draw.font_style = opts[:font_style]
      draw.pointsize = opts[:font_size]
      draw.fill = opts[:color]
      draw.gravity = opts[:gravity]
      if opts[:outline_width].to_i.positive?
        draw.stroke = opts[:outline_color]
        draw.stroke_width = opts[:outline_width]
      end

      wrapped_text = word_wrap(text, opts[:wrapped_width], draw)

      draw.annotate(
        image,
        0,
        0,
        opts[:position_x],
        opts[:position_y],
        wrapped_text
      )
    end

    # Wraps text to fit within a specified width.
    def word_wrap(text, max_width, draw)
      lines = []
      current_line = ''

      text.split.each do |word|
        if word_too_wide?(word, max_width, draw)
          lines.concat(split_word_into_lines(word, max_width, draw))
        else
          test_line = current_line.empty? ? word : "#{current_line} #{word}"
          if word_too_wide?(test_line, max_width, draw)
            lines << current_line
            current_line = word
          else
            current_line = test_line
          end
        end
      end

      lines << current_line unless current_line.empty?
      lines.join("\n")
    end

    # Helper method to determine if the text exceeds the maximum width.
    def word_too_wide?(text, max_width, draw)
      draw.get_type_metrics(text).width > max_width
    end

    # Splits a single word into lines if it's too wide to fit the max width.
    def split_word_into_lines(word, max_width, draw)
      word.each_char.with_object(['']) do |char, segments|
        test_segment = segments.last + char
        if word_too_wide?(test_segment, max_width, draw)
          segments << char
        else
          segments[-1] = test_segment
        end
      end
    end
  end
end
