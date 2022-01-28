require 'git'
require 'tempfile'

# TODO: オプションを実装する
# - デフォルトのエディタ
# - コミットしない
# - 投稿しない
# - テンプレのパス

Tempfile.create do |tmp|
  system("nvim #{tmp.path}")
  content =  File.read(tmp.path)

  raw_title, raw_categories, raw_body = content.match(/(.*?)(?:\r?\n)+(.*?)(?:\r?\n)+(.*)/m).captures

  title = raw_title.strip
  is_draft = title.start_with?('x')
  category_tags = raw_categories.split(',').map(&:strip).reduce('') { |result, category|
    result + "<category term=\"#{category}\"/>"
  }
  body = raw_body.strip

  puts <<~XML
    <?xml version="1.0" encoding="utf-8"?>
    <entry xmlns="http://www.w3.org/2005/Atom"
           xmlns:app="http://www.w3.org/2007/app">
      <title>#{title.encode(xml: :text)}</title>
      <content type="text/plain">#{body.encode(xml: :text)}</content>
      #{category_tags}
      <app:control>
        <app:draft>#{is_draft ? 'yes' : 'no'}</app:draft>
      </app:control>
    </entry>
  XML

  # TODO: Gitにpushする
  # TODO: はてブロのAPIを叩く
  #       - 認証情報を取ってくる
end
