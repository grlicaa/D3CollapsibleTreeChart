(function( util, server, $, d3 ) {

com_oracle_apex_d3_tree_start = function(
  pRegionId, 
  pAjaxId,
  pNoDataFoundMsg,
  pColors,
  pColorLegendMapping,
  pLinkDistance,
  pInitiallyCollapsed,
  pConfig,
  pAutoRefresh,
  pRefreshInterval,
  pNodeClass,
  pNodeHighlightClass,
  pEscapeHtml,
  pPageItemsSubmit,
  pMinHeight,
  pMaxHeight,
  pMinAR,
  pMaxAR,
  pShowTooltip,
  pShowLegend,
  pLegendPosition
){
  var autoRefreshInterval;
  var color;
  var radius_factor;
  var value_min;

  var apex_data_json;
  var gLegend$ = false;
  var gTooltip$ = false;
  var gHasHookedEvents = false;
  var gHoveredNode = false;
  var gFocusedNode = false;
  var gFocusedChildIdx = 0;
  var gFocusedDataNode = false;
  var isFocused = false;
  var gResizeHandlerBound = false;

  var gRegion$; // holds the region
  var gChart$   // holds the chart
  var gAry;
  var gClassScale = d3.scale.ordinal().range( d3.range( 1, 16 ) );

  var gIdPrefix = "d3_treechart_";
  var gPluginIdPrefix = "com_oracle_apex_d3_";
  var gTreeMultiParents = [];

  if ( pColors ) {
      var colorScale = d3.scale.ordinal()
          .range( pColors.split( ':' ) );
  }
  var colorAccessor = function(d) { 
    if (pColors == 'DEFAULT') {
      return null;
    } else if (pColors == 'COLUMN') {
      return (d?d.COLORVALUE:null); 
    } else {
      return colorScale ? colorScale(d.COLORVALUE) : null; 
    }
  };

  // build Legend <-> Color mapping
  var gLegendMapping = false;
  if (pColors == 'COLUMN') {
    try {
      gLegendMapping = JSON.parse(pColorLegendMapping);
    } catch (e) {console.log(e)}
  }

  function getLegendForColor(c) {
    if (pColors == 'COLUMN' && gLegendMapping) {
      if (gLegendMapping[c.toLowerCase()]) {
        return gLegendMapping[c.toLowerCase()];
      } else {
        return c;
      }
    } else {
      return c;
    }
  }

  var classficationsAccessor = function(d) { return d.COLORVALUE; };

  var dConfig = "";
  var config = {
    "trdur":                       500,
    "css_class_node":              "com_oracle_apex_d3_tree_node",
    "css_class_leafnode":          "com_oracle_apex_d3_tree_leafnode",
    "css_class_link":              "com_oracle_apex_d3_tree_link",
    "circle_radius_min":           10,
    "circle_radius_max":           10,
    "legend_column_width":         200,
    "root_label":                  "Tree root",
    "show_coll_child_cnt":         true,
    "show_coll_child_template":    " (#CNT#)",
    "offset_scrollbars":           20, 
    "margin":                      {"top": 20, "right": 120, "bottom": 20, "left": 120}
  }

  try {
    dConfig = JSON.parse(pConfig);
  } catch (e) {
    dConfig = {};
  }

  for (var attrname in dConfig) { config[attrname] = dConfig[attrname]; }

  function fireApexEvent(e, d) {
    apex.event.trigger(
      $x(pRegionId),
      gPluginIdPrefix + e, 
      d
    );
  }

 function textEllipsis(object, d) {
   if (d.LABEL) {
      var self = d3.select(object);
          self.text(d.LABEL);
      var textLength = self.node().getComputedTextLength(),
          text = self.text();
      while (textLength > ((d.r * 2) - 2 * 6) && text.length > 0) {
          text = text.slice(0, -1);
          self.text(text);
          textLength = self.node().getComputedTextLength();
      }
      if( text.length < d.LABEL.length )
        return text + '...';
      else
        return text;
    } else {
      return "";
    }
  } 

  function getCircleRadius(nodeValue) {
    if (nodeValue && !isNaN(parseFloat(nodeValue))) {
      return Math.round(config.circle_radius_min + (parseFloat(nodeValue) - value_min) * radius_factor);
    } else {
      return config.circle_radius_min;
    }
  }

  function getLabel(d) {
    var lLabel = d.LABEL;
    if (config.show_coll_child_cnt) {
      if (d._children && d._children.length > 0) {
        lLabel = lLabel + config.show_coll_child_template.replace(/#CNT#/, d._children.length);
      }
    }
    return lLabel;
  }

  function getTooltipContent(d) {
    if (d.INFOSTRING) {
      if (pEscapeHtml == 'Y')  {
        return d3.select(document.createElement("div")).text(d.INFOSTRING).node();
      } else {
        return d3.select(document.createElement("div")).html(d.INFOSTRING).node();
      }
    } else {
      return "";
    }
  }

  function buildHierarchy(pData) {
    var lookup    = [];
    var lookup2   = [];
    var rootnodes = [];

    var sizemin  = false;
    var sizemax  = false;
    var hasLabel = false;
	
	
    // build lookup array
    for (var i=0;i<pData.row.length; i++) {
      lookup["LO"+pData.row[i].ID] = i;
      if (pData.row[i].LABEL) {hasLabel = true;}
      if (pData.row[i].SIZEVALUE) {
        if (!sizemin || parseFloat(pData.row[i].SIZEVALUE) < sizemin) {
          sizemin = parseFloat(pData.row[i].SIZEVALUE);
        }
        if (!sizemax || parseFloat(pData.row[i].SIZEVALUE) > sizemax) {
          sizemax = parseFloat(pData.row[i].SIZEVALUE);
        }
      }
    }
    radius_factor = (config.circle_radius_max - config.circle_radius_min) / ((sizemax - sizemin==0?1:sizemax-sizemin));
    value_min = sizemin;

    var newRoot = {
      "PARENT_ID":  "parent_" + gPluginIdPrefix + "tree_node_id0123456789",
      "ID":         gPluginIdPrefix + "tree_node_id0123456789",
      "SIZEVALUE":  false,
      "COLORVALUE": "",
      "DEPTH":      0,
      "LABEL":      hasLabel?config.root_label:""
    };

    // detect root nodes
    for (var i=0;i<pData.row.length; i++) {
	  if (checkIfParentIsArray( pData.row[i].PARENT_ID )) {
		  var l_in=false;
		  for(var j=0; j<pData.row[i].PARENT_ID.length; j++) {
			  if (!("LO"+pData.row[i].PARENT_ID[j] in lookup) || (pData.row[i].ID == pData.row[i].PARENT_ID[j]))
				  l_in = true;
		  }
		  if (l_in) 
			rootnodes.push(pData.row[i]);
	  }
	  else {
		  if (!("LO"+pData.row[i].PARENT_ID in lookup) || (pData.row[i].ID == pData.row[i].PARENT_ID)) {
			rootnodes.push(pData.row[i]);
		  }
	  }
    }
	
	function checkIfParentIsArray(item) {
		return Object.prototype.toString.call( item ) === '[object Array]';
	}

    // insert artifical root
    pData.row.push(newRoot);
    lookup["LO" + gPluginIdPrefix + "tree_node_id0123456789"] = pData.row.length - 1;

    for (var r=0;r<rootnodes.length;r++) {
		rootnodes[r].PARENT_ID =  gPluginIdPrefix +"tree_node_id0123456789";
    }
	

    for (var i=0;i<pData.row.length; i++) {
	  if (checkIfParentIsArray( pData.row[i].PARENT_ID )) {
		  for(var j=0; j<pData.row[i].PARENT_ID.length; j++) {
			  if (!("LO"+pData.row[i].PARENT_ID[j] in lookup2)) { 
				lookup2["LO"+pData.row[i].PARENT_ID[j]] = [];
			  }
			  lookup2["LO"+pData.row[i].PARENT_ID[j]].push(pData.row[i].ID); 	  
		  }		  
	  }
	  else {
		  if (!("LO"+pData.row[i].PARENT_ID in lookup2)) { 
			lookup2["LO"+pData.row[i].PARENT_ID] = [];
		  }
		  lookup2["LO"+pData.row[i].PARENT_ID].push(pData.row[i].ID); 
	  }
    }

    function buildHierarchy_core(pData, pRootParentId, pDepth) {
      var target = [];
      var lrow, ix;
      if ("LO"+pRootParentId in lookup2) {
        for (var i=0;i<lookup2["LO"+pRootParentId].length; i++) {
          lrow = {};
          ix = lookup["LO"+lookup2["LO"+pRootParentId][i]];

          lrow.ID         = pData.row[ix].ID;
		  lrow.CHILD_PARENT= pData.row[ix].ID+"_"+pRootParentId;
          lrow.SIZEVALUE  = pData.row[ix].SIZEVALUE;
          lrow.DEPTH      = pDepth,
          lrow.COLORVALUE = pData.row[ix].COLORVALUE;
          lrow.LABEL      = pData.row[ix].LABEL;
          lrow.INFOSTRING = pData.row[ix].INFOSTRING;
          lrow.LINK       = pData.row[ix].LINK;
          lrow.ROWNUM     = ix;
          lrow.children = buildHierarchy_core(pData, pData.row[ix].ID, pDepth + 1);     
          if (lrow.children.length == 0) {
            lrow.children = false;
          }
          target.push(lrow);
        }
      }
      return target;
    }
    return buildHierarchy_core(pData, "parent_" + gPluginIdPrefix + "tree_node_id0123456789", 0);
  }


  function _recommendedHeight() {
    var minAR = pMinAR;
    var maxAR = pMaxAR;
    var w = gChart$.width();
    var h = (gChart$.height() === 0) ? (w/maxAR) : gChart$.height();
    var ar = w/h;
    if (ar < minAR) {
        h = w/maxAR + 1;
    } else if (ar > maxAR) {
        h = w/minAR - 1;
    }
    return Math.max(pMinHeight, Math.min(pMaxHeight, h));
  }

  Region$ = $("#" + pRegionId);
  gChart$ = $("#" + gIdPrefix + pRegionId); 

  if (d3.selectAll("#" + gIdPrefix + pRegionId).size() != 1) {
    console.log("WARNING:");
    console.log("********");
    console.log("DIV ID " + gIdPrefix + pRegionId + " occurs " + d3.selectAll("#" + gIdPrefix + pRegionId).size() + " times!");
    console.log("Chart may not display correctly");
    console.log("Check STATIC ID values of your chart regions");
  }

  var diagonal = d3.svg.diagonal().projection(function(d) { return [d.y, d.x]; });
  
  var width = gChart$.width() - config.margin.left - config.margin.right;
  var height = _recommendedHeight() - config.margin.top - config.margin.bottom;
  var maxWidth = 0;


  var pack = d3.layout.tree()
    .size([ height, width])  
    .sort(function (a,b) {return b.ROWNUM - a.ROWNUM;})   
    .value(function(d) { return d.SIZEVALUE; })
  ;

  var svg = d3.selectAll(gChart$).append("svg")
    .attr("width", width + config.margin.left + config.margin.right - config.offset_scrollbars)
    .attr("height", height + config.margin.top + config.margin.bottom - config.offset_scrollbars)
  ;
  var svgg = svg.append("g")
    .attr("transform", "translate(" + config.margin.left + "," + config.margin.top + ")")
  ;

  function _resizeFunction() {
    width = gChart$.width() - config.margin.left - config.margin.right;
    height = _recommendedHeight() - config.margin.top - config.margin.bottom;
    pack.size([ height, width]);

    svg.attr("height", height + config.margin.top + config.margin.bottom - config.offset_scrollbars)
    svg.attr("width", width + config.margin.left + config.margin.right - config.offset_scrollbars)
    updateChart(apex_data_json);
	

  }

  // this function is being called upon data refresh and
  // it maintains the "collapsed/uncollapsed" state of each node.

  function copyCollapsedState(s, d, defaultCollapsed) {
    d._hidden  = [];
    d._visible = [];

    if (d.ID == gFocusedDataNode.ID) {gFocusedDataNode = d; gFocusedDataNode.stale = false; } 

    for (var cdx=0; cdx < d.children.length; cdx++) {
      var currentDChild = d.children[cdx];
      var currentSChild = false;
      if (s) {  
        if (s._children) {
          for (var csx=0; csx < s._children.length; csx++) {
            if (s._children[csx].ID == currentDChild.ID) {
              d._hidden.push(currentDChild);
              currentSChild = s._children[csx];
              break;
            }  
          }
        }  
        if (s.children) {
          for (var csx=0; csx < s.children.length; csx++) {
            if (s.children[csx].ID == currentDChild.ID) {
              d._visible.push(currentDChild);
              currentSChild = s.children[csx];
              break;
            } 
          }  
        }  
      }
      if (currentSChild) {
        copyCollapsedState(currentSChild, currentDChild, defaultCollapsed);
      } else {
        if (defaultCollapsed) {
          if (d._visible.length == 0) {
            d._hidden.push(currentDChild);
          } else {
            d._visible.push(currentDChild);
          }
        } else {
          if (d._visible.length == 0 && d._hidden.length > 0) {
            d._hidden.push(currentDChild);
          } else {
            d._visible.push(currentDChild);
          }
        }
        copyCollapsedState(false, currentDChild, defaultCollapsed);
      }
    }
    if (d._hidden.length > 0 || d._visible.length > 0) {
      d._children = d._hidden;
      d.children = d._visible;
    } else {
      d._children = false;
      d.children = false;
    }
  }

  function collapseAll(d) {
    if (d.children) {
      if (!d._children) {
        d._children = d.children;
      } else {
        d._children.push.apply(d._children, d.children);
      }
      d.children = false;
    }
    if (d._children) {
      d._children.forEach(collapseAll);
    }
  }

  function expandAll(d) {
    if (d._children) {
      if (!d.children) {
        d.children = d._children;
      } else {
        d.children.push.apply(d.children, d._children);
      }
      d._children = false;
    }
    if (d.children) {
      d.children.forEach(expandAll);
    }
  }

  function getData(fContinueThere) {
    apex.event.trigger(
      $x(pRegionId),
      "apexbeforerefresh" 
    );

    apex.server.plugin(
      pAjaxId,
      {
        p_debug: $v('pdebug'),
        pageItems: pPageItemsSubmit.split(",")
      },   
      {
        success: fContinueThere,
        error: function (d) {console.log(d.responseText); },
        dataType: "json"
      }
    );
  }

  function refreshData(d3json, pCollapse, pRefresh) {
    if (!gLegend$) { 
      gLegend$ = $( document.createElement( 'div' ) );

      if ( pLegendPosition == 'TOP' ) {
          gChart$.before( gLegend$ );
      } else {
          gChart$.after( gLegend$ );
      }
    }

    if (!gTooltip$) { 
          gTooltip$ = $( document.createElement( 'div' ) )
              .addClass( 'a-D3TreeChart-tooltip a-D3Tooltip' )
              .appendTo( gChart$ )
              .hide();
    }

    if (d3json.row.length == 0) {
      apex_data_json = {};
      d3.selectAll("g").remove();
      svgg = svg.append("g")
       .attr("transform", "translate(" + config.margin.left + "," + config.margin.top + ")")
      ;
      svg.append("g")
        .attr("id", gIdPrefix + pRegionId + "_nodatafoundmsg")
        .attr("transform", "translate(10,20)")
        .append("text")
        .text(pNoDataFoundMsg);
      return;
    } else {
      d3.selectAll("#" + gIdPrefix + pRegionId + "_nodatafoundmsg").remove();
    }
   

    var new_apex_data_json = buildHierarchy(d3json)[0];
//	console.log("new_apex_data_json is");
//	console.log(JSON.stringify(new_apex_data_json,null, 2));

    if (new_apex_data_json.children) { 
      if (new_apex_data_json.children.length == 1) {
        new_apex_data_json = new_apex_data_json.children[0];
      }
    }
    if (pRefresh) {
      if (gFocusedDataNode) {gFocusedDataNode.stale = true;}
      copyCollapsedState(apex_data_json, new_apex_data_json, pCollapse);
      if (gFocusedDataNode.stale) {gFocusedDataNode = false;}
 
      apex_data_json = new_apex_data_json;
    } else {
      apex_data_json = new_apex_data_json;
      if (pCollapse) {
        apex_data_json.children.forEach(collapseAll);
      }
    }
    
    apex_data_json.is_root = true;
    apex_data_json.x0 = height / 2;
    apex_data_json.y0 = 0;

	updateChart(apex_data_json);
  }    
  
  function getNodefromTree(list, in_id) {
		return list.row.filter(function(d) {
            return d['ID'] === in_id;
        })[0];
	}  

  function adjustSvgWidth(widthNeeded) {
    if (widthNeeded >= maxWidth) {
      maxWidth = widthNeeded;
    }
/*
    if (widthNeeded >= width) {
      width = widthNeeded;
      svg.attr("width", width + config.margin.left + config.margin.right);
    }
*/
  }

  function updateChart(source) {
    maxWidth = 0;

    // events
    function getCssClass(d, highlight) {
      var lClass = highlight?pNodeHighlightClass:pNodeClass;

      if (d.children||d._children) {
        return config.css_class_node + (lClass == ""?"":" "+lClass);
      } else {
        return config.css_class_node + " " + config.css_class_leafnode + (lClass == ""?"":" "+lClass);
      }
    }

    function setFocusToNode(d) {
      if (gFocusedDataNode) {
        gFocusedDataNode = d;
        if (gFocusedDataNode.parent) {
          for (var pix=0;pix < gFocusedDataNode.parent.children.length; pix++) {
            if (gFocusedDataNode.parent.children[pix].ID == gFocusedDataNode.ID) {
              gFocusedChildIdx = pix;
              break;
            }
          }
        } else {
          gFocusedChildIdx = 0;
        }
        gFocusedNode = $('#' + gIdPrefix + pRegionId + '_' + gFocusedDataNode.ID ).first().focus();
      }
    }

    function processEvent_Touch(d) {
      fireApexEvent("touchend", d);
      toggleNodeCollapsed(d);
      setFocusToNode(d);
      return false;
    }

    function processEvent_Click(d) {
      fireApexEvent("click", d);
      toggleNodeCollapsed(d);
      setFocusToNode(d);
      return false;
    }

    function processEvent_linkClick(d) {
      if (d.LINK) {
        var win = apex.navigation.redirect(d.LINK);
        win.focus();
      }
    }
	


    function toggleNodeCollapsed(d) {
	  for(var i=0; i<nodes.length; i++) {
			if (nodes[i].ID == d.ID) {
				if (nodes[i].children) {
					nodes[i]._children = nodes[i].children;
					nodes[i].children = false;
				} 
				else {
					nodes[i].children = nodes[i]._children;
					nodes[i]._children = false;
				}
				updateChart(nodes[i]);
			}
		}
    }

    var nodes = pack.nodes(apex_data_json).reverse();
    var links = pack.links(nodes);

	
    var classifications = oracle.jql()
       .select( [function(rows){ return colorAccessor(rows[0]) }, 'color'] )
       .from( nodes.filter(function(d) {return !d.row; }) )
       .group_by( [function(row){ return row.COLORVALUE; }, 'classifications'] )();


  
    nodes.forEach(function(d) { d.y = d.depth * pLinkDistance; });
	
    var node = svgg.selectAll("." + config.css_class_node)
      .data(nodes,function(d) {return d.ID;});

	  
	// INSERT SECTION
	
	function getAvgMultiNodesPosition(type, in_id) {
		var locdX=0, locdY=0, locCount=0;
		nodes.forEach(function(d) { 
		    if(d.ID==in_id) {
				locCount++;
				locdX=locdX+d.x;
				locdY=locdY+d.y;
			}
		});
		//console.log("ID:"+in_id+" locdX:"+locdX+" locdY"+locdY+" count:"+locCount);
		if (type=='dx' && locCount!=0) 
			return locdX/locCount;
		else if (type=='dy' && locCount!=0) 
			return locdY/locCount;
		else
			return 0;
	}

    var nodeEnter = node.enter()
      .append("g")
      .attr("id",        function(d) { return gIdPrefix + pRegionId + "_" + d.ID})
      .attr("class",     function(d) { return getCssClass(d, false);})
      .attr("transform", function(d) { adjustSvgWidth(getAvgMultiNodesPosition('dy', d.ID)); return "translate(" + source.y0 + "," + source.x0 + ")"; })
      .on("dblClick", function(d) {fireApexEvent("dblClick", d);})
    ;

    nodeEnter.append("circle")
      .attr("r", 1e-6)
      .style("fill", function(d) { return colorAccessor(d); })
      .style("stroke", function(d) { return colorAccessor(d); })
      .each(function (d) {
          d3.select( this )
            .classed( 'u-Color-' + gClassScale( classficationsAccessor.apply( this, arguments ) ) + '-BG--fill' + 
                    ' u-Color-' + gClassScale( classficationsAccessor.apply( this, arguments ) ) + '-BG--br', true );
      })
      .on("touchend", processEvent_Touch)
      .on("click", processEvent_Click)
    ;

    nodeEnter.append("text")
      .attr("x", function(d) { return d.children || d._children ? -(getCircleRadius(d.SIZEVALUE) + 2) : getCircleRadius(d.SIZEVALUE) + 2; })
      .attr("dy", function(d) { return (d.children || d._children)&&!d.is_root ? "-0.35em" : "0.35em"; })
      .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
      .classed( function(d) { return 'u-Color-' + gClassScale( d.COLORVALUE ) + '-FG--fill';} )
      .text(function(d) { return getLabel(d); })
      .style("fill-opacity", 1e-6)
      .style("cursor", function (d) {return d.LINK?"pointer":"";})
      .on("click", processEvent_linkClick)
      .on("touchend", processEvent_linkClick)
    ;


    if ( pShowTooltip ) {
          var tooltipColor;
          var tooltipGenerator = d3.oracle.tooltip()
              .accessors({
                  label : function (d) {return d.LABEL;},
                  value : function( d ) { return (d.SIZEVALUE?d.SIZEVALUE:null); },
                  color : function() { return tooltipColor },
                  content : function( d ) { return getTooltipContent(d);}
              })
              .symbol( 'circle' );
    }


    nodeEnter.on("mouseover", function(d) {
      if ( pShowTooltip ) {
        tooltipColor = window.getComputedStyle( this.getElementsByTagName('circle')[0] ).getPropertyValue( 'fill' );

        d3.select( gTooltip$.get(0) )
            .datum( d )
            .call( tooltipGenerator );
        gTooltip$.stop().fadeIn( 100 );

        gTooltip$.position({
          my: 'left+20 center',
          of: d3.event,
          at: 'right center',
          within: gRegion$,
          collision: 'flip fit'
        });
      }

      nodeEnter
         .filter(function(d1) {return d1.ID == d.ID;})
         .attr("class",     function(d) { return getCssClass(d, true); })
      ;
      fireApexEvent("mouseover", d);
    }); 

    nodeEnter.on("mousemove", function(d) {
      if ( pShowTooltip ) {
        tooltipColor = window.getComputedStyle( this.getElementsByTagName('circle')[0] ).getPropertyValue( 'fill' );
        d3.select( gTooltip$.get(0) )
            .datum( d )
            .call( tooltipGenerator );
        
        if ( !gTooltip$.is(':visible') ) {
          gTooltip$.fadeIn();
        }

        gTooltip$.position({
          my: 'left+20 center',
          of: d3.event,
          at: 'right center',
          within: gRegion$,
          collision: 'flip fit'
        });
      }

      fireApexEvent("mousemove", d);
    }); 

    nodeEnter.on("focus", function(d) {
      var self = this;
      if ( this !== gHoveredNode || isKeydownTriggered ) {
        isKeydownTriggered = false;

        if ( pShowTooltip ) {
          tooltipColor = window.getComputedStyle( this.getElementsByTagName('circle')[0] ).getPropertyValue( 'fill' );
          d3.select( gTooltip$.get(0) )
              .datum( d )
              .call( tooltipGenerator );
          gTooltip$.stop().fadeIn( 100 );

          var off = $( this ).offset();
          gTooltip$.position({
              my: 'center bottom-5',
              of: gChart$,
              at: 'left+' + 
                  Math.round( off.left - gChart$.offset().left + this.getBBox().width / 2 ) + 
                  ' top+' + 
                  ( off.top - gChart$.offset().top ),
              within: gRegion$,
              collision: 'fit fit'
          });
        }
      }
      nodeEnter
         .filter(function(d1) {return d1.ID == d.ID;})
         .attr("class",     function(d) { return getCssClass(d, true); })
      ;

    });
 
    nodeEnter.on( 'blur', function(d) {
      nodeEnter
         .filter(function(d1) {return d1.ID == d.ID;})
         .attr("class",     function(d) { return getCssClass(d, false); })
      ;
        gFocusedNode = null;
        if ( !gHoveredNode ) {
            gTooltip$.stop().fadeOut( 100);
        }

        var self = this;
        d3.select( gChart$.get(0) )
            .selectAll( '.'+config.css_class_node)
    });


    nodeEnter.on("mouseout", function(d) {
      if ( pShowTooltip ) {
        gTooltip$.stop().fadeOut( 100 );
      }

      nodeEnter
         .filter(function(d1) {return d1.ID == d.ID && !(gFocusedNode && gFocusedDataNode && gFocusedDataNode.ID == d.ID)})
         .attr("class",     function(d) { return getCssClass(d, false); })
      ;
      fireApexEvent("mouseout", d);
    }); 
	
    // UPDATE SECTION!

    var nodeUpdate = node.transition().duration(config.trdur * 2)
        .attr("transform", function(d) { adjustSvgWidth(getAvgMultiNodesPosition('dy',d.ID));  return "translate(" + getAvgMultiNodesPosition('dy',d.ID) + "," + getAvgMultiNodesPosition('dx',d.ID) + ")"; })
    ;

    nodeUpdate
      .select("circle")
      .attr("r", function (d) {return getCircleRadius(d.SIZEVALUE);})
      .style("fill", function(d) { return colorAccessor(d); })
      .style("stroke", function(d) { return colorAccessor(d); })
      .each(function (d) {
        d3.select( this )
         .classed( 'u-Color-' + gClassScale( classficationsAccessor.apply( this, arguments ) ) + '-BG--fill' + 
                    ' u-Color-' + gClassScale( classficationsAccessor.apply( this, arguments ) ) + '-BG--br', true );
      }
    );
   
    var nodeText = nodeUpdate.select("text")
      .text(function(d) { return getLabel(d); })
      .each(function(d) {if (d.COLORVALUE) {d3.select(this).classed( function(d) { return 'u-Color-' + gClassScale( d.COLORVALUE ) + '-FG--fill';} )}})
      .style("fill-opacity", 1)
      .style("cursor", function (d) {return d.LINK?"pointer":"";})
    ;

    nodeText.each(function (d) {
        d3.select( this )
          .text( function(d){ return textEllipsis(this, d); } );
      });

	
    // DELETE SECTION
	
    var nodeExit = node.exit()
      .transition()
      .duration(config.trdur * 2)
      .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
      .remove();

    nodeExit
      .select("circle") 
      .attr("r", 1e-6);

    nodeExit.select("text")
      .style("fill-opacity", 1e-6);
	

    var link = svgg.selectAll("path." + config.css_class_link)
      .data(links, function(d) { 
		return d.target.CHILD_PARENT;});
		
	
    link.enter()
      .insert("path", "g")
      .attr("class", config.css_class_link)
      .attr("d", function(d) {
        var o = {x: source.x0, y: source.y0};
        return diagonal({source: o, target: o});
      });

    link.transition()
      .duration(config.trdur * 2)
      .attr("d", function(d) {
		var l_source  = {x: getAvgMultiNodesPosition('dx', d.source.ID), y: getAvgMultiNodesPosition('dy', d.source.ID)}
        var l_target = {x: getAvgMultiNodesPosition('dx', d.target.ID), y: getAvgMultiNodesPosition('dy', d.target.ID)};
        return diagonal({source: l_source, target: l_target});
      });
  
    
    link.exit().transition()
      .duration(config.trdur * 2)
      .attr("d", function(d) {
        var o = {x: source.x, y: source.y};
        return diagonal({source: o, target: o});
      })
      .remove();
    
    // Stash the old positions for transition.
    nodes.forEach(function(d) {
      d.x0 = d.x;
      d.y0 = d.y;
    });

    if ( pShowLegend ) {
      gAry = d3.oracle.ary()
          .hideTitle( true )
          .showValue( false )
          .leftColor( true )
          .numberOfColumns( 3 )
          .accessors({
              color: function(d) { return d.color; },
              label: function(d) { return (pColors=="COLUMN")?getLegendForColor(d.color):d.classifications; }
          })
          .symbol('circle');

      gAry.numberOfColumns( Math.max( Math.floor( width / config.legend_column_width ), 1 ) );

      d3.select( gLegend$.get(0) )
        .datum(classifications)
        .call( gAry )
        .selectAll( '.a-D3ChartLegend-item' )
        .each(function (d, i) {
            d3.select( this )
                .selectAll( '.a-D3ChartLegend-item-color' )
                .each(function() {
                    var self = d3.select( this );
                    var colorClass = self.attr( 'class' ).match(/u-Color-\d+-BG--bg/g) || [];
                    for (var i = colorClass.length - 1; i >= 0; i--) {
                        self.classed( colorClass[i], false );
                    };
                    self.classed( 'u-Color-' + gClassScale( d.classifications ) + '-BG--bg', true );
                })
        });
    }

    if ( !gHasHookedEvents ) {
            isFocused = false;
            $("svg", gChart$).first().on( 'focus', function() {
                isFocused = true;
                if (gFocusedDataNode) {
                  gFocusedNode = $('#' + gIdPrefix + pRegionId + '_' + gFocusedDataNode.ID ).first().focus();
                }
            })
            .on( 'keydown', function (e) {
                switch ( e.which ) {
                    case 13:
                        if ( gFocusedDataNode.LINK ) {
                          var win = apex.navigation.redirect(gFocusedDataNode.LINK);
                          win.focus();
                          e.preventDefault();
                        }
                        break;
                    case 32:
                        if ( gFocusedDataNode ) {
                          toggleNodeCollapsed(gFocusedDataNode);
                          e.preventDefault();
                        }
                        break;
                    case 37:
                        isKeydownTriggered = true;
                        if ( !gFocusedDataNode ) {
                            gFocusedDataNode = apex_data_json;
                            gFocusedChildIdx = 0;
                        } else {
                          if (gFocusedDataNode.parent) {
                            gFocusedDataNode = gFocusedDataNode.parent;
                            if (gFocusedDataNode.parent) {
                              for (var pix=0;pix < gFocusedDataNode.parent.children.length; pix++) {
                                if (gFocusedDataNode.parent.children[pix].ID == gFocusedDataNode.ID) {
                                  gFocusedChildIdx = pix;
                                  break;
                                }
                              }
                            } else {
                              gFocusedChildIdx = 0;
                            }
                          }
                        }
                        e.preventDefault();
                        break;  
                    case 38:
                        // Focus previous rectangle
                        isKeydownTriggered = true;
                        if ( !gFocusedDataNode ) {
                            gFocusedDataNode = apex_data_json;
                            gFocusedChildIdx = 0;
                        } else {
                           if (!gFocusedDataNode.is_root) {
                             if (gFocusedChildIdx > 0) {
                               gFocusedChildIdx--;
                               gFocusedDataNode = gFocusedDataNode.parent.children[gFocusedChildIdx];
                             } else {
                               gFocusedChildIdx = gFocusedDataNode.parent.children.length - 1;
                               gFocusedDataNode = gFocusedDataNode.parent.children[gFocusedChildIdx];
                             }
                           }
                        }
                        e.preventDefault();
                        break;
                    case 39:
                        isKeydownTriggered = true;
                        if ( !gFocusedDataNode ) {
                            gFocusedDataNode = apex_data_json;
                            gFocusedChildIdx = 0;
                        } else {
                          if (gFocusedDataNode.children) {
                            gFocusedDataNode = gFocusedDataNode.children[0];  
                            gFocusedChildIdx = 0;
                          }
                        }
                        e.preventDefault();
                        break;  
                    case 40:
                        // Focus next rectangle
                        isKeydownTriggered = true;
                        if ( !gFocusedDataNode ) {
                            gFocusedDataNode = apex_data_json;
                            gFocusedChildIdx = 0;
                        } else {
                           if (!gFocusedDataNode.is_root) {
                             if (gFocusedChildIdx < (gFocusedDataNode.parent.children.length - 1)) {
                                gFocusedChildIdx++
                                gFocusedDataNode = gFocusedDataNode.parent.children[gFocusedChildIdx];
                             } else {
                               gFocusedChildIdx = 0;
                               gFocusedDataNode = gFocusedDataNode.parent.children[gFocusedChildIdx];
                             }
                           }
                        }
                        e.preventDefault();
                        break;
                }
                gFocusedNode = $('#' + gIdPrefix + pRegionId + '_' + gFocusedDataNode.ID ).first().focus();
            })
            .on( 'blur', function (e) {
                if ( !$( document.activeElement ).is( '.' + config.css_class_node ) ) {
                    isFocused = false;
                    gFocusedNode = false;

                    var self = this;
                    svg.selectAll( '.' + config.css_class_node)
                        .attr( 'opacity', 1 );
                }
            });

        $( document ).on( 'keydown', function (e) {
            if ( isFocused && e.which >= 37 && e.which <= 40 ) {
                e.preventDefault();
            }
        })

        gHasHookedEvents = true;
    }

    var resizeTimeout;
    var resizeHandler = function() {
          clearTimeout( resizeTimeout );
          resizeTimeout = setTimeout( function() {
              _resizeFunction();
          }, 500);
        };

    if (!gResizeHandlerBound) {
      $(window).resize(resizeHandler );
      gResizeHandlerBound=true;
    }

    if (parseInt(svg.attr("width")) > (maxWidth + config.margin.left + config.margin.right - config.offset_scrollbars )) {
      setTimeout(function() {svg.attr("width", maxWidth + config.margin.left + config.margin.right);}, (config.trdur * 2));
    } else {
      svg.attr("width", maxWidth + config.margin.left + config.margin.right);
    }
    apex.event.trigger(
      $x(pRegionId),
      "apexafterrefresh" 
    );
  }

  function updateData(d3json) {
    refreshData(d3json, (pInitiallyCollapsed=="Y"), true);
  }
   
  function addData(d3json) {
    refreshData(d3json, (pInitiallyCollapsed=="Y"), false);

    apex.event.trigger(
      $x(pRegionId),
      gPluginIdPrefix + "initialized"
    );

    if (pAutoRefresh == 'Y') {
      autoRefreshInterval = window.setInterval(  
        function() { getData(updateData); },
        pRefreshInterval
      );
    }
  }

  // bind events

  apex.jQuery("#"+pRegionId).bind(
    "apexrefresh", 
    function() { getData(updateData); }
  );

  apex.jQuery("#"+pRegionId).bind(
    gPluginIdPrefix + "tree_collapse", 
    function() {
      if (apex_data_json.children || apex_data_json._children) {
        collapseAll(apex_data_json);
        gFocusedDataNode = false;
        updateChart(apex_data_json);
      } 
    }
  );

  apex.jQuery("#"+pRegionId).bind(
    gPluginIdPrefix + "tree_expand", 
    function() { 
      if (apex_data_json.children || apex_data_json._children) {
        expandAll(apex_data_json);
        updateChart(apex_data_json); 
      }
    }
  );


  getData(addData);
}})( apex.util, apex.server, apex.jQuery, d3 );


