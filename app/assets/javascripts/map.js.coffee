# TODO switch to Rinks.fetch?

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
  # Create map.
  Map = new L.Map 'map',
    center: new L.LatLng(45.53, -73.63)
    zoom: 13
    layers: [
      new L.TileLayer 'http://{s}.tile.cloudmade.com/266d579a42a943a78166a0a732729463/51080/256/{z}/{x}/{y}.png',
        maxZoom: 18
        attribution: '© 2011 <a href="http://cloudmade.com/">CloudMade</a> – Map data <a href="http://creativecommons.org/licenses/by-sa/2.0/">CCBYSA</a> 2011 <a href="http://openstreetmap.org/">OpenStreetMap.org</a> contributors – <a href="http://cloudmade.com/about/api-terms-and-conditions">Terms of Use</a>'
    ]
    minZoom: 10
    maxZoom: 16

  # http://support.cloudmade.com/answers/general
  Map.locateAndSetView 14
  Map.on 'locationfound', (event) ->
    radius = event.accuracy / 2
    marker = new L.Marker event.latlng
    Map.addLayer marker
    marker.bindPopup "You are within #{radius} meters from this point" # @todo translate
    Map.addLayer new L.Circle event.latlng, radius
  Map.on 'locationerror', (event) ->
    console.log event.message if window.debug
  Map.on 'popupclose', (event) ->
    console.log event

  # Simple i18n "framework".
  I18n =
    en:
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
      # Translate from rink kind to path component.
      PSE: 'sports-dequipe'
      PPL: 'patin-libre'
      PP: 'paysagee'
      C: 'paysagee'

  t = (string) ->
    I18n[locale] and I18n[locale][string] or string

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
    # @note "new L.Icon.extend({})" raises "TypeError: object is not a function"
    initialize: ->
      icon = L.Icon.extend
        iconUrl: "/assets/#{@model.get 'genre'}_#{if @model.get 'ouvert' then 'on' else 'off'}.png"
        shadowUrl: "/assets/#{@model.get 'genre'}_shadow.png"
        iconSize: new L.Point 28, 28
        shadowSize: new L.Point 44, 28
        iconAnchor: new L.Point 15, 27
        popupAnchor: new L.Point(0, -24) # CoffeeScript bug requires parentheses?
      @marker = new L.Marker new L.LatLng(@model.get('lat'), @model.get('lng')), icon: new icon
      @marker.bindPopup('test') # TODO make popup appear with favorite, i'm going (Twitter, Facebook), last update
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
      @marker.openPopup()
      Map.setView @marker.getLatLng(), 15
  # TODO when clicking on marker, navigate to rink/:id for bookmarking
  # TODO in popup: rink.toggle and @collection.bind 'change:favorite', ->

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
        unless @currentUrl() is t 'favorites'
          state = @id in kinds or @id in statuses
          @$('.icon').toggleClass 'active', state
          @$('input').toggleAttr 'checked', state
      else
        state = @currentUrl() is t 'favorites'
        @$('.icon').toggleClass 'active', state
      @
    toggle: (state) ->
      if @type?
        [kinds, statuses] = @fromUrl @currentUrl()
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
          Backbone.history.navigate Options.get('path'), true
          Options.save path: @rootUrl()
        else
          Options.save path: @currentUrl()
          Backbone.history.navigate t('favorites'), true

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
      'rink/:id': 'show'
      'patinoire/:id': 'show'
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
      rink = @collection.get(id)
      # If rink is not visible, display all rinks.
      unless rink.get 'visible'
        @collection.showIfMatching @fromUrl(@rootUrl())...
      rink.get('view').openPopup()
    default: ->
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
    currentUrl: ->
      Backbone.history.getFragment()
    rootUrl: ->
      @toUrl ['PP', 'PPL', 'PSE'], []
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

  # Add helper functions to views and routers.
  _.each [MarkersView, MarkerView, ControlsView, ControlView, Router], (klass) ->
    _.extend klass.prototype, Helpers

  # Seed collection.
  Rinks = new RinkSet
  Rinks.reset json

  # Instantiate routes.
  Routes = new Router
    collection: Rinks

  # Set up options singleton.
  Singleton = Backbone.Model.extend
    localStorage: new Store 'options'
  Options = new Singleton
    path: Helpers.rootUrl()

  # Instantiate views.
  markers = new MarkersView
    el: '#map' # to avoid creating an element
    collection: Rinks
  controls = new ControlsView
    el: '#controls' # to avoid creating an element
    collection: Rinks

  # Route the initial URL.
  Backbone.history.start pushState: true

  window.debug = env is 'development'

  # Backbone doesn't attach the "events" option directly to the view, even
  # though it makes sense given that views needn't necessarily hardcode CSS
  # selectors (and maybe shouldn't).
  # @see https://github.com/documentcloud/backbone/issues/656
