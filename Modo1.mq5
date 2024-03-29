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
input double     volume=1.0;

#include <Trade\Trade.mqh>


struct Operation{
int historySize;

ulong current;
ulong last;
ulong second;

string symbol;

string ct;
string lt;
string st;

ENUM_ORDER_REASON cr;
ENUM_ORDER_REASON lr;
ENUM_ORDER_REASON sr;

bool active;
};


double Ask;
double Bid;
CTrade trade;
int initialHistory;
ulong lastTicket;
ulong secondlastTicket;
ulong currentTicket;
 string currentType;
 string lastTicketType;
 string secondTicketType;
 
void updateBidAsk(){
   Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits);
   Bid=NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
}
void updateHistory(){
   datetime end=TimeCurrent();                 // current server time
   datetime start=end-PeriodSeconds(PERIOD_D1);
    HistorySelect(start,end);
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
 

 Operation EUR_USD;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  updateHistory();
 /* ulong tickt=HistoryOrderGetTicket(HistoryOrdersTotal()-1);
   HistoryOrderSelect(tickt);
    string sym;
   sym=HistoryOrderGetString(tickt, ORDER_SYMBOL);*/
  AssignOp(_Symbol, EUR_USD);
  printOp(EUR_USD);
//---
   updateHistory();
   if(GetLastError()>0){
   Alert("Error: ", GetLastError());
   }
   updateHistory();
   initialHistory=HistoryOrdersTotal();
   Alert("Initial History: ", initialHistory);


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
   checkIfActive(EUR_USD);
   if(EUR_USD.active&&EUR_USD.current==0){
   AssignOp(EUR_USD.symbol, EUR_USD);
      //printOp(EUR_USD);
   }
   
   updateHistory();
   
   if(HistoryOrdersTotal()>initialHistory){
   //FOR EVERY SYMBOL
   int i, j;
    for(i=(HistoryOrdersTotal()-1), j=0;i>=0;i--){
         updateHistory();
          ulong t= HistoryOrderGetTicket(i);
          if(HistoryOrderSelect(t)){
             if(EUR_USD.symbol==(HistoryOrderGetString(t, ORDER_SYMBOL))){
                j++;
          };
       }
   };
    updateHistory();
       if(j>EUR_USD.historySize){
    //   Alert("Deal closed");
    dealClosed(EUR_USD);
       }          
   };

   
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
 

  }
//+------------------------------------------------------------------+
  
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

void placeBuyOrder(Operation &EUR_USD){
int err=0;
int c = 0;
int NumberOfTries=5;

 for(c = 0 ; c < NumberOfTries ; c++){
  updateBidAsk();
  updateHistory();

    //trade.Buy(volume, NULL, Ask,((Ask)-(StopLoss*_Point)),((Ask)+(TakeProfit*_Point)),NULL);

   MqlTradeRequest request={0};
   MqlTradeResult  result={0};

   request.action   =TRADE_ACTION_DEAL;                     // tipo de operación comercial
   request.symbol   =Symbol();                              // símbolo
   request.volume   =volume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_BUY;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)-(StopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+(TakeProfit*_Point));
   
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
if(err==4 || err==137 ||err==146 || err==136 || err==138||err==4752||err==4756) //Busy errors

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
  
  void placeSellOrder(Operation &EUR_USD){
  
int err=0;
int c = 0;
int NumberOfTries=5;

 for(c = 0 ; c < NumberOfTries ; c++){
  updateBidAsk();
  updateHistory();

 //trade.Sell(volume, NULL, Bid,((Bid)+(StopLoss*_Point)),((Bid)-(TakeProfit*_Point)),NULL);

   MqlTradeRequest request={0};
   MqlTradeResult  result={0};

   request.action   =TRADE_ACTION_DEAL;                     // tipo de operación comercial
   request.symbol   =Symbol();                              // símbolo
   request.volume   =volume;                                  // volumen de 0.1 lote
   request.type     =ORDER_TYPE_SELL;                        // tipo de orden
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // precio de apertura
   request.deviation=5;                                     // desviación permisible del precio
   request.magic    =0;                         // Número mágico de la orden
   request.sl=(SymbolInfoDouble(Symbol(),SYMBOL_BID)+(StopLoss*_Point));
   request.tp=(SymbolInfoDouble(Symbol(),SYMBOL_BID)-(TakeProfit*_Point));
   
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

void AssignOp(string symbol, Operation &EUR_USD){
EUR_USD.symbol=symbol;
updateHistory();
int size= HistoryOrdersTotal();
ulong arr[];
ArrayResize(arr,size);
int j, i;
   for(i=(HistoryOrdersTotal()-1), j=0;i>=0;i--){
   updateHistory();
   ulong t= HistoryOrderGetTicket(i);
   if(HistoryOrderSelect(t)){
   if(symbol==(HistoryOrderGetString(t, ORDER_SYMBOL))){
   arr[j]=t;
   //Alert(arr[j]);
    j++;
   };
  }
   };
    updateHistory();
    EUR_USD.historySize=j;
    //Alert(j);
//ARR tiene toda la historia de tickets con ese simbolo. La posicion cero tiene el mas reciente.
   checkIfActive(EUR_USD);

  if(EUR_USD.active){
  EUR_USD.current=arr[0];
  EUR_USD.ct=findType(EUR_USD.current);
  if(j>=3){
  EUR_USD.last=arr[2];
  EUR_USD.lt=findType(EUR_USD.last);
  } else{
  EUR_USD.last=0;
  };
  if(j>=5){
  EUR_USD.second=arr[4];
  EUR_USD.st=findType(EUR_USD.second);
  } else{
    EUR_USD.second=0;
  };
  }else if(!EUR_USD.active){
  EUR_USD.current=0;
  //EUR_USD.ct=findType(EUR_USD.current);
    if(j>=2){
  EUR_USD.last=arr[1];
  EUR_USD.lt=findType(EUR_USD.last);}
   else{
  EUR_USD.last=0;
   };
    if(j>=4){
  EUR_USD.second=arr[3];
  EUR_USD.st=findType(EUR_USD.second);
   } else{
  EUR_USD.second=0;
   };
  } 
}

void checkIfActive(Operation &EUR_USD){
string symbol=EUR_USD.symbol;
int i;
  for(i=0;i<PositionsTotal();i++){
  string sym=PositionGetSymbol(i);
 // Alert(sym);
  if(symbol==sym){
   EUR_USD.active=true;
   }
  };
}

void printOp(Operation &EUR_USD){
  Alert("c: ", EUR_USD.current, " ",EUR_USD.ct);
  Alert("l: ", EUR_USD.last, " ", EUR_USD.lt);
  Alert("s: ", EUR_USD.second, " ", EUR_USD.st);
}

void dealClosed(Operation &EUR_USD){
getReasons(EUR_USD);
//Alert(EnumToString(EUR_USD.cr), " ", EnumToString(EUR_USD.lr), " ", EnumToString(EUR_USD.sr));
//printOp(EUR_USD);
updateBidAsk();

//Si toca take profit y el ulitmo no es igual que el current
if((EUR_USD.lt!=EUR_USD.ct||EUR_USD.lr!=ORDER_REASON_TP)&&EUR_USD.cr==ORDER_REASON_TP){
   if(EUR_USD.ct=="ORDER_TYPE_BUY"){
   Alert("buy & tp  ", Symbol());
   placeBuyOrder(EUR_USD);
   }
   if(EUR_USD.ct=="ORDER_TYPE_SELL"){
   Alert("sell & tp  " , Symbol());
   placeSellOrder(EUR_USD);
   }
} 
//Si toca sell loss
if(EUR_USD.cr==ORDER_REASON_SL){
   if(EUR_USD.ct=="ORDER_TYPE_BUY"){
    Alert("buy & sl  ", Symbol());
   placeSellOrder(EUR_USD);
   }
   if(EUR_USD.ct=="ORDER_TYPE_SELL"){
    Alert("sell & sl  ", Symbol());
   placeBuyOrder(EUR_USD);
  }
}
//SI HAY 1SL Y 2TPS SEGUIDOS
if(EUR_USD.lt==EUR_USD.ct&&EUR_USD.cr==ORDER_REASON_TP&&EUR_USD.lr==ORDER_REASON_TP&&
EUR_USD.sr==ORDER_REASON_SL){
   if(EUR_USD.ct=="ORDER_TYPE_BUY"){
    Alert("buy & 2xtp ", Symbol());
   placeSellOrder(EUR_USD);
   }
  if(EUR_USD.ct=="ORDER_TYPE_SELL"){
   Alert("sell & 2xtp  ", Symbol());
   placeBuyOrder(EUR_USD);
   }
}
// 1 TP de lasttype y 2 TP de currenttype
if(EUR_USD.lt==EUR_USD.ct&&EUR_USD.cr==ORDER_REASON_TP&&EUR_USD.lr==ORDER_REASON_TP&&
EUR_USD.sr==ORDER_REASON_TP&&EUR_USD.st!=EUR_USD.lt){
   if(EUR_USD.ct=="ORDER_TYPE_BUY"){
   Alert("buy & tp  ", Symbol());
   placeBuyOrder(EUR_USD);
   }
  if(EUR_USD.ct=="ORDER_TYPE_SELL"){
   Alert("sell & tp  ", Symbol());
   placeSellOrder(EUR_USD);
   }
}
// SI HAY 3 TPS
if(EUR_USD.lt==EUR_USD.ct&&EUR_USD.st==EUR_USD.lt&&EUR_USD.cr==ORDER_REASON_TP&&EUR_USD.lr==ORDER_REASON_TP&&
EUR_USD.sr==ORDER_REASON_TP){
   if(EUR_USD.ct=="ORDER_TYPE_BUY"){
   Alert("buy & 3xtp  ", Symbol());
   placeSellOrder(EUR_USD);
   }
  if(EUR_USD.ct=="ORDER_TYPE_SELL"){
    Alert("sell & 3xtp  ", Symbol());
   placeBuyOrder(EUR_USD);
   }
}
   updateHistory();
   initialHistory=HistoryOrdersTotal();
   AssignOp(EUR_USD.symbol, EUR_USD);

}

void getReasons(Operation &EUR_USD){
updateHistory();
ulong arr[];
ArrayResize(arr,HistoryOrdersTotal());
int j, i;
   for(i=(HistoryOrdersTotal()-1), j=0;i>=0;i--){
   updateHistory();
   ulong t= HistoryOrderGetTicket(i);
   if(HistoryOrderSelect(t)){
   if(EUR_USD.symbol==(HistoryOrderGetString(t, ORDER_SYMBOL))){
   arr[j]=t;
   //Alert(arr[j]);
    j++;
   };
  }
   };
   updateHistory();
   
 EUR_USD.cr=HistoryOrderGetInteger((arr[0]),ORDER_REASON);  
 EUR_USD.lr=HistoryOrderGetInteger((arr[2]),ORDER_REASON);  
 EUR_USD.lr=HistoryOrderGetInteger((arr[4]),ORDER_REASON); 
}