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


#define MAGICMA  2024512

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
input int EntryBuyBlueCandle = 1;
input int EntryBuyRedCandle = 5;
input int EntrySellRedCandle = 1;
input int EntrySellBlueCandle = 5;
input int ExitBuyBlueCandle = 2;
input int ExitBuyRedCandle = 2;
input int ExitSellRedCandle = 2;
input int ExitSellBlueCandle = 2;
input int TrendLinePeriod = 7;


// Internal PARAMETERS
double TicketNumber;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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


//   bool BuyCondition = ( getTrendLine(6) < 0 && getTrendLine(5) < 0 && getTrendLine(4) < 0 && getTrendLine(3) < 0 && getTrendLine(2) > 0 && getTrendLine(1) > 0)); 
//   bool SellCondition = ( getTrendLine(6) > 0 && getTrendLine(5) > 0 && getTrendLine(4) > 0 && getTrendLine(3) > 0 && getTrendLine(2) > 0 && getTrendLine(1) < 0);
   
   bool BuyCondition = ( getTrendLineCountConditions(EntryBuyBlueCandle,0,1) && getTrendLineCountConditions(EntryBuyRedCandle,EntryBuyBlueCandle ,-1) ); 
   bool SellCondition = ( getTrendLineCountConditions(EntrySellRedCandle,0,-1) && getTrendLineCountConditions(EntrySellBlueCandle,EntrySellRedCandle,1) );
   
   if (BuyCondition){
      return BUY;
   }else if (SellCondition){
      return SELL;
   }else{
      return WAIT;
   }

/*   
   if (getRibonBlue(3) && getRibonBlue(2) && getRibonBlue(1) && getTrendLine(1) > 0 &&  getRibonBlueHeight(1) > Point() * 1){
      return BUY;
   }else if (getRibonRed(3) && getRibonRed(2) && getRibonRed(1) && getTrendLine(1) < 0 && getRibonRedHeight(1) > Point() * 1){
      return SELL;
   }else{
      return WAIT;
   }
*/
}  

ExitStatus getExitStatus(){
   int total_orders = CalculateCurrentOrders(MAGICMA);
//   bool closeBuyCondition = ( getRibonRed(2) && getRibonRed(1) && getTrendLine(1) < 0 &&  getRibonRedHeight(1) > Point() * 1);
//   bool closeSellCondition = (getRibonBlue(2) && getRibonBlue(1) && getTrendLine(1) > 0 && getRibonBlueHeight(1) > Point() * 1 ); 

   bool closeBuyCondition = ( getTrendLineCountConditions(ExitBuyRedCandle,0,-1) && getTrendLineCountConditions(ExitBuyBlueCandle,ExitBuyRedCandle,1) ); 
   bool closeSellCondition = (  getTrendLineCountConditions(ExitSellBlueCandle,0,1) && getTrendLineCountConditions(ExitSellRedCandle,ExitSellBlueCandle,-1) );
   
   
   if (total_orders == 0) return CloseWAIT;
   
   if (total_orders > 0 && closeBuyCondition){
      return CloseBuy;
   }
   
   if (total_orders < 0 && closeSellCondition ){
      return CloseSell;
   }
   return CloseWAIT;
}


  
  
  
  
  
double getTrendLineCountConditions(int number ,int shift = 1, int cnd = 1){
   bool condition = true;
   for(int i=1; i < number; i++) {
      double value = getTrendLine(i+shift);
      if (cnd == 1){
         if (value < 0) condition = false;
      }
      if (cnd == -1){
         if (value > 0) condition = false;
      }
   }
   return condition;
}

  
double getRibonBlue(int shift){
   // buffer 13 is for the trend line 0 for wait 1 for buy -1 for sell 
   // buffer 5 is the trend up bound  line 
   // buffer 6 is the trend down bound line
   // ribbon up is 0
   // ribbon down is 1
   double value  = iCustom(NULL, 0, "myIndicators\\x-xardfx" ,2, shift);
   if (value == EMPTY_VALUE){
     return 0;
   }
   return value;
}


double getRibonRed(int shift){
   double value = iCustom(NULL, 0, "myIndicators\\x-xardfx",1, shift);
   if(value == EMPTY_VALUE){
      return 0;
   }
   return value;
}

double getTrendLine(int shift){
   double value = iCustom(NULL, 0, "myIndicators\\x-xardfx" , TrendLinePeriod,30, shift);
   if(value == EMPTY_VALUE){
      return 0;
   }
   return value;
}


double getRibonRedHeight(double shift){
   double value = iCustom(NULL, 0, "myIndicators\\x-xardfx",5, shift);
   double value2 = iCustom(NULL, 0, "myIndicators\\x-xardfx",10, shift);
   double height = (value  - value2);   
   return height;
}

double getRibonBlueHeight(double shift){
   double value = iCustom(NULL, 0, "myIndicators\\x-xardfx",6, shift);
   double value2 = iCustom(NULL, 0, "myIndicators\\x-xardfx",11, shift);
   double height = (value2  - value);
   return height;
}