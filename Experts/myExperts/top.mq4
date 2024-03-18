//+------------------------------------------------------------------+
//|                                                         Xard.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <utils.mqh>


#define MAGICMA  2024512232

enum EntryStatus  { 
    BUY,
    SELL,
    WAIT,
};
enum ExitStatus {
   CloseBuy,
   CloseSell,
   CloseWAIT,
};



// INPUTS
input double Lots          =0.1;
input double MaximumRisk   =0.02;
input double DecreaseFactor=3;


input string IndicatorInputs = "=========================================";
input int rsi_period = 12;                            //RSI period
input int demarker_period = 12;                       //DeMarker period
input int fisher_period = 12;
input int level_1 = 70;                               //__ top
input int level_2 = 50;                               //__ middle
input int level_3 = 30;                               //__ bottom
input int rsi_width = 1;                              //__ width
input bool fisher_flip = 0;                           //__ flip


// Internal PARAMETERS
double TicketNumber;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason){}

  
void EntryStrategy(){
   switch (getEntryStatus()){
      case BUY:         
         TicketNumber =OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"BUY Order" , MAGICMA,0,clrGreen);
         if(TicketNumber != -1){
            if(OrderSelect(TicketNumber,SELECT_BY_TICKET,MODE_TRADES))
              Comment("BUY order opened : ",OrderOpenPrice());
          } 
         break;
      case SELL:
         TicketNumber =OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"SELL Order" , MAGICMA,0,clrRed);
         if(TicketNumber != -1){
            if(OrderSelect(TicketNumber,SELECT_BY_TICKET,MODE_TRADES))
              Comment("Sell order opened : ",OrderOpenPrice());
          } 
         break;
   }
}
void ExitStrategy(){    
   int orders = CalculateCurrentOrders(MAGICMA);     
   switch (getExitStatus()){
      case CloseBuy:         
         CloseOrder(TicketNumber,Lots,Bid,3);
         break;
      case CloseSell:
         CloseOrder(TicketNumber,Lots,Ask,3);
         break;
   }
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
   if (CalculateCurrentOrders(MAGICMA) == 0){
      EntryStrategy();
   }else{
      ExitStrategy();
   }  
}



EntryStatus getEntryStatus(){

   bool BuyCondition = (getTopSignal(1) > 0 ); 
   bool SellCondition = ( getTopSignal(1) < 0 );
   
   if (BuyCondition){
      return BUY;
   }else if (SellCondition){
      return SELL;
   }else{
      return WAIT;
   }

}  

ExitStatus getExitStatus(){
   int total_orders = CalculateCurrentOrders(MAGICMA);

   bool closeBuyCondition = ( getTopSignal(1) < 0 ); 
   bool closeSellCondition = (  getTopSignal(1) > 0 );
   
   
   if (total_orders == 0) return CloseWAIT;
   
   if (total_orders > 0 && closeBuyCondition){
      return CloseBuy;
   }
   
   if (total_orders < 0 && closeSellCondition ){
      return CloseSell;
   }
   return CloseWAIT;
}



double getTopSignal(int shift){
   double value = iCustom(NULL, 0, "myIndicators\\top",rsi_period,demarker_period,fisher_period,level_1,level_2,level_3,rsi_width,fisher_flip,3, shift);
   return value;
}