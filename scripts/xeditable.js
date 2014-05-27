angular.module('xeditable').factory('editableThemes', function() {
  var themes = {
    //default
    'default': {
      formTpl:      '<form class="editable-wrap"></form>',
      noformTpl:    '<span class="editable-wrap"></span>',
      controlsTpl:  '<span class="editable-controls"></span>',
      inputTpl:     '',
      errorTpl:     '<div class="editable-error" ng-show="$error" ng-bind="$error"></div>',
      buttonsTpl:   '<span class="editable-buttons"></span>',
      submitTpl:    '<button type="submit"><img alt="Save" src="./img/buttons/save.png"></img></button>',
      cancelTpl:    '<button type="button" ng-click="$form.$cancel()"><img alt="Cancel" src="./img/buttons/cancel.png"></img></button>'
    }
   };
  return themes;
});
