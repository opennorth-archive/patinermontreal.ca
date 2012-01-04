$(window).resize ->
  $('#inside').height $(window).height() - 86

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

# Simple i18n "framework".
I18n =
  en:
    locale: 'en'
    other_locale: 'fr'
    # Popup
    accuracy: 'You are within %{radius} meters of this point'
    condition: 'in %{condition} condition'
    unknown_condition: 'Ice condition not available'
    instructions: "<em>Ask %{region} to publish the condition of its rinks by contacting:</em>"
    add_favorite: 'Add to favorites'
    remove_favorite: 'Remove from favorites'
    # Social
    tweet: 'Tweet'
    tweet_related: 'opennorth:The creators of Patiner Montreal'
    tweet_text_PSE: "I'm going to play hockey at %{park}"
    tweet_text_PPL: "I'm going skating at %{park}"
    tweet_text_PP: "I'm going skating at %{park}"
    # Rink kinds
    _PSE: 'Team sports'
    _PPL: 'Free skating'
    _PP: 'Landscaped'
    # Rink descriptions
    'Aire de patinage libre': 'Free skating area'
    'Grande patinoire avec bandes': 'Big rink with boards'
    'Patinoire avec bandes': 'Rink with boards'
    'Patinoire de patin libre': 'Free skating rink'
    'Patinoire décorative': 'Decorative rink'
    'Patinoire entretenue par les citoyens': 'Rink maintained by citizens'
    'Patinoire réfrigérée': 'Refrigerated rink'
    'Petite patinoire avec bandes': 'Small rink with boards'
    # Interface statuses
    open: 'Open'
    closed: 'Closed'
    cleared: 'Cleared'
    flooded: 'Flooded'
    resurfaced: 'Resurfaced'
    Excellente: 'excellent'
    Bonne: 'good'
    Mauvaise: 'bad'
    # URLs
    rinks: 'rinks'
    rinks_url: 'rinks/%{id}-%{slug}'
    favorites_url: 'favorites'
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
    locale: 'fr'
    other_locale: 'en'
    # Popup
    accuracy: 'Vous êtes à moins de %{radius} mètres de ce point'
    condition: 'en %{condition} condition'
    unknown_condition: 'État de la patinoire non disponible'
    instructions: "<em>Demandez à %{region} de publier l'état de ses patinoires en contactant :</em>"
    add_favorite: 'Ajouter aux favories'
    remove_favorite: 'Supprimer des favories'
    # Social
    tweet: 'Tweeter'
    tweet_related: 'nordouvert:Les créateurs de Patiner Montréal'
    tweet_text_PSE: 'Je vais jouer au hockey à %{park}'
    tweet_text_PPL: 'Je vais patiner à %{park}'
    tweet_text_PP: 'Je vais patiner à %{park}'
    # Rink kinds
    _PSE: "Sports d'équipe"
    _PPL: 'Patin libre'
    _PP: 'Paysagée'
    # Interface statuses
    open: 'Ouverte'
    closed: 'Fermée'
    cleared: 'Déblayée'
    flooded: 'Arrosée'
    resurfaced: 'Resurfacée'
    Excellente: 'excellente'
    Bonne: 'bonne'
    Mauvaise: 'mauvaise'
    # URLs
    rinks: 'patinoires'
    rinks_url: 'patinoires/%{id}-%{slug}'
    favorites_url: 'favories'
    # Translate from rink kind to path component.
    PSE: 'sports-dequipe'
    PPL: 'patin-libre'
    PP: 'paysagee'
    C: 'paysagee'

window.t = (string, args = {}) ->
  current_locale = args.locale or locale
  string = I18n[current_locale][string] or string
  string = string.replace ///%\{#{key}\}///g, value for key, value of args
  string

# Monkey-patch Backbone to be trailing-slash agnostic.
# @see https://github.com/documentcloud/backbone/issues/520
((_getFragment) ->
    Backbone.History.prototype.getFragment = ->
      _getFragment.apply(this, arguments).replace /\/$/, ''
) Backbone.History.prototype.getFragment

other_locale = t 'other_locale'
other_domain = $('#language a').attr('href').match(/^http:\/\/[^\/]+\//)[0].replace t('locale'), other_locale

# Update the language switch link after each navigation event.
((_navigate) ->
    Backbone.History.prototype.navigate = ->
      _navigate.apply this, arguments
      $('#language a').attr 'href', _.reduce ['about', 'contact', 'donate', 'api', 'rinks', 'favorites', 'sports-dequipe', 'patin-libre', 'paysagee', 'ouvert', 'deblaye', 'arrose', 'resurface'], (string,component) ->
        string.replace t(component), t(component, locale: other_locale)
      , other_domain + Backbone.history.getFragment()
) Backbone.History.prototype.navigate

$ ->
  window.debug = env is 'development'

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
      # Handing "C" is unnecessarily hard.
      @set(genre: 'PP') if 'C' is @get 'genre'
      @set url: t('rinks_url', id: @get('id'), slug: @get('slug'))
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
    template: _.template $('#popup-template').html()
    initialize: ->
      state = if @model.get 'ouvert'
        'on'
      else if @model.get 'condition' # rinks with conditions receive updates
        'off'
      else
        'na'
      icon = L.Icon.extend
        iconUrl: "/assets/#{@model.get 'genre'}_#{state}.png"
        shadowUrl: "/assets/#{@model.get 'genre'}_shadow.png"
        iconSize: new L.Point 28, 28
        shadowSize: new L.Point 44, 28
        iconAnchor: new L.Point 15, 27
        popupAnchor: new L.Point(0, -24) # CoffeeScript bug requires parentheses?
      # "new L.Icon.extend({})" raises "TypeError: object is not a function"
      @marker = new L.Marker new L.LatLng(@model.get('lat'), @model.get('lng')), icon: new icon
      @marker.bindPopup @template @model.toJSON()
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
      twttr.widgets.load() if twttr.widgets
      Options.save openingPopup: false
      Map.panTo @marker.getLatLng()
    show: ->
      unless @rinkUrl()
        Options.save beforePopup: @currentUrl()
      Backbone.history.navigate @model.get('url'), true
  # @todo in popup: rink.toggle and @collection.bind 'change:favorite', ...
  # @todo favorite may need to be a view in order to define events on it

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
      _.each ['ouvert', 'deblaye', 'arrose', 'resurface'], (id) =>
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
      'favorites': 'favorites'
      'favories': 'favorites'
      'f': 'filter'
      'f/*filters': 'filter'
      'rinks/:id': 'show'
      'patinoires/:id': 'show'
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
      rink = @collection.get id.match(/^\d+/)[0]
      # If rink is not visible, display all rinks first.
      unless rink.get 'visible'
        @collection.showIfMatching @fromUrl(@rootUrl())...
      rink.get('view').openPopup()
    default: ->
      # If no route, display all rinks.
      @navigate @rootUrl(), true

  # Helpers to mix-in to views and routers.
  window.Helpers =
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
      'open': 'ouvert'
      'ouvert': 'ouvert'
      'cleared': 'deblaye'
      'deblaye': 'deblaye'
      'flooded': 'arrose'
      'arrose': 'arrose'
      'resurfaced': 'resurface'
      'resurface': 'resurface'
    numberToPhone: (number, options = {}) ->
      number = number.replace(/([0-9]{3})([0-9]{3})([0-9]{4})/, '($1) $2-$3')
      if options.extension
        number += ' x' + options.extension
      number
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
      statuses = _.filter ['ouvert', 'deblaye', 'arrose', 'resurface'], (filter) ->
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
      'f/' + _.uniq(_.map(kinds.sort().concat(statuses.sort()), (filter) -> t filter)).join '/'

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
  window.Rinks = new RinkSet
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
