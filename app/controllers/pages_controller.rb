class PagesController < ApplicationController
  def index
    @rinks = Patinoire.geocoded
  end

  def about
  end

  def contact
  end

end
