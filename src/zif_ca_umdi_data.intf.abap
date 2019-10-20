INTERFACE zif_ca_umdi_data
  PUBLIC .

  " Data types
  TYPES: tv_relation_type TYPE c LENGTH 2.

  TYPES:
  " Ranges
    tt_r_object TYPE RANGE OF seoclass-clsname .
  TYPES:
    tt_r_package TYPE RANGE OF devclass .
  TYPES:
    tt_r_report TYPE RANGE OF reposrc-progname .


  " Constantes
  CONSTANTS: BEGIN OF cs_objects,
               BEGIN OF class_type,
                 class     TYPE seoclstype VALUE '0',
                 interface TYPE seoclstype VALUE '1',
               END OF class_type,
               BEGIN OF types,
                 program   TYPE trobjtype VALUE 'PROG',
                 class     TYPE trobjtype VALUE 'CLAS',
                 interface TYPE trobjtype VALUE 'INTF',
                 function  TYPE trobjtype VALUE 'FUNC',
               END OF types,
               BEGIN OF states,
                 active TYPE r3state VALUE 'A',
               END OF states,
               BEGIN OF relation_type,
                 inheritance  TYPE tv_relation_type VALUE 'IN',
                 use          TYPE tv_relation_type VALUE 'US',
                 implementing TYPE tv_relation_type VALUE 'IM',
               END OF relation_type,
             END OF cs_objects.
  CONSTANTS: BEGIN OF cs_message,
               BEGIN OF types,
                 error   TYPE c LENGTH 1 VALUE 'E',
                 success TYPE c LENGTH 1 VALUE 'S',
               END OF types,
             END OF cs_message.
  CONSTANTS: BEGIN OF cs_yuml_app,
               bsp  TYPE string VALUE 'ZCA_UMDI_YUML',
               page TYPE string VALUE 'index.html',
             END OF cs_yuml_app.


  " Types
  TYPES:
    BEGIN OF ts_sel_screen,
      class     TYPE REF TO data, "tt_r_object,
      interface TYPE REF TO data, "tt_r_object,
      package   TYPE REF TO data, "tt_r_package,
      report    TYPE REF TO data, "tt_r_report,
    END OF ts_sel_screen .
  TYPES:
    " Lista de objetos encontrados según criterios de búsqueda
    BEGIN OF ts_object_list,
      type        TYPE trobjtype,
      object      TYPE progname,
      object_desc TYPE string,
    END OF ts_object_list .
  TYPES:
    tt_object_list TYPE STANDARD TABLE OF ts_object_list WITH EMPTY KEY .
  TYPES:
    " Lista de objetos y que referencias utilizan.
    BEGIN OF ts_object_list_ref,
      type               TYPE trobjtype,
      object             TYPE progname,
      object_desc        TYPE string,
      internal_name      TYPE progname,
      type_ref           TYPE trobjtype,
      object_ref         TYPE string,
      fullname_ref       TYPE string,
      internal_name_ref  TYPE progname,
      relation_type      TYPE tv_relation_type,
      relation_type_desc TYPE string,
    END OF ts_object_list_ref .
  TYPES:
    tt_object_list_ref TYPE STANDARD TABLE OF ts_object_list_ref WITH EMPTY KEY .

  " Información técnica de la clase/interface
  TYPES: BEGIN OF ts_interface_typeinfo,
           interface TYPE seoclsname,
         END OF ts_interface_typeinfo.
  TYPES tt_interface_typeinfo TYPE STANDARD TABLE OF ts_interface_typeinfo WITH EMPTY KEY.
  TYPES: BEGIN OF ts_object_oo_typeinfo,
           type            TYPE trobjtype,
           object          TYPE progname,
           interfaces_impl TYPE tt_interface_typeinfo,
           inheritance     TYPE seoclsname,
         END OF ts_object_oo_typeinfo.
  TYPES: tt_object_oo_typeinfo TYPE STANDARD TABLE OF ts_object_oo_typeinfo WITH EMPTY KEY.

ENDINTERFACE.
