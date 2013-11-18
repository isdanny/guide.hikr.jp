require 'rubygems' 
require 'bundler/setup'
require 'digest'
require 'fleakr'

Fleakr.api_key       = "06a5a0dfe07d9d2d0af5ae6fe74bad03"
Fleakr.shared_secret = "c211ffcb95dc9680"
Fleakr.auth_token    = ""

ROOT = File.absolute_path(".")

def flickr_image(url)
  hash = Digest::MD5.base64digest(url).delete!("=").gsub("/","_")
  path = File.join(ROOT,"_cache","img-#{hash}.yml")
  if File.exist? path 
    img = YAML::load( File.open( path ) )
    # p "reading #{path}"
  else
    # p "getting #{url}"
    fimg = Fleakr.resource_from_url(url)
    img = {
      'url'=>fimg.url,
      'title'=>fimg.title||"",
      'taken'=>fimg.taken,
      'owner_url'=>fimg.owner.photos_url,
      'owner_name'=>fimg.owner.name||fimg.owner.username,
    }
    [:square, :large_square, :thumbnail, :small, :small_320, :medium, :medium_640, :medium_800, :large, :large_1600, :large_2048, :original].each do |size|
      if s = fimg.send(size)
        img[size.to_s] = s.url
      end
    end
    p "writing #{path}"
    File.open(path, 'w+') do |f|
        f.puts YAML::dump(img)
    end
  end
  return img
end

def image_template(url, size, klass='' )
  img = flickr_image(url)
  "<div class='flickr-photo #{klass}'><img title='"+img['title']+"' alt='"+img['title']+"' src='"+img[size]+"'><div class='photo-date'>"+img['taken']+"</div><div class='caption'>Photo by <a target='_blank' href='"+img['url']+"'>"+img['owner_name']+"</a> </div></div>"
end

module Jekyll

  class FlickrTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end
    
    def render(context)
      params = @text.split(/\s/)
      url = params[0]
      size = params[1] || 'medium'        
      image_template(url, size )
    end
  end

  class FurlTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      params = @text.split(/\s/)
      p params
      url = params[0]
      size = params[1] || 'medium'
      img = flickr_image(url)
      img[size]
    end
  end
end

module Flickr
  def flickr(url, size = 'medium' )
    image_template(url, size||'medium', "")
  end
  def furl(url)
    size = "square"
    img = flickr_image(url)
    img[size]
  end
end


Liquid::Template.register_tag('furl', Jekyll::FurlTag)
Liquid::Template.register_tag('flickr', Jekyll::FlickrTag)
Liquid::Template.register_filter(Flickr)

