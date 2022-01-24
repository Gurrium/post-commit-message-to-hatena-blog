#!/usr/bin/ruby
require 'git'

last_commit = Git.open(File.expand_path(__dir__ + '/../../')).log.first

raw_title, raw_categories, raw_body = last_commit.message.match(/\[post\](.*?)(?:\r?\n)+(.*?)(?:\r?\n)+(.*)/m).captures

title = raw_title.strip
is_draft = title.start_with?('x')
categories = raw_categories.split(',').map(&:strip).reduce('') { |result, category|
  result + "<category term=\"#{category}\"/>"
}
body = raw_body.strip

puts <<XML
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
       xmlns:app="http://www.w3.org/2007/app">
  <title>#{title.encode(xml: :text)}</title>
  <content type="text/plain">#{body.encode(xml: :text)}</content>
  #{categories}
  <app:control>
    <app:draft>#{is_draft ? 'yes' : 'no'}</app:draft>
  </app:control>
</entry>
XML
