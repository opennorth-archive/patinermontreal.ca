$ ->
  # Create map.
  Map = new L.Map 'map',
    center: new L.LatLng(45.53, -73.63)
    zoom: 13
    layers: [
      new L.TileLayer 'http://{s}.tile.cloudmade.com/266d579a42a943a78166a0a732729463/51080/256/{z}/{x}/{y}.png',
        maxZoom: 18
    ]
    minZoom: 10
    maxZoom: 16

  # Simple i18n "framework".
  I18n =
    en:
      # Translate rink kinds and statuses.
      'sport-dequipe': 'team-sports'
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
      PSE: 'sport-dequipe'
      PPL: 'patin-libre'
      PP: 'paysagee'
      C: 'paysagee'
  t = (string) ->
    I18n[locale] and I18n[locale][string] or string

  # Define models.
  Rink = Backbone.Model.extend
    initialize: (attributes) ->
      # Coerce booleans.
      _.each ['ouvert', 'deblaye', 'arrose', 'resurface'], (key) ->
        unless attributes[key]?
          attrs = {}
          attrs[key] = false
          @set(attrs)
      , @
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
    # TODO move iconName, icon, latlng, marker, popup, addMarker, openPopup to view?
    # @return string the rink's kind, one of "PSE", "PPL" or "PP"
    iconName: ->
      genre = @get 'genre'
      if genre is 'C'
        'PPL'
      else
        genre
    # @return L.Icon the rink's icon
    # @note "new L.Icon.extend({})" raises "TypeError: object is not a function"
    icon: ->
      klass = L.Icon.extend
        iconUrl: "/assets/#{@iconName()}_#{if @get 'ouvert' then 'on' else 'off'}.png"
        shadowUrl: "/assets/#{@iconName()}_shadow.png"
        iconSize: new L.Point 28, 28
        shadowSize: new L.Point 44, 28
        iconAnchor: new L.Point 15, 27
      new klass
    # @return L.LatLng the rink's latitude and longitude
    latlng: ->
      new L.LatLng @get('lat'), @get('lng')
    # @return L.Marker the rink's marker
    marker: ->
      new L.Marker @latlng(), icon: @icon()
    # @return L.Popup the rink's popup
    popup: ->
      new L.Popup
      # TODO make popup appear with favorite, i'm going actions
    # Adds the rink's marker to the map.
    addMarker: ->
      Map.addLayer @marker()
    # Removes a rink's marker from the map.
    removeMarker: ->

    # Open the rink's popup.
    openPopup: ->
      Map.setView @latlng(), 13
      Map.openPopup @popup()

  # Define collections.
  RinkSet = Backbone.Collection.extend
    model: Rink
    localStorage: new Store 'rinks'
    # Sets only matching rinks as visible.
    showIfMatching: (kinds, statuses) ->
      @each (rink) ->
        if (rink.get('genre') in kinds and _.all statuses, (status) -> rink.get status)
          rink.show()
        else
          rink.hide()
      @trigger 'changeAll'
    # Sets only favorite rinks as visible.
    showIfFavorite: ->
      @each (rink) ->
        if rink.get 'favorite'
          rink.show()
        else
          rink.hide()
      @trigger 'changeAll'
    # @return array all visible rinks
    visible: ->
      @filter (rink) ->
        rink.get 'visible'
    # @return array all favorite rinks
    favorites: ->
      @filter (rink) ->
        rink.get 'favorite'

  # @expects a RinkSet collection and a reference to Router#navigate
  MarkersView = Backbone.View.extend
    initialize: (attributes) ->
      @navigate = attributes.navigate
      @collection.bind 'changeAll', @render, @
    render: ->
      @collection.each (model) ->
        if model.get 'visible'
          model.addMarker()
        else
          model.removeMarker()
      @

  # TODO implement popup view
  # TODO @collection.bind 'change:favorite', ->

  # A view for the primary buttons.
  # @expects a RinkSet collection and a reference to Router#navigate
  ControlsView = Backbone.View.extend
    initialize: (attributes) ->
      @navigate = attributes.navigate
    render: ->
      @
    # Toggles a filter.
    # @param string type "kinds" or "statuses"
    # @param string filter a filter, e.g. "PSE" or "deblaye"
    # @private
    toggleFilter: (event, type, filter) ->
      $(@selector event).toggleClass 'active'
      [kinds, statuses] = @fromUrl Backbone.history.getFragment()
      if type is 'kinds' then filters = kinds else filters = statuses
      if filter in filters
        filters = _.without filters, filter
      else
        filters.push filter
      if type is 'kinds' then kinds = filters else statuses = filters
      @navigate @toUrl(kinds, statuses), true
    # Toggles a rink kind filter.
    # @param jQuery.Event an event
    # @param string a rink kind
    # @private
    toggleKind: (event, kind) ->
      @toggleFilter event, 'kinds', kind
    # Toggles a rink status filter.
    # @param jQuery.Event an event
    # @param string a rink status
    # @private
    toggleStatus: (event, status) ->
      @toggleFilter event, 'statuses', status
    # @param jQuery.Event an event
    # @return string the event target's selector
    # @private
    selector: (event) ->
      '#' + event.target.id
    toggleTeamSports: (event) ->
      @toggleKind event, 'PSE'
    toggleFreeSkating: (event) ->
      @toggleKind event, 'PPL'
    toggleLandscaped: (event) ->
      @toggleKind event, 'PP'
    toggleCleared: (event) ->
      @toggleStatus event, 'deblaye'
    toggleFlooded: (event) ->
      @toggleStatus event, 'arrose'
    toggleResurfaced: (event) ->
      @toggleStatus event, 'resurface'
    toggleFavorites: (event) ->
      selector = @selector event
      $(selector).toggleClass 'active'
      if $(selector).hasClass 'active'
        $('input', selector).attr 'checked', 'checked'
        @navigate t('favorites'), true
      else
        $('input', selector).removeAttr 'checked'
        # TODO @navigate (determine the last URL based on UI state), true

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
      'favorites': 'favorites'
      'favories': 'favorites'
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
    # Performs the "favorites" action.
    favorites: ->
      @collection.showIfFavorite()
      # TODO set buttons state
      # TODO render
    # Performs the "filter" action.
    # @param string splat a URL path
    filter: (splat) ->
      [kinds, statuses] = @fromUrl splat
      @collection.showIfMatching kinds, statuses
      # TODO set buttons state
      # TODO render
    # Performs the "show" action.
    # @param string id a rink ID
    show: (id) ->
      # TODO find rink and openPopup() for it
    default: ->
      @navigate @toUrl ['PP', 'PPL', 'PSE'], []

  # Helpers to mix-in to views and routers.
  Helpers =
    # Maps path components to rink kinds.
    kinds:
      'team-sports': ['PSE']
      'sports-dequipe': ['PSE']
      'free-skating': ['PPL']
      'patin-libre': ['PPL']
      'landscaped': ['PP', 'C']
      'paysagee': ['PP', 'C']
    # Maps path components to rink statuses.
    statuses:
      'cleared': 'deblaye'
      'deblaye': 'deblaye'
      'flooded': 'arrose'
      'arrose': 'arrose'
      'resurfaced': 'resurface'
      'resurface': 'resurface'
    # @param string splat a URL path
    # @return array a two-value array where the first value is an array of rink
    #   kinds and the second value is an array of rink statuses
    fromUrl: (splat) ->
      kinds = []
      statuses = []
      for part in splat.split('/')
        if part of @kinds
          kinds = kinds.concat @kinds[part]
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
  _.each [MarkersView, ControlsView, Router], (klass) ->
    _.extend klass.prototype, Helpers

  # Seed collection.
  Rinks = new RinkSet
  Rinks.reset json

  # Instantiate routes.
  Routes = new Router
    collection: Rinks

  # Instantiate views.
  # @note views ought to be able to call Router.navigate
  markers = new MarkersView
    el: '#map'
    collection: Rinks
    navigate: Routes.navigate
  controls = new ControlsView
    el: '#controls'
    collection: Rinks
    navigate: Routes.navigate

  # Backbone doesn't attach the "events" option directly to the view, even
  # though it makes sense given that views needn't necessarily hardcode CSS
  # selectors (and maybe shouldn't).
  # @see https://github.com/documentcloud/backbone/issues/656
  controls.delegateEvents
    'click #PSE': 'toggleTeamSports'
    'click #PPL': 'toggleFreeSkating'
    'click #PP': 'toggleLandscaped'
    'click #deblaye': 'toggleCleared'
    'click #arrose': 'toggleFlooded'
    'click #resurface': 'toggleResurfaced'
    'click #favories': 'toggleFavorites'

  # Route the initial URL.
  Backbone.history.start pushState: true

  window.debug = env is 'development'
