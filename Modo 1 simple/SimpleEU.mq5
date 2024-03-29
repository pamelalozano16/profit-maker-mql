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
/*Operation EUR_USD;
Operation EUR_USD;*/

Operation EUR_USD;
int currentHistory;
bool tradeOver=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("START v2.5");
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
    /*if(!EUR_USD.active||!EUR_USD.active||!EUR_USD.active){
      
      Alert("Something not active");
   }*/

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
     // Alert(result.retcode);
       ENUM_TRADE_TRANSACTION_TYPE ot= ENUM_TRADE_TRANSACTION_TYPE(trans.type);
      //Alert(EnumToString(ot),trans.symbol);
      if(ot==TRADE_TRANSACTION_DEAL_ADD&&trans.symbol==EUR_USD.symbol){
                  EUtradeOver();
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
   if(EUR_USD.historySize>=3){
   EUR_USD.last=EUR_USD.history[2];
   EUR_USD.lt=findType(EUR_USD.last);
   } else{
   EUR_USD.last=0;
   }
   if(EUR_USD.historySize>=5){
   EUR_USD.second=EUR_USD.history[4];
   EUR_USD.st=findType(EUR_USD.second);
   }else{
      EUR_USD.second=0;
   }
   PrintOp(EUR_USD);
   }
   if(!EUR_USD.active){
   EUR_USD.current=0;
   EUR_USD.ct=NULL;
   EUR_USD.open=0;
   if(EUR_USD.historySize>=2){
      EUR_USD.last=EUR_USD.history[1];
      EUR_USD.lt=findType(EUR_USD.last);
   } else{
      EUR_USD.last=0;
   }
  if(EUR_USD.historySize>=4){
   EUR_USD.second=EUR_USD.history[3];
   EUR_USD.st=findType(EUR_USD.second);
   } else{
      EUR_USD.second=0;
   }
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

 void dealClosed(Operation &EUR_USD){
  // PrintOp(EUR_USD);
  getReasons(EUR_USD);
  
  
  if(EUR_USD.ct=="ORDER_TYPE_BUY"&&EUR_USD.cr==ORDER_REASON_TP){
  Alert(Symbol(), " BUY & TP ", EUR_USD.current);
  placeBuyOrder();
  }
  if(EUR_USD.ct=="ORDER_TYPE_BUY"&&EUR_USD.cr==ORDER_REASON_SL){
  Alert(Symbol(), " BUY & sl ", EUR_USD.current);
  placeSellOrder();
  }
  if(EUR_USD.ct=="ORDER_TYPE_SELL"&&EUR_USD.cr==ORDER_REASON_TP){
  Alert(Symbol(), " SELL & TP ", EUR_USD.current);
  placeSellOrder();
  }
  if(EUR_USD.ct=="ORDER_TYPE_SELL"&&EUR_USD.cr==ORDER_REASON_SL){
  Alert(Symbol(), " SELL & SL ", EUR_USD.current);
   placeBuyOrder();
  }
   /*
  if(EUR_USD.ct=="ORDER_TYPE_BUY"&&EUR_USD.cr==ORDER_REASON_TP&&EUR_USD.lr==ORDER_REASON_TP&&
  EUR_USD.lt=="ORDER_TYPE_BUY"){
  Alert("BUY & 2XTP");
  placeSellOrder();
  }
  if(EUR_USD.ct=="ORDER_TYPE_BUY"&&EUR_USD.cr==ORDER_REASON_TP&&EUR_USD.lr==ORDER_REASON_TP&&
  EUR_USD.lt=="ORDER_TYPE_SELL"){
  Alert(Symbol(), " BUY & TP ", EUR_USD.current);
  placeBuyOrder();
  }
  if(EUR_USD.ct=="ORDER_TYPE_SELL"&&EUR_USD.cr==ORDER_REASON_TP&&EUR_USD.lr==ORDER_REASON_TP&&
  EUR_USD.lt=="ORDER_TYPE_BUY"){
  Alert(Symbol(), " SELL & TP ", EUR_USD.current);
  placeSellOrder();
  }
  if(EUR_USD.ct=="ORDER_TYPE_SELL"&&EUR_USD.cr==ORDER_REASON_TP&&EUR_USD.lr==ORDER_REASON_TP&&
  EUR_USD.lt=="ORDER_TYPE_SELL"){
   Alert("SELL & 2XTP");
  placeBuyOrder();
  }*/
  
 };
 
 void getReasons(Operation &EUR_USD){
 int i;
 ulong temp;
 updateHistory();
for(i=HistoryOrdersTotal()-1;i>=0;i--){
      updateHistory();
      temp=HistoryOrderGetTicket(i);
      if(HistoryOrderSelect(temp)){
         if(HistoryOrderGetString(temp, ORDER_SYMBOL)==Symbol()){
           break;
         }
      }
    }
    
    updateHistory();
 EUR_USD.cr=HistoryOrderGetInteger(temp,ORDER_REASON);  
   if(EUR_USD.historySize>=2){
    EUR_USD.lr=HistoryOrderGetInteger(EUR_USD.history[1],ORDER_REASON);  
   } else{
      EUR_USD.lr=ORDER_REASON_CLIENT;
   }
    if(EUR_USD.historySize>=4){
 EUR_USD.sr=HistoryOrderGetInteger(EUR_USD.history[3],ORDER_REASON); 
   } else{
     EUR_USD.sr=ORDER_REASON_CLIENT;
   }
//Alert(EUR_USD.history[1], " ", EUR_USD.history[3]);
 Alert("cr: ", EnumToString( EUR_USD.cr));
  Alert("lr: ", EnumToString( EUR_USD.lr));
  Alert("sr: ", EnumToString( EUR_USD.sr));
 }
 
  void placeBuyOrder(){
  
int err=0;
int c = 0;
int NumberOfTries=5;

 for(c = 0 ; c < NumberOfTries ; c++){


   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   ZeroMemory(request);

   request.action   =TRADE_ACTION_DEAL;                     // tipo de operación comercial
   request.symbol   =EUR_USD.symbol;                              // símbolo
   request.volume   =EUvolume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_BUY;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)-(EUStopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+(EUTakeProfit*_Point));
   
   if(!OrderSend(request,result)){

    err=GetLastError();
      }

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

 
 
  void placeSellOrder(){
  
int err=0;
int c = 0;
int NumberOfTries=5;

 for(c = 0 ; c < NumberOfTries ; c++){


   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   ZeroMemory(request);

   request.action   =TRADE_ACTION_DEAL;                     // tipo de operación comercial
   request.symbol   =EUR_USD.symbol;                              // símbolo
   request.volume   =EUvolume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_SELL;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_BID)+(EUStopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_BID)-(EUTakeProfit*_Point));
   
   if(!OrderSend(request,result)){

    err=GetLastError();
      }

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

void EUtradeOver(){
       Sleep(5000);
      //int history=searchHistory(EUR_USD);
      checkIfActive(EUR_USD);
    // Alert(history, " ",EUR_USD.historySize);
   if(!EUR_USD.active){
   Alert("Deal Closed");
   dealClosed(EUR_USD);
      }
     AssignOp(EUR_USD);
  }
 
 
 
//+------------------------------------------------------------------+
//| Helper functions                                      |
//+------------------------------------------------------------------+
void updateHistory(){
   datetime end=TimeCurrent();                
   datetime start=end-(2*PeriodSeconds(PERIOD_D1));
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