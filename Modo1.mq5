//+------------------------------------------------------------------+
//|                                                      Example.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com
 
// ES NECESARIO HABILITAR EL AUTOMATED TRADING EN OPCIONES Y CUANDO  |
// CORRAS EL PROGRAMA                                                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
//--- input parameters
input int      TakeProfit=30;
input int      StopLoss=30;
input double   volume=0.01;

double Ask;
double Bid;
CTrade trade;
int initialHistory;
ulong lastTicket;
ulong secondlastTicket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//BACKTESTING
   //if(PositionsTotal()==0){
   // trade.Buy(volume, NULL, Ask,((Ask)-(StopLoss*_Point)),((Ask)+(TakeProfit*_Point)),NULL);
   //}
   
   Ask=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   Bid=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   HistorySelect(0,TimeCurrent());
   initialHistory=HistoryOrdersTotal();
   lastTicket=HistoryOrderGetTicket(initialHistory-1);
   secondlastTicket=HistoryOrderGetTicket(initialHistory-3);
   //Alert(lastTicket, " ", secondlastTicket);
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
void OnTick()
  {
//---
   Ask=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   Bid=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   HistorySelect(0,TimeCurrent());
   if(HistoryOrdersTotal()>initialHistory&&PositionsTotal()==0){
   secondlastTicket=lastTicket;
   lastTicket=HistoryOrderGetTicket(HistoryOrdersTotal()-1);
 // Alert("New closed deal. Ticket: ", lastTicket, " Second: ", secondlastTicket);
   DealClosed();
   initialHistory=HistoryOrdersTotal();
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
ENUM_ORDER_TYPE orderType;

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
    
      trade.PositionModify(ticket, sl, tp);

    
      } 
      if(req_order==ORDER_STATE_STARTED&&trans_type==TRADE_TRANSACTION_REQUEST&&
   orderType==ORDER_TYPE_BUY&&positions>0){
   //PLACING AN ORDER TO BUY NO DETECTA MODIFICACIONES
    ulong ticket = PositionGetTicket(0);
    
    double sl=(result.price)-(StopLoss*_Point);
    double tp=((result.price)+(TakeProfit*_Point));
    
    
    Alert("Type: ",EnumToString(orderType));
    
    trade.PositionModify(ticket, sl, tp);
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
  
  void DealClosed(){
  ENUM_ORDER_REASON lastTicketType = HistoryOrderGetInteger(lastTicket, ORDER_REASON);
  ENUM_ORDER_REASON secondTicketType = HistoryOrderGetInteger(secondlastTicket, ORDER_REASON);
  
  if(orderType==ORDER_TYPE_SELL&&lastTicketType==ORDER_REASON_TP&&secondTicketType!=ORDER_REASON_TP){
  Alert("BUY & TP ", trade.RequestActionDescription());
  trade.Buy(volume, NULL, Ask,((Ask)-(StopLoss*_Point)),((Ask)+(TakeProfit*_Point)),NULL);
  }
  if(orderType==ORDER_TYPE_SELL&&lastTicketType==ORDER_REASON_SL){
  Alert("BUY & SL ", trade.RequestActionDescription());
  trade.Sell(volume, NULL, Bid,((Bid)+(StopLoss*_Point)),((Bid)-(TakeProfit*_Point)),NULL);
  }
  if(orderType==ORDER_TYPE_BUY&&lastTicketType==ORDER_REASON_TP&&secondTicketType!=ORDER_REASON_TP){
  Alert("SELL & TP ", trade.RequestActionDescription());
  trade.Sell(volume, NULL, Bid,((Bid)+(StopLoss*_Point)),((Bid)-(TakeProfit*_Point)),NULL);
  }
  if(orderType==ORDER_TYPE_BUY&&lastTicketType==ORDER_REASON_SL){
  Alert("SELL & SL ", trade.RequestActionDescription());
  trade.Buy(volume, NULL, Ask,((Ask)-(StopLoss*_Point)),((Ask)+(TakeProfit*_Point)),NULL);
  }
  
  if(orderType==ORDER_TYPE_SELL&&lastTicketType==ORDER_REASON_TP&&secondTicketType==ORDER_REASON_TP){
  Alert("BUY & 2XTP");
  trade.Sell(volume, NULL, Bid,((Bid)+(StopLoss*_Point)),((Bid)-(TakeProfit*_Point)),NULL);
  }
  if(orderType==ORDER_TYPE_BUY&&lastTicketType==ORDER_REASON_TP&&secondTicketType==ORDER_REASON_TP){
   Alert("SELL & 2XTP");
  trade.Buy(volume, NULL, Ask,((Ask)-(StopLoss*_Point)),((Ask)+(TakeProfit*_Point)),NULL);
  }
  
  
  //Alert(EnumToString(lastTicketType), " " , EnumToString(secondTicketType));
  }
  