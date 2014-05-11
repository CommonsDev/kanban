module = angular.module('kanban.directives', ['restangular'])

module.directive('avatarSrc', ($compile) ->
        link = (scope, element, attrs) ->
                if scope.user.mugshot and scope.user.mugshot != ""
                        element.attr('src', scope.user.mugshot)
                else
                        tmpl = "http://sigil.cupcake.io/{{ user.username }}.png"
                        if scope.size
                                tmpl += "?w={{ size }}"

                        element.attr('ng-src', tmpl)


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
                controller: ($scope, KanbanCards) ->
                        $scope.showCardMenu = false
                        $scope.cardMenuState = 'actions'

                        $scope.toggleMenu = ->
                                $scope.showCardMenu = not $scope.showCardMenu
                                $scope.cardMenuState = 'actions'

                        $scope.toMenuState = (state) ->
                                $scope.cardMenuState = state

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
                                        KanbanCards.one($scope.card.id).patch({assignees: new_set}).then(() ->
                                                $scope.card.assignees = _.filter($scope.card.assignees, (item) ->
                                                        return item.resource_uri != user.resource_uri
                                                )
                                        )



        }
)