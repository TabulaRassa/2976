/* Печать чека через кассовый регистратор     */
/* Copyright (C) АО Банкомсвязь 1998-2000 гг. */

define input parameter rid-doc as integer.
define shared variable uid     as character.

define variable doc-date  as DATE.
define variable rid-main  as integer.
define variable doc-num   as integer.
define variable div       as integer.
define variable wh        as integer.
define variable doc-sum   as decimal.
define variable ware      as character.
define variable tovar-obj as character.
define variable doc-descr as character initial "Кассовый чек".
define variable price     as decimal.
define variable quantity  as decimal.
define variable nal       as character.
define variable rows      as integer.
define variable i         as integer.
define variable command   as character.
define variable inp-file  as character.
define variable back-flag as character.

def temp-table res no-undo
  field rid-wares         as int
  field rec-id            as int
  field quantity          as dec
  field q-type            as int initial 1
  field p-type            as int initial 1
  field price             as dec
  
  index i0 is primary rec-id
  .


find first document where document.rid-document = rid-doc. 
if document.exect then do:
  message "Чек уже напечатан" view-as alert-box.
  return.
end.

run init.
run create-plain.
run create-xml.

procedure init:

  run src/kernel/get_ffv.p ( "1:1", rid-doc ).
  doc-date = DATE(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:2", rid-doc ).
  doc-num = INTEGER(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:3", rid-doc ).
  div = INTEGER(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:4", rid-doc ).
  wh = INTEGER(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:5", rid-doc ).
  doc-sum = DECIMAL(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:7", rid-doc ).
  rid-main = INTEGER(RETURN-VALUE).
  run src/kernel/get_ffv.p ( "1:8", rid-doc ). 
  back-flag = RETURN-VALUE.

  run src/kernel/get_tr.p ( 2, rid-doc, OUTPUT rows ).
  do i = 1 to rows:
    run src/kernel/get_ftv.p ( "2:2", rid-doc, i ).
    find first wares no-lock where
      wares.alfa-cod = RETURN-VALUE no-error.
    if not available wares then
      next.
    run src/kernel/get_ftv.p ( "2:3", rid-doc, i ).
    price = DECIMAL(RETURN-VALUE).
    run src/kernel/get_ftv.p ( "2:5", rid-doc, i ).
    quantity = DECIMAL(RETURN-VALUE).
    create res.
    assign
      res.rec-id = i
      res.rid-wares = wares.rid-wares
      res.quantity = quantity
      res.price = price * 100
      .
  end.
end.

procedure create-plain:
  inp-file = "temp/" + trim(string(doc-num)) + ".csh".
  if uid = "igor_m" then
    message inp-file view-as alert-box.
  OUTPUT TO VALUE(inp-file).
  for each res no-lock
    :

    export delimiter ";" res.
  end.
  OUTPUT CLOSE.
end.

procedure create-xml:

  def var start-request     as char no-undo initial "http://10.9.10.210:8090/21138A37-6E3F-462B-9A62-126BA27646F0/OpenSaleReceiptWithLoad?CallID=".
  def var cash-address      as char no-undo initial "&SystemID=1&SAreaID=1&OperationID=".
  def var end-request       as char no-undo initial "&SlotID=1&CashDeskCompatable=0&IsRestaurantReceipt=1"
  def var receipt-id        as char no-undo initial "&ReceiptID=".

  def var OpenSR            as char no-undo initial "OpenSaleReceiptWithLoad".
  def var SavePR            as char no-undo initial "SavePostponedReceipt".

end.

