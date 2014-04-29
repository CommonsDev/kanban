module = angular.module('kanban.controllers', ['restangular', 'ui.router', 'kanban.services'])

class KanbanBoardCtrl
        constructor: (@$scope, @$stateParams, @kanbanService) ->
                @$scope.board = @kanbanService.load(@$stateParams.kanbanId)


module.controller("KanbanBoardCtrl", ['$scope', '$stateParams', 'kanbanService', KanbanBoardCtrl])
