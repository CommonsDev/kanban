module = angular.module('kanban.controllers', ['restangular', 'ui.router', 'kanban.services'])

class KanbanBoardCtrl
        constructor: (@$scope, @$stateParams, @KanbanBoards, @kanbanService) ->
                @$scope.leftPanel =
                        tab: ""

                @$scope.searchForm =
                        term: ""

                @$scope.boards = @KanbanBoards.getList().$object
                @$scope.board = @kanbanService.load(@$stateParams.kanbanId)

class KanbanCardCtrl
        constructor: (@$scope, @$stateParams, @KanbanCards) ->
                @$scope.card = @KanbanCards.one(@$stateParams.cardId).get().$object
                @$scope.sidebar =
                        tab: 'details'


module.controller("KanbanBoardCtrl", ['$scope', '$stateParams', 'KanbanBoards', 'kanbanService', KanbanBoardCtrl])
module.controller("KanbanCardCtrl", ['$scope', '$stateParams', 'KanbanCards', KanbanCardCtrl])
