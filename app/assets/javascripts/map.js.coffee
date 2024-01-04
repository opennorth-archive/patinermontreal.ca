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
    # Date
    abbr_month_names: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    time_format: '%{b} %{e}, %{l}%{P}'
    # Popup
    accuracy: 'You are within %{radius} meters of this point'
    condition: 'In %{condition} condition'
    unknown_condition: 'Ice condition not available'
    call_to_action: "You can contribute by asking the city to publish this rink’s conditions:"
    request_email: 'Email'
    request_phone: 'Phone'
    or_call: 'or call'
    add_favorite: 'Add to favorites'
    remove_favorite: 'Remove from favorites'
    explanation: 'Going skating? Let your friends know:'
    # Social
    tweet: "I’m going"
    tweet_text_PSE: "I’m going to play hockey at %{park}"
    tweet_text_PPL: "I’m going skating at %{park}"
    tweet_text_PP: "I’m going skating at %{park}"
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
    'Patinoire réfrigérée Bleu-Blanc-Bouge': 'Refrigerated rink Bleu-Blanc-Bouge'
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
    # smartbanner
    download: 'Download'
  fr:
    locale: 'fr'
    other_locale: 'en'
    # Date
    abbr_month_names: ['jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.']
    time_format: '%{b} %{e} à %{H}h'
    # Popup
    accuracy: 'Vous êtes à moins de %{radius} mètres de ce point'
    condition: 'En %{condition} condition'
    unknown_condition: 'État de la patinoire non disponible'
    call_to_action: "Vous pouvez contribuer en demandant à la ville de publier l’état de cette patinoire:"
    request_email: 'Courriel'
    request_phone: 'Téléphone'
    or_call: 'ou appelez le'
    add_favorite: 'Ajouter aux favories'
    remove_favorite: 'Supprimer des favories'
    explanation: 'Vous allez patiner? Informez vos amis:'
    # Social
    tweet: "J’y vais"
    tweet_text_PSE: 'Je vais jouer au hockey à %{park}'
    tweet_text_PPL: 'Je vais patiner à %{park}'
    tweet_text_PP: 'Je vais patiner à %{park}'
    # Rink kinds
    _PSE: "Sports d’équipe"
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
    # smartbanner
    download: 'Télécharger'

window.t = (string, args = {}) ->
  current_locale = args.locale or locale
  string = I18n[current_locale][string] or string
  string = string.replace ///%\{#{key}\}///g, value for key, value of args
  string

window.format_date = (string) ->
  date = new Date Date.parse(string)
  hour = date.getHours()
  args =
    b: t('abbr_month_names')[date.getMonth()]
    e: date.getDate()
    H: hour
    l: if hour > 12 then hour - 12 else (if hour is 0 then 12 else hour)
    P: if hour > 11 then 'pm' else 'am'
  t('time_format', args)

# Monkey-patch Backbone to be trailing-slash agnostic and to ignore query string.
# @see https://github.com/documentcloud/backbone/issues/520
((_getFragment) ->
    Backbone.History.prototype.getFragment = ->
      _getFragment.apply(this, arguments).replace(/\/$/, '').replace(/\?.*/, '')
) Backbone.History.prototype.getFragment

other_locale = t 'other_locale'
other_domain = $('#language a').attr('href').match(/^http(s?):\/\/[^\/]+\//)[0].replace t('locale'), other_locale

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

  $('.control').tooltip()

  $.smartbanner
    title: "Patiner Montréal"
    authors: {'android': 'Android' , 'ios': 'iPhone'}
    price: null
    appStoreLanguage: t('locale')
    icons: {'android': '/assets/app-icon-android.png', 'ios': '/assets/app-icon-ios.png'}
    iOSUniversalApp: false
    button: t('download')
    appendToSelector: 'header'

  # Toggle social sidebar
  $(window).on 'load', (e) ->
    $('#share-toggle').fadeIn();
  $('#share-toggle').on 'click', (e) ->
    e.preventDefault();
    $('#social .navbar').slideToggle( 'fast' )
    return

  # Create map.
  Map = new L.Map 'map',
    center: new L.LatLng(45.53, -73.63)
    zoom: 13
    minZoom: 11
    maxZoom: 18
    maxBounds: L.latLngBounds(L.latLng(45.170459, -74.447699), L.latLng(46.035873, -73.147435))

  tilesUrl = "https://tiles.stadiamaps.com/tiles/stamen_toner_lite/{z}/{x}/{y}{r}.{ext}";

  basemap = new L.tileLayer(tilesUrl, {
    ext: 'png',
    attribution: '&copy; <a href="https://www.stadiamaps.com/" target="_blank">Stadia Maps</a> &copy; <a href="https://www.stamen.com/" target="_blank">Stamen Design</a> &copy; <a href="https://openmaptiles.org/" target="_blank">OpenMapTiles</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(Map);

  # Define models.
  Rink = Backbone.Model.extend
    # @note +defaults+ doesn't have access to model attributes or collection.
    initialize: (attributes) ->
      # Handing "C" is unnecessarily hard.
      @set(genre: 'PP') if 'C' is @get 'genre'
      @set url: t('rinks_url', id: @get('id'), slug: @get('slug'))

      # Set the favorite based on local storage.
      Backbone.sync 'read', @,
        success: (response) =>
          @set favorite: response.favorite
        error: (message) =>
          # Do nothing.
    defaults:
      favorite: false
      visible: false
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
        model.view = new MarkerView model: model

  # @expects a Rink model
  MarkerView = Backbone.View.extend
    template: _.template $('#popup-template').html()
    # @see L.Marker.bindPopup
    initialize: ->
      offset = new L.Point 0, -10

      state = if @model.get 'ouvert'
        'on'
      else if @model.get 'condition' # rinks with conditions receive updates
        'off'
      else
        'na'

      icon = L.Icon.extend
        options:
          iconUrl: "/assets/#{@model.get 'genre'}_#{state}.png"
          iconRetinaUrl: "/assets/#{@model.get 'genre'}_#{state}_2x.png"
          shadowUrl: "/assets/#{@model.get 'genre'}_shadow.png"
          iconSize: new L.Point 28, 28
          shadowSize: new L.Point 34, 26
          iconAnchor: new L.Point 15, 27
          shadowAnchor: [13, 22]
          popupAnchor: offset
      # "new L.Icon.extend({})" raises "TypeError: object is not a function"

      @marker = new L.Marker new L.LatLng(@model.get('lat'), @model.get('lng')), icon: new icon
      @marker._popup = new L.Popup offset: offset, autoPan: true, autoPanPaddingTopLeft: [50,100], autoPanPaddingBottomRight: [70,40], closeButton: false, @marker
      @marker._popup.setContent @template @model.toJSON()
      @marker._popup._initLayout()

      # @see delegateEvents
      $(@marker._popup._contentNode).delegate '.favorite', 'click.delegateEvents' + @cid, _.bind ->
        @model.toggle()
      , @
      @marker.on 'click', ->
        Options.save(beforePopup: @currentUrl()) unless @rinkUrl()
        Backbone.history.navigate @model.get('url'), true
      , @
      @model.bind 'change:favorite', ->
        @marker._popup.setContent @template @model.toJSON()
        twttr.widgets.load() if twttr.widgets
      , @
      @model.bind 'change:visible', @render, @
    render: ->
      if @model.get 'visible'
        Map.addLayer @marker
      else
        Map.removeLayer @marker
      @
    # Opens the marker's popup.
    openPopup: ->
      # Prevent restoration of last known state if opening another popup.
      Options.save openingPopup: true
      @marker.openPopup()
      Options.save openingPopup: false
      # Refresh Twitter button.
      twttr.widgets.load() if twttr.widgets
      # Pan to popup.
      $('#social .navbar').slideUp()

  # Don't navigate to the last known state if opening another popup.
  Map.on 'popupclose', (event) ->
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
      rink.view.openPopup()
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
    body: (arrondissement) ->
      string = if arrondissement.name then "Attn: #{arrondissement.name}\r\n\r\n" else ''
      string += "Serait-il possible de publier l'état de vos patinoires extérieures comme le font plusieurs arrondissements à la Ville de Montréal ? Voir: https://ville.montreal.qc.ca/portal/page?_pageid=5798,94909650&_dad=portal&_schema=PORTAL\r\n\r\nMerci."
      encodeURIComponent string


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
  #window.location.replace window.location.pathname
  Backbone.history.start pushState: true

  # https://support.cloudmade.com/answers/general
  Map.on 'locationfound', (event) ->
    radius = event.accuracy / 2
    if radius < 1000
      locationIcon = L.Icon.extend
        options:
          iconUrl: "/assets/marker-icon.png"
          iconRetinaUrl: "/assets/marker-icon-2x.png"
          shadowUrl: "/assets/marker-shadow.png"
          iconSize: [25, 41]
          shadowSize: [33, 31]
          iconAnchor:   [12, 41]
          shadowAnchor: [10, 31]
          popupAnchor:  [0, -46]
      marker = new L.Marker event.latlng, icon: new locationIcon
      Map.addLayer marker
      marker.bindPopup t 'accuracy', radius: radius
      Map.addLayer new L.Circle event.latlng, radius
  Map.on 'locationerror', (event) ->
    console.log event.message if window.debug

  # If a popup is open, don't set the view to the marker.
  if Helpers.rinkUrl()
    Map.locate()
  else
    Map.locate( setView: true, zoom: 13 )

  # Backbone doesn't attach the "events" option directly to the view, even
  # though it makes sense given that views needn't necessarily hardcode CSS
  # selectors (and maybe shouldn't).
  # @see https://github.com/documentcloud/backbone/issues/656
