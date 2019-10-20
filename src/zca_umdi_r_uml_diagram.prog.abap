*&---------------------------------------------------------------------*
*& Report ZCA_UMDI_R_UML_DIAGRAM
*&---------------------------------------------------------------------*
*& Description: Generate the UML diagram according to the objects entered on the screen
* & Author: Iván Rodrigo - 30/09/2019
*&---------------------------------------------------------------------*
REPORT zca_umdi_r_uml_diagram MESSAGE-ID zca_umdi.

INCLUDE zca_umdi_r_uml_diagram_top.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS: s_pack FOR mv_package,
                s_class FOR mv_object MATCHCODE OBJECT seo_classes_interfaces,
                s_intf FOR mv_object MATCHCODE OBJECT seo_classes_interfaces,
                s_report FOR mv_report.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.
PARAMETERS p_yuml AS CHECKBOX USER-COMMAND yuml.
SELECTION-SCREEN BEGIN OF BLOCK blyuml WITH FRAME TITLE TEXT-t03.
PARAMETERS: p_ycode RADIOBUTTON GROUP g1 MODIF ID yum,
            p_yhtml RADIOBUTTON GROUP g1 MODIF ID yum.
SELECTION-SCREEN END OF BLOCK blyuml.
SELECTION-SCREEN END OF BLOCK bl2.

INCLUDE zca_umdi_r_uml_diagram_c01.

AT SELECTION-SCREEN OUTPUT.
  lcl_contr=>handle_pbo( ).


*----------------------------------------------------------------------*
* Start of selection
*----------------------------------------------------------------------*
START-OF-SELECTION.

  " Se instancia el controlador local para la gestion de todos los procesos.
  DATA(lo_contr) = NEW lcl_contr( ).

  " Búsqueda de datos
  lo_contr->search( ).

*----------------------------------------------------------------------*
* End of selection
*----------------------------------------------------------------------*
END-OF-SELECTION.

  lo_contr->show_data( IMPORTING ev_no_data = DATA(lv_no_data) ).

  IF lv_no_data = abap_true.
    MESSAGE TEXT-s01 TYPE zif_ca_umdi_data=>cs_message-types-success.
  ENDIF.
