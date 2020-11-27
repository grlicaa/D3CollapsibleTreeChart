# D3 Collapsible Tree Chart

## Demo

A demo application is available on apex.oracle.com
<https://apex.oracle.com/pls/apex/f?p=67842>

## Preview

![Preview image](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/D3TreePreview.gif)

## Change log

### V 6.0.2

- Added inline .js and .css files (APEX 20.2 deprecated those files)
- Fixed dynamic action "dblclick"
- Added dynamic documentationPreview image

### V 6.0.1

- Found in applications: Sample Charts
- added option Multiple parents

## About

Plugin was build due to collaboration with [APEX R&D](https://www.apexrnd.be)

## Install

- Import plug-in "region_type_plugin_com_oracle_apex_d3_coll_tree.sql" into your application.
- Add region on page and define SQL source.

## Documentation

### Must define

Here are few options you need to define carefully.

#### Page items to submit

If this is null tree don't work.

![sample1](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample1.png)

#### Number of rows

If this number is lower than ROWNUMBER of your SQL Query additional rows does not get presented on tree.
![sample7](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample7.png)

### Colors

To set custom colors you need to define color value field in SQL query.
Sample picture :
![sample1](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample1.png)

Next in attributes section find "Color Scheme" and choose Query Column.
Here you can define Legend Color Mapping like in a picture sample below:

![sample2](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample2.png)

### Multiple parents

![sample6](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample6.png)
Setting for this is simple, just put one field "Parent" with multiple column delimited values like "10:20:30"

![sample3](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample3.png)
![sample4](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample4.png)
You can even use Selectlist 2 Plug-in for adding multiple parents.
![sample5](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample5.png)

### Dynamic actions

This plugin plays well with Oracle APEX Dynamic action such as "refresh" region. In background plugin also triggers "apexbeforerefresh" and "apexbeafterfresh" actions.

#### Custom events

In this plugin we have 5 declarative inline events, which are triggered on specific action.
All of events are returning "data" object of current triggering node.
Sample of data object :

```json
{ "ID": "22",
  "CHILD_PARENT": "22_19",
  "SIZEVALUE": 10,
  "DEPTH": 3,
  "COLORVALUE":"green",
  "LABEL": "Task E",
  "INFOSTRING": null,
  "LINK": null,
  "ROWNUM": 0,
  ...
  }
```

To get that data inside following events use next JavaScript expression :

- Command : `this.data`
- Test with : `console.log("event data :", this.data);`

##### Events list

- D3Chart_Initialized

    This action is triggered when D3 is fully initialized.

- D3Chart_MouseClick

    When user clicks on tree node circle.

- D3Chart_MouseDblClick

    When user double clicks on tree node circle.

- D3Chart_MouseOut

    When user move mouse on tree node circle.

- D3Chart_MouseOver

    When user move mouse out of tree node circle.

#### Additional events

In case you need buttons like expand or collapse all you can use following code to achieve that.

```javascript
$("#REG_NAME").trigger( "com_oracle_apex_d3_tree_collapse" );
$("#REG_NAME").trigger( "com_oracle_apex_d3_tree_expand"   );
```

## APEX Versions

- Oracle Application Express 5.x
- Oracle Application Express 18.x
- Oracle Application Express 19.x
- Oracle Application Express 20.x
