#!/usr/bin/env ruby

require 'rubygems'
require 'activeresource'
require 'nokogiri'
require 'time'

c = YAML::load_file('config.yml')

class LogItem < ActiveResource::Base
  self.site = "https://www.logforlife.com/logs/#{c['id']}/"
  self.user = c['key']
end

f = File.open('sensor.Export.xml')
doc = Nokogiri(f.read)
f.close

doc.search('Sensor').each do |s|
  t = Time.parse(s['DisplayTime'])
  log_item = {}
  log_item[:glucose_quantity] = s['Value']
  log_item[:time] = t.strftime("%I:%M %p")
  log_item[:date] = t.strftime("%Y-%m-%d")
  
  response = LogItem.post(:bulk_create, :log_item => log_item)
  
  puts response.to_yaml
end

# 25.times do
#   response = LogItem.post(:bulk_create, :log_item => {
#    :glucose_quantity => rand(300),
#    :time => "8:30 AM",
#    :date => Date.today
#   })
#   
#   puts response.to_yaml
# end

