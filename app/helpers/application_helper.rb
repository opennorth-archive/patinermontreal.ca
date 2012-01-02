module ApplicationHelper
  def translated_path
    other_locale = t :other_locale
    %w(about contact donate api rinks favorites PSE PPL PP ouvert deblaye arrose resurface).reduce(request.fullpath) do |string,component|
      string.sub t(component), t(component, locale: other_locale)
    end
  end
end
