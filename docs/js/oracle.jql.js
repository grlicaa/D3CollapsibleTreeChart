
(function(oracle){
    function _eval(_exp, _row) {
        switch (typeof _exp) {
            case 'string':
                return _row[_exp];
            case 'function':
                return _exp(_row);
            default:
                return _exp;
        }
    };

    (!oracle) && (window.oracle = oracle = {});

    oracle.jql = function() {
        var select,
            from,
            where,
            group_by,
            page,
            page_size,
            order_by;

        var exports = function() {
            var result = [];
            var iFrom = (typeof from === 'function') ? from.apply(this, arguments) : from;
            if (group_by) {
                var groups = {};
                var groupsArray = [];
                var rowGroups, path, groupValue;
                for (var i = 0; i < iFrom.length; i++) {
                    if (!where || where(iFrom[i])) {
                        rowGroups = [];
                        for (var j = 0; j < group_by.length; j++) {
                            groupValue = _eval(((typeof group_by[j] == 'string') ? group_by[j] : group_by[j][0]), iFrom[i]);
                            rowGroups.push((typeof groupValue) + ':' + groupValue);
                        };
                        path = groups;
                        for (var j = 0; j < rowGroups.length; j++) {
                            if (!path[rowGroups[j]]) {
                                path = path[rowGroups[j]] = (j < rowGroups.length-1 ? {} : _pushNPeek(groupsArray, []));
                            } else {
                                path = path[rowGroups[j]];
                            }
                        };
                        path.push(iFrom[i]);
                    }
                };
                for (var i = 0; i < groupsArray.length; i++) {
                    var row = {};
                    for (var j = 0; j < select.length; j++) {
                        row[select[j][1]] = _eval(select[j][0], groupsArray[i]);
                    };
                    for (var j = 0; j < group_by.length; j++) {
                        switch (typeof group_by[j]) {
                            case 'object':
                                row[group_by[j][1] || group_by[j][0]] = _eval(group_by[j][0], groupsArray[i][0]);
                                break;
                            case 'string':
                                row[group_by[j]] = _eval(group_by[j], groupsArray[i][0]);
                                break;
                        }
                    };
                    result.push(row);
                };
                return result;
            } else {
                var row;
                for (var i = 0; i < iFrom.length; i++) {
                    if (!where || where(iFrom[i])) {
                        row = {};
                        for (var j = 0; j < select.length; j++) {
                            switch (typeof select[j]) {
                                case 'object':
                                    row[select[j][1] || select[j][0]] = _eval(select[j][0], iFrom[i]);
                                    break;
                                case 'string':
                                    row[select[j]] = _eval(select[j], iFrom[i]);
                                    break;
                            }
                        };
                        result.push(row);
                    }
                };
            }

            if ( order_by ) {
                result.sort( _doSort );
            }

            if ( typeof page === 'number' && typeof page_size === 'number' ) {
                result = result.slice( page * page_size, ( page + 1 ) * page_size );
            }

            return result;
        };

        // An array of arrays
        // [['a', 'b']] would take the 'a' property of each object and rename it 'b' in the result
        // [[function(_r){ return _r.a + 1; }, 'a+']] would add 1 to the value of 'a' and return it as 'a+' in the result.
        //
        exports.select = function() {
            if (arguments.length == 0) {
                return select;
            }
            select = [];
            for (var i = 0; i < arguments.length; i++) {
                select.push(arguments[i]);
            };
            return exports;
        };

        // An array of objects
        exports.from = function(_x) {
            if (_x == undefined) {
                return from;
            }
            from = _x;
            return exports;
        };

        exports.where = function(_x) {
            if (_x == undefined) {
                return where;
            }
            where = _x;
            return exports;
        };

        exports.group_by = function(_x) {
            if (arguments.length == 0) {
                return group_by;
            }
            group_by = [];
            for (var i = 0; i < arguments.length; i++) {
                group_by.push(arguments[i]);
            };
            return exports;
        };

        exports.page = function(_x) {
            if (_x == undefined) {
                return page;
            }
            page = _x;
            return exports;
        };
        exports.page_size = function(_x) {
            if (_x == undefined) {
                return page_size;
            }
            page_size = _x;
            return exports;
        };
        exports.order_by = function(_x) {
            if (arguments.length == 0) {
                return order_by;
            }
            if ( _x === false ) {
                order_by = null;
                return exports;
            }
            order_by = [];
            for (var i = 0; i < arguments.length; i++) {
                order_by.push(arguments[i]);
            };
            return exports;
        };

        function _doSort( _r1, _r2 ) {
            var r1v,
                r2v,
                res,
                acc,
                inv;
            for ( var i = 0; i < order_by.length; i++ ) {
                acc = order_by[ i ][ 0 ];
                inv = order_by[ i ][ 1 ].toLowerCase() !== 'asc';
                switch ( typeof acc ) {
                    case 'function' :
                        r1v = acc.call( _r1, _r1 );
                        r2v = acc.call( _r2, _r2 );
                        break;
                    default :
                        r1v = _r1[ acc ];
                        r2v = _r2[ acc ];
                        break;
                }
                if ( r1v === r2v ) {
                    continue;
                } else if ( r1v < r2v ) {
                    res = -1;
                } else {
                    res = 1;
                }
                return inv ? -res : res;
            }
        }

        function _pushNPeek(_arr, _x) {
            _arr.push(_x);
            return _x;
        }

        exports.get = function() {
            return exports.apply(this, arguments);
        };

        return exports;
    };

    function _joinRows(r1, a1, r2, a2) {
        var r = {};
        for ( var k1 in r1 ) {
            r[ ( a1 ? ( a1 + '.' ) : '' ) + k1 ] = r1[ k1 ];
        }
        for ( var k2 in r2 ) {
            r[ ( a2 ? ( a2 + '.' ) : '' ) + k2 ] = r2[ k2 ];
        }
        return r;
    }
    oracle.jql.join = function(_t1, _t2, _on, _type) {
        if (_type === 'right') {
            return oracle.jql.join( _t2, _t1, _on, 'left' );
        }
        var isLeftJoin = (_type === 'left');
        var t1 = (typeof _t1[1] === 'string') ? _t1[0] : _t1;
        var t1Alias = (typeof _t1[1] === 'string') ? _t1[1] : false;
        var t2 = (typeof _t2[1] === 'string') ? _t2[0] : _t2;
        var t2Alias = (typeof _t2[1] === 'string') ? _t2[1] : false;

        var exports = function() {
            var result = [];
            var t1i = (typeof t1 === 'function') ? t1.apply(this, arguments) : t1;
            var t2i = (typeof t2 === 'function') ? t2.apply(this, arguments) : t2;
            var rowJoined;
            for (var i = 0; i < t1i.length; i++) {
                rowJoined = false;
                for (var j = 0; j < t2i.length; j++) {
                    if ( !_on || _on( t1i[i], t2i[j] ) ) {
                        rowJoined = true;
                        result.push( _joinRows( t1i[i], t1Alias, t2i[j], t2Alias ) );
                    }
                };
                if (!rowJoined && isLeftJoin) {
                    result.push( _joinRows( t1i[i], t1Alias, null, false ) );
                }
            };
            return result;
        };
        return exports;
    };

    oracle.jql.left_join = function(_t1, _t2, _on) {
        return oracle.jql.join( _t1, _t2, _on, 'left' );
    };
    oracle.jql.right_join = function(_t1, _t2, _on) {
        return oracle.jql.join( _t2, _t1, _on, 'left' );
    };

    oracle.jql.max = function(_accessor) {
        var f = function(_rows) {
            var r = null;
            var ri = null;
            for (var i = _rows.length - 1; i >= 0; i--) {
                ri = _eval(_accessor, _rows[i]);
                if (r == null || ri > r) {
                    r = ri;
                }
            };
            return r;
        };
        return f;
    };
    oracle.jql.min = function(_accessor) {
        var f = function(_rows) {
            var r = null;
            var ri = null;
            for (var i = _rows.length - 1; i >= 0; i--) {
                ri = _eval(_accessor, _rows[i]);
                if (r == null || ri < r) {
                    r = ri;
                }
            };
            return r;
        };
        return f;
    };
    oracle.jql.sum = function(_accessor) {
        var f = function(_rows) {
            var r = 0,
                ri;
            for (var i = _rows.length - 1; i >= 0; i--) {
                ri = _eval(_accessor, _rows[i]);
                if (typeof ri == 'number') {
                    r += ri;
                }
            };
            return r;
        };
        return f;
    };
    oracle.jql.avg = function(_accessor) {
        var f = function(_rows) {
            var r = 0,
                ri,
                s = 0;
            for (var i = _rows.length - 1; i >= 0; i--) {
                ri = _eval(_accessor, _rows[i]);
                if (typeof ri == 'number') {
                    r += ri;
                    s++;
                }
            };
            return (s == 0) ? null : (r / s);
        };
        return f;
    };
    oracle.jql.count = function() {
        var f = function(_rows) {
            return _rows.length
        };
        return f;
    };
})(window.oracle);