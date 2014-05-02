module = angular.module('kanban.controllers', ['restangular', 'ui.router', 'kanban.services'])

class KanbanCardCommentCtrl
        constructor: (@$scope, @KanbanCardComments) ->
                @$scope.newcommentForm =
                        text: ""
                        card: @$scope.card.resource_uri

                @$scope.submitNewComment = this.submitNewComment

        submitNewComment: () =>
                @KanbanCardComments.post(@$scope.newcommentForm).then((comment) =>
                        console.debug("posted comment")
                )


class KanbanBoardCtrl
        constructor: (@$scope, @$stateParams, @KanbanBoards, @KanbanLists, @KanbanTasks, @kanbanService) ->
                @$scope.leftPanel =
                        tab: ""

                @$scope.searchForm =
                        term: ""

                @$scope.columnSortableOptions =
                        placeholder: "task",
                        connectWith: "ul.list",
                        items: "> li"

                @$scope.boards = @KanbanBoards.getList().$object

                # Load board if we specify one
                if @$stateParams.kanbanId > 0
                        @$scope.board = @kanbanService.load(@$stateParams.kanbanId)


class KanbanListCtrl
        constructor: (@$scope, @KanbanCards) ->
                @$scope.newCardForm =
                        list: @$scope.list.resource_uri

                @$scope.newCardSubmit = this.newCardSubmit

        newCardSubmit: () =>
                @KanbanCards.post(@$scope.newCardForm).then((card) =>
                        @$scope.list.cards = _.union(@$scope.list.cards, card)
                        @$scope.showAddTask = false
                )




class KanbanCardCtrl
        constructor: (@$scope, @$stateParams, @KanbanCards) ->
                @$scope.card = @KanbanCards.one(@$stateParams.cardId).get().$object

                console.debug(@$scope.card)
                @$scope.sidebar =
                        tab: 'details'




module.controller("KanbanBoardCtrl", ['$scope', '$stateParams', 'KanbanBoards', 'KanbanLists', 'KanbanTasks', 'kanbanService', KanbanBoardCtrl])
module.controller("KanbanListCtrl", ['$scope', 'KanbanCards', KanbanListCtrl])
module.controller("KanbanCardCommentCtrl", ['$scope', 'KanbanCardComments', KanbanCardCommentCtrl])
module.controller("KanbanCardCtrl", ['$scope', '$stateParams', 'KanbanCards', KanbanCardCtrl])
