#!/usr/bin/env ruby
require 'rubygems'
require 'ruby-debug'
require File.expand_path(File.join(File.dirname(__FILE__), 'deadscan.rb'))

JS_DIR = ENV['JS_DIR'] || 'public/javascripts'
puts "Using JS_DIR=#{JS_DIR}"
HTML_DIR = ENV['HTML_DIR'] || 'app/{views,helpers,controllers}'
FILETYPE = '.js'
INCLUDE_TOKEN = 'javascript'
JQUERY_SELECTOR_RE = /\$\(['"](.*?)['"]\)/
CLASS_AND_ID_RE = /([\.#][^\.# '">:,\(]+)/

class DeadJavascriptScanner < DeadScanner
  def self.target_dir; JS_DIR; end
  def self.filetype; '.js'; end
  def self.include_token; INCLUDE_TOKEN; end

  def self.extract_tokens(file)
    tokens = File.read(file).split("\n").map do |line|
      line.scan(JQUERY_SELECTOR_RE).flatten.uniq.map do |selector|
        selector.scan CLASS_AND_ID_RE
      end
    end.flatten.uniq.map {|token| token[1..-1]}
  end
end

DeadJavascriptScanner.scan
