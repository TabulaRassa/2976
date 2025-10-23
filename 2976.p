/* �203 ���ᮢ� 祪 � ������ �� �᪠�쭮� �ਭ�� ��⥪�  */
 
{trigmain.i}
def shared variable uid as character.

def temp-table res no-undo
  field npp             as int
  field alfa-cod        as char
  field quantity        as dec
  field price           as dec
  field summa           as dec
  field akcz            as logical /* �ਧ��� ��樧���� ⮢�� */ 

  index i0 is primary unique npp
  index i1 alfa-cod price

  .
 
PROCEDURE OnBusinessProcess :
  define input parameter rid-typedoc as INTEGER.
  define input parameter rid-main as integer.
  define output parameter rid-doc as integer.

/*
  define variable ok-flag as logical.
  repeat:
    run src/kernel/new_doc.p ( rid-typedoc, rid-main,  OUTPUT rid-doc ).
    if rid-doc = ? then
      run src/textmesl.p ( "�������� ����� ᮧ����� ���㬥�⮢?" , 
                           2, OUTPUT ok-flag ).
      if ok-flag then
        LEAVE.
  end.
*/
  define vari id-doc as integer.                                               
  define vari eng    as logical initial yes.                                   
 
  define variable rid-typedoc-rel as INTEGER.                                    

  define variable lst-rash        as character.
  define variable lst-chk         as character.
 
  if rid-main = ? then  /* ����� ������ ���㬥�� */                         
  do:                                                                          
     run src/kernel/get_fap2.p ( "1:7", rid-typedoc ).
     rid-typedoc-rel = INTEGER (RETURN-VALUE).
     run src/kernel/seldoctp.w ( rid-typedoc-rel, OUTPUT rid-main ).
  end.

  if rid-main <> ? then do:
    /* 31.07.2003 ��堤�� � - ��७�᫠ �஢��� �� ⨯�� ���㬥�⮢ �᭮����� 
    run src/kernel/rel_sum.p (rid-main, "���/����", ?, output sum).
    IF sum <> 0 THEN DO:
       message "�� �⮬� ���㬥��� 㦥 �믨ᠭ� ��������� ���������" view-as alert-box.
      RETURN.
    END.
    /* ���� ���⠢��� ࠧ�襭�� ᮧ����� �� ��᪮�쪮 �������� ��������� */
    */
 
    find first document where
               document.rid-document = rid-main
    no-lock no-error.
    find first typedoc where
               typedoc.rid-typedoc = document.rid-typedoc
    no-lock no-error.
    case typedoc.id-typedoc:
      when 310 then
      do:
        /*---> igor_m ��� ���᭥� � ����� 2 �� ����� 1 �� ᮧ��� 祪 ---*/
        def var id-podr       as int no-undo.
        def var cbook         as int no-undo.
        def var b-count       as char no-undo.
        def var b-an          as char no-undo.
        run src/kernel/get_ffv.p("1:3", rid-main).
        id-podr = int(return-value).
        run src/kernel/get_ffv.p("1:4", rid-main).
        cbook = int(return-value).
        run src/kernel/get_ftv.p("2:1", rid-main, 1).
        b-count = return-value.
        run src/kernel/get_ftv.p("2:2", rid-main, 1).
        b-an = return-value.
        if id-podr = 1 and cbook = 1 and b-count = "0.301.020" and b-an = "320373546" then
        do:
          run src/message_alert.p("���������� ᮧ���� 祪 ��� ����� 1 � ����� 2.").
          return.
        end.

        /*<--- igor_m ��� ���᭥� � ����� 2 �� ����� 1 �� ᮧ��� 祪 ---*/
        run src/kernel/rel_docs1.p ( rid-main, "�����", "", 
            OUTPUT lst-rash ). /* ������⢮ ��室��� � ����� �ਢ易� ��� */
        /*message lst-rash view-as alert-box.*/

        run src/kernel/rel_docs.p ( rid-main, "��� ��.", "", 
            OUTPUT lst-chk ). /* ������⢮ �ਢ易���� 祪�� */
        /*
        message lst-chk view-as alert-box.
        message num-entries (lst-rash) "|" num-entries (lst-chk) view-as alert-box.
        */

        if num-entries (lst-rash) = num-entries (lst-chk) then
        do:
          message "�� ����室��� 祪� 㦥 �믨ᠭ�" view-as alert-box.
          RETURN.
        end.
      end.
    end.
  end.

  run src/kernel/new_doc.p ( rid-typedoc, rid-main,  OUTPUT rid-doc ).

END.
 
PROCEDURE OnNewRelation :
 
  define input parameter rid-doc  as integer.
  define input parameter rid-main as integer.
 
  define variable num     as integer.
  define variable workday as date.
  define variable rows    as integer.
  define variable i       as integer.
  define variable j       as integer.
  define variable k       as integer.

  define variable root        as character.

  define variable lst-rash    as character.
  define variable lst-chk     as character.
  define variable rid-rs      as integer.
  define variable pr          as decimal. /* 業� ���㣫����� �� ���� ������ */
  define variable qv          as decimal. /* ������⢮ */
  define variable sum-opl     as decimal initial 0. /* �㬬� ����祭��� �����⮬ */
  define variable sum-rash    as decimal initial 0. /* �㬬� ��࠭��� �� ��室��� ��������� */
  define variable l           as integer initial 0. 
 
  /* ᮧ����� �� �᭮����� ���, � �� ⮫쪮 ��室��� + 
     ��� � 祪 �� ��९��뢠���� */


  run src/kernel/goperday.p ( OUTPUT workday ).
  run src/kernel/new_dnum.p ( workday, rid-doc, OUTPUT num ).
  run src/kernel/set_ffv.p ( "1:1", rid-doc, STRING(workday) ).
  run src/kernel/set_ffv.p ( "1:2", rid-doc, STRING(num) ).
 
  if rid-main <> ? then do:
  
    find first document where
               document.rid-document = rid-main
    no-lock no-error.
    find first typedoc where
               typedoc.rid-typedoc = document.rid-typedoc
    no-lock no-error.
    case typedoc.id-typedoc:
      when 2975 then
      do:
         run src/kernel/set_ffv.p ( "1:7", rid-doc, STRING(rid-main) ).
         run src/kernel/cp_fld.p ( rid-main,"1:3,1:4,1:18",
                                   rid-doc, "1:3,1:4,1:10").
        
         j = 1.
         run src/kernel/get_tr.p ( 2, rid-main, OUTPUT rows ).
         do i = 1 to rows :
           run src/kernel/get_ftv.p ( "2:2", rid-main, i ).
           run src/kernel/wr_root.p ( RETURN-VALUE, OUTPUT root ).
           if root <> "�" then
           do:
              run src/kernel/set_ftv.p ( "2:1", rid-doc, j, STRING(j) ).
              run src/kernel/get_ftv.p ( "2:2", rid-main, i ).
              run src/kernel/set_ftv.p ( "2:2", rid-doc, j, RETURN-VALUE ).
              run src/kernel/get_ftv.p ( "2:3", rid-main, i ).
              run src/kernel/set_ftv.p ( "2:3", rid-doc, j, RETURN-VALUE ).
              run src/kernel/get_ftv.p ( "2:4", rid-main, i ).
              run src/kernel/set_ftv.p ( "2:5", rid-doc, j, RETURN-VALUE ).
              run src/kernel/get_ftv.p ( "2:5", rid-main, i ).
              run src/kernel/set_ftv.p ( "2:10", rid-doc, j, RETURN-VALUE ).
              run src/kernel/set_ftv.p ( "2:6", rid-doc, j, "�" ).
              j = j + 1.
           end.
         end.                                                
      end.
      when 310 then
      do:

         run src/kernel/set_ffv.p ( "1:9", rid-doc, STRING(rid-main) ).
         
         run src/kernel/rel_docs1.p ( rid-main, "�����", "", 
             OUTPUT lst-rash ). /* ������⢮ ��室��� � ����� �ਢ易� ��� */

         run src/kernel/rel_docs.p ( rid-main, "��� ��.", "", 
             OUTPUT lst-chk ). /* ������⢮ �ਢ易���� 祪�� � ��� */

         do i = 1 to num-entries (lst-rash):
            k = 0.
            do j = 1 to num-entries (lst-chk):
              run src/kernel/get_ffv.p ( "1:7", INTEGER(entry (j, lst-chk)) ).
              IF INTEGER(RETURN-VALUE) = INTEGER ( entry (i, lst-rash)) then 
              do:
                k = 1.
              end.
            end.
            if k = 0 then
            do:
              rid-rs = INTEGER ( entry (i, lst-rash)).
            end.
         end.
         if num-entries (lst-chk) = 0 then 
            rid-rs = INTEGER ( entry (1, lst-rash)).

         run src/kernel/get_tr.p ( 4, rid-main, OUTPUT rows ).
         do i = 1 to rows:
           run src/kernel/get_ftv.p ( "4:2", rid-main, i ).
           if INTEGER (RETURN-VALUE) = rid-rs then
           do:
             run src/kernel/get_ftv.p ( "4:3", rid-main, i ).
             sum-opl = DECIMAL ( RETURN-VALUE ).
             run src/kernel/set_ffv.p ( "1:10", rid-doc, RETURN-VALUE ).
           end.
         end.

         /*message "2- " rid-rs view-as alert-box.*/

         run src/kernel/cp_fld.p ( rid-rs,"1:3,1:4,1:9,1:40,1:42",
                                   rid-doc, "1:3,1:4,1:14,1:12,1:13").
         run src/kernel/set_ffv.p ( "1:7", rid-doc, STRING(rid-rs) ).

         /*---> 18.09.09 igor_m ��᫥����⥫쭠� ����⠭���� ����権 �� � � ���⮬ ��������� 祪�� ---*/
         def var n-row         as int no-undo.
         def var r-doc         as int no-undo.
         def var a-cod         as char no-undo.
         def var a-price       as dec no-undo.
         def var a-quant       as dec no-undo.
         def var ch-list       as char no-undo.                    
         def var t_quant      as int no-undo.
         def var t_sum        as dec no-undo initial 0.
         def var l_sum        as dec no-undo.
         
         run src/kernel/get_ffv.p("1:12", rid-doc).
         if return-value = "" then
         do:
           run src/kernel/get_ftv.p("2:1", rid-main, 1).
           run src/kernel/set_ffv.p("1:12", rid-doc, return-value).
         end.

         run src/kernel/get_tr.p(2, rid-rs, output n-row).      /* 18.09.09 igor_m ����樨 �� ��室��� */
         do i = 1 to n-row:
           run src/kernel/get_ftv.p("2:2", rid-rs, i).
           a-cod = return-value.
           run src/kernel/wr_root.p(a-cod, OUTPUT root ).
           if root = "�" then 
             next.                                              /* 18.09.09 igor_m ��� �� ���� */
           create res.
           res.alfa-cod = a-cod.
           run src/kernel/get_ftv.p("2:1", rid-rs, i).
           res.npp = int(return-value).
           run src/kernel/get_ftv.p("2:3", rid-rs, i).
           res.price = dec(return-value).
           run src/kernel/get_ftv.p("2:4", rid-rs, i).
           res.quantity = dec(return-value).
           run src/kernel/get_ftv.p("2:5", rid-rs, i).
           res.summa = dec(return-value).
           run src/kernel/get_ftv.p("2:18", rid-rs, i).
           if dec(return-value) > 0 then
             res.akcz = yes.
           else
             res.akcz = no.
         end.

         run src/kernel/rel_docs.p(rid-rs, "��� ��.", "", output ch-list).   /* 18.09.09 igor_m �饬 �裡 */
         do i = 1 to num-entries(ch-list):
           r-doc = int(entry(i, ch-list)).
           find first document no-lock where document.rid-doc = r-doc no-error.
           if not available document then
             next.
           find first typedoc of document no-lock.
           if typedoc.id-typedoc <> 203 then
             next.                                              /* 18.09.09 igor_m �᫨ �� 祪, � �� ���� */
           run src/kernel/get_tr.p(2, r-doc, output n-row).
           do j = 1 to n-row:
             run src/kernel/get_ftv.p("2:2", r-doc, j).
             a-cod = return-value.
             run src/kernel/get_ftv.p("2:4", r-doc, j).
             a-price = dec(return-value).
             run src/kernel/get_ftv.p("2:5", r-doc, j).
             a-quant = dec(return-value).
             find first res where 
               res.alfa-cod = a-cod and
               res.price = a-price use-index i1 no-error.
             if not available res then
               next.
             assign
               res.quantity = res.quantity - a-quant
               res.summa = res.summa - a-quant * res.price
               .
             if res.quantity <= 0 then
               delete res.                                      /* 18.09.09 igor_m �, �� ��������� */
           end.
         end.
         
         i = 1.
         sum-rash = 0.
         for each res no-lock 
           use-index i0                /* 18.09.09 igor_m �롨ࠥ� �� ���浪�, �⮡� ������ �� ����� */
           :
         
           sum-rash = sum-rash + res.summa.
           l_sum = sum-opl - (sum-rash - res.quantity * res.price).
           find first wares no-lock where wares.alfa-cod = res.alfa-cod.
           if /*i > 1 and*/ sum-opl < sum-rash then        /* 18.09.09 igor_m �᫨ ��ࢠ� ��ப� - ������塞 ��� ����*/
           do:
            /*----> igor_m 29.09.09 ---*/
            if (res.price > sum-opl) or (res.price > 20) then
            do:
              sum-rash = sum-rash - res.summa.
              next.
            end.
            t_quant = trunc(l_sum / res.price, 0).
            if t_quant <= 0 then
            do:
              sum-rash = sum-rash - res.summa.
              next.
            end.
            t_sum = t_quant * res.price.
            if uid = "dbadmin" then 
              message t_quant skip
                      t_sum skip
                      sum-opl skip
                      sum-rash skip
                      l_sum view-as alert-box.
            run src/kernel/set_ftv.p("2:1", rid-doc, i, string(i)).
            run src/kernel/set_ftv.p("2:2", rid-doc, i, res.alfa-cod).
/*            run src/kernel/getwarp3.p(res.alfa-cod, 30, workday).
            if RETURN-VALUE = ? or
              RETURN-VALUE = "" or
              RETURN-VALUE = "NOT-FOUND" then
              run src/kernel/set_ftv.p("2:3", rid-doc, i, SUBSTRING(wares.wares-name,1,24,"CHARACTER")).
            else
              run src/kernel/set_ftv.p("2:3", rid-doc, i, SUBSTRING(RETURN-VALUE,1,24,"CHARACTER")).*/
            run src/kernel/set_ftv.p("2:3", rid-doc, i, SUBSTRING(wares.wares-name,1,39,"CHARACTER")).
            run src/kernel/set_ftv.p("2:4", rid-doc, i, string(round(res.price, 2))).
            run src/kernel/set_ftv.p("2:5", rid-doc, i, string(t_quant)).
            if res.akcz then
              run src/kernel/set_ftv.p ( "2:6", rid-doc, i, "�" ).
            else
              run src/kernel/set_ftv.p ( "2:6", rid-doc, i, "�" ).

            i = i + 1.
            sum-rash = sum-rash + t_sum.
            l_sum = l_sum - t_sum.

            if round(l_sum, 2) > 0 then
            /*<---- igor_m 29.09.09 ---*/
            do:
              /* �ய���� ⮢�� 4901 ����襭�� ���.������-� � ���-�� = 1 � �� 業� = ࠧ��� */
              run src/kernel/set_ftv.p ( "2:1", rid-doc, i, STRING(i) ).
              run src/kernel/set_ftv.p ( "2:2", rid-doc, i, "4901" ).
           
/*              find first wares no-lock where wares.alfa-cod = "4901".
              run src/kernel/getwarp3.p ( "4901", 30, workday ).
              if RETURN-VALUE = ?  or
                RETURN-VALUE = "" or
                RETURN-VALUE = "NOT-FOUND" then
                run src/kernel/set_ftv.p ( "2:3", rid-doc, i, SUBSTRING(wares.wares-name,1,24,"CHARACTER") ).
              else 
                run src/kernel/set_ftv.p ( "2:3", rid-doc, i, SUBSTRING(RETURN-VALUE,1,24,"CHARACTER") ).*/

              run src/kernel/set_ftv.p("2:3", rid-doc, i, SUBSTRING(wares.wares-name,1,39,"CHARACTER")).

              run src/kernel/set_ftv.p ( "2:4", rid-doc, i, STRING(round(l_sum, 2))).
              run src/kernel/set_ftv.p ( "2:5", rid-doc, i, STRING( 1 ) ).
              if res.akcz then
                run src/kernel/set_ftv.p ( "2:6", rid-doc, i, "�" ).
              else
                run src/kernel/set_ftv.p ( "2:6", rid-doc, i, "�" ).
            end.
            sum-rash = sum-opl.
            leave.
           end.
           
           run src/kernel/set_ftv.p("2:1", rid-doc, i, string(i)).
           run src/kernel/set_ftv.p("2:2", rid-doc, i, res.alfa-cod).
/*           run src/kernel/getwarp3.p(res.alfa-cod, 30, workday).
           if RETURN-VALUE = ? or
             RETURN-VALUE = "" or
             RETURN-VALUE = "NOT-FOUND" then
             run src/kernel/set_ftv.p("2:3", rid-doc, i, SUBSTRING(wares.wares-name,1,24,"CHARACTER")).
           else
             run src/kernel/set_ftv.p("2:3", rid-doc, i, SUBSTRING(RETURN-VALUE,1,24,"CHARACTER")).*/
           run src/kernel/set_ftv.p("2:3", rid-doc, i, SUBSTRING(wares.wares-name,1,39,"CHARACTER")).

           run src/kernel/set_ftv.p("2:4", rid-doc, i, string(round(res.price, 2))).
           run src/kernel/set_ftv.p("2:5", rid-doc, i, string(res.quantity)).
            if res.akcz then
              run src/kernel/set_ftv.p ( "2:6", rid-doc, i, "�" ).
            else
              run src/kernel/set_ftv.p ( "2:6", rid-doc, i, "�" ).
             
           i = i + 1.  
         end.

         if sum-opl < sum-rash then
         do:
           /* �ய���� ⮢�� 4901 ����襭�� ���.������-� � ���-�� = 1 � �� 業� = ࠧ��� 
           �᫨ �� ��諮�� ����樨, ࠧ�����饩 ���. ������. �� �㬬� ����� 20 ��.*/
           run src/kernel/set_ftv.p ( "2:1", rid-doc, i, STRING(i) ).
           run src/kernel/set_ftv.p ( "2:2", rid-doc, i, "4901" ).
        
           find first wares no-lock where wares.alfa-cod = "4901".
           run src/kernel/getwarp3.p ( "4901", 30, workday ).
           if RETURN-VALUE = ?  or
             RETURN-VALUE = "" or
             RETURN-VALUE = "NOT-FOUND" then
             run src/kernel/set_ftv.p ( "2:3", rid-doc, i, SUBSTRING(wares.wares-name,1,24,"CHARACTER") ).
           else 
             run src/kernel/set_ftv.p ( "2:3", rid-doc, i, SUBSTRING(RETURN-VALUE,1,24,"CHARACTER") ).
         
           run src/kernel/set_ftv.p ( "2:4", rid-doc, i, STRING(round( sum-opl - (sum-rash - res.quantity * res.price), 2))).
           run src/kernel/set_ftv.p ( "2:5", rid-doc, i, STRING( 1 ) ).
           run src/kernel/set_ftv.p ( "2:6", rid-doc, i, "�" ).
         end.

         /* 21.09.09 igor_m ��७�� � 祪 ���ᮢ�� ����� �� ��� */
         run src/kernel/get_ffv.p("1:4", rid-main).
         run src/kernel/set_ffv.p("1:11", rid-doc, int(return-value)).
         /*<--- 18.09.09 igor_m ��᫥����⥫쭠� ����⠭���� ����権 �� � � ���⮬ ��������� 祪�� ---*/

      end.
    end.
  end.
END.
 
PROCEDURE OnNewDocument :
  define input parameter rid-doc as integer.
 
  define variable workday as DATE.
  define variable num     as integer.

  run src/kernel/goperday.p ( OUTPUT workday ).
  run src/kernel/set_ffv.p ( "1:1", rid-doc, STRING(workday) ).
  run src/kernel/new_dnum.p ( workday, rid-doc, OUTPUT num ).
  run src/kernel/set_ffv.p ( "1:2", rid-doc, STRING(num) ).
END.
 
PROCEDURE OnCloseDocument :
  define input parameter rid-doc as integer.
 
  define variable doc-date  as DATE.
  define variable rid-main  as integer.
  define variable doc-num   as integer.
  define variable div       as integer.
  define variable wh        as integer.
  define variable doc-sum   as decimal.
  define variable ware      as character.
  define variable tovar-obj as character.
  define variable doc-descr as character initial "��� ��.".
  define variable price     as decimal.
  define variable quantity  as decimal.
  define variable nal       as character.
  define variable rows      as integer.
  define variable i         as integer.
  define variable command   as character.
  define variable inp-file  as character.
  define variable back-flag as character.

  define variable rid-sch   as integer.

  def var disc        as dec no-undo.
 
  run src/kernel/get_ffv.p ( "1:1", rid-doc ).
  doc-date = DATE(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:2", rid-doc ).
  doc-num = INTEGER(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:3", rid-doc ).
  div = INTEGER(RETURN-VALUE).

/*  run src/kernel/get_ffv.p ( "1:5", rid-doc ). ���� �㬬� */
  run src/kernel/get_ffv.p ( "1:10", rid-doc ).
  doc-sum = DECIMAL(RETURN-VALUE).

  run src/kernel/get_ffv.p ( "1:7", rid-doc ).
  rid-main = INTEGER(RETURN-VALUE).

  if doc-sum = 0 then
  do:
    run src/kernel/get_ffv.p("1:18", rid-main).
    doc-sum = DECIMAL(RETURN-VALUE).
    run src/kernel/set_ffv.p("1:10", rid-doc, return-value).
  end.

  run src/kernel/get_ffv.p ( "1:8", rid-doc ).
  Back-flag = RETURN-VALUE. 
  run src/kernel/get_ffv.p ( "1:9", rid-doc ).
  rid-sch = INTEGER(RETURN-VALUE).

  run src/kernel/get_ffv.p("1:15", rid-doc).
  disc = dec(return-value).

  run src/kernel/gen_doc.p ( rid-doc,
    doc-num, div, doc-date, doc-descr, doc-sum, 0 ).
 
  run src/kernel/genrelat.p ( rid-doc, rid-main,     
        doc-descr, "" , doc-sum ).

  run src/kernel/genrelat.p ( rid-doc, rid-sch,     
        doc-descr, "" , doc-sum ).

  /*---> 21.09.09 igor_m ᮧ��� �஢���� �� ���ᮢ�� ����� 2 */  
  def var cbook         as int no-undo.
  def var id-client     as int no-undo.
  run src/kernel/get_ffv.p("1:4", rid-sch).
  cbook = int(return-value).
  run src/kernel/get_ffv.p("1:3", rid-doc).
  id-client = int(return-value).
  if cbook = 2 and id-client = 1 and doc-date >= 09/01/2009 then
  do:
    def var count         as char no-undo.
    def var credit-obj    as char no-undo.
    def var debet-obj     as char no-undo.
    def var acc50         as char no-undo.
    def var sum           as dec no-undo.
    def var vsum          as dec no-undo.
    def var wh-2          as logical no-undo.
    def var fend          as char no-undo.
    def var type-cur      as int no-undo.
    def var rl1           as dec no-undo initial 0.
    def var rl2           as dec no-undo initial 0.
    def var rych          as logical no-undo initial yes.
    def var acc-dp        as char no-undo.
    def var dp-obj        as char no-undo.
    def var rt            as dec no-undo.
    def var accum-rel-sv  as dec no-undo.
    def var rateYCH       as dec no-undo.
    def var rows4         as int no-undo.
    def var currency      as int no-undo.
    def var relat         as logical no-undo initial no.
    def var cash-cnt      as char no-undo.
    def var cash-an       as char no-undo.
    def var t_str         as char no-undo.
    
    run src/kernel/get_ffv.p ( "1:3", rid-doc ).
    fend = string(int(return-value), "9").
    run src/kernel/get_ffv.p("1:11", rid-doc).
    cbook = INTEGER ( RETURN-VALUE ).
    run src/kernel/get_ffv.p("1:5", rid-sch).
    currency = int(return-value).
    run src/kernel/get_ffv.p("�", rid-sch). /* 1:9 */
    wh-2 = logical(return-value).
    run src/kernel/get_ffv.p("1:6", rid-sch).
    type-cur = INTEGER ( RETURN-VALUE ).
    run src/kernel/get_rate.p(doc-date, 1, 3, output rateYCH ).
    run src/kernel/get_ffv.p("1:13", rid-sch).
    acc-dp = RETURN-VALUE.
    run src/kernel/get_ffv.p("1:14", rid-sch).
    dp-obj = RETURN-VALUE.

    run src/kernel/cb_toacc.p ( cbook, OUTPUT acc50 ).
    run src/kernel/cb_toobj.p ( cbook, OUTPUT debet-obj ).

    if disc < 0 then
    do:
      run src/kernel/gen_opr.p(rid-doc, doc-date, "0.949.010", "0.301.020", 376739785, debet-obj, abs(disc), 0, ?, 0, 0, "������").
    end.
    if disc > 0 then
    do:
      run src/kernel/gen_opr.p(rid-doc, doc-date, "0.301.020", "0.719.010", debet-obj, 376739785, abs(disc), 0, ?, 0, 0, "��������").
    end.

    run src/kernel/get_tr.p ( 2, rid-sch, OUTPUT rows ).
    do i = 1 to rows:
      run src/kernel/get_ffv.p ( "2:1", rid-sch).
      count = RETURN-VALUE.
      run src/kernel/get_ffv.p ( "2:2", rid-sch).
      credit-obj = RETURN-VALUE.
      run src/kernel/get_ffv.p ( "2:3", rid-sch).
      vsum = DECIMAL ( RETURN-VALUE ).
      /*---> igor_m 20.04.10 ---*/
/*      run src/kernel/get_ffv.p ( "2:4", rid-sch).*/
      run src/kernel/get_ffv.p("1:5", rid-doc).
      sum = DECIMAL ( RETURN-VALUE ).
      vsum = 0.
      /*<--- igor_m 20.04.10 ---*/
      
      if TRIM (acc50) <> "" then
      do:
        if cbook = 2 then
        run src/kernel/gen_opr.p ( rid-doc, doc-date, acc50, count,               
          debet-obj, credit-obj, sum, currency, type-cur , vsum ,0,                   
          "��室 �।�� � �����" ).                                       
      end.
      else
        run src/kernel/seterror.p ( rid-doc,
         "�� ���ᮢ�� ����� �� ����� �����ᮢ� ���" ).
       /* ��堤�� - ���� ����*/ 
      def var cnt as character.
      if count = "0.361.011" or count = "0.361.010" then 
      do:
         /*!!! 05.04.04 ��堤�� � - ��� ���㯠⥫� ���᭥� */
         if fend = "1" then
            cnt = "1.361.11" + fend.
         else
            cnt = "1.361.01" + fend.
         rl1 = rl1 + 1.
      end.
      if count = "0.372.010" then
      do:
         cnt = "1.372.010".
         rl2 = rl2 + 1.
      end.
      /* 24.03.04 ��堤�� �. - �������� ��� �����⭮� 䨭 ����� */
      if count = "0.505.010" then
      do:
         cnt = "1.505.010".
      end.
      /* !!! 22.04.04 ��堤�� �. - �������� ��� �����⮢ ����� �� ��㣠� */
      if count = "0.631.050" then
      do:
         cnt = "1.631.051".
      end.

/*      run src/kernel/get_ftv.p("2:1", rid-sch, 1).
      if return-value = "0.301.020" then
      do:
         cnt = "1.361.001".         
      end.*/
      /* ��७�᫠ �஢���� ��᫥ ࠧ��᪨ �㬬�
      run src/kernel/gen_opr.p ( rid-doc, doc-date, "1.301.0" + fend, cnt,               
          debet-obj, credit-obj,sum / rt, 0,?,sum,0,                   
          "��室 �।�� � �����" ).                                       
      */
    end.
      
    run src/kernel/get_tr.p ( 2, rid-sch, OUTPUT rows ).
    if wh-2 then                  
    do:
      run src/kernel/get_tr.p(4, rid-sch, output rows4).
      do i = 1 to rows4:
        run src/kernel/get_ftv.p("4:4", rid-sch, i).
        accum-rel-sv = accum-rel-sv + dec(return-value).
        run src/kernel/get_ftv.p("4:2", rid-sch, i).
        relat = (int(return-value) <> 0).
      end.

      /*---> igor_m 20.04.10 ---*/
      run src/kernel/get_ffv.p("1:5", rid-doc).
      accum-rel-sv = dec(return-value).

      /*run src/kernel/get_ffv.p("1:7", rid-sch).*/
      run src/kernel/get_ffv.p("1:5", rid-doc).
      doc-sum = dec(return-value).
      /*<--- igor_m 20.04.10 ---*/
      run src/kernel/get_ffv.p("1:8", rid-sch).
      rt = dec(return-value).
      /*
      run src/kernel/get_ffv.p("1:23", rid-sch).
      rych = logical(return-value).
      */
      run src/kernel/get_ffv.p("1:3", rid-doc).
      id-client = int(return-value).
      run src/kernel/cb_toobj.p(1, OUTPUT debet-obj ).

      if not rych then 
      do:
         if relat then 
         do:
            if rl1 = rows or rl2 = rows then
               run src/kernel/gen_opr.p ( rid-doc, doc-date, "1.301.001", cnt,
                   debet-obj, credit-obj,accum-rel-sv, 0,?,doc-sum,0,
                   "��室 �।�� � �����" ).                                       
            else
               run src/kernel/seterror.p ( rid-doc,
                 "�㬬� �� ࠧ���� ������ �� ��।������ �� ࠧ�� ��⠬ (� 1-�� ⠡���)").
       
         end. 
         else
         do:
            if rl1 = rows or rl2 = rows or ( rl1 = rl2 and rl1 = 0 ) then
               run src/kernel/gen_opr.p ( rid-doc, doc-date, "1.301.001", cnt,               
                   debet-obj, credit-obj,doc-sum / rt, 0,?,doc-sum,0,                   
                   "��室 �।�� � �����" ).                                       
            else
               run src/kernel/seterror.p ( rid-doc,
                 "�㬬� �� ࠧ���� ������ �� ��।������ �� ࠧ�� ��⠬ (� 1-�� ⠡���)").
       
         end.
      end.
      else 
      do:
         if rl1 = rows or rl2 = rows or ( rl1 = rl2 and rl1 = 0 ) then
            run src/kernel/gen_opr.p ( rid-doc, doc-date, "1.301.001", cnt,
                debet-obj, credit-obj, doc-sum / rateYCH, 0,?,doc-sum,0,                   
                "��室 �।�� � �����" ).                                       
      end.
      
      if acc-dp <> "" and dp-obj <> "" then 
      do:
         if rl1 = rows or rl2 = rows or ( rl1 = rl2 and rl1 = 0 ) then
            run src/kernel/gen_opr.p ( rid-doc, doc-date, acc-dp, acc-dp,               
                dp-obj, dp-obj, doc-sum / rateYCH, 0,?,doc-sum,0,                   
                "��室 �।�� � �����" ).                                       
      end.
    end.

    if disc < 0 then
    do:
      run src/kernel/gen_opr.p(rid-doc, doc-date, "1.720.001", "1.301.001", 376739785, debet-obj, abs(disc / rt), 0, ?, abs(disc), 0, "������").
    end.
    if disc > 0 then
    do:
      run src/kernel/gen_opr.p(rid-doc, doc-date, "1.301.001", "1.720.001", debet-obj, 376739785, abs(disc / rt), 0, ?, abs(disc), 0, "��������").
    end.
  end.
  /*<--- 21.09.09 igor_m ᮧ��� �஢���� �� ���ᮢ�� ����� 2 */
END.
 
PROCEDURE OnAddLine :                                                          
  define input parameter rid-doc as integer.                                   
  define input parameter frm as character.                                     
  define input parameter row as integer.                                       
 
  run src/kernel/set_ftv.p ( frm + ":1", rid-doc, row, STRING ( row ) ).       
  run src/kernel/set_ftv.p ( frm + ":6", rid-doc, row, "�" ).       
END.      
 
PROCEDURE OnDeleteLine :
  define input parameter rid-doc as integer.
  define input parameter frm as character.
  define input parameter row as integer.
 
  define variable i         as integer.
  define variable rows      as integer.
  define variable cost      as decimal.
 
  run src/kernel/get_tr.p ( 2, rid-doc, OUTPUT rows ).
  DO i = row to rows:
    run src/kernel/set_ftv.p ( frm + ":1",rid-doc, i, STRING ( i ) ).
  END.
  run src/kernel/get_tfun.p ( "2:10", rid-doc, 1, OUTPUT cost ).
  run src/kernel/set_ffv.p ( "1:5", rid-doc, STRING ( cost ) ).
END.
 
PROCEDURE ONModifyField :
  define input parameter rid-doc as integer.
  define input parameter fld as character.
  define input parameter row as integer.
 
  define var quantity as decimal.
  define var price    as decimal.
  define var cost     as decimal.
  define var sum      as decimal.
  define var ware     as character.
 
  if fld = "1:1" then
  do:
    define variable num as integer.
    run src/kernel/get_ffv.p ( "1:1", rid-doc ).
    run src/kernel/new_dnum.p ( DATE (RETURN-VALUE), rid-doc, OUTPUT num ).
    run src/kernel/set_ffv.p ( "1:2", rid-doc, STRING(num) ). 
  end.
  if fld = "2:2" then
  do:
    define variable doc-date as DATE.
    define variable price-type as integer.
    run src/kernel/get_ffv.p ( "1:1", rid-doc ).
    doc-date = DATE ( RETURN-VALUE ).
    run src/kernel/get_ftv.p ( "2:2", rid-doc, row ).
    ware = RETURN-VALUE.
    find first wares where wares.alfa-cod = ware NO-LOCK NO-ERROR.
    if available wares then
    do:
      run src/kernel/getwarp.p ( wares.rid-wares, 50 ).
      /* 25/01/05 ��堤�� - ���� �⪫�稫� � ��� �� ⮢��� �� ��㯯� � ����*/
      IF RETURN-VALUE  = "NOT-FOUND" or RETURN-VALUE  = ? then
        run src/kernel/set_ftv.p ( "2:6", rid-doc, row, "�" ). /*��������� ��㯯�*/
      else
        run src/kernel/set_ftv.p ( "2:6", rid-doc, row, RETURN-VALUE ). /*��������� ��㯯�*/
      
      /* �ய��뢠��� ��⪮�� �������� ⮢�� ��� 祪� */
/*      run src/kernel/getwarp3.p ( ware, 30, doc-date ).
      if RETURN-VALUE = ?  or
         RETURN-VALUE = "" or
         RETURN-VALUE = "NOT-FOUND" then
      do:
         run src/kernel/set_ftv.p ( "2:3", rid-doc, row, SUBSTRING(wares.wares-name,1,24,"CHARACTER") ).
      end.
      else do:
         run src/kernel/set_ftv.p ( "2:3", rid-doc, row, SUBSTRING(RETURN-VALUE,1,24,"CHARACTER") ).
      end.*/
      run src/kernel/set_ftv.p("2:3", rid-doc, row, SUBSTRING(wares.wares-name,1,39,"CHARACTER")).
    end.

    run src/kernel/get_ffv.p ( "1:6", rid-doc ).
    price-type = INTEGER ( RETURN-VALUE ).
    run src/kernel/wr_price.p ( ware, doc-date, 
      price-type, OUTPUT price ).
    run src/kernel/set_ftv.p ( "2:4", rid-doc, row, STRING ( round(price, 2) ) ).
  end.
  if fld = "2:4" or fld = "2:5" then 
  do:
    run src/kernel/get_ftv.p ( "2:4", rid-doc, row ).
    price = DECIMAL (RETURN-VALUE).
    run src/kernel/get_ftv.p ( "2:5", rid-doc, row ).
    quantity = DECIMAL (RETURN-VALUE).
 
    def var BeforCost as decimal.
    def var BeforSum as decimal.
 
    run src/kernel/get_ffv.p ("1:5", rid-doc ).
    BeforSum = DECIMAL (RETURN-VALUE).
    run src/kernel/get_ftv.p ("2:10", rid-doc, row).
    BeforCost = DECIMAL (RETURN-VALUE).
    cost = quantity * price.
    run src/kernel/set_ftv.p ( "2:10", rid-doc, row, STRING (cost) ).
 
/*    sum = BeforSum - BeforCost + Cost.*/
    
  end.

  if fld = "2:10" then
  do:
    def var disc          as dec no-undo.
    run src/kernel/get_tfun.p ( "2:10", rid-doc, 1, OUTPUT sum).
    run src/kernel/set_ffv.p ( "1:5", rid-doc, STRING(Sum)).

    disc = round(sum, 1) - sum.
    sum = sum + disc.
    run src/kernel/set_ffv.p("1:15", rid-doc, string(disc)).
    run src/kernel/set_ffv.p("1:5", rid-doc, string(sum)).
  end.

END.
 
PROCEDURE OnBarCode :
  define input parameter rid-doc as integer.
  define input parameter fld as character.
  define input parameter row as integer.
  define input parameter barcode as character.
 
  if SUBSTRING ( fld, 1, 1) <> "2" then RETURN "".
 
  define variable rows as integer.
  define variable code as character.
  define variable quantity as decimal.
  define variable ware as character.
 
  if INTEGER(SUBSTRING (barcode, 1, 2)) = 2 or 
     INTEGER(SUBSTRING (barcode, 1, 2)) >= 20 and
     INTEGER(SUBSTRING (barcode, 1, 2)) <= 29 then
  do:
    code = SUBSTRING ( barcode, 3, 5).
    quantity = DECIMAL ( SUBSTRING ( barcode, 8, 5) ) / 1000.
  end.
  else
  do:
    code = barcode.
    quantity = 1.
  end.
  run src/kernel/bar2ware.p ( code, OUTPUT ware ).
  run src/kernel/get_tr.p ( 2, rid-doc, OUTPUT rows ).
  run src/kernel/get_ftv.p ( "2:2", rid-doc, row ).
  if RETURN-VALUE = "" then rows = row - 1.
  run src/kernel/set_ftv.p ( "2:1", rid-doc, rows + 1, STRING (rows + 1) ).
  run src/kernel/set_ftv.p ( "2:2", rid-doc, rows + 1, ware ).
  run src/kernel/set_ftv.p ( "2:5", rid-doc, rows + 1, STRING(quantity) ).
END.

 