services = angular.module('kanban.services', ['restangular'])

class KanbanService
        constructor: (@$rootScope, @KanbanBoards) ->
                @board = null

        load: (kanban_id) =>
                @board = @KanbanBoards.one(kanban_id).get().$object
                return @board

# Services
services.factory('kanbanService', ($rootScope, KanbanBoards) ->
        return new KanbanService($rootScope, KanbanBoards)
)

services.factory('KanbanBoards', (Restangular) ->
        return Restangular.service('flipflop/board')
)

services.factory('KanbanLists', (Restangular) ->
        return Restangular.service('flipflop/list')
)

services.factory('KanbanTasks', (Restangular) ->
        return Restangular.service('flipflop/task')
)

services.factory('KanbanCards', (Restangular) ->
        return Restangular.service('flipflop/card')
)

services.factory('KanbanCardComments', (Restangular) ->
        return Restangular.service('flipflop/cardcomment')
)
