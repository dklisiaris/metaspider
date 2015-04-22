#!/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'open-uri'
require 'nokogiri'

class Base
  attr_reader :url, :page

  def initialize(url=nil)
    load_page(url)
  end

  # Downloads a page from the web.
  #
  # ==== Attributes
  #
  # * +url+ - The url of webpage to download.
  # 
  def load_page(url=nil)
    begin
      @url = url      

      puts "Downloading page: #{url}"
      open(url, :content_length_proc => lambda do |content_length|
        raise EmptyPageError.new(url, content_length) unless content_length.nil? or content_length > 1024
      end) do |f|        

        @page = f.read.gsub(/\s+/, " ")
      end
    rescue Errno::ENOENT => e
      puts "Page: #{url} NOT FOUND."
      puts e
    rescue EmptyPageError => e
      puts "Page: #{url} is EMPTY."
      puts e        
      @page = nil
    rescue OpenURI::HTTPError => e
      puts e
      puts e.io.status          
    rescue StandardError => e          
      puts "Generic error #{e.class}. Will wait for 2 minutes and then try again."
      puts e        
      sleep(120)
      retry        
    end if present?(url) and url.match(/\A#{URI::regexp(['http', 'https'])}\z/)
  end

  def   

  def present?(value)
    return (not value.nil? and not value.empty?) ? true : false
  end  

end

# Raised when a page is considered empty.
#
class EmptyPageError < StandardError
  attr_reader :url, :content_length

  def initialize(url, content_length)
    @url = url
    @content_length = content_length

    msg = "Page: #{url} is only #{content_length} bytes, so it is considered EMPTY."
    super(msg)
  end    
end