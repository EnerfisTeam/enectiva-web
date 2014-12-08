module Jekyll
  module GalleryLinkFilter

    def gallery_link(input, asset, gallery, cls = '')

      img = "<img
        src=\"/img/screen_thumbs/#{asset}.png\"
        alt=\"#{input}\"
        width=\"145\"
        height=\"145\">"
      "<a
        href=\"/img/screens/#{asset}.png\"
        rel=\"gal[#{gallery}]\"
        class=\"swipebox #{cls}\">#{img}</a>"
    end
  end
end

Liquid::Template.register_filter(Jekyll::GalleryLinkFilter)