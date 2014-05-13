module = angular.module('kanban.directives', ['restangular'])

module.directive('avatarSrc', ($compile) ->
        link = (scope, element, attrs) ->
                if scope.user.mugshot and scope.user.mugshot != ""
                        element.attr('src', scope.user.mugshot)
                else
                        tmpl = "http://sigil.cupcake.io/{{ user.username }}.png"
                        if scope.size
                                tmpl += "?w={{ size }}"

                        # element.attr('src', tmpl)


                $compile(element)(scope)

        return {
                scope:
                        user: "=avatarSrc"
                        size: "=avatarSize"
                restrict: 'A',
                link: link

                }
        )

module.directive('kanbanCard', ->
        return {
                scope:
                        card: '=card'
                        board: '=board'
                restrict: 'E',
                templateUrl: 'views/fragments/card_widget.html'
                controller: ($scope, $controller) ->

                        angular.extend(this, $controller('AbstractKanbanCardCtrl', {$scope: $scope}))

                        $scope.showCardMenu = false
                        $scope.cardMenuState = 'actions'

                        $scope.toggleMenu = ->
                                $scope.showCardMenu = not $scope.showCardMenu
                                $scope.cardMenuState = 'actions'

                        $scope.toMenuState = (state) ->
                                $scope.cardMenuState = state

        }
)