prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_release=>'5.1.4.00.08'
,p_default_workspace_id=>61716057417882438171
,p_default_application_id=>67842
,p_default_owner=>'ANDREJGR'
);
end;
/
prompt --application/shared_components/plugins/region_type/com_oracle_apex_d3_coll_tree
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(115185577336138139104)
,p_plugin_type=>'REGION TYPE'
,p_name=>'COM.ORACLE.APEX.D3.COLL.TREE'
,p_display_name=>'D3 Collapsible Tree Chart'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#IMAGE_PREFIX#libraries/d3/3.3.11/d3.min.js',
'#IMAGE_PREFIX#plugins/com.oracle.apex.d3/d3.oracle.js',
'#IMAGE_PREFIX#plugins/com.oracle.apex.d3/oracle.jql.js',
'#IMAGE_PREFIX#plugins/com.oracle.apex.d3.tooltip/d3.oracle.tooltip.js',
'#IMAGE_PREFIX#plugins/com.oracle.apex.d3.ary/d3.oracle.ary.js',
'#PLUGIN_FILES#com_oracle_apex_d3tree.js'))
,p_css_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#IMAGE_PREFIX#plugins/com.oracle.apex.d3.tooltip/d3.oracle.tooltip.css',
'#IMAGE_PREFIX#plugins/com.oracle.apex.d3.ary/d3.oracle.ary.css',
''))
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function ora_d3_tree_ajax (  p_region in apex_plugin.t_region,',
'                                 p_plugin in apex_plugin.t_plugin )',
'                        return apex_plugin.t_region_ajax_result is',
'    c_label_col  constant varchar2(255) := p_region.attribute_12;',
'    c_value_col  constant varchar2(255) := p_region.attribute_13;',
'    c_pk_col     constant varchar2(255) := p_region.attribute_14;',
'    c_parent_col constant varchar2(255) := p_region.attribute_15;',
'    c_group_col  constant varchar2(255) := p_region.attribute_16;',
'    c_desc_col   constant varchar2(255) := p_region.attribute_18;',
'    c_link_str   constant varchar2(255) := p_region.attribute_09;',
'',
'    l_label_col_no  pls_integer;',
'    l_value_col_no  pls_integer;',
'    l_pk_col_no     pls_integer;',
'    l_parent_col_no pls_integer;',
'    l_group_col_no  pls_integer;',
'    l_link_col_no   pls_integer;',
'    l_desc_col_no   pls_integer;',
'',
'    l_label  varchar2(4000);',
'    l_value  number;',
'    l_pk     varchar2(4000);',
'    l_parent varchar2(4000);',
'    l_group  varchar2(4000);',
'    l_link   varchar2(4000);',
'    l_desc   varchar2(4000);',
'',
'    l_num_rows          pls_integer := p_region.fetched_rows;',
'    l_count             pls_integer := 0;',
'    l_column_value_list apex_plugin_util.t_column_value_list2;',
'    l_region_source     varchar2(32767) := p_region.source;',
'    ',
'begin',
'    -- get the data to be displayed',
'    l_column_value_list := apex_plugin_util.get_data2 (',
'                               p_sql_statement  => l_region_source,',
'                               p_min_columns    => 4,',
'                               p_max_columns    => null,',
'                               p_component_name => p_region.name,',
'                               p_max_rows       => null );',
'',
'    -- Get the actual column number for the fields we want.',
'    l_label_col_no := apex_plugin_util.get_column_no (',
'                        p_attribute_label   => ''Label Column'',',
'                        p_column_alias      => c_label_col,',
'                        p_column_value_list => l_column_value_list,',
'                        p_is_required       => false,',
'                        p_data_type         => apex_plugin_util.c_data_type_varchar2',
'                    );',
'    l_value_col_no := apex_plugin_util.get_column_no (',
'                        p_attribute_label   => ''Value Column'',',
'                        p_column_alias      => c_value_col,',
'                        p_column_value_list => l_column_value_list,',
'                        p_is_required       => false,',
'                        p_data_type         => apex_plugin_util.c_data_type_number',
'                    );',
'    l_pk_col_no := apex_plugin_util.get_column_no (',
'                        p_attribute_label   => ''Primary Key Column'',',
'                        p_column_alias      => c_pk_col,',
'                        p_column_value_list => l_column_value_list,',
'                        p_is_required       => true,',
'                        p_data_type         => apex_plugin_util.c_data_type_varchar2',
'                    );',
'    l_parent_col_no := apex_plugin_util.get_column_no (',
'                        p_attribute_label   => ''Parent Key Column'',',
'                        p_column_alias      => c_parent_col,',
'                        p_column_value_list => l_column_value_list,',
'                        p_is_required       => true,',
'                        p_data_type         => apex_plugin_util.c_data_type_varchar2',
'                    );',
'    l_group_col_no := apex_plugin_util.get_column_no (',
'                        p_attribute_label   => ''Color Group Column'',',
'                        p_column_alias      => c_group_col,',
'                        p_column_value_list => l_column_value_list,',
'                        p_is_required       => true,',
'                        p_data_type         => apex_plugin_util.c_data_type_varchar2',
'                    );',
'/*',
'    l_link_col_no := apex_plugin_util.get_column_no (',
'                        p_attribute_label   => ''Link Column'',',
'                        p_column_alias      => c_link_col,',
'                        p_column_value_list => l_column_value_list,',
'                        p_is_required       => false,',
'                        p_data_type         => apex_plugin_util.c_data_type_varchar2',
'                    );',
'*/',
'    l_desc_col_no := apex_plugin_util.get_column_no (',
'                        p_attribute_label   => ''Description Column'',',
'                        p_column_alias      => c_desc_col,',
'                        p_column_value_list => l_column_value_list,',
'                        p_is_required       => false,',
'                        p_data_type         => apex_plugin_util.c_data_type_varchar2',
'                    );',
'',
'    -- Loop through the data',
'    apex_json.open_object;',
'    apex_json.open_array(''row'');',
'    for l_row_num in 1..l_column_value_list(1).value_list.count loop',
'        if l_count < nvl(l_num_rows,l_count) then',
'            l_count := l_count+1;',
'',
'            begin',
'                -- Assign the column values of the current row',
'                -- into session state',
'                apex_plugin_util.set_component_values (',
'                    p_column_value_list => l_column_value_list,',
'                    p_row_num           => l_row_num );',
'',
'                apex_json.open_object;',
'',
'                l_pk     := apex_plugin_util.get_value_as_varchar2(',
'                                p_data_type => l_column_value_list(l_pk_col_no).data_type,',
'                                p_value     => l_column_value_list(l_pk_col_no).value_list(l_row_num) );',
'                l_group  := apex_plugin_util.get_value_as_varchar2(',
'                                p_data_type => l_column_value_list(l_group_col_no).data_type,',
'                                p_value     => l_column_value_list(l_group_col_no).value_list(l_row_num) );',
'                l_parent := apex_plugin_util.get_value_as_varchar2(',
'                                p_data_type => l_column_value_list(l_parent_col_no).data_type,',
'                                p_value     => l_column_value_list(l_parent_col_no).value_list(l_row_num) );',
'',
'',
'                -- Emit the required columns',
'                apex_json.write(''ID'',        l_pk);',
'                apex_json.write(''COLORVALUE'',l_group);',
'                if l_parent LIKE ''%:%'' THEN',
'                     apex_json.open_array(''PARENT_ID''); -- "PARENT_ID": [',
'                          for i IN (select regexp_substr(l_parent ,''[^:]+'', 1, level) As str from dual',
'                                        connect by regexp_substr(l_parent, ''[^:]+'', 1, level) is not null)',
'                          loop',
'                              apex_json.write(i.str);',
'                          end loop;',
'                     apex_json.close_array; --- ]',
'                else',
'                    apex_json.write(''PARENT_ID'', l_parent);',
'                end if;',
'                ',
'  ',
'                if c_link_str is not null then',
'                  l_link := apex_plugin_util.replace_substitutions( p_value => c_link_str );',
'                  for i in l_column_value_list.first..l_column_value_list.last loop',
'                    l_link := replace(',
'                       l_link, ',
'                       ''#''||l_column_value_list(i).name||''#'', ',
'                       apex_plugin_util.get_value_as_varchar2(',
'                         p_data_type => l_column_value_list(i).data_type,',
'                         p_value     => l_column_value_list(i).value_list(l_row_num)',
'                       )',
'                    );',
'                  end loop;',
'                    apex_json.write(''LINK'',apex_util.prepare_url(l_link));',
'                end if;',
'',
'                -- Emit the optional columns if provided',
'',
'                if l_value_col_no is not null then',
'                  l_value  := l_column_value_list(l_value_col_no).value_list(l_row_num).number_value;',
'                  apex_json.write(''SIZEVALUE'', l_value);',
'                end if;',
'',
'                if l_label_col_no is not null then',
'                    l_label  := apex_plugin_util.get_value_as_varchar2(',
'                                p_data_type => l_column_value_list(l_label_col_no).data_type,',
'                                p_value     => l_column_value_list(l_label_col_no).value_list(l_row_num) );',
'                    apex_json.write(''LABEL'',     l_label);',
'                end if;',
'/*',
'',
'                if l_link_col_no is not null then',
'',
'                    l_link := apex_plugin_util.get_value_as_varchar2(',
'                                    p_data_type => l_column_value_list(l_link_col_no).data_type,',
'                                    p_value     => l_column_value_list(l_link_col_no).value_list(l_row_num) );',
'                    apex_json.write(''LINK'',        apex_util.prepare_url(l_link));',
'                end if;',
'*/',
'                if l_desc_col_no is not null then',
'                    l_desc := apex_plugin_util.get_value_as_varchar2(',
'                                    p_data_type => l_column_value_list(l_desc_col_no).data_type,',
'                                    p_value     => l_column_value_list(l_desc_col_no).value_list(l_row_num) );',
'                    apex_json.write(''INFOSTRING'',l_desc);',
'                end if;',
'',
'                apex_json.close_object;',
'',
'                apex_plugin_util.clear_component_values;',
'            exception when others then',
'                apex_plugin_util.clear_component_values;',
'                raise;',
'            end;',
'        end if;',
'    end loop;',
'    apex_json.close_all;',
'',
'    return null;',
'  end ora_d3_tree_ajax; ',
'',
' function ora_d3_tree_render (',
'      p_region              in apex_plugin.t_region,',
'      p_plugin              in apex_plugin.t_plugin,',
'      p_is_printer_friendly in boolean ',
'  ) return apex_plugin.t_region_render_result is ',
'    l_colors             apex_application_page_regions.attribute_02%type := p_region.attribute_02;',
'    l_colorlegendmapping apex_application_page_regions.attribute_25%type := p_region.attribute_25;',
'    l_auto_refr          apex_application_page_regions.attribute_04%type := p_region.attribute_04;',
'    l_refr_int           number                                          := to_number( p_region.attribute_05 );',
'',
'    l_node_class         apex_application_page_regions.attribute_06%type := p_region.attribute_06;',
'    l_node_hlclass       apex_application_page_regions.attribute_07%type := p_region.attribute_07;',
'',
'    l_adv_conf_yn        apex_application_page_regions.attribute_10%type := p_region.attribute_10;',
'    l_adv_conf           apex_application_page_regions.attribute_11%type := p_region.attribute_11;',
'',
'    l_link_dist          apex_application_page_regions.attribute_19%type := p_region.attribute_19;',
'    l_init_collapsed     apex_application_page_regions.attribute_20%type := p_region.attribute_20;',
'    ',
'    l_msg_nodata         apex_application_page_regions.no_data_found_message%type := p_region.no_data_found_message;',
'',
'',
'    --Aspect Ratios',
'    c_min_ar                constant number         := apex_plugin_util.get_attribute_as_number(p_plugin.attribute_01, ''Min Aspect Ratio'');',
'    c_max_ar                constant number         := apex_plugin_util.get_attribute_as_number(p_plugin.attribute_02, ''Max Aspect Ratio'');',
'    l_formatted_min_ar      varchar2(200);',
'    l_formatted_max_ar      varchar2(200);',
'',
'',
'    --Dimensions',
'    c_min_height            constant number         := nvl(p_region.attribute_21, 200);',
'    c_max_height            constant number         := nvl(p_region.attribute_22, 500);',
'',
'    -- Legend',
'    c_show_legend           constant boolean        := p_region.attribute_23 is not null;',
'    c_legend_position       constant varchar2(200)  := p_region.attribute_23;',
'    ',
'     -- Tooltip configuration',
'    c_show_tooltip          constant boolean        := p_region.attribute_24 = ''Y'';',
'',
'',
'    l_escape_html      varchar2(10);',
'  begin',
'   -- Formatting to fix add_attribute bug.',
'    if c_min_ar > -1 and c_min_ar < 1 and c_min_ar <> 0 then',
'        l_formatted_min_ar := (case when c_min_ar < 0 then ''-'' else '''' end) || ''0'' || to_char(abs(c_min_ar));',
'    else',
'        l_formatted_min_ar := to_char(c_min_ar);',
'    end if;',
'    if c_max_ar > -1 and c_max_ar < 1 and c_max_ar <> 0 then',
'        l_formatted_max_ar := (case when c_max_ar < 0 then ''-'' else '''' end) || ''0'' || to_char(abs(c_max_ar));',
'    else',
'        l_formatted_max_ar := to_char(c_max_ar);',
'    end if;',
'',
'',
'    -- Color scheme',
'    case l_colors',
'        when ''MODERN'' then',
'            l_colors := ''#FF3B30:#FF9500:#FFCC00:#4CD964:#34AADC:#007AFF:#5856D6:#FF2D55:#8E8E93:#C7C7CC'';',
'        when ''MODERN2'' then',
'            l_colors := ''#1ABC9C:#2ECC71:#4AA3DF:#9B59B6:#3D566E:#F1C40F:#E67E22:#E74C3C'';',
'        when ''SOLAR'' then',
'            l_colors := ''#B58900:#CB4B16:#DC322F:#D33682:#6C71C4:#268BD2:#2AA198:#859900'';',
'        when ''METRO'' then',
'            l_colors := ''#E61400:#19A2DE:#319A31:#EF9608:#8CBE29:#A500FF:#00AAAD:#FF0094:#9C5100:#E671B5'';',
'        else',
'            null;',
'    end case;',
'',
'',
'    if l_adv_conf_yn = ''N'' then l_adv_conf := ''''; end if;',
'',
'    if p_region.escape_output then ',
'      l_escape_html := ''Y'';',
'    else ',
'      l_escape_html := ''N'';',
'    end if;',
'',
'    apex_css.add (',
'      p_css => ''.com_oracle_apex_d3_tree_link {fill: none; stroke: #ccc; stroke-width: 1.5px;}'',',
'      p_key => ''com_oracle_apex_d3_tree_link'' ',
'    );                ',
'    apex_css.add (',
'      p_css => ''.d3_treechart_container .a-D3TreeChart-tooltip {position: absolute; }'',',
'      p_key => ''com_oracle_apex_d3_absolutepos'' ',
'    );                ',
'    apex_css.add (',
'      p_css => ''.com_oracle_apex_d3_tree_node:focus {outline-color: gray;background : #eee}'',',
'      p_key => ''com_oracle_apex_d3_node_focused'' ',
'    );                ',
'',
'sys.htp.p(',
'         ''<div class="d3_treechart_container" id="''',
'        ||apex_plugin_util.escape(p_region.static_id, true)',
'        ||''">''',
'        ||''<div id="d3_treechart_''',
'        ||apex_plugin_util.escape(p_region.static_id, true) ',
'        ||''" style="overflow-x: auto;">''',
'    );',
'    sys.htp.p(''</div></div>'');',
'',
'',
'    apex_javascript.add_onload_code (',
'      ''com_oracle_apex_d3_tree_start(''||',
'        apex_javascript.add_value(p_region.static_id,              true)  ||',
'        apex_javascript.add_value(apex_plugin.get_ajax_identifier, true)  ||',
'        apex_javascript.add_value(l_msg_nodata,                    true)  ||',
'        apex_javascript.add_value(l_colors,                        true)  ||',
'        apex_javascript.add_value(l_colorlegendmapping,            true)  ||',
'        apex_javascript.add_value(l_link_dist,                     true)  ||',
'        apex_javascript.add_value(l_init_collapsed,                true)  ||',
'        apex_javascript.add_value(l_adv_conf,                      true)  ||',
'        apex_javascript.add_value(l_auto_refr,                     true)  ||',
'        apex_javascript.add_value(l_refr_int,                      true)  ||',
'        apex_javascript.add_value(l_node_class,                    true)  ||',
'        apex_javascript.add_value(l_node_hlclass,                  true)  ||',
'        apex_javascript.add_value(l_escape_html,                   true)  ||',
'        apex_javascript.add_value(p_region.ajax_items_to_submit,   true)  ||',
'        apex_javascript.add_value(c_min_height,                    true)  ||',
'        apex_javascript.add_value(c_max_height,                    true)  ||',
'        apex_javascript.add_value(l_formatted_min_ar,              true)  ||',
'        apex_javascript.add_value(l_formatted_max_ar,              true)  ||',
'        apex_javascript.add_value(c_show_tooltip,                  true)  ||',
'        apex_javascript.add_value(c_show_legend,                   true)  ||',
'        apex_javascript.add_value(c_legend_position,               false) ||',
'      '');''',
'    );',
'    return null;',
'  end ora_d3_tree_render; ',
'',
''))
,p_api_version=>1
,p_render_function=>'ora_d3_tree_render'
,p_ajax_function=>'ora_d3_tree_ajax'
,p_standard_attributes=>'SOURCE_SQL:AJAX_ITEMS_TO_SUBMIT:FETCHED_ROWS:NO_DATA_FOUND_MESSAGE:ESCAPE_OUTPUT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>',
'	This plugin provides a&nbsp;<em>Collapsible Tree Chart</em> based on the <a href="http://www.d3js.org" target="_blank">D3js</a> framework. Collapsible Tree charts allow to visualize data hierarchies. This plugin is based on the <a href="http://bl.oc'
||'ks.org/mbostock/4339083">collapsible tree  example</a>&nbsp;by the D3js author Mike Bostock.</p>',
'<p>',
'	Plugin features:</p>',
'<ul>',
'	<li>',
'		Generate a Collapsible Tree Chart based on the SQL query in the Region source',
'		<ul>',
'			<li>',
'				The data hierarchy (columns ID and PARENT_ID) is being detected automatically. If the query returns multiple root nodes, the plugin creates an own root node.</li>',
'			<li>',
'				Plugin honors the&nbsp;<em>Page Items to Submit&nbsp;</em>attribute</li>',
'			<li>',
'				Plugin honors the&nbsp;<em>Escape Special Characters&nbsp;</em>attribute (this applies to the &quot;Infobox&quot; which is displayed on Mouseover)</li>',
'		</ul>',
'	</li>',
'	<li>',
'		The Plugin is AJAX aware',
'		<ul>',
'			<li>',
'				Honors the&nbsp;<em>apexrefresh</em> event - you can refresh the chart with a Dynamic Action</li>',
'			<li>',
'				The Plugin provides an&nbsp;<em>Auto Refresh&nbsp;</em>mode</li>',
'			<li>',
'				Plugin posts events to the APEX Dynamic Action Framework. So you can create dynamic Actions (e.g. to refresh other APEX components) based on the following plugin events.',
'				<ul>',
'					<li>',
'						Mouseover</li>',
'					<li>',
'						Mouseout</li>',
'					<li>',
'						Mouse Click</li>',
'					<li>',
'						Mouse Double Click</li>',
'					<li>',
'						Chart initialized<br />',
'						&nbsp;</li>',
'				</ul>',
'			</li>',
'		</ul>',
'	</li>',
'	<li>',
'		CSS and responsive Features',
'		<ul>',
'			<li>',
'				The plugin is responsive and changes its size according to the device&#39;s display size</li>',
'			<li>',
'				All components (Areas, Infoboxes, highlighted areas) can be augmented with own CSS classes</li>',
'		</ul>',
'	</li>',
'</ul>'))
,p_version_identifier=>'6.0.1'
,p_about_url=>'http://apex.oracle.com/plugins'
,p_files_version=>500
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195296880287026373)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>510
,p_prompt=>'Minimum Aspect Ratio'
,p_attribute_type=>'NUMBER'
,p_is_required=>true
,p_default_value=>'1.333'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter the minimum aspect ratio that charts use to recommend a height. A minimum aspect ratio of 1.333 means that the chart''s width should be no less than 1.333 times its height. </p>',
'<p>Note: This setting can be overridden by the ''Minimum Height'' setting on the region.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195297225469026375)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>520
,p_prompt=>'Maximum Aspect Ratio'
,p_attribute_type=>'NUMBER'
,p_is_required=>true
,p_default_value=>'3'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter the maximum aspect ratio that charts use to recommend a height. A maximum aspect ratio of 3 means that the chart''s width should be no greater than 3 times its height. </p>',
'<p>Note: This setting can be overridden by the ''Maximum Height'' setting on the region.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195297622377026375)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>140
,p_prompt=>'Color Scheme'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'DEFAULT'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Select the color scheme used to render the chart.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195297983896026376)
,p_plugin_attribute_id=>wwv_flow_api.id(117195297622377026375)
,p_display_sequence=>5
,p_display_value=>'Theme Default'
,p_return_value=>'DEFAULT'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195298477066026377)
,p_plugin_attribute_id=>wwv_flow_api.id(117195297622377026375)
,p_display_sequence=>10
,p_display_value=>'Modern'
,p_return_value=>'MODERN'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195298964912026378)
,p_plugin_attribute_id=>wwv_flow_api.id(117195297622377026375)
,p_display_sequence=>20
,p_display_value=>'Modern 2'
,p_return_value=>'MODERN2'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195299503011026379)
,p_plugin_attribute_id=>wwv_flow_api.id(117195297622377026375)
,p_display_sequence=>30
,p_display_value=>'Solar'
,p_return_value=>'SOLAR'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195300008075026379)
,p_plugin_attribute_id=>wwv_flow_api.id(117195297622377026375)
,p_display_sequence=>40
,p_display_value=>'Metro'
,p_return_value=>'METRO'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195300510371026379)
,p_plugin_attribute_id=>wwv_flow_api.id(117195297622377026375)
,p_display_sequence=>50
,p_display_value=>'Query Column'
,p_return_value=>'COLUMN'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195301008094026379)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>110
,p_prompt=>'Auto Refresh'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_show_in_wizard=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'<p>Select whether the chart is refreshed automatically.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195301415085026380)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>120
,p_prompt=>'Refresh Interval'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_show_in_wizard=>false
,p_display_length=>5
,p_max_length=>5
,p_unit=>'ms'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(117195301008094026379)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'<p>Enter the refresh interval (in milliseconds).</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195301779332026380)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>190
,p_prompt=>'Node CSS Class'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_display_length=>30
,p_max_length=>30
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'</pre>',
'<g class="node {your CSS class}">',
'  <circle>{Node Circle definition}</circle>',
'  <text>{Label}</text>',
'</g>',
'</pre>'))
,p_help_text=>'<p>Enter an additional CSS class name to be applied to each area. The class is being applied to the "div" node which makes up the area for a node.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195302187972026381)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>180
,p_prompt=>'Highlight CSS Class'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_display_length=>30
,p_max_length=>30
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'</pre>',
'<g class="node {your CSS class}">',
'  <circle>{Node Circle definition}</circle>',
'  <text>{Label}</text>',
'</g>',
'</pre>'))
,p_help_text=>'<p>Enter an additional CSS class name to be applied to each area. The class is being applied to the "div" node which makes up the area for a node.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195302551064026381)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>30
,p_prompt=>'Link Target'
,p_attribute_type=>'LINK'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Example 1: URL to navigate to page 10 and set P10_EMPNO to the EMPNO value of the clicked entry.',
'<pre>f?p=&amp;APP_ID.:10:&amp;APP_SESSION.::&amp;DEBUG.:RP,10:P10_EMPNO:&amp;EMPNO.</pre>',
'</p>',
'<p>Example 2: Display the EMPNO value of the clicked entry in a JavaScript alert',
'<pre>javascript:alert(''current empno: &amp;EMPNO.'');</pre>',
'</p>'))
,p_help_text=>'<p>Enter a target page to be called when the user clicks a chart entry.</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195303022972026382)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>200
,p_prompt=>'Tree Configuration JSON'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>true
,p_is_common=>false
,p_show_in_wizard=>false
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{',
'  "trdur":                       500,',
'  "css_class_node":              "com_oracle_apex_d3_tree_node",',
'  "css_class_leafnode":          "com_oracle_apex_d3_tree_leafnode",',
'  "css_class_link":              "com_oracle_apex_d3_tree_link",',
'  "circle_radius_min":           10,',
'  "circle_radius_max":           10,',
'  "legend_column_width":         200,',
'  "root_label":                  "Tree root",',
'  "show_coll_child_cnt":         true,',
'  "show_coll_child_template":    " (#CNT#)",',
'  "offset_scrollbars":           20, ',
'  "margin":                      {"top": 20, "right": 120, "bottom": 20, "left": 120}',
'}'))
,p_display_length=>75
,p_max_length=>4000
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'{',
'  "trdur":                       500,',
'  "css_class_node":              "com_oracle_apex_d3_tree_node",',
'  "css_class_leafnode":          "com_oracle_apex_d3_tree_leafnode",',
'  "css_class_link":              "com_oracle_apex_d3_tree_link",',
'  "circle_radius_min":           10,',
'  "circle_radius_max":           10,',
'  "legend_column_width":         200,',
'  "root_label":                  "Tree root",',
'  "show_coll_child_cnt":         true,',
'  "show_coll_child_template":    " (#CNT#)",',
'  "offset_scrollbars":           20, ',
'  "margin":                      {"top": 20, "right": 120, "bottom": 20, "left": 120}',
'}',
'</pre>'))
,p_help_text=>'<p>Enter configuration values to change the chart''s behavior. Make sure that this is always <em>valid JSON</em> syntax,  otherwise the plugin will not pick up your changes. </p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195303410349026383)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>10
,p_prompt=>'Label Column'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
,p_help_text=>'Select the column from the region SQL Query which holds the labels for the chart.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195303746213026383)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>20
,p_prompt=>'Value Column'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'NUMBER'
,p_is_translatable=>false
,p_help_text=>'Select the column from the region SQL Query which holds the values for the chart.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195304222613026383)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>40
,p_prompt=>'Primary Key Column'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
,p_help_text=>'Select the column from the region SQL Query that holds the primary key values for the chart. The primary key and parent key columns are used to define the hierarchy for the chart.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195304628931026384)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>50
,p_prompt=>'Parent Key Column'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
,p_help_text=>'Select the column from the region SQL Query that holds the parent key values for the chart. The primary key and parent key columns are used to define the hierarchy for the chart.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195304970711026384)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>60
,p_prompt=>'Color Group Column'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
,p_help_text=>'Select the column from the region SQL Query that holds the color group values for the chart.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195305390460026384)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>80
,p_prompt=>'Tootip Column'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>false
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(117195308760462026388)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'Select the column from the region SQL Query that holds the tooltip values for the chart.'
);
end;
/
begin
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195305741998026385)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>130
,p_prompt=>'Link Distance'
,p_attribute_type=>'NUMBER'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'180'
,p_display_length=>5
,p_max_length=>5
,p_unit=>'px'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'Enter the distance between links. Default is 180 pixels.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195306139992026385)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>20
,p_display_sequence=>100
,p_prompt=>'Initially Collapsed'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'Select whether the links should initially be collapsed or expanded.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195306575893026385)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>21
,p_display_sequence=>160
,p_prompt=>'Minimum Height'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_display_length=>10
,p_unit=>'pixels'
,p_is_translatable=>false
,p_help_text=>'Enter the minimum height, in pixels, of the chart. Chart width will adapt to the size of the region.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195306954063026385)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>22
,p_display_sequence=>170
,p_prompt=>'Maximum Height'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_display_length=>10
,p_unit=>'pixels'
,p_is_translatable=>false
,p_help_text=>'Enter the maximum height, in pixels, of the chart. Chart width will adapt to the size of the region.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195307356744026386)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>23
,p_display_sequence=>90
,p_prompt=>'Legend'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_null_text=>'No Legend'
,p_help_text=>'Select where the legend is displayed on the chart.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195307748486026386)
,p_plugin_attribute_id=>wwv_flow_api.id(117195307356744026386)
,p_display_sequence=>10
,p_display_value=>'Above chart'
,p_return_value=>'TOP'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(117195308293624026387)
,p_plugin_attribute_id=>wwv_flow_api.id(117195307356744026386)
,p_display_sequence=>20
,p_display_value=>'Below chart'
,p_return_value=>'BOTTOM'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195308760462026388)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>24
,p_display_sequence=>70
,p_prompt=>'Show Tooltips'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Select whether to show tooltips.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(117195309178558026388)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>25
,p_display_sequence=>150
,p_prompt=>'Legend Color Mapping'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>true
,p_default_value=>'{"red":"Legend for red","blue":"Legend for Blue"}'
,p_display_length=>40
,p_max_length=>500
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(117195297622377026375)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'COLUMN'
,p_help_text=>'Enter the color mapping for the legend.'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(117195311297761026415)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_name=>'SOURCE_SQL'
,p_sql_min_column_count=>3
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Provide a SQL query as follows:</p>',
'<h1>SQL Example</h1>',
'<pre>',
'select',
'  empno as ID,              --required',
'  mgr   as PARENT_ID,       --required',
'  job   as COLORVALUE,      --required',
'  sal   as SIZEVALUE,       --optional',
'  ename as LABEL,           --optional',
'  null  as LINK,            --optional',
'  text  as INFOSTRING       --optional',
'from emp',
'</pre>',
''))
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(117195313178130026418)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_name=>'com_oracle_apex_d3_click'
,p_display_name=>'D3Chart_MouseClick'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(117195313585739026419)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_name=>'com_oracle_apex_d3_dblclick'
,p_display_name=>'D3Chart_MouseDblClick'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(117195313937209026419)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_name=>'com_oracle_apex_d3_initialized'
,p_display_name=>'D3Chart_Initialized'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(117195314386207026419)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_name=>'com_oracle_apex_d3_mouseout'
,p_display_name=>'D3Chart_MouseOut'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(117195314751601026420)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_name=>'com_oracle_apex_d3_mouseover'
,p_display_name=>'D3Chart_MouseOver'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2866756E6374696F6E28207574696C2C207365727665722C20242C2064332029207B0D0A0D0A636F6D5F6F7261636C655F617065785F64335F747265655F7374617274203D2066756E6374696F6E280D0A202070526567696F6E49642C200D0A20207041';
wwv_flow_api.g_varchar2_table(2) := '6A617849642C0D0A2020704E6F44617461466F756E644D73672C0D0A202070436F6C6F72732C0D0A202070436F6C6F724C6567656E644D617070696E672C0D0A2020704C696E6B44697374616E63652C0D0A202070496E697469616C6C79436F6C6C6170';
wwv_flow_api.g_varchar2_table(3) := '7365642C0D0A202070436F6E6669672C0D0A2020704175746F526566726573682C0D0A20207052656672657368496E74657276616C2C0D0A2020704E6F6465436C6173732C0D0A2020704E6F6465486967686C69676874436C6173732C0D0A2020704573';
wwv_flow_api.g_varchar2_table(4) := '6361706548746D6C2C0D0A202070506167654974656D735375626D69742C0D0A2020704D696E4865696768742C0D0A2020704D61784865696768742C0D0A2020704D696E41522C0D0A2020704D617841522C0D0A20207053686F77546F6F6C7469702C0D';
wwv_flow_api.g_varchar2_table(5) := '0A20207053686F774C6567656E642C0D0A2020704C6567656E64506F736974696F6E0D0A297B0D0A2020766172206175746F52656672657368496E74657276616C3B0D0A202076617220636F6C6F723B0D0A2020766172207261646975735F666163746F';
wwv_flow_api.g_varchar2_table(6) := '723B0D0A20207661722076616C75655F6D696E3B0D0A0D0A202076617220617065785F646174615F6A736F6E3B0D0A202076617220674C6567656E6424203D2066616C73653B0D0A20207661722067546F6F6C74697024203D2066616C73653B0D0A2020';
wwv_flow_api.g_varchar2_table(7) := '7661722067486173486F6F6B65644576656E7473203D2066616C73653B0D0A20207661722067486F76657265644E6F6465203D2066616C73653B0D0A20207661722067466F63757365644E6F6465203D2066616C73653B0D0A20207661722067466F6375';
wwv_flow_api.g_varchar2_table(8) := '7365644368696C64496478203D20303B0D0A20207661722067466F6375736564446174614E6F6465203D2066616C73653B0D0A2020766172206973466F6375736564203D2066616C73653B0D0A20207661722067526573697A6548616E646C6572426F75';
wwv_flow_api.g_varchar2_table(9) := '6E64203D2066616C73653B0D0A0D0A20207661722067526567696F6E243B202F2F20686F6C64732074686520726567696F6E0D0A202076617220674368617274242020202F2F20686F6C6473207468652063686172740D0A202076617220674172793B0D';
wwv_flow_api.g_varchar2_table(10) := '0A20207661722067436C6173735363616C65203D2064332E7363616C652E6F7264696E616C28292E72616E6765282064332E72616E67652820312C203136202920293B0D0A0D0A202076617220674964507265666978203D202264335F74726565636861';
wwv_flow_api.g_varchar2_table(11) := '72745F223B0D0A20207661722067506C7567696E4964507265666978203D2022636F6D5F6F7261636C655F617065785F64335F223B0D0A20207661722067547265654D756C7469506172656E7473203D205B5D3B0D0A0D0A2020696620282070436F6C6F';
wwv_flow_api.g_varchar2_table(12) := '72732029207B0D0A20202020202076617220636F6C6F725363616C65203D2064332E7363616C652E6F7264696E616C28290D0A202020202020202020202E72616E6765282070436F6C6F72732E73706C69742820273A27202920293B0D0A20207D0D0A20';
wwv_flow_api.g_varchar2_table(13) := '2076617220636F6C6F724163636573736F72203D2066756E6374696F6E286429207B200D0A202020206966202870436F6C6F7273203D3D202744454641554C542729207B0D0A20202020202072657475726E206E756C6C3B0D0A202020207D20656C7365';
wwv_flow_api.g_varchar2_table(14) := '206966202870436F6C6F7273203D3D2027434F4C554D4E2729207B0D0A20202020202072657475726E2028643F642E434F4C4F5256414C55453A6E756C6C293B200D0A202020207D20656C7365207B0D0A20202020202072657475726E20636F6C6F7253';
wwv_flow_api.g_varchar2_table(15) := '63616C65203F20636F6C6F725363616C6528642E434F4C4F5256414C554529203A206E756C6C3B200D0A202020207D0D0A20207D3B0D0A0D0A20202F2F206275696C64204C6567656E64203C2D3E20436F6C6F72206D617070696E670D0A202076617220';
wwv_flow_api.g_varchar2_table(16) := '674C6567656E644D617070696E67203D2066616C73653B0D0A20206966202870436F6C6F7273203D3D2027434F4C554D4E2729207B0D0A20202020747279207B0D0A202020202020674C6567656E644D617070696E67203D204A534F4E2E706172736528';
wwv_flow_api.g_varchar2_table(17) := '70436F6C6F724C6567656E644D617070696E67293B0D0A202020207D20636174636820286529207B636F6E736F6C652E6C6F672865297D0D0A20207D0D0A0D0A202066756E6374696F6E206765744C6567656E64466F72436F6C6F72286329207B0D0A20';
wwv_flow_api.g_varchar2_table(18) := '2020206966202870436F6C6F7273203D3D2027434F4C554D4E2720262620674C6567656E644D617070696E6729207B0D0A20202020202069662028674C6567656E644D617070696E675B632E746F4C6F7765724361736528295D29207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(19) := '20202072657475726E20674C6567656E644D617070696E675B632E746F4C6F7765724361736528295D3B0D0A2020202020207D20656C7365207B0D0A202020202020202072657475726E20633B0D0A2020202020207D0D0A202020207D20656C7365207B';
wwv_flow_api.g_varchar2_table(20) := '0D0A20202020202072657475726E20633B0D0A202020207D0D0A20207D0D0A0D0A202076617220636C6173736669636174696F6E734163636573736F72203D2066756E6374696F6E286429207B2072657475726E20642E434F4C4F5256414C55453B207D';
wwv_flow_api.g_varchar2_table(21) := '3B0D0A0D0A20207661722064436F6E666967203D2022223B0D0A202076617220636F6E666967203D207B0D0A20202020227472647572223A20202020202020202020202020202020202020202020203530302C0D0A20202020226373735F636C6173735F';
wwv_flow_api.g_varchar2_table(22) := '6E6F6465223A202020202020202020202020202022636F6D5F6F7261636C655F617065785F64335F747265655F6E6F6465222C0D0A20202020226373735F636C6173735F6C6561666E6F6465223A2020202020202020202022636F6D5F6F7261636C655F';
wwv_flow_api.g_varchar2_table(23) := '617065785F64335F747265655F6C6561666E6F6465222C0D0A20202020226373735F636C6173735F6C696E6B223A202020202020202020202020202022636F6D5F6F7261636C655F617065785F64335F747265655F6C696E6B222C0D0A20202020226369';
wwv_flow_api.g_varchar2_table(24) := '72636C655F7261646975735F6D696E223A202020202020202020202031302C0D0A2020202022636972636C655F7261646975735F6D6178223A202020202020202020202031302C0D0A20202020226C6567656E645F636F6C756D6E5F7769647468223A20';
wwv_flow_api.g_varchar2_table(25) := '20202020202020203230302C0D0A2020202022726F6F745F6C6162656C223A202020202020202020202020202020202020225472656520726F6F74222C0D0A202020202273686F775F636F6C6C5F6368696C645F636E74223A2020202020202020207472';
wwv_flow_api.g_varchar2_table(26) := '75652C0D0A202020202273686F775F636F6C6C5F6368696C645F74656D706C617465223A2020202022202823434E542329222C0D0A20202020226F66667365745F7363726F6C6C62617273223A202020202020202020202032302C200D0A20202020226D';
wwv_flow_api.g_varchar2_table(27) := '617267696E223A202020202020202020202020202020202020202020207B22746F70223A2032302C20227269676874223A203132302C2022626F74746F6D223A2032302C20226C656674223A203132307D0D0A20207D0D0A0D0A2020747279207B0D0A20';
wwv_flow_api.g_varchar2_table(28) := '20202064436F6E666967203D204A534F4E2E70617273652870436F6E666967293B0D0A20207D20636174636820286529207B0D0A2020202064436F6E666967203D207B7D3B0D0A20207D0D0A0D0A2020666F72202876617220617474726E616D6520696E';
wwv_flow_api.g_varchar2_table(29) := '2064436F6E66696729207B20636F6E6669675B617474726E616D655D203D2064436F6E6669675B617474726E616D655D3B207D0D0A0D0A202066756E6374696F6E2066697265417065784576656E7428652C206429207B0D0A20202020617065782E6576';
wwv_flow_api.g_varchar2_table(30) := '656E742E74726967676572280D0A20202020202024782870526567696F6E4964292C0D0A20202020202067506C7567696E4964507265666978202B20652C200D0A202020202020640D0A20202020293B0D0A20207D0D0A0D0A2066756E6374696F6E2074';
wwv_flow_api.g_varchar2_table(31) := '657874456C6C6970736973286F626A6563742C206429207B0D0A20202069662028642E4C4142454C29207B0D0A2020202020207661722073656C66203D2064332E73656C656374286F626A656374293B0D0A2020202020202020202073656C662E746578';
wwv_flow_api.g_varchar2_table(32) := '7428642E4C4142454C293B0D0A20202020202076617220746578744C656E677468203D2073656C662E6E6F646528292E676574436F6D7075746564546578744C656E67746828292C0D0A2020202020202020202074657874203D2073656C662E74657874';
wwv_flow_api.g_varchar2_table(33) := '28293B0D0A2020202020207768696C652028746578744C656E677468203E202828642E72202A203229202D2032202A20362920262620746578742E6C656E677468203E203029207B0D0A2020202020202020202074657874203D20746578742E736C6963';
wwv_flow_api.g_varchar2_table(34) := '6528302C202D31293B0D0A2020202020202020202073656C662E746578742874657874293B0D0A20202020202020202020746578744C656E677468203D2073656C662E6E6F646528292E676574436F6D7075746564546578744C656E67746828293B0D0A';
wwv_flow_api.g_varchar2_table(35) := '2020202020207D0D0A20202020202069662820746578742E6C656E677468203C20642E4C4142454C2E6C656E67746820290D0A202020202020202072657475726E2074657874202B20272E2E2E273B0D0A202020202020656C73650D0A20202020202020';
wwv_flow_api.g_varchar2_table(36) := '2072657475726E20746578743B0D0A202020207D20656C7365207B0D0A20202020202072657475726E2022223B0D0A202020207D0D0A20207D200D0A0D0A202066756E6374696F6E20676574436972636C65526164697573286E6F646556616C75652920';
wwv_flow_api.g_varchar2_table(37) := '7B0D0A20202020696620286E6F646556616C7565202626202169734E614E287061727365466C6F6174286E6F646556616C7565292929207B0D0A20202020202072657475726E204D6174682E726F756E6428636F6E6669672E636972636C655F72616469';
wwv_flow_api.g_varchar2_table(38) := '75735F6D696E202B20287061727365466C6F6174286E6F646556616C756529202D2076616C75655F6D696E29202A207261646975735F666163746F72293B0D0A202020207D20656C7365207B0D0A20202020202072657475726E20636F6E6669672E6369';
wwv_flow_api.g_varchar2_table(39) := '72636C655F7261646975735F6D696E3B0D0A202020207D0D0A20207D0D0A0D0A202066756E6374696F6E206765744C6162656C286429207B0D0A20202020766172206C4C6162656C203D20642E4C4142454C3B0D0A2020202069662028636F6E6669672E';
wwv_flow_api.g_varchar2_table(40) := '73686F775F636F6C6C5F6368696C645F636E7429207B0D0A20202020202069662028642E5F6368696C6472656E20262620642E5F6368696C6472656E2E6C656E677468203E203029207B0D0A20202020202020206C4C6162656C203D206C4C6162656C20';
wwv_flow_api.g_varchar2_table(41) := '2B20636F6E6669672E73686F775F636F6C6C5F6368696C645F74656D706C6174652E7265706C616365282F23434E54232F2C20642E5F6368696C6472656E2E6C656E677468293B0D0A2020202020207D0D0A202020207D0D0A2020202072657475726E20';
wwv_flow_api.g_varchar2_table(42) := '6C4C6162656C3B0D0A20207D0D0A0D0A202066756E6374696F6E20676574546F6F6C746970436F6E74656E74286429207B0D0A2020202069662028642E494E464F535452494E4729207B0D0A202020202020696620287045736361706548746D6C203D3D';
wwv_flow_api.g_varchar2_table(43) := '202759272920207B0D0A202020202020202072657475726E2064332E73656C65637428646F63756D656E742E637265617465456C656D656E7428226469762229292E7465787428642E494E464F535452494E47292E6E6F646528293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(44) := '7D20656C7365207B0D0A202020202020202072657475726E2064332E73656C65637428646F63756D656E742E637265617465456C656D656E7428226469762229292E68746D6C28642E494E464F535452494E47292E6E6F646528293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(45) := '7D0D0A202020207D20656C7365207B0D0A20202020202072657475726E2022223B0D0A202020207D0D0A20207D0D0A0D0A202066756E6374696F6E206275696C6448696572617263687928704461746129207B0D0A20202020766172206C6F6F6B757020';
wwv_flow_api.g_varchar2_table(46) := '2020203D205B5D3B0D0A20202020766172206C6F6F6B7570322020203D205B5D3B0D0A2020202076617220726F6F746E6F646573203D205B5D3B0D0A0D0A202020207661722073697A656D696E20203D2066616C73653B0D0A202020207661722073697A';
wwv_flow_api.g_varchar2_table(47) := '656D617820203D2066616C73653B0D0A20202020766172206861734C6162656C203D2066616C73653B0D0A090D0A090D0A202020202F2F206275696C64206C6F6F6B75702061727261790D0A20202020666F72202876617220693D303B693C7044617461';
wwv_flow_api.g_varchar2_table(48) := '2E726F772E6C656E6774683B20692B2B29207B0D0A2020202020206C6F6F6B75705B224C4F222B70446174612E726F775B695D2E49445D203D20693B0D0A2020202020206966202870446174612E726F775B695D2E4C4142454C29207B6861734C616265';
wwv_flow_api.g_varchar2_table(49) := '6C203D20747275653B7D0D0A2020202020206966202870446174612E726F775B695D2E53495A4556414C554529207B0D0A2020202020202020696620282173697A656D696E207C7C207061727365466C6F61742870446174612E726F775B695D2E53495A';
wwv_flow_api.g_varchar2_table(50) := '4556414C554529203C2073697A656D696E29207B0D0A2020202020202020202073697A656D696E203D207061727365466C6F61742870446174612E726F775B695D2E53495A4556414C5545293B0D0A20202020202020207D0D0A20202020202020206966';
wwv_flow_api.g_varchar2_table(51) := '20282173697A656D6178207C7C207061727365466C6F61742870446174612E726F775B695D2E53495A4556414C554529203E2073697A656D617829207B0D0A2020202020202020202073697A656D6178203D207061727365466C6F61742870446174612E';
wwv_flow_api.g_varchar2_table(52) := '726F775B695D2E53495A4556414C5545293B0D0A20202020202020207D0D0A2020202020207D0D0A202020207D0D0A202020207261646975735F666163746F72203D2028636F6E6669672E636972636C655F7261646975735F6D6178202D20636F6E6669';
wwv_flow_api.g_varchar2_table(53) := '672E636972636C655F7261646975735F6D696E29202F20282873697A656D6178202D2073697A656D696E3D3D303F313A73697A656D61782D73697A656D696E29293B0D0A2020202076616C75655F6D696E203D2073697A656D696E3B0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(54) := '766172206E6577526F6F74203D207B0D0A20202020202022504152454E545F4944223A202022706172656E745F22202B2067506C7567696E4964507265666978202B2022747265655F6E6F64655F696430313233343536373839222C0D0A202020202020';
wwv_flow_api.g_varchar2_table(55) := '224944223A20202020202020202067506C7567696E4964507265666978202B2022747265655F6E6F64655F696430313233343536373839222C0D0A2020202020202253495A4556414C5545223A202066616C73652C0D0A20202020202022434F4C4F5256';
wwv_flow_api.g_varchar2_table(56) := '414C5545223A2022222C0D0A202020202020224445505448223A202020202020302C0D0A202020202020224C4142454C223A2020202020206861734C6162656C3F636F6E6669672E726F6F745F6C6162656C3A22220D0A202020207D3B0D0A0D0A202020';
wwv_flow_api.g_varchar2_table(57) := '202F2F2064657465637420726F6F74206E6F6465730D0A20202020666F72202876617220693D303B693C70446174612E726F772E6C656E6774683B20692B2B29207B0D0A09202069662028636865636B4966506172656E74497341727261792820704461';
wwv_flow_api.g_varchar2_table(58) := '74612E726F775B695D2E504152454E545F4944202929207B0D0A09092020766172206C5F696E3D66616C73653B0D0A09092020666F7228766172206A3D303B206A3C70446174612E726F775B695D2E504152454E545F49442E6C656E6774683B206A2B2B';
wwv_flow_api.g_varchar2_table(59) := '29207B0D0A0909092020696620282128224C4F222B70446174612E726F775B695D2E504152454E545F49445B6A5D20696E206C6F6F6B757029207C7C202870446174612E726F775B695D2E4944203D3D2070446174612E726F775B695D2E504152454E54';
wwv_flow_api.g_varchar2_table(60) := '5F49445B6A5D29290D0A0909090920206C5F696E203D20747275653B0D0A090920207D0D0A09092020696620286C5F696E29200D0A090909726F6F746E6F6465732E707573682870446174612E726F775B695D293B0D0A0920207D0D0A092020656C7365';
wwv_flow_api.g_varchar2_table(61) := '207B0D0A09092020696620282128224C4F222B70446174612E726F775B695D2E504152454E545F494420696E206C6F6F6B757029207C7C202870446174612E726F775B695D2E4944203D3D2070446174612E726F775B695D2E504152454E545F49442929';
wwv_flow_api.g_varchar2_table(62) := '207B0D0A090909726F6F746E6F6465732E707573682870446174612E726F775B695D293B0D0A090920207D0D0A0920207D0D0A202020207D0D0A090D0A0966756E6374696F6E20636865636B4966506172656E7449734172726179286974656D29207B0D';
wwv_flow_api.g_varchar2_table(63) := '0A090972657475726E204F626A6563742E70726F746F747970652E746F537472696E672E63616C6C28206974656D2029203D3D3D20275B6F626A6563742041727261795D273B0D0A097D0D0A0D0A202020202F2F20696E73657274206172746966696361';
wwv_flow_api.g_varchar2_table(64) := '6C20726F6F740D0A2020202070446174612E726F772E70757368286E6577526F6F74293B0D0A202020206C6F6F6B75705B224C4F22202B2067506C7567696E4964507265666978202B2022747265655F6E6F64655F696430313233343536373839225D20';
wwv_flow_api.g_varchar2_table(65) := '3D2070446174612E726F772E6C656E677468202D20313B0D0A0D0A20202020666F72202876617220723D303B723C726F6F746E6F6465732E6C656E6774683B722B2B29207B0D0A0909726F6F746E6F6465735B725D2E504152454E545F4944203D202067';
wwv_flow_api.g_varchar2_table(66) := '506C7567696E4964507265666978202B22747265655F6E6F64655F696430313233343536373839223B0D0A202020207D0D0A090D0A0D0A20202020666F72202876617220693D303B693C70446174612E726F772E6C656E6774683B20692B2B29207B0D0A';
wwv_flow_api.g_varchar2_table(67) := '09202069662028636865636B4966506172656E7449734172726179282070446174612E726F775B695D2E504152454E545F4944202929207B0D0A09092020666F7228766172206A3D303B206A3C70446174612E726F775B695D2E504152454E545F49442E';
wwv_flow_api.g_varchar2_table(68) := '6C656E6774683B206A2B2B29207B0D0A0909092020696620282128224C4F222B70446174612E726F775B695D2E504152454E545F49445B6A5D20696E206C6F6F6B7570322929207B200D0A090909096C6F6F6B7570325B224C4F222B70446174612E726F';
wwv_flow_api.g_varchar2_table(69) := '775B695D2E504152454E545F49445B6A5D5D203D205B5D3B0D0A09090920207D0D0A09090920206C6F6F6B7570325B224C4F222B70446174612E726F775B695D2E504152454E545F49445B6A5D5D2E707573682870446174612E726F775B695D2E494429';
wwv_flow_api.g_varchar2_table(70) := '3B200920200D0A090920207D090920200D0A0920207D0D0A092020656C7365207B0D0A09092020696620282128224C4F222B70446174612E726F775B695D2E504152454E545F494420696E206C6F6F6B7570322929207B200D0A0909096C6F6F6B757032';
wwv_flow_api.g_varchar2_table(71) := '5B224C4F222B70446174612E726F775B695D2E504152454E545F49445D203D205B5D3B0D0A090920207D0D0A090920206C6F6F6B7570325B224C4F222B70446174612E726F775B695D2E504152454E545F49445D2E707573682870446174612E726F775B';
wwv_flow_api.g_varchar2_table(72) := '695D2E4944293B200D0A0920207D0D0A202020207D0D0A0D0A2020202066756E6374696F6E206275696C644869657261726368795F636F72652870446174612C2070526F6F74506172656E7449642C2070446570746829207B0D0A202020202020766172';
wwv_flow_api.g_varchar2_table(73) := '20746172676574203D205B5D3B0D0A202020202020766172206C726F772C2069783B0D0A20202020202069662028224C4F222B70526F6F74506172656E74496420696E206C6F6F6B75703229207B0D0A2020202020202020666F72202876617220693D30';
wwv_flow_api.g_varchar2_table(74) := '3B693C6C6F6F6B7570325B224C4F222B70526F6F74506172656E7449645D2E6C656E6774683B20692B2B29207B0D0A202020202020202020206C726F77203D207B7D3B0D0A202020202020202020206978203D206C6F6F6B75705B224C4F222B6C6F6F6B';
wwv_flow_api.g_varchar2_table(75) := '7570325B224C4F222B70526F6F74506172656E7449645D5B695D5D3B0D0A0D0A202020202020202020206C726F772E49442020202020202020203D2070446174612E726F775B69785D2E49443B0D0A090920206C726F772E4348494C445F504152454E54';
wwv_flow_api.g_varchar2_table(76) := '3D2070446174612E726F775B69785D2E49442B225F222B70526F6F74506172656E7449643B0D0A202020202020202020206C726F772E53495A4556414C554520203D2070446174612E726F775B69785D2E53495A4556414C55453B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(77) := '2020206C726F772E44455054482020202020203D207044657074682C0D0A202020202020202020206C726F772E434F4C4F5256414C5545203D2070446174612E726F775B69785D2E434F4C4F5256414C55453B0D0A202020202020202020206C726F772E';
wwv_flow_api.g_varchar2_table(78) := '4C4142454C2020202020203D2070446174612E726F775B69785D2E4C4142454C3B0D0A202020202020202020206C726F772E494E464F535452494E47203D2070446174612E726F775B69785D2E494E464F535452494E473B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(79) := '6C726F772E4C494E4B202020202020203D2070446174612E726F775B69785D2E4C494E4B3B0D0A202020202020202020206C726F772E524F574E554D20202020203D2069783B0D0A202020202020202020206C726F772E6368696C6472656E203D206275';
wwv_flow_api.g_varchar2_table(80) := '696C644869657261726368795F636F72652870446174612C2070446174612E726F775B69785D2E49442C20704465707468202B2031293B20202020200D0A20202020202020202020696620286C726F772E6368696C6472656E2E6C656E677468203D3D20';
wwv_flow_api.g_varchar2_table(81) := '3029207B0D0A2020202020202020202020206C726F772E6368696C6472656E203D2066616C73653B0D0A202020202020202020207D0D0A202020202020202020207461726765742E70757368286C726F77293B0D0A20202020202020207D0D0A20202020';
wwv_flow_api.g_varchar2_table(82) := '20207D0D0A20202020202072657475726E207461726765743B0D0A202020207D0D0A2020202072657475726E206275696C644869657261726368795F636F72652870446174612C2022706172656E745F22202B2067506C7567696E496450726566697820';
wwv_flow_api.g_varchar2_table(83) := '2B2022747265655F6E6F64655F696430313233343536373839222C2030293B0D0A20207D0D0A0D0A0D0A202066756E6374696F6E205F7265636F6D6D656E6465644865696768742829207B0D0A20202020766172206D696E4152203D20704D696E41523B';
wwv_flow_api.g_varchar2_table(84) := '0D0A20202020766172206D61784152203D20704D617841523B0D0A202020207661722077203D20674368617274242E776964746828293B0D0A202020207661722068203D2028674368617274242E6865696768742829203D3D3D203029203F2028772F6D';
wwv_flow_api.g_varchar2_table(85) := '6178415229203A20674368617274242E68656967687428293B0D0A20202020766172206172203D20772F683B0D0A20202020696620286172203C206D696E415229207B0D0A202020202020202068203D20772F6D61784152202B20313B0D0A202020207D';
wwv_flow_api.g_varchar2_table(86) := '20656C736520696620286172203E206D6178415229207B0D0A202020202020202068203D20772F6D696E4152202D20313B0D0A202020207D0D0A2020202072657475726E204D6174682E6D617828704D696E4865696768742C204D6174682E6D696E2870';
wwv_flow_api.g_varchar2_table(87) := '4D61784865696768742C206829293B0D0A20207D0D0A0D0A2020526567696F6E24203D202428222322202B2070526567696F6E4964293B0D0A202067436861727424203D202428222322202B20674964507265666978202B2070526567696F6E4964293B';
wwv_flow_api.g_varchar2_table(88) := '200D0A0D0A20206966202864332E73656C656374416C6C28222322202B20674964507265666978202B2070526567696F6E4964292E73697A65282920213D203129207B0D0A20202020636F6E736F6C652E6C6F6728225741524E494E473A22293B0D0A20';
wwv_flow_api.g_varchar2_table(89) := '202020636F6E736F6C652E6C6F6728222A2A2A2A2A2A2A2A22293B0D0A20202020636F6E736F6C652E6C6F6728224449562049442022202B20674964507265666978202B2070526567696F6E4964202B2022206F63637572732022202B2064332E73656C';
wwv_flow_api.g_varchar2_table(90) := '656374416C6C28222322202B20674964507265666978202B2070526567696F6E4964292E73697A652829202B20222074696D65732122293B0D0A20202020636F6E736F6C652E6C6F6728224368617274206D6179206E6F7420646973706C617920636F72';
wwv_flow_api.g_varchar2_table(91) := '726563746C7922293B0D0A20202020636F6E736F6C652E6C6F672822436865636B205354415449432049442076616C756573206F6620796F757220636861727420726567696F6E7322293B0D0A20207D0D0A0D0A202076617220646961676F6E616C203D';
wwv_flow_api.g_varchar2_table(92) := '2064332E7376672E646961676F6E616C28292E70726F6A656374696F6E2866756E6374696F6E286429207B2072657475726E205B642E792C20642E785D3B207D293B0D0A20200D0A2020766172207769647468203D20674368617274242E776964746828';
wwv_flow_api.g_varchar2_table(93) := '29202D20636F6E6669672E6D617267696E2E6C656674202D20636F6E6669672E6D617267696E2E72696768743B0D0A202076617220686569676874203D205F7265636F6D6D656E6465644865696768742829202D20636F6E6669672E6D617267696E2E74';
wwv_flow_api.g_varchar2_table(94) := '6F70202D20636F6E6669672E6D617267696E2E626F74746F6D3B0D0A2020766172206D61785769647468203D20303B0D0A0D0A0D0A2020766172207061636B203D2064332E6C61796F75742E7472656528290D0A202020202E73697A65285B2068656967';
wwv_flow_api.g_varchar2_table(95) := '68742C2077696474685D2920200D0A202020202E736F72742866756E6374696F6E2028612C6229207B72657475726E20622E524F574E554D202D20612E524F574E554D3B7D292020200D0A202020202E76616C75652866756E6374696F6E286429207B20';
wwv_flow_api.g_varchar2_table(96) := '72657475726E20642E53495A4556414C55453B207D290D0A20203B0D0A0D0A202076617220737667203D2064332E73656C656374416C6C2867436861727424292E617070656E64282273766722290D0A202020202E6174747228227769647468222C2077';
wwv_flow_api.g_varchar2_table(97) := '69647468202B20636F6E6669672E6D617267696E2E6C656674202B20636F6E6669672E6D617267696E2E7269676874202D20636F6E6669672E6F66667365745F7363726F6C6C62617273290D0A202020202E617474722822686569676874222C20686569';
wwv_flow_api.g_varchar2_table(98) := '676874202B20636F6E6669672E6D617267696E2E746F70202B20636F6E6669672E6D617267696E2E626F74746F6D202D20636F6E6669672E6F66667365745F7363726F6C6C62617273290D0A20203B0D0A20207661722073766767203D207376672E6170';
wwv_flow_api.g_varchar2_table(99) := '70656E6428226722290D0A202020202E6174747228227472616E73666F726D222C20227472616E736C6174652822202B20636F6E6669672E6D617267696E2E6C656674202B20222C22202B20636F6E6669672E6D617267696E2E746F70202B2022292229';
wwv_flow_api.g_varchar2_table(100) := '0D0A20203B0D0A0D0A202066756E6374696F6E205F726573697A6546756E6374696F6E2829207B0D0A202020207769647468203D20674368617274242E77696474682829202D20636F6E6669672E6D617267696E2E6C656674202D20636F6E6669672E6D';
wwv_flow_api.g_varchar2_table(101) := '617267696E2E72696768743B0D0A20202020686569676874203D205F7265636F6D6D656E6465644865696768742829202D20636F6E6669672E6D617267696E2E746F70202D20636F6E6669672E6D617267696E2E626F74746F6D3B0D0A20202020706163';
wwv_flow_api.g_varchar2_table(102) := '6B2E73697A65285B206865696768742C2077696474685D293B0D0A0D0A202020207376672E617474722822686569676874222C20686569676874202B20636F6E6669672E6D617267696E2E746F70202B20636F6E6669672E6D617267696E2E626F74746F';
wwv_flow_api.g_varchar2_table(103) := '6D202D20636F6E6669672E6F66667365745F7363726F6C6C62617273290D0A202020207376672E6174747228227769647468222C207769647468202B20636F6E6669672E6D617267696E2E6C656674202B20636F6E6669672E6D617267696E2E72696768';
wwv_flow_api.g_varchar2_table(104) := '74202D20636F6E6669672E6F66667365745F7363726F6C6C62617273290D0A20202020757064617465436861727428617065785F646174615F6A736F6E293B0D0A090D0A0D0A20207D0D0A0D0A20202F2F20746869732066756E6374696F6E2069732062';
wwv_flow_api.g_varchar2_table(105) := '65696E672063616C6C65642075706F6E2064617461207265667265736820616E640D0A20202F2F206974206D61696E7461696E73207468652022636F6C6C61707365642F756E636F6C6C617073656422207374617465206F662065616368206E6F64652E';
wwv_flow_api.g_varchar2_table(106) := '0D0A0D0A202066756E6374696F6E20636F7079436F6C6C6170736564537461746528732C20642C2064656661756C74436F6C6C617073656429207B0D0A20202020642E5F68696464656E20203D205B5D3B0D0A20202020642E5F76697369626C65203D20';
wwv_flow_api.g_varchar2_table(107) := '5B5D3B0D0A0D0A2020202069662028642E4944203D3D2067466F6375736564446174614E6F64652E494429207B67466F6375736564446174614E6F6465203D20643B2067466F6375736564446174614E6F64652E7374616C65203D2066616C73653B207D';
wwv_flow_api.g_varchar2_table(108) := '200D0A0D0A20202020666F722028766172206364783D303B20636478203C20642E6368696C6472656E2E6C656E6774683B206364782B2B29207B0D0A2020202020207661722063757272656E74444368696C64203D20642E6368696C6472656E5B636478';
wwv_flow_api.g_varchar2_table(109) := '5D3B0D0A2020202020207661722063757272656E74534368696C64203D2066616C73653B0D0A202020202020696620287329207B20200D0A202020202020202069662028732E5F6368696C6472656E29207B0D0A20202020202020202020666F72202876';
wwv_flow_api.g_varchar2_table(110) := '6172206373783D303B20637378203C20732E5F6368696C6472656E2E6C656E6774683B206373782B2B29207B0D0A20202020202020202020202069662028732E5F6368696C6472656E5B6373785D2E4944203D3D2063757272656E74444368696C642E49';
wwv_flow_api.g_varchar2_table(111) := '4429207B0D0A2020202020202020202020202020642E5F68696464656E2E707573682863757272656E74444368696C64293B0D0A202020202020202020202020202063757272656E74534368696C64203D20732E5F6368696C6472656E5B6373785D3B0D';
wwv_flow_api.g_varchar2_table(112) := '0A2020202020202020202020202020627265616B3B0D0A2020202020202020202020207D20200D0A202020202020202020207D0D0A20202020202020207D20200D0A202020202020202069662028732E6368696C6472656E29207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(113) := '202020666F722028766172206373783D303B20637378203C20732E6368696C6472656E2E6C656E6774683B206373782B2B29207B0D0A20202020202020202020202069662028732E6368696C6472656E5B6373785D2E4944203D3D2063757272656E7444';
wwv_flow_api.g_varchar2_table(114) := '4368696C642E494429207B0D0A2020202020202020202020202020642E5F76697369626C652E707573682863757272656E74444368696C64293B0D0A202020202020202020202020202063757272656E74534368696C64203D20732E6368696C6472656E';
wwv_flow_api.g_varchar2_table(115) := '5B6373785D3B0D0A2020202020202020202020202020627265616B3B0D0A2020202020202020202020207D200D0A202020202020202020207D20200D0A20202020202020207D20200D0A2020202020207D0D0A2020202020206966202863757272656E74';
wwv_flow_api.g_varchar2_table(116) := '534368696C6429207B0D0A2020202020202020636F7079436F6C6C617073656453746174652863757272656E74534368696C642C2063757272656E74444368696C642C2064656661756C74436F6C6C6170736564293B0D0A2020202020207D20656C7365';
wwv_flow_api.g_varchar2_table(117) := '207B0D0A20202020202020206966202864656661756C74436F6C6C617073656429207B0D0A2020202020202020202069662028642E5F76697369626C652E6C656E677468203D3D203029207B0D0A202020202020202020202020642E5F68696464656E2E';
wwv_flow_api.g_varchar2_table(118) := '707573682863757272656E74444368696C64293B0D0A202020202020202020207D20656C7365207B0D0A202020202020202020202020642E5F76697369626C652E707573682863757272656E74444368696C64293B0D0A202020202020202020207D0D0A';
wwv_flow_api.g_varchar2_table(119) := '20202020202020207D20656C7365207B0D0A2020202020202020202069662028642E5F76697369626C652E6C656E677468203D3D203020262620642E5F68696464656E2E6C656E677468203E203029207B0D0A202020202020202020202020642E5F6869';
wwv_flow_api.g_varchar2_table(120) := '6464656E2E707573682863757272656E74444368696C64293B0D0A202020202020202020207D20656C7365207B0D0A202020202020202020202020642E5F76697369626C652E707573682863757272656E74444368696C64293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(121) := '20207D0D0A20202020202020207D0D0A2020202020202020636F7079436F6C6C617073656453746174652866616C73652C2063757272656E74444368696C642C2064656661756C74436F6C6C6170736564293B0D0A2020202020207D0D0A202020207D0D';
wwv_flow_api.g_varchar2_table(122) := '0A2020202069662028642E5F68696464656E2E6C656E677468203E2030207C7C20642E5F76697369626C652E6C656E677468203E203029207B0D0A202020202020642E5F6368696C6472656E203D20642E5F68696464656E3B0D0A202020202020642E63';
wwv_flow_api.g_varchar2_table(123) := '68696C6472656E203D20642E5F76697369626C653B0D0A202020207D20656C7365207B0D0A202020202020642E5F6368696C6472656E203D2066616C73653B0D0A202020202020642E6368696C6472656E203D2066616C73653B0D0A202020207D0D0A20';
wwv_flow_api.g_varchar2_table(124) := '207D0D0A0D0A202066756E6374696F6E20636F6C6C61707365416C6C286429207B0D0A2020202069662028642E6368696C6472656E29207B0D0A2020202020206966202821642E5F6368696C6472656E29207B0D0A2020202020202020642E5F6368696C';
wwv_flow_api.g_varchar2_table(125) := '6472656E203D20642E6368696C6472656E3B0D0A2020202020207D20656C7365207B0D0A2020202020202020642E5F6368696C6472656E2E707573682E6170706C7928642E5F6368696C6472656E2C20642E6368696C6472656E293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(126) := '7D0D0A202020202020642E6368696C6472656E203D2066616C73653B0D0A202020207D0D0A2020202069662028642E5F6368696C6472656E29207B0D0A202020202020642E5F6368696C6472656E2E666F724561636828636F6C6C61707365416C6C293B';
wwv_flow_api.g_varchar2_table(127) := '0D0A202020207D0D0A20207D0D0A0D0A202066756E6374696F6E20657870616E64416C6C286429207B0D0A2020202069662028642E5F6368696C6472656E29207B0D0A2020202020206966202821642E6368696C6472656E29207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(128) := '20642E6368696C6472656E203D20642E5F6368696C6472656E3B0D0A2020202020207D20656C7365207B0D0A2020202020202020642E6368696C6472656E2E707573682E6170706C7928642E6368696C6472656E2C20642E5F6368696C6472656E293B0D';
wwv_flow_api.g_varchar2_table(129) := '0A2020202020207D0D0A202020202020642E5F6368696C6472656E203D2066616C73653B0D0A202020207D0D0A2020202069662028642E6368696C6472656E29207B0D0A202020202020642E6368696C6472656E2E666F724561636828657870616E6441';
wwv_flow_api.g_varchar2_table(130) := '6C6C293B0D0A202020207D0D0A20207D0D0A0D0A202066756E6374696F6E20676574446174612866436F6E74696E7565546865726529207B0D0A20202020617065782E6576656E742E74726967676572280D0A20202020202024782870526567696F6E49';
wwv_flow_api.g_varchar2_table(131) := '64292C0D0A20202020202022617065786265666F72657265667265736822200D0A20202020293B0D0A0D0A20202020617065782E7365727665722E706C7567696E280D0A20202020202070416A617849642C0D0A2020202020207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(132) := '20705F64656275673A202476282770646562756727292C0D0A2020202020202020706167654974656D733A2070506167654974656D735375626D69742E73706C697428222C22290D0A2020202020207D2C2020200D0A2020202020207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(133) := '202020737563636573733A2066436F6E74696E756554686572652C0D0A20202020202020206572726F723A2066756E6374696F6E20286429207B636F6E736F6C652E6C6F6728642E726573706F6E736554657874293B207D2C0D0A202020202020202064';
wwv_flow_api.g_varchar2_table(134) := '617461547970653A20226A736F6E220D0A2020202020207D0D0A20202020293B0D0A20207D0D0A0D0A202066756E6374696F6E2072656672657368446174612864336A736F6E2C2070436F6C6C617073652C20705265667265736829207B0D0A20202020';
wwv_flow_api.g_varchar2_table(135) := '6966202821674C6567656E642429207B200D0A202020202020674C6567656E6424203D20242820646F63756D656E742E637265617465456C656D656E7428202764697627202920293B0D0A0D0A2020202020206966202820704C6567656E64506F736974';
wwv_flow_api.g_varchar2_table(136) := '696F6E203D3D2027544F50272029207B0D0A20202020202020202020674368617274242E6265666F72652820674C6567656E642420293B0D0A2020202020207D20656C7365207B0D0A20202020202020202020674368617274242E61667465722820674C';
wwv_flow_api.g_varchar2_table(137) := '6567656E642420293B0D0A2020202020207D0D0A202020207D0D0A0D0A20202020696620282167546F6F6C7469702429207B200D0A2020202020202020202067546F6F6C74697024203D20242820646F63756D656E742E637265617465456C656D656E74';
wwv_flow_api.g_varchar2_table(138) := '28202764697627202920290D0A20202020202020202020202020202E616464436C617373282027612D44335472656543686172742D746F6F6C74697020612D4433546F6F6C7469702720290D0A20202020202020202020202020202E617070656E64546F';
wwv_flow_api.g_varchar2_table(139) := '28206743686172742420290D0A20202020202020202020202020202E6869646528293B0D0A202020207D0D0A0D0A202020206966202864336A736F6E2E726F772E6C656E677468203D3D203029207B0D0A202020202020617065785F646174615F6A736F';
wwv_flow_api.g_varchar2_table(140) := '6E203D207B7D3B0D0A20202020202064332E73656C656374416C6C28226722292E72656D6F766528293B0D0A20202020202073766767203D207376672E617070656E6428226722290D0A202020202020202E6174747228227472616E73666F726D222C20';
wwv_flow_api.g_varchar2_table(141) := '227472616E736C6174652822202B20636F6E6669672E6D617267696E2E6C656674202B20222C22202B20636F6E6669672E6D617267696E2E746F70202B20222922290D0A2020202020203B0D0A2020202020207376672E617070656E6428226722290D0A';
wwv_flow_api.g_varchar2_table(142) := '20202020202020202E6174747228226964222C20674964507265666978202B2070526567696F6E4964202B20225F6E6F64617461666F756E646D736722290D0A20202020202020202E6174747228227472616E73666F726D222C20227472616E736C6174';
wwv_flow_api.g_varchar2_table(143) := '652831302C32302922290D0A20202020202020202E617070656E6428227465787422290D0A20202020202020202E7465787428704E6F44617461466F756E644D7367293B0D0A20202020202072657475726E3B0D0A202020207D20656C7365207B0D0A20';
wwv_flow_api.g_varchar2_table(144) := '202020202064332E73656C656374416C6C28222322202B20674964507265666978202B2070526567696F6E4964202B20225F6E6F64617461666F756E646D736722292E72656D6F766528293B0D0A202020207D0D0A2020200D0A0D0A2020202076617220';
wwv_flow_api.g_varchar2_table(145) := '6E65775F617065785F646174615F6A736F6E203D206275696C644869657261726368792864336A736F6E295B305D3B0D0A2F2F09636F6E736F6C652E6C6F6728226E65775F617065785F646174615F6A736F6E20697322293B0D0A2F2F09636F6E736F6C';
wwv_flow_api.g_varchar2_table(146) := '652E6C6F67284A534F4E2E737472696E67696679286E65775F617065785F646174615F6A736F6E2C6E756C6C2C203229293B0D0A0D0A20202020696620286E65775F617065785F646174615F6A736F6E2E6368696C6472656E29207B200D0A2020202020';
wwv_flow_api.g_varchar2_table(147) := '20696620286E65775F617065785F646174615F6A736F6E2E6368696C6472656E2E6C656E677468203D3D203129207B0D0A20202020202020206E65775F617065785F646174615F6A736F6E203D206E65775F617065785F646174615F6A736F6E2E636869';
wwv_flow_api.g_varchar2_table(148) := '6C6472656E5B305D3B0D0A2020202020207D0D0A202020207D0D0A2020202069662028705265667265736829207B0D0A2020202020206966202867466F6375736564446174614E6F646529207B67466F6375736564446174614E6F64652E7374616C6520';
wwv_flow_api.g_varchar2_table(149) := '3D20747275653B7D0D0A202020202020636F7079436F6C6C6170736564537461746528617065785F646174615F6A736F6E2C206E65775F617065785F646174615F6A736F6E2C2070436F6C6C61707365293B0D0A2020202020206966202867466F637573';
wwv_flow_api.g_varchar2_table(150) := '6564446174614E6F64652E7374616C6529207B67466F6375736564446174614E6F6465203D2066616C73653B7D0D0A200D0A202020202020617065785F646174615F6A736F6E203D206E65775F617065785F646174615F6A736F6E3B0D0A202020207D20';
wwv_flow_api.g_varchar2_table(151) := '656C7365207B0D0A202020202020617065785F646174615F6A736F6E203D206E65775F617065785F646174615F6A736F6E3B0D0A2020202020206966202870436F6C6C6170736529207B0D0A2020202020202020617065785F646174615F6A736F6E2E63';
wwv_flow_api.g_varchar2_table(152) := '68696C6472656E2E666F724561636828636F6C6C61707365416C6C293B0D0A2020202020207D0D0A202020207D0D0A202020200D0A20202020617065785F646174615F6A736F6E2E69735F726F6F74203D20747275653B0D0A20202020617065785F6461';
wwv_flow_api.g_varchar2_table(153) := '74615F6A736F6E2E7830203D20686569676874202F20323B0D0A20202020617065785F646174615F6A736F6E2E7930203D20303B0D0A0D0A09757064617465436861727428617065785F646174615F6A736F6E293B0D0A20207D202020200D0A20200D0A';
wwv_flow_api.g_varchar2_table(154) := '202066756E6374696F6E206765744E6F646566726F6D54726565286C6973742C20696E5F696429207B0D0A090972657475726E206C6973742E726F772E66696C7465722866756E6374696F6E286429207B0D0A2020202020202020202020207265747572';
wwv_flow_api.g_varchar2_table(155) := '6E20645B274944275D203D3D3D20696E5F69643B0D0A20202020202020207D295B305D3B0D0A097D20200D0A0D0A202066756E6374696F6E2061646A75737453766757696474682877696474684E656564656429207B0D0A202020206966202877696474';
wwv_flow_api.g_varchar2_table(156) := '684E6565646564203E3D206D6178576964746829207B0D0A2020202020206D61785769647468203D2077696474684E65656465643B0D0A202020207D0D0A2F2A0D0A202020206966202877696474684E6565646564203E3D20776964746829207B0D0A20';
wwv_flow_api.g_varchar2_table(157) := '20202020207769647468203D2077696474684E65656465643B0D0A2020202020207376672E6174747228227769647468222C207769647468202B20636F6E6669672E6D617267696E2E6C656674202B20636F6E6669672E6D617267696E2E726967687429';
wwv_flow_api.g_varchar2_table(158) := '3B0D0A202020207D0D0A2A2F0D0A20207D0D0A0D0A202066756E6374696F6E20757064617465436861727428736F7572636529207B0D0A202020206D61785769647468203D20303B0D0A0D0A202020202F2F206576656E74730D0A2020202066756E6374';
wwv_flow_api.g_varchar2_table(159) := '696F6E20676574437373436C61737328642C20686967686C6967687429207B0D0A202020202020766172206C436C617373203D20686967686C696768743F704E6F6465486967686C69676874436C6173733A704E6F6465436C6173733B0D0A0D0A202020';
wwv_flow_api.g_varchar2_table(160) := '20202069662028642E6368696C6472656E7C7C642E5F6368696C6472656E29207B0D0A202020202020202072657475726E20636F6E6669672E6373735F636C6173735F6E6F6465202B20286C436C617373203D3D2022223F22223A2220222B6C436C6173';
wwv_flow_api.g_varchar2_table(161) := '73293B0D0A2020202020207D20656C7365207B0D0A202020202020202072657475726E20636F6E6669672E6373735F636C6173735F6E6F6465202B20222022202B20636F6E6669672E6373735F636C6173735F6C6561666E6F6465202B20286C436C6173';
wwv_flow_api.g_varchar2_table(162) := '73203D3D2022223F22223A2220222B6C436C617373293B0D0A2020202020207D0D0A202020207D0D0A0D0A2020202066756E6374696F6E20736574466F637573546F4E6F6465286429207B0D0A2020202020206966202867466F6375736564446174614E';
wwv_flow_api.g_varchar2_table(163) := '6F646529207B0D0A202020202020202067466F6375736564446174614E6F6465203D20643B0D0A20202020202020206966202867466F6375736564446174614E6F64652E706172656E7429207B0D0A20202020202020202020666F722028766172207069';
wwv_flow_api.g_varchar2_table(164) := '783D303B706978203C2067466F6375736564446174614E6F64652E706172656E742E6368696C6472656E2E6C656E6774683B207069782B2B29207B0D0A2020202020202020202020206966202867466F6375736564446174614E6F64652E706172656E74';
wwv_flow_api.g_varchar2_table(165) := '2E6368696C6472656E5B7069785D2E4944203D3D2067466F6375736564446174614E6F64652E494429207B0D0A202020202020202020202020202067466F63757365644368696C64496478203D207069783B0D0A20202020202020202020202020206272';
wwv_flow_api.g_varchar2_table(166) := '65616B3B0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A20202020202020207D20656C7365207B0D0A2020202020202020202067466F63757365644368696C64496478203D20303B0D0A20202020202020207D0D0A20202020';
wwv_flow_api.g_varchar2_table(167) := '2020202067466F63757365644E6F6465203D202428272327202B20674964507265666978202B2070526567696F6E4964202B20275F27202B2067466F6375736564446174614E6F64652E494420292E666972737428292E666F63757328293B0D0A202020';
wwv_flow_api.g_varchar2_table(168) := '2020207D0D0A202020207D0D0A0D0A2020202066756E6374696F6E2070726F636573734576656E745F546F756368286429207B0D0A20202020202066697265417065784576656E742822746F756368656E64222C2064293B0D0A202020202020746F6767';
wwv_flow_api.g_varchar2_table(169) := '6C654E6F6465436F6C6C61707365642864293B0D0A202020202020736574466F637573546F4E6F64652864293B0D0A20202020202072657475726E2066616C73653B0D0A202020207D0D0A0D0A2020202066756E6374696F6E2070726F63657373457665';
wwv_flow_api.g_varchar2_table(170) := '6E745F436C69636B286429207B0D0A20202020202066697265417065784576656E742822636C69636B222C2064293B0D0A202020202020746F67676C654E6F6465436F6C6C61707365642864293B0D0A202020202020736574466F637573546F4E6F6465';
wwv_flow_api.g_varchar2_table(171) := '2864293B0D0A20202020202072657475726E2066616C73653B0D0A202020207D0D0A0D0A2020202066756E6374696F6E2070726F636573734576656E745F6C696E6B436C69636B286429207B0D0A20202020202069662028642E4C494E4B29207B0D0A20';
wwv_flow_api.g_varchar2_table(172) := '202020202020207661722077696E203D20617065782E6E617669676174696F6E2E726564697265637428642E4C494E4B293B0D0A202020202020202077696E2E666F63757328293B0D0A2020202020207D0D0A202020207D0D0A090D0A0D0A0D0A202020';
wwv_flow_api.g_varchar2_table(173) := '2066756E6374696F6E20746F67676C654E6F6465436F6C6C6170736564286429207B0D0A092020666F722876617220693D303B20693C6E6F6465732E6C656E6774683B20692B2B29207B0D0A090909696620286E6F6465735B695D2E4944203D3D20642E';
wwv_flow_api.g_varchar2_table(174) := '494429207B0D0A09090909696620286E6F6465735B695D2E6368696C6472656E29207B0D0A09090909096E6F6465735B695D2E5F6368696C6472656E203D206E6F6465735B695D2E6368696C6472656E3B0D0A09090909096E6F6465735B695D2E636869';
wwv_flow_api.g_varchar2_table(175) := '6C6472656E203D2066616C73653B0D0A090909097D200D0A09090909656C7365207B0D0A09090909096E6F6465735B695D2E6368696C6472656E203D206E6F6465735B695D2E5F6368696C6472656E3B0D0A09090909096E6F6465735B695D2E5F636869';
wwv_flow_api.g_varchar2_table(176) := '6C6472656E203D2066616C73653B0D0A090909097D0D0A090909097570646174654368617274286E6F6465735B695D293B0D0A0909097D0D0A09097D0D0A202020207D0D0A0D0A20202020766172206E6F646573203D207061636B2E6E6F646573286170';
wwv_flow_api.g_varchar2_table(177) := '65785F646174615F6A736F6E292E7265766572736528293B0D0A20202020766172206C696E6B73203D207061636B2E6C696E6B73286E6F646573293B0D0A0D0A090D0A2020202076617220636C617373696669636174696F6E73203D206F7261636C652E';
wwv_flow_api.g_varchar2_table(178) := '6A716C28290D0A202020202020202E73656C65637428205B66756E6374696F6E28726F7773297B2072657475726E20636F6C6F724163636573736F7228726F77735B305D29207D2C2027636F6C6F72275D20290D0A202020202020202E66726F6D28206E';
wwv_flow_api.g_varchar2_table(179) := '6F6465732E66696C7465722866756E6374696F6E286429207B72657475726E2021642E726F773B207D2920290D0A202020202020202E67726F75705F627928205B66756E6374696F6E28726F77297B2072657475726E20726F772E434F4C4F5256414C55';
wwv_flow_api.g_varchar2_table(180) := '453B207D2C2027636C617373696669636174696F6E73275D202928293B0D0A0D0A0D0A20200D0A202020206E6F6465732E666F72456163682866756E6374696F6E286429207B20642E79203D20642E6465707468202A20704C696E6B44697374616E6365';
wwv_flow_api.g_varchar2_table(181) := '3B207D293B0D0A090D0A20202020766172206E6F6465203D20737667672E73656C656374416C6C28222E22202B20636F6E6669672E6373735F636C6173735F6E6F6465290D0A2020202020202E64617461286E6F6465732C66756E6374696F6E28642920';
wwv_flow_api.g_varchar2_table(182) := '7B72657475726E20642E49443B7D293B0D0A0D0A0920200D0A092F2F20494E534552542053454354494F4E0D0A090D0A0966756E6374696F6E206765744176674D756C74694E6F646573506F736974696F6E28747970652C20696E5F696429207B0D0A09';
wwv_flow_api.g_varchar2_table(183) := '09766172206C6F6364583D302C206C6F6364593D302C206C6F63436F756E743D303B0D0A09096E6F6465732E666F72456163682866756E6374696F6E286429207B200D0A090920202020696628642E49443D3D696E5F696429207B0D0A090909096C6F63';
wwv_flow_api.g_varchar2_table(184) := '436F756E742B2B3B0D0A090909096C6F6364583D6C6F6364582B642E783B0D0A090909096C6F6364593D6C6F6364592B642E793B0D0A0909097D0D0A09097D293B0D0A09092F2F636F6E736F6C652E6C6F67282249443A222B696E5F69642B22206C6F63';
wwv_flow_api.g_varchar2_table(185) := '64583A222B6C6F6364582B22206C6F636459222B6C6F6364592B2220636F756E743A222B6C6F63436F756E74293B0D0A090969662028747970653D3D27647827202626206C6F63436F756E74213D3029200D0A09090972657475726E206C6F6364582F6C';
wwv_flow_api.g_varchar2_table(186) := '6F63436F756E743B0D0A0909656C73652069662028747970653D3D27647927202626206C6F63436F756E74213D3029200D0A09090972657475726E206C6F6364592F6C6F63436F756E743B0D0A0909656C73650D0A09090972657475726E20303B0D0A09';
wwv_flow_api.g_varchar2_table(187) := '7D0D0A0D0A20202020766172206E6F6465456E746572203D206E6F64652E656E74657228290D0A2020202020202E617070656E6428226722290D0A2020202020202E6174747228226964222C202020202020202066756E6374696F6E286429207B207265';
wwv_flow_api.g_varchar2_table(188) := '7475726E20674964507265666978202B2070526567696F6E4964202B20225F22202B20642E49447D290D0A2020202020202E617474722822636C617373222C202020202066756E6374696F6E286429207B2072657475726E20676574437373436C617373';
wwv_flow_api.g_varchar2_table(189) := '28642C2066616C7365293B7D290D0A2020202020202E6174747228227472616E73666F726D222C2066756E6374696F6E286429207B2061646A7573745376675769647468286765744176674D756C74694E6F646573506F736974696F6E28276479272C20';
wwv_flow_api.g_varchar2_table(190) := '642E494429293B2072657475726E20227472616E736C6174652822202B20736F757263652E7930202B20222C22202B20736F757263652E7830202B202229223B207D290D0A2020202020202E6F6E282264626C436C69636B222C2066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(191) := '6429207B66697265417065784576656E74282264626C436C69636B222C2064293B7D290D0A202020203B0D0A0D0A202020206E6F6465456E7465722E617070656E642822636972636C6522290D0A2020202020202E61747472282272222C2031652D3629';
wwv_flow_api.g_varchar2_table(192) := '0D0A2020202020202E7374796C65282266696C6C222C2066756E6374696F6E286429207B2072657475726E20636F6C6F724163636573736F722864293B207D290D0A2020202020202E7374796C6528227374726F6B65222C2066756E6374696F6E286429';
wwv_flow_api.g_varchar2_table(193) := '207B2072657475726E20636F6C6F724163636573736F722864293B207D290D0A2020202020202E656163682866756E6374696F6E20286429207B0D0A2020202020202020202064332E73656C65637428207468697320290D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(194) := '202E636C6173736564282027752D436F6C6F722D27202B2067436C6173735363616C652820636C6173736669636174696F6E734163636573736F722E6170706C792820746869732C20617267756D656E747320292029202B20272D42472D2D66696C6C27';
wwv_flow_api.g_varchar2_table(195) := '202B200D0A20202020202020202020202020202020202020202720752D436F6C6F722D27202B2067436C6173735363616C652820636C6173736669636174696F6E734163636573736F722E6170706C792820746869732C20617267756D656E7473202920';
wwv_flow_api.g_varchar2_table(196) := '29202B20272D42472D2D6272272C207472756520293B0D0A2020202020207D290D0A2020202020202E6F6E2822746F756368656E64222C2070726F636573734576656E745F546F756368290D0A2020202020202E6F6E2822636C69636B222C2070726F63';
wwv_flow_api.g_varchar2_table(197) := '6573734576656E745F436C69636B290D0A202020203B0D0A0D0A202020206E6F6465456E7465722E617070656E6428227465787422290D0A2020202020202E61747472282278222C2066756E6374696F6E286429207B2072657475726E20642E6368696C';
wwv_flow_api.g_varchar2_table(198) := '6472656E207C7C20642E5F6368696C6472656E203F202D28676574436972636C6552616469757328642E53495A4556414C554529202B203229203A20676574436972636C6552616469757328642E53495A4556414C554529202B20323B207D290D0A2020';
wwv_flow_api.g_varchar2_table(199) := '202020202E6174747228226479222C2066756E6374696F6E286429207B2072657475726E2028642E6368696C6472656E207C7C20642E5F6368696C6472656E29262621642E69735F726F6F74203F20222D302E3335656D22203A2022302E3335656D223B';
wwv_flow_api.g_varchar2_table(200) := '207D290D0A2020202020202E617474722822746578742D616E63686F72222C2066756E6374696F6E286429207B2072657475726E20642E6368696C6472656E207C7C20642E5F6368696C6472656E203F2022656E6422203A20227374617274223B207D29';
wwv_flow_api.g_varchar2_table(201) := '0D0A2020202020202E636C6173736564282066756E6374696F6E286429207B2072657475726E2027752D436F6C6F722D27202B2067436C6173735363616C652820642E434F4C4F5256414C55452029202B20272D46472D2D66696C6C273B7D20290D0A20';
wwv_flow_api.g_varchar2_table(202) := '20202020202E746578742866756E6374696F6E286429207B2072657475726E206765744C6162656C2864293B207D290D0A2020202020202E7374796C65282266696C6C2D6F706163697479222C2031652D36290D0A2020202020202E7374796C65282263';
wwv_flow_api.g_varchar2_table(203) := '7572736F72222C2066756E6374696F6E20286429207B72657475726E20642E4C494E4B3F22706F696E746572223A22223B7D290D0A2020202020202E6F6E2822636C69636B222C2070726F636573734576656E745F6C696E6B436C69636B290D0A202020';
wwv_flow_api.g_varchar2_table(204) := '2020202E6F6E2822746F756368656E64222C2070726F636573734576656E745F6C696E6B436C69636B290D0A202020203B0D0A0D0A0D0A2020202069662028207053686F77546F6F6C7469702029207B0D0A2020202020202020202076617220746F6F6C';
wwv_flow_api.g_varchar2_table(205) := '746970436F6C6F723B0D0A2020202020202020202076617220746F6F6C74697047656E657261746F72203D2064332E6F7261636C652E746F6F6C74697028290D0A20202020202020202020202020202E6163636573736F7273287B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(206) := '20202020202020202020206C6162656C203A2066756E6374696F6E20286429207B72657475726E20642E4C4142454C3B7D2C0D0A20202020202020202020202020202020202076616C7565203A2066756E6374696F6E2820642029207B2072657475726E';
wwv_flow_api.g_varchar2_table(207) := '2028642E53495A4556414C55453F642E53495A4556414C55453A6E756C6C293B207D2C0D0A202020202020202020202020202020202020636F6C6F72203A2066756E6374696F6E2829207B2072657475726E20746F6F6C746970436F6C6F72207D2C0D0A';
wwv_flow_api.g_varchar2_table(208) := '202020202020202020202020202020202020636F6E74656E74203A2066756E6374696F6E2820642029207B2072657475726E20676574546F6F6C746970436F6E74656E742864293B7D0D0A20202020202020202020202020207D290D0A20202020202020';
wwv_flow_api.g_varchar2_table(209) := '202020202020202E73796D626F6C282027636972636C652720293B0D0A202020207D0D0A0D0A0D0A202020206E6F6465456E7465722E6F6E28226D6F7573656F766572222C2066756E6374696F6E286429207B0D0A20202020202069662028207053686F';
wwv_flow_api.g_varchar2_table(210) := '77546F6F6C7469702029207B0D0A2020202020202020746F6F6C746970436F6C6F72203D2077696E646F772E676574436F6D70757465645374796C652820746869732E676574456C656D656E747342795461674E616D652827636972636C6527295B305D';
wwv_flow_api.g_varchar2_table(211) := '20292E67657450726F706572747956616C756528202766696C6C2720293B0D0A0D0A202020202020202064332E73656C656374282067546F6F6C746970242E67657428302920290D0A2020202020202020202020202E646174756D28206420290D0A2020';
wwv_flow_api.g_varchar2_table(212) := '202020202020202020202E63616C6C2820746F6F6C74697047656E657261746F7220293B0D0A202020202020202067546F6F6C746970242E73746F7028292E66616465496E282031303020293B0D0A0D0A202020202020202067546F6F6C746970242E70';
wwv_flow_api.g_varchar2_table(213) := '6F736974696F6E287B0D0A202020202020202020206D793A20276C6566742B32302063656E746572272C0D0A202020202020202020206F663A2064332E6576656E742C0D0A2020202020202020202061743A202772696768742063656E746572272C0D0A';
wwv_flow_api.g_varchar2_table(214) := '2020202020202020202077697468696E3A2067526567696F6E242C0D0A20202020202020202020636F6C6C6973696F6E3A2027666C697020666974270D0A20202020202020207D293B0D0A2020202020207D0D0A0D0A2020202020206E6F6465456E7465';
wwv_flow_api.g_varchar2_table(215) := '720D0A2020202020202020202E66696C7465722866756E6374696F6E28643129207B72657475726E2064312E4944203D3D20642E49443B7D290D0A2020202020202020202E617474722822636C617373222C202020202066756E6374696F6E286429207B';
wwv_flow_api.g_varchar2_table(216) := '2072657475726E20676574437373436C61737328642C2074727565293B207D290D0A2020202020203B0D0A20202020202066697265417065784576656E7428226D6F7573656F766572222C2064293B0D0A202020207D293B200D0A0D0A202020206E6F64';
wwv_flow_api.g_varchar2_table(217) := '65456E7465722E6F6E28226D6F7573656D6F7665222C2066756E6374696F6E286429207B0D0A20202020202069662028207053686F77546F6F6C7469702029207B0D0A2020202020202020746F6F6C746970436F6C6F72203D2077696E646F772E676574';
wwv_flow_api.g_varchar2_table(218) := '436F6D70757465645374796C652820746869732E676574456C656D656E747342795461674E616D652827636972636C6527295B305D20292E67657450726F706572747956616C756528202766696C6C2720293B0D0A202020202020202064332E73656C65';
wwv_flow_api.g_varchar2_table(219) := '6374282067546F6F6C746970242E67657428302920290D0A2020202020202020202020202E646174756D28206420290D0A2020202020202020202020202E63616C6C2820746F6F6C74697047656E657261746F7220293B0D0A20202020202020200D0A20';
wwv_flow_api.g_varchar2_table(220) := '2020202020202069662028202167546F6F6C746970242E697328273A76697369626C6527292029207B0D0A2020202020202020202067546F6F6C746970242E66616465496E28293B0D0A20202020202020207D0D0A0D0A202020202020202067546F6F6C';
wwv_flow_api.g_varchar2_table(221) := '746970242E706F736974696F6E287B0D0A202020202020202020206D793A20276C6566742B32302063656E746572272C0D0A202020202020202020206F663A2064332E6576656E742C0D0A2020202020202020202061743A202772696768742063656E74';
wwv_flow_api.g_varchar2_table(222) := '6572272C0D0A2020202020202020202077697468696E3A2067526567696F6E242C0D0A20202020202020202020636F6C6C6973696F6E3A2027666C697020666974270D0A20202020202020207D293B0D0A2020202020207D0D0A0D0A2020202020206669';
wwv_flow_api.g_varchar2_table(223) := '7265417065784576656E7428226D6F7573656D6F7665222C2064293B0D0A202020207D293B200D0A0D0A202020206E6F6465456E7465722E6F6E2822666F637573222C2066756E6374696F6E286429207B0D0A2020202020207661722073656C66203D20';
wwv_flow_api.g_varchar2_table(224) := '746869733B0D0A20202020202069662028207468697320213D3D2067486F76657265644E6F6465207C7C2069734B6579646F776E5472696767657265642029207B0D0A202020202020202069734B6579646F776E547269676765726564203D2066616C73';
wwv_flow_api.g_varchar2_table(225) := '653B0D0A0D0A202020202020202069662028207053686F77546F6F6C7469702029207B0D0A20202020202020202020746F6F6C746970436F6C6F72203D2077696E646F772E676574436F6D70757465645374796C652820746869732E676574456C656D65';
wwv_flow_api.g_varchar2_table(226) := '6E747342795461674E616D652827636972636C6527295B305D20292E67657450726F706572747956616C756528202766696C6C2720293B0D0A2020202020202020202064332E73656C656374282067546F6F6C746970242E67657428302920290D0A2020';
wwv_flow_api.g_varchar2_table(227) := '2020202020202020202020202E646174756D28206420290D0A20202020202020202020202020202E63616C6C2820746F6F6C74697047656E657261746F7220293B0D0A2020202020202020202067546F6F6C746970242E73746F7028292E66616465496E';
wwv_flow_api.g_varchar2_table(228) := '282031303020293B0D0A0D0A20202020202020202020766172206F6666203D202428207468697320292E6F666673657428293B0D0A2020202020202020202067546F6F6C746970242E706F736974696F6E287B0D0A20202020202020202020202020206D';
wwv_flow_api.g_varchar2_table(229) := '793A202763656E74657220626F74746F6D2D35272C0D0A20202020202020202020202020206F663A20674368617274242C0D0A202020202020202020202020202061743A20276C6566742B27202B200D0A2020202020202020202020202020202020204D';
wwv_flow_api.g_varchar2_table(230) := '6174682E726F756E6428206F66662E6C656674202D20674368617274242E6F666673657428292E6C656674202B20746869732E67657442426F7828292E7769647468202F20322029202B200D0A2020202020202020202020202020202020202720746F70';
wwv_flow_api.g_varchar2_table(231) := '2B27202B200D0A20202020202020202020202020202020202028206F66662E746F70202D20674368617274242E6F666673657428292E746F7020292C0D0A202020202020202020202020202077697468696E3A2067526567696F6E242C0D0A2020202020';
wwv_flow_api.g_varchar2_table(232) := '202020202020202020636F6C6C6973696F6E3A202766697420666974270D0A202020202020202020207D293B0D0A20202020202020207D0D0A2020202020207D0D0A2020202020206E6F6465456E7465720D0A2020202020202020202E66696C74657228';
wwv_flow_api.g_varchar2_table(233) := '66756E6374696F6E28643129207B72657475726E2064312E4944203D3D20642E49443B7D290D0A2020202020202020202E617474722822636C617373222C202020202066756E6374696F6E286429207B2072657475726E20676574437373436C61737328';
wwv_flow_api.g_varchar2_table(234) := '642C2074727565293B207D290D0A2020202020203B0D0A0D0A202020207D293B0D0A200D0A202020206E6F6465456E7465722E6F6E282027626C7572272C2066756E6374696F6E286429207B0D0A2020202020206E6F6465456E7465720D0A2020202020';
wwv_flow_api.g_varchar2_table(235) := '202020202E66696C7465722866756E6374696F6E28643129207B72657475726E2064312E4944203D3D20642E49443B7D290D0A2020202020202020202E617474722822636C617373222C202020202066756E6374696F6E286429207B2072657475726E20';
wwv_flow_api.g_varchar2_table(236) := '676574437373436C61737328642C2066616C7365293B207D290D0A2020202020203B0D0A202020202020202067466F63757365644E6F6465203D206E756C6C3B0D0A202020202020202069662028202167486F76657265644E6F64652029207B0D0A2020';
wwv_flow_api.g_varchar2_table(237) := '2020202020202020202067546F6F6C746970242E73746F7028292E666164654F75742820313030293B0D0A20202020202020207D0D0A0D0A20202020202020207661722073656C66203D20746869733B0D0A202020202020202064332E73656C65637428';
wwv_flow_api.g_varchar2_table(238) := '20674368617274242E67657428302920290D0A2020202020202020202020202E73656C656374416C6C2820272E272B636F6E6669672E6373735F636C6173735F6E6F6465290D0A202020207D293B0D0A0D0A0D0A202020206E6F6465456E7465722E6F6E';
wwv_flow_api.g_varchar2_table(239) := '28226D6F7573656F7574222C2066756E6374696F6E286429207B0D0A20202020202069662028207053686F77546F6F6C7469702029207B0D0A202020202020202067546F6F6C746970242E73746F7028292E666164654F7574282031303020293B0D0A20';
wwv_flow_api.g_varchar2_table(240) := '20202020207D0D0A0D0A2020202020206E6F6465456E7465720D0A2020202020202020202E66696C7465722866756E6374696F6E28643129207B72657475726E2064312E4944203D3D20642E494420262620212867466F63757365644E6F646520262620';
wwv_flow_api.g_varchar2_table(241) := '67466F6375736564446174614E6F64652026262067466F6375736564446174614E6F64652E4944203D3D20642E4944297D290D0A2020202020202020202E617474722822636C617373222C202020202066756E6374696F6E286429207B2072657475726E';
wwv_flow_api.g_varchar2_table(242) := '20676574437373436C61737328642C2066616C7365293B207D290D0A2020202020203B0D0A20202020202066697265417065784576656E7428226D6F7573656F7574222C2064293B0D0A202020207D293B200D0A090D0A202020202F2F20555044415445';
wwv_flow_api.g_varchar2_table(243) := '2053454354494F4E210D0A0D0A20202020766172206E6F6465557064617465203D206E6F64652E7472616E736974696F6E28292E6475726174696F6E28636F6E6669672E7472647572202A2032290D0A20202020202020202E6174747228227472616E73';
wwv_flow_api.g_varchar2_table(244) := '666F726D222C2066756E6374696F6E286429207B2061646A7573745376675769647468286765744176674D756C74694E6F646573506F736974696F6E28276479272C642E494429293B202072657475726E20227472616E736C6174652822202B20676574';
wwv_flow_api.g_varchar2_table(245) := '4176674D756C74694E6F646573506F736974696F6E28276479272C642E494429202B20222C22202B206765744176674D756C74694E6F646573506F736974696F6E28276478272C642E494429202B202229223B207D290D0A202020203B0D0A0D0A202020';
wwv_flow_api.g_varchar2_table(246) := '206E6F64655570646174650D0A2020202020202E73656C6563742822636972636C6522290D0A2020202020202E61747472282272222C2066756E6374696F6E20286429207B72657475726E20676574436972636C6552616469757328642E53495A455641';
wwv_flow_api.g_varchar2_table(247) := '4C5545293B7D290D0A2020202020202E7374796C65282266696C6C222C2066756E6374696F6E286429207B2072657475726E20636F6C6F724163636573736F722864293B207D290D0A2020202020202E7374796C6528227374726F6B65222C2066756E63';
wwv_flow_api.g_varchar2_table(248) := '74696F6E286429207B2072657475726E20636F6C6F724163636573736F722864293B207D290D0A2020202020202E656163682866756E6374696F6E20286429207B0D0A202020202020202064332E73656C65637428207468697320290D0A202020202020';
wwv_flow_api.g_varchar2_table(249) := '2020202E636C6173736564282027752D436F6C6F722D27202B2067436C6173735363616C652820636C6173736669636174696F6E734163636573736F722E6170706C792820746869732C20617267756D656E747320292029202B20272D42472D2D66696C';
wwv_flow_api.g_varchar2_table(250) := '6C27202B200D0A20202020202020202020202020202020202020202720752D436F6C6F722D27202B2067436C6173735363616C652820636C6173736669636174696F6E734163636573736F722E6170706C792820746869732C20617267756D656E747320';
wwv_flow_api.g_varchar2_table(251) := '292029202B20272D42472D2D6272272C207472756520293B0D0A2020202020207D0D0A20202020293B0D0A2020200D0A20202020766172206E6F646554657874203D206E6F64655570646174652E73656C65637428227465787422290D0A202020202020';
wwv_flow_api.g_varchar2_table(252) := '2E746578742866756E6374696F6E286429207B2072657475726E206765744C6162656C2864293B207D290D0A2020202020202E656163682866756E6374696F6E286429207B69662028642E434F4C4F5256414C554529207B64332E73656C656374287468';
wwv_flow_api.g_varchar2_table(253) := '6973292E636C6173736564282066756E6374696F6E286429207B2072657475726E2027752D436F6C6F722D27202B2067436C6173735363616C652820642E434F4C4F5256414C55452029202B20272D46472D2D66696C6C273B7D20297D7D290D0A202020';
wwv_flow_api.g_varchar2_table(254) := '2020202E7374796C65282266696C6C2D6F706163697479222C2031290D0A2020202020202E7374796C652822637572736F72222C2066756E6374696F6E20286429207B72657475726E20642E4C494E4B3F22706F696E746572223A22223B7D290D0A2020';
wwv_flow_api.g_varchar2_table(255) := '20203B0D0A0D0A202020206E6F6465546578742E656163682866756E6374696F6E20286429207B0D0A202020202020202064332E73656C65637428207468697320290D0A202020202020202020202E74657874282066756E6374696F6E2864297B207265';
wwv_flow_api.g_varchar2_table(256) := '7475726E2074657874456C6C697073697328746869732C2064293B207D20293B0D0A2020202020207D293B0D0A0D0A090D0A202020202F2F2044454C4554452053454354494F4E0D0A090D0A20202020766172206E6F646545786974203D206E6F64652E';
wwv_flow_api.g_varchar2_table(257) := '6578697428290D0A2020202020202E7472616E736974696F6E28290D0A2020202020202E6475726174696F6E28636F6E6669672E7472647572202A2032290D0A2020202020202E6174747228227472616E73666F726D222C2066756E6374696F6E286429';
wwv_flow_api.g_varchar2_table(258) := '207B2072657475726E20227472616E736C6174652822202B20736F757263652E79202B20222C22202B20736F757263652E78202B202229223B207D290D0A2020202020202E72656D6F766528293B0D0A0D0A202020206E6F6465457869740D0A20202020';
wwv_flow_api.g_varchar2_table(259) := '20202E73656C6563742822636972636C652229200D0A2020202020202E61747472282272222C2031652D36293B0D0A0D0A202020206E6F6465457869742E73656C65637428227465787422290D0A2020202020202E7374796C65282266696C6C2D6F7061';
wwv_flow_api.g_varchar2_table(260) := '63697479222C2031652D36293B0D0A090D0A0D0A20202020766172206C696E6B203D20737667672E73656C656374416C6C2822706174682E22202B20636F6E6669672E6373735F636C6173735F6C696E6B290D0A2020202020202E64617461286C696E6B';
wwv_flow_api.g_varchar2_table(261) := '732C2066756E6374696F6E286429207B200D0A090972657475726E20642E7461726765742E4348494C445F504152454E543B7D293B0D0A09090D0A090D0A202020206C696E6B2E656E74657228290D0A2020202020202E696E7365727428227061746822';
wwv_flow_api.g_varchar2_table(262) := '2C20226722290D0A2020202020202E617474722822636C617373222C20636F6E6669672E6373735F636C6173735F6C696E6B290D0A2020202020202E61747472282264222C2066756E6374696F6E286429207B0D0A2020202020202020766172206F203D';
wwv_flow_api.g_varchar2_table(263) := '207B783A20736F757263652E78302C20793A20736F757263652E79307D3B0D0A202020202020202072657475726E20646961676F6E616C287B736F757263653A206F2C207461726765743A206F7D293B0D0A2020202020207D293B0D0A0D0A202020206C';
wwv_flow_api.g_varchar2_table(264) := '696E6B2E7472616E736974696F6E28290D0A2020202020202E6475726174696F6E28636F6E6669672E7472647572202A2032290D0A2020202020202E61747472282264222C2066756E6374696F6E286429207B0D0A0909766172206C5F736F7572636520';
wwv_flow_api.g_varchar2_table(265) := '203D207B783A206765744176674D756C74694E6F646573506F736974696F6E28276478272C20642E736F757263652E4944292C20793A206765744176674D756C74694E6F646573506F736974696F6E28276479272C20642E736F757263652E4944297D0D';
wwv_flow_api.g_varchar2_table(266) := '0A2020202020202020766172206C5F746172676574203D207B783A206765744176674D756C74694E6F646573506F736974696F6E28276478272C20642E7461726765742E4944292C20793A206765744176674D756C74694E6F646573506F736974696F6E';
wwv_flow_api.g_varchar2_table(267) := '28276479272C20642E7461726765742E4944297D3B0D0A202020202020202072657475726E20646961676F6E616C287B736F757263653A206C5F736F757263652C207461726765743A206C5F7461726765747D293B0D0A2020202020207D293B0D0A2020';
wwv_flow_api.g_varchar2_table(268) := '0D0A202020200D0A202020206C696E6B2E6578697428292E7472616E736974696F6E28290D0A2020202020202E6475726174696F6E28636F6E6669672E7472647572202A2032290D0A2020202020202E61747472282264222C2066756E6374696F6E2864';
wwv_flow_api.g_varchar2_table(269) := '29207B0D0A2020202020202020766172206F203D207B783A20736F757263652E782C20793A20736F757263652E797D3B0D0A202020202020202072657475726E20646961676F6E616C287B736F757263653A206F2C207461726765743A206F7D293B0D0A';
wwv_flow_api.g_varchar2_table(270) := '2020202020207D290D0A2020202020202E72656D6F766528293B0D0A202020200D0A202020202F2F20537461736820746865206F6C6420706F736974696F6E7320666F72207472616E736974696F6E2E0D0A202020206E6F6465732E666F724561636828';
wwv_flow_api.g_varchar2_table(271) := '66756E6374696F6E286429207B0D0A202020202020642E7830203D20642E783B0D0A202020202020642E7930203D20642E793B0D0A202020207D293B0D0A0D0A2020202069662028207053686F774C6567656E642029207B0D0A20202020202067417279';
wwv_flow_api.g_varchar2_table(272) := '203D2064332E6F7261636C652E61727928290D0A202020202020202020202E686964655469746C6528207472756520290D0A202020202020202020202E73686F7756616C7565282066616C736520290D0A202020202020202020202E6C656674436F6C6F';
wwv_flow_api.g_varchar2_table(273) := '7228207472756520290D0A202020202020202020202E6E756D6265724F66436F6C756D6E7328203320290D0A202020202020202020202E6163636573736F7273287B0D0A2020202020202020202020202020636F6C6F723A2066756E6374696F6E286429';
wwv_flow_api.g_varchar2_table(274) := '207B2072657475726E20642E636F6C6F723B207D2C0D0A20202020202020202020202020206C6162656C3A2066756E6374696F6E286429207B2072657475726E202870436F6C6F72733D3D22434F4C554D4E22293F6765744C6567656E64466F72436F6C';
wwv_flow_api.g_varchar2_table(275) := '6F7228642E636F6C6F72293A642E636C617373696669636174696F6E733B207D0D0A202020202020202020207D290D0A202020202020202020202E73796D626F6C2827636972636C6527293B0D0A0D0A202020202020674172792E6E756D6265724F6643';
wwv_flow_api.g_varchar2_table(276) := '6F6C756D6E7328204D6174682E6D617828204D6174682E666C6F6F7228207769647468202F20636F6E6669672E6C6567656E645F636F6C756D6E5F776964746820292C2031202920293B0D0A0D0A20202020202064332E73656C6563742820674C656765';
wwv_flow_api.g_varchar2_table(277) := '6E64242E67657428302920290D0A20202020202020202E646174756D28636C617373696669636174696F6E73290D0A20202020202020202E63616C6C28206741727920290D0A20202020202020202E73656C656374416C6C2820272E612D443343686172';
wwv_flow_api.g_varchar2_table(278) := '744C6567656E642D6974656D2720290D0A20202020202020202E656163682866756E6374696F6E2028642C206929207B0D0A20202020202020202020202064332E73656C65637428207468697320290D0A202020202020202020202020202020202E7365';
wwv_flow_api.g_varchar2_table(279) := '6C656374416C6C2820272E612D443343686172744C6567656E642D6974656D2D636F6C6F722720290D0A202020202020202020202020202020202E656163682866756E6374696F6E2829207B0D0A20202020202020202020202020202020202020207661';
wwv_flow_api.g_varchar2_table(280) := '722073656C66203D2064332E73656C65637428207468697320293B0D0A202020202020202020202020202020202020202076617220636F6C6F72436C617373203D2073656C662E61747472282027636C6173732720292E6D61746368282F752D436F6C6F';
wwv_flow_api.g_varchar2_table(281) := '722D5C642B2D42472D2D62672F6729207C7C205B5D3B0D0A2020202020202020202020202020202020202020666F7220287661722069203D20636F6C6F72436C6173732E6C656E677468202D20313B2069203E3D20303B20692D2D29207B0D0A20202020';
wwv_flow_api.g_varchar2_table(282) := '202020202020202020202020202020202020202073656C662E636C61737365642820636F6C6F72436C6173735B695D2C2066616C736520293B0D0A20202020202020202020202020202020202020207D3B0D0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(283) := '20202073656C662E636C6173736564282027752D436F6C6F722D27202B2067436C6173735363616C652820642E636C617373696669636174696F6E732029202B20272D42472D2D6267272C207472756520293B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(284) := '207D290D0A20202020202020207D293B0D0A202020207D0D0A0D0A2020202069662028202167486173486F6F6B65644576656E74732029207B0D0A2020202020202020202020206973466F6375736564203D2066616C73653B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(285) := '202020242822737667222C2067436861727424292E666972737428292E6F6E282027666F637573272C2066756E6374696F6E2829207B0D0A202020202020202020202020202020206973466F6375736564203D20747275653B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(286) := '202020202020206966202867466F6375736564446174614E6F646529207B0D0A20202020202020202020202020202020202067466F63757365644E6F6465203D202428272327202B20674964507265666978202B2070526567696F6E4964202B20275F27';
wwv_flow_api.g_varchar2_table(287) := '202B2067466F6375736564446174614E6F64652E494420292E666972737428292E666F63757328293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D290D0A2020202020202020202020202E6F6E2820276B657964';
wwv_flow_api.g_varchar2_table(288) := '6F776E272C2066756E6374696F6E20286529207B0D0A20202020202020202020202020202020737769746368202820652E77686963682029207B0D0A2020202020202020202020202020202020202020636173652031333A0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(289) := '2020202020202020202020202020696620282067466F6375736564446174614E6F64652E4C494E4B2029207B0D0A20202020202020202020202020202020202020202020202020207661722077696E203D20617065782E6E617669676174696F6E2E7265';
wwv_flow_api.g_varchar2_table(290) := '6469726563742867466F6375736564446174614E6F64652E4C494E4B293B0D0A202020202020202020202020202020202020202020202020202077696E2E666F63757328293B0D0A2020202020202020202020202020202020202020202020202020652E';
wwv_flow_api.g_varchar2_table(291) := '70726576656E7444656661756C7428293B0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020202020627265616B3B0D0A20202020202020202020202020202020202020206361';
wwv_flow_api.g_varchar2_table(292) := '73652033323A0D0A202020202020202020202020202020202020202020202020696620282067466F6375736564446174614E6F64652029207B0D0A2020202020202020202020202020202020202020202020202020746F67676C654E6F6465436F6C6C61';
wwv_flow_api.g_varchar2_table(293) := '707365642867466F6375736564446174614E6F6465293B0D0A2020202020202020202020202020202020202020202020202020652E70726576656E7444656661756C7428293B0D0A2020202020202020202020202020202020202020202020207D0D0A20';
wwv_flow_api.g_varchar2_table(294) := '2020202020202020202020202020202020202020202020627265616B3B0D0A2020202020202020202020202020202020202020636173652033373A0D0A20202020202020202020202020202020202020202020202069734B6579646F776E547269676765';
wwv_flow_api.g_varchar2_table(295) := '726564203D20747275653B0D0A20202020202020202020202020202020202020202020202069662028202167466F6375736564446174614E6F64652029207B0D0A2020202020202020202020202020202020202020202020202020202067466F63757365';
wwv_flow_api.g_varchar2_table(296) := '64446174614E6F6465203D20617065785F646174615F6A736F6E3B0D0A2020202020202020202020202020202020202020202020202020202067466F63757365644368696C64496478203D20303B0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(297) := '202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202020206966202867466F6375736564446174614E6F64652E706172656E7429207B0D0A20202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(298) := '67466F6375736564446174614E6F6465203D2067466F6375736564446174614E6F64652E706172656E743B0D0A202020202020202020202020202020202020202020202020202020206966202867466F6375736564446174614E6F64652E706172656E74';
wwv_flow_api.g_varchar2_table(299) := '29207B0D0A202020202020202020202020202020202020202020202020202020202020666F722028766172207069783D303B706978203C2067466F6375736564446174614E6F64652E706172656E742E6368696C6472656E2E6C656E6774683B20706978';
wwv_flow_api.g_varchar2_table(300) := '2B2B29207B0D0A20202020202020202020202020202020202020202020202020202020202020206966202867466F6375736564446174614E6F64652E706172656E742E6368696C6472656E5B7069785D2E4944203D3D2067466F6375736564446174614E';
wwv_flow_api.g_varchar2_table(301) := '6F64652E494429207B0D0A2020202020202020202020202020202020202020202020202020202020202020202067466F63757365644368696C64496478203D207069783B0D0A202020202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(302) := '20202020627265616B3B0D0A20202020202020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(303) := '20202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202020202020202067466F63757365644368696C64496478203D20303B0D0A202020202020202020202020202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(304) := '0D0A20202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020202020652E70726576656E7444656661756C742829';
wwv_flow_api.g_varchar2_table(305) := '3B0D0A202020202020202020202020202020202020202020202020627265616B3B20200D0A2020202020202020202020202020202020202020636173652033383A0D0A2020202020202020202020202020202020202020202020202F2F20466F63757320';
wwv_flow_api.g_varchar2_table(306) := '70726576696F75732072656374616E676C650D0A20202020202020202020202020202020202020202020202069734B6579646F776E547269676765726564203D20747275653B0D0A20202020202020202020202020202020202020202020202069662028';
wwv_flow_api.g_varchar2_table(307) := '202167466F6375736564446174614E6F64652029207B0D0A2020202020202020202020202020202020202020202020202020202067466F6375736564446174614E6F6465203D20617065785F646174615F6A736F6E3B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(308) := '2020202020202020202020202020202067466F63757365644368696C64496478203D20303B0D0A2020202020202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(309) := '696620282167466F6375736564446174614E6F64652E69735F726F6F7429207B0D0A20202020202020202020202020202020202020202020202020202020206966202867466F63757365644368696C64496478203E203029207B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(310) := '202020202020202020202020202020202020202020202067466F63757365644368696C644964782D2D3B0D0A2020202020202020202020202020202020202020202020202020202020202067466F6375736564446174614E6F6465203D2067466F637573';
wwv_flow_api.g_varchar2_table(311) := '6564446174614E6F64652E706172656E742E6368696C6472656E5B67466F63757365644368696C644964785D3B0D0A20202020202020202020202020202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(312) := '202020202020202020202020202020202067466F63757365644368696C64496478203D2067466F6375736564446174614E6F64652E706172656E742E6368696C6472656E2E6C656E677468202D20313B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(313) := '2020202020202020202020202067466F6375736564446174614E6F6465203D2067466F6375736564446174614E6F64652E706172656E742E6368696C6472656E5B67466F63757365644368696C644964785D3B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(314) := '20202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020202020652E';
wwv_flow_api.g_varchar2_table(315) := '70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020202020202020627265616B3B0D0A2020202020202020202020202020202020202020636173652033393A0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(316) := '202020202069734B6579646F776E547269676765726564203D20747275653B0D0A20202020202020202020202020202020202020202020202069662028202167466F6375736564446174614E6F64652029207B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(317) := '2020202020202020202020202067466F6375736564446174614E6F6465203D20617065785F646174615F6A736F6E3B0D0A2020202020202020202020202020202020202020202020202020202067466F63757365644368696C64496478203D20303B0D0A';
wwv_flow_api.g_varchar2_table(318) := '2020202020202020202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202020206966202867466F6375736564446174614E6F64652E6368696C6472656E29207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(319) := '2020202020202020202020202020202020202020202067466F6375736564446174614E6F6465203D2067466F6375736564446174614E6F64652E6368696C6472656E5B305D3B20200D0A2020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(320) := '202067466F63757365644368696C64496478203D20303B0D0A20202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(321) := '2020202020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020202020202020627265616B3B20200D0A2020202020202020202020202020202020202020636173652034303A0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(322) := '20202020202020202020202020202F2F20466F637573206E6578742072656374616E676C650D0A20202020202020202020202020202020202020202020202069734B6579646F776E547269676765726564203D20747275653B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(323) := '20202020202020202020202020202069662028202167466F6375736564446174614E6F64652029207B0D0A2020202020202020202020202020202020202020202020202020202067466F6375736564446174614E6F6465203D20617065785F646174615F';
wwv_flow_api.g_varchar2_table(324) := '6A736F6E3B0D0A2020202020202020202020202020202020202020202020202020202067466F63757365644368696C64496478203D20303B0D0A2020202020202020202020202020202020202020202020207D20656C7365207B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(325) := '20202020202020202020202020202020202020696620282167466F6375736564446174614E6F64652E69735F726F6F7429207B0D0A20202020202020202020202020202020202020202020202020202020206966202867466F63757365644368696C6449';
wwv_flow_api.g_varchar2_table(326) := '6478203C202867466F6375736564446174614E6F64652E706172656E742E6368696C6472656E2E6C656E677468202D20312929207B0D0A202020202020202020202020202020202020202020202020202020202020202067466F63757365644368696C64';
wwv_flow_api.g_varchar2_table(327) := '4964782B2B0D0A202020202020202020202020202020202020202020202020202020202020202067466F6375736564446174614E6F6465203D2067466F6375736564446174614E6F64652E706172656E742E6368696C6472656E5B67466F637573656443';
wwv_flow_api.g_varchar2_table(328) := '68696C644964785D3B0D0A20202020202020202020202020202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020202020202020202020202067466F63757365644368696C64496478203D20';
wwv_flow_api.g_varchar2_table(329) := '303B0D0A2020202020202020202020202020202020202020202020202020202020202067466F6375736564446174614E6F6465203D2067466F6375736564446174614E6F64652E706172656E742E6368696C6472656E5B67466F63757365644368696C64';
wwv_flow_api.g_varchar2_table(330) := '4964785D3B0D0A20202020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020202020207D0D0A20202020';
wwv_flow_api.g_varchar2_table(331) := '2020202020202020202020202020202020202020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020202020202020627265616B3B0D0A202020202020202020202020202020207D0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(332) := '202020202020202067466F63757365644E6F6465203D202428272327202B20674964507265666978202B2070526567696F6E4964202B20275F27202B2067466F6375736564446174614E6F64652E494420292E666972737428292E666F63757328293B0D';
wwv_flow_api.g_varchar2_table(333) := '0A2020202020202020202020207D290D0A2020202020202020202020202E6F6E282027626C7572272C2066756E6374696F6E20286529207B0D0A20202020202020202020202020202020696620282021242820646F63756D656E742E616374697665456C';
wwv_flow_api.g_varchar2_table(334) := '656D656E7420292E69732820272E27202B20636F6E6669672E6373735F636C6173735F6E6F646520292029207B0D0A20202020202020202020202020202020202020206973466F6375736564203D2066616C73653B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(335) := '2020202020202067466F63757365644E6F6465203D2066616C73653B0D0A0D0A20202020202020202020202020202020202020207661722073656C66203D20746869733B0D0A20202020202020202020202020202020202020207376672E73656C656374';
wwv_flow_api.g_varchar2_table(336) := '416C6C2820272E27202B20636F6E6669672E6373735F636C6173735F6E6F6465290D0A2020202020202020202020202020202020202020202020202E617474722820276F706163697479272C203120293B0D0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(337) := '0D0A2020202020202020202020207D293B0D0A0D0A2020202020202020242820646F63756D656E7420292E6F6E2820276B6579646F776E272C2066756E6374696F6E20286529207B0D0A20202020202020202020202069662028206973466F6375736564';
wwv_flow_api.g_varchar2_table(338) := '20262620652E7768696368203E3D20333720262620652E7768696368203C3D2034302029207B0D0A20202020202020202020202020202020652E70726576656E7444656661756C7428293B0D0A2020202020202020202020207D0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(339) := '7D290D0A0D0A202020202020202067486173486F6F6B65644576656E7473203D20747275653B0D0A202020207D0D0A0D0A2020202076617220726573697A6554696D656F75743B0D0A2020202076617220726573697A6548616E646C6572203D2066756E';
wwv_flow_api.g_varchar2_table(340) := '6374696F6E2829207B0D0A20202020202020202020636C65617254696D656F75742820726573697A6554696D656F757420293B0D0A20202020202020202020726573697A6554696D656F7574203D2073657454696D656F7574282066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(341) := '29207B0D0A20202020202020202020202020205F726573697A6546756E6374696F6E28293B0D0A202020202020202020207D2C20353030293B0D0A20202020202020207D3B0D0A0D0A20202020696620282167526573697A6548616E646C6572426F756E';
wwv_flow_api.g_varchar2_table(342) := '6429207B0D0A202020202020242877696E646F77292E726573697A6528726573697A6548616E646C657220293B0D0A20202020202067526573697A6548616E646C6572426F756E643D747275653B0D0A202020207D0D0A0D0A2020202069662028706172';
wwv_flow_api.g_varchar2_table(343) := '7365496E74287376672E6174747228227769647468222929203E20286D61785769647468202B20636F6E6669672E6D617267696E2E6C656674202B20636F6E6669672E6D617267696E2E7269676874202D20636F6E6669672E6F66667365745F7363726F';
wwv_flow_api.g_varchar2_table(344) := '6C6C62617273202929207B0D0A20202020202073657454696D656F75742866756E6374696F6E2829207B7376672E6174747228227769647468222C206D61785769647468202B20636F6E6669672E6D617267696E2E6C656674202B20636F6E6669672E6D';
wwv_flow_api.g_varchar2_table(345) := '617267696E2E7269676874293B7D2C2028636F6E6669672E7472647572202A203229293B0D0A202020207D20656C7365207B0D0A2020202020207376672E6174747228227769647468222C206D61785769647468202B20636F6E6669672E6D617267696E';
wwv_flow_api.g_varchar2_table(346) := '2E6C656674202B20636F6E6669672E6D617267696E2E7269676874293B0D0A202020207D0D0A20202020617065782E6576656E742E74726967676572280D0A20202020202024782870526567696F6E4964292C0D0A202020202020226170657861667465';
wwv_flow_api.g_varchar2_table(347) := '727265667265736822200D0A20202020293B0D0A20207D0D0A0D0A202066756E6374696F6E20757064617465446174612864336A736F6E29207B0D0A2020202072656672657368446174612864336A736F6E2C202870496E697469616C6C79436F6C6C61';
wwv_flow_api.g_varchar2_table(348) := '707365643D3D225922292C2074727565293B0D0A20207D0D0A2020200D0A202066756E6374696F6E20616464446174612864336A736F6E29207B0D0A2020202072656672657368446174612864336A736F6E2C202870496E697469616C6C79436F6C6C61';
wwv_flow_api.g_varchar2_table(349) := '707365643D3D225922292C2066616C7365293B0D0A0D0A20202020617065782E6576656E742E74726967676572280D0A20202020202024782870526567696F6E4964292C0D0A20202020202067506C7567696E4964507265666978202B2022696E697469';
wwv_flow_api.g_varchar2_table(350) := '616C697A6564220D0A20202020293B0D0A0D0A2020202069662028704175746F52656672657368203D3D2027592729207B0D0A2020202020206175746F52656672657368496E74657276616C203D2077696E646F772E736574496E74657276616C282020';
wwv_flow_api.g_varchar2_table(351) := '0D0A202020202020202066756E6374696F6E2829207B20676574446174612875706461746544617461293B207D2C0D0A20202020202020207052656672657368496E74657276616C0D0A202020202020293B0D0A202020207D0D0A20207D0D0A0D0A2020';
wwv_flow_api.g_varchar2_table(352) := '2F2F2062696E64206576656E74730D0A0D0A2020617065782E6A5175657279282223222B70526567696F6E4964292E62696E64280D0A20202020226170657872656672657368222C200D0A2020202066756E6374696F6E2829207B206765744461746128';
wwv_flow_api.g_varchar2_table(353) := '75706461746544617461293B207D0D0A2020293B0D0A0D0A2020617065782E6A5175657279282223222B70526567696F6E4964292E62696E64280D0A2020202067506C7567696E4964507265666978202B2022747265655F636F6C6C61707365222C200D';
wwv_flow_api.g_varchar2_table(354) := '0A2020202066756E6374696F6E2829207B0D0A20202020202069662028617065785F646174615F6A736F6E2E6368696C6472656E207C7C20617065785F646174615F6A736F6E2E5F6368696C6472656E29207B0D0A2020202020202020636F6C6C617073';
wwv_flow_api.g_varchar2_table(355) := '65416C6C28617065785F646174615F6A736F6E293B0D0A202020202020202067466F6375736564446174614E6F6465203D2066616C73653B0D0A2020202020202020757064617465436861727428617065785F646174615F6A736F6E293B0D0A20202020';
wwv_flow_api.g_varchar2_table(356) := '20207D200D0A202020207D0D0A2020293B0D0A0D0A2020617065782E6A5175657279282223222B70526567696F6E4964292E62696E64280D0A2020202067506C7567696E4964507265666978202B2022747265655F657870616E64222C200D0A20202020';
wwv_flow_api.g_varchar2_table(357) := '66756E6374696F6E2829207B200D0A20202020202069662028617065785F646174615F6A736F6E2E6368696C6472656E207C7C20617065785F646174615F6A736F6E2E5F6368696C6472656E29207B0D0A2020202020202020657870616E64416C6C2861';
wwv_flow_api.g_varchar2_table(358) := '7065785F646174615F6A736F6E293B0D0A2020202020202020757064617465436861727428617065785F646174615F6A736F6E293B200D0A2020202020207D0D0A202020207D0D0A2020293B0D0A0D0A0D0A202067657444617461286164644461746129';
wwv_flow_api.g_varchar2_table(359) := '3B0D0A7D7D292820617065782E7574696C2C20617065782E7365727665722C20617065782E6A51756572792C20643320293B0D0A0D0A0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(117195315444045026423)
,p_plugin_id=>wwv_flow_api.id(115185577336138139104)
,p_file_name=>'com_oracle_apex_d3tree.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
