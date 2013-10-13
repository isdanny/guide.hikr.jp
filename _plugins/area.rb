module Jekyll

  class Site

    attr_accessor :areas

    def get_areas()
      if self.areas.nil?
        self.areas = {}
        self.pages.each do |page|
          if page.data.key? "area"
            area = page.data["area"]
            if ! self.areas.key? area
              self.areas[area] = []
            end
            self.areas[area].push(page)
          end
        end
      end
      self.areas
    end

    alias orig_site_payload site_payload
    def site_payload
      get_areas()
      h = orig_site_payload
      payload = h["site"]
      payload['areas'] = self.areas 
      h["site"] = payload
      h
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
      self.data['area'] = area
      self.data['courses'] = pages
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
      site.areas.keys.each do | area |
        site.pages << AreaPage.new(site, site.source, "area", area, site.areas[area])
        site.pages << AreaMap.new(site, site.source, "data/area", area, site.areas[area])
      end
    end
  end

end