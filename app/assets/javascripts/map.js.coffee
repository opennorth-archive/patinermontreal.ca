# @see hasClass
$.fn.hasAttr = (attr) ->
  _.any this, (el) ->
    typeof $(el).attr(attr) isnt 'undefined'

# @see toggleClass
$.fn.toggleAttr = (attr, state) ->
  isBoolean = typeof state is 'boolean'
  this.each ->
    self = $ this
    state = not self.hasAttr(attr) unless isBoolean
    if state
      self.attr attr, attr
    else
      self.removeAttr attr

# Monkey-patch Backbone to be trailing-slash agnostic.
# @see https://github.com/documentcloud/backbone/issues/520
((_getFragment) ->
    Backbone.History.prototype.getFragment = ->
      _getFragment.apply(this, arguments).replace /\/$/, ''
) Backbone.History.prototype.getFragment

$ ->
  window.debug = env is 'development'

  # Simple i18n "framework".
  I18n =
    en:
      accuracy: 'You are within %{radius} meters of this point'
      rinks_url: 'rinks/%{id}-%{slug}'
      favorites_url: 'favorites'
      rinks: 'rinks'
      # Translate rink kinds and statuses.
      'sports-dequipe': 'team-sports'
      'patin-libre': 'free-skating'
      'paysagee': 'landscaped'
      'ouvert': 'open'
      'deblaye': 'cleared'
      'arrose': 'flooded'
      'resurface': 'resurfaced'
      'favories': 'favorites'
      # Translate from rink kind to path component.
      PSE: 'team-sports'
      PPL: 'free-skating'
      PP: 'landscaped'
      C: 'landscaped'
    fr:
      accuracy: 'Vous êtes à moins de %{radius} mètres de ce point'
      rinks_url: 'patinoires/%{id}-%{slug}'
      favorites_url: 'favories'
      rinks: 'patinoires'
      # Translate from rink kind to path component.
      PSE: 'sports-dequipe'
      PPL: 'patin-libre'
      PP: 'paysagee'
      C: 'paysagee'

  t = (string, args) ->
    string = I18n[locale] and I18n[locale][string] or string
    if args
      for key, value of args
        string = string.replace "%{#{key}}", value
    string

  # Create map.
  Map = new L.Map 'map',
    center: new L.LatLng(45.53, -73.63)
    zoom: 13
    layers: [
      new L.TileLayer 'http://{s}.tile.cloudmade.com/266d579a42a943a78166a0a732729463/51080/256/{z}/{x}/{y}.png',
        attribution: '© 2011 <a href="http://cloudmade.com/">CloudMade</a> – Map data <a href="http://creativecommons.org/licenses/by-sa/2.0/">CCBYSA</a> 2011 <a href="http://openstreetmap.org/">OpenStreetMap.org</a> contributors – <a href="http://cloudmade.com/about/api-terms-and-conditions">Terms of Use</a>'
    ]
    minZoom: 10
    maxZoom: 18

  # Define models.
  Rink = Backbone.Model.extend
    initialize: (attributes) ->
      # Coerce booleans.
      _.each ['ouvert', 'deblaye', 'arrose', 'resurface'], (key) =>
        unless attributes[key]?
          attrs = {}
          attrs[key] = false
          @set(attrs)
      # Handing "C" is unnecessarily hard.
      @set(genre: 'PP') if 'C' is @get 'genre'
    defaults:
      favorite: false
      visible: false
      view: null
    # Sets the rink as visible.
    show: ->
      @set visible: true
    # Sets the rink as hidden.
    hide: ->
      @set visible: false
    # Toggles the rink's favorite status.
    toggle: ->
      @save favorite: not @get 'favorite'

  # Define collections.
  RinkSet = Backbone.Collection.extend
    model: Rink
    localStorage: new Store 'rinks'
    # Sets only matching rinks as visible.
    showIfMatching: (kinds, statuses) ->
      @each (rink) ->
        rink.set visible: (rink.get('genre') in kinds and _.all statuses, (status) -> rink.get status)
      @trigger 'changeAll', kinds, statuses
    # Sets only favorite rinks as visible.
    showIfFavorite: ->
      @each (rink) ->
        rink.set visible: rink.get 'favorite'
      @trigger 'changeAll'
    # @return array all visible rinks
    visible: ->
      @filter (rink) ->
        rink.get 'visible'
    # @return array all favorite rinks
    favorites: ->
      @filter (rink) ->
        rink.get 'favorite'

  # @expects a RinkSet collection
  MarkersView = Backbone.View.extend
    initialize: ->
      @collection.each (model) ->
        view = new MarkerView model: model
        model.set view: view

  # @expects a Rink model
  MarkerView = Backbone.View.extend
    initialize: ->
      icon = L.Icon.extend
        iconUrl: "/assets/#{@model.get 'genre'}_#{if @model.get 'ouvert' then 'on' else 'off'}.png"
        shadowUrl: "/assets/#{@model.get 'genre'}_shadow.png"
        iconSize: new L.Point 28, 28
        shadowSize: new L.Point 44, 28
        iconAnchor: new L.Point 15, 27
        popupAnchor: new L.Point(0, -24) # CoffeeScript bug requires parentheses?
      # "new L.Icon.extend({})" raises "TypeError: object is not a function"
      @marker = new L.Marker new L.LatLng(@model.get('lat'), @model.get('lng')), icon: new icon
      @marker.bindPopup('test') # TODO make popup appear with favorite, i'm going (Twitter, Facebook), last update
      # Replace the default "click" callback.
      @marker.off 'click', @marker.openPopup
      @marker.on 'click', @show, @
      @model.bind 'change:visible', @render, @
    render: ->
      if @model.get 'visible'
        @addMarker()
      else
        @removeMarker()
      @
    # Adds the rink's marker to the map.
    addMarker: ->
      Map.addLayer @marker
    # Removes a rink's marker from the map.
    removeMarker: ->
      Map.removeLayer @marker
    # Opens the marker's popup.
    openPopup: ->
      # Prevent restoration of last known state if opening another popup.
      Options.save openingPopup: true
      @marker.openPopup()
      Options.save openingPopup: false
      Map.panTo @marker.getLatLng()
    show: ->
      unless @rinkUrl()
        Options.save beforePopup: @currentUrl()
      Backbone.history.navigate t('rinks_url', id: @model.get('id'), slug: @model.get('slug')), true
  # TODO in popup: rink.toggle and @collection.bind 'change:favorite', ->

  Map.on 'popupclose', (event) ->
    # Don't navigate to the last known state if opening another popup.
    unless Options.get 'openingPopup'
      Backbone.history.navigate Options.get('beforePopup'), true

  # A view for the primary buttons.
  # @expects a RinkSet collection
  ControlsView = Backbone.View.extend
    initialize: ->
      _.each ['PP', 'PPL', 'PSE'], (id) =>
        new ControlView collection: @collection, el: "##{id}", type: 'kinds'
      _.each ['deblaye', 'arrose', 'resurface'], (id) =>
        new ControlView collection: @collection, el: "##{id}", type: 'statuses'
      new ControlView collection: @collection, el: '#favories'

  # A view for a single button.
  # @expects a RinkSet collection
  ControlView = Backbone.View.extend
    initialize: (attributes) ->
      @id = $(@el).attr 'id'
      @type = attributes.type
      @collection.bind 'changeAll', @render, @
    events:
      click: 'toggle'
    render: (kinds, statuses) ->
      if @type?
        # Don't change state of controls if showing "my favorites".
        unless @favoritesUrl()
          state = @id in kinds or @id in statuses
          @$('.icon').toggleClass 'active', state
          @$('input').toggleAttr 'checked', state
      else
        @$('.icon').toggleClass 'active', @favoritesUrl()
      @
    toggle: (state) ->
      # This creates an extra history entry if switching from an open popup to
      # "my favorites", but it's simplest.
      Map.closePopup()
      if @type?
        [kinds, statuses] = if @filterUrl() then @fromUrl @currentUrl() else @fromUI()
        if @type is 'kinds'
          filters = kinds
        else
          filters = statuses
        if @id in filters
          filters = _.without filters, @id
        else
          filters.push @id
        if @type is 'kinds'
          kinds = filters
        else
          statuses = filters
        Backbone.history.navigate @toUrl(kinds, statuses), true
      else
        if @$('.icon').hasClass 'active'
          Backbone.history.navigate Options.get('beforeFavorites'), true
        else
          unless @favoritesUrl()
            Options.save beforeFavorites: @currentUrl()
          Backbone.history.navigate t('favorites_url'), true

  # Define routes.
  # @expects a RinkSet collection
  Router = Backbone.Router.extend
    initialize: (attributes) ->
      @collection = attributes.collection
    # Maps path components to actions.
    routes:
      '': 'default'
      'about': 'about'
      'a-propos': 'about'
      'contact': 'contact'
      'donate': 'donate'
      'dons': 'donate'
      'api': 'api'
      'favorites': 'favorites'
      'favories': 'favorites'
      'f': 'filter'
      'f/*filters': 'filter'
      'rinks/:id': 'show'
      'patinoires/:id': 'show'
    # Performs the "about" action.
    about: ->
      # TODO display about
    # Performs the "contact" action.
    contact: ->
      # TODO display contact
    # Performs the "donate" action.
    donate: ->
      # TODO display donate
    # Performs the "api" action.
    api: ->
      # TODO display api
    # Performs the "favorites" action.
    favorites: ->
      @collection.showIfFavorite()
    # Performs the "filter" action.
    # @param string splat a URL path
    filter: (splat) ->
      @collection.showIfMatching @fromUrl(splat)...
    # Performs the "show" action.
    # @param string id a rink ID
    show: (id) ->
      # Remove the slug from the ID.
      matches = id.match /^\d+/
      rink = @collection.get matches[0]
      # If rink is not visible, display all rinks first.
      unless rink.get 'visible'
        @collection.showIfMatching @fromUrl(@rootUrl())...
      rink.get('view').openPopup()
    default: ->
      # If no route, display all rinks.
      @navigate @rootUrl(), true

  # Helpers to mix-in to views and routers.
  Helpers =
    # Maps path components to rink kinds.
    kinds:
      'team-sports': 'PSE'
      'sports-dequipe': 'PSE'
      'free-skating': 'PPL'
      'patin-libre': 'PPL'
      'landscaped': 'PP'
      'paysagee': 'PP'
    # Maps path components to rink statuses.
    statuses:
      'cleared': 'deblaye'
      'deblaye': 'deblaye'
      'flooded': 'arrose'
      'arrose': 'arrose'
      'resurfaced': 'resurface'
      'resurface': 'resurface'
    # @return string the current URL
    currentUrl: ->
      Backbone.history.getFragment()
    # @return string the root URL
    rootUrl: ->
      @toUrl ['PP', 'PPL', 'PSE'], []
    # @return boolean whether the current URL is a filter URL
    filterUrl: ->
      @currentUrl().indexOf('f/') >= 0
    # @return boolean whether the current URL is a rink URL
    rinkUrl: ->
      @currentUrl().indexOf(t 'rinks') >= 0
    # @return boolean whether the current URL is the favorites URL
    favoritesUrl: ->
      @currentUrl() is t 'favorites_url'
    # Returns a filter URL based on the UI's state.
    # @return array a two-value array where the first value is an array of rink
    #   kinds and the second value is an array of rink statuses
    fromUI: ->
      kinds = _.filter ['PP', 'PPL', 'PSE'], (filter) ->
        $("##{filter} .icon").hasClass 'active'
      statuses = _.filter ['deblaye', 'arrose', 'resurface'], (filter) ->
        $("##{filter} .icon").hasClass 'active'
      [kinds, statuses]
    # @param string splat a URL path
    # @return array a two-value array where the first value is an array of rink
    #   kinds and the second value is an array of rink statuses
    fromUrl: (splat) ->
      kinds = []
      statuses = []
      if splat?
        for part in splat.split('/')
          if part of @kinds
            kinds.push @kinds[part]
          else if part of @statuses
            statuses.push @statuses[part]
          else if part is 'f'
            # Do nothing.
          else
            console.log "Unknown filter: #{part}" if window.debug
      [kinds, statuses]
    # Performs the inverse of +fromUrl+.
    # @param array kinds rink kinds
    # @param array statuses rink statuses
    # @return string a URL path
    toUrl: (kinds, statuses) ->
      'f/' + _.uniq(_.map(kinds.sort().concat(statuses.sort()), (status) -> t status)).join '/'

  # Set up options singleton.
  Singleton = Backbone.Model.extend
    localStorage: new Store 'options'
  Options = new Singleton
    id: 1
    beforeFavorites: Helpers.rootUrl()
    beforePopup: Helpers.rootUrl()
    openingPopup: false

  # Add helper functions to views and routers.
  _.each [MarkersView, MarkerView, ControlsView, ControlView, Router], (klass) ->
    _.extend klass.prototype, Helpers

  # Seed collection.
  Rinks = new RinkSet
  Rinks.reset json

  # Instantiate routes.
  Routes = new Router
    collection: Rinks

  # Instantiate views.
  markers = new MarkersView
    el: '#map' # to avoid creating an element
    collection: Rinks
  controls = new ControlsView
    el: '#controls' # to avoid creating an element
    collection: Rinks

  # Route the initial URL.
  Backbone.history.start pushState: true

  # http://support.cloudmade.com/answers/general
  Map.on 'locationfound', (event) ->
    marker = new L.Marker event.latlng
    Map.addLayer marker
    radius = event.accuracy / 2
    marker.bindPopup t 'accuracy', radius: radius
    Map.addLayer new L.Circle event.latlng, radius
  Map.on 'locationerror', (event) ->
    console.log event.message if window.debug

  # If a popup is open, don't set the view to the marker.
  if Helpers.rinkUrl()
    Map.locate()
  else
    Map.locateAndSetView 14

  # Backbone doesn't attach the "events" option directly to the view, even
  # though it makes sense given that views needn't necessarily hardcode CSS
  # selectors (and maybe shouldn't).
  # @see https://github.com/documentcloud/backbone/issues/656
