class @WishesController extends FastRender.RouteController

  waitOn: -> Meteor.subscribe('wishes')

  after: -> document.title = "Wishes | Reversim Summit 2015"

  tempalte: 'wishes'

  data: ->
    page: 'wishes'