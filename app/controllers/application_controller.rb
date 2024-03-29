class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] ||
      I18n.available_locales.find{|x| x.to_s == request.subdomains.first} ||
      I18n.default_locale
  end
end
