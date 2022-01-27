require 'net/https'

uri = URI.parse('https://blog.hatena.ne.jp/gurrium/giarrium.hatenablog.com/atom/entry')

req = Net::HTTP::Post.new(uri.path, initheader = { 'Content-type': 'text/xml' })
req.basic_auth('gurrium', 'hogehoge')
req.body = <<BODY
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
       xmlns:app="http://www.w3.org/2007/app">
  <title>title</title>
  <content type="text/plain">
  body
  </content>
  <updated>2008-01-01T00:00:00</updated>
  <category term="Scala" />
  <app:control>
    <app:draft>yes</app:draft>
  </app:control>
</entry>
BODY

https = Net::HTTP.new(uri.host, 443)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_PEER

res = https.start {|https| https.request(req) }

puts case res
when Net::HTTPSuccess, Net::HTTPRedirection
  res.body
else
  res.value
end
