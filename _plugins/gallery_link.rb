module Jekyll
  module GalleryLinkFilter

    def gallery_link(input, asset, gallery, cls = '')

      img = "<img src=\"/img/screens_p/#{asset}_300.png\" alt=\"#{input}\" width=\"300\">"
      "<a
        href=\"/img/screens/#{asset}_1150.png\"
        rel=\"gal[#{gallery}]\"
        class=\"swipebox #{cls}\">#{img}</a>"
    end
  end
end

Liquid::Template.register_filter(Jekyll::GalleryLinkFilter)