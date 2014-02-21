module = angular.module('kanban.controllers', ['restangular'])

class BoardCtrl
        constructor: (@$scope, @Restangular) ->
                null

module.controller("BoardCtrl", ['$scope', 'Restangular', BoardCtrl])
