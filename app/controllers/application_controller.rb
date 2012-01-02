class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] ||
      I18n.available_locales.find{|x| x.to_s == request.subdomains.first} ||
      request.compatible_language_from(I18n.available_locales) ||
      I18n.default_locale
  end
end
