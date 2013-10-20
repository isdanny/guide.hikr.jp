module Jekyll

  class Site

    attr_accessor :areas

    def get_areas()
      if self.areas.nil?
        self.areas = {}
        self.pages.each do |page|
          if page.data.key? "area"
            area = page.data["area"]
            if ! self.areas.has_key? area
              self.areas[area] = []
            end
            self.areas[area] << page
          end
        end
      end
      self.areas
    end

    old_payload = self.instance_method(:site_payload)

    define_method(:site_payload) do
      areas = get_areas()
      payload = old_payload.bind(self).call
      payload['site']['area_names'] = areas.keys
      payload['site']['areas'] = areas
      payload
    end
  end

  class AreaPage < Page
    def initialize(site,base,dir,area, pages)
      @site = site
      @base = base
      @dir = dir
      @name = area+'.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'area.html')
      self.data['area_listing'] = area
      self.data['map'] = ['/data/area/'+area+'.json']
    end
  end

  class AreaMap < Page
    def initialize(site,base,dir,area, pages)
      @site = site
      @base = base
      @dir = dir
      @name = area+'.json'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'area.json')
      self.data['area'] = area
      self.data['courses'] = pages
    end
  end

  class RenderTimeTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "#{@text} #{Time.now}"
    end
  end

  class AreaPageGenerator < Generator
    safe true

    def generate(site)
      site.get_areas()
      p site.areas.keys
      site.areas.keys.each do | area |
        site.pages << AreaPage.new(site, site.source, "area", area, site.areas[area])
        site.pages << AreaMap.new(site, site.source, "data/area", area, site.areas[area])
      end
    end
  end

end
