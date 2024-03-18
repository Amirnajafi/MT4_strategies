//+------------------------------------------------------------------+
//|                                                        utils.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict


#include <MQLTA ErrorHandling.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
int CalculateCurrentOrders(int MAGICMA)
{
    int buys = 0, sells = 0;
    //---
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            break;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA)
        {
            if (OrderType() == OP_BUY)
                buys++;
            if (OrderType() == OP_SELL)
                sells++;
        }
    }
    //--- return orders volume
    if (buys > 0)
        return (buys);
    else
        return (-sells);
}


//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized(double Lots , double MaximumRisk ,double DecreaseFactor)
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
  }


void CloseAll(int Command , int MagicNumber , double Slippage )
{
   const int OP_ALL = -1;
   // If the command is OP_ALL then run the CloseAll function for both BUY and SELL orders
   if (Command == OP_ALL)
   {
      CloseAll(OP_BUY , MagicNumber , Slippage);
      CloseAll(OP_SELL , MagicNumber , Slippage);
      return;
   }
   double ClosePrice = 0;
   // Scan all the orders to close them individually
   // NOTE that the for loop scans from the last to the first, this is because when we close orders the list of orders is updated
   // hence the for loop would skip orders if we scan from first to last
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      // First select the order individually to get its details, if the selection fails print the error and exit the function
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
      {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
      }
      // Check if the order is for the current symbol and was opened by the EA and is the type to be closed
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == Command)
      {
         // Define the close price
         RefreshRates();
         if (Command == OP_BUY)
            ClosePrice = Bid;
         if (Command == OP_SELL)
            ClosePrice = Ask;
         // Get the position size and the order identifier (ticket)
         double Lots = OrderLots();
         int Ticket = OrderTicket();
         // Close the individual order
         CloseOrder(Ticket, Lots, ClosePrice,Slippage);
      }
   }
}



// Close Single Order Function adjusted to handle errors and retry multiple times
void CloseOrder(int Ticket, double Lots, double CurrentPrice , double Slippage)
{
   // Try to close the order by ticket number multiple times in case of failure
   for (int i = 1; i <= 10; i++)
   {
      // Send the close command
      bool res = OrderClose(Ticket, Lots, CurrentPrice, Slippage,clrCyan);
      // If the close was successful print the resul and exit the function
      if (res)
      {
         Print("TRADE - CLOSE SUCCESS - Order ", Ticket, " closed at price ", CurrentPrice);
         break;
      }
      // If the close failed print the error
      else
      {
         int Error = GetLastError();
         string ErrorText = GetLastErrorText(Error);
         Print("ERROR - CLOSE FAILED - error closing order ", Ticket, " return error: ", Error, " - ", ErrorText);
      }
   }
   return;
}



// Stop Loss Price Calculation if dynamic
double StopLossPriceCalculate(int Command = -1 , int ATRPeriod = 20 , double ATRMultiplier = 2)
{
   double StopLossPrice = 0;
   // Include a value for the stop loss, ideally coming from an indicator
   double ATRCurr = iATR(Symbol(), PERIOD_CURRENT, ATRPeriod, 1); // Previous value of the ATR indicator
   if (Command == OP_BUY)
      StopLossPrice = Bid - ATRCurr * ATRMultiplier;
   if (Command == OP_SELL)
      StopLossPrice = Ask + ATRCurr * ATRMultiplier;

   return StopLossPrice;
}

// Take Profit Price Calculation if dynamic
double TakeProfitCalculate(int Command = -1 , int ATRPeriod = 20, double ATRMultiplier = 2)
{
   double TakeProfitPrice = 0;
   // Include a value for the take profit, ideally coming from an indicator
   double ATRCurr = iATR(Symbol(), PERIOD_CURRENT, ATRPeriod, 1); // Previous value of the ATR indicator
   if (Command == OP_BUY)
      TakeProfitPrice = Bid + ATRCurr * ATRMultiplier;
   if (Command == OP_SELL)
      TakeProfitPrice = Ask - ATRCurr * ATRMultiplier;

   return TakeProfitPrice;
}

