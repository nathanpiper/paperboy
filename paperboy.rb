#!/usr/bin/env ruby
require 'rubygems'
require 'mail'
require 'fileutils'
require 'yaml'

config = YAML.load_file 'paperboy.yaml'

output_file = "#{config['temp_dir']}tmp.mobi"

puts "Fetching feeds"
config['recipes'].each do |recipe|
	puts "Grabbing recipe #{recipe} ..."
	system("ebook-convert \"#{recipe}\".recipe #{output_file}")
	
	if $? == 0 then
		puts "Sending to kindle(s)"
		config['recipients'].each do |recipient|
			Mail.deliver do 
				to recipient
				from config['from']
				subject "Kindle delivery: #{recipe}"
				body "Here is the current edition of #{recipe}"
				add_file output_file
				delivery_method :sendmail
			end
		end

		puts "Deleting temporary file"
		FileUtils.rm output_file
	end
end