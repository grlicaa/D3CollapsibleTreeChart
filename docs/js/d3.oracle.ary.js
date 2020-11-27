(function(d3){
    !d3.oracle && (d3.oracle = {});
    d3.oracle.ary = function() {
        // Custom Plug-in events
        var dispatch = d3.dispatch('itemover', 'itemout', 'itemclick'),
            // The Chart Title
            title = "Chart Title",
            // The color scheme to be used
            colorScale = d3.scale.category10(),
            // Sets the legend width. When 0 or undefined (Default value), the legend takes 100% of its container (Which should be positioned relatively)
            width = undefined,
            // Sets the maximum plugin height. When 0 or undefined (Default value) the legend grows to fit in all the items. If set, the item container (layout) gets a vertical scrollbar.
            maximumHeight = undefined,
            // Defines if the legend columns should adapt to the container size
            responsive = false,
            background = true,
            minimumColumnWidth = 0,
            // If responsive is false, this indicates the number of columns to be displayed.
            numberOfColumns = 3,
            // If responsive is true, depending on the container width legend columns may vary to adapt.
            maximumNumberOfColumns = 5,
            // big-square, square, circle
            symbol = "square",
            hideTitle = false,
            // Whether the color element should be dieplayed on the left side of an item
            leftColor = false,
            showValue = false,
            // If showColor is false this option will be ignored. Otherwise the value will be displayed only when the user hovers the element
            showValueOnHover = false,
            linkOpenMode = "_blank",
            // The borders that should be shown
            borders = {
                top: true,
                right: true,
                bottom: true, 
                left: true
            },

            // Functions for mapping the needed attributes. These can be provided by the user.
            accessors = {
                label: function (d) {
                    return d.label;
                },
                value: function (d) {
                    return d.value;
                },
                color: function (d, i) {
                    return d.color || colorScale(i);
                },
                link: function (d) {
                    return d.link;
                }
            },
            formatters = {
                value: d3.oracle.fnf()
                    .decimals(2)
            },

            // These four properties define the class that will be used for rendering the component
            namespace = "a",
            componentName = "D3ChartLegend",
            baseClassName = (namespace ? namespace + "-" : "") + componentName,
            baseClass = "." + baseClassName;
        
        // Getter/Setter Factory functions
        function _getBasicGetterSetter(targetVariableName){
            // Is this safe? This is a plugin private function so it is not meant to be used externally
            return eval(
                "(function(){ \
                    if(arguments[0] === undefined){ \
                        return " + targetVariableName + "; \
                    } else { \
                        " + targetVariableName + " = arguments[0]; \
                    } \
                    return exports; \
                });"
            );
        }
        function _getObjectGetterSetter(object) {
            return (
                function() {
                    // arguments[0] can be an object property name or an object with multiple values
                    // arguments[1] can be an object property value

                    // No arguments passed: Whole Object Getter
                    if (arguments[1] === undefined && arguments[0] === undefined) {
                        return object;
                    // arguments[0] string and no arguments[1] passed: Getter (Object property getter)
                    } else if (arguments[1] === undefined && (typeof arguments[0] == "string")) {
                        return object[arguments[0]];
                    // arguments[0] is passed an object and arguments[1] is ignored: Setter (Object property setter)
                    } else if (typeof arguments[0] == "object") {
                        if(Object.getOwnPropertyNames(arguments[0]).length > 0){
                            for (var key in arguments[0]) {
                                object[key] = arguments[0][key];
                            }
                        } else {
                            for (var key in object) {
                                delete object[key];
                            }
                        }
                    // Both arguments passed (Types doesn't matter): Setter
                    } else {
                        object[arguments[0]] = arguments[1];
                    }

                    // Chained exports are posible with setters
                    return exports;
                }
            );
        };
        
        
        // Plug-in rendering stuff
        function exports(_selection) {
            function getLegendBorderClasses(){
                var result = null;

                if(Object.getOwnPropertyNames(borders).length > 0) {
                    var bordersBitMask = 0
                        + (!!borders.top << 3)
                        + (!!borders.right << 2)
                        + (!!borders.bottom << 1)
                        + !!borders.left;

                    switch(bordersBitMask){
                        case 15:
                            result = baseClassName + "--external-borders";
                            break;
                        case 8:
                            result = baseClassName + "--top-border-only";
                            break;
                        case 4:
                            result = baseClassName + "--right-border-only";
                            break;
                        case 2:
                            result = baseClassName + "--bottom-border-only";
                            break;
                        case 1:
                            result = baseClassName + "--left-border-only";
                            break;
                        case 0:
                            result = "";
                            break;
                        case 3:
                        case 5:
                        case 6:
                        case 7:
                            result = baseClassName + "--no-top-border";

                            switch(bordersBitMask){
                                case 3:
                                    result += " " + baseClassName + "--no-right-border";
                                    break;
                                case 5:
                                    result += " " + baseClassName + "--no-bottom-border";
                                    break;
                                case 6:
                                    result += " " + baseClassName + "--no-left-border";
                                    break;
                            };

                            break;
                        case 9:
                        case 10:
                        case 11:
                            result = baseClassName + "--no-right-border";

                            switch(bordersBitMask){
                                case 9:
                                    result += " " + baseClassName + "--no-bottom-border";
                                    break;
                                case 10:
                                    result += " " + baseClassName + "--no-left-border";
                                    break;
                            };

                            break;
                        case 12:
                        case 13:
                            result = baseClassName + "--no-bottom-border";

                            switch(bordersBitMask){
                                case 13:
                                    result += " " + baseClassName + "--no-left-border";
                                    break;
                            };

                            break;
                        case 14: 
                            result = baseClassName + "--no-left-border";
                            break;
                    }
                } else {
                    result = baseClassName + "--no-external-borders " + baseClassName + "--no-internal-borders";
                }

                return result;
            }
            
            _selection.each(function(data) {
                var self = d3.select(this);

                var borderClasses = getLegendBorderClasses();
                
                var legendClasses = {};

                legendClasses[baseClassName] = true;
                //legendClasses[baseClassName + "--columns-" + maximumNumberOfColumns] = !!!responsive;
                legendClasses[baseClassName + "--background"] = !!background;
                legendClasses[baseClassName + "--columns-" + Math.min(numberOfColumns, maximumNumberOfColumns)] = true;
                legendClasses[baseClassName + "--" + symbol + "-color"] = true;
                legendClasses[baseClassName + "--hide-title"] = !!hideTitle;
                legendClasses[baseClassName + "--left-color"] = !!leftColor;
                legendClasses[baseClassName + "--show-value"] = !!showValue && !!!showValueOnHover;
                legendClasses[baseClassName + "--show-value-on-hover"] = !!showValue && !!showValueOnHover;
                if(!!borderClasses){
                    legendClasses[borderClasses] = true;
                }
                delete(borderClasses);

                self
                    .attr("class", "")
                    .classed(legendClasses);

                if(width){
                    self.style("width", width);
                }
                if(maximumHeight){
                    self.style({
                        "max-height": maximumHeight,
                        "overflow": "auto"
                    });
                }

                var titleElement = self.select(baseClass + "-title");
                if(titleElement.empty()){
                    titleElement = self
                        .append("div")
                        .classed(baseClassName + "-title", true);
                }
                titleElement.text(title);

                var layoutElement = self.select(baseClass + "-layout");
                if(layoutElement.empty()){
                    layoutElement = self
                        .append("div")
                        .classed(baseClassName + "-layout", true);
                }

                var itemElements = layoutElement
                    .selectAll(baseClass + "-item")
                    .data(data);

                itemElements.enter()
                    .append("div")
                    .classed(baseClassName + "-item", true)
                    .on("mouseover", dispatch.itemover)
                    .on("mouseout", dispatch.itemout)
                    .on("click", function(d){
                        var link;
                        if(!!accessors.link && !!(link = accessors.link.call(this, d))){
                            window.open(link, linkOpenMode);
                        }
                        delete link;
                        
                        dispatch.itemclick.apply(this, arguments);
                    });

                itemElements.exit().remove();

                itemElements
                    .classed(baseClassName + "-item--with-link", function(d){
                        return !!accessors.link && !!accessors.link.call(this, d);
                    });
                    //.style("min-width", Math.max(0, minimumColumnWidth) + "px");

                var colorElements = itemElements.selectAll(baseClass + "-item-color")
                    .data(function(d){ return [ accessors.color.apply(this, arguments) ]; });

                colorElements.enter()
                    .append("div")
                    .classed(baseClassName + "-item-color", true);

                colorElements.exit().remove();

                colorElements.style(
                    "background-color", 
                    function(d) { return d; }
                );

                var valueElements = itemElements.selectAll(baseClass + "-item-value")
                    .data(function(){ return [ formatters.value(accessors.value.apply(this, arguments)) ]; });

                valueElements.enter()
                    .append("div")
                    .classed(baseClassName + "-item-value", true);

                valueElements.exit().remove();

                valueElements
                    .text(
                        function(d) { return d; }
                    )
                    .attr(
                        "title",
                        function(d) { return d; }
                    );

                var labelElements = itemElements.selectAll(baseClass + "-item-label")
                    .data(function(){ return [ accessors.label.apply(this, arguments) ]; });

                labelElements.enter()
                    .append("div")
                    .classed(baseClassName + "-item-label", true)

                labelElements.exit().remove();
                
                labelElements.text(
                    function(d) { return d; }
                );

            });
        }

        exports.title = _getBasicGetterSetter("title");
        exports.colorScale = _getBasicGetterSetter("colorScale");
        exports.width = _getBasicGetterSetter("width");
        exports.maximumHeight = _getBasicGetterSetter("maximumHeight");
        exports.symbol = _getBasicGetterSetter("symbol");
        exports.linkOpenMode = _getBasicGetterSetter("linkOpenMode");
        exports.responsive = _getBasicGetterSetter("responsive");
        exports.background = _getBasicGetterSetter("background");
        exports.minimumColumnWidth = _getBasicGetterSetter("minimumColumnWidth");
        exports.numberOfColumns = _getBasicGetterSetter("numberOfColumns");
        exports.maximumNumberOfColumns = _getBasicGetterSetter("maximumNumberOfColumns");
        /*exports.bigSquareColors = _getBasicGetterSetter("bigSquareColors");
        exports.squareColors = _getBasicGetterSetter("squareColors");
        exports.circleColors = _getBasicGetterSetter("circleColors");*/
        exports.symbol = _getBasicGetterSetter("symbol");
        exports.hideTitle = _getBasicGetterSetter("hideTitle");
        exports.leftColor = _getBasicGetterSetter("leftColor");
        exports.showValue = _getBasicGetterSetter("showValue");
        exports.showValueOnHover = _getBasicGetterSetter("showValueOnHover");

        exports.accessors = _getObjectGetterSetter(accessors);
        exports.formatters = _getObjectGetterSetter(formatters);
        exports.borders = _getObjectGetterSetter(borders);

        d3.rebind(exports, dispatch, "on");

        return exports;
    };
})(d3);