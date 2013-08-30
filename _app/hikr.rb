# myapp.rb
require 'sinatra'

set :public_folder, "_site"
set :static, true

get "/" do
  File.read(File.join("_site","index.html"))
end


get '/c/:page' do
  path = File.join("_site/c", params[:page])
  p path
  if File.exists? File.join(path,"index.html")
    File.read File.join(path,"index.html") 
  else 
    404
  end
end

get '/c/:page/' do
  path = File.join("_site/c", params[:page])
  p path
  if File.exists? File.join(path,"index.html")
    File.read File.join(path,"index.html") 
  elsif File.exists? path
    File.read path
  else
    404
  end
end
