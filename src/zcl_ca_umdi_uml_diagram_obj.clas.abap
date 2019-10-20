CLASS zcl_ca_umdi_uml_diagram_obj DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_langu TYPE sylangu DEFAULT sy-langu.
    METHODS get_objects
      IMPORTING is_sel_screen TYPE zif_ca_umdi_data=>ts_sel_screen
      EXPORTING et_objects    TYPE zif_ca_umdi_data=>tt_object_list.
    METHODS get_object_oo_typeinfo
      IMPORTING
        iv_type     TYPE trobjtype
        iv_object   TYPE any
      EXPORTING
        es_typeinfo TYPE zif_ca_umdi_data=>ts_object_oo_typeinfo.

  PROTECTED SECTION.
    DATA ms_sel_screen TYPE zif_ca_umdi_data=>ts_sel_screen.
    DATA mv_langu TYPE sylangu.
    METHODS get_object_class
      EXPORTING
        et_objects TYPE zif_ca_umdi_data=>tt_object_list.
    METHODS get_object_interface
      EXPORTING
        et_objects TYPE zif_ca_umdi_data=>tt_object_list.
    METHODS get_object_program
      EXPORTING
        et_objects TYPE zif_ca_umdi_data=>tt_object_list.
    METHODS get_object_package
      EXPORTING
        et_objects TYPE zif_ca_umdi_data=>tt_object_list.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ca_umdi_uml_diagram_obj IMPLEMENTATION.


  METHOD constructor.
    mv_langu = iv_langu.

  ENDMETHOD.


  METHOD get_objects.
    CLEAR et_objects.

    ms_sel_screen = is_sel_screen.

    " Se van buscados de los parámetros de selecccion

    " Clases
    get_object_class( IMPORTING et_objects = DATA(lt_class) ).
    INSERT LINES OF lt_class INTO TABLE et_objects.

    " Interface
    get_object_interface( IMPORTING et_objects = DATA(lt_interfaces) ).
    INSERT LINES OF lt_interfaces INTO TABLE et_objects.

    " Programas
    get_object_program( IMPORTING et_objects = DATA(lt_programs) ).
    INSERT LINES OF lt_programs INTO TABLE et_objects.


    " Objetos que esten dentro de una clase
    get_object_package( IMPORTING et_objects = DATA(lt_packages) ).
    INSERT LINES OF lt_packages INTO TABLE et_objects.


    " Se quitan duplicados
    SORT et_objects BY type object.
    DELETE ADJACENT DUPLICATES FROM et_objects COMPARING type object.

  ENDMETHOD.


  METHOD get_object_class.
    FIELD-SYMBOLS <lt_r_object> TYPE zif_ca_umdi_data=>tt_r_object.
    CLEAR et_objects.

    IF ms_sel_screen-class IS BOUND.
      ASSIGN ms_sel_screen-class->* TO <lt_r_object>.

      IF <lt_r_object> IS NOT INITIAL.

        SELECT @zif_ca_umdi_data=>cs_objects-types-class AS type, a~clsname AS object, b~descript AS object_desc INTO TABLE @et_objects
               FROM seoclass AS a LEFT OUTER JOIN seoclasstx AS b
                    ON b~clsname = a~clsname
                       AND b~langu = @mv_langu
               WHERE a~clsname IN @<lt_r_object>
                     AND a~clstype = @zif_ca_umdi_data=>cs_objects-class_type-class.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD get_object_interface.
    FIELD-SYMBOLS <lt_r_object> TYPE zif_ca_umdi_data=>tt_r_object.
    CLEAR et_objects.

    IF ms_sel_screen-interface IS BOUND.
      ASSIGN ms_sel_screen-interface->* TO <lt_r_object>.

      IF <lt_r_object> IS NOT INITIAL.

        SELECT @zif_ca_umdi_data=>cs_objects-types-interface AS type, a~clsname AS object, b~descript AS object_desc INTO TABLE @et_objects
               FROM seoclass AS a LEFT OUTER JOIN seoclasstx AS b
                    ON b~clsname = a~clsname
                       AND b~langu = @mv_langu
               WHERE a~clsname IN @<lt_r_object>
                     AND a~clstype = @zif_ca_umdi_data=>cs_objects-class_type-interface.
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD get_object_program.
    FIELD-SYMBOLS <lt_r_object> TYPE zif_ca_umdi_data=>tt_r_report.
    CLEAR et_objects.

    IF ms_sel_screen-report IS BOUND.
      ASSIGN ms_sel_screen-report->* TO <lt_r_object>.

      IF <lt_r_object> IS NOT INITIAL.

        SELECT @zif_ca_umdi_data=>cs_objects-types-program AS type, a~progname AS object, b~text AS object_desc INTO TABLE @et_objects
               FROM reposrc AS a LEFT OUTER JOIN trdirt AS b
                    ON b~name = a~progname
                       AND b~sprsl = @mv_langu
               WHERE a~progname IN @<lt_r_object>
                     AND a~r3state = 'A'.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_object_package.
    DATA lt_r_object TYPE RANGE OF trobjtype.
    DATA ls_sel_screen TYPE zif_ca_umdi_data=>ts_sel_screen.

    FIELD-SYMBOLS <lt_r_object> TYPE zif_ca_umdi_data=>tt_r_package.
    CLEAR et_objects.

    IF ms_sel_screen-package IS BOUND.
      ASSIGN ms_sel_screen-package->* TO <lt_r_object>.

      IF <lt_r_object> IS NOT INITIAL.

        " Se rellenan los tipos a buscar en los objetos
        lt_r_object = VALUE #( ( sign = 'I' option = 'EQ' low = zif_ca_umdi_data=>cs_objects-types-class )
                              ( sign = 'I' option = 'EQ' low = zif_ca_umdi_data=>cs_objects-types-interface )
                              ( sign = 'I' option = 'EQ' low = zif_ca_umdi_data=>cs_objects-types-program ) ).

        SELECT object, obj_name INTO TABLE @DATA(lt_tadir)
               FROM tadir
               WHERE object IN @lt_r_object
                     AND devclass IN @<lt_r_object>.
        IF sy-subrc = 0.

          " Si hay datos hay que extraer los textos. Para ello primero se extrae los objetos en sus respectivos ranges y se asigna su referencia a la estructura de la pantalla de seleccion

          DATA(lt_r_class) = VALUE zif_ca_umdi_data=>tt_r_object( FOR <wa1> IN lt_tadir WHERE ( object = zif_ca_umdi_data=>cs_objects-types-class  ) ( sign = 'I' option = 'EQ' low = <wa1>-obj_name ) ).
          GET REFERENCE OF lt_r_class[] INTO ls_sel_screen-class.

          DATA(lt_r_int) = VALUE zif_ca_umdi_data=>tt_r_object( FOR <wa1> IN lt_tadir WHERE ( object = zif_ca_umdi_data=>cs_objects-types-interface  ) ( sign = 'I' option = 'EQ' low = <wa1>-obj_name ) ).
          GET REFERENCE OF lt_r_int[] INTO ls_sel_screen-interface.

          DATA(lt_r_prog) = VALUE zif_ca_umdi_data=>tt_r_report( FOR <wa1> IN lt_tadir WHERE ( object = zif_ca_umdi_data=>cs_objects-types-program  ) ( sign = 'I' option = 'EQ' low = <wa1>-obj_name ) ).
          GET REFERENCE OF lt_r_prog[] INTO ls_sel_screen-report.

          " Se instancia la clase en una variable local para que haga la búsqueda de objetos y textos
          NEW zcl_ca_umdi_uml_diagram_obj( iv_langu = mv_langu )->get_objects( EXPORTING is_sel_screen = ls_sel_screen IMPORTING et_objects = et_objects ).

        ENDIF.


      ENDIF.

    ENDIF.


  ENDMETHOD.

  METHOD get_object_oo_typeinfo.
    DATA ls_clskey TYPE seoclskey.
    DATA lt_implementings TYPE seor_implementings_r.
    DATA ls_inheritance TYPE vseoextend.
    DATA lt_comprisings TYPE seor_comprisings_r.

    CLEAR: es_typeinfo.

    " La estructura de acceso es la misma para clase o interface
    ls_clskey-clsname = iv_object.

    CASE iv_type.
      WHEN zif_ca_umdi_data=>cs_objects-types-class.
        " De la clases solo nos interesa las interfaces y la herencia
        CALL FUNCTION 'SEO_CLASS_TYPEINFO_GET'
          EXPORTING
            clskey        = ls_clskey
          IMPORTING
            implementings = lt_implementings " Interface definidas
            inheritance   = ls_inheritance " Herencia
          EXCEPTIONS
            not_existing  = 1
            is_interface  = 2
            model_only    = 3
            OTHERS        = 4.
        IF sy-subrc = 0.
          es_typeinfo-type = iv_type.
          es_typeinfo-object = iv_object.
          es_typeinfo-inheritance = ls_inheritance-refclsname. " Herencia
          " Las interfaces
          LOOP AT lt_implementings ASSIGNING FIELD-SYMBOL(<ls_implementings>).
            INSERT VALUE #( interface = <ls_implementings>-refclsname ) INTO TABLE es_typeinfo-interfaces_impl.
          ENDLOOP.

        ENDIF.
      WHEN zif_ca_umdi_data=>cs_objects-types-interface.
        CALL FUNCTION 'SEO_INTERFACE_TYPEINFO_GET'
          EXPORTING
            intkey       = ls_clskey
          IMPORTING
            comprisings  = lt_comprisings
          EXCEPTIONS
            not_existing = 1
            is_class     = 2
            model_only   = 3
            OTHERS       = 4.
        IF sy-subrc = 0.
          es_typeinfo-type = iv_type.
          es_typeinfo-object = iv_object.
          LOOP AT lt_comprisings ASSIGNING FIELD-SYMBOL(<ls_comprisings>).
            INSERT VALUE #( interface = <ls_comprisings>-refclsname ) INTO TABLE es_typeinfo-interfaces_impl.
          ENDLOOP.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
