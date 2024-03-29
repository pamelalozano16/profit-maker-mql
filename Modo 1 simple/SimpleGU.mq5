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
/*Operation GBP_USD;
Operation GBP_USD;*/

Operation GBP_USD;
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
    /*if(!GBP_USD.active||!GBP_USD.active||!GBP_USD.active){
      
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
      if(ot==TRADE_TRANSACTION_DEAL_ADD&&trans.symbol==GBP_USD.symbol){
                  GUtradeOver();
      }


      

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

//+------------------------------------------------------------------+
int searchHistory(Operation &GBP_USD){
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

void AssignOp(Operation &GBP_USD){
   checkIfActive(GBP_USD);
   updateHistory();
    getHistory(GBP_USD);
   

   
   if(GBP_USD.active){
   GBP_USD.current=GBP_USD.history[0];
   GBP_USD.ct=findType(GBP_USD.current);
   if(GBP_USD.historySize>=3){
   GBP_USD.last=GBP_USD.history[2];
   GBP_USD.lt=findType(GBP_USD.last);
   } else{
   GBP_USD.last=0;
   }
   if(GBP_USD.historySize>=5){
   GBP_USD.second=GBP_USD.history[4];
   GBP_USD.st=findType(GBP_USD.second);
   }else{
      GBP_USD.second=0;
   }
   PrintOp(GBP_USD);
   }
   if(!GBP_USD.active){
   GBP_USD.current=0;
   GBP_USD.ct=NULL;
   GBP_USD.open=0;
   if(GBP_USD.historySize>=2){
      GBP_USD.last=GBP_USD.history[1];
      GBP_USD.lt=findType(GBP_USD.last);
   } else{
      GBP_USD.last=0;
   }
  if(GBP_USD.historySize>=4){
   GBP_USD.second=GBP_USD.history[3];
   GBP_USD.st=findType(GBP_USD.second);
   } else{
      GBP_USD.second=0;
   }
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

 void dealClosed(Operation &GBP_USD){
  // PrintOp(GBP_USD);
  getReasons(GBP_USD);
  
  
  if(GBP_USD.ct=="ORDER_TYPE_BUY"&&GBP_USD.cr==ORDER_REASON_TP){
  Alert(Symbol(), " BUY & TP ", GBP_USD.current);
  placeBuyOrder();
  }
  if(GBP_USD.ct=="ORDER_TYPE_BUY"&&GBP_USD.cr==ORDER_REASON_SL){
  Alert(Symbol(), " BUY & sl ", GBP_USD.current);
  placeSellOrder();
  }
  if(GBP_USD.ct=="ORDER_TYPE_SELL"&&GBP_USD.cr==ORDER_REASON_TP){
  Alert(Symbol(), " SELL & TP ", GBP_USD.current);
  placeSellOrder();
  }
  if(GBP_USD.ct=="ORDER_TYPE_SELL"&&GBP_USD.cr==ORDER_REASON_SL){
  Alert(Symbol(), " SELL & SL ", GBP_USD.current);
   placeBuyOrder();
  }
   /*
  if(GBP_USD.ct=="ORDER_TYPE_BUY"&&GBP_USD.cr==ORDER_REASON_TP&&GBP_USD.lr==ORDER_REASON_TP&&
  GBP_USD.lt=="ORDER_TYPE_BUY"){
  Alert("BUY & 2XTP");
  placeSellOrder();
  }
  if(GBP_USD.ct=="ORDER_TYPE_BUY"&&GBP_USD.cr==ORDER_REASON_TP&&GBP_USD.lr==ORDER_REASON_TP&&
  GBP_USD.lt=="ORDER_TYPE_SELL"){
  Alert(Symbol(), " BUY & TP ", GBP_USD.current);
  placeBuyOrder();
  }
  if(GBP_USD.ct=="ORDER_TYPE_SELL"&&GBP_USD.cr==ORDER_REASON_TP&&GBP_USD.lr==ORDER_REASON_TP&&
  GBP_USD.lt=="ORDER_TYPE_BUY"){
  Alert(Symbol(), " SELL & TP ", GBP_USD.current);
  placeSellOrder();
  }
  if(GBP_USD.ct=="ORDER_TYPE_SELL"&&GBP_USD.cr==ORDER_REASON_TP&&GBP_USD.lr==ORDER_REASON_TP&&
  GBP_USD.lt=="ORDER_TYPE_SELL"){
   Alert("SELL & 2XTP");
  placeBuyOrder();
  }*/
  
 };
 
 void getReasons(Operation &GBP_USD){
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
 GBP_USD.cr=HistoryOrderGetInteger(temp,ORDER_REASON);  
   if(GBP_USD.historySize>=2){
    GBP_USD.lr=HistoryOrderGetInteger(GBP_USD.history[1],ORDER_REASON);  
   } else{
      GBP_USD.lr=ORDER_REASON_CLIENT;
   }
    if(GBP_USD.historySize>=4){
 GBP_USD.sr=HistoryOrderGetInteger(GBP_USD.history[3],ORDER_REASON); 
   } else{
     GBP_USD.sr=ORDER_REASON_CLIENT;
   }
//Alert(GBP_USD.history[1], " ", GBP_USD.history[3]);
 Alert("cr: ", EnumToString( GBP_USD.cr));
  Alert("lr: ", EnumToString( GBP_USD.lr));
  Alert("sr: ", EnumToString( GBP_USD.sr));
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
   request.symbol   =GBP_USD.symbol;                              // símbolo
   request.volume   =GUvolume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_BUY;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)-(GUStopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+(GUTakeProfit*_Point));
   
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
   request.symbol   =GBP_USD.symbol;                              // símbolo
   request.volume   =GUvolume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_SELL;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_BID)+(GUStopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_BID)-(GUTakeProfit*_Point));
   
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

void GUtradeOver(){
       Sleep(5000);
      //int history=searchHistory(GBP_USD);
      checkIfActive(GBP_USD);
    // Alert(history, " ",GBP_USD.historySize);
   if(!GBP_USD.active){
   Alert("Deal Closed");
   dealClosed(GBP_USD);
      }
     AssignOp(GBP_USD);
  }
 
 
 
//+------------------------------------------------------------------+
//| Helper functions                                      |
//+------------------------------------------------------------------+
void updateHistory(){
   datetime end=TimeCurrent();                
   datetime start=end-(2*PeriodSeconds(PERIOD_D1));
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