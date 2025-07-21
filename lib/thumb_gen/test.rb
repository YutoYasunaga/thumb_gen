# frozen_string_literal: true

require 'thumb_gen/generator'

module ThumbGen
  # rubocop:disable all
  module Test
    def self.generate_sample
      output_path = 'sample_output.jpg'
      background_url = 'sample_input.jpg'
      texts = [
        {
          text: 'ThumbGen is a Ruby gem that simplifies the creation of article thumbnails',
          wrapped_width: 800,
          font: 'PublicSans-Bold',
          font_size: 80,
          color: '#047857',
          outline_color: '#f8fafc',
          outline_width: 1,
          gravity: 'northwest',
          position_x: 40,
          position_y: 120
        },
        {
          text: '5 min read',
          wrapped_width: 800,
          font: 'Roboto-Italic',
          font_size: 48,
          color: '#09090b',
          gravity: 'southwest',
          position_x: 400,
          position_y: 40
        },
        {
          text: 'My Blog',
          wrapped_width: 1280,
          font: 'Roboto-BoldItalic',
          font_size: 64,
          color: '#86198f',
          gravity: 'northeast',
          position_x: 200,
          position_y: 30
        }
      ]
      options = {
        width: 1280,
        height: 720,
        format: 'jpg'
      }
      ThumbGen::Generator.new(output_path, background_url, texts, options).generate
    end
  end
  # rubocop:enable all
end
