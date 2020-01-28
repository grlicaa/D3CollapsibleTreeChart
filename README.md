# D3 Collapsible Tree Chart

## Demo
A demo application is available on apex.oracle.com<br/>
https://apex.oracle.com/pls/apex/f?p=67842

## Preview
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/D3TreePreview.gif)

## Change log
V 6.0.1
Found in applications: Sample Charts 
- added option Multiple parents

## About
Plugin was build due to collaboration with [APEX R&D](https://www.apexrnd.be)

## Install
<ol>
<li>Import plug-in "region_type_plugin_com_oracle_apex_d3_coll_tree.sql" into your application.</li>
<li>Add region on page and define SQL source.</li>
</ol>


## Documentation

### Must define
Here are few options you need to define carefully.

#### Page items to submit: 
If this is null tree don't work.<br/>
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample1.png)
#### Number of rows:
If this number is lower than ROWNUMBER of your SQL Query additional rows does not get presented on tree.<br/>
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample7.png)


### Colors
To set custom colors you need to define color value field in SQL query.<br/>
Sample picture :<br/>
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample1.png)
Next in attributes section find "Color Scheme" and choose Query Column.<br/>
Here you can define Legend Color Mapping like in a picture sample below:<br/>
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample2.png)

### Multiple parents
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample6.png)
Setting for this is simple, just put one field "Parent" with multiple column delimited values like "10:20:30"<br/>
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample3.png)
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample4.png)
You can even use Selectlist 2 Plug-in for adding multiple parents.<br/>
![](https://raw.githubusercontent.com/grlicaa/D3CollapsibleTreeChart/master/docs/sample5.png)


## APEX Versions
<ul>
<li>Application Express 5.x</li>
<li>Application Express 18.x</li>
<li>Application Express 19.x</li>
</ul>
