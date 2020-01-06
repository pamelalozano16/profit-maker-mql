//+------------------------------------------------------------------+
//|                                                      Example.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
//--- input parameters
input int      TakeProfit=30;
input int      StopLoss=30;
double Ask;
double Bid;
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Ask=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   Bid=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   /* POR QUE NO SE CAMBIA EL PROFIT LOSS Y EL TAKE PROFIT
    double sl=(Ask)-(StopLoss*_Point);
    double tp=((Ask)+(TakeProfit*_Point));
   for(int i=0;i<PositionsTotal();i++){
   ulong ticket = PositionGetTicket(i);
    trade.PositionModify(ticket, sl, tp);
   }*/
   
//---
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
   //Alert(ticket);
   //Alert(result.price);
       
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
