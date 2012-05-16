#!/usr/bin/env ruby
require 'rubygems'
require 'ruby-debug'

REGEXES = {
 :id => /[#]\w+ \{/,
 :class => /[.]\w+ \{/
}

cssfiles = `find activities/ -name '*.css'`.split("\n")
max_filename = cssfiles.map(&:length).max
cssfiles.each do |cssfile|
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
      uses = `grep -R #{val} ../../app/{views,helpers,controllers}`
      puts [cssfile.ljust(max_filename + 1), val].join('') if uses.empty?
    end
  end
end
