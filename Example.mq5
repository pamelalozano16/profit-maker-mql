//+------------------------------------------------------------------+
//|                                                      example.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>
//--- input parameters
input int      TakeProfit=30;
input int      StopLoss=30;
input int      volume=1;


CTrade trade;
COrderInfo order;
//Create instance of Ctrade called trade

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//Get the ask price
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK),_Digits);

//Get the bid price
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID),_Digits);

//IF NO ORDER OR POSITIONS EXISTS = NO OPEN ORDERS OR POSITIONS (NOTHING TRADING)
   /* if((OrdersTotal()==0)&&(PositionsTotal()==0)){
       trade.Buy(volume, NULL, Ask, (Ask-(StopLoss*_Point)), (Ask+(TakeProfit*_Point)),
       NULL);
    }*/
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnInit()
  {

   for(int i=0; i<PositionsTotal(); i++)
     {
      long tick= PositionGetTicket(i);
      if(PositionSelectByTicket(tick))
        {
         ENUM_POSITION_PROPERTY_DOUBLE price_pos=PositionGetDouble(POSITION_PRICE_OPEN);
         ENUM_POSITION_TYPE type_pos=PositionGetInteger(POSITION_TYPE,tick);
       //  Alert(price_pos);
        }
     }
      if(PositionsTotal()==0){
    trade.Buy(volume, NULL, Ask,((Ask)-(StopLoss*_Point)),((Ask)+(TakeProfit*_Point)),NULL);
   }
   

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade()
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans)
  {
   ENUM_TRADE_TRANSACTION_TYPE  trans_type=trans.type;
   Comment(trans_type);
   Comment(EnumToString(trans_type));
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
//+------------------------------------------------------------------+
