//+------------------------------------------------------------------+
//|                                                     PruebaGY.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      GYStopLoss;
input int      GYTakeProfit;
input double   GYbalance;
input bool     GYnew=false;

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
/*Operation JPY_USD;
Operation JPY_USD;*/
double GYvolume = 1;
double GYdays= 7;
bool GYnewH=GYnew;
Operation JPY_USD;
int currentHistory;
bool tradeOver=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("START v3.5");
   //Initialize current history;
   updateHistory();
   currentHistory=HistoryOrdersTotal();

   //Initialize Operation
   getHistory(JPY_USD);
   
   MqlDateTime from;
   MqlDateTime to;
   TimeToStruct(TimeCurrent()-(GYdays*PeriodSeconds(PERIOD_D1)), from);
   TimeToStruct(TimeCurrent(), to);
   Alert ("From: ");
   printDate(from);
   Alert("To: ");
   printDate(to);
   
  Alert("Current history: ", JPY_USD.historySize);
   JPY_USD.symbol=Symbol();
   JPY_USD.current=0;
   JPY_USD.open=1;
   JPY_USD.last=0;
   JPY_USD.second=0;
   AssignOp(JPY_USD);
   updateVolume();
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
    /*if(!JPY_USD.active||!JPY_USD.active||!JPY_USD.active){
      
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
      if(ot==TRADE_TRANSACTION_DEAL_ADD&&trans.symbol==JPY_USD.symbol){
                  GYtradeOver();
      }


      

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| EA functions                                      |
//+------------------------------------------------------------------+
int getHistory(Operation &JPY_USD){
   updateHistory();
   int i, j;
   ArrayResize(JPY_USD.history, HistoryOrdersTotal());
   for(i=HistoryOrdersTotal()-1, j=0;i>=0;i--){
      updateHistory();
      ulong ticket=HistoryOrderGetTicket(i);
      if(HistoryOrderSelect(ticket)){
         if(HistoryOrderGetString(ticket, ORDER_SYMBOL)==Symbol()){
           JPY_USD.history[j]=ticket;
         //  Alert(j, " ", ticket);
           j++;
         }
      }
   }
      if(j<6&&!GYnewH){
   GYdays++;
   getHistory(JPY_USD);
   return 0;
   }
   ArrayResize(JPY_USD.history, (j+1));
   JPY_USD.historySize=j;
  /* for(i=0;i<(j+1);i++){
      Alert(i);
      Alert(JPY_USD.history[i]," ");
   }*/
   return 0;
}

//+------------------------------------------------------------------+
int searchHistory(Operation &JPY_USD){
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

void AssignOp(Operation &JPY_USD){
   checkIfActive(JPY_USD);
   updateHistory();
    getHistory(JPY_USD);
   

   
   if(JPY_USD.active){
   JPY_USD.current=JPY_USD.history[0];
   JPY_USD.ct=findType(JPY_USD.current);
   if(JPY_USD.historySize>=3){
   JPY_USD.last=JPY_USD.history[2];
   JPY_USD.lt=findType(JPY_USD.last);
   } else{
   JPY_USD.last=0;
   }
   if(JPY_USD.historySize>=5){
   JPY_USD.second=JPY_USD.history[4];
   JPY_USD.st=findType(JPY_USD.second);
   }else{
      JPY_USD.second=0;
   }
   PrintOp(JPY_USD);
   }
   if(!JPY_USD.active){
   JPY_USD.current=0;
   JPY_USD.ct=NULL;
   JPY_USD.open=0;
   if(JPY_USD.historySize>=2){
      JPY_USD.last=JPY_USD.history[1];
      JPY_USD.lt=findType(JPY_USD.last);
   } else{
      JPY_USD.last=0;
   }
  if(JPY_USD.historySize>=4){
   GYnewH=false;
   JPY_USD.second=JPY_USD.history[3];
   JPY_USD.st=findType(JPY_USD.second);
   } else{
      JPY_USD.second=0;
   }
    PrintOp(JPY_USD);
   }
}

void checkIfActive(Operation &JPY_USD){
string symbol=JPY_USD.symbol;
int i;

  for(i=0;i<PositionsTotal()+1;i++){
  string sym=PositionGetSymbol(i);
 // Alert(sym);
  if(JPY_USD.symbol==sym){
   JPY_USD.open=PositionGetTicket(i);
   JPY_USD.active=true;
   break;
   }else{
   JPY_USD.active=false;
   }
  };

}

 void dealClosed(Operation &JPY_USD){
  // PrintOp(JPY_USD);
  getReasons(JPY_USD);
  
  
  if(JPY_USD.ct=="ORDER_TYPE_BUY"&&JPY_USD.cr==ORDER_REASON_TP&&JPY_USD.lr!=ORDER_REASON_TP){
  Alert(Symbol(), " BUY & TP ", JPY_USD.current);
  placeBuyOrder();
  }
  if(JPY_USD.ct=="ORDER_TYPE_BUY"&&JPY_USD.cr==ORDER_REASON_SL){
  Alert(Symbol(), " BUY & sl ", JPY_USD.current);
  placeSellOrder();
  }
  if(JPY_USD.ct=="ORDER_TYPE_SELL"&&JPY_USD.cr==ORDER_REASON_TP&&JPY_USD.lr!=ORDER_REASON_TP){
  Alert(Symbol(), " SELL & TP ", JPY_USD.current);
  placeSellOrder();
  }
  if(JPY_USD.ct=="ORDER_TYPE_SELL"&&JPY_USD.cr==ORDER_REASON_SL){
  Alert(Symbol(), " SELL & SL ", JPY_USD.current);
   placeBuyOrder();
  }

  if(JPY_USD.ct=="ORDER_TYPE_BUY"&&JPY_USD.cr==ORDER_REASON_TP&&JPY_USD.lr==ORDER_REASON_TP&&
  JPY_USD.lt=="ORDER_TYPE_BUY"){
  Alert("BUY & 2XTP");
  placeSellOrder();
  }
  if(JPY_USD.ct=="ORDER_TYPE_BUY"&&JPY_USD.cr==ORDER_REASON_TP&&JPY_USD.lr==ORDER_REASON_TP&&
  JPY_USD.lt=="ORDER_TYPE_SELL"){
  Alert(Symbol(), " BUY & TP ", JPY_USD.current);
  placeBuyOrder();
  }
  if(JPY_USD.ct=="ORDER_TYPE_SELL"&&JPY_USD.cr==ORDER_REASON_TP&&JPY_USD.lr==ORDER_REASON_TP&&
  JPY_USD.lt=="ORDER_TYPE_BUY"){
  Alert(Symbol(), " SELL & TP ", JPY_USD.current);
  placeSellOrder();
  }
  if(JPY_USD.ct=="ORDER_TYPE_SELL"&&JPY_USD.cr==ORDER_REASON_TP&&JPY_USD.lr==ORDER_REASON_TP&&
  JPY_USD.lt=="ORDER_TYPE_SELL"){
   Alert("SELL & 2XTP");
  placeBuyOrder();
  }
  
 };
 
 void getReasons(Operation &JPY_USD){
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
 JPY_USD.cr=HistoryOrderGetInteger(temp,ORDER_REASON);  
   if(JPY_USD.historySize>=2){
    JPY_USD.lr=HistoryOrderGetInteger(JPY_USD.history[1],ORDER_REASON);  
   } else{
      JPY_USD.lr=ORDER_REASON_CLIENT;
   }
    if(JPY_USD.historySize>=4){
 JPY_USD.sr=HistoryOrderGetInteger(JPY_USD.history[3],ORDER_REASON); 
   } else{
     JPY_USD.sr=ORDER_REASON_CLIENT;
   }
//Alert(JPY_USD.history[1], " ", JPY_USD.history[3]);
 Alert("cr: ", EnumToString( JPY_USD.cr));
  Alert("lr: ", EnumToString( JPY_USD.lr));
  Alert("sr: ", EnumToString( JPY_USD.sr));
 }
 
  void placeBuyOrder(){
  
int err=0;
int c = 0;
int NumberOfTries=5;

 for(c = 0 ; c < NumberOfTries ; c++){
 
      updateVolume();


   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   ZeroMemory(request);

   request.action   =TRADE_ACTION_DEAL;                     // tipo de operación comercial
   request.symbol   =JPY_USD.symbol;                              // símbolo
   request.volume   =GYvolume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_BUY;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)-(GYStopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+(GYTakeProfit*_Point));
   
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
   
   updateVolume();

   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   ZeroMemory(request);

   request.action   =TRADE_ACTION_DEAL;                     // tipo de operación comercial
   request.symbol   =JPY_USD.symbol;                              // símbolo
   request.volume   =GYvolume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_SELL;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_BID)+(GYStopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_BID)-(GYTakeProfit*_Point));
   
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

void GYtradeOver(){
       Sleep(5000);
 //     int history=searchHistory(JPY_USD);
      checkIfActive(JPY_USD);
  //   Alert(history, " ",JPY_USD.historySize);
   if(!JPY_USD.active){
   Alert("Deal Closed");
   dealClosed(JPY_USD);
      }
     AssignOp(JPY_USD);
  }
 
 
 
//+------------------------------------------------------------------+
//| Helper functions                                      |
//+------------------------------------------------------------------+
void updateHistory(){
   datetime end=TimeCurrent();    
   MqlDateTime startDate;            
   datetime start=end-(GYdays*PeriodSeconds(PERIOD_D1));
 /*  TimeToStruct(start, startDate);
   printDate(startDate);*/
   HistorySelect(start,end);
   
}

void PrintOp(Operation &JPY_USD){
  Alert(JPY_USD.symbol);
  Alert("Open: ", JPY_USD.open);
  Alert("c: ", JPY_USD.current, " ",JPY_USD.ct);
  Alert("l: ", JPY_USD.last, " ", JPY_USD.lt);
  Alert("s: ", JPY_USD.second, " ", JPY_USD.st);

}
string findType(ulong ticket){
  string type;
  if(HistoryOrderSelect(ticket)){
   type= EnumToString(ENUM_ORDER_TYPE(HistoryOrderGetInteger(ticket, ORDER_TYPE)));
  }
  updateHistory();
  return type;
 }
 
  
 void updateVolume(){
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance!=GYbalance){
      GYvolume=NormalizeDouble(balance/GYbalance,2);
      Alert("Current volume: ", GYvolume);
      }
   }
   
   void printDate(MqlDateTime &date){
   Alert(date.day, " ",date.mon, " ", date.year, " ", date.hour, 
   ":", date.min,":", date.sec);  
   }