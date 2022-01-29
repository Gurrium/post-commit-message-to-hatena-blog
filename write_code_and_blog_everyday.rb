require 'git'
require 'tempfile'
require 'net/https'

# TODO: オプションを実装する
# - デフォルトのエディタ
# - コミットしない
# - 投稿しない
# - テンプレのパス

HATENA_ID = ENV['HATENA_ID'].freeze
HATENA_BLOG_ID = ENV['HATENA_BLOG_ID'].freeze
HATENA_BLOG_API_KEY = ENV['HATENA_BLOG_API_KEY'].freeze

class Entry
  attr_reader :title, :body, :categories, :is_draft

  def initialize(title, body, categories)
    @title = title
    @body = body
    @categories = categories
    @is_draft = title.start_with?('x')
  end
end

def extract_entry(content)
  title, categories, body = content.match(/(.*?)(?:\r?\n)+(.*?)(?:\r?\n)+(.*)/m).captures

  return Entry.new(
    title.strip,
    body.strip,
    categories.split(',').map(&:strip)
  )
end

def request_body(entry)
  category_tags = entry.categories.reduce('') { |result, category|
    result + "<category term=\"#{category}\"/>"
  }

  return <<~XML
    <?xml version="1.0" encoding="utf-8"?>
    <entry xmlns="http://www.w3.org/2005/Atom"
           xmlns:app="http://www.w3.org/2007/app">
      <title>#{entry.title.encode(xml: :text)}</title>
      <content type="text/plain">#{entry.body.encode(xml: :text)}</content>
      #{category_tags}
      <app:control>
        <app:draft>#{entry.is_draft ? 'yes' : 'no'}</app:draft>
      </app:control>
    </entry>
  XML
end

def post_entry(entry)
  uri = URI.parse("https://blog.hatena.ne.jp/#{HATENA_ID}/#{HATENA_BLOG_ID}/atom/entry")

  req = Net::HTTP::Post.new(uri.path, initheader = { 'Content-type': 'text/xml' })
  req.basic_auth(HATENA_ID, HATENA_BLOG_API_KEY)
  req.body = request_body(entry)

  https = Net::HTTP.new(uri.host, 443)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_PEER

  return https.start {|https| https.request(req) }
end

def commit_and_push(commit_message)
  g = Git.open('.')
  g.add
  g.commit(commit_message)
  g.push
end

Tempfile.create do |tmp|
  system("nvim #{tmp.path}")

  entry = extract_entry(File.read(tmp.path))

  post_entry(entry)
  commit_and_push(entry.title)
end
