#!/usr/bin/env ruby

require 'rubygems'
require 'activeresource'
require 'nokogiri'
require 'time'
require 'csv'

module LogForLife
  
  class LogItem < ActiveResource::Base
    c = YAML::load_file('config.yml')
    self.site = "https://www.logforlife.com/logs/#{c['id']}/"
    self.user = c['key']
  end
  
  class Importer
    
    attr_accessor :entries
    
    def initialize
      @entries = []
    end
    
    def parse_dexcom_xml(path = 'dexcom/sensor.Export.xml')
      
      doc = Nokogiri(File.open(path))
      
      doc.search('Sensor').each do |s|
        t = Time.parse(s['DisplayTime'])
        i = {:glucose_quantity => s['Value'],
             :date => t.strftime("%Y-%m-%d"),
             :time => t.strftime("%I:%M %p")}
        
        @entries << i
      end
    end
    
    def parse_onetouch_csv(path = 'onetouch/Export_1202009.csv')
      CSV::Reader.parse(File.open(path)) do |row|
        i = {:glucose_quantity => row[3],
             :date => Date.parse(row[1]),
             :time => Time.parse(row[2]).strftime("%I:%M %p")}
        
        @entries << i
      end
    end
    
    def submit
      @entries.each do |e|
        response = LogItem.post(:bulk_create, :log_item => e)
        puts response.to_yaml
      end
    end
    
  end

end