#!/usr/bin/env ruby
require 'rubygems'
require 'ruby-debug'

# http://stackoverflow.com/questions/6224329/how-can-i-iterate-through-a-css-class-subclasses-in-ruby
JS_DIR = ENV['JS_DIR'] || 'public/javascripts'
puts "Using JS_DIR=#{JS_DIR}"
HTML_DIR = ENV['HTML_DIR'] || 'app/{views,helpers,controllers}'
FILETYPE = '.js'
INCLUDE_TOKEN = 'javascript'
def include_path(path)
  path.split('/').drop(2).last(2).join('/').sub(FILETYPE, '')
end

def short_path(path)
  path.split('/').drop(2).join('/')
end
JQUERY_SELECTOR_RE = /\$\(['"](.*?)['"]\)/
CLASS_AND_ID_RE = /([\.#][^\.# '">:,\(]+)/

files = `find #{JS_DIR} -name '*#{FILETYPE}'`.split("\n")
puts $files;
files.each do |file|
  cmd = "grep -r #{include_path(file)} #{HTML_DIR} | grep #{INCLUDE_TOKEN}"
  res = `#{cmd}`

  # if this is dead, can we make any educated guesses?
  if res.empty?
    linecount = `wc -l #{file}`.split(' ').first.strip
    puts "* Potentially orphaned: #{short_path(file)} (#{linecount} LOC)"
    images = `grep background-image #{file}`
    unless images.empty?
      images.scan(/url\(.*\)/).each do |image|
        puts "image: #{image.ljust(25)} #{short_path(file)}"
      end
    end
  end

  # extract all classes and ids
  tokens = File.read(file).split("\n").map do |line|
    line.scan(JQUERY_SELECTOR_RE).flatten.uniq.map do |selector|
      #puts "selector: #{selector}"
      classes_and_ids = selector.scan CLASS_AND_ID_RE
      #puts "classes_and_ids: #{classes_and_ids}", '***'
      classes_and_ids
    end
  end.flatten.uniq.map {|token| token[1..-1]}
  tokens.each do |token|
    uses = `grep -R '#{token}' #{HTML_DIR}`
    cols = [30, token.length+1].max
    puts [token.ljust(cols), short_path(file)].join('') if uses.empty?
  end

  #TODO line separator if file yielded reults
  #TODO tokens should be a single list, not a hash
end
