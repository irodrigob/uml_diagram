CLASS zcl_ca_umdi_uml_diagram DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING iv_langu TYPE sylangu DEFAULT sy-langu.
    METHODS get_relations
      IMPORTING
        is_sel_screen TYPE zif_ca_umdi_data=>ts_sel_screen
      EXPORTING
        et_relations  TYPE zif_ca_umdi_data=>tt_object_list_ref.
    METHODS generate_code_uml_app
      IMPORTING iv_yuml TYPE sap_bool OPTIONAL
      EXPORTING ev_code TYPE string.
  PROTECTED SECTION.
    DATA mv_langu TYPE sylangu.
    DATA ms_sel_screen TYPE zif_ca_umdi_data=>ts_sel_screen.
    DATA mt_object_list TYPE zif_ca_umdi_data=>tt_object_list.
    DATA mt_object_list_ref TYPE zif_ca_umdi_data=>tt_object_list_ref.
    DATA mo_objects TYPE REF TO zcl_ca_umdi_uml_diagram_obj.
    METHODS get_objects.
    METHODS get_objects_ref.
    METHODS get_objects_relation_type.
    METHODS complete_relation_type_desc.

    METHODS generate_code_yuml
      EXPORTING ev_code TYPE string.
    "! Determina el color del objeto para YUML
    METHODS yuml_determine_color_object
      IMPORTING
        iv_object_type  TYPE any
      RETURNING
        VALUE(rv_color) TYPE string.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ca_umdi_uml_diagram IMPLEMENTATION.


  METHOD get_relations.

    CLEAR: et_relations.

    mo_objects = NEW zcl_ca_umdi_uml_diagram_obj( iv_langu = mv_langu ).

    ms_sel_screen = is_sel_screen.

    " El primer paso es buscar los objetos
    get_objects(  ).

    " Si se han encontrado objetos...
    IF mt_object_list IS NOT INITIAL.

      " se buscan las referencias de cada uno de ellos
      get_objects_ref(  ).

      " Se buscan como se relacionan entre si.
      get_objects_relation_type(  ).

      et_relations = mt_object_list_ref.

    ENDIF.
  ENDMETHOD.

  METHOD get_objects.
    CLEAR mt_object_list.

    mo_objects->get_objects( EXPORTING is_sel_screen = ms_sel_screen
                             IMPORTING et_objects = mt_object_list ).

  ENDMETHOD.

  METHOD constructor.
    mv_langu = iv_langu.
  ENDMETHOD.


  METHOD get_objects_ref.

    " Se instancia la clase encarga de encontrar las referencias
    DATA(lo_ref) = NEW zcl_ref_object(  ).

    LOOP AT mt_object_list ASSIGNING FIELD-SYMBOL(<ls_object>).

      lo_ref->search_refs( EXPORTING iv_object              = <ls_object>-object
                                     iv_type                = <ls_object>-type
                                     iv_level_depth_max     = 1
                           IMPORTING et_refs                = DATA(lt_refs)
                          EXCEPTIONS type_object_not_valid = 1
                                     OTHERS                = 2 ).

      IF sy-subrc = 0.

        " Solo interesan los objetos de referencia que se usan a para montar el diagrama
        LOOP AT lt_refs ASSIGNING FIELD-SYMBOL(<ls_ref>) WHERE ( type_ref = zif_ca_umdi_data=>cs_objects-types-class
                                                                 OR type_ref = zif_ca_umdi_data=>cs_objects-types-interface
                                                                 OR type_ref = zif_ca_umdi_data=>cs_objects-types-program ).

          " Se pasan los datos a una tabla compatible, que incialmente son idénticas. No se ha usado el mismo tipo por que habrá que añadir informaciçpn
          " adicional
          DATA(ls_object_ref) = CORRESPONDING zif_ca_umdi_data=>ts_object_list_ref( <ls_ref> ).
          ls_object_ref = CORRESPONDING #( BASE ( ls_object_ref ) <ls_object> ).

          " Finalmente a la tabla definitiva.
          INSERT ls_object_ref INTO TABLE mt_object_list_ref.


        ENDLOOP.
        CLEAR lt_refs. " Se quita los datos previos
      ELSE.
        " Si no hay referencias se pasa directamente objeto a la tabla de referencias.
        ls_object_ref = CORRESPONDING #( <ls_object> ).
        INSERT ls_object_ref INTO TABLE mt_object_list_ref.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_objects_relation_type.

    " Se recorre cada objeto principal para ir obteniendo los diferentes tipos de asociación.
    " En el caso de las clases se leerá su configuración para saber exactamente su relación.

    LOOP AT mt_object_list_ref ASSIGNING FIELD-SYMBOL(<ls_objects_dummy>)
                               WHERE type_ref IS NOT INITIAL AND object_ref IS NOT INITIAL
                               GROUP BY ( type = <ls_objects_dummy>-type
                                          object = <ls_objects_dummy>-object )
                               ASSIGNING FIELD-SYMBOL(<group>).


      " Si se esta leyendo una clase o interface se lee su informción para saber el tipo de relación
      IF <group>-type = zif_ca_umdi_data=>cs_objects-types-class OR <group>-type = zif_ca_umdi_data=>cs_objects-types-interface.
        mo_objects->get_object_oo_typeinfo( EXPORTING iv_type = <group>-type iv_object = <group>-object
                                            IMPORTING es_typeinfo = DATA(ls_typeinfo) ).
      ENDIF.

      LOOP AT GROUP <group> ASSIGNING FIELD-SYMBOL(<ls_group>).

        " Para aquellos objetos que usa el objeto principal no sea una interface o clase el tipo de relación será la de "use"
        IF <ls_group>-type_ref = zif_ca_umdi_data=>cs_objects-types-class OR <ls_group>-type_ref = zif_ca_umdi_data=>cs_objects-types-interface.
          " Si el tipo de ojeto donde esta y el de referencia son clases se mira: Si es una herencia
          IF <ls_group>-type = zif_ca_umdi_data=>cs_objects-types-class AND <ls_group>-type_ref = zif_ca_umdi_data=>cs_objects-types-class.
            IF <ls_group>-object_ref = ls_typeinfo-inheritance.
              <ls_group>-relation_type = zif_ca_umdi_data=>cs_objects-relation_type-inheritance.
            ELSE. " Si no es herencia, el tipo de relación de será de uso
              <ls_group>-relation_type = zif_ca_umdi_data=>cs_objects-relation_type-use.
            ENDIF.

            " Si el tipo de objeto es una clase y su referencia es una interface hay que mirar si esta declarada en la misma.
          ELSEIF <ls_group>-type = zif_ca_umdi_data=>cs_objects-types-class AND <ls_group>-type_ref = zif_ca_umdi_data=>cs_objects-types-interface.
            READ TABLE ls_typeinfo-interfaces_impl TRANSPORTING NO FIELDS WITH KEY interface = <ls_group>-object_ref.
            IF sy-subrc = 0. " Si existe la relación es una implemetación
              <ls_group>-relation_type = zif_ca_umdi_data=>cs_objects-relation_type-implementing.
            ELSE.
              <ls_group>-relation_type = zif_ca_umdi_data=>cs_objects-relation_type-use.
            ENDIF.
          ELSE. " Cualquier otro objeto se determina como "use"
            <ls_group>-relation_type = zif_ca_umdi_data=>cs_objects-relation_type-use.
          ENDIF.
        ELSE.
          <ls_group>-relation_type = zif_ca_umdi_data=>cs_objects-relation_type-use.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    " Se completan los textos del tipo de relación
    complete_relation_type_desc(  ).

  ENDMETHOD.


  METHOD complete_relation_type_desc.
    LOOP AT mt_object_list_ref ASSIGNING FIELD-SYMBOL(<ls_objects>).
      CASE <ls_objects>-relation_type.
        WHEN zif_ca_umdi_data=>cs_objects-relation_type-inheritance.
          <ls_objects>-relation_type_desc = TEXT-t01.
        WHEN zif_ca_umdi_data=>cs_objects-relation_type-implementing.
          <ls_objects>-relation_type_desc = TEXT-t02.
        WHEN zif_ca_umdi_data=>cs_objects-relation_type-use.
          <ls_objects>-relation_type_desc = TEXT-t03.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_code_uml_app.
    CLEAR ev_code.
    IF iv_yuml = abap_true.
      generate_code_yuml( IMPORTING ev_code = ev_code ).
    ENDIF.
  ENDMETHOD.


  METHOD generate_code_yuml.

    CLEAR ev_code.

    LOOP AT mt_object_list_ref ASSIGNING FIELD-SYMBOL(<ls_objects>).
      DATA(lv_code) = ||.

      " Se determina el color para el tipo de objeto como para su referencia
      DATA(lv_color) = yuml_determine_color_object( iv_object_type = <ls_objects>-type ).
      DATA(lv_color_ref) = yuml_determine_color_object( iv_object_type = <ls_objects>-type_ref ).

      CASE <ls_objects>-relation_type.
        WHEN zif_ca_umdi_data=>cs_objects-relation_type-implementing.
          lv_code = |{ lv_code }[{ <ls_objects>-type } { <ls_objects>-object }{ lv_color }]-.-^[{ <ls_objects>-type_ref } { <ls_objects>-object_ref }{ lv_color_ref }]|.
        WHEN zif_ca_umdi_data=>cs_objects-relation_type-inheritance.
          lv_code = |{ lv_code }[{ <ls_objects>-type } { <ls_objects>-object }{ lv_color }]-^[{ <ls_objects>-type_ref } { <ls_objects>-object_ref }{ lv_color_ref }]|.
        WHEN zif_ca_umdi_data=>cs_objects-relation_type-use.
          lv_code = |{ lv_code }[{ <ls_objects>-type } { <ls_objects>-object }{ lv_color }]->[{ <ls_objects>-type_ref } { <ls_objects>-object_ref }{ lv_color_ref }]|.
      ENDCASE.

      ev_code = COND #( WHEN ev_code IS INITIAL THEN lv_code ELSE |{ ev_code },{ lv_code }| ).

    ENDLOOP.

  ENDMETHOD.


  METHOD yuml_determine_color_object.
    rv_color = |\{bg:white\}|.
    CASE iv_object_type.
      WHEN zif_ca_umdi_data=>cs_objects-types-class.
        rv_color = |\{bg:wheat\}|.
      WHEN zif_ca_umdi_data=>cs_objects-types-interface.
        rv_color = |\{bg:skyblue\}|.
      WHEN zif_ca_umdi_data=>cs_objects-types-function.
        rv_color = |\{bg:tan\}|.
      WHEN zif_ca_umdi_data=>cs_objects-types-program.
        rv_color = |\{bg:steelblue\}|.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
