module Jekyll
  module ExtractLocaleFilter

    def extract_locale(input)
      locale = input[1, 2]

      unless @context.registers[:site].config['authorized_locales'].include? locale
        locale = @context.registers[:site].config['default_locale']
      end
      locale
    end
  end
end

Liquid::Template.register_filter(Jekyll::ExtractLocaleFilter)