# myapp.rb
require 'sinatra'
require 'json'
require 'yaml'
require 'rdiscount'
YAML::ENGINE.yamler = 'psych'

set :public_folder, "_site"
set :static, true

class Article
  attr_accessor :body
  attr_accessor :meta

  def initialize(content)
    md = content.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m)
    self.meta = YAML.load md[:metadata]
    self.body = md.post_match
  end

  def self.get(path)
    file_path = File.join('c', path, 'index.md')
    if(File.exists? file_path)
      Article.new File.read file_path
    else
      nil
    end
  end

end

get "/" do
  File.read(File.join("_site","index.html"))
end

get '/edit' do
  haml :edit
end

get '/c/:page/' do
  if article = Article.get(params[:page])
    md =  RDiscount.new(article.body, :smart, :filter_html)
    p article.meta.to_json
    haml :article, :locals=>{ :body=>md.to_html, :meta=>article.meta, :maps=>article.meta.map.to_json }
  else
    404
  end
end

get '/api/article/:path', :provides => :json do
  path = params[:path]
  callback = params[:callback]
  content_type :js
  file_path = File.join('c', path, '/index.md')
  p file_path
  if File.exists? file_path
    ext = File.extname file_path
    if ext==".md"
      article = {}
      parts = (File.read file_path).split("---\n",3)
      article[:meta] = YAML.load parts[1]
      article[:markdown] = parts[2]
      p article[:meta]
      "#{callback}(#{article.to_json})"
    else
      File.read file_path
    end
  else
    404
  end
end