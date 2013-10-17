require 'liquid'
require 'fleakr'

Fleakr.api_key       = "06a5a0dfe07d9d2d0af5ae6fe74bad03"
Fleakr.shared_secret = "c211ffcb95dc9680"
Fleakr.auth_token    = ""

CACHED_IMAGES = {}

def image_template(url, size, klass='')
  img = CACHED_IMAGES[url] ||= Fleakr.resource_from_url(url) 
  imgfile = img.send(size||'medium')
  "<div class='flickr-photo #{klass}'><a target='_blank' href='#{img.url}'><img title='#{img.title}' alt='#{img.title}' src='#{imgfile.url}'></a><div class='caption'>Photo by <a target='_blank' href='#{img.owner.photos_url}'>#{img.owner.name||img.owner.username}</a> </div></div>"   
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
      image_template(url, size)
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
