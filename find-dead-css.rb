#!/usr/bin/env ruby
require 'rubygems'
require 'ruby-debug'

# http://stackoverflow.com/questions/6224329/how-can-i-iterate-through-a-css-class-subclasses-in-ruby
REGEXES = {
 :id => /[#]\w+ \{/,
 :class => /[.]\w+ \{/
}
STYLESHEET_DIR = ENV['STYLESHEET_DIR'] || 'public/stylesheets'
HTML_DIR = ENV['HTML_DIR'] || 'app/{views,helpers,controllers}'

def short_path(path)
  path.split('/').drop(2).last(2).join('').sub('.css', '')
end

cssfiles = `find #{STYLESHEET_DIR} -name '*.css'`.split("\n")
max_filename = cssfiles.map(&:length).max
cssfiles.each do |cssfile|
  res = `grep -r #{short_path(cssfile)} #{HTML_DIR} | grep add_stylesheet`
  unless res.empty?
    puts "* Orphan file: #{cssfile}"
    next
  end

  contents = `grep -v ': ' #{cssfile}`
  tokens = {:id => [], :class => []}
  contents.split("\n").each do |line|
    REGEXES.each do |key, regex|
      token = line.scan(regex).to_s.scan(/\w/).join
      tokens[key] << token unless token.empty?
    end
  end
  REGEXES.each do |key, _|
    tokens[key].uniq!
    tokens[key].each do |val|
      uses = `grep -R #{val} #{HTML_DIR}`
      puts [cssfile.ljust(max_filename + 1), val].join('') if uses.empty?
    end
  end
end
