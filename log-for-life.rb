#!/usr/bin/env ruby

require 'rubygems'
require 'activeresource'
require 'nokogiri'
require 'time'

module LogForLife

  class Importer

    attr_accessor :site, :user, :entries

    def initialize
      # Configuration for logforlife.com, logid and API key.
      c = YAML::load_file('config.yml')
      @site = "https://www.logforlife.com/logs/#{c['id']}/"
      @user = c['key']
      
      @entries = []
    end

    def parse_dexcom_xml(path = 'dexcom/sensor.Export.xml')
      f = File.open(path)
      doc = Nokogiri(f.read)
      f.close

      doc.search('Sensor').each do |s|
        t = Time.parse(s['DisplayTime'])
        log_item = {}
        log_item[:glucose_quantity] = s['Value']
        log_item[:time] = t.strftime("%I:%M %p")
        log_item[:date] = t.strftime("%Y-%m-%d")

        @entries << log_item
      end
    end
    
    def submit
      @entries.each do |e|
        response = LogItem.post(:bulk_create, :log_item => e, :site => @site, :user => @user)
        puts response.to_yaml
      end
    end

  end

  class LogItem < ActiveResource::Base
  end

end