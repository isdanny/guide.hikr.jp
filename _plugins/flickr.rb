require 'liquid'
require 'fleakr'

Fleakr.api_key       = "06a5a0dfe07d9d2d0af5ae6fe74bad03"
Fleakr.shared_secret = "c211ffcb95dc9680"
Fleakr.auth_token    = ""

CACHED_IMAGES = {}

module Flickr
  def flickr_image(url,size="large")
    img = image_object(url)
    imgfile = img.send(size)
    "<div class='flickr-photo'><a target='_blank' href='#{img.url}'><img title='#{img.title}' alt='#{img.title}' src='#{imgfile.url}'></a><div class='caption'>Image by <a target='_blank' href='#{img.owner.photos_url}'>#{img.owner.name||img.owner.username}</a> </div></div>"
  end

  private

  def image_object(url)
    CACHED_IMAGES[url] ||= Fleakr.resource_from_url(url)
  end
end

Liquid::Template.register_filter(Flickr)
