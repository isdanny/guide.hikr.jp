# myapp.rb
require 'sinatra'
require 'json'
require 'yaml'

set :public_folder, "_site"
set :static, true

get "/" do
  File.read(File.join("_site","index.html"))
end

get '/edit' do
  haml :edit
end

get '/c/:page' do
  file_path = File.join('_site/c',  params[:page] )
  file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i  
  p file_path
  if File.exists? file_path
    File.read file_path 
  else 
    404
  end
end

get '/api/src', :provides => :json do
  path = params[:path]
  callback = params[:callback]
  content_type :js
  file_path = File.join('c', path)
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