//+------------------------------------------------------------------+
//|                                                  Modo1Probar.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input int      TakeProfit=15;
input int      StopLoss=15;
input int      volume=1;

#include <Trade\Trade.mqh>

double Ask;
double Bid;
CTrade trade;
int initialHistory;
ulong lastTicket;
ulong secondlastTicket;
ulong currentTicket;
ulong initialTicket=0;
 string currentType;
 string lastTicketType;
 string secondTicketType;
 
void updateBidAsk(){
   Ask=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   Bid=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
}
void updateHistory(){
    HistorySelect(0,TimeCurrent());
}

string findType(ulong ticket){
  string type;
  if(HistoryOrderSelect(ticket)){
   type= EnumToString(ENUM_ORDER_TYPE(HistoryOrderGetInteger(ticket, ORDER_TYPE)));
  }
  updateHistory();
  return type;
 }
 
 string findReason(ulong ticket){
  string reason;
  if(HistoryOrderSelect(ticket)){
   reason= EnumToString(ENUM_ORDER_REASON(HistoryOrderGetInteger(ticket, ORDER_REASON)));
  }
  updateHistory();
  return reason;
 }
 
 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   Alert(TimeCurrent());
   Alert(TimeCurrent()-__DATE__);

   if(GetLastError()>0){
   Alert("Error: ", GetLastError());
   }
   HistorySelect(0,TimeCurrent());
   initialHistory=HistoryOrdersTotal();
  // Alert("Initial History: ", initialHistory);
   if (PositionsTotal()>0){
   
   currentTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-1);
   currentType = findType(currentTicket);
   //Alert("Current: ", currentTicket, " ", currentType); 
   initialTicket=currentTicket;
   Alert(initialTicket);
   
   updateHistory();
   lastTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-3);
   lastTicketType = findType(lastTicket);
   //Alert("Last: ", lastTicket, " ", lastTicketType); 

   
   updateHistory();
   secondlastTicket=HistoryOrderGetTicket(initialHistory-5);
   secondTicketType = findType(secondlastTicket);
   //Alert("Second last: ", secondlastTicket, " ", secondTicketType); 
   } 
   else{
   
   lastTicket=HistoryOrderGetTicket(initialHistory-2);
   lastTicketType = findType(lastTicket);
   //Alert("Last: ", lastTicket, " ", lastTicketType); 

   secondlastTicket=HistoryOrderGetTicket(initialHistory-4);
   secondTicketType = findType(secondlastTicket);
   //Alert("Second last: ", secondlastTicket, " ", secondTicketType); 

   }
   updateHistory();
  // Alert("Current: ", currentTicket, " ", currentType);
   //Alert("Last: ", lastTicket, " ", lastTicketType);
   //Alert("Second last: ", secondlastTicket, " ", secondTicketType);

   return(INIT_SUCCEEDED);
  }
  

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

ENUM_ORDER_TYPE orderType;

void OnTick()
  {
//---
   if(PositionsTotal()>0&&PositionGetTicket(0)!=currentTicket){
   currentTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-1);
   currentType = findType(currentTicket);
 //  Alert("Current: ", currentTicket, " ", currentType); 
   lastTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-3);
   lastTicketType = findType(lastTicket);
 //  Alert("Last: ", lastTicket, " ", lastTicketType); 
   secondlastTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-5);
   secondTicketType = findType(secondlastTicket);
 //  Alert("Second last: ", secondlastTicket, " ", secondTicketType); 
   }
  // Alert("History Orders total: ", HistoryOrdersTotal());
   if((HistoryOrdersTotal()>initialHistory&&PositionsTotal()==0)||
   (initialTicket>0&&PositionsTotal()==0)){
   if(initialTicket>0){
   orderType=ENUM_ORDER_TYPE(StringToEnum(findType(initialTicket), orderType));
   }
 // Alert("New closed deal. Ticket: ", lastTicket, " Second: ", secondlastTicket);
 
 //AQUI TIENES QUE PASAR COMO PARAMETRO QUE MODO SE VA A APLICAR
 
   DealClosed("modo1");
   initialHistory=HistoryOrdersTotal();
   //INITIAL TICKET
   initialTicket=0;
   }

   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |

//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   ENUM_TRADE_TRANSACTION_TYPE trans_type= (ENUM_TRADE_TRANSACTION_TYPE)trans.type;
   ENUM_ORDER_STATE req_order= (ENUM_ORDER_STATE)request.type;
   ENUM_ORDER_TYPE order_type= (ENUM_ORDER_TYPE)trans.order_type;
   int positions = PositionsTotal();

  if(trans_type==TRADE_TRANSACTION_ORDER_ADD){
    orderType=(ENUM_ORDER_TYPE)order_type;
     }
   if(req_order==ORDER_STATE_PLACED&&trans_type==TRADE_TRANSACTION_REQUEST&&
   orderType==ORDER_TYPE_SELL&&positions>0){
   //PLACING AN ORDER TO SELL NO DETECTA MODIFICACIONES
   ulong ticket = PositionGetTicket(0);
       
    double sl=(result.price)+(StopLoss*_Point);
    double tp=((result.price)-(TakeProfit*_Point));
    
    Alert("Type: ",EnumToString(orderType));
    if(request.sl==0.00000&&request.tp==0.00000){
         // trade.PositionModify(ticket, sl, tp);
    }


    
      } 
      if(req_order==ORDER_STATE_STARTED&&trans_type==TRADE_TRANSACTION_REQUEST&&
   orderType==ORDER_TYPE_BUY&&positions>0){
   //PLACING AN ORDER TO BUY NO DETECTA MODIFICACIONES
    ulong ticket = PositionGetTicket(0);
    
    double sl=(result.price)-(StopLoss*_Point);
    double tp=((result.price)+(TakeProfit*_Point));
    
    
    Alert("Type: ",EnumToString(orderType));
    
        if(request.sl==0.00000&&request.tp==0.00000){
//    trade.PositionModify(ticket, sl, tp);
         }
      } 
   

  }
//+------------------------------------------------------------------+

string GetOrderType(long type)
  {
   string str_type="unknown operation";
   switch(type)
     {
      case(ORDER_TYPE_BUY):
         return("buy");
      case(ORDER_TYPE_SELL):
         return("sell");
      case(ORDER_TYPE_BUY_LIMIT):
         return("buy limit");
      case(ORDER_TYPE_SELL_LIMIT):
         return("sell limit");
      case(ORDER_TYPE_BUY_STOP):
         return("buy stop");
      case(ORDER_TYPE_SELL_STOP):
         return("sell stop");
      case(ORDER_TYPE_BUY_STOP_LIMIT):
         return("buy stop limit");
      case(ORDER_TYPE_SELL_STOP_LIMIT):
         return("sell stop limit");
     }
   return(str_type);
  }
  
  void DealClosed(string modo){
  updateHistory();
  ulong closedTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-1);
  ENUM_ORDER_REASON ticketReason = HistoryOrderGetInteger(closedTicket, ORDER_REASON);
  ulong LastclosedTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-3);
 ENUM_ORDER_REASON lastTicketReason = HistoryOrderGetInteger(LastclosedTicket, ORDER_REASON);
  Alert("Closed: ",closedTicket, " ", LastclosedTicket, " ", lastTicketType);


  Alert("Reason: ", EnumToString(ticketReason), "Last reason: ", EnumToString(lastTicketReason));
  updateBidAsk();
  //Modo 1
  if(modo=="modo1"){
  
  updateBidAsk();
  
    if(orderType==ORDER_TYPE_SELL&&ticketReason==ORDER_REASON_TP&&lastTicketReason!=ORDER_REASON_TP){
  Alert("BUY & TP ", trade.RequestActionDescription());
  placeBuyOrder();
  }
  if(orderType==ORDER_TYPE_SELL&&ticketReason==ORDER_REASON_SL){
  Alert("BUY & SL ", trade.RequestActionDescription());
  placeSellOrder();
  }
  if(orderType==ORDER_TYPE_BUY&&ticketReason==ORDER_REASON_TP&&lastTicketReason!=ORDER_REASON_TP){
  Alert("SELL & TP ", trade.RequestActionDescription());
  placeSellOrder();
  }
  if(orderType==ORDER_TYPE_BUY&&ticketReason==ORDER_REASON_SL){
  Alert("SELL & SL ", trade.RequestActionDescription());
   placeBuyOrder();
  }


  if(orderType==ORDER_TYPE_SELL&&ticketReason==ORDER_REASON_TP&&lastTicketReason==ORDER_REASON_TP&&
  lastTicketType=="ORDER_TYPE_BUY"){
  Alert("BUY & 2XTP");
  placeSellOrder();
  }
  if(orderType==ORDER_TYPE_SELL&&ticketReason==ORDER_REASON_TP&&lastTicketReason==ORDER_REASON_TP&&
  lastTicketType=="ORDER_TYPE_SELL"){
  Alert("BUY & TP");
  placeBuyOrder();
  }
  if(orderType==ORDER_TYPE_BUY&&ticketReason==ORDER_REASON_TP&&lastTicketReason==ORDER_REASON_TP&&
  lastTicketType=="ORDER_TYPE_BUY"){
  Alert("SELL & TP");
  placeSellOrder();
  }
  if(orderType==ORDER_TYPE_BUY&&ticketReason==ORDER_REASON_TP&&lastTicketReason==ORDER_REASON_TP&&
  lastTicketType=="ORDER_TYPE_SELL"){
   Alert("SELL & 2XTP");
  placeBuyOrder();
  }
  
    };
    //END OF FUNCTION DEAL CLOSED
  //Alert(EnumToString(lastTicketType), " " , EnumToString(secondTicketType));
  }
  
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
    }
//+------------------------------------------------------------------+

void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+

void placeBuyOrder(){
int err=0;
int c = 0;
int NumberOfTries=5;

 for(c = 0 ; c < NumberOfTries ; c++){
  updateBidAsk();
  updateHistory();
  if(PositionsTotal()==0){
    trade.Buy(volume, NULL, Ask,((Ask)-(StopLoss*_Point)),((Ask)+(TakeProfit*_Point)),NULL);

  }
    err=GetLastError();

if(err==0)

{

break;

}

else

{
Alert("Error: ", err);
if(err==4 || err==137 ||err==146 || err==136 || err==138||err==4756||err==4752) //Busy errors

{

Sleep(5000);
ResetLastError();
continue;

}

else //normal error

{

break;

}

}

}

}
  
  void placeSellOrder(){
  
int err=0;
int c = 0;
int NumberOfTries=5;

 for(c = 0 ; c < NumberOfTries ; c++){
  updateBidAsk();
  updateHistory();
    if(PositionsTotal()==0){
 trade.Sell(volume, NULL, Bid,((Bid)+(StopLoss*_Point)),((Bid)-(TakeProfit*_Point)),NULL);
 }
   err=GetLastError();

if(err==0)

{

break;

}

else

{
Alert("Error: ", err);

if(err==4 || err==137 ||err==146 || err==136|| err==138||err==4756||err==4752) //Busy errors

{

Sleep(5000);
ResetLastError();
continue;

}

else //normal error

{

break;

}

}

}

}

template<typename T>
T StringToEnum(string str,T enu)
  {
   for(int i=0;i<256;i++)
      if(EnumToString(enu=(T)i)==str)
         return(enu);
//---
   return(-1);
  }