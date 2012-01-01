class PagesController < ApplicationController
  def index
    @rinks = Patinoire.geocoded
    # @todo check that this works across languages, otherwise do:
    # http://blog.slashpoundbang.com/post/12701215379/how-to-cache-an-internationalized-site-with-rack-cache
    # or add the locale to the etag
    fresh_when etag: @rinks, last_modified: @rinks.maximum(:updated_at).utc, public: true
  end

  def about
  end

  def contact
  end

  def channel
    render layout: false
  end
end
