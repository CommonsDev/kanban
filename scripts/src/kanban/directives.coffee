module = angular.module('kanban.directives', [])

module.directive('kanbanCard', ->
        return {
                scope:
                        card: '=card'
                        board: '=board'
                restrict: 'E',
                templateUrl: 'views/fragments/card_widget.html'
                controller: ($scope) ->
                        $scope.showCardMenu = false
                        $scope.cardMenuState = 'actions'

                        $scope.toggleMenu = ->
                                $scope.showCardMenu = not $scope.showCardMenu

                        $scope.toMenuState = (state) ->
                                $scope.cardMenuState = state

        }
)