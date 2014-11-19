module Breadcrumbs
  ##
  # Returns ordered list
  def get_pages(url)
    pages = []
    index = 'index.html'

    parts = url.gsub(/^\//, '').gsub(index, '').split '/'
    if parts.length > 1
      locale = parts[0]
      root = site.data['menu']['main'][locale][0]['path']
      if parts[1] != root
        pages << get_page_from_url(locale, root, index)
        (1...parts.length).each do |i|
          pages << get_page_from_url(parts[0..i], index)
        end
      end
    end
    pages
  end

  def join(*parts)
    '/' + parts.flat_map { |part| [part] }.join('/')
  end

  ##
  # Gets Page object that has given url. Very inefficient O(n) solution.
  def get_page_from_url(*parts)
    url = join *parts
    site.pages.each do |page|
      return page if page.url == url
    end
  end

  def ancestors
    get_pages(self.url)
  end

  ##
  # Make ancestors available.
  def to_liquid(attrs = self.class::ATTRIBUTES_FOR_LIQUID)
    super(attrs + %w[
				ancestors
			])
  end
end

##
# Monkey patch Jekyll's Page and Post classes.
module Jekyll

  class Page
    include Breadcrumbs
  end
end
