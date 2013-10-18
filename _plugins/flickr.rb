require 'liquid'
require 'fleakr'
require 'digest'

Fleakr.api_key       = "06a5a0dfe07d9d2d0af5ae6fe74bad03"
Fleakr.shared_secret = "c211ffcb95dc9680"
Fleakr.auth_token    = ""

ROOT = File.absolute_path(".")


def image_template(url, size, klass='' )
  hash = Digest::MD5.base64digest(url).delete!("=").gsub("/","_")
  path = File.join(ROOT,"_cache","img-#{hash}.yml")
  if File.exist? path 
    img = YAML::load( File.open( path ) )
    p "reading #{path}"
  else
    fimg = Fleakr.resource_from_url(url)
    img = {
      :url=>fimg.url,
      :title=>fimg.title,
      :owner_url=>fimg.owner.photos_url,
      :owner_name=>fimg.owner.name||fimg.owner.username,
    }
    [:square, :thumbnail, :small, :medium, :large, :original].each do |size|
      img[size] = fimg.send(size).url
    end
    p "writing #{path}"
    File.open(path, 'w+') do |f|
        f.puts YAML::dump(img)
    end
  end
  "<div class='flickr-photo #{klass}'><a target='_blank' href='#{img[:url]}'><img title='#{img[:title]}' alt='#{img[:title]}' src='#{img[":#{size}"]}'></a><div class='caption'>Photo by <a target='_blank' href='#{img[:owner_url]}'>#{img[:owner_name]}</a> </div></div>"
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
end

module Flickr
  def flickr(url, size = 'medium' )
    image_template(url, size||'medium', "")
  end
end

Liquid::Template.register_tag('flickr', Jekyll::FlickrTag)
Liquid::Template.register_filter(Flickr)

