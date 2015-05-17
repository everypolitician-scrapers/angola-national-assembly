#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'
require 'date'

require 'colorize'
require 'pry'
require 'csv'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko(url)
  Nokogiri::HTML(open(url).read) 
end

def datefrom(date)
  Date.parse(date)
end

@BASE = 'http://www.parlamento.ao'

def scrape(url)
  warn "Fetching #{url}"

  page = noko(url)
  content = page.css('div#main-content')

  content.css('div.members-table').each do |mp|
    parts = mp.css('div')
    data = {
      name: parts[1].css('a').text.strip,
      photo: parts[0].css('img/@src').text,
      party: parts[2].text.strip,
      constituency: parts[3].text.strip,
    }
    data[:photo].prepend @BASE unless data[:photo].empty?
    puts data
    # ScraperWiki.save_sqlite([:name, :term], data)
  end
end


page = '/web/guest/deputados-e-grupos-parlamentares/deputados/lista'
scrape(@BASE + page)
