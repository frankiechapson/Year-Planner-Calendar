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
,p_release=>'5.1.3.00.05'
,p_default_workspace_id=>1831297063944648
,p_default_application_id=>102
,p_default_owner=>'PLAYGROUND'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/region_type/yearplanner_apexplugin
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(8125908206591514)
,p_plugin_type=>'REGION TYPE'
,p_name=>'YEARPLANNER.APEXPLUGIN'
,p_display_name=>'Year Planner Calendar'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION YPC_render ( p_region                IN apex_plugin.t_region',
'                    , p_plugin                IN apex_plugin.t_plugin',
'                    , p_is_printer_friendly   IN BOOLEAN',
'                    ) RETURN apex_plugin.t_region_render_result IS',
'',
'/*',
'',
'inline CSS example:',
'',
'.YPC-New-Day-Type-W {',
' background-color: #F0FFFF !important;',
'} ',
'',
'.YPC-New-Day-Type-E {',
' background-color: #C9C9C9 !important;',
'} ',
'',
'.YPC-Empty {',
' background-color: #F9F9F9 !important;',
'} ',
'',
'td.YPC-Column-00 {',
' font-weight:bold !important;',
'} ',
'',
'',
'',
'*/',
'',
'',
'    type T_STRING_LIST  is table of varchar2( 10 ) index by binary_integer;',
'',
'    regionid            varchar2( 200 );',
'    n                   pls_integer;',
'',
'    V_YEAR              varchar2(  10 );',
'    V_MONTHS            T_STRING_LIST;',
'    V_DAYS              T_STRING_LIST;',
'    V_DATE              date;',
'',
'    V_DAY_O_CODE        varchar2(  50 ); ',
'    V_DAY_O_TYPE        varchar2(  50 ); ',
'    V_DAY_N_CODE        varchar2(  50 ); ',
'    V_DAY_N_TYPE        varchar2(  50 ); ',
'',
'    V_CLASS_YEAR        varchar2( 500 ); ',
'    V_CLASS_COLUMN      varchar2( 500 ); ',
'    V_CLASS_MONTH_NUM   varchar2( 500 ); ',
'    V_CLASS_DAY_O_CODE  varchar2( 500 ); ',
'    V_CLASS_DAY_O_TYPE  varchar2( 500 ); ',
'    V_CLASS_DAY_N_CODE  varchar2( 500 ); ',
'    V_CLASS_DAY_N_TYPE  varchar2( 500 ); ',
'',
'    V_I                 number;',
'    V_J                 number;',
'',
'BEGIN',
'',
'    V_DAYS   (  1 ) := ''Mo'';',
'    V_DAYS   (  2 ) := ''Tu'';',
'    V_DAYS   (  3 ) := ''We'';',
'    V_DAYS   (  4 ) := ''Th'';',
'    V_DAYS   (  5 ) := ''Fr'';',
'    V_DAYS   (  6 ) := ''Sa'';',
'    V_DAYS   (  7 ) := ''Su'';',
'',
'    V_MONTHS (  1 ) := ''January'';',
'    V_MONTHS (  2 ) := ''Febuary'';',
'    V_MONTHS (  3 ) := ''March'';',
'    V_MONTHS (  4 ) := ''April'';',
'    V_MONTHS (  5 ) := ''May'';',
'    V_MONTHS (  6 ) := ''June'';',
'    V_MONTHS (  7 ) := ''July'';',
'    V_MONTHS (  8 ) := ''August'';',
'    V_MONTHS (  9 ) := ''September'';',
'    V_MONTHS ( 10 ) := ''October'';',
'    V_MONTHS ( 11 ) := ''November'';',
'    V_MONTHS ( 12 ) := ''December'';',
'',
'    begin',
'        execute immediate ''select ''||p_region.attribute_01||'' from dual'' into V_YEAR;',
'    exception when others then',
'        null;',
'    end;',
'    V_YEAR       := nvl( V_YEAR, to_char(sysdate,''yyyy'') );',
'',
'    -------------------------------------------------------------------------------------------',
'    -- get the static id',
'    select static_id ',
'      into regionid ',
'      from apex_application_page_regions ',
'     where region_name      = p_region.name ',
'       AND application_id   = :APP_ID ',
'       AND page_id          = :APP_PAGE_ID ',
'       and rownum           = 1;',
'    -- if no static id is set, generate random',
'    if regionid is null then',
'        n := dbms_random.value(1,10000);',
'        regionid := regionid + n;',
'    end if;',
'',
'    -------------------------------------------------------------------------------------------',
'',
'    V_CLASS_YEAR := ''YPC-Year-''||V_YEAR;',
'',
'    sys.htp.p(''<table class="a-IRR-table YPC-Table ''||V_CLASS_YEAR||''" id="''||regionid||''">'');',
'',
'    sys.htp.p(''<thead>'');',
'    sys.htp.p(''<tr>'');',
'    sys.htp.p(''<th class="a-IRR-header YPC-Header-Year">''||V_YEAR||''</th>'');',
'    for L_H in 0..36',
'    loop',
'        sys.htp.p(''<th class="a-IRR-header YPC-Header-Day-''||V_DAYS( mod( L_H, 7 ) + 1 )||'' YPC-Header-Column-''||substr( ''0''||to_char( L_H + 1 ), -2 ) ||''" >''||V_DAYS( MOD( L_H, 7 ) + 1 ) ||''</th>'');',
'    end loop;',
'    sys.htp.p(''</tr>'');',
'    sys.htp.p(''</thead>'');',
'    ------------------------------------------------------------------------------------------',
'',
'    V_DATE       := to_date( V_YEAR||''0101'', ''yyyymmdd'' );',
'',
'    for L_M in 1..12',
'    loop',
'',
'        V_CLASS_MONTH_NUM := ''YPC-Month-''||substr( ''0''||to_char( L_M ), -2 ) ;',
'        V_CLASS_COLUMN    := ''YPC-Column-00'';',
'        sys.htp.p(''<tr class="''||V_CLASS_MONTH_NUM||''">'');',
'        sys.htp.p(''<td class="''||V_CLASS_MONTH_NUM||'' ''||V_CLASS_COLUMN||''">'');',
'        sys.htp.p(V_MONTHS( L_M ));',
'        sys.htp.p(''</td>'');',
'',
'        V_DAY_N_CODE :=  trim( to_char( V_DATE , ''DY'', ''NLS_DATE_LANGUAGE=AMERICAN'' ) );',
'        -- 1st day position',
'        case V_DAY_N_CODE',
'            when ''MON'' then V_I := 1;',
'            when ''TUE'' then V_I := 2;',
'            when ''WED'' then V_I := 3;',
'            when ''THU'' then V_I := 4;',
'            when ''FRI'' then V_I := 5;',
'            when ''SAT'' then V_I := 6;',
'            when ''SUN'' then V_I := 7;',
'        end case;',
'',
'        V_J := extract( day from trunc(last_day( V_DATE ) ) );',
'',
'        for L_D in 1..37 ',
'        loop',
'',
'            V_CLASS_COLUMN    := ''YPC-Column-''||substr( ''0''||to_char( L_D ), -2 ) ;',
'',
'            if L_D < V_I or L_D >= V_I + V_J then -- empty cell',
'                -- empty cell',
'                sys.htp.p(''<td class="YPC-Empty ''||V_CLASS_MONTH_NUM||'' ''||V_CLASS_COLUMN||''">'');',
'                sys.htp.p(''</td>'');',
'            else',
'',
'                begin',
'                    execute immediate ''select ORIG_DAY_TYPE_CODE, ORIG_WEEK_DAY_CODE, REAL_DAY_TYPE_CODE, REAL_WEEK_DAY_CODE from CA_CALENDAR_ORIG_AND_REAL_VW where CALENDAR_DAY = :1'' ',
'                      into V_DAY_O_TYPE, V_DAY_O_CODE, V_DAY_N_TYPE, V_DAY_N_CODE using V_DATE;',
'                exception when others then',
'                    V_DAY_N_CODE :=  trim( to_char( V_DATE , ''DY'', ''NLS_DATE_LANGUAGE=AMERICAN'' ) );',
'                    if V_DAY_N_CODE in ( ''SAT'', ''SUN'' ) then',
'                        V_DAY_N_TYPE := ''E'';  -- Weekend',
'                    else',
'                        V_DAY_N_TYPE := ''W'';  -- Workday',
'                    end if;',
'                    V_DAY_O_TYPE := V_DAY_N_TYPE;',
'                    V_DAY_O_CODE := V_DAY_N_CODE;',
'                end;',
'',
'                V_CLASS_DAY_O_CODE  := ''YPC-Orig-Day-Code-''||V_DAY_O_CODE;',
'                V_CLASS_DAY_O_TYPE  := ''YPC-Orig-Day-Type-''||V_DAY_O_TYPE;',
'                V_CLASS_DAY_N_CODE  := ''YPC-New-Day-Code-''||V_DAY_N_CODE;',
'                V_CLASS_DAY_N_TYPE  := ''YPC-New-Day-Type-''||V_DAY_N_TYPE;',
'',
'                sys.htp.p(''<td class="''||V_CLASS_MONTH_NUM||'' ''||V_CLASS_COLUMN||'' ''||V_CLASS_DAY_O_CODE||'' ''||V_CLASS_DAY_O_TYPE||'' ''||V_CLASS_DAY_N_CODE||'' ''||V_CLASS_DAY_N_TYPE);',
'                if V_DATE = trunc( sysdate )  then',
'                    sys.htp.p('' YPC-Today'');',
'                end if;',
'                sys.htp.p( ''">''||to_char( V_DATE, ''dd'' ) );',
'                sys.htp.p(''</td>'');',
'',
'                V_DATE := V_DATE + 1;',
'',
'            end if;',
'',
'        end loop;',
'',
'        sys.htp.p(''</tr>'');',
'',
'    end loop;',
'',
'    ------------------------------------------------------------------------------------------',
'    sys.htp.p(''</table>'');',
'    ------------------------------------------------------------------------------------------',
'',
'    return null;',
'',
'exception  when others then',
'    sys.htp.p(sqlerrm);',
'    return null;',
'END;',
''))
,p_api_version=>2
,p_render_function=>'YPC_render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8151954492905918)
,p_plugin_id=>wwv_flow_api.id(8125908206591514)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Year'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'to_char( sysdate, ''yyyy'' )'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The year.',
'It can be:',
'- a constant eg.: 2018',
'- an expression eg.: extract( year from sysdate )',
'- or a page item eg.: V(''P222_YEAR'')',
'since this is a pl/sql region, only the page submit can refresh it.'))
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
