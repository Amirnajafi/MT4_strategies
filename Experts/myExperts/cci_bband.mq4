//+------------------------------------------------------------------+
//|                                                      CCI_BB_EA.mq4|
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input int BBPeriod = 20;
input double BBDeviation = 2.0;
input int CCIPeriod = 14;
input double StopLoss = 30;
input double TakeProfit = 60;
#define MAGICMA 20131111
//--- Inputs
input double Lots = 0.1;
input double MaximumRisk = 0.02;
input double DecreaseFactor = 3;
input int MovingPeriod = 12;
input int MovingShift = 6;

extern double OrderShift = 5;
extern string IndicatorName = "myIndicators\\forex-pro-shadow-indicator";

// indicator params
extern int JOKERTIMING = 2020; // 105;//21;
//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
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
double LotsOptimized()
{
    double lot = Lots;
    int orders = HistoryTotal(); // history orders total
    int losses = 0;              // number of losses orders without a break
                                 //--- select lot size
    lot = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 1000.0, 1);
    //--- calcuulate number of losses orders without a break
    if (DecreaseFactor > 0)
    {
        for (int i = orders - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false)
            {
                Print("Error in history!");
                break;
            }
            if (OrderSymbol() != Symbol() || OrderType() > OP_SELL)
                continue;
            //---
            if (OrderProfit() > 0)
                break;
            if (OrderProfit() < 0)
                losses++;
        }
        if (losses > 1)
            lot = NormalizeDouble(lot - lot * losses / DecreaseFactor, 1);
    }
    //--- return lot size
    if (lot < 0.1)
        lot = 0.1;
    return (lot);
}
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Indicator buffers are automatically created by the terminal
    return (INIT_SUCCEEDED);
}

void CheckAndCloseOrder(int orderType)
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol() && OrderMagicNumber() == 0)
        {
            if (OrderType() == orderType)
            {
                if (!OrderClose(OrderTicket(), OrderLots(), Bid, 3, White))
                    Print("OrderClose error ", GetLastError());
            }
        }
    }
}

void CheckForOpen()
{
    int res;
    //--- go trading only for first tiks of new bar
    if (Volume[0] > 1)
        return;

    bool buyCondition = iCustom(NULL, 0, IndicatorName, JOKERTIMING, 5, OrderShift) > 0;
    bool sellCondition = iCustom(NULL, 0, IndicatorName, JOKERTIMING, 6, OrderShift) > 0;

    //--- sell conditions
    if (sellCondition)
    {
        res = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 3, 0, 0, "", MAGICMA, 0, Red);
        return;
    }
    //--- buy conditions
    if (buyCondition)
    {
        res = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 3, 0, 0, "", MAGICMA, 0, Blue);
        return;
    }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Bollinger Bands calculation
    double upperBB = iBands(Symbol(), 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
    double lowerBB = iBands(Symbol(), 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, 0);

    // CCI calculation
    double cci = iCCI(Symbol(), 0, CCIPeriod, PRICE_CLOSE, 0);

    // Check for existing orders and close them if opposite condition is met
    if (OrdersTotal() > 0)
    {
        if (cci > 100 && Close[1] > upperBB)
        {
            CheckAndCloseOrder(OP_BUY);
        }
        else if (cci < -100 && Close[1] < lowerBB)
        {
            CheckAndCloseOrder(OP_SELL);
        }
    }

    // If there are no open orders, check conditions to open a new order
    if (OrdersTotal() == 0)
    {
        //--- go trading only for first tiks of new bar
        if (Volume[0] > 1)
            return;
        // Check for buy conditions
        if (cci < -100 && Close[1] < lowerBB)
        {
            // SendOrder(OP_BUY, Lots, StopLoss, TakeProfit);
            int res = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 3, 0, 0, "", MAGICMA, 0, Blue);
            return;
        }
        // Check for sell conditions
        else if (cci > 100 && Close[1] > upperBB)
        {
            // SendOrder(OP_SELL, Lots, StopLoss, TakeProfit);
            int res = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 3, 0, 0, "", MAGICMA, 0, Red);
            return;
        }
    }
}
//+------------------------------------------------------------------+
// Use this function when sending an order
// For buy orders:

// For sell orders:
