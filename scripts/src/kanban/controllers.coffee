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
        constructor: (@$scope, @$state, @$stateParams, @KanbanBoards, @KanbanCards, @KanbanLists, @KanbanTasks, @kanbanService) ->
                @$scope.leftPanel =
                        tab: ""

                @$scope.searchForm =
                        term: ""
                        labels: []
                        users: []

                @$scope.dragfrom = null


                @$scope.columnSortableOptions =
                        placeholder: "placeholder",
                        connectWith: ".card-list",
                        items: "li"
                        update: (e, ui) => # This should be moved
                                if ui.sender
                                        card = ui.item.sortable.moved
                                        card.list = ui.item.sortable.droptarget.scope().list.resource_uri
                                        @KanbanCards.one(card.id).patch({list: card.list})

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


module.controller('AbstractKanbanCardCtrl', ($scope, $state, KanbanCards, KanbanTasks, kanbanService) ->
        $scope.showAddTask = false

        $scope.deleteCard = ->
                $scope.card.remove().then(=>
                        list = _.find(kanbanService.board.lists, (list) =>
                                return list.resource_uri == $scope.card.list
                        )

                        card = _.find(list.cards, (card) =>
                                return card.resource_uri == $scope.card.resource_uri
                        )

                        idx = list.cards.indexOf(card)
                        list.cards.splice(idx, 1)
                        $state.go('kanban')
                )

        # Tasks
        $scope.markTaskDone = (task, state) ->
                KanbanTasks.one(task.id).patch({done: state}).then(=>
                        task.done = state
                        if state is true
                                $scope.card.tasks_done_count += 1
                        else
                                $scope.card.tasks_done_count -= 1
                )

        $scope.submitNewTask = ->
                $scope.newTaskForm.card = $scope.card.resource_uri
                KanbanTasks.post($scope.newTaskForm).then((task) =>
                        $scope.card.tasks.push(task)
                        $scope.showAddTask = false
                )

        $scope.deleteTask = (task) ->
                KanbanTasks.one(task.id).remove().then(=>
                        $scope.card.tasks = _.without($scope.card.tasks, task)
                        if task.done
                                $scope.card.tasks_done_count -= 1
                )

        # Labels
        $scope.isLabelAssigned = (label) ->
                return _.find($scope.card.labels, (item) ->
                        return item.resource_uri == label.resource_uri
                ) != undefined

        $scope.assignLabel = ($event, label) ->
                checkbox = $event.target

                new_set = _.pluck($scope.card.labels, 'resource_uri')

                if checkbox.checked
                        if _.contains(new_set, label.resource_uri)
                                return true

                        new_set.push(label.resource_uri)
                        KanbanCards.one($scope.card.id).patch({labels: new_set}).then((card) ->
                                $scope.card.labels.push(label)
                        )
                else
                        new_set = _.without(new_set, label.resource_uri)
                        KanbanCards.one($scope.card.id).patch({labels: new_set}).then(() ->
                                $scope.card.labels = _.filter($scope.card.labels, (item) ->
                                        return item.resource_uri != label.resource_uri
                                )
                        )

        # Members
        $scope.isMemberAssigned = (user) ->
                return _.find($scope.card.assignees, (item) ->
                        return item.resource_uri == user.resource_uri
                ) != undefined


        $scope.assignMember = ($event, user) ->
                checkbox = $event.target

                new_set = _.pluck($scope.card.assignees, 'resource_uri')

                if checkbox.checked
                        if _.contains(new_set, user.resource_uri)
                                return true

                        new_set.push(user.resource_uri)
                        KanbanCards.one($scope.card.id).patch({assignees: new_set}).then((card) ->
                                $scope.card.assignees.push(user)
                        )
                else
                        new_set = _.without(new_set, user.resource_uri)
                        KanbanCards.one($scope.card.id).patch({assignees: new_set}).then( ->
                                $scope.card.assignees = _.filter($scope.card.assignees, (item) ->
                                        return item.resource_uri != user.resource_uri
                                )
                        )

)

module.controller('KanbanCardDetailCtrl', ($scope, $controller, $stateParams, KanbanCards) ->

        angular.extend(this, $controller('AbstractKanbanCardCtrl', {$scope: $scope}))



        $scope.card = KanbanCards.one($stateParams.cardId).get().then((card) ->
                $scope.card = card
                console.debug($scope.board)
                $scope.card_list = _.findWhere($scope.board.lists, {resource_uri: card.list})
                console.debug($scope.list_name)
        )

        $scope.sidebar =
                tab: 'details'

        $scope.newTaskForm =
                title: ''
)


module.controller("KanbanBoardCtrl", ['$scope', '$state', '$stateParams', 'KanbanBoards', 'KanbanCards', 'KanbanLists', 'KanbanTasks', 'kanbanService', KanbanBoardCtrl])
module.controller("KanbanListCtrl", ['$scope', 'KanbanLists', 'KanbanCards', KanbanListCtrl])
module.controller("KanbanCardCommentCtrl", ['$scope', 'KanbanCardComments', KanbanCardCommentCtrl])
