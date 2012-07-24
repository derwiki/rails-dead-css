#!/usr/bin/env ruby
require 'rubygems'
#require 'ruby-debug'

HTML_DIR = ENV['HTML_DIR'] || 'app/{views,helpers,controllers}'
CLASS_AND_ID_RE = /([\.#][^\.# '">:,\(]+)/

class DeadScanner
  def self.include_path(path)
    path.split('/').drop(2).last(2).join('/').sub(FILETYPE, '')
  end

  def self.short_path(path)
    path.split('/').drop(2).join('/')
  end

  # %(filetype html_dir target_dir filetype include_token extract_tokens).each do |meth|
  #   define_method(method.to_sym) do
  #     raise NotImplementedError, "Must implement `#{meth}'"
  #   end
  # end

  def self.scan
    files = `find #{target_dir} -name '*#{filetype}'`.split("\n")
    files.each do |file|
      unless include_token.nil?
        cmd = "grep -r #{include_path(file)} #{HTML_DIR} | grep #{include_token}"
        res = `#{cmd}`

        if res.empty?
          linecount = `wc -l #{file}`.split(' ').first.strip
          puts "* Potentially orphaned: #{short_path(file)} (#{linecount} LOC)"
        end
      end

      tokens = self.extract_tokens(file)
      self.handle_tokens(tokens)
    end
  end

  def self.handle_tokens(tokens)
    tokens.each do |token|
      print "#{token} "
      token = token['self.'.length..-1] if token.starts_with? 'self.'
      uses = `grep -R '#{token}' #{HTML_DIR} | grep -v def`
      cols = [30, token.length+1].max
      puts [token.ljust(cols), short_path(file)].join('') if uses.empty?
    end
  end
end
