class @Wish

  @makeWish: (options) ->
    if not Meteor.userId()
      throw new Meteor.Error 401, "Please log in"
    _.extend(options, owner: Meteor.userId(), createdAt: new Date(), votes: {}, comments: [])
    Wishes.insert(options)

  @delete: (wishData) ->
    Wishes.update(wishData._id, $set: deleted: true)

  @count: ->
    Wishes.find($or: [{deleted: $exists: false}, {deleted: false}]).count()

  constructor: (@data) ->

  comments: ->
    @data.comments

  addComment: (content) ->
    comment = {commenter: Meteor.userId(), content: content}
    Wishes.update(@data._id, $push: comments: comment)

@Wishes = new Meteor.Collection "wishes"

Wishes.allow
  insert: (userId, doc) ->
    # the user must be logged in, and the document must be owned by the user
    userId and doc.owner == userId

  update: (userId, doc, fields, modifier) ->
    # can only change your own documents
    if doc.owner == userId then return true


    # Allow voting
    if (userId and
        fields.length == 1 and
        fields[0] == 'votes' and
        modifier.$set and
        modifier.$set.hasOwnProperty("votes.#{userId}"))
      return true

    # Allowed to add comments
    if (userId and
        fields.length == 1 and
        fields[0] == 'comments' and
        modifier.$push and
        modifier.$push.comments.commenter == userId)
      return true

  remove: (userId, doc) ->
    # can only remove your own documents
    doc.owner == userId

  fetch: ['owner']

Wishes.deny
  update: (userId, doc, fields, modifier) ->
    # owner can't vote for himself
    doc.owner == userId and 'votes' in fields

  fetch: ['owner']
