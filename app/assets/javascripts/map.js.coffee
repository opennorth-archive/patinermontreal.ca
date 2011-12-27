$ ->
  Map = new L.Map 'map',
    center: new L.LatLng(45.53, -73.63)
    zoom: 13

  Map.addLayer new L.TileLayer 'http://{s}.tile.cloudmade.com/802f8920aed1443583f059aedbf2cef6/5870/{z}/{x}/{y}.png',
    maxZoom: 18

  # TODO read leaflet docs, draw map

  # Simple i18n "framework".
  I18n =
    en:
      'sport-dequipe': 'team-sports'
      'patin-libre': 'free-skating'
      'paysagee': 'landscaped'
      'deblaye': 'cleared'
      'arrose': 'flooded'
      'resurface': 'resurfaced'
      PSE: 'team-sports'
      PPL: 'free-skating'
      PP: 'landscaped'
    fr:
      PSE: 'sport-dequipe'
      PPL: 'patin-libre'
      PP: 'paysagee'

  t = (string) ->
    I18n[locale] and I18n[locale][string] or string

  # Define models.
  Rink = Backbone.Model.extend
    defaults:
      favorite: false
    toggle: ->
      @save favorite: not @get 'favorite'

  # Define collections.
  RinkSet = Backbone.Collection.extend
    model: Rink
    localStorage: new Store 'rinks'
    favorites: ->
      @filter (rink) ->
        rink.get 'favorite'

  # Seed collection.
  Rinks = new RinkSet
  Rinks.reset json

  # Define views.
  MarkersView = Backbone.view.extend
    # TODO implement popup view

  ControlsView = Backbone.View.extend
    el: '#controls'
    events:
      'click #team-sports': 'toggleTeamSports'
      'click #free-skating': 'toggleFreeSkating'
      'click #landscaped': 'toggleLandscaped'
      'click #cleared': 'toggleCleared'
      'click #flooded': 'toggleFlooded'
      'click #resurfaced': 'toggleResurfaced'
      'click #favorites': 'toggleFavorites'
    toggleFilter: (type, filter) ->
      [kinds, statuses] = Routes.fromURL Backbone.history.getFragment

      if type == 'kinds' then filters = kinds else filters = statuses
      filters = if filter in filters
        _.without filters, filter
      else
        filters.push filter
      if type == 'kinds' then kinds = filters else statuses = filters

      Routes.navigate Routes.toURL(kinds, statuses), true
    toggleKind: (kind) ->
      toggleFilter 'kinds', kind
    toggleStatus: (status) ->
      toggleFilter 'statuses', status
    render: ->
      # TODO display visible rinks
      @
    toggleTeamSports: ->
      @toggleKind 'PSE'
    toggleFreeSkating: ->
      @toggleKind 'PPL'
    toggleLandscaped: ->
      @toggleKind 'PP'
    toggleCleared: ->
      @toggleStatus 'deblaye'
    toggleFlooded: ->
      @toggleStatus 'arrose'
    toggleResurfaced: ->
      @toggleStatus 'resurface'
    toggleFavorites: ->

  # Instantiate views
  markers = new MarkersView
  controls = new ControlsView

  # Define routes.
  Router = Backbone.Router.extend
    kinds:
      'team-sports': ['PSE']
      'sports-dequipe': ['PSE']
      'free-skating': ['PPL']
      'patin-libre': ['PPL']
      'landscaped': ['PP', 'C']
      'paysagee': ['PP', 'C']
    statuses:
      'cleared': 'deblaye'
      'deblaye': 'deblaye'
      'flooded': 'arrose'
      'arrose': 'arrose'
      'resurfaced': 'resurface'
      'resurface': 'resurface'
    fromURL: (splat) ->
      kinds = []
      statuses = []
      for part in splat.split('/')
        if part of @kinds
          kinds = kinds.concat @kinds[part]
        else if part of @statuses
          statuses.push @statuses[part]
        else
          console.log "Unknown filter: #{part}" if debug
      [kinds, statuses]
    toURL: (kinds, statuses) ->
      _.map(kinds.sort.concat(statuses.sort), (status) -> t status).join '/'
    routes:
      'about': 'about'
      'a-propos': 'about'
      'contact': 'contact'
      'donate': 'donate'
      'dons': 'donate'
      'favorites': 'favorites'
      'favories': 'favorites'
      'f/*filters': 'filter'
      'f/*filters': 'filter'
      'rink/:id': 'show'
      'patinoire/:id': 'show'
    about: ->
      # TODO display about
    contact: ->
      # TODO display contact
    donate: ->
      # TODO display donate
    favorites: ->
      # TODO set visible to Rinks.favorites
    filter: (splat) ->
      [kinds, statuses] = @filters splat
      Rinks.filter (rink) ->
        rink.get('genre') in kinds and _.all statuses, (status) ->
          rink.get status
      # TODO set visible to filtered set
    show: (id) ->
      # TODO make popup appear with favorite, i'm going actions

  # Instantiate routes and route the initial URL.
  Routes = new Router
  Backbone.history.start pushState: true

  # Set to false in production.
  window.debug = true
