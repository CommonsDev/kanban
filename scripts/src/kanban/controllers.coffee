module = angular.module('kanban.controllers', ['restangular', 'ui.router', 'kanban.services'])

class KanbanCardCommentCtrl
        constructor: (@$scope, @KanbanCardComments) ->
                @$scope.comments = @$scope.card.comments

                @$scope.newcommentForm =
                        text: ""
                        card: @$scope.card.resource_uri

                @$scope.submitNewComment = this.submitNewComment

        submitNewComment: () =>
                @KanbanCardComments.post(@$scope.newcommentForm).then((comment) =>
                        @$scope.comments.push(comment)
                )

class KanbanBoardCtrl
        constructor: (@$scope, @$state, @$stateParams, @KanbanBoards, @KanbanLists, @KanbanTasks, @kanbanService) ->
                @$scope.leftPanel =
                        tab: ""

                @$scope.searchForm =
                        term: ""
                        labels: []
                        users: []

                @$scope.columnSortableOptions =
                        placeholder: "task",
                        connectWith: "ul.list",
                        items: "> li"

                @$scope.boards = @KanbanBoards.getList().$object

                # Load board if we specify one
                if @$stateParams.kanbanId > 0
                        @$scope.board = @kanbanService.load(@$stateParams.kanbanId)

                @$scope.createBoard = this.createBoard
                @$scope.createList = this.createList
                @$scope.updateBoard = this.updateBoard
                @$scope.filterWithLabels = this.filterWithLabels
                @$scope.filterWithUsers = this.filterWithUsers
                @$scope.updateLabelFilter = this.updateLabelFilter
                @$scope.updateUserFilter = this.updateUserFilter


        createBoard: =>
                @KanbanBoards.post({}).then((board) =>
                        @$state.go('kanban', {kanbanId: board.id})
                )

        createList: =>
                @KanbanLists.post({board: @$scope.board.resource_uri}).then((list) =>
                        @$scope.board.lists.push(list)
                )

        updateBoard: =>
                @$scope.board.patch({title: @$scope.board.title, labels: @$scope.board.labels})

        updateUserFilter: ($event, user) =>
                checkbox = $event.target

                if checkbox.checked
                        @$scope.searchForm.users.push(user)
                else
                        idx = @$scope.searchForm.users.indexOf(user)
                        @$scope.searchForm.users.splice(idx, 1)

        updateLabelFilter: ($event, label) =>
                checkbox = $event.target

                if checkbox.checked
                        @$scope.searchForm.labels.push(label)
                else
                        idx = @$scope.searchForm.labels.indexOf(label)
                        @$scope.searchForm.labels.splice(idx, 1)


        filterWithUsers: (actual, expected) =>
                return _.every(@$scope.searchForm.users, (member_uri) =>
                        return _.find(actual.assigned_to, (assignee) =>
                                return assignee.resource_uri == member_uri
                        )
                )

        filterWithLabels: (actual, expected) =>
                return _.every(@$scope.searchForm.labels, (label_uri) =>
                        return _.find(actual.labels, (label) =>
                                return label.resource_uri == label_uri
                        )
                )


class KanbanListCtrl
        constructor: (@$scope, @KanbanLists, @KanbanCards) ->
                @$scope.newCardForm =
                        list: @$scope.list.resource_uri

                @$scope.newCardSubmit = this.newCardSubmit
                @$scope.updateList = this.updateList
                @$scope.deleteList = this.deleteList

        newCardSubmit: () =>
                @KanbanCards.post(@$scope.newCardForm).then((card) =>
                        @$scope.list.cards = _.union(@$scope.list.cards, card)
                        @$scope.showAddTask = false
                )

        updateList: () =>
                @KanbanLists.one(@$scope.list.id).patch({title: @$scope.list.title})

        deleteList: () =>
                console.debug("deleting list...")
                @KanbanLists.one(@$scope.list.id).remove().then(() =>
                        @$scope.board.lists = _.without(@$scope.board.lists, @$scope.list)
                )

class KanbanCardDetailCtrl
        constructor: (@$scope, @$state, @$stateParams, @KanbanCards, @KanbanTasks, @kanbanService) ->
                @$scope.card = @KanbanCards.one(@$stateParams.cardId).get().$object

                @$scope.sidebar =
                        tab: 'details'

                @$scope.newTaskForm =
                        title: ''

                @$scope.deleteCard = this.deleteCard
                @$scope.submitNewTask = this.submitNewTask

        deleteCard: () =>
                @$scope.card.remove().then(=>
                        list = _.find(@kanbanService.board.lists, (list) =>
                                return list.resource_uri == @$scope.card.list
                        )

                        card = _.find(list.cards, (card) =>
                                return card.resource_uri == @$scope.card.resource_uri
                        )

                        idx = list.cards.indexOf(card)
                        list.cards.splice(idx, 1)
                        @$state.go('kanban')
                )

        submitNewTask: =>
                @$scope.newTaskForm.card = @$scope.card.resource_uri
                @KanbanTasks.post(@$scope.newTaskForm).then((task) =>
                        @$scope.card.tasks.push(task)
                )


module.controller("KanbanBoardCtrl", ['$scope', '$state', '$stateParams', 'KanbanBoards', 'KanbanLists', 'KanbanTasks', 'kanbanService', KanbanBoardCtrl])
module.controller("KanbanListCtrl", ['$scope', 'KanbanLists', 'KanbanCards', KanbanListCtrl])
module.controller("KanbanCardCommentCtrl", ['$scope', 'KanbanCardComments', KanbanCardCommentCtrl])
module.controller("KanbanCardDetailCtrl", ['$scope', '$state', '$stateParams', 'KanbanCards', 'KanbanTasks', 'kanbanService', KanbanCardDetailCtrl])
