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
/*Operation GBP_JPY;
Operation GBP_JPY;*/
double GYvolume = 1;
double GYdays= 7;
Operation GBP_JPY;
int currentHistory;
bool tradeOver=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("START v3.4");
   //Initialize current history;
   updateHistory();
   currentHistory=HistoryOrdersTotal();

   //Initialize Operation
   getHistory(GBP_JPY);
   
   MqlDateTime from;
   MqlDateTime to;
   TimeToStruct(TimeCurrent()-(GYdays*PeriodSeconds(PERIOD_D1)), from);
   TimeToStruct(TimeCurrent(), to);
   Alert ("From: ");
   printDate(from);
   Alert("To: ");
   printDate(to);
   
  Alert("Current history: ", GBP_JPY.historySize);
   GBP_JPY.symbol=Symbol();
   GBP_JPY.current=0;
   GBP_JPY.open=1;
   GBP_JPY.last=0;
   GBP_JPY.second=0;
   AssignOp(GBP_JPY);
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
    /*if(!GBP_JPY.active||!GBP_JPY.active||!GBP_JPY.active){
      
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
      if(ot==TRADE_TRANSACTION_DEAL_ADD&&trans.symbol==GBP_JPY.symbol){
                  GYtradeOver();
      }


      

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| EA functions                                      |
//+------------------------------------------------------------------+
int getHistory(Operation &GBP_JPY){
   updateHistory();
   int i, j;
   ArrayResize(GBP_JPY.history, HistoryOrdersTotal());
   for(i=HistoryOrdersTotal()-1, j=0;i>=0;i--){
      updateHistory();
      ulong ticket=HistoryOrderGetTicket(i);
      if(HistoryOrderSelect(ticket)){
         if(HistoryOrderGetString(ticket, ORDER_SYMBOL)==Symbol()){
           GBP_JPY.history[j]=ticket;
         //  Alert(j, " ", ticket);
           j++;
         }
      }
   }
      if(j<6&&!GYnew){
   GYdays++;
   getHistory(GBP_JPY);
   return 0;
   }
   ArrayResize(GBP_JPY.history, (j+1));
   GBP_JPY.historySize=j;
  /* for(i=0;i<(j+1);i++){
      Alert(i);
      Alert(GBP_JPY.history[i]," ");
   }*/
   return 0;
}

//+------------------------------------------------------------------+
int searchHistory(Operation &GBP_JPY){
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

void AssignOp(Operation &GBP_JPY){
   checkIfActive(GBP_JPY);
   updateHistory();
    getHistory(GBP_JPY);
   

   
   if(GBP_JPY.active){
   GBP_JPY.current=GBP_JPY.history[0];
   GBP_JPY.ct=findType(GBP_JPY.current);
   if(GBP_JPY.historySize>=3){
   GBP_JPY.last=GBP_JPY.history[2];
   GBP_JPY.lt=findType(GBP_JPY.last);
   } else{
   GBP_JPY.last=0;
   }
   if(GBP_JPY.historySize>=5){
   GBP_JPY.second=GBP_JPY.history[4];
   GBP_JPY.st=findType(GBP_JPY.second);
   }else{
      GBP_JPY.second=0;
   }
   PrintOp(GBP_JPY);
   }
   if(!GBP_JPY.active){
   GBP_JPY.current=0;
   GBP_JPY.ct=NULL;
   GBP_JPY.open=0;
   if(GBP_JPY.historySize>=2){
      GBP_JPY.last=GBP_JPY.history[1];
      GBP_JPY.lt=findType(GBP_JPY.last);
   } else{
      GBP_JPY.last=0;
   }
  if(GBP_JPY.historySize>=4){
   GBP_JPY.second=GBP_JPY.history[3];
   GBP_JPY.st=findType(GBP_JPY.second);
   } else{
      GBP_JPY.second=0;
   }
    PrintOp(GBP_JPY);
   }
}

void checkIfActive(Operation &GBP_JPY){
string symbol=GBP_JPY.symbol;
int i;

  for(i=0;i<PositionsTotal()+1;i++){
  string sym=PositionGetSymbol(i);
 // Alert(sym);
  if(GBP_JPY.symbol==sym){
   GBP_JPY.open=PositionGetTicket(i);
   GBP_JPY.active=true;
   break;
   }else{
   GBP_JPY.active=false;
   }
  };

}

 void dealClosed(Operation &GBP_JPY){
  // PrintOp(GBP_JPY);
  getReasons(GBP_JPY);
  
  
  if(GBP_JPY.ct=="ORDER_TYPE_BUY"&&GBP_JPY.cr==ORDER_REASON_TP&&GBP_JPY.lr!=ORDER_REASON_TP){
  Alert(Symbol(), " BUY & TP ", GBP_JPY.current);
  placeBuyOrder();
  }
  if(GBP_JPY.ct=="ORDER_TYPE_BUY"&&GBP_JPY.cr==ORDER_REASON_SL){
  Alert(Symbol(), " BUY & sl ", GBP_JPY.current);
  placeSellOrder();
  }
  if(GBP_JPY.ct=="ORDER_TYPE_SELL"&&GBP_JPY.cr==ORDER_REASON_TP&&GBP_JPY.lr!=ORDER_REASON_TP){
  Alert(Symbol(), " SELL & TP ", GBP_JPY.current);
  placeSellOrder();
  }
  if(GBP_JPY.ct=="ORDER_TYPE_SELL"&&GBP_JPY.cr==ORDER_REASON_SL){
  Alert(Symbol(), " SELL & SL ", GBP_JPY.current);
   placeBuyOrder();
  }

  if(GBP_JPY.ct=="ORDER_TYPE_BUY"&&GBP_JPY.cr==ORDER_REASON_TP&&GBP_JPY.lr==ORDER_REASON_TP&&
  GBP_JPY.lt=="ORDER_TYPE_BUY"){
  Alert("BUY & 2XTP");
  placeSellOrder();
  }
  if(GBP_JPY.ct=="ORDER_TYPE_BUY"&&GBP_JPY.cr==ORDER_REASON_TP&&GBP_JPY.lr==ORDER_REASON_TP&&
  GBP_JPY.lt=="ORDER_TYPE_SELL"){
  Alert(Symbol(), " BUY & TP ", GBP_JPY.current);
  placeBuyOrder();
  }
  if(GBP_JPY.ct=="ORDER_TYPE_SELL"&&GBP_JPY.cr==ORDER_REASON_TP&&GBP_JPY.lr==ORDER_REASON_TP&&
  GBP_JPY.lt=="ORDER_TYPE_BUY"){
  Alert(Symbol(), " SELL & TP ", GBP_JPY.current);
  placeSellOrder();
  }
  if(GBP_JPY.ct=="ORDER_TYPE_SELL"&&GBP_JPY.cr==ORDER_REASON_TP&&GBP_JPY.lr==ORDER_REASON_TP&&
  GBP_JPY.lt=="ORDER_TYPE_SELL"){
   Alert("SELL & 2XTP");
  placeBuyOrder();
  }
  
 };
 
 void getReasons(Operation &GBP_JPY){
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
 GBP_JPY.cr=HistoryOrderGetInteger(temp,ORDER_REASON);  
   if(GBP_JPY.historySize>=2){
    GBP_JPY.lr=HistoryOrderGetInteger(GBP_JPY.history[1],ORDER_REASON);  
   } else{
      GBP_JPY.lr=ORDER_REASON_CLIENT;
   }
    if(GBP_JPY.historySize>=4){
 GBP_JPY.sr=HistoryOrderGetInteger(GBP_JPY.history[3],ORDER_REASON); 
   } else{
     GBP_JPY.sr=ORDER_REASON_CLIENT;
   }
//Alert(GBP_JPY.history[1], " ", GBP_JPY.history[3]);
 Alert("cr: ", EnumToString( GBP_JPY.cr));
  Alert("lr: ", EnumToString( GBP_JPY.lr));
  Alert("sr: ", EnumToString( GBP_JPY.sr));
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
   request.symbol   =GBP_JPY.symbol;                              // símbolo
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
   request.symbol   =GBP_JPY.symbol;                              // símbolo
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
 //     int history=searchHistory(GBP_JPY);
      checkIfActive(GBP_JPY);
  //   Alert(history, " ",GBP_JPY.historySize);
   if(!GBP_JPY.active){
   Alert("Deal Closed");
   dealClosed(GBP_JPY);
      }
     AssignOp(GBP_JPY);
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

void PrintOp(Operation &GBP_JPY){
  Alert(GBP_JPY.symbol);
  Alert("Open: ", GBP_JPY.open);
  Alert("c: ", GBP_JPY.current, " ",GBP_JPY.ct);
  Alert("l: ", GBP_JPY.last, " ", GBP_JPY.lt);
  Alert("s: ", GBP_JPY.second, " ", GBP_JPY.st);

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