(function(d3){
    d3.oracle = {
        randomData: function (_opts) {
            function bumpLayer(n, o) {
                function bump(a) {
                    var x = 1 / (.1 + Math.random()),
                            y = 2 * Math.random() - .5,
                            z = 10 / (.1 + Math.random());
                    for (var i = 0; i < n; i++) {
                        var w = (i / n - y) * z;
                        a[i] += x * Math.exp(-w * w);
                    }
                }

                var a = [], i;
                for (i = 0; i < n; ++i)
                    a[i] = o + o * Math.random();
                for (i = 0; i < 5; ++i)
                    bump(a);
                return a.map(function (d, i) {
                    return {x: i, y: Math.max(0, d)};
                });
            }

            return d3.range(_opts.series || 1).map(function () {
                return bumpLayer(_opts.points, .1);
            });
        },
        coalesce: function () {
            var result = undefined;
            for (i in arguments) {
                if (typeof arguments[i] !== "undefined") {
                    result = arguments[i];
                    break;
                }
            }
            return result;
        },
        fnf: function () {
            var decimals = 1,
                    bigDecimals = 1,
                    smallDecimals = 3,
                    prefix = '',
                    suffix = '';
            var exports = function (_x) {
                var symbol = '';
                var sign = '';
                var small = false;

                if (_x < 0) {
                    sign = '-';
                    _x = -1 * _x;
                }

                if (_x >= 100) {
                    _x = Math.floor(_x);
                    if (_x >= 1000) {
                        _x = _x / 1000;
                        symbol = 'K';
                        if (_x >= 1000) {
                            _x = _x / 1000;
                            symbol = 'M';
                            if (_x >= 1000) {
                                _x = _x / 1000;
                                symbol = 'G';
                            }
                        }
                    }
                } else if (_x < 1) {
                    small = true;
                }
                var base = Math.pow(10, (symbol ? bigDecimals : (small ? smallDecimals : decimals)));
                return sign + prefix + (Math.floor(_x * base) / base) + symbol + suffix;
            };

            exports.decimals = function (_x) {
                if (_x == undefined) {
                    return decimals;
                }
                decimals = _x;
                return this;
            };
            exports.bigDecimals = function (_x) {
                if (_x == undefined) {
                    return bigDecimals;
                }
                bigDecimals = _x;
                return this;
            };
            exports.smallDecimals = function (_x) {
                if (_x == undefined) {
                    return smallDecimals;
                }
                smallDecimals = _x;
                return this;
            };
            exports.prefix = function (_x) {
                if (_x == undefined) {
                    return prefix;
                }
                prefix = _x;
                return this;
            };
            exports.suffix = function (_x) {
                if (_x == undefined) {
                    return suffix;
                }
                suffix = _x;
                return this;
            };
            return exports;
        }
    }
})(d3);