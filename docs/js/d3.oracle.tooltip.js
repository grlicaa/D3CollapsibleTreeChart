(function( d3 ){
    if ( !d3 ) {
        throw 'D3 is required';
    }
    !d3.oracle && (d3.oracle = {});

    function _accessor ( _prop ) {
        return function( d ) {
            return d[_prop];
        };
    };
    // Self Accessor
    function _sa ( d ) {
        return d;
    };

    function _arr ( _value ) {
        if ( _value !== null && _value !== undefined ) {
            return [ _value ];
        } else {
            return [];
        }
    }

    var CSS_CLASS_NAME = 'a-D3Tooltip';
    var CSS_CLASS = '.' + CSS_CLASS_NAME;
    
    d3.oracle.tooltip = function() {
        var accessors = {
                color : _accessor('color'),
                label : _accessor('label'),
                value : _accessor('value'),
                content : _accessor('content')
            },
            formatters = {
                value: d3.oracle.fnf()
                    .decimals(2)
            },
            transitions = {
                enable: d3.functor(true),
                ease: d3.functor("ease-in-out"),
                duration: d3.functor(250)
            },
            symbol = d3.functor('square');

        function exports ( _selection ) {
            _selection.each( function( d ) {
                var self = d3.select( this );

                var heading = self.select( CSS_CLASS + '-heading' );
                if(heading.empty()){
                    heading = self.append( 'div' )
                        .classed( CSS_CLASS_NAME + '-heading', true );
                }

                var color = heading.selectAll( CSS_CLASS + '-marker' )
                    //.data( _arr( accessors.color( d ) ) );
                    .data( [ accessors.color( d ) ] );

                color.exit().remove();
                color.enter()
                    .append( 'div' )
                        .classed(CSS_CLASS_NAME + '-marker', true)
                        .classed(CSS_CLASS_NAME + '-marker--' + symbol(), true);
                color.style({
                    'background-color' : _sa
                });

                var value = heading.selectAll( CSS_CLASS + '-value' ) 
                    .data(_arr(accessors.value( d )));
                value
                    .exit()
                    .remove();
                value.enter()
                    .insert('div', CSS_CLASS + '-label')
                    .classed(CSS_CLASS_NAME + '-value', true);
                
                if(transitions.enable()){
                    value
                        .transition()
                        .duration(transitions.duration)
                        .tween("text", function(d){
                            var interpolator = d3.interpolate(
                                this.$$current || 0,
                                d
                            );

                            this.$$current = d;

                            return function(t){
                                this.textContent = formatters.value(interpolator(t));
                            };
                        });
                }
                
                value
                    .text(function(d){
                        return formatters.value(d);
                    });

                var label = heading.selectAll( CSS_CLASS + '-label' ) 
                    .data( _arr( accessors.label( d ) ) );
                label.exit().remove();
                label.enter()
                        .append( 'div' )
                                .classed( CSS_CLASS_NAME + '-label', true );
                label.text( _sa );
                heading.classed( CSS_CLASS_NAME + '-heading--no-label', label.empty() );

                heading.selectAll( CSS_CLASS + '-marker, ' + CSS_CLASS + '-label, ' + CSS_CLASS + '-value' ).sort( function(){

                });


                var content = self.selectAll( CSS_CLASS + '-content' ) 
                        .data( _arr( accessors.content( d ) ) );
                content.exit().remove();
                content.enter()
                        .append( 'div' )
                                .classed( CSS_CLASS_NAME + '-content', true );
                content.each( function( d ) {
                        if ( typeof d == 'string' ) {
                                d3.select( this ).html( '' ).text( d );
                        } else if ( d !== null && d !== undefined ) {
                                d3.select( this ).html( '' ).append( function() { return d; } );
                        } else {
                                d3.select( this ).remove();
                        }
                });
            });
        };

            function _getObjectSetterGetter ( obj ) {
                return (function ( prop, x ) {
                    if ( x === undefined && prop === undefined) {
                        return obj;
                    } else if ( x === undefined && (typeof prop == 'string') ) {
                        return obj[prop];
                    } else if ( typeof prop == 'object' ) {
                        for ( var k in prop ) {
                            obj[k] = d3.functor( prop[k] );
                        }
                    } else {
                        obj[prop] = d3.functor( x );
                    }
                    return exports;
                });
            };

            exports.accessors = _getObjectSetterGetter( accessors );
            exports.formatters = _getObjectSetterGetter(formatters);
            exports.transitions = _getObjectSetterGetter(transitions);
            exports.symbol = function( _x ) {
                    if ( _x === undefined ) {
                            return symbol;
                    } 
                    symbol = d3.functor( _x );
                    return exports;
            };

            return exports;
    };
})( window.d3 );