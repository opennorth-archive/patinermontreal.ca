class PagesController < ApplicationController
  def index
    @rinks = Patinoire.all
  end

  def about
  end

  def contact
  end

end
