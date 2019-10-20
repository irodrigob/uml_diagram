*&---------------------------------------------------------------------*
*& Include          ZCA_UMDI_R_UML_DIAGRAM_C01
*&---------------------------------------------------------------------*
CLASS lcl_contr DEFINITION.

  PUBLIC SECTION.
    METHODS constructor.
    METHODS search.
    METHODS show_data
      EXPORTING ev_no_data TYPE sap_bool.
    CLASS-METHODS handle_pbo.

  PROTECTED SECTION.
    DATA mo_controller TYPE REF TO zcl_ca_umdi_uml_diagram.
    DATA ms_sel_screen TYPE zif_ca_umdi_data=>ts_sel_screen.
    DATA mt_relations TYPE zif_ca_umdi_data=>tt_object_list_ref.
    DATA mo_alv TYPE REF TO zcl_ca_alv.
    DATA mv_code_yuml TYPE string.
    METHODS yuml_process.

ENDCLASS.

CLASS lcl_contr IMPLEMENTATION.
  METHOD constructor.
    mo_controller = NEW zcl_ca_umdi_uml_diagram(  ).
  ENDMETHOD.

  METHOD search.

    CLEAR: mt_relations.

    " Se pasan los parámetros de selección a una estructura.
    " Nota Iván: Se opta en pasarlos como referencia para no tener que definir estructuras intermedias. Pero al final el receptor tiene que tener un field-symbols
    " para mapearlo además de comprobar previamente si el puntero esta asignado. No tengo claro que sea la mejor solucion por no declarar tipos de datos a medida.
    GET REFERENCE OF s_class[] INTO ms_sel_screen-class.
    GET REFERENCE OF s_intf[] INTO ms_sel_screen-interface.
    GET REFERENCE OF s_pack[] INTO ms_sel_screen-package.
    GET REFERENCE OF s_report[] INTO ms_sel_screen-report.

    " Se llamado al controlador global encargado de obtener las relaciones de los objetos pasados
    mo_controller->get_relations( EXPORTING is_sel_screen = ms_sel_screen
                                  IMPORTING et_relations = mt_relations  ).


    IF p_yuml = abap_true. " Se lanza el proceso para YUML
      yuml_process(  ).
    ENDIF.
  ENDMETHOD.

  METHOD show_data.

    IF mt_relations IS NOT INITIAL.
      ev_no_data = abap_false.

      DATA(mo_alv) = NEW zcl_ca_alv(  ).

      mo_alv->create_alv(
        EXPORTING
          iv_program        = sy-repid
        CHANGING
          ct_data           = mt_relations
        EXCEPTIONS
          error_create_alv  = 1
          OTHERS            = 2 ).

      IF sy-subrc = 0.


        "Columnas optimizadas
        mo_alv->set_optimized_cols( abap_true ).

        "Todas las funciones ALV por defecto
        mo_alv->set_alv_functions( abap_true ).

        "Título del programa
        mo_alv->set_title( |{  sy-title }| ).

        mo_alv->set_field_properties(  iv_field = 'OBJECT_DESC' iv_all_text = TEXT-a01 ).
        mo_alv->set_field_properties(  iv_field = 'OBJECT' iv_all_text = TEXT-a02 ).
        mo_alv->set_field_properties(  iv_field = 'INTERNAL_NAME' iv_all_text = TEXT-a03 iv_visible = abap_false ).
        mo_alv->set_field_properties(  iv_field = 'TYPE_REF' iv_all_text = TEXT-a04 ).
        mo_alv->set_field_properties(  iv_field = 'OBJECT_REF' iv_all_text = TEXT-a05 ).
        mo_alv->set_field_properties(  iv_field = 'FULLNAME_REF' iv_all_text = TEXT-a06 iv_visible = abap_false ).
        mo_alv->set_field_properties(  iv_field = 'INTERNAL_NAME_REF' iv_all_text = TEXT-a07 iv_visible = abap_false ).
        mo_alv->set_field_properties(  iv_field = 'RELATION_TYPE' iv_all_text = TEXT-a08 ).
        mo_alv->set_field_properties(  iv_field = 'RELATION_TYPE_DESC' iv_all_text = TEXT-a09 ).

        mo_alv->show_alv( ).


      ENDIF.

    ELSE.
      ev_no_data = abap_true.
    ENDIF.
  ENDMETHOD.




  METHOD yuml_process.

    " Primero se genera el código
    mo_controller->generate_code_uml_app( EXPORTING iv_yuml = abap_true IMPORTING ev_code = mv_code_yuml ).

    IF p_ycode = abap_true. " Si solo se quiere el código se muestra en pantalla
      cl_demo_output=>display_text( mv_code_yuml ).
    ELSEIF p_yhtml = abap_true. " Si se quiere ver como página HTML se lanzará la BSP

      " Parámetros de la BSP
      DATA(lt_params) = VALUE tihttpnvp( ( name = 'code' value = mv_code_yuml )
                                         ( name = 'sap-client' value = sy-mandt )
                                         ( name = 'sap-language' value = sy-langu ) ).

      " Se genera la URL para llamar a la BSP
      cl_http_ext_webapp=>create_url_for_bsp_application(
        EXPORTING
          bsp_application      = zif_ca_umdi_data=>cs_yuml_app-bsp
          bsp_start_page       = zif_ca_umdi_data=>cs_yuml_app-page
          bsp_start_parameters = lt_params
        IMPORTING
          abs_url              = DATA(lv_url_bsp) ).

      " Se llama al navegador para lanzar la BPS
      CALL METHOD cl_gui_frontend_services=>execute
        EXPORTING
          document               = lv_url_bsp
          operation              = ' '
        EXCEPTIONS
          file_extension_unknown = 1
          file_not_found         = 1
          path_not_found         = 1
          error_execute_failed   = 3  ""Note 2043916 This is more appropriate with new error handling.
          error_no_gui           = 2
          OTHERS                 = 3.
    ENDIF.

  ENDMETHOD.

  METHOD handle_pbo.
    LOOP AT SCREEN.
      IF screen-group1 = 'YUM'.
        IF p_yuml = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
