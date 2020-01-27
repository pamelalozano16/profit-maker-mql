//+------------------------------------------------------------------+
//|                                                     PruebaEU.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      EUStopLoss;
input int      EUTakeProfit;
input double   EUvolume;

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
Operation EUR_USD;
int currentHistory;
bool tradeOver=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("START v1.3");
   //Initialize current history;
   updateHistory();
   currentHistory=HistoryOrdersTotal();

   //Initialize Operation
   getHistory(EUR_USD);
   EUR_USD.symbol=Symbol();
   EUR_USD.current=0;
   EUR_USD.open=1;
   EUR_USD.last=0;
   EUR_USD.second=0;
   AssignOp(EUR_USD);

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
      int history=searchHistory(EUR_USD);
      checkIfActive(EUR_USD);
      //Alert(history, " ",EUR_USD.historySize);
   if(history>EUR_USD.historySize&&!EUR_USD.active){
   Alert("Deal Closed");
      }
     AssignOp(EUR_USD);
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


  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
      if(result.retcode==10009){
            tradeOver=true;
      }

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| EA functions                                      |
//+------------------------------------------------------------------+
void getHistory(Operation &EUR_USD){
   updateHistory();
   int i, j;
   ArrayResize(EUR_USD.history, HistoryOrdersTotal());
   for(i=HistoryOrdersTotal()-1, j=0;i>=0;i--){
      updateHistory();
      ulong ticket=HistoryOrderGetTicket(i);
      if(HistoryOrderSelect(ticket)){
         if(HistoryOrderGetString(ticket, ORDER_SYMBOL)==Symbol()){
           EUR_USD.history[j]=ticket;
           j++;
         }
      }
   }
   ArrayResize(EUR_USD.history, (j+1));
   EUR_USD.historySize=j+1;
}

//+------------------------------------------------------------------+
int searchHistory(Operation &EUR_USD){
   updateHistory();
   int i, j;
   for(i=HistoryOrdersTotal()-1, j=0;i>=0;i--){
      updateHistory();
      ulong ticket=HistoryOrderGetTicket(i);
      if(HistoryOrderSelect(ticket)){
         if(HistoryOrderGetString(ticket, ORDER_SYMBOL)==Symbol()){
           j++;
         }
      }
   }
   updateHistory();
   return j+1;
}

void AssignOp(Operation &EUR_USD){
   checkIfActive(EUR_USD);
   updateHistory();
    getHistory(EUR_USD);
   

   
   if(EUR_USD.active){
   EUR_USD.current=EUR_USD.history[0];
   EUR_USD.ct=findType(EUR_USD.current);
   EUR_USD.last=EUR_USD.history[2];
   EUR_USD.second=EUR_USD.history[4];
   EUR_USD.lt=findType(EUR_USD.last);
   EUR_USD.st=findType(EUR_USD.second);
   PrintOp(EUR_USD);
   }
   if(!EUR_USD.active){
   EUR_USD.current=0;
   EUR_USD.ct=NULL;
   EUR_USD.open=0;
   EUR_USD.last=EUR_USD.history[1];
   EUR_USD.second=EUR_USD.history[3];
   EUR_USD.lt=findType(EUR_USD.last);
   EUR_USD.st=findType(EUR_USD.second);
   PrintOp(EUR_USD);
   }
}

void checkIfActive(Operation &EUR_USD){
string symbol=EUR_USD.symbol;
int i;

  for(i=0;i<PositionsTotal()+1;i++){
  string sym=PositionGetSymbol(i);
 // Alert(sym);
  if(EUR_USD.symbol==sym){
   EUR_USD.open=PositionGetTicket(i);
   EUR_USD.active=true;
   break;
   }else{
   EUR_USD.active=false;
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

void PrintOp(Operation &EUR_USD){
  Alert(EUR_USD.symbol);
  Alert("Open: ", EUR_USD.open);
  Alert("c: ", EUR_USD.current, " ",EUR_USD.ct);
  Alert("l: ", EUR_USD.last, " ", EUR_USD.lt);
  Alert("s: ", EUR_USD.second, " ", EUR_USD.st);

}
string findType(ulong ticket){
  string type;
  if(HistoryOrderSelect(ticket)){
   type= EnumToString(ENUM_ORDER_TYPE(HistoryOrderGetInteger(ticket, ORDER_TYPE)));
  }
  updateHistory();
  return type;
 } 