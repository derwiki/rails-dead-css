#!/usr/bin/env ruby
require 'rubygems'
require 'ripper'
require File.expand_path(File.join(File.dirname(__FILE__), 'deadscan.rb'))

RUBY_DIR = ENV['RUBY_DIR'] || '{app,lib}/'
puts "Using RUBY_DIR=#{RUBY_DIR}"
METHOD_RE = /def (self\.)?([^ (\n]+)/

class DeadJavascriptScanner < DeadScanner
  def self.target_dir; RUBY_DIR; end
  def self.filetype; '.rb'; end
  def self.include_token; nil; end

  def self.scan
    cmd = "ack -ro 'def (self\.)?([A-z0-9\!\?-_]+)' #{HTML_DIR}/{app,lib} | cut -d' ' -f2"
    tokens = `#{cmd}`.split("\n").uniq.each do |token|
      print '.'
      token = token['self.'.length..-1] if token =~ /^self\./
      uses = `grep -R '#{token}' #{HTML_DIR} | grep -v def`
      puts "\n#{token} may be a dead function" if uses.empty?
    end
  end
end

DeadJavascriptScanner.scan
