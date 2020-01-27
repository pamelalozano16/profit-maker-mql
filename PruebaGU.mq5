//+------------------------------------------------------------------+
//|                                                     PruebaGU.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      GUStopLoss;
input int      GUTakeProfit;
input double   GUvolume;

//+------------------------------------------------------------------+
//| Operation Struct                                                 |
//+------------------------------------------------------------------+
struct Operation{
ulong history[];
int historySize;
ulong current;
ulong last;
ulong second;
string symbol;
ulong open;
string ct;
string lt;
string st;
ENUM_ORDER_REASON cr;
ENUM_ORDER_REASON lr;
ENUM_ORDER_REASON sr;
bool active;
};
///
///
//--- Global parameters
Operation GBP_USD;
int currentHistory;
bool tradeOver=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("START");
   //Initialize current history;
   updateHistory();
   currentHistory=HistoryOrdersTotal();

   //Initialize Operation
   getHistory(GBP_USD);
   GBP_USD.symbol=Symbol();
   GBP_USD.current=0;
   GBP_USD.open=1;
   GBP_USD.last=0;
   GBP_USD.second=0;
   AssignOp(GBP_USD);

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

   if(tradeOver){
      AssignOp(GBP_USD);
   if(HistoryDealsTotal()>currentHistory&&!GBP_USD.active){
   Alert("Deal Closed");
      }
      tradeOver=false;
   }
   updateHistory();
   currentHistory=HistoryOrdersTotal();
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---     
      tradeOver=true;

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| EA functions                                      |
//+------------------------------------------------------------------+
void getHistory(Operation &GBP_USD){
   updateHistory();
   int i, j;
   ArrayResize(GBP_USD.history, HistoryOrdersTotal());
   for(i=HistoryOrdersTotal()-1, j=0;i>=0;i--){
      updateHistory();
      ulong ticket=HistoryOrderGetTicket(i);
      if(HistoryOrderSelect(ticket)){
         if(HistoryOrderGetString(ticket, ORDER_SYMBOL)==Symbol()){
           GBP_USD.history[j]=ticket;
           j++;
         }
      }
   }
   ArrayResize(GBP_USD.history, (j+1));
   GBP_USD.historySize=j+1;
}

void AssignOp(Operation &GBP_USD){
   checkIfActive(GBP_USD);
   updateHistory();
   getHistory(GBP_USD);
   
   if(GBP_USD.active){
   GBP_USD.current=GBP_USD.history[0];
   GBP_USD.ct=findType(GBP_USD.current);
   GBP_USD.last=GBP_USD.history[2];
   GBP_USD.second=GBP_USD.history[4];
   GBP_USD.lt=findType(GBP_USD.last);
   GBP_USD.st=findType(GBP_USD.second);
   PrintOp(GBP_USD);
   }
   if(!GBP_USD.active){
   GBP_USD.current=0;
   GBP_USD.ct=NULL;
   GBP_USD.open=0;
   GBP_USD.last=GBP_USD.history[1];
   GBP_USD.second=GBP_USD.history[3];
   GBP_USD.lt=findType(GBP_USD.last);
   GBP_USD.st=findType(GBP_USD.second);
   PrintOp(GBP_USD);
   }
}

void checkIfActive(Operation &GBP_USD){
string symbol=GBP_USD.symbol;
int i;

  for(i=0;i<PositionsTotal()+1;i++){
  string sym=PositionGetSymbol(i);
 // Alert(sym);
  if(GBP_USD.symbol==sym){
   GBP_USD.open=PositionGetTicket(i);
   GBP_USD.active=true;
   break;
   }else{
   GBP_USD.active=false;
   }
  };

}

//+------------------------------------------------------------------+
//| Helper functions                                      |
//+------------------------------------------------------------------+
void updateHistory(){
   datetime end=TimeCurrent();                
   datetime start=end-PeriodSeconds(PERIOD_D1);
   HistorySelect(start,end);
}

void PrintOp(Operation &GBP_USD){
  Alert(GBP_USD.symbol);
  Alert("Open: ", GBP_USD.open);
  Alert("c: ", GBP_USD.current, " ",GBP_USD.ct);
  Alert("l: ", GBP_USD.last, " ", GBP_USD.lt);
  Alert("s: ", GBP_USD.second, " ", GBP_USD.st);

}
string findType(ulong ticket){
  string type;
  if(HistoryOrderSelect(ticket)){
   type= EnumToString(ENUM_ORDER_TYPE(HistoryOrderGetInteger(ticket, ORDER_TYPE)));
  }
  updateHistory();
  return type;
 } 