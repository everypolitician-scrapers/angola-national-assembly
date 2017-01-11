#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'capybara'
require 'capybara/poltergeist'
require 'pry'
require 'scraperwiki'

include Capybara::DSL
Capybara.default_driver = :poltergeist

@BASE = 'http://www.parlamento.ao'
@PAGE = @BASE + '/web/guest/deputados-e-grupos-parlamentares/deputados/lista'

def extract_people
  within('div#main-content') do
    all('div.members-table').each do |mp|
      parts = mp.all('div')
      data = {
        name:         parts[1].find('a').text.strip,
        homepage:     parts[1].find('a')[:href],
        photo:        parts[0].find('img')[:src],
        party:        parts[2].text.strip || 'unknown',
        constituency: parts[3].text.strip,
        term:         3,
      }
      data[:id] = data[:homepage].split('/').last
      data[:photo].prepend @BASE unless data[:photo].empty?
      data[:homepage].prepend @BASE unless data[:homepage].empty?
      puts "Adding #{data[:id]}"
      sleep 1
      # puts data
      ScraperWiki.save_sqlite(%i(id term), data)
    end
  end
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil

visit @PAGE
extract_people

next_link = '//a[text()[contains(.,"Próximo")]]'
while page.has_xpath? next_link
  puts 'Next page...'
  find(:xpath, next_link).click
  extract_people
end
