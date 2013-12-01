require 'sinatra'
require 'jekyll'

set :public_folder, '_site'

get '/foo' do
  options = Jekyll.configuration({})
  Jekyll::Commands::Build.process(options)
  'bar'
end

get '/edit' do
  'hello'
end

get '/save/*' do
  "param: #{params[:splat]}"
end

get '/*' do
    file_name = "./_site#{request.path_info}".gsub(%r{\/+},'/')
    if File.directory?(file_name)
      file_name = file_name+'/index.html'
    end
    if File.exists?(file_name)
      File.read(file_name)
    else
      raise Sinatra::NotFound
    end
end
