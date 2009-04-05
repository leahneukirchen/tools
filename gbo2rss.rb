#!/usr/bin/env ruby
require 'cgi'
require 'time'

page = `/opt/local/bin/w3m -dump http://german-bash.org/action/latest`

page.sub!(/.*?(#\d)/m, '\1')
page.gsub!(/\*\Z/, '')

puts <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:dc='http://purl.org/dc/elements/1.1/'>
  <channel>
    <title>german-bash.org</title>
    <link>http://german-bash.org/action/latest</link>
    <description>Latest quotes from german-bash.org</description>
EOF

page.split("#").each { |item|
  next  if item.empty?
  num = item[/\A(\d+)/, 1]
  item =~ /(\d\d)\.(\d\d)\.(\d\d\d\d \d\d\:\d\d)/
  date = Time.parse("#$2/#$1/#$3")
  puts "<item>"
  puts "  <title>german-bash.org: ##{num}</title>"
  puts "  <guid>http://german-bash.org/#{num}</guid>"
  puts "  <description>"
  puts CGI.escapeHTML("    <pre>##{CGI.escapeHTML item}</pre>")
  puts "  </description>"
  puts "  <pubDate>#{date.rfc822}</pubDate>"
  puts "</item>"
}

puts <<EOF
  </channel>
</rss>
EOF
