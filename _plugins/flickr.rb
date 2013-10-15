require 'liquid'
require 'fleakr'

Fleakr.api_key       = "06a5a0dfe07d9d2d0af5ae6fe74bad03"
Fleakr.shared_secret = "c211ffcb95dc9680"
Fleakr.auth_token    = ""

CACHED_IMAGES = {}

module Flickr
  def flickr_image(url)
    "<img alt='#{image_object(url).title}' src='#{image_object(url).large.url}'>"
  end

  def flickr_medium_image(url)
    "<img alt='#{image_object(url).title}' src='#{image_object(url).medium.url}'>"
  end

  private

  def image_object(url)
    CACHED_IMAGES[url] ||= Fleakr.resource_from_url(url)
  end
end

Liquid::Template.register_filter(Flickr)