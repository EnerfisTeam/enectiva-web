# encoding=utf-8
base_path = 'soluzioni'
locale = 'it'
text = File.read(locale + '/' + base_path + '/index.html')
text.scan(/feature__title">(.+?)<.+?inner">(.+?)<\/div>/m) do |m|
  title, cont = m
  accents = 'Úěščřžýáíéůú '
  clean = 'uescrzyaieuu-'
  slug = title.downcase.tr(accents, clean).gsub(',', '')


  path = '_solutions/' + base_path + '/' + locale + '/'
  Dir.mkdir path unless Dir.exists? path
  File.open(path + slug + '.html', 'w') do |file|
    header = <<HEADER
---
layout: default
title: #{title}
locale: #{locale}
---

<h1>#{title}</h1>
HEADER
    file.write(header)
    file.write(cont)
  end
end
