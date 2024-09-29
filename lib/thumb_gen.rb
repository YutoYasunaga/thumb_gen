# frozen_string_literal: true

require_relative 'thumb_gen/version'
require 'thumb_gen/generator'

module ThumbGen
  class Error < StandardError; end

  def self.generate(output_path, background_url, texts, options)
    Generator.new(output_path, background_url, texts, options).generate
  end
end
