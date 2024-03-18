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


input string Indicator_Inputs    = "==================================";
// INDICATOR VARIABLE
input int    MaFastPeriod        = 9;
input int    MaFastMethod        = MODE_EMA;
input int    MaFastPrice         = PRICE_MEDIAN;
input int    MaMediumPeriod      = 36;
input int    MaMediumMethod      = MODE_EMA;
input int    MaMediumPrice       = PRICE_MEDIAN;
input int    MaHighPeriod        = 36;
input int    MaHighMethod        = MODE_EMA;
input int    MaHighPrice         = PRICE_HIGH;
input int    MaLowPeriod         = 36;
input int    MaLowMethod         = MODE_EMA;
input int    MaLowPrice          = PRICE_LOW;
input int    SignalSize          = 15;                  
input int    Corner              = 3;  
input int    ShiftToTheLeft      = 100; 
input double ShiftToTheRight     = 100;

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

   bool BuyCondition = (get2Factor(0) > 0 ); 
   bool SellCondition = ( get2Factor(0) < 0 );
   
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

   bool closeBuyCondition = ( get2Factor(0) < 0 ); 
   bool closeSellCondition = (  get2Factor(0) > 0 );
   
   
   if (total_orders == 0) return CloseWAIT;
   
   if (total_orders > 0 && closeBuyCondition){
      return CloseBuy;
   }
   
   if (total_orders < 0 && closeSellCondition ){
      return CloseSell;
   }
   return CloseWAIT;
}


double get2Factor(int shift){
   double value = iCustom(NULL, 0, "myIndicators\\2-factor",MaFastPeriod,MaFastMethod,MaFastPrice,MaMediumPeriod,MaMediumMethod,MaMediumPrice,MaHighPeriod,MaHighMethod,MaHighPrice,MaLowPeriod,MaLowMethod,MaLowPrice,SignalSize,Corner,ShiftToTheLeft,ShiftToTheRight,6, shift);
   return value;
}