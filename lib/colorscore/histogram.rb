require "shellwords"

module Colorscore
  class Histogram
    def initialize(image_path, options = {})
      params = [
        '-resize 400x400',
        '-format %c',
        "-dither #{options.fetch(:dither) { 'None' }}",
        "-quantize #{options.fetch(:quantize) { 'YIQ' }}",
        "-colors #{options.fetch(:colors) { 16 }.to_i}",
        "-depth #{options.fetch(:depth) { 8 }.to_i}",
        '-alpha deactivate '
      ]

      #params.unshift(options[:resize]) if options[:resize]

      output = `convert #{image_path.shellescape} #{ params.join(' ') } histogram:info:-`
      @lines = output.lines.map(&:strip).reject(&:empty?).
        sort_by { |l| l[/(\d+):/, 1].to_i }
    end

    # Returns an array of colors in descending order of occurances.
    def colors
      hex_values = @lines.map { |line| line[/#([0-9A-F]{6})/, 1] }.compact
      hex_values.map { |hex| Color::RGB.from_html(hex) }
    end

    def color_counts
      @lines.map { |line| line.split(':')[0].to_i }
    end

    def scores
      total = color_counts.inject(:+).to_f
      scores = color_counts.map { |count| count / total }
      scores.zip(colors)
    end
  end
end
