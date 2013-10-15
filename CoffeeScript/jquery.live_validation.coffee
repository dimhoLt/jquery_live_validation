###
    jQuery live validation 1.0
    
    Copyright (c) 2013 Helge Söderström
    http://github.com/dimhoLt
    
    Plugin website:
    http://github.com/dimhoLt/jquery_live_validation
    
    Dual licensed under the MIT and GPL licenses.
    http://en.wikipedia.org/wiki/MIT_License
    http://en.wikipedia.org/wiki/GNU_General_Public_License
    
    Compile through:
    $ coffee -bw -o js -c CoffeeScript/jquery.live_validation.coffee
    
    Minify compiled JS through:
    $ uglifyjs js/jquery.live_validation.js -p js/jquery.live_validation.min.js
###

$.fn.extend
    liveValidation: (options) ->

        inputField = $(this)
        
        settings =
            # The inputContainer for the field.
            container: null
            
            # The condition to run to check for success. Allowed value types:
            #   Regex                : Tests the input field to match the regex. This should considered default.
            #   jQuery input field   : For password matching etc, this type matches the two's input.
            #   Function(fieldValue) : Supply a function receiving the field value. Must return a bool.
            validationCondition: null
            
            # The error message. Set to false to disable showing a message.
            errorMessage: "Error here =("
            
            # The success message. Set to false to disable showing a message.
            successMessage: false
            
            # Events for which the plugin listens to and makes changes.
            events: [ 'keyup', 'blur' ]
            
            # States to reset on focus. Set to false for ignore.
            resetStatesOnFocus: [ "error" ]
            
            # Animation speed for toggling the validation message.
            #
            # Unit: ms
            animationSpeed: 100

            # Hides the current message and shows a success message instead.
            showSuccessMessage: (settings) ->
                # Find the live validation box and show it.
                statusContainer = settings.container.find(".fieldStatus")
    
                # Don't show the message if set to false.
                if settings.successMessage is false
                    settings.hideMessage false
                    return
    
                if statusContainer.length is 1
                    statusContainer.text settings.successMessage
    
                    slideDistance = statusContainer.outerHeight() - 2
                    statusContainer
                    .removeClass("error")
                    .addClass("success")
                    .promise()
                    .done ->
                            inputField.animate {
                                'margin-bottom': '-' + slideDistance + 'px'
                            }, settings.animationSpeed, ->
                                inputField.delay(timeout).animate
                                    'margin-bottom': '0px'

            # Hides the current message and shows an error message instead.
            showErrorMessage: (settings) ->
                # Now find the live validation box and show it.
                statusContainer = settings.container.find(".fieldStatus")
    
                # Now, if the message is set to false, don't show one.
                if settings.errorMessage is false
                    settings.hideMessage false
                    return
    
                if statusContainer.length is 1
                    statusContainer.text settings.errorMessage
    
                    slideDistance = statusContainer.outerHeight() - 2
                    statusContainer
                    .removeClass("success")
                    .addClass("error")
                    .animate
                            'margin-bottom': '-' + slideDistance + 'px'
                        , settings.animationSpeed

            # Hides the live validation message for a given container.
            hideMessage: (animate = true) ->
                return if !settings.container? or settings.container.length < 1
    
                statusContainer = settings.container.find(".fieldStatus")
                return if statusContainer.length < 1
    
                if animate
                    statusContainer.animate
                        'margin-bottom': '0px'
                    , settings.animationSpeed
    
                else
                    statusContainer.css
                        'margin-bottom': '0px'

            # Takes an input container and sets it to the success class and shows it's
            # live validation message.
            #
            # If "message" is set to "false", no message will be displayed, only the
            # @container will receive the success-class.
            validationSuccess: (inputField, settings) ->
                return if !settings.container? or settings.container.length < 1
    
                fieldset = settings.container.find("fieldset")
                # Add success class to container...
                fieldset.removeClass("error").addClass("success")
    
                # Now, if the message is set to false, don't show one.
                if settings.successMessage is false
                    settings.hideMessage false
                    return
    
                settings.showSuccessMessage settings

            # Takes an input container and sets it to the error class and shows it's
            # live valdation error message.
            #
            # If "message" is set to "false", no message will be displayed, only the
            # @container will receive the error-class.
            validationFailure: (inputField, settings) ->
                return if !settings.container? or settings.container.length < 1
    
                fieldset = settings.container.find("fieldset")
                # Add error class to container...
                fieldset.removeClass("success").addClass("error")
    
                settings.showErrorMessage settings

            # Resets the states from the validationSuccess() and validationFailure()
            # functions.
            resetState: (inputField, settings) ->
                return if not settings.container? or settings.container.length < 1
                return if settings.resetStatesOnFocus is false
    
                fieldset = settings.container.find "fieldset"
                if "error" in settings.resetStatesOnFocus and fieldset.hasClass("error")
                    fieldset.removeClass "error"
                    settings.hideMessage()
    
                if "success" in settings.resetStatesOnFocus and fieldset.hasClass("success")
                    fieldset.removeClass "success"
                    settings.hideMessage()
            
        settings = jQuery.extend settings, options
        
        # Performs the validation.
        validate = ->
            result = false
            if typeof settings.validationCondition is "object" and settings.validationCondition instanceof RegExp
                result = settings.validationCondition.test inputField.val()
                
            else if typeof settings.validationCondition is "function"
                result = settings.validationCondition inputField.val()
   
            else
                result = settings.validationCondition.val() is inputField.val()
   
            if result is true
                settings["validationSuccess"](inputField, settings)
            else
                settings["validationFailure"](inputField, settings)
                
                
        # Evaluates and runs whether or not the event should be run depending
        # on the key the user pressed.
        evaluateValidate = (keyCode) ->
            # Don't run if we're just pressing shift, cmd, ctrl etc.
            disallowedKeys = [
                9    # Tab
                16   # Shift
                17   # Ctrl / cmd
                18   # Alt
                37   # Left arrow
                38   # Up arrow
                39   # Right arrow
                40   # Down arrow
                91   # Left window key
                92   # Right window key
                93   # Right ctrl / cmd
            ]
            return if keyCode in disallowedKeys
            
            validate()


        # Init and bindings.
        settings.container = inputField.closest(".inputContainer")
        
        # If we send a jQuery selector to match against, fail this validation
        # if the supplied variable changes.
        if typeof settings.validationCondition is "object" and settings.validationCondition instanceof jQuery
            settings.validationCondition.on settings.events.join(" "), (e) =>
                evaluateValidate e.keyCode
        
        # Attach validation event.
        settings.container.on settings.events.join(" "), (e) =>
            evaluateValidate e.keyCode
            
        # If we want to reset error classes on focus, attach event for it.
        if settings.resetStatesOnFocus isnt false
            inputField.on 'focus', ->
                settings.resetState inputField, settings
            