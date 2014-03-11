require 'nokogiri'
require 'httpclient'
require 'kinopoisk/movie'
require 'kinopoisk/search'
require 'kinopoisk/person'

module Kinopoisk
  SEARCH_URL = "http://www.kinopoisk.ru/index.php?kp_query="
  NotFound   = Class.new StandardError
  @@proxy    = nil

  def self.proxy
    @@proxy
  end

  def self.proxy=(value)
    @@proxy = value
  end

  # Headers are needed to mimic proper request so kinopoisk won't block it
  def self.fetch(url)
    HTTPClient.new(proxy: @@proxy).get url, nil, { 'User-Agent'=>'a', 'Accept-Encoding'=>'a' }
  end

  # Returns a nokogiri document or an error if fetch response status is not 200
  def self.parse(url)
    p = fetch url
    p.status==200 ? Nokogiri::HTML(p.body.encode('utf-8')) : raise(NotFound)
  end
end
